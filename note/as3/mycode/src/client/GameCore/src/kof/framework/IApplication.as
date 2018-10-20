//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import flash.events.IEventDispatcher;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IApplication {

    /**
     * Returns the configuration.
     */
    function get configuration() : IConfiguration;

    function get timer() : IAppTimer;

    function get pause() : Boolean;

    function set pause( value : Boolean ) : void;

    function get eventDispatcher() : IEventDispatcher;

    /**
     * Run with the target CAppStage instance.
     */

    function get runningStage() : CAppStage;

    function runWithStage( stage : CAppStage ) : void;

    function pushStage( stage : CAppStage ) : void;

    function popStage() : void;

    function popToRootStage() : void;

    function popToStageStackLevel( level : int ) : void;

    function replaceStage( stage : CAppStage ) : void;

    function get deltaFactor() : Number;

    function set deltaFactor( fFactor : Number ) : void;

} // interface IApplication
}
