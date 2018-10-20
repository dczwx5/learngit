//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/1/3.
 */
package kof.game.invest {

import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.InvestRewardConfig;

public class CInvestManager extends CAbstractHandler implements IUpdatable {
    public function CInvestManager() {
        super();
    }
    public function update(delta:Number) : void {

    }

    public var fristFlg : Boolean = true;
    public var m_hasPut : Boolean;
    public var m_infos : Array = [];

    public function getObtainedObjById( id : int ):Object{
        var obj : Object;
        for each ( obj in m_infos ){
            if( obj.id == id ){
                return obj;
                break;
            }
        }
        return null;
    }

    public function isCanGetAward():Boolean{
        if( m_hasPut ){
            var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTREWARDCONFIG );
            var ary : Array = pTable.toArray();
            var investRewardConfig : InvestRewardConfig;
            for each( investRewardConfig in ary ){
                if( _playerData.teamData.level >= investRewardConfig.level && getObtainedObjById( investRewardConfig.ID ) == null ){
                    return true;
                }
            }
        }
        return false;
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
}
}
