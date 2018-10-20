//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard {

import QFLib.Foundation.CMap;

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.equipCard.util.CEquipCardUtil;
import kof.game.equipCard.view.CEquipCardViewHandler;
import kof.game.playerCard.data.CPlayerCardData;
import kof.game.playerCard.util.ECardPoolType;
import kof.message.EquipCard.EquipCardOpenResponse;
import kof.message.EquipCard.EquipCardResponse;

public class CEquipCardManager extends CAbstractHandler {

    private var m_pResultArr:Array = [];// 单抽或者N连抽结果
//    private var m_pFreeResultArr:Array = [];// 免费抽卡结果
//    private var m_iCurrFreeNum:int;// 当前免费抽卡次数
//    private var m_fFreeExpiredTime:Number = 0;// 免费抽卡到期时间戳
    private var m_pCurrNumMap:CMap;// 每个卡池抽卡次数信息

    public function CEquipCardManager()
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
    public function updateData(response:EquipCardResponse):void
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

        (system.getHandler(CEquipCardViewHandler) as CEquipCardViewHandler).updateNumInfo();
    }

    /**
     * 免费抽卡返回数据
     * @param response
     */
    /*
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

        m_pFreeResultArr.push(cardData);

        m_iCurrFreeNum = response.number;
        m_fFreeExpiredTime = response.timestamp;
        system.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EPlayerCardEventType.UpdateCDTime,null));
    }
    */

    /**
     * 界面初始化数据
     * @param response
     */
    public function updateOpenData(response:EquipCardOpenResponse):void
    {
        if(m_pCurrNumMap == null)
        {
            m_pCurrNumMap = new CMap();
        }

        m_pCurrNumMap.add(ECardPoolType.Type_Common, response.number, true);

        (system.getHandler(CEquipCardViewHandler) as CEquipCardViewHandler).updateNumInfo();
    }

    /**
     * 抽卡数据
     */
    public function get cardResultData():Array
    {
        return m_pResultArr;
    }

    /*
    public function get cardFreeResultData():Array
    {
        return m_pFreeResultArr;
    }
    */

    /**
     * 当前免费抽卡次数
     */
    /*
    public function get currFreeNum():int
    {
        return m_iCurrFreeNum;
    }

    public function get freeExpiredTime():Number
    {
        return m_fFreeExpiredTime;
    }
    */

    public function get currNumMap():CMap
    {
        if(m_pCurrNumMap == null)
        {
            m_pCurrNumMap = new CMap();
        }

        return m_pCurrNumMap;
    }

    override public function dispose():void
    {
        m_pResultArr.length = 0;
//        m_pFreeResultArr.length = 0;
//        m_iCurrFreeNum = 0;
//        m_fFreeExpiredTime = 0;

        if(m_pCurrNumMap)
        {
            m_pCurrNumMap.clear();
        }
    }
}
}
