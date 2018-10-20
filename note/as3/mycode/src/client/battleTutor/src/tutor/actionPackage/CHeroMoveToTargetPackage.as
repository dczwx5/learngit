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
import kof.util.CAssertUtils;
// 这个会有问题, 怪物还没有ready, 报错, 不要使用
public class CHeroMoveToTargetPackage extends CActionPackageBase {
    public function CHeroMoveToTargetPackage() {

    }

    public override function buildAction() : CActionBase {
        CAssertUtils.assertNotNull(srcObject);
        CAssertUtils.assertNotNull(destObject);


        var buildHeroMovePackage:CActionPackageBase = CActionPackageBuilder.build(CHeroMoveToPackage, tutorBase, null, null, false);
        var moveToObj:CGameObject = destObject;
        var tarPos:CVector2 = tutorBase.battleTutor.actorHelper.getObjectPos(moveToObj);
        var srcPos:CVector2 = tutorBase.battleTutor.actorHelper.getObjectPos(srcObject);
        var moveToPos:CVector2 = new CVector2();
        moveToPos.y = tarPos.y;
        var needRun:Boolean = false;
        if (tarPos && srcPos) {
            if (srcPos < tarPos) {
                // 转右
                moveToPos.x = tarPos.x-100;
                if (moveToPos.x > srcPos.x) {
                    // 跑
                    needRun = true;
                } else {
                    // 不跑, 离怪更远了
                    needRun = false;
                }
            } else {
                // 转左
                moveToPos.x = tarPos.x+150;
                if (moveToPos.x < srcPos.x) {
                    // 跑
                    needRun = true;
                } else {
                    // 不跑, 离怪更远了
                    needRun = false;
                }
            }
        }
        var moveAct:CActionBase;
//        if (needRun) {
            buildHeroMovePackage.isMovePixel = false;
            buildHeroMovePackage.toX = moveToPos.x;
            buildHeroMovePackage.toY = moveToPos.y;
            buildHeroMovePackage.srcObject = srcObject;
            moveAct = buildHeroMovePackage.buildAction();
//        }
        return moveAct;
    }
}
}
