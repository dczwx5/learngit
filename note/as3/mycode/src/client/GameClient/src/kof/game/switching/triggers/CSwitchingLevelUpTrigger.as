//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.triggers {

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.switching.ISwitchingTrigger;
import kof.util.CAssertUtils;

/**
 * 战队升级触发器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingLevelUpTrigger extends CAbstractSwitchingTrigger implements ISwitchingTrigger {

    /** Creates a new CSwitchingLevelUpTrigger */
    public function CSwitchingLevelUpTrigger() {
        super();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        CAssertUtils.assertNotNull( m_pSystemRef, "CAppSystem required." );

        var pPlayerSystem : CPlayerSystem = m_pSystemRef.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
        if ( pPlayerSystem ) {
            pPlayerSystem.addEventListener( CPlayerEvent.PLAYER_LEVEL_UP, _onPlayerLevelUp, false, CEventPriority.DEFAULT, true );
            pPlayerSystem.addEventListener( CPlayerEvent.PLAYER_DATA, _onPlayerData, false, CEventPriority.DEFAULT, true );
        }

        return true;
    }

    /**
     * 这个暂时使用的方式解决玩家数据首次加载和功能开启的触发冲突问题。
     */
    [Ignore]
    private function _onPlayerData( event : CPlayerEvent ) : void {
        event.currentTarget.removeEventListener( event.type, _onPlayerData );

        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        evt.isInitPhase = true;
        notifier.dispatchEvent( evt );
    }

    private function _onPlayerLevelUp( event : CPlayerEvent ) : void {
        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        notifier.dispatchEvent( evt );
    }

}
}
