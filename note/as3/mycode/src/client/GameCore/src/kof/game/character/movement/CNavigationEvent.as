//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.movement {

import flash.events.Event;
import flash.geom.Point;

/**
 * 导航事件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CNavigationEvent extends Event {

    static public const EVENT_BEGIN : String = "navigationBegin";
    static public const EVENT_CHECKPOINT : String = "navigationCheckPoint";
    static public const EVENT_END : String = "navigationEnd";

    private var m_pCurrentPoint : Point;

    /**
     * Creates a new CNavigationEvent.
     */
    public function CNavigationEvent( type : String, theCurrentPoint : Point ) {
        super( type, false, false );

        this.m_pCurrentPoint = theCurrentPoint;
    }

    final public function get currentPoint() : Point {
        return m_pCurrentPoint;
    }

}
}
// vim:ft=as3 ts=4 sw=4 et tw=0

