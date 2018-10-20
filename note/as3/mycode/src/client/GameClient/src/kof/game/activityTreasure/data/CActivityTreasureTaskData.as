//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by Ender 2018-6-30.
 */
package kof.game.activityTreasure.data {

/**
 * @author Ender
 * @date 2018-6-30
 */
public class CActivityTreasureTaskData {

    /**
     *  任务Id
     */
    private var id : int;
    /**
     * 任务状态 0未完成 1可领取(可能不需要) 2已领取
     */
    private var state : int;
    /**
     * 当前任务进度
     */
    private var currVal : int;

    public function CActivityTreasureTaskData( id : int = 0, currVal : int = 0, state : int = 0 ) {
        m_id = id;
        m_state = state;
        m_currVal = currVal;
    }

    public function get m_id() : int {
        return id;
    }

    public function set m_id( value : int ) : void {
        id = value;
    }

    public function get m_currVal() : int {
        return currVal;
    }

    public function set m_currVal( value : int ) : void {
        currVal = value;
    }

    public function get m_state() : int {
        return state;
    }

    public function set m_state( value : int ) : void {
        state = value;
    }
}
}
