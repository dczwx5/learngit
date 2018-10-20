//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
package kof.game.character.fight.sync.synctimeline {

import QFLib.Foundation;

import kof.game.character.fight.CFightHandler;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.synctimeline.base.CBaseFightTimeLineNode;
import kof.game.character.fight.sync.synctimeline.base.CCharacterFightData;
import kof.game.character.fight.sync.synctimeline.base.CFightSyncNodeData;
import kof.game.character.fight.sync.synctimeline.base.CFightTimeLine;
import kof.game.character.fight.sync.synctimeline.base.IFightTimeLineNode;
import kof.game.character.fight.sync.synctimeline.base.action.CBaseFighterKeyAction;
import kof.game.character.fight.sync.synctimeline.base.action.EFighterActionType;
import kof.game.core.CGameComponent;
import kof.message.CAbstractPackMessage;

public class CFightTimeLineFacade extends CGameComponent {
    public function CFightTimeLineFacade( fightHandle : CFightHandler ) {
        super( "fighttimeline" );
        m_pFightHandler = fightHandle;
    }

    override protected function onEnter() : void {
//        if ( m_pFightHandler )
//            m_pFightTimeLine = m_pFightHandler.fightTimeLine;
    }

    final private function get m_pFightTimeLine() : CFightTimeLine {
        return m_pFightHandler.fightTimeLine;
    }

    override protected function onExit() : void {
        super.onExit();

//        m_pFightTimeLine = null;
        m_pFightHandler = null;
    }

    public function insertMsgByType( type : int, fTime : Number, msg : CAbstractPackMessage ) : Boolean {
        var actionType : int = type;
        var retNode : CBaseFightTimeLineNode;
        var fightData : CCharacterFightData;
        var insertAction : CBaseFighterKeyAction;

        if ( EFighterActionType.E_IGNORE_LIST ) {
            var boIgnore : int = EFighterActionType.E_IGNORE_LIST.indexOf( type );
            if ( boIgnore > -1 ) {
                Foundation.Log.logTraceMsg( "Ignore Type :" + type + "  to TimeLine" );
                return false;
            }
        }

        fightData = new CCharacterFightData();
        fightData.owner = owner;
        insertAction = fightData.recordActionsToData( actionType, msg );

        retNode = _insertDataTimeLineNode( fTime, fightData );
        if ( retNode != null )
            pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.EVT_TIME_LINE_NODE_INSERTED,
                    owner, [ retNode, insertAction ] ) );

        return retNode != null;
    }

    public function insertMsgAtCurrentTime( type : int, msg : CAbstractPackMessage ) : Boolean {
        var ret : Boolean;
        var currentTime : Number = currentLineTime;
        ret = insertMsgByType( type, currentTime, msg );
        return ret;
    }

    private function _insertDataTimeLineNode( fTime : Number, fightData : CCharacterFightData ) : CBaseFightTimeLineNode {
        var nodeData : CFightSyncNodeData;
        if ( !m_pFightHandler || !m_pFightTimeLine ) {
            Foundation.Log.logTraceMsg( "fightHandler or TimeLine are not ready !!" );
            return null;
        }
        nodeData = _allocateFightNodeData();
        nodeData.fSyncTime = fTime;
        nodeData.appendFighterData( fightData );
        var insertedNode : CBaseFightTimeLineNode = m_pFightTimeLine.insertNodeByData( nodeData );
        return insertedNode;
    }

    private function _allocateFightNodeData() : CFightSyncNodeData {
        var ret : CFightSyncNodeData = new CFightSyncNodeData();
        return ret;
    }

    final public function get currentLineTime() : Number {
        return m_pFightTimeLine.getCurrentTime();
    }

    public function get bStarted() : Boolean {
        if ( !m_pFightTimeLine || !m_pFightTimeLine.bStarted )
            return false;
        return true;
    }

    public function traceTimeLineMsg() : void {
        if ( m_pFightTimeLine ) {
            m_pFightTimeLine.traverse();
        }
    }

    public function get preSelfNode() : CBaseFightTimeLineNode {
        return null;
    }

    final private function get pFightTrigger() : CCharacterFightTriggle {
        return owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

//    private var m_pFightTimeLine : CFightTimeLine;
    private var m_pFightHandler : CFightHandler;

}
}
