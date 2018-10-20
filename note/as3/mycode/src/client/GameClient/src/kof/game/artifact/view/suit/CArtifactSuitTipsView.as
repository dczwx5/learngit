//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-31
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact.view.suit {

import flash.display.DisplayObject;

import kof.framework.CAppSystem;
import kof.game.artifact.data.CArtifactData;
import kof.ui.master.Artifact.ArtifactSuitTipsUI;

/**
 * 神灵套装TIPS
 *@author tim
 *@create 2018-05-31 10:25
 **/
public class CArtifactSuitTipsView {

    private var _m_pTipsUI:ArtifactSuitTipsUI;
    private var _m_pSuitAttrPanelCurr:CArtifactSuitAttrPanel;
    private var _m_pSuitAttrPanelNext:CArtifactSuitAttrPanel;
    private var _m_pSystem:CAppSystem;
    public function CArtifactSuitTipsView(system:CAppSystem) {
        _m_pSystem = system;
        _m_pTipsUI = new ArtifactSuitTipsUI();
        _m_pSuitAttrPanelCurr = new CArtifactSuitAttrPanel(_m_pTipsUI.uiBoxCurr ,_m_pSystem, false);
        _m_pSuitAttrPanelNext = new CArtifactSuitAttrPanel(_m_pTipsUI.uiBoxNext ,_m_pSystem, true);

    }

    public function showTips(data:CArtifactData) : void {
        App.tip.addChild( _m_pTipsUI );

        _m_pTipsUI.uiBoxCurr.visible = false;
        _m_pTipsUI.uiBoxNext.visible = false;
        _m_pTipsUI.uiBoxMax.visible = false;
        if (data.suitCfg == null) {//一个套装都没激活
            _m_pTipsUI.uiBoxNext.visible = true;
        } else if (data.nextSuitCfg != null) {//已激活一个套装，还有更高级的套装
            _m_pTipsUI.uiBoxCurr.visible = true;
            _m_pTipsUI.uiBoxNext.visible = true;
        } else { //当前激活的套装已经是最高级
            _m_pTipsUI.uiBoxCurr.visible = true;
            _m_pTipsUI.uiBoxMax.visible = true;
        }

        var lastDsp:DisplayObject;
        if (_m_pTipsUI.uiBoxCurr.visible) {
            _m_pSuitAttrPanelCurr.update(data);
            lastDsp = _m_pTipsUI.uiBoxCurr;
        }

        if (_m_pTipsUI.uiBoxNext.visible) {
            _m_pSuitAttrPanelNext.update(data);
            lastDsp = _m_pTipsUI.uiBoxNext;
            if (_m_pTipsUI.uiBoxCurr.visible) {
                _m_pTipsUI.uiBoxNext.y = _m_pTipsUI.uiBoxNext.comXml.@y[0];
            } else {
                _m_pTipsUI.uiBoxNext.y = _m_pTipsUI.uiBoxCurr.comXml.@y[0];
            }
        }

        if (_m_pTipsUI.uiBoxMax.visible) {
            _m_pTipsUI.uiBoxMax.y = lastDsp.y + lastDsp.height + 10;
            lastDsp = _m_pTipsUI.uiBoxMax;
        }

        _m_pTipsUI.uiBoxTips.y = lastDsp.y + lastDsp.height + 10;
        _m_pTipsUI.uiImgBg.height = _m_pTipsUI.uiBoxTips.y + _m_pTipsUI.uiBoxTips.height + 2;

    }
}
}

import QFLib.Utils.HtmlUtil;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.artifact.CArtifactManager;
import kof.game.artifact.data.CArtifactData;
import kof.game.common.CLang;
import kof.table.ArtifactColour;
import kof.table.ArtifactSuit;
import kof.table.PassiveSkillPro;

import morn.core.components.Box;
import morn.core.components.Label;

class CArtifactSuitAttrPanel {
    public var uiLabelAttr0:Label;
    public var uiLabelAttr1:Label;
    public var uiLabelAttr2:Label;

    public var uiLabelAttrValue0:Label;
    public var uiLabelAttrValue1:Label;
    public var uiLabelAttrValue2:Label;

    private var _uiLabelTitle:Label;
    private var _uiLabelFightingValue:Label;
    private var _uiLabelMeet:Label;
    private var _uiLabelNotMeet:Label;

    private var _m_pSystem:CAppSystem;
    private var _m_uiView:Box;
    private var _m_bIsShowNext:Boolean;//是否显示下一品级的属性
    public function CArtifactSuitAttrPanel(uiView:Box, system:CAppSystem, isShowNext:Boolean) {
        _m_uiView = uiView;
        _m_pSystem = system;
        _m_bIsShowNext = isShowNext;
        for (var i:int = 0; i < 3; i++) {
            this["uiLabelAttr" + i ] = _m_uiView.getChildByName("uiLabelAttr" + i);
            this["uiLabelAttrValue" + i ] = _m_uiView.getChildByName("uiLabelAttrValue" + i);
        }
        _uiLabelTitle = _m_uiView.getChildByName("uiLabelTitle") as Label;
        _uiLabelFightingValue = _m_uiView.getChildByName("uiLabelFightingValue") as Label;
        _uiLabelMeet = _m_uiView.getChildByName("uiLabelMeet") as Label;
        _uiLabelNotMeet = _m_uiView.getChildByName("uiLabelNotMeet") as Label;
    }

    public function update(data:CArtifactData):void {
        var mgr:CArtifactManager = _m_pSystem.getBean(CArtifactManager);
        var suitCfg:ArtifactSuit = _m_bIsShowNext ? data.nextSuitCfg : data.suitCfg;
        var proCfg : PassiveSkillPro;
        var pTable:IDataTable = (_m_pSystem.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
        for (var i:int = 0; i < 3; i++) {
            proCfg = pTable.findByPrimaryKey( suitCfg.propertyID[i]);
            this["uiLabelAttr"+i].text = proCfg.name;
            this["uiLabelAttrValue"+i].text = suitCfg.propertyValue[i];
        }

        var colorCfg:ArtifactColour = mgr.getColorCfg(suitCfg.qualityID + 1);
        var colorName:String = HtmlUtil.color(colorCfg.qualityColour, colorCfg.colour.replace("0x", "#"));
        var count:int = _m_bIsShowNext ? data.getSuitActivateSoulCount(data.suitID + 1) : data.getSuitActivateSoulCount();
        var maxNum:int = 3;
        var countStr:String = count + "/" + maxNum;
        countStr = HtmlUtil.color(countStr, count >= maxNum ? "#70e324": "#e8210d");
        _uiLabelTitle.text = CLang.Get("artifact_suit_tips_title", {colorName: colorName, count: countStr});
        _uiLabelFightingValue.text = _m_bIsShowNext ? mgr.getSuitFighting(data.nextSuitCfg.ID ).toString() : mgr.getSuitFighting(data.suitID).toString();
        _uiLabelMeet.visible = count >= maxNum;
        _uiLabelNotMeet.visible = count < maxNum;
    }


}
