//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package action {

import QFLib.Math.CVector2;

import kof.game.character.CFacadeMediator;
import kof.game.character.movement.CMovement;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;

public class CActionActorMove extends CActionBase {
    public function CActionActorMove() {
    }

    public override function start() : void {
        super.start();
        var pHero:CGameObject = hero;

        var toX:Number = 2900;
        var toY:Number = 1189;
        var movementComponent:CMovement = pHero.getComponentByClass(CMovement, false) as CMovement;
        var transform:ITransform = (pHero.getComponentByClass(ITransform, false) as ITransform);
//        if (movementComponent) movementComponent.collisionEnabled = false; // todo :

        var pFacadeMediator:CFacadeMediator = (pHero.getComponentByClass(CFacadeMediator, false) as CFacadeMediator);
//        var isCanMove:Boolean = (pHero.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).moveToPixel(Vector.<CVector2>([new CVector2(toX, toY)]), _onMoveEnd);
//
//        var isCanMove:Boolean = (pHero.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).moveToPixel(Vector.<CVector2>([new CVector2(toX, toY)]), _onMoveEnd);


        var isCanMove:Boolean = pFacadeMediator.moveTo(new CVector2( pHero.transform.x + 500, pHero.transform.y ), _onMoveEnd);

        if (!isCanMove) {
            // 点不可走。直接跳过
            log("不可走");
            _onMoveEnd();
        }
    }

    public override function update() : void {
        if (!_isStart && _isFinish) {
            return ;
        }
        if (_isFinish) {
            this.end();
        }
    }

    private function _onMoveEnd() : void {
        _isFinish = true;
    }
}
}
