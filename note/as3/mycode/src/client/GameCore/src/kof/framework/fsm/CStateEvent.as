//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework.fsm {

import flash.events.Event;

/**
 * CState Event.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CStateEvent extends Event {

    public static const ENTER:String = "enterState";
    public static const LEAVE:String = "leaveState";
    public static const BEFORE:String = "beforeEvent";
    public static const AFTER:String = "afterEvent";
    public static const CHANGE:String = "changeStage";
    public static const TRANSITION_COMPLETE:String = "transitionComplete";
    public static const TRANSITION_CANCELLED:String = "transitionCancelled";

    private var m_strFrom:String;
    private var m_strTo:String;
    private var m_listArgs:Array;

    public function CStateEvent(name:String, from:String, to:String, args:Array = null) {
        super(name, false, true);
        this.m_strFrom = from;
        this.m_strTo = to;
        this.m_listArgs = args || [];
    }

    final public function get from():String { return m_strFrom; }
    final public function get to():String { return m_strTo; }
    final public function get argList():Array { return m_listArgs; }

}
}
