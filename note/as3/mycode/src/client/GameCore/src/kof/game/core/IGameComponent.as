//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

import QFLib.Interface.IDisposable;

import kof.framework.IDataHolder;

/**
 * An interface for component be using in CGameObject.
 *
 * @see kof.game.core.CGameComponent
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IGameComponent extends IDisposable, IDataHolder {

    /** Returns the name of this component. */
    function get name() : String;

    /** Sets the name of this component. */
    function set name( value : String ) : void;

    /** Returns the owner of this component. */
    function get owner() : CGameObject;

    /** Returns true if the IGameComponent was enabled. */
    function get enabled() : Boolean;
    function set enabled( value : Boolean ) : void;

    /** A inline function for <code>CGameObject</code>'s getComponent.  */
    function getComponent( clazz : Class, cache : Boolean = true ) : IGameComponent;

}
}
