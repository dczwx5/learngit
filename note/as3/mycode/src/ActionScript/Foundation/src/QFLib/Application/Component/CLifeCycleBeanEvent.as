//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Application.Component
{
    import flash.events.Event;

    /**
     * @author Jeremy (jeremy@qifun.com)
     */
    public class CLifeCycleBeanEvent extends Event
    {

        public static const BEAN_ADDED : String = "beanAdded";
        public static const BEAN_REMOVED : String = "beanRemoved";

        public function CLifeCycleBeanEvent( eventName : String,
                                             container : CContainerLifeCycle, child : * = null, bubbles : Boolean =
                                                     false, cancelable : Boolean = false )
        {
            super( eventName, bubbles, cancelable );
            this.parent = container;
            this.child = child;
        }

        public var parent : IContainer;
        public var child : *;

    }
}

