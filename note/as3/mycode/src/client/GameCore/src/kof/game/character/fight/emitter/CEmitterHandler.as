//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/13.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {


import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;

public class CEmitterHandler extends CGameSystemHandler {
    public function CEmitterHandler() {

        super( CEmitterComponent );

    }

    override public function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        var bValidated : Boolean = super.tickValidate( delta, obj );
        if ( !bValidated )
            return false;

        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( !pAnimation || !pAnimation.isFrameFrozen ) {
            var emitterComp : CEmitterComponent = obj.getComponentByClass( CEmitterComponent, true ) as CEmitterComponent;
            emitterComp.update( delta );
        }

        return false;
    }

}
}
