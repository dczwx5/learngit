//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/6/27.
 */
package kof.game.activityHall.data {

public class CActivityState {
    public function CActivityState() {
    }
    /**
     *准备中
     */
    public static const ACTIVITY_PREPARE:int = 1;
    /**
     *开始
     */
    public static const ACTIVITY_START:int = 2;

    /**
     *完成
     */
    public static const ACTIVITY_COMPLETE:int = 3;

    /**
     *结束
     */
    public static const ACTIVITY_END:int = 4;

    /**
     *关闭
     */
    public static const ACTIVITY_CLOSE:int = 5;

}
}
