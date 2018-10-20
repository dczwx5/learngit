//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/23.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;

import kof.game.character.fight.sync.synctimeline.base.action.IFighterKeyAction;

import kof.game.core.CGameObject;

public class CFightSyncNodeData implements IDisposable {
    public function CFightSyncNodeData() {
        m_theDicForNodeData = new CMap( true );
    }

    public function dispose() : void {
        if ( m_theDicForNodeData )
            m_theDicForNodeData.clear();
        m_theDicForNodeData = null;
        m_fSyncTime = NaN;
    }

    public function recycle() : void {
        m_theDicForNodeData.clear();
        m_fSyncTime = NaN;
    }

    public function get fSyncTime() : Number {
        return m_fSyncTime;
    }

    public function set fSyncTime( fTime : Number ) : void {
        m_fSyncTime = fTime;
    }

    public function appendFighterData( fightData : CCharacterFightData ) : Boolean {
        var pOwner : CGameObject = fightData.owner;
        var existFighterData : CCharacterFightData;
        existFighterData = m_theDicForNodeData.find( pOwner ) as CCharacterFightData;

        if ( existFighterData ) {
            for each( var action : IFighterKeyAction in fightData.fighterActions ) {
                if ( action )
                    existFighterData.recordActionsToData( action.type, action.actionData ); //addAction( action );
            }
            return true;
        }

        m_theDicForNodeData.add( pOwner, fightData );

        return true;
    }

    public function getFighterDataByOwner( owner : CGameObject ) : CCharacterFightData {
        return m_theDicForNodeData.find( owner ) as CCharacterFightData;
    }

    public function get dataCount() : int{
        return m_theDicForNodeData.count;
    }

    public function getFighterDatas() : Vector.<CCharacterFightData> {
        var ret : Vector.<CCharacterFightData> = new Vector.<CCharacterFightData>();
        for ( var key : CGameObject in m_theDicForNodeData ) {
            ret.push( m_theDicForNodeData[ key ] );
        }

        return ret;
    }

    private var m_fSyncTime : Number;
    private var m_theDicForNodeData : CMap;
}
}
