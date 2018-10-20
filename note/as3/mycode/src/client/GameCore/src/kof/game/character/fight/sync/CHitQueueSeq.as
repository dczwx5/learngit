//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/10.
//----------------------------------------------------------------------
package kof.game.character.fight.sync {

public class CHitQueueSeq implements IQueueSeq {

    public function CHitQueueSeq() {
    }

    public function get queueID() : Number
    {
        return m_queueID;
    }

    public function get queueSeqTime() : Number
    {
        return m_queueSeqTime;
    }

    public function set queueID( value : Number) : void
    {
        this.m_queueID = value;
    }

    public function set queueSeqTime( value : Number ) : void
    {
        this.m_queueSeqTime;
    }

    public function set skillID( value : int ) : void
    {
        this.m_skillID = value;
    }

    public function get skillID() : int
    {
        return m_skillID;
    }

    public function set hitID(value : int) :void
    {
        this.m_hitID = value;
    }

    public function get hitID() : int
    {
        return this.m_hitID;
    }

    private var m_queueID : Number;
    private var m_queueSeqTime : Number;
    private var  m_skillID : int ;
    private var m_hitID : int ;
}
}
