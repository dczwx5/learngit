package kof.game.bundle {

import QFLib.Interface.IDisposable;

import flash.events.Event;

import kof.framework.IPropertyChangeDescriptor;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSystemBundleEvent extends Event implements IDisposable {

    static public const BUNDLE_REGISTERED : String = "bundleRegistered";
    static public const BUNDLE_UNREGISTERED : String = "bundleUnRegistered";

    static public const BUNDLE_START : String = "bundleStart";
    static public const BUNDLE_STOP : String = "bundleStop";
    static public const USER_DATA : String = "bundleUserData";

    internal var m_pBundle : ISystemBundle;
    internal var m_pContext : ISystemBundleContext;
    internal var m_pEndCallbacks : Vector.<Function>;
    internal var m_pPropertyData : IPropertyChangeDescriptor;

    /**
     * Creates a new CSystemBundleEvent.
     */
    public function CSystemBundleEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false ) {
        super( type, bubbles, cancelable );
    }

    public function dispose() : void {
        m_pBundle = null;
        m_pContext = null;
        if ( m_pEndCallbacks && m_pEndCallbacks.length )
            m_pEndCallbacks.splice( 0, m_pEndCallbacks.length );
        m_pEndCallbacks = null;
    }

    /**
     * Returns the context which the bundle attached to.
     */
    public function get context() : ISystemBundleContext {
        return m_pContext;
    }

    /**
     * Returns the bundle which the event dispatched.
     */
    public function get bundle() : ISystemBundle {
        return m_pBundle;
    }

    public function subscribeEventPhaseEnd( pCallback : Function ) : void {
        if ( !m_pEndCallbacks )
            m_pEndCallbacks = new <Function>[];
        if ( m_pEndCallbacks.indexOf( pCallback ) == -1 )
            m_pEndCallbacks.push( pCallback );
    }

    public function get propertyData() : IPropertyChangeDescriptor {
        return m_pPropertyData;
    }

} // class CSystemBundleEvent
} // package kof.game.bundle
