//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.triggers {

import flash.events.Event;

/**
 * 功能开启触发器事件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingTriggerEvent extends Event {

    /** Creates a new CSwitchingTriggerEvent */
    public function CSwitchingTriggerEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
    }

    private var m_bInitPhase : Boolean;

    public function get isInitPhase() : Boolean {
        return m_bInitPhase;
    }

    public function set isInitPhase( value : Boolean ) : void {
        m_bInitPhase = value;
    }

}
}
