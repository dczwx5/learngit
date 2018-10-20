//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.bundle {

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ISystemBundleState {

    function get value() : int;

    function get isStopped() : Boolean;

    function get isStarted() : Boolean;

}
}
