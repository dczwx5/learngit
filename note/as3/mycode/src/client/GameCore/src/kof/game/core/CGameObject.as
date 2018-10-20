//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;
import QFLib.Memory.CSmartObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

import kof.framework.IDataHolder;

/**
 * Dispatching when this CGameObject was added to the handling container.
 */
[Event(name="add", type="flash.events.Event")]
/**
 * Dispatching when this CGameObject was removed from the handling container.
 */
[Event(name="remove", type="flash.events.Event")]
/**
 * A container object that contains a lot of <code>IGameComponent</code>s using
 * in the <code>CECSLoop</code>.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CGameObject extends CSmartObject implements IDisposable, IDataHolder, IEventDispatcher {

    internal static const COMPONENT_CLASS_IDS : CMap = new CMap();

    /** @private */
    protected var m_components : Vector.<IGameComponent>;
    /** @private */
    internal var classToComponentMap : Dictionary;
    /** @private */
    internal var m_data : Object;
    /** @private */
    internal var m_bDataDirty : Boolean;
    /** @private */
    internal var m_eventDelegate : IEventDispatcher;
    /** @private */
    internal var m_pTransform : ITransform;
    /** @private */
    internal var m_bRunning : Boolean;

    internal static function getClassIDByClass( clazz : Class ) : int {
        var ID : int = COMPONENT_CLASS_IDS.find( clazz );
        if ( !ID ) {
            COMPONENT_CLASS_IDS.add( clazz, COMPONENT_CLASS_IDS.length + 1 );
            ID = COMPONENT_CLASS_IDS.find( clazz );
        }
        return ID;
    }

    /**
     * Creates a new CGameObject.
     */
    public function CGameObject( data : Object = null ) {
        super();

        m_bRunning = false;
        m_data = data;
        m_components = new <IGameComponent>[];
        m_eventDelegate = new EventDispatcher();
        classToComponentMap = new Dictionary( true );
    }

    /**
     * @inheritDoc
     */
    override public function dispose() : void {
        super.dispose();

        this.onRemoved();

        m_bRunning = false;
        m_eventDelegate = null;
        m_data = null;
        if ( m_components )
            m_components.splice( 0, m_components.length );
        m_components = null;
        classToComponentMap = null;

        if ( m_pTransform )
            m_pTransform.dispose();
        m_pTransform = null;
    }

    [Inline]
    final public function get transform() : ITransform {
        if ( !m_pTransform ) {
            m_pTransform = getComponentByClass( ITransform, m_bRunning ) as ITransform;
        }
        return m_pTransform;
    }

    /**
     * @inheritDoc
     */
    [Inline]
    final public function get data() : Object {
        return m_data;
    }

    [Inline]
    /** @private */
    final public function set data( value : Object ) : void {
        if ( m_data == value )
            return;
        m_data = value;
        m_bDataDirty = true;
    }

    [Inline]
    final public function get isRunning() : Boolean {
        return m_bRunning;
    }

    /** Called by CECSLoop when this CGameObject was added. */
    final internal function onAdded() : void {
        m_bRunning = true;

        if ( m_components && m_components.length ) {
            for each ( var comp : IGameComponent in m_components ) {
                if ( comp is CGameComponent ) {
                    (comp as CGameComponent).setEnter();
                }
            }
        }
    }

    /** Called by CECSLoop when this CGameObject was removed. */
    final internal function onRemoved() : void {
        m_bRunning = false;

        var reversed : Vector.<IGameComponent>= m_components.slice().reverse();

//        if (m_components && m_components.length) {
        if( reversed && reversed.length ){
            for each (var comp:IGameComponent in reversed ) {
                if (comp is CGameComponent) {
                    (comp as CGameComponent).setExit();
                }
            }
        }
    }

    /**
     * Returns a full components of this CGameObject, be careful.
     */
    [Inline]
    final public function get components() : Vector.<IGameComponent> {
        return m_components;
    }

    /**
     * Adds many <code>IGameComponent</code> into this <code>CGameObject</code>,
     * and return the added <code>IGameComponent</code>.
     *
     * @param comps A non-fixed arguments typeof IGameComponent.
     */
    final public function addComponents( ... comps ) : Vector.<IGameComponent> {
        const ret : Vector.<IGameComponent> = new <IGameComponent>[];
        for each ( var c : * in comps ) {
            if ( c is IGameComponent ) {
                this.addComponent( c as IGameComponent );
                ret.push( c );
            }
        }

        return ret;
    }

    /**
     * Adds a <code>IGameComponent</code> into this <code>CGameObject</code>.
     *
     * @param component The component to add.
     */
    final public function addComponent( component : IGameComponent ) : void {
        if ( !component )
            return;
        this.m_components.push( component );
        if ( component is IGameComponent )
            (component as CGameComponent).setOwner( this );
    }

    /**
     * Removes from this <code>CGameObject</code> and returns the removed
     * <code>IGameComponent</code>s.
     *
     * @param dispose
     * @param comps A non-fixed arguments typeof IGameComponent.
     */
    final public function removeComponents( dispose : Boolean, ... comps ) : Vector.<IGameComponent> {
        const ret : Vector.<IGameComponent> = new <IGameComponent>[];
        for each ( var c : * in comps ) {
            if ( c is IGameComponent ) {
                if ( this.removeComponent( c as IGameComponent, dispose ) ) {
                    ret.push( c );
                }
            }
        }
        return ret;
    }

    /**
     * Removes from this <code>CGameObject</code>, return true if removed
     * success, false otherwise.
     *
     * @param component The component to remove.
     * @param dispose True if dispose() be called.
     */
    final public function removeComponent( component : IGameComponent, dispose : Boolean ) : Boolean {
        const index : int = this.m_components.indexOf( component );
        if ( index != -1 ) {
            this.m_components.splice( index, 1 );
            if ( component is CGameComponent )
                (component as CGameComponent).setOwner( null );

            if ( dispose )
                component.dispose();

            if ( component == this.m_pTransform )
                m_pTransform = null;

            for ( var keyClassID : int in classToComponentMap ) {
                if ( classToComponentMap[keyClassID] == component )
                    delete classToComponentMap[ keyClassID ];
            }

            return true;
        }
        return false;
    }

    /**
     * Retrieves the first component typeof <code>class</code>. If
     * <code>cache</code> was true, then caching the class to component mapping,
     * false otherwise.
     */
    final public function getComponentByClass( clazz : Class, cache : Boolean ) : IGameComponent {
        if ( !clazz )
            return null;
        var ID : int = getClassIDByClass( clazz );
        if ( ID in classToComponentMap )
            return classToComponentMap[ ID ] as IGameComponent;
        const comp : IGameComponent = this.findComponentByClass( clazz );
        if ( cache && comp ) {
            classToComponentMap[ ID ] = comp;
        }
        return comp;
    }

    /**
     * Tells whether the specified <code>component</code> contains in this
     * <code>CGameObject</code>.
     *
     * @param component A component to check.
     */
    final public function findComponent( component : IGameComponent ) : IGameComponent {
        if ( !component )
            return null;

        const index : int = this.m_components.indexOf( component );
        if ( index != -1 ) {
            return this.m_components[ index ] as IGameComponent;
        }
        return null;
    }

    /**
     * Returns a <code>IGameComponent</code> which matching first or null if not
     * .found
     */
    final public function findComponentByClass( clazz : Class ) : IGameComponent {
        if ( null == clazz )
            return null;

        for each ( var comp : IGameComponent in m_components ) {
            if ( comp is clazz )
                return comp;
        }
        return null;
    }

    /**
     * Removes all the <code>IGameComponent</code> from this
     * <code>CGameObject</code>.
     */
    final public function removeAllComponents( dispose : Boolean ) : void {
        var reversed : Vector.<IGameComponent> = this.m_components.slice().reverse();
        var comp : IGameComponent;
        for each ( comp in reversed ) {
            this.removeComponent( comp, false );
        }

        if ( dispose ) {
            for each ( comp in reversed ) {
                comp.dispose();
            }
        }

        reversed.splice( 0, reversed.length );

        for (var keyClassID : int in classToComponentMap) {
            delete classToComponentMap[ keyClassID ];
        }
    }

    [Inline]
    final public function invalidateData() : void {
        m_bDataDirty = true;
    }

    final internal function updateData() : void {
        if ( m_bDataDirty ) {
            m_bDataDirty = false;

            if ( m_components && m_components.length ) {
                for each ( var comp : IGameComponent in m_components ) {
                    if ( comp is CGameComponent ) {
                        (comp as CGameComponent).setDataUpdated();
                    }
                }
            }
        }
    }

    /**
     * @inheritDoc
     */
    final public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0,
                                            useWeakReference : Boolean = false ) : void {
        m_eventDelegate.addEventListener( type, listener, useCapture, priority, useWeakReference );
    }

    /**
     * @inheritDoc
     */
    final public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void {
        m_eventDelegate.removeEventListener( type, listener, useCapture );
    }

    /**
     * @inheritDoc
     */
    [Inline]
    final public function dispatchEvent( event : Event ) : Boolean {
        return m_eventDelegate.dispatchEvent( event );
    }

    /**
     * @inheritDoc
     */
    [Inline]
    final public function hasEventListener( type : String ) : Boolean {
        return m_eventDelegate.hasEventListener( type );
    }

    /**
     * @inheritDoc
     */
    [Inline]
    final public function willTrigger( type : String ) : Boolean {
        return m_eventDelegate.willTrigger( type );
    }

}
}

