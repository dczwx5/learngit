//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact.view {

import kof.game.artifact.CArtifactManager;
import kof.game.artifact.CArtifactSystem;
import kof.game.artifact.data.CArtifactData;
import kof.ui.master.Artifact.ArtifactTipsUI;

/**
 * 神器TIPS
 *@author tim
 *@create 2018-05-25 20:18
 **/
public class CArtifactTipsView {
    private var _m_pTipsUI:ArtifactTipsUI;
    public function CArtifactTipsView() {
        _m_pTipsUI = new ArtifactTipsUI();
    }

    public function showTips(data:CArtifactData, system:CArtifactSystem) : void {
        App.tip.addChild( _m_pTipsUI );
        _m_pTipsUI.uiLabelName.text = data.htmlNameWithNum;
        var mgr:CArtifactManager = system.getBean(CArtifactManager);

        var base:int = data.isLock ? 0 : data.fighting;
        var soul:int = data.soulFighting;
        var suit:int = mgr.getSuitFighting(data.suitID);
        _m_pTipsUI.uiLabelFightingTotal.text = (base + soul + suit).toString();
        _m_pTipsUI.uiLabelFightingBase.text = base.toString();
        _m_pTipsUI.uiLabelFightingSoul.text = soul.toString();
        _m_pTipsUI.uiLabelFightingSuit.text = suit.toString();
        _m_pTipsUI.uiBoxFightingTotal.centerX = 0;
    }
}
}
