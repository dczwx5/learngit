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
public class CTreasureBoxData {

    /**
     * 宝箱Id。取值1~8
     */
    private var boxId : int;
    /**
     * 宝箱状态 0未开启 1可开启 2已开启
     */
    private var boxState : int;

    public function CTreasureBoxData( boxId : int = 0, boxState : int = 0 ) {
        m_boxId = boxId;
        m_boxState = boxState;
    }

    public function get m_boxId() : int {
        return boxId;
    }

    public function set m_boxId( value : int ) : void {
        boxId = value;
    }

    public function get m_boxState() : int {
        return boxState;
    }

    public function set m_boxState( value : int ) : void {
        boxState = value;
    }
}
}
