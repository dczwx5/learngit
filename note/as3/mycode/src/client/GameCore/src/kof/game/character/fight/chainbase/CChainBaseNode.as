//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/11.
//----------------------------------------------------------------------
package kof.game.character.fight.chainbase {

import kof.game.character.fight.skillchain.ISkillConditionEvaluate;

/**
 * the base node of a chain , contain a pre node and next node,
 */
public class CChainBaseNode implements ISkillConditionEvaluate{

    public function CChainBaseNode() {

    }

    public function dispose() : void
    {
        this.preNode = null;
        this.nextNode = null;
    }

    public function isEvaluate() : Boolean
    {
        return false;
    }

    public function get evaluateValue() : *
    {
        return m_evaluateValue;
    }

    public function set evaluateValue( value : * ) : void
    {
        m_evaluateValue = value;
    }

    public function get evaluateType() : int
    {
        return m_evaluateType
    }
    public function get evaluateSuperType() : int
    {
        return m_evaluateSuperType;
    }

    final public function get nextNode() : CChainBaseNode
    {
        return m_nextNode;
    }

    final public function get preNode() : CChainBaseNode
    {
        return m_preNode;
    }

    final public function set nextNode(node : CChainBaseNode) : void
    {
        m_nextNode = node;
    }

    final public function set preNode(node : CChainBaseNode) : void
    {
        m_preNode = node;
    }

    private var m_nextNode : CChainBaseNode;
    private var m_preNode : CChainBaseNode;

    /**
     * 每个node的数据部分 实现借口ISkillConditionEvaluate
     */
    protected var m_evaluateType : int;
    protected var m_evaluateSuperType : int;
    protected var m_evaluateValue : *;
}
}
