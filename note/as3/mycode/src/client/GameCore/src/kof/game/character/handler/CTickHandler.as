//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.handler {

import kof.game.character.animation.IAnimation;
import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;
import kof.game.core.CSubscribeBehaviour;
import kof.game.core.IGameComponent;
import kof.game.core.IGameSystemHandler;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTickHandler extends CGameSystemHandler implements IGameSystemHandler {

    /** Creates a new CTickHandler */
    public function CTickHandler() {
        super( CSubscribeBehaviour );
    }

    /** @inheritDoc */
    override protected function onSetup() : Boolean {
        return true;
    }

    /** @inheritDoc */
    override protected function onShutdown() : Boolean {
        return true;
    }

    /** @inheritDoc */
    override public function tickUpdate( delta : Number, obj : CGameObject ) : void {
        const components : Vector.<IGameComponent> = obj.components;
        for each ( var comp : CGameComponent in components ) {
            if ( comp is CSubscribeBehaviour )
                CSubscribeBehaviour( comp ).update( delta );
        }

        _tickObjAnimationFrozenTime( obj , delta );
    }

    private function _tickObjAnimationFrozenTime( obj : CGameObject, delta : Number ) : void {
        if ( obj == null )
            return;
        var bValidated : Boolean = true ;
        bValidated = bValidated && obj.isRunning;
        if ( bValidated ) {
            var animation : IAnimation = obj.getComponentByClass( IAnimation, true ) as IAnimation;
            animation.tickFrozenTime( delta );
        }
    }

}
}
