//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/8/11.
 */
package kof.game.newServerActivity.data {

import QFLib.Foundation.CMap;

import flash.utils.Dictionary;

import kof.data.CObjectData;

public class CNewServerActivityData extends CObjectData{

    private var m_iRank : int; //我的排名
    private var m_iForce : int;//我的战斗力

    private var m_sFirstName : String;//排名第一的名字
    private var m_iFirstForce : int;
    private var m_iFirstHeadID : int;
    private var m_iFirstID : int;

    private var m_rewardStateDic : Dictionary;//true

    public function CNewServerActivityData() {
        super();
        _data = new CMap();
    }

    override public function updateDataByData( data : Object ) : void
    {
        if( !data ) return;
        m_iRank = data["selfInfo" ].rank;
        m_iForce = data["selfInfo" ].value;
        m_rewardStateDic = new Dictionary();
        if( data["prizeState" ].length > 0 )
        {
            for( var i : int = 0; i < data["prizeState" ].length; i++ )
            {
                var stage : int = data["prizeState" ][ i ].stage;
                var state :Boolean = data["prizeState" ][ i ].state;
                m_rewardStateDic[stage] = state;
            }
        }
        m_sFirstName = data["firstInfo" ].name;
        m_iFirstForce = data["firstInfo" ].value;
        m_iFirstHeadID = data["firstInfo" ].headId;
        m_iFirstID = data["firstInfo" ]._id;
    }

    public function get myRank() : int { return m_iRank ; }
    public function get myForce() : int { return m_iForce; }
    public function get stageRewardState() : Dictionary { return m_rewardStateDic;}
    public function get firstHeadID() : int { return m_iFirstHeadID;}
    public function get firstName() : String { return m_sFirstName; }
    public function get firstForce() : int { return m_iFirstForce;}
    public function get firstID() : int { return m_iFirstID;}
}
}

