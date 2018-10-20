//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-26
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact.view.soul {

import QFLib.Utils.FileType;
import QFLib.Utils.HtmlUtil;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.artifact.CArtifactEvent;
import kof.game.artifact.CArtifactHandler;
import kof.game.artifact.CArtifactManager;
import kof.game.artifact.data.CArtifactSoulData;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.table.ArtifactColour;
import kof.table.ArtifactSoulQuality;
import kof.ui.master.Artifact.ArtifactBreachUI;
import kof.util.CQualityColor;

/**
 * 神灵突破面板
 *@author tim
 *@create 2018-05-26 12:23
 **/
public class CArtifactSoulBreachPanel {
    private var _m_pData:CArtifactSoulData;
    private var _m_uiView:ArtifactBreachUI;
    private var _m_pSystem:CAppSystem;
    private var _m_pAttrPanelCurr:CArtifactSoulAttrPanel;
    private var _m_pAttrPanelResult:CArtifactSoulAttrPanel;
    private var _m_pAttrPanelSuccess:CArtifactSoulAttrPanel;

    private var _m_iOwnStoneCount:int;
    private var _m_iNeedStoneCount:int;
    public function CArtifactSoulBreachPanel(system: CAppSystem, uiView: ArtifactBreachUI) {
        _m_uiView = uiView;
        _m_pSystem = system;
        _m_pAttrPanelCurr = new CArtifactSoulAttrPanel(_m_pSystem, _m_uiView.uiBoxCurr, false, false);
        _m_pAttrPanelResult = new CArtifactSoulAttrPanel(_m_pSystem, _m_uiView.uiBoxResult, false, true);
        _m_pAttrPanelSuccess = new CArtifactSoulAttrPanel(_m_pSystem, _m_uiView.uiBoxSuccess, false, false);
    }

    public function addEventListeners():void {
        _m_uiView.uiBtnBreach.addEventListener(MouseEvent.CLICK, _onBtnClick);
        _m_uiView.uiBtnPurify.addEventListener(MouseEvent.CLICK, _onBtnClick);
        _m_uiView.uiNumFighting.addEventListener(Event.CHANGE, _onNumChange);
        _m_uiView.uiBtnBreach.addEventListener(MouseEvent.ROLL_OVER, _onBtnOver);
        _m_uiView.uiLabelCost.addEventListener(TextEvent.LINK, _onTextLink);
    }

    public function removeEventListeners():void {
        _m_uiView.uiBtnBreach.removeEventListener(MouseEvent.CLICK, _onBtnClick);
        _m_uiView.uiBtnPurify.removeEventListener(MouseEvent.CLICK, _onBtnClick);
        _m_uiView.uiNumFighting.removeEventListener(Event.CHANGE, _onNumChange);
        _m_uiView.uiBtnBreach.removeEventListener(MouseEvent.ROLL_OVER, _onBtnOver);
        _m_uiView.uiLabelCost.removeEventListener(TextEvent.LINK, _onTextLink);
    }

    private function _onTextLink( event : TextEvent ) : void {
        m_pManager.openShop();
    }

    private function _onBtnOver( event : MouseEvent ) : void {
        if (!_m_pData.isShowBreachResult) {
            _m_uiView.uiBoxResult.visible = true;
            _m_uiView.uiBoxTips.visible = false;
        }
    }

    private function _onNumChange( event : Event ) : void {
        _m_uiView.uiBoxFighting.x = _m_uiView.uiBtnPurify.x + _m_uiView.uiBtnPurify.width * 0.5 - _m_uiView.uiBoxFighting.width * 0.5;
    }

    private function _onBtnClick( event : MouseEvent ) : void {
        switch (event.currentTarget) {
            case _m_uiView.uiBtnPurify:
                _m_pData.isShowBreachResult = false;
                _m_pSystem.dispatchEvent( new CArtifactEvent(CArtifactEvent.ARTIFACTUPDATE,null));
                break;
            case _m_uiView.uiBtnBreach:
                m_pHandler.artifactSoulBreachRequest(_m_pData.artifactID, _m_pData.artifactSoulID);
                break;
        }
    }

    public function update(data: CArtifactSoulData):void
    {
        _m_pData = data;
        var isShow:Boolean = data.isCanBreakByAttr || data.isShowBreachResult;
        _m_uiView.visible = isShow;
        if (!isShow) {
            _m_uiView.uiBoxResult.visible = false;
            _m_uiView.uiBoxTips.visible = true;
            return;
        }

        if (data.isShowBreachResult) {//已突破成功，显示突破后界面
            _m_uiView.uiBoxCurr.visible = false;
            _m_uiView.uiBoxResult.visible = false;
            _m_uiView.uiBoxSuccess.visible = true;
            _m_uiView.uiLabelSuccess.visible = true;
            _m_uiView.uiBtnBreach.visible = false;
            _m_uiView.uiBtnPurify.visible = true;
            _m_pAttrPanelSuccess.update(_m_pData);
            _m_uiView.uiImgArrow.visible = false;
            _m_uiView.uiBoxTips.visible = false;
            _m_uiView.uiBoxCost.visible = false;
            _m_uiView.uiLabelSuccess.visible = true;
        } else { //突破前界面
            _m_uiView.uiBoxCurr.visible = true;
            _m_uiView.uiBoxResult.visible = true;
            _m_uiView.uiBoxSuccess.visible = false;
            _m_uiView.uiLabelSuccess.visible = false;
            _m_uiView.uiBtnBreach.visible = true;
            _m_uiView.uiBtnPurify.visible = false;
            _m_pAttrPanelCurr.update(_m_pData);
            _m_pAttrPanelResult.update(_m_pData);
            _m_uiView.uiImgArrow.visible = true;
            _m_uiView.uiBoxCost.visible = true;
            _m_uiView.uiLabelSuccess.visible = false;

            //显示突破石ICON
            var stoneIconUrl:String = "icon/artifact/breakthroughIcon/" + _m_pData.qualityCfg.breakItem + "." + FileType.PNG;
            _m_uiView.img_stoneIcon.skin = stoneIconUrl;

            //显示突破石数量
            var qualityCfg:ArtifactSoulQuality = _m_pData.qualityCfg;
            var bagData:CBagData = (_m_pSystem.stage.getSystem(CBagSystem).getBean(CBagManager) as CBagManager).getBagItemByUid(qualityCfg.breakItem);
            _m_iOwnStoneCount  = bagData != null ? bagData.num : 0;
            _m_iNeedStoneCount = qualityCfg.nums;
            var costItemName:String = HtmlUtil.hrefAndU(_m_pData.breackCostItemCfg.name, _m_pData.breackCostItemCfg.ID.toString(), CQualityColor.getColorByQuality(_m_pData.breackCostItemCfg.quality - 1));
            _m_uiView.uiBtnBreach.disabled = _m_iOwnStoneCount < _m_iNeedStoneCount;

            App.render.callLater(function():void {
                _m_uiView.uiLabelCost.textField.styleSheet = HtmlUtil.hrefSheet;
                _m_uiView.uiLabelCost.textField.text = CLang.Get("artifact_soul_breach_item_num",{itemName: costItemName, cost:_m_iNeedStoneCount,  own: _m_iOwnStoneCount});
            });

            //显示突破说明
            var rate:int = m_pManager.constantCfg.soulBreakRate * 0.01;
            var soulName:String = _m_pData.htmlName;
            var colorTable:IDataTable = (_m_pSystem.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ARTIFACTCOLOUR);
            var colorCfgOfNext:ArtifactColour = (colorTable.findByPrimaryKey(_m_pData.quality + 2) as ArtifactColour);
            var colorNameOfNext:String = HtmlUtil.color(colorCfgOfNext.qualityColour, colorCfgOfNext.colour.replace("0x", "#"));
            _m_uiView.uiLabelTips.text = CLang.Get("artifact_soul_breach_desc", {rate: rate, soulName: soulName, colorName: colorNameOfNext});
        }

        //显示战力
        _m_uiView.uiNumFighting.num = data.getFighting(false);
    }

    private function get m_pHandler():CArtifactHandler {
        return (_m_pSystem.getHandler(CArtifactHandler) as CArtifactHandler);
    }

    private function get m_pManager():CArtifactManager {
        return (_m_pSystem.getBean(CArtifactManager) as CArtifactManager);
    }
}
}
