//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by Ender 2018-6-29.
 */
package kof.game.activityTreasure.data {

/**
 * @author Ender
 * @date 2018-6-29
 */
public class CDartsPointData {
    /**
     * 苦无靶点Id
     */
    private var id : int;
    /**
     * 苦无靶点状态：0————可投射，1————已投射
     */
    private var state : int;

    public function CDartsPointData( id : int = 0, state : int = 0 ) {
        m_id = id;
        m_state = state;
    }

    public function get m_id() : int {
        return id;
    }

    public function set m_id( value : int ) : void {
        id = value;
    }

    public function get m_state() : int {
        return state;
    }

    public function set m_state( value : int ) : void {
        state = value;
    }
}
}
