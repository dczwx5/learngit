//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/30.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.CActionCommon;

import kof.util.CAssertUtils;

import morn.core.handlers.Handler;

public class CHeroMoveToPackage extends CActionPackageBase {
    public function CHeroMoveToPackage() {

    }

    public override function buildAction() : CActionBase {
        CAssertUtils.assertNotNull(srcObject);
        CAssertUtils.assertNotNaN(toX);
        CAssertUtils.assertNotNaN(toY);

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var moveAct:CActionCommon = new CActionCommon();

        var initialize:Function = function () : Boolean {
            isMoveTo = false;
            return true;
        };

        var setMoveTo:Function = function () : Boolean {
            isMoveTo = true;
            return true;
        };
        var checkMoveTo:Function = function () : Boolean {
            return isMoveTo;
        };

        var isMonsterRunning:Function = function () : Boolean {
            log("| -----------------------monster is running");
            return srcObject.isRunning;
        };

        moveAct.addStartHandler(new Handler(initialize));
        moveAct.addPassHandler(new Handler(isMonsterRunning));
        if (isMovePixel) {
            moveAct.addPassHandler(new Handler(battleTutor.actorHelper.moveToByPixel, [srcObject, toX, toY, setMoveTo]));
        } else {
            moveAct.addPassHandler(new Handler(battleTutor.actorHelper.moveTo, [srcObject, toX, toY, setMoveTo]));
        }
        moveAct.addPassHandler(new Handler(checkMoveTo));


        return moveAct;
    }
}
}
