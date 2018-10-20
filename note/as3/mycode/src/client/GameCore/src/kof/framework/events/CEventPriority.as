//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.events {

/**
 * 事件优先级常量
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CEventPriority {

    //--------------------------------------------------------------------------
    // 以下从上到下优先级从高到底
    //--------------------------------------------------------------------------

    /** 鼠标样式控制 */
    public static const CURSOR_MANAGEMENT:int = 200;
    /** 数据绑定 */
    public static const BINDING:int = 100;
    /** 默认优先级 */
    public static const DEFAULT:int = 0;
    /** 默认控制器，常用于各系统的默认行为监听，这样在其余的辅助系统才可以保证进行默认行为阻断event.preventDefault() */
    public static const DEFAULT_HANDLER:int = -50;
    /** 特效表现 */
    public static const EFFECT:int = -100;

    public function CEventPriority() {
    }

}
}
