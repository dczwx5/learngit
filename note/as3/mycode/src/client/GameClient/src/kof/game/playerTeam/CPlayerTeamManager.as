//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/24.
 */
package kof.game.playerTeam {

import QFLib.Interface.IUpdatable;
import kof.framework.CAbstractHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;

public class CPlayerTeamManager extends CAbstractHandler implements IUpdatable{
    public function CPlayerTeamManager() {
    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    public function update(delta:Number) : void {

    }

    // ====================================S2C==================================================
//    public function initialPlayerData(response:PlayerInfoResponse) : void {
//        playerData.updateDataByData(response);
//    }
//    public function updatePlayerData(response:PlayerInfoModifyResponse) : void {
//        playerData.updateDataByData(response);
//    }
//
//    public function updateRandomName(name:String) : void {
//        playerData.updateRandomName(name);
//    }

    public function get playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
}
}
