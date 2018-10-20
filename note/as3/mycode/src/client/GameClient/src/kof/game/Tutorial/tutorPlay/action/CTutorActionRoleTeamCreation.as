//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.util.CAssertUtils;

/**
 * 战队创建引导动作
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTutorActionRoleTeamCreation extends CTutorActionBase {

    /** Creates a new CTutorActionRoleTeamCreation */
    public function CTutorActionRoleTeamCreation( vInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( vInfo, pSystem );
    }

    override public function dispose() : void {
        var pTeamSystem : CPlayerTeamSystem;
        if ( _system )
            pTeamSystem = _system.stage.getSystem( CPlayerTeamSystem ) as CPlayerTeamSystem;

        super.dispose();

//        if ( pTeamSystem ) {
//            pTeamSystem.removeEventListener( CPlayerTeamSystem.EVENT_PLAYER_TEAM_CREATION_COMPLETE, _system_playerTeamCreationCompleted );
//        }
    }

    override public function start() : void {
        // 弹开战队创建
        CAssertUtils.assertNotNull( _system );

        if (_isTeamCreated()) {
            _actionValue = true;
        } else {
            var pTeamSystem : CPlayerTeamSystem = _system.stage.getSystem( CPlayerTeamSystem ) as CPlayerTeamSystem;
            if ( pTeamSystem ) {
                pTeamSystem.showCreation();
//            pTeamSystem.addEventListener( CPlayerTeamSystem.EVENT_PLAYER_TEAM_CREATION_COMPLETE, _system_playerTeamCreationCompleted, false, CEventPriority.BINDING, true );
            }

            super.start();
            this.playAudio();
        }
    }

    public override function update(delta:Number) : void { // 更新
        super.update(delta);

        _actionValue = _isTeamCreated();
    }

    private function _isTeamCreated() : Boolean {
        var playerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        if (playerSystem) {
            var playerData:CPlayerData = playerSystem.playerData;
            if (playerData) {
                return playerData.teamData.createTeam;
            }
        }
        return false;
    }
//    private function _system_playerTeamCreationCompleted( event : Event ) : void {
//        var playerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
//        if (playerSystem) {
//            var playerData:CPlayerData = playerSystem.playerData;
//            if (playerData) {
//                _actionValue = playerData.createTeam;
//            }
//        }
//    }

}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
