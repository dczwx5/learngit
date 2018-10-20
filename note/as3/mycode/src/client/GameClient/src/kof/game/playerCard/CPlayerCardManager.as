//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/9.
 */
package kof.game.playerCard {

import QFLib.Foundation.CMap;

import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.CPlayerHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerUIHandler;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndType;
import kof.game.playerCard.data.CPlayerCardData;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.playerCard.util.ECardPoolType;
import kof.game.playerCard.util.ECardResultType;
import kof.game.playerCard.util.ECardViewType;
import kof.game.playerCard.util.EPlayerCardEventType;
import kof.game.playerCard.view.CPlayerCardViewHandler;
import kof.message.CardPlayer.CardPlayerFreeResponse;
import kof.message.CardPlayer.CardPlayerOpenResponse;
import kof.message.CardPlayer.CardPlayerResponse;
import kof.table.Item;

public class CPlayerCardManager extends CAbstractHandler {

    private var m_pResultArr:Array = [];// 单抽或者N连抽结果
    private var m_pFreeResultArr:Array = [];// 免费抽卡结果
    private var m_iCurrFreeNum:int = -1;// 当前免费抽卡次数
    private var m_fFreeExpiredTime:Number = 0;// 免费抽卡到期时间戳
    private var m_pCurrNumMap:CMap;// 每个卡池抽卡次数信息
    private var m_bIsFirstShowA:Boolean;// 是否显示首个第20次必送A级格斗家信息
    private var m_bIsInitData:Boolean;// 是否初始化数据
    private var m_sMailContent:String;// 信封内容

    public function CPlayerCardManager()
    {
        super();
    }

    override protected virtual function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        return ret;
    }

    /**
     * 抽卡返回数据
     * @param response
     */
    public function updateData(response:CardPlayerResponse):void
    {
        m_pResultArr.length = 0;

        for each(var obj:Object in response.dataMap)
        {
            var cardData:CPlayerCardData = new CPlayerCardData();
            cardData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            if(obj.hasOwnProperty("count"))
            {
                obj["itemNum"] = obj["count"];
                delete obj["count"];
            }

            cardData.updateDataByData(obj);
            m_pResultArr.push(cardData);
        }

        if(m_pCurrNumMap == null)
        {
            m_pCurrNumMap = new CMap();
        }

        m_pCurrNumMap.add(response.poolID,response.number,true);

        m_bIsFirstShowA = response.isShow;

        (system.getHandler(CPlayerCardViewHandler ) as CPlayerCardViewHandler).updateCurrCount();
    }

    /**
     * 免费抽卡返回数据
     * @param response
     */
    public function updateFreeData(response:CardPlayerFreeResponse):void
    {
        m_pFreeResultArr.length = 0;

        var obj:Object = {};
        obj.itemID = response.itemID;
        obj.itemNum = response.count;
        obj["display"] = response["display"];

        var cardData:CPlayerCardData = new CPlayerCardData();
        cardData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        cardData.updateDataByData(obj);
        var itemTableData:Item = _itemTable.findByPrimaryKey(response.itemID) as Item;
        cardData.star = itemTableData == null ? 0 : int(itemTableData.param2);

        m_pFreeResultArr.push(cardData);

        m_iCurrFreeNum = response.number;
        m_fFreeExpiredTime = response.timestamp;

        if(m_pCurrNumMap == null)
        {
            m_pCurrNumMap = new CMap();
        }

        var currNum:int = m_pCurrNumMap.find(ECardPoolType.Type_Common) as int;
        m_pCurrNumMap.add(ECardPoolType.Type_Common, currNum + 1, true);

        (system.getHandler(CPlayerCardViewHandler ) as CPlayerCardViewHandler).updateCurrCount();
        system.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EPlayerCardEventType.UpdateCDTime,null));
    }

    /**
     * 界面初始化数据
     * @param response
     */
    public function updateOpenData(response:CardPlayerOpenResponse):void
    {
        if(m_pCurrNumMap == null)
        {
            m_pCurrNumMap = new CMap();
        }

        m_bIsInitData = true;

        m_pCurrNumMap.add(ECardPoolType.Type_Common, response.number1, true);
        m_pCurrNumMap.add(ECardPoolType.Type_Better, response.number2, true);
        m_pCurrNumMap.add(ECardPoolType.Type_Active, response.number3, true);

        m_bIsFirstShowA = response.isShow;

        if((system.getHandler(CPlayerCardViewHandler ) as CPlayerCardViewHandler).isViewShow)
        {
            (system.getHandler(CPlayerCardViewHandler ) as CPlayerCardViewHandler).updateCurrCount();
        }

        m_fFreeExpiredTime = response.timestamp;
        m_iCurrFreeNum = response.freeNumber;
        system.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EPlayerCardEventType.UpdateCDTime,null));
    }

    /**
     * 抽卡数据
     */
    public function get cardResultData():Array
    {
        return m_pResultArr;
    }

    public function get cardFreeResultData():Array
    {
        return m_pFreeResultArr;
    }

    /**
     * 当前免费抽卡次数
     */
    public function get currFreeNum():int
    {
        return m_iCurrFreeNum;
    }

    public function get freeExpiredTime():Number
    {
        return m_fFreeExpiredTime;
    }

    public function get currNumMap():CMap
    {
        if(m_pCurrNumMap == null)
        {
            m_pCurrNumMap = new CMap();
        }

        return m_pCurrNumMap;
    }


    public function get isFirstShowA():Boolean
    {
        return m_bIsFirstShowA;
    }

    public function get isInitData():Boolean
    {
        return m_bIsInitData;
    }

    public function get mailContent():String
    {
        return m_sMailContent;
    }

    public function set mailContent(value:String):void
    {
        m_sMailContent = value;
    }

    override public function dispose():void
    {
        m_pResultArr.length = 0;
        m_pFreeResultArr.length = 0;
        m_iCurrFreeNum = 0;
        m_fFreeExpiredTime = 0;

        if(m_pCurrNumMap)
        {
            m_pCurrNumMap.clear();
        }
    }

//==========================================table==================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _itemTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ITEM);
    }
}
}
