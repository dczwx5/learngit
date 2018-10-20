//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/30.
 */
package tutor.actionPackage {

import QFLib.Math.CVector2;

import action.CActionBase;
import kof.game.core.CGameObject;

public class CObjectMoveToHeroPackage extends CActionPackageBase {
    public function CObjectMoveToHeroPackage() {

    }

    public override function buildAction() : CActionBase {
        if (targetObjectID < 0) {
            return null;
        }
        var buildHeroMovePackage:CActionPackageBase = CActionPackageBuilder.build(CHeroMoveToPackage, tutorBase, null, null, false);
        var moveToObj:CGameObject = tutorBase.battleTutor.actorHelper.getMonsterByID(targetObjectID);

        var mPos:CVector2 = tutorBase.battleTutor.actorHelper.getObjectPos(moveToObj);
        var hPos:CVector2 = tutorBase.battleTutor.actorHelper.getObjectPos(tutorBase.battleTutor.actorHelper.hero);
        var moveToPos:CVector2 = new CVector2();
        moveToPos.y = mPos.y;
        var needRun:Boolean = false;
        if (mPos && hPos) {
            if (hPos < mPos) {
                // 转右
                moveToPos.x = mPos.x-100;
                if (moveToPos.x > hPos.x) {
                    // 跑
                    needRun = true;
                } else {
                    // 不跑, 离怪更远了
                    needRun = false;
                }
            } else {
                // 转左
                moveToPos.x = mPos.x+150;
                if (moveToPos.x < hPos.x) {
                    // 跑
                    needRun = true;
                } else {
                    // 不跑, 离怪更远了
                    needRun = false;
                }
            }
        }
        var moveAct:CActionBase;
        if (needRun) {
            buildHeroMovePackage.isMovePixel = false;
            buildHeroMovePackage.toX = moveToPos.x;
            buildHeroMovePackage.toY = moveToPos.y;
            moveAct = buildHeroMovePackage.buildAction();
        }
        return moveAct;
    }
}
}
