//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Application.Component
{
    import flash.events.Event;

    /**
     * @author Jeremy (jeremy@qifun.com)
     */
    public class CLifeCycleEvent extends Event
    {

        public static const FAILED : String = "Failed";
        public static const STARTING : String = "Starting";
        public static const AFTER_STARTING : String = "AfterStarting";
        public static const STARTED : String = "Started";
        public static const STOPPING : String = "Stopping";
        public static const STOPPED : String = "Stopped";
        public static const TRANSITION_COMPLETED : String = "TransitionCompleted";

        public var error : Error;

        public function CLifeCycleEvent( eventName : String, bubbles : Boolean = false, cancelable : Boolean = false )
        {
            super( eventName, bubbles, cancelable );
        }
    }
}
