//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Framework.CObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;
import QFLib.Memory.CSmartObject;

import kof.game.character.display.IDisplay;

/**
 * 特别适用于KOF当前的坐标系之间的转换逻辑的ITransform组件实现
 * 委托于IDisplay的CCharacter换算坐标
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKOFTransform extends CCharacterTransform {

    static private const EMPTY_VEC2 : CVector2 = new CVector2();

    public function CKOFTransform() {
        super();
    }

    final public function to2DAxis() : CVector2 {
        var display : IDisplay = getComponent( IDisplay ) as IDisplay;
        var ret : CVector2;
        if ( display && display.modelDisplay ) {
//            ret = new CVector2( display.modelDisplay.theObject.x, display.modelDisplay.theObject.y );
            var vec3 : CVector3 = display.modelDisplay.get2DPosition();
            ret = new CVector2( vec3.x, vec3.y );
        }

        if( null == ret )
                ret = EMPTY_VEC2.clone();

        return ret;
    }

    final public function from2DAxis( x : Number, y : Number, fHeight : Number = 0, bMoveToAvailablePosition : Boolean = false ) : void {
        var display : IDisplay = getComponent( IDisplay ) as IDisplay;
        if ( display && display.modelDisplay ) {
            var vPos3D: CVector3 = CObject.get3DPositionFrom2D( display.modelDisplay, x, y, fHeight );
            display.modelDisplay.setPositionToFrom2D( x, y, fHeight, 0.0, false, fHeight == 0.0, bMoveToAvailablePosition );
            // sync to ECS right now.
            this.x = display.modelDisplay.position.x;
            this.y = display.modelDisplay.position.z;
            this.z = display.modelDisplay.position.y;
        }
    }

}
}
