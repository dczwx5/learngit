//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/24.
 */
package kof.game.player {

import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;

import kof.framework.CAbstractHandler;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.message.Hero.AddHeroResponse;
import kof.message.Hero.HeroMessageModifyResponse;
import kof.message.Player.PlayerInfoModifyResponse;
import kof.message.Player.PlayerInfoResponse;

public class CPlayerManager extends CAbstractHandler implements IUpdatable{
    public function CPlayerManager() {
    }
    public override function dispose() : void {
        super.dispose();
        _playerData = null;
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        _playerData = new CPlayerData(system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem);


        return ret;
    }

    public function update(delta:Number) : void {

    }

    // ====================================S2C==================================================
    public function initialPlayerData(response:PlayerInfoResponse) : void {
        _playerData.updateDataByData(response);
    }
    public function updatePlayerData(response:PlayerInfoModifyResponse) : void {
        _playerData.updateDataByData(response);
    }
    public function addHero(response:AddHeroResponse) : CPlayerHeroData {
        return _playerData.addHero(response);
    }
    public function updateHeroData(response:HeroMessageModifyResponse) : CPlayerHeroData {
        return _playerData.updateHero(response);
    }
    public function updateRandomName(name:String) : void {
        _playerData.updateRandomName(name);
    }

    public function get playerData() : CPlayerData {
        return _playerData;
    }
    private var _playerData:CPlayerData;
}
}
