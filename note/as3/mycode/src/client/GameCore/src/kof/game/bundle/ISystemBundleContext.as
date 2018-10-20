package kof.game.bundle {

import QFLib.Interface.IDisposable;

import flash.events.IEventDispatcher;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ISystemBundleContext extends IEventDispatcher, IDisposable {

    /**
     * Returns the current <code>ISystemBundleConfiguration</code>.
     */
    function get configuration() : ISystemBundleConfiguration;

    /**
     * Assigned a new <code>ISystemBundleConfiguration</code>.
     */
    function set configuration( value : ISystemBundleConfiguration ) : void;

    function get defaultMatchingFilter() : Function;
    function set defaultMatchingFilter( value : Function ) : void;

    /**
     * Retrieves the <code>ISystemBundle</code> registered in this
     * <code>ISystemBundleContext</code>. <code>null</code> return when
     * non-exists in registered cache.
     */
    function getSystemBundle( idBundle : * ) : ISystemBundle;

    /**
     * Registers a <code>ISystemBundle</code>.
     */
    function registerSystemBundle( pBundle : ISystemBundle ) : void;

    /**
     * Unregisters a <code>ISystemBundle</code>.
     */
    function unregisterSystemBundle( pBundle : ISystemBundle ) : void;

    /**
     * Indicates the `state` value for the given <code>ISystemBundle</code>.
     */
    function getSystemBundleState( pBundle : ISystemBundle ) : int;

    /**
     * Retreives the user-defined data specify by the
     * <code>ISystemBundle</code>.
     *
     * @param pBundle <code>ISystemBundle</code> reference.
     * @param sProperty The property to request.
     * @param vDefault The default value when the request property non-exists.
     * @return The content of defined <code>property</code> or pre-defined
     * default value <code>vDefault</code> which was <code>undefined</code>
     */
    function getUserData( pBundle : ISystemBundle, sProperty : String, vDefault : * = undefined ) : *;

    function setUserData( pBundle : ISystemBundle, sProperty : String, pValue : *, matchingFilter : Function = null ) : void;
    function setUserDataOnly( pBundle : ISystemBundle, sProperty : String, pValue : * ) : void;

    function startBundle( pBundle : ISystemBundle ) : Boolean;
    function stopBundle( pBundle : ISystemBundle ) : Boolean;

    /**
     * Returns the iterator for <code>ISystemBundle</code>.
     */
    function get systemBundleIterator() : Object;

} // interface ISystemBundleContext
} // package kof.game.bundle


