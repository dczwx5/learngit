//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/23.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base {

import QFLib.Interface.IDisposable;

import kof.game.character.fight.sync.synctimeline.base.CCharacterFightData;

import kof.game.core.CGameObject;

public class CBaseFightTimeLineNode implements IFightTimeLineNode, IDisposable{
    public function CBaseFightTimeLineNode( data : CFightSyncNodeData = null ) {
        m_theNodeSyncData = data;
    }

    public function dispose() : void{
        if( m_theNodeSyncData )
            m_theNodeSyncData.dispose();
        m_theNodeSyncData =  null;

        m_theNext = null;
        m_thePrev = null;
    }

    public function recycle() : void{
        m_theNodeSyncData.recycle();
        m_thePrev = null;
        m_theNext = null;
    }

    public function set nodeFightData( data : CFightSyncNodeData ) : void {
        m_theNodeSyncData = data;
    }

    public function get nextLocalNode() : CBaseFightTimeLineNode{
        return m_pNextLocalNode;
    }

    public function appenFighterData( data : CCharacterFightData) : Boolean{
        return nodeFightData.appendFighterData( data );
    }

    public function get nextGlobalNode() : CBaseFightTimeLineNode{
        return m_pNextGlobalNode;
    }

    public function get nodeFightData() : CFightSyncNodeData{
        return m_theNodeSyncData;
    }

    public function hasOwner( owner : CGameObject ) : Boolean{
        var characterData : CCharacterFightData = nodeFightData.getFighterDataByOwner( owner );
        return characterData != null;
    }

    public function hasOtherOwner( target : CGameObject ) : Boolean{

        var characterData : CCharacterFightData = nodeFightData.getFighterDataByOwner( target );
        return characterData == null && nodeFightData.dataCount > 0 ;
    }

    public function replayNode() : void{

    }

    public function get prev() : CBaseFightTimeLineNode{
        return m_thePrev;
    }

    public function get next() : CBaseFightTimeLineNode{
        return m_theNext;
    }

    public function set prev( node : CBaseFightTimeLineNode ) : void {
        m_thePrev = node;
    }

    public function set next( node : CBaseFightTimeLineNode ) : void{
        m_theNext = node;
    }

    public function get nodeDataTime() : Number{
        return m_theNodeSyncData.fSyncTime;
    }

    private var m_theNodeSyncData  : CFightSyncNodeData;
    private var m_pNextLocalNode : CBaseFightTimeLineNode;
    private var m_pNextGlobalNode : CBaseFightTimeLineNode;
    private var m_thePrev : CBaseFightTimeLineNode;
    private var m_theNext : CBaseFightTimeLineNode;
}
}
