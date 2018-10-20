//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package kof.game.Tutorial.battleTutorPlay {

import flash.display.Stage;

import kof.framework.CAppSystem;

public interface IBattleTutorFacade {
    function dispose() : void ;
    function initialize() : void ;

    function listenEvent(func:Function) : void ;
    function unListenEvent(func:Function) : void ;

    function start(data:CBattleTutorData) : void ;
    function hide() : void ;
    function stop() : void ;
    function set system(v:CAppSystem) : void ;
    function  playing() : Boolean;

    function get stage() : Stage ;
    function set stage(value:Stage) : void ;

}
}
