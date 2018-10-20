package kof.game.bundle {

import QFLib.Interface.IDisposable;

import flash.events.IEventDispatcher;

[Event(name="bundleStart", type="kof.game.bundle.CSystemBundleEvent")]
[Event(name="bundleStop", type="kof.game.bundle.CSystemBundleEvent")]
[Event(name="bundleUserData", type="kof.game.bundle.CSystemBundleEvent")]
/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ISystemBundle extends IDisposable, IEventDispatcher {

    /**
     * Returns the ID, any type supported, make sure <code>==</code>
     * compare correct.
     */
    function get bundleID() : *;

} // interface ISystemBundle
} // package kof.game.bundle

