//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Application.Component
{

    /**
     *
     * @author Jeremy (jeremy@qifun.com)
     */
    public interface ILifeCycle
    {

        function get isFailed() : Boolean;

        function get isStarted() : Boolean;

        function get isStopped() : Boolean;

        function get isStopping() : Boolean;

        function get isStarting() : Boolean;

        function get isRunning() : Boolean;

        function start() : void;

        function stop() : void;

        function addLifeCycleListener( func : Function ) : void;

        function removeLifeCycleListener( func : Function ) : void;

    } // interface ILifeCycle.
}
