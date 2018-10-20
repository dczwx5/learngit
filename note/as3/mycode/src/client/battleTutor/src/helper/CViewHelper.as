//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package helper {

import QFLib.Framework.CObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;


import kof.game.fightui.CFightViewHandler;
import kof.game.fightui.compoment.CInstanceProcessViewHandler;
import kof.game.fightui.compoment.CSkillViewHandler;
import kof.game.lobby.CLobbySystem;
import kof.game.scene.ISceneFacade;
import kof.util.CAssertUtils;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.FrameClip;

import view.CAbilityIntroViewHandler;

import view.CBattleTutorViewHandlerBase;
import view.CDefend1IntroViewHandler;
import view.CDefend2IntroViewHandler;
import view.CDescViewHandler;

import view.CKeyDescViewHandler;
import view.CKeyPressViewHandler;
import view.CMaskViewHandler;
import view.CMultiKeyDescViewHandler;
import view.CMultiKeyPressViewHandler;
import view.CQEIntroViewHandler;
import view.CQTEViewHandler;
import view.CWSADViewHandler;

public class CViewHelper extends CHelperBase {
    public function CViewHelper(battleTutor:CBattleTutor) {
        super(battleTutor);
    }

    [Inline]
    public function get WSADView():CWSADViewHandler {
        return (_pBattleTutor.system.getBean(CWSADViewHandler) as CWSADViewHandler);
    }

    [Inline]
    public function get keyDesc():CKeyDescViewHandler {
        return (_pBattleTutor.system.getBean(CKeyDescViewHandler) as CKeyDescViewHandler);
    }
    [Inline]
    public function get descView():CDescViewHandler {
        return (_pBattleTutor.system.getBean(CDescViewHandler) as CDescViewHandler);
    }
    [Inline]
    public function get keyPress():CKeyPressViewHandler {
        return (_pBattleTutor.system.getBean(CKeyPressViewHandler) as CKeyPressViewHandler);
    }

    [Inline]
    public function get qteView():CQTEViewHandler {
        return (_pBattleTutor.system.getBean(CQTEViewHandler) as CQTEViewHandler);
    }
    [Inline]
    public function get multiKeyDesc():CMultiKeyDescViewHandler {
        return (_pBattleTutor.system.getBean(CMultiKeyDescViewHandler) as CMultiKeyDescViewHandler);
    }
    [Inline]
    public function get multiKeyPress():CMultiKeyPressViewHandler {
        return (_pBattleTutor.system.getBean(CMultiKeyPressViewHandler) as CMultiKeyPressViewHandler);
    }
    [Inline]
    public function get abilityIntroView():CAbilityIntroViewHandler {
        return (_pBattleTutor.system.getBean(CAbilityIntroViewHandler) as CAbilityIntroViewHandler);
    }
    [Inline]
    public function get defend1IntroView():CDefend1IntroViewHandler {
        return (_pBattleTutor.system.getBean(CDefend1IntroViewHandler) as CDefend1IntroViewHandler);
    }
    [Inline]
    public function get defend2IntroView():CDefend2IntroViewHandler {
        return (_pBattleTutor.system.getBean(CDefend2IntroViewHandler) as CDefend2IntroViewHandler);
    }
    [Inline]
    public function get qeIntroView():CQEIntroViewHandler {
        return (_pBattleTutor.system.getBean(CQEIntroViewHandler) as CQEIntroViewHandler);
    }
    [Inline]
    public function get maskView():CMaskViewHandler {
        return (_pBattleTutor.system.getBean(CMaskViewHandler) as CMaskViewHandler);
    }

    // ====================================other
    [Inline]
    public function get pLobbySystem():CLobbySystem {
        return (_pBattleTutor.system.stage.getSystem(CLobbySystem) as CLobbySystem);
    }
//    [Inline]
//    public function get pFightUI():FightUI {
//        return (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).fightUI;
//    }
    [Inline]
    public function get instanceProcessViewHandler():CInstanceProcessViewHandler {
        return (pLobbySystem.getBean(CFightViewHandler).getBean(CInstanceProcessViewHandler) as CInstanceProcessViewHandler);
    }

//    public function get3dPosByScreen2dPos() : CVector3 {
//
//    }
    public function d3Tod2(d3Pos:CVector3):CVector2 {
        var ret:CVector3;
        ret = CObject.get2DPositionFrom3D(d3Pos.x, d3Pos.z, d3Pos.y, ret);
        return new CVector2(ret.x, ret.y);
    }

    public function scene3dToScreen(d3Pos:CVector3):CVector2 {
        var d2Pos:CVector2 = d3Tod2(d3Pos); // new CVector2(d3Pos.x, d3Pos.y);
        var pSceneFacade:ISceneFacade = _pBattleTutor.systemHelper.sceneSystem;
        if (pSceneFacade.scenegraph.mainCamera) {
            pSceneFacade.scenegraph.mainCamera.worldToScreen(d2Pos);
        }
        return d2Pos;
    }

    public function scene2dToScreen(d2Pos:CVector2):CVector2 {
        d2Pos = d2Pos.clone(); // new CVector2(d2Pos.x, d2Pos.y);
        var pSceneFacade:ISceneFacade = _pBattleTutor.systemHelper.sceneSystem;
        if (pSceneFacade.scenegraph.mainCamera) {
            pSceneFacade.scenegraph.mainCamera.worldToScreen(d2Pos);
        }
        return d2Pos;
    }

    public function showView(viewClazz:Class):Boolean {
        var v:CBattleTutorViewHandlerBase = (_pBattleTutor.system.getBean(viewClazz) as CBattleTutorViewHandlerBase);
        CAssertUtils.assertNotNull(v);
        v.addDisplay();
        return true;
    }

    public function hideView(viewClazz:Class):Boolean {
        var v:CBattleTutorViewHandlerBase = (_pBattleTutor.system.getBean(viewClazz) as CBattleTutorViewHandlerBase);
        CAssertUtils.assertNotNull(v);

        v.removeDisplay();
        return true;
    }

    public function getFightUiSkillItemByKey(key:String) : Component {
        return (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).getSkillItemByKey(key);
//
//        var fightUI:FightUI = pFightUI;
//        var findCell:Component;
//
//        if (key == EKeyCode.SPACE) {
//            findCell = fightUI.spcicalSkill;
//        } else {
//            var cells:Vector.<Box> = fightUI.list_skill.cells;
//            for each (var item:Box in cells) {
//                var skillItem:SkillItemUI = item as SkillItemUI;
//                if (skillItem && skillItem.txt_key.text == key) {
//                    findCell = skillItem;
//                    break;
//                }
//            }
//        }
//
//        return findCell;
    }

    public function get battleTutorBoxInFightView() : Box {
        return  ((pLobbySystem.getBean(CFightViewHandler) as CFightViewHandler).battleTutorBox);
    }
    public function showFightUI() : Boolean {
        setFightUIVisible(true);
        return true;
    }
    public function hideFightUI() : Boolean {
        setFightUIVisible(false);
        return true;
    }

    public function showAutoFightTips() : Boolean {
        (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).showAutoFightTips();
        return true;
    }
    public function hideAutoFightTips() : Boolean {
        (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).hideAutoFightTips();
        return true;
    }

    public function showAllSkillItem() : Boolean {
        (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).showAllSkillItems();
        return true;
    }
    public function setSkillItemVisible(key:String, v:Boolean) : Boolean {
        if (v) {
            (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).showSkillItemByKey(key);
        } else {
            (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).hideSkillItemByKey(key);
        }
        return true;
    }
    public function setFightUIVisible(v:Boolean) : Boolean {
        (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).setFightUIVisible(v);
        return true;
    }

    public function get autoFightBtn() : Component {
        return (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).autoFightBtn;
    }
    public function get autoFightEffect() : FrameClip {
        return (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).autoFightEffect;
    }
    public function get qeEffect() : FrameClip {
        return (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).qeEffect;
    }
}
}
