//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Application.Component
{
    import flash.events.IEventDispatcher;

    [Event(name="beanAdded", type="QFLib.Application.Component.CLifeCycleBeanEvent")]
    [Event(name="beanRemoved", type="QFLib.Application.Component.CLifeCycleBeanEvent")]
    /**
     * @author Jeremy (jeremy@qifun.com)
     */
    public interface ILifeCycleListener extends IEventDispatcher
    {

        function get isInherited() : Boolean;

    }
}
