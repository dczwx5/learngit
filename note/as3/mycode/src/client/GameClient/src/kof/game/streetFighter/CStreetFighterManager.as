//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter {


import kof.framework.CAbstractHandler;
import QFLib.Interface.IUpdatable;
import kof.framework.IDatabase;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.data.CStreetFighterData;

public class CStreetFighterManager extends CAbstractHandler implements IUpdatable {
    public function CStreetFighterManager() {
        clear();
    }

    public function update( delta : Number ) : void {
    }

    public override function dispose():void {
        super.dispose();
        clear();
    }

    public function clear() : void {

    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var pPlayerData:CPlayerData = playerSystem.playerData;
        _data = new CStreetFighterData(system.stage.getSystem(IDatabase) as IDatabase);
        _data._playerUID = pPlayerData.ID;

        return ret;
    }

    [Inline]
    public function get data() : CStreetFighterData {
        return _data;
    }
    [Inline]
    private function get _system() : CStreetFighterSystem {
        return system as CStreetFighterSystem;
    }
    private var _data:CStreetFighterData;
}
}
