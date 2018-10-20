//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/27.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base {

import QFLib.Foundation;
import QFLib.Foundation.CTimer;
import QFLib.Memory.CResourcePool;

/**
 * 时间线数据结构 双向链表结构
 */
public class CFightTimeLine implements IFightTimeLine {
    public function CFightTimeLine( name : String ) {
        m_sTimeLineName = name;
        m_NodePool = new CResourcePool( "fight node pool", CBaseFightTimeLineNode, 100 );
        m_theTimer = new CTimer();
    }

    public function update( delta : Number ) : void {
        if ( !isNaN( m_fTimeLineElapse ) ) {
            var toFixElapse : Number = int( m_fTimeLineElapse * 1000 ) / 1000;
            m_fTimeLineElapse = toFixElapse + delta;
        }
    }

    public function recycle() : void {
        var pNode : CBaseFightTimeLineNode = m_theHeadNode;
        while ( pNode != null ) {
            var temNext : CBaseFightTimeLineNode = pNode.next;
            m_NodePool.recycle( pNode );
            pNode = null;
            pNode = temNext;
        }
        m_theHeadNode = null;
        m_theLastNode = null;
        m_fTimeLineElapse = NaN;
        m_fStartedTime = NaN;
    }

    public function dispose() : void {
        var pNode : CBaseFightTimeLineNode = m_theHeadNode;
        while ( pNode != null ) {
            var temNext : CBaseFightTimeLineNode = pNode.next;
            pNode.dispose();
            pNode = null;
            pNode = temNext;
        }

        if ( m_NodePool ) {
            m_NodePool.dispose();
        }
        m_NodePool = null;
        m_fTimeLineElapse = NaN;
        m_fStartedTime = NaN;
        m_theLastNode = null;
    }

    public function getCurrentTime() : Number {
        if ( isNaN( m_fStartedTime ) || isNaN( m_fTimeLineElapse ) )
            return NaN;

        return m_theTimer.seconds();
//        return m_fStartedTime + m_fTimeLineElapse;
    }

    public function setStartAtTime( fStartedTime : Number ) : void {
        m_fStartedTime = fStartedTime;
        m_fTimeLineElapse = 0.000;
        m_theTimer.reset();
    }

    public function get bStarted() : Boolean {
        return !isNaN( m_fStartedTime ) && !isNaN( m_fTimeLineElapse );
    }

    public function createNodeByData( data : CFightSyncNodeData ) : CBaseFightTimeLineNode {
        if ( null == data ) return null;
        var node : CBaseFightTimeLineNode = _allocateNode();
        node.nodeFightData = data;
        return node;
    }

    public function findNodeByData( data : CFightSyncNodeData ) : CBaseFightTimeLineNode {
        var temNode : CBaseFightTimeLineNode;
        if ( null == m_theHeadNode ) return null;
        temNode = m_theHeadNode;
        while ( temNode ) {
            if ( temNode.nodeDataTime == data.fSyncTime )
                return temNode;
            temNode = temNode.next;
        }
        return null;
    }

    public function deleteNodeByData( data : CFightSyncNodeData ) : Boolean {
        if ( null == data ) return false;

        var existNode : CBaseFightTimeLineNode;
        existNode = findNodeByData( data );

        if ( null == existNode )
            return false;

        if ( m_theHeadNode == existNode ) {
            if ( null != m_theHeadNode.next ) {
                m_theHeadNode = existNode.next;
                m_theHeadNode.prev = null;
            }
        } else {
            if ( null != existNode.next ) {
                existNode.next.prev = existNode.prev;
                existNode.prev.next = existNode.next;
            }
        }

        _freeNode( existNode );
        return true;
    }

    public function insertNodeByData( data : CFightSyncNodeData ) : CBaseFightTimeLineNode{
        var comingNode : CBaseFightTimeLineNode;
        var fightData : CCharacterFightData;
        if ( m_theHeadNode == null ) {
            m_theHeadNode = createNodeByData( data );
            m_theLastNode = m_theHeadNode;
            return m_theHeadNode;
        }

        comingNode = findNodeByData( data );
        if ( null != findNodeByData( data ) ) {
            var fighterDataList : Vector.<CCharacterFightData> = data.getFighterDatas();
            for each ( fightData in  fighterDataList ) {
                comingNode.appenFighterData( fightData );
            }
            if ( m_theLastNode.nodeDataTime < comingNode.nodeDataTime )
                m_theLastNode = comingNode;
            return comingNode;
        }

        var insertHeadNode : CBaseFightTimeLineNode;
        insertHeadNode = _getPreInsertHeadNode( data );
        if ( insertHeadNode == null ) {
            comingNode = createNodeByData( data );
            comingNode.next = m_theHeadNode;
            m_theHeadNode.prev = comingNode;
            if ( comingNode.nodeDataTime > m_theLastNode.nodeDataTime )
                m_theLastNode = comingNode;
            return comingNode;
        }

        if ( insertHeadNode.nodeDataTime != data.fSyncTime ) {
            comingNode = createNodeByData( data );
            comingNode.prev = insertHeadNode;
            comingNode.next = insertHeadNode.next;
            insertHeadNode.next = comingNode;
            if ( comingNode.nodeDataTime > m_theLastNode.nodeDataTime )
                m_theLastNode = comingNode;
            return comingNode;
        }

        if ( insertHeadNode.nodeDataTime == data.fSyncTime ) {
            comingNode = insertHeadNode;
            for each( fightData in data.getFighterDatas() ) {
                comingNode.appenFighterData( fightData );
            }
            if ( comingNode.nodeDataTime > m_theLastNode.nodeDataTime )
                m_theLastNode = comingNode;
            return comingNode ;
        }
        return null;
    }

    public function get nodeCount() : int {
        var count : int = 1;
        var pNode : CBaseFightTimeLineNode = m_theHeadNode;
        while ( null != pNode.next ) {
            count++;
            pNode = pNode.next;
        }
        return count;
    }

    private function _getPreInsertHeadNodeByData( data : CFightSyncNodeData ) : CBaseFightTimeLineNode {

        var fTime : Number = data.fSyncTime;
        var temTime : Number;
        var pNode : CBaseFightTimeLineNode = m_theHeadNode;
        var retNode : CBaseFightTimeLineNode;
        while ( null != pNode ) {
            temTime = pNode.nodeFightData.fSyncTime;
            if ( temTime > fTime )
                retNode = pNode.prev;
            if ( temTime == fTime )
                retNode = pNode;
            retNode = pNode;
            pNode = pNode.next;
        }
        return retNode;
    }

    private function _getPreInsertHeadNode( data : CFightSyncNodeData ) : CBaseFightTimeLineNode {
        if ( m_theLastNode == null )
            return null;
        var pNode : CBaseFightTimeLineNode;
        var dataTime : Number = data.fSyncTime;
        var temTime : Number;

        pNode = m_theLastNode;
        temTime = pNode.nodeDataTime;

        if ( temTime == dataTime )
            return m_theLastNode.prev;

        if ( temTime > dataTime ) {
            while ( pNode != null ) {
                temTime = pNode.nodeDataTime;
                if ( temTime <= dataTime )
                    return pNode;

                pNode = pNode.prev;
            }
        }

        if( temTime < dataTime ) {
            return m_theLastNode;
        }

        return null;
    }

    private function _freeNode( existNode : CBaseFightTimeLineNode ) : Boolean {
        if ( existNode == null )
            return true;
        if ( existNode.nodeFightData ) {
            existNode.nodeFightData.dispose();
        }
        existNode.dispose();
        existNode.nodeFightData = null;
        existNode = null;
        return true;
    }

    private function _recycleNode( existNode : CBaseFightTimeLineNode ) : Boolean {
        if ( existNode == null )
            return true;
        if ( existNode.nodeFightData ) {
            existNode.nodeFightData.recycle();
        }

        m_NodePool.recycle( existNode );
        existNode = null;
        return true;
    }

    public function traverse() : void {

        var pNode : CBaseFightTimeLineNode = m_theHeadNode;
        var seqCount : int = 1;
        var traceMsg : String = "{ TheTimeLineQueueIsAsFollow : ";
        while ( null != pNode ) {
            var nodeDataMsg : String = "";
            for each( var fightData : CCharacterFightData in pNode.nodeFightData.getFighterDatas() ) {
                nodeDataMsg += fightData.fightNodeMsg;
            }
            traceMsg += "{ SeqID: " + (seqCount++) + " ," +
                    "ActionTime: " + pNode.nodeDataTime + "," +
                    nodeDataMsg + "}";
            pNode = pNode.next;
            if ( pNode != null ) traceMsg += ",";
        }
        traceMsg += "}";
        Foundation.Log.logTraceMsg( traceMsg );
    }

    private function _allocateNode() : CBaseFightTimeLineNode {
        return m_NodePool.allocate() as CBaseFightTimeLineNode;//new CBaseFightTimeLineNode();
    }


    private var m_sTimeLineName : String;
    private var m_theHeadNode : CBaseFightTimeLineNode;
    private var m_theLastNode : CBaseFightTimeLineNode;
    private var m_NodePool : CResourcePool;
    private var m_fTimeLineElapse : Number;
    private var m_fStartedTime : Number;
    private var m_theTimer : CTimer;

}
}
