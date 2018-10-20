//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import kof.framework.fsm.CStateEvent;

/**
 * 角色Idle状态
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterIdleState extends CCharacterState {

    public function CCharacterIdleState() {
        super( CCharacterActionStateConstants.IDLE );
    }

    override protected virtual function onStateChange( event : CStateEvent ) : void {
        // Ignore.
        this.setMovable( true ); // 可以主动移动
        this.setDirectionPermit( true ); // 可以转身镜像

    }

}
}
