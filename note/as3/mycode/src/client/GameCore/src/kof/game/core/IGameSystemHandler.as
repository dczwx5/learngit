//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IGameSystemHandler {

    function get enabled() : Boolean;

    function set enabled( value : Boolean ) : void;

    function isComponentSupported( obj : CGameObject ) : Boolean;

    function beforeTick( delta : Number ) : void;

    function tickValidate( delta : Number, obj : CGameObject ) : Boolean;

    function tickUpdate( delta : Number, obj : CGameObject ) : void;

    function afterTick( delta : Number ) : void;

}
}
