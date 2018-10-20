//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package helper {

import QFLib.Math.CVector3;
import action.CActionBase;
import action.EKeyCode;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.game.scene.CSceneSystem;
import kof.util.CAssertUtils;

import view.CBattleTutorViewHandlerBase;

public class CCondHelper extends CHelperBase {
    public function CCondHelper(battleTutor:CBattleTutor) {
        super (battleTutor);
    }

    // dir is EKeyCode.Type : 指引移动方向
    public function checkHeroRunTo(dir:String, pHero:CGameObject, targetPos:CVector3, canEquot:Boolean) : Boolean {
        var transform:ITransform = (pHero.getComponentByClass(ITransform, false) as ITransform);

        var ret:Boolean = false;
        switch (dir) {
            case EKeyCode.W :
                if ((canEquot && transform.y <= targetPos.y) || (!canEquot && transform.y < targetPos.y)) {
                    ret = true;
                }
                break;
            case EKeyCode.A :
                if ((canEquot && transform.x <= targetPos.x) || (!canEquot && transform.x < targetPos.x)) {
                    ret = true;
                }
                break;
            case EKeyCode.S :
                if ((canEquot && transform.y >= targetPos.y) || (!canEquot && transform.y > targetPos.y)) {
                    ret = true;
                }
                break;
            case EKeyCode.D :
                if ((canEquot && transform.x >= targetPos.x) || (!canEquot && transform.x > targetPos.x)) {
                    ret = true;
                }
                break;
        }
        return ret;
    }

    public function isActorDead(actorID:int) : Boolean {
        var sceneSystem:CSceneSystem = _pBattleTutor.systemHelper.sceneSystem as CSceneSystem;
        var allGameObj:Array = sceneSystem.allGameObjectIterator as Array;
        for each (var obj:CGameObject in allGameObj) {
            var objID:int = (obj.getComponentByClass(CCharacterProperty, false) as CCharacterProperty).prototypeID;
            if (actorID == objID) {
                var stateBoard:CCharacterStateBoard = (obj.getComponentByClass(CCharacterStateBoard, false) as CCharacterStateBoard);
                return stateBoard && stateBoard.getValue(CCharacterStateBoard.DEAD);
            }
        }
        return true; // 怪物先挂了, 避免卡死
    }

    public function isPassTime(act:CActionBase, duringTime:Number) : Boolean {
        return act.passTime > duringTime;
    }

    public function isViewShowed(viewClazz:Class) : Boolean {
        var v:CBattleTutorViewHandlerBase = (_pBattleTutor.system.getBean(viewClazz) as CBattleTutorViewHandlerBase);
        CAssertUtils.assertNotNull(v);
        var ret:Boolean = v.isShowed();
        return ret;
    }
}
}
