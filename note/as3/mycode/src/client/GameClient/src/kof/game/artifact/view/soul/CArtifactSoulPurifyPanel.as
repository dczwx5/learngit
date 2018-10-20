//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-26
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact.view.soul {

import QFLib.Utils.HtmlUtil;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.artifact.CArtifactHandler;
import kof.game.artifact.CArtifactManager;
import kof.game.artifact.data.CArtifactSoulData;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.table.ArtifactConstant;
import kof.table.Item;
import kof.ui.CUISystem;
import kof.ui.master.Artifact.ArtifactPurifyUI;
import kof.util.CQualityColor;

/**
 * 神灵洗炼面板
 *@author tim
 *@create 2018-05-26 12:17
 **/
public class CArtifactSoulPurifyPanel {
    private var _m_uiView:ArtifactPurifyUI;
    private var _m_pSystem:CAppSystem;
    private var _m_pAttrPanelCurr:CArtifactSoulAttrPanel;
    private var _m_pAttrPanelResult:CArtifactSoulAttrPanel;
    private var _m_pData:CArtifactSoulData;

    private var _m_iOwnStoneCount:int;
    private var _m_iNeedStoneCount:int;
    private var _m_rootView : CArtifactSoulStrengthenView;
    public function CArtifactSoulPurifyPanel(system: CAppSystem, uiView: ArtifactPurifyUI,rootView : CArtifactSoulStrengthenView) {
        _m_uiView = uiView;
        _m_pSystem = system;
        _m_rootView = rootView;
        _m_pAttrPanelCurr = new CArtifactSoulAttrPanel(_m_pSystem, _m_uiView.uiBoxCurr, false, false);
        _m_pAttrPanelResult = new CArtifactSoulAttrPanel(_m_pSystem, _m_uiView.uiBoxResult, true, false);
    }

    public function addEventListeners():void {
        _m_uiView.uiBtnPurify.addEventListener(MouseEvent.CLICK, _onBtnClick);
        _m_uiView.uiBtnSave.addEventListener(MouseEvent.CLICK, _onBtnClick);
        _m_uiView.uiNumCurrFighting.addEventListener(Event.CHANGE, _onNumChange);
        _m_uiView.uiNumResultFighting.addEventListener(Event.CHANGE, _onNumChange);
        _m_uiView.txt_my_stone_vale.addEventListener(TextEvent.LINK, _onTextLink);
    }

    public function removeEventListeners():void {
        _m_uiView.uiBtnPurify.removeEventListener(MouseEvent.CLICK, _onBtnClick);
        _m_uiView.uiBtnSave.removeEventListener(MouseEvent.CLICK, _onBtnClick);
        _m_uiView.uiNumCurrFighting.removeEventListener(Event.CHANGE, _onNumChange);
        _m_uiView.uiNumResultFighting.removeEventListener(Event.CHANGE, _onNumChange);
        _m_uiView.txt_my_stone_vale.removeEventListener(TextEvent.LINK, _onTextLink);
    }

    private function _onTextLink( event : TextEvent ) : void {
        m_pManager.openShop();
    }

    private function _onNumChange( event : Event ) : void {
        _m_uiView.uiBoxCurrFighting.centerX = 0;
        _m_uiView.uiBoxResultFighting.centerX = 12;
        _m_uiView.uiClipFightingResult.x = _m_uiView.uiNumResultFighting.x + _m_uiView.uiNumResultFighting.width + 6;
    }

    private function _onBtnClick( event : MouseEvent ) : void {
        switch (event.currentTarget) {
            case _m_uiView.uiBtnPurify:
                if (_m_iOwnStoneCount < _m_iNeedStoneCount )
                {
                    (_m_pSystem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.Get("playerCard_prop_notEnough"));
                    return;
                }
                _checkRequest();
                break;
            case _m_uiView.uiBtnSave:
                m_pHandler.propertyReplaceRequest(_m_pData.artifactID, _m_pData.artifactSoulID);
                break;
        }
    }
    //洗练增加二次确认框，可突破提示
    //=========add by Lune 0710======================
    private function _checkRequest() : void
    {
        var newScale : int = 0;
        var standard : int = Math.floor(m_pManager.constantCfg.soulBreakRate * 0.01);
        var isBreach : Boolean;
        var tisStr : String;
        for(var i : int = 0; i < _m_pData.scaleValue.length; i++)
        {
            if(!_m_pData || !_m_pData.scaleValue[i] || !_m_pData.newScaleValue)
                break;
            newScale = _m_pData.scaleValue[i] + _m_pData.newScaleValue[i];
            if(newScale < standard)
            {
                isBreach = false;//3条属性有一条未达标就pass
                break;
            }
            isBreach = true;
        }
        if(isBreach)
        {
            tisStr = CLang.Get("artifact_prompt_2");//保存后可突破啦，建议保存哦！
            _m_rootView.uiCanvas.showMsgBox( tisStr,
                    function():void{m_pHandler.artifactPurifyRequest(_m_pData.artifactID, _m_pData.artifactSoulID);},
                    null,true,null,null,true,"artifact_prompt_2" );
            return;
        }
        var oldPower : int = _m_pData.getFighting(false);
        var newPower : int = _m_pData.hasNewProperty?_m_pData.getFighting(true):0;
        if(newPower > oldPower)
        {
            tisStr = CLang.Get("artifact_prompt_1");//洗练后战力会降低，确定不替换吗？
            _m_rootView.uiCanvas.showMsgBox( tisStr,
                    function():void{m_pHandler.artifactPurifyRequest(_m_pData.artifactID, _m_pData.artifactSoulID);},
                    null,true,null,null,true,"artifact_prompt_1" );
        }
        else
        {
            m_pHandler.artifactPurifyRequest(_m_pData.artifactID, _m_pData.artifactSoulID);
        }
    }
    public function update(data: CArtifactSoulData):void {
        _m_pData = data;
        var isShow:Boolean = !data.isCanBreakByAttr && !data.isShowBreachResult;
        _m_uiView.visible = isShow;
        if (!isShow) {
            return;
        }

        var constant:ArtifactConstant = m_pManager.constantCfg;
        _m_pAttrPanelCurr.update(_m_pData);
        if (data.hasNewProperty) {//有新洗炼出来的属性没替换
            _m_uiView.uiBoxTips.visible = false;
            _m_uiView.uiBtnSave.disabled = false;
            _m_pAttrPanelResult.visible = true;
            _m_pAttrPanelResult.update(_m_pData);
        } else {
            _m_uiView.uiBoxTips.visible = true;
            _m_uiView.uiBtnSave.disabled = true;
            _m_pAttrPanelResult.visible = false;

            //显示洗练提示动态文本
            var tips:String = CLang.Get("artifact_soul_purify_desc" , {rate: Math.floor(constant.soulBreakRate * 0.01), soulName: data.htmlName});
            _m_uiView.uiLabelTips.text = tips;
        }

        //显示洗炼石数量
        var bagData:CBagData = (_m_pSystem.stage.getSystem(CBagSystem).getBean(CBagManager) as CBagManager).getBagItemByUid(constant.purifyItemID);
        _m_iOwnStoneCount  = bagData != null ? bagData.num : 0;
        _m_iNeedStoneCount = constant.purifyConsume;

        var itemTable:IDataTable = (_m_pSystem.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        var itemCfg:Item = itemTable.findByPrimaryKey(m_pManager.constantCfg.purifyItemID);
        var itemName:String = HtmlUtil.hrefAndU(itemCfg.name, null,  CQualityColor.getColorByQuality(itemCfg.quality - 1));
        App.render.callLater(function():void {
            _m_uiView.txt_my_stone_vale.textField.styleSheet = HtmlUtil.hrefSheet;
            _m_uiView.txt_my_stone_vale.textField.text = CLang.Get("artifact_soul_purify_item_num",{itemName: itemName, need: _m_iNeedStoneCount, own: _m_iOwnStoneCount});
        });

        //显示战力
        _m_uiView.uiNumCurrFighting.num = data.getFighting(false);
        if (data.hasNewProperty) {
            _m_uiView.uiNumResultFighting.num = data.getFighting(true);
        }
        _m_uiView.uiClipFightingResult.visible = _m_uiView.uiNumResultFighting.num != _m_uiView.uiNumCurrFighting.num;
        if (_m_uiView.uiClipFightingResult.visible) {
            _m_uiView.uiClipFightingResult.index = _m_uiView.uiNumResultFighting.num > _m_uiView.uiNumCurrFighting.num ? 0 : 1;
        }
    }

    private function get m_pHandler():CArtifactHandler {
        return (_m_pSystem.getHandler(CArtifactHandler) as CArtifactHandler);
    }

    private function get m_pManager():CArtifactManager {
        return (_m_pSystem.getBean(CArtifactManager) as CArtifactManager);
    }
}
}
