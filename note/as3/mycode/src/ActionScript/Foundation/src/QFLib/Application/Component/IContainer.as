//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Application.Component
{
    import flash.events.IEventDispatcher;

    /**
     * @author Jeremy (jeremy@qifun.com)
     */
    public interface IContainer extends IEventDispatcher
    {

        function addBean( o : *, managed : int = 0 ) : Boolean;

        function getBeans( filter : Function = null ) : Vector.<Object>;

        function updateBean( oldBean : *, newBean : *, managed : int = 0 ) : void;

        function removeBean( o : * ) : Boolean;

    } // interface IContainer
} // package...

