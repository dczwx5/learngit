//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/14.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.syncentity {

import QFLib.Foundation.CMap;

import flash.utils.Dictionary;

import kof.game.character.fight.sync.CHitQueueSeq;

import kof.game.core.CGameObject;

/**
 * 全局的击打同步的信息
 */
public class CHitStateSync {

    public function CHitStateSync() : void {
//        m_targetListInfo = new Dictionary();
    }

    public function reset() : void {
        this.m_targetListInfo = null;
        this.m_skillID = 1;
        this.m_queueSeq = null;
        this.m_hitID = 1;
        this.m_hitQueueID = 1;
        this.m_skillQueueID = 1;
    }

    public function get TargetListInfo() : Dictionary {
        return m_targetListInfo;
    }

    final public function set targetListInfo( value : Dictionary ) : void {
        m_targetListInfo = value;
    }

    final public function set hitQueueSeq( value : CHitQueueSeq ) : void {
        m_queueSeq = value;
    }

    final public function get hitQueueSeq() : CHitQueueSeq {
        return m_queueSeq;
    }

    final public function setSkillQueue( skillQueueID : int, skillID : int ) : void {
        this.m_skillID = skillID;
        this.m_skillQueueID = skillQueueID;
    }

    final public function setHitQueue( hitQueueID : int, hitID : int,
                                       targetList : Vector.<CGameObject>,skillHitQueueId : int) : void {
        this.m_hitID = hitID;
        this.m_hitQueueID = hitQueueID;
        this.m_pTargetList = targetList;
        this.m_skillHitQueueID = skillHitQueueId;
    }

    public function get skillQueueID() : Number {
        return m_skillQueueID;
    }

    public function get skillID() : int {
        return m_skillID;
    }

    public function get hitID ( ) : int {
        return m_hitID;
    }

    public function get hitQueueID () : int {
        return m_hitQueueID;
    }

    public function get hitTargetList() : Vector.<CGameObject>{
        return m_pTargetList;
    }

    public function get skillHitQueueID() : int{
        return m_skillHitQueueID;
    }

    private var m_targetListInfo : Dictionary;
    private var m_pTargetList :Vector.<CGameObject>;
    private var m_queueSeq : CHitQueueSeq;
    private var m_hitQueueID : int;
    private var m_hitID : int;
    private var m_skillQueueID : int;
    private var m_skillID : int;
    private var m_skillHitQueueID : int;
}
}