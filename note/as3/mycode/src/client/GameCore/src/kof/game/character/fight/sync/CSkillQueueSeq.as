//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/10.
//----------------------------------------------------------------------
package kof.game.character.fight.sync {

public class CSkillQueueSeq implements IQueueSeq {
    public function CSkillQueueSeq() {
        clear();
    }

    public function setSkillQueue( queueID : int, skillID : int, time : Number ) : void {
        this.m_queueID = queueID;
        this.m_skillID = skillID;
        this.m_queueSeqTime = time;
    }

    public function from( other : CSkillQueueSeq ) : void {
        this.m_queueID = other.queueID;
        this.m_skillID = other.skillID
        this.m_queueSeqTime = other.queueSeqTime;
    }

    public function get queueID() : Number {
        return m_queueID;
    }

    public function stepQueueID() : void {
        m_queueID++;
    }

    public function clear() : void {
        m_queueID = 1;
        m_skillID = 0;
        m_queueSeqTime = 0.0;
    }

    public function get queueSeqTime() : Number {
        return m_queueSeqTime;
    }

    public function set queueID( value : Number ) : void {
        this.m_queueID = value;
    }

    public function set queueSeqTime( value : Number ) : void {
        this.m_queueSeqTime;
    }

    public function set skillID( value : int ) : void {
        this.m_skillID = value;
    }

    public function get skillID() : int {
        return m_skillID;
    }

    private var m_queueID : Number;
    private var m_queueSeqTime : Number;
    private var m_skillID : int;
}
}
