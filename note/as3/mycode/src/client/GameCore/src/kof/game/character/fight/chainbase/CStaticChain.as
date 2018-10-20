//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/11.
//----------------------------------------------------------------------
package kof.game.character.fight.chainbase {


public class CStaticChain {

    public function CStaticChain() : void
    {
        /**
         *首尾链接
         */
        m_headNode = new _CChainHeadNode();
        m_tailNode = new _CChainTailNode();
        m_middleNode = new _CChainHeadNode();

        m_headNode.nextNode = m_middleNode;
        m_tailNode.preNode = m_middleNode;

        m_middleNode.preNode = m_headNode;
        m_tailNode.nextNode = m_tailNode;

        m_dicParallelNodes = [];

    }

    public function dispose() : void
    {
        m_headNode.dispose();
        m_headNode = null;

        m_tailNode.dispose();
        m_tailNode = null;

        m_middleNode.dispose();
        m_middleNode = null;

        for each( var node : CChainBaseNode in m_dicParallelNodes )
        {
            node.dispose();
            node = null;
        }

        m_dicParallelNodes.splice( 0 , m_dicParallelNodes.length );
        m_dicParallelNodes = null;

        m_lastSequenceNode = null;
    }

    /**
     *
     * @param node do not point to the headNode and tailNode
     */
    public function addParallelChainNode( node : CChainBaseNode )  : void
    {
        var parallelLength : int = m_dicParallelNodes.length;
        node.preNode = m_middleNode;
        node.nextNode = m_tailNode;
        m_dicParallelNodes[length] = node;

    }
    //往当前节点插入顺序节点
    public function addSequenceChainNode( node : CChainBaseNode ) : Boolean
    {
        if( null == node ) return false;

        if( null == m_lastSequenceNode )
        {
            m_lastSequenceNode = node;
            m_lastSequenceNode.preNode = m_headNode;
            m_lastSequenceNode.nextNode = m_middleNode;
            m_headNode.nextNode = m_lastSequenceNode;
            return true;
        }

        var temNode : CChainBaseNode;
        temNode = m_lastSequenceNode.nextNode;

        m_lastSequenceNode.nextNode = node;
        node.preNode = m_lastSequenceNode;
        node.nextNode = temNode;

        m_lastSequenceNode = node ;
        return true;

    }

    public function removeSeqChainNode( node : CChainBaseNode ) : Boolean
    {
        var temPreNode : CChainBaseNode;
        temPreNode = m_lastSequenceNode;

        if( m_lastSequenceNode != null )
        {
            while ( temPreNode != m_headNode ) {
                if ( node != temPreNode ) {
                    temPreNode = temPreNode.preNode;
                    continue;
                }
                else
                {
                    var temNode : CChainBaseNode;
                    temNode = temPreNode.preNode;
                    temNode.nextNode = temPreNode.nextNode;

                    temPreNode.dispose();
                    temPreNode = null;
                    return true;
                }
            }
        }

        return false;
    }

    public function removeParalChainNode( node : CChainBaseNode ) : Boolean
    {
        for ( var i : int = 0 ; i< m_dicParallelNodes.length ; i++ )
        {
            if( node === m_dicParallelNodes[i] )
            {
                m_dicParallelNodes.splice( i , 1 );
                return true;
            }
        }

        return false;
    }

    /**
     *
     * @return if all chain is true return true;
     */
    public function traversingChain() : Boolean
    {
        var ret : Boolean = true ;
        var nextNode : CChainBaseNode = m_headNode;
        //evaluate the seq chain
        while ( nextNode != m_middleNode)
        {
            if( nextNode.isEvaluate() ){
                nextNode = nextNode.nextNode;
                continue;
            }
            else
            {
                return false;
            }
        }

        //evaluate the parallel chain
        var paraRet : Boolean = false;
        if( m_dicParallelNodes.length == 0 )
        {
            paraRet = true;
            return  ret && paraRet;
        }


        for( var i: int= 0 ; i< m_dicParallelNodes.length ; i++ )
        {
            paraRet  =  (m_dicParallelNodes[i] as CChainBaseNode).isEvaluate();
            if(paraRet) break;
        }

        return ret && paraRet;

    }

    //头结点是进入关键 判断是总是为true的
    private var m_headNode : _CChainHeadNode;
    private var m_tailNode : _CChainTailNode;
    private var m_middleNode : _CChainHeadNode;

    private var m_dicParallelNodes : Array;

    private var m_lastSequenceNode : CChainBaseNode;
}
}

import kof.game.character.fight.chainbase.CChainBaseNode;

/**
 * 链的首节点 判断条件始终为true
 */
class _CChainHeadNode extends CChainBaseNode
{
    public function _CChainHeadNode() : void
    {
        this.preNode = null;
    }

    override public function isEvaluate() : Boolean
    {
        return true;
    }
}

/**
 * 链的尾节点 判断条件始终为true
 */

class _CChainTailNode extends CChainBaseNode
{
    public function _CChainTailNode() : void
    {
        this.nextNode = null;
    }

    override  public function isEvaluate() : Boolean
    {
        return true;
    }
}
