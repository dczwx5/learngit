//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/28.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.CActionCommon;

import kof.game.core.CGameObject;
import kof.util.CAssertUtils;

import morn.core.handlers.Handler;

public class CSpellSkillPackage extends CActionPackageBase {
    public function CSpellSkillPackage() {

    }

    private var _isHitOk:Boolean = false;
    public override function buildAction() : CActionBase {
        CAssertUtils.assertNotNull(srcObject);

        var useSkillAct:CActionBase = new CActionCommon();
        var battleTutor:CBattleTutor = tutorBase.battleTutor;

        var hitFunc:Function = function () : Boolean {
            _isHitOk = true;
            return true;
        };
        var isHitOk:Function = function () : Boolean {
            return _isHitOk;
        };
        var resetHitOk:Function = function () : Boolean {
            _isHitOk = false;
            return true;
        };
        var monster:CGameObject = srcObject;
        for (var i:int = 0; i < totalPressCount; i++) {
            useSkillAct.addPassHandler(new Handler(battleTutor.actorHelper.castSkillAndHit, [monster, skillIDList[i], hitFunc])); // 监听播放技能事件
//            useSkillAct.addPassHandler(new Handler(isHitOk)); // 是否击中 //            useSkillAct.addPassHandler(new Handler(resetHitOk));
            useSkillAct.addPassHandler(new Handler(battleTutor.actionHelper.resetStartTime, [useSkillAct]));
            useSkillAct.addPassHandler(new Handler(battleTutor.condHelper.isPassTime, [useSkillAct, 400]));
        }

        return useSkillAct;
    }
}
}
