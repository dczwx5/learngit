//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/19.
 */
package kof.game.task.data {

public class CTaskStateType {
    public function CTaskStateType() {
    }

    /** 尚未能接取 */
    public static const CAN_NOT_RECEIVE:int = -1;

    /** 已接取，还不能进行 */
    public static const CAN_NOT_DO:int = 1;

    /** 已接取，可进行 */
    public static const CAN_DO:int = 2;

    /** 已完成*/
    public static const FINISH:int = 3;

    /** 已完成并且领奖完毕*/
    public static const COMPLETE:int = 4;
}
}
