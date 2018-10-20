//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/18.
 */
package kof.game.guildWar.view {

import QFLib.Utils.HtmlUtil;

import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CLang;
import kof.game.currency.enum.ECurrencyType;
import kof.game.guildWar.CGuildWarHelpHandler;
import kof.game.guildWar.CGuildWarNetHandler;
import kof.game.guildWar.CGuildWarSystem;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.data.fightActivation.CGuildWarBuffData;
import kof.game.guildWar.data.fightActivation.CGuildWarBuffRecordData;
import kof.game.guildWar.enum.CGuildWarState;
import kof.game.guildWar.enum.EGuildWarBuffType;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CCurrencyData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.table.GuildWarBuff;
import kof.table.GuildWarBuff;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.ClubActiveUI;

import morn.core.components.Box;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.Label;
import morn.core.handlers.Handler;

/**
 * 战斗鼓舞界面
 */
public class CGuildWarInspireViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:ClubActiveUI;
    private var m_arrAttr:Array;

    public function CGuildWarInspireViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ ClubActiveUI];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new ClubActiveUI();

                m_pViewUI.btn_close.clickHandler = new Handler(_onClickCloseHandler);
                m_pViewUI.btn_common.clickHandler = new Handler(_onClickCommonHandler);
                m_pViewUI.btn_diamond.clickHandler = new Handler(_onClickDiamonHandler);
                m_pViewUI.list_attr.renderHandler = new Handler(_renderAttrListHandler);
                m_pViewUI.list_log.renderHandler = new Handler(_renderLogListHandler);

                m_pViewUI.list_attr.dataSource = [];
                m_pViewUI.list_log.dataSource = [];

                m_arrAttr = [CGuildWarBuffData.Hp, CGuildWarBuffData.Attack, CGuildWarBuffData.Defense];

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addPopupDialog( m_pViewUI );

        _initView();
        _addListeners();
        _reqInfo();
    }

    private function _addListeners():void
    {
        system.addEventListener(CGuildWarEvent.UpdateBuffInfo, _onUpdateBuffInfoHandler);
        system.addEventListener(CGuildWarEvent.UpdateBuffResponseInfo, _onBuffResponseHandler);
        m_pViewUI.btn_common.addEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.btn_common.addEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
        m_pViewUI.btn_diamond.addEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.btn_diamond.addEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CGuildWarEvent.UpdateBuffInfo, _onUpdateBuffInfoHandler);
        system.removeEventListener(CGuildWarEvent.UpdateBuffResponseInfo, _onBuffResponseHandler);
        m_pViewUI.btn_common.removeEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.btn_common.removeEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
        m_pViewUI.btn_diamond.removeEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.btn_diamond.removeEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
        }
    }

    private function _reqInfo():void
    {
        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarBuffInfoRequest();
    }

    private function _updateLeftCount():void
    {
        var tableData1:GuildWarBuff = _helper.getBuffTableData(EGuildWarBuffType.Type_Common);
        var tableData2:GuildWarBuff = _helper.getBuffTableData(EGuildWarBuffType.Type_Diamond);

        if(tableData1 && tableData2)
        {
            m_pViewUI.txt_bindNum.text = tableData1.currencyValue.toString();
            m_pViewUI.txt_unBindNum.text = tableData2.currencyValue.toString();

            m_pViewUI.txt_leftCount1.isHtml = true;
            m_pViewUI.txt_leftCount2.isHtml = true;

            var commonLimit:int = tableData1.countLimit;
            var diamondLimit:int = tableData2.countLimit;

            var buffData:CGuildWarBuffData = (system as CGuildWarSystem).data.buffData;
            if(buffData)
            {
                if(buffData.ordinaryBuffCount >= commonLimit)
                {
                    m_pViewUI.txt_leftCount1.text = "剩余次数" + HtmlUtil.color("0", "#ff0000") + "/" + commonLimit;
                }
                else
                {
                    var leftNum:int = commonLimit - buffData.ordinaryBuffCount;
                    m_pViewUI.txt_leftCount1.text = HtmlUtil.color("剩余次数"+leftNum+"/"+commonLimit, "#f0ecec");
                }

                if(buffData.diamondBuffCount >= diamondLimit)
                {
                    m_pViewUI.txt_leftCount2.text = "剩余次数" + HtmlUtil.color("0", "#ff0000") + "/" + diamondLimit;
                }
                else
                {
                    leftNum = diamondLimit - buffData.diamondBuffCount;
                    m_pViewUI.txt_leftCount2.text = HtmlUtil.color("剩余次数"+leftNum+"/"+diamondLimit, "#f0ecec");
                }
            }
        }
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }

            m_pViewUI.list_log.dataSource = [];
        }
    }

    private function _onClickCloseHandler():void
    {
        removeDisplay();
    }

    private function _onClickCommonHandler():void
    {
        var tableData1:GuildWarBuff = _helper.getBuffTableData(EGuildWarBuffType.Type_Common);

        if(tableData1)
        {
            var countLimit:int = tableData1.countLimit;
            if(_guildWarData.buffData.ordinaryBuffCount >= countLimit)
            {
                _uiSystem.showMsgAlert("次数不足",CMsgAlertHandler.WARNING);
                return;
            }
        }

        var tableData:GuildWarBuff = _helper.getBuffTableData(EGuildWarBuffType.Type_Common);
        var needNum:int = tableData == null ? 0 : tableData.currencyValue;
        var currencyType:int = tableData == null ? 0 : tableData.currencyType;
        var currencyData:CCurrencyData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.currency;
        var ownNum:int = currencyData.getValueByType(currencyType);
//        if(ownNum < needNum)
//        {
//            _uiSystem.showMsgAlert("绑钻不足",CMsgAlertHandler.WARNING);
//            return;
//        }

        var recipSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
        recipSystem.showCostBdDiamondMsgBox(needNum, function():void{
            if(CGuildWarState.isInInspire)
            {
                _uiSystem.showMsgAlert(CLang.Get("clientLockTips"),CMsgAlertHandler.WARNING);
                return;
            }

            (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarBuffRequest(EGuildWarBuffType.Type_Common);
            CGuildWarState.isInInspire = true;
        });
    }

    private function _onClickDiamonHandler():void
    {
        var tableData1:GuildWarBuff = _helper.getBuffTableData(EGuildWarBuffType.Type_Diamond);

        if(tableData1)
        {
            var countLimit:int = tableData1.countLimit;
            if(_guildWarData.buffData.diamondBuffCount >= countLimit)
            {
                _uiSystem.showMsgAlert("次数不足",CMsgAlertHandler.WARNING);
                return;
            }
        }

        var tableData:GuildWarBuff = _helper.getBuffTableData(EGuildWarBuffType.Type_Diamond);
        var needNum:int = tableData == null ? 0 : tableData.currencyValue;
        var currencyType:int = tableData == null ? 0 : tableData.currencyType;
        var currencyData:CCurrencyData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.currency;
        var ownNum:int = currencyData.getValueByType(currencyType);
        if(ownNum < needNum)
        {
            _uiSystem.showMsgAlert("钻石不足",CMsgAlertHandler.WARNING);
            return;
        }

        if(CGuildWarState.isInInspire)
        {
            _uiSystem.showMsgAlert(CLang.Get("clientLockTips"),CMsgAlertHandler.WARNING);
            return;
        }

        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarBuffRequest(EGuildWarBuffType.Type_Diamond);
        CGuildWarState.isInInspire = true;
    }

//监听=================================================================================================================
    private function _onUpdateBuffInfoHandler(e:CGuildWarEvent):void
    {
        m_pViewUI.list_attr.dataSource = m_arrAttr;

        if(_guildWarData && _guildWarData.buffData && _guildWarData.buffData.recordData)
        {
            m_pViewUI.list_log.dataSource = _guildWarData.buffData.recordData.list;
        }

        _updateLeftCount();
    }

    /**
     * 鼓舞成功
     * @param e
     */
    private function _onBuffResponseHandler(e:CGuildWarEvent):void
    {
        var buffData:CGuildWarBuffData = _guildWarData.buffData;
        var buffType:int = e.data as int;
        if(buffType == EGuildWarBuffType.Type_Common)
        {
            var tableData:GuildWarBuff = _helper.getBuffTableData(EGuildWarBuffType.Type_Common);
            if(buffData && tableData)
            {
                buffData.ordinaryBuffCount += 1;
                buffData.attack += tableData[CGuildWarBuffData.Attack];
                buffData.hp += tableData[CGuildWarBuffData.Hp];
                buffData.defense += tableData[CGuildWarBuffData.Defense];
            }
        }
        else if(buffType == EGuildWarBuffType.Type_Diamond)
        {
            tableData = _helper.getBuffTableData(EGuildWarBuffType.Type_Diamond);
            if(buffData && tableData)
            {
                buffData.diamondBuffCount += 1;
                buffData.hpPercent += tableData[CGuildWarBuffData.Hp];
                buffData.attackPercent += tableData[CGuildWarBuffData.Attack];
                buffData.defensePercent += tableData[CGuildWarBuffData.Defense];
            }
        }

        m_pViewUI.list_attr.refresh();
        _updateLeftCount();

        if(buffData && buffData.recordData)
        {
            var obj:Object = {};
            obj.buffType = buffType;
            obj.name = ((system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData).teamData.name;
            buffData.recordData.adddData(obj);

            m_pViewUI.list_log.refresh();
        }
    }

    private function _onRollOverHandler(e:MouseEvent):void
    {
        var type:int;
        if( e.target == m_pViewUI.btn_common)
        {
            type = EGuildWarBuffType.Type_Common;
        }
        else if(e.target == m_pViewUI.btn_diamond)
        {
            type = EGuildWarBuffType.Type_Diamond;
        }

        var tableData:GuildWarBuff = _helper.getBuffTableData(type);
        if(tableData)
        {
            var len:int = m_pViewUI.list_attr.cells.length;
            for(var i:int = 0; i < len; i++)
            {
                var cell:Box = m_pViewUI.list_attr.getCell(i);
                var txt_fixAddValue:Label = cell.getChildByName("txt_fixAddValue") as Label;
                var txt_globalAddValue:Label = cell.getChildByName("txt_globalAddValue") as Label;

                var attrName:String = cell.dataSource as String;
                if(attrName == null)
                {
                    continue;
                }

                if(type == EGuildWarBuffType.Type_Common)
                {
                    txt_fixAddValue.visible = true;
                    txt_fixAddValue.text = "+" + tableData[attrName];
                }
                else if(type == EGuildWarBuffType.Type_Diamond)
                {
                    txt_globalAddValue.visible = true;
                    var percentValue:Number = tableData[attrName] * 0.01;
                    var numberStr:String = percentValue % 1 == 0 ? percentValue.toString() : percentValue.toFixed(2);
                    txt_globalAddValue.text = numberStr + "%";
                }
            }
        }
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
        var len:int = m_pViewUI.list_attr.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var cell:Box = m_pViewUI.list_attr.getCell(i);
            var txt_fixAddValue:Label = cell.getChildByName("txt_fixAddValue") as Label;
            var txt_globalAddValue:Label = cell.getChildByName("txt_globalAddValue") as Label;
            txt_fixAddValue.visible = false;
            txt_globalAddValue.visible = false;
        }
    }

//render===============================================================================================================
    private function _renderAttrListHandler(item:Component, index:int):void
    {
        var render:Box = item as Box;
        var data:String = item.dataSource as String;

        var txt_attrName:Label = render.getChildByName("txt_attrName") as Label;
        var txt_attrFixValue:Label = render.getChildByName("txt_attrFixValue") as Label;
        var txt_fixAddValue:Label = render.getChildByName("txt_fixAddValue") as Label;
        var txt_globalValue:Label = render.getChildByName("txt_globalValue") as Label;
        var txt_globalAddValue:Label = render.getChildByName("txt_globalAddValue") as Label;

        txt_fixAddValue.visible = false;
        txt_globalAddValue.visible = false;

        var buffData:CGuildWarBuffData = (system as CGuildWarSystem).data.buffData;
        if(render && data && buffData)
        {
            txt_attrName.text = _getAttrNameCN(data);
            txt_attrFixValue.text = buffData[data] + "";
            var percentName:String = data + "Percent";
            var percentValue:Number = buffData[percentName] * 0.01;
            var numberStr:String = percentValue % 1 == 0 ? percentValue.toString() : percentValue.toFixed(2);
            txt_globalValue.text = numberStr + "%";
        }
        else
        {
            txt_attrName.text = "";
            txt_attrFixValue.text = "";
            txt_fixAddValue.text = "";
            txt_globalValue.text = "";
            txt_globalAddValue.text = "";
        }
    }

    private function _getAttrNameCN(attrNameEN:String):String
    {
        var name:String = "";
        if(attrNameEN == CGuildWarBuffData.Hp)
        {
            name = CBasePropertyData._HP;
        }

        if(attrNameEN == CGuildWarBuffData.Attack)
        {
            name = CBasePropertyData._Attack;
        }

        if(attrNameEN == CGuildWarBuffData.Defense)
        {
            name = CBasePropertyData._Defense;
        }

        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;

        return playerData.globalProperty.getAttrNameCN(name);
    }

    private function _renderLogListHandler(item:Component, index:int):void
    {
        var render : Box = item as Box;
        var data : CGuildWarBuffRecordData = item.dataSource as CGuildWarBuffRecordData;

        var txt_name:Label = render.getChildByName("txt_name") as Label;
        var txt_desc:Label = render.getChildByName("txt_desc") as Label;

        if(data)
        {
            txt_name.text = data.name;
            txt_desc.text = data.buffType == EGuildWarBuffType.Type_Common ? "进行了一次绑钻鼓舞" : "进行了一次钻石鼓舞";
        }
        else
        {
            txt_name.text = "";
            txt_desc.text = "";
        }
    }

//property=============================================================================================================
    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _helper():CGuildWarHelpHandler
    {
        return system.getHandler(CGuildWarHelpHandler) as CGuildWarHelpHandler;
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get _guildWarData():CGuildWarData
    {
        return (system as CGuildWarSystem).data;
    }
}
}
