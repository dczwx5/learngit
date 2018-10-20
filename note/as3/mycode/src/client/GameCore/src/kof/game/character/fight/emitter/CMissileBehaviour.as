//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/13.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import kof.game.character.movement.CMovement;

public class CMissileBehaviour extends CMovement {
    public function CMissileBehaviour() {
        super();
    }

    /** @inheritDoc */
    override protected virtual function onEnter() : void {
        if ( !('moveSpeed' in owner.data) && !owner.data.hasOwnProperty( 'moveSpeed' ) ) {
            owner.data.moveSpeed = DEFAULT_SPEED;
        }

    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

    }
}
}
