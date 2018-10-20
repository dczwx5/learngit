//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/23.
 */
package kof.game.playerTeam {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.common.system.CAppSystemImp;
import kof.game.currency.buyPower.CBuyPowerViewHandler;
import kof.game.player.data.CPlayerData;

public class CPlayerTeamSystem extends CAppSystemImp {

    public static const EVENT_PLAYER_TEAM_CREATION_COMPLETE : String = "playerTeamCreationComplete";

    public function CPlayerTeamSystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.PLAYER_TEAM);
    }
    public override function dispose() : void {
        super.dispose();
    }

    // ====================================================================
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();
        if ( !ret ) {
        } else {
            this.addBean( _manager = new CPlayerTeamManager() );
            this.addBean( _netHandler = new CPlayerTeamHandler() );
            this.addBean( _uiHandler = new CPlayerTeamUIHandler() );

        }
        return ret;
    }

    public function inverseBuyVitView() : void {
        var view:CBuyPowerViewHandler = getBean(CBuyPowerViewHandler) as CBuyPowerViewHandler;
        view.inverseWindow();
    }
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);
        if (isActived) {
            _uiHandler.showPlayerTeam(playerData.ID);
        } else {
            _uiHandler.hidePlayerTeam();
        }
    }

    public function showPlayerInfo(playerID:Number) : void {
        _uiHandler.showPlayerTeam(playerID);
    }
    public function hidePlayerInfo() : void {
        _uiHandler.hidePlayerTeam();
    }

    public function showCreation() : void {
        var pUiHandler : CPlayerTeamUIHandler = this.getHandler( CPlayerTeamUIHandler ) as CPlayerTeamUIHandler;
        if ( pUiHandler ) {
            pUiHandler.showCreateTeam();
        }
    }

    // get/set
    public function get playerData() : CPlayerData {
        return _manager.playerData;
    }
    public function get netHandler() : CPlayerTeamHandler {
        return _netHandler;
    }
    public function get uiHandler() : CPlayerTeamUIHandler {
        return _uiHandler;
    }

    // ==================================property====================================
    private var _netHandler:CPlayerTeamHandler;
    private var _manager:CPlayerTeamManager;
    private var _uiHandler:CPlayerTeamUIHandler;

}
}