//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

import QFLib.Interface.IUpdatable;

import kof.framework.CAppSystem;

/**
 * A game handling system.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CECSLoop extends CAppSystem implements IUpdatable {

    /** @private */
    private var m_pPipeline : CGameSystemPipeline;
    /** @private */
    private var m_bInitialized : Boolean;
    /** @private */
    private var m_listObjects : CEntityLinkList;

    /**
     * Creates a new CECSLoop.
     */
    public function CECSLoop() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pPipeline )
            m_pPipeline.dispose();
        m_pPipeline = null;
    }

    override protected function onSetup() : Boolean {
        if ( !m_bInitialized ) {
            m_bInitialized = true;
            m_pPipeline = new CGameSystemPipeline( this );
            m_listObjects = new CEntityLinkList();
        }

        return m_bInitialized;
    }

    override protected function onShutdown() : Boolean {
        if ( m_pPipeline )
            m_pPipeline.dispose();

        if ( m_listObjects )
            m_listObjects.dispose();

        m_pPipeline = null;
        m_listObjects = null;

        return true;
    }

    public function addHandler( handler : IGameSystemHandler ) : void {
        m_pPipeline.add( handler );
    }

    public function removeHandler( handler : IGameSystemHandler ) : void {
        m_pPipeline.remove( handler );
    }

    public function removeAllHandler() : void {
        var handlers : Vector.<IGameSystemHandler> = m_pPipeline.handlers.slice();
        for each ( var handler : IGameSystemHandler in handlers ) {
            if ( handler )
                m_pPipeline.remove( handler );
        }
    }

    public function addObject( obj : CGameObject ) : void {
        if ( !obj )
            return;
        m_listObjects.push( obj );

        obj.onAdded();
    }

    public function removeObject( obj : CGameObject ) : void {
        if ( !obj )
            return;
        const entry : CEntityLinkListEntry = m_listObjects.find( obj );
        if ( entry )
            entry.remove();

        m_listObjects.m_nSize--;

        obj.onRemoved();
    }

    public function update( delta : Number ) : void {
        if ( !m_bInitialized )
            return;

        // before tick phase.

        m_pPipeline.beforeTick( delta );

        var current : CEntityLinkListEntry = this.m_listObjects.head;
        var curGameObj : CGameObject;

        for ( ; current != this.m_listObjects.tail; ) {
            // Update transform first.
            curGameObj = current.obj as CGameObject;
            if ( curGameObj ) {
                curGameObj.updateData();

                m_pPipeline.tickUpdate( delta, current.obj as CGameObject );
            }

            current = current.next;
        }

        // after tick phase.
        m_pPipeline.afterTick( delta );
    }

}
}

import QFLib.Interface.IDisposable;

import flash.utils.Dictionary;

import kof.game.core.CGameObject;
import kof.game.core.CECSLoop;
import kof.game.core.IGameSystemHandler;
import kof.game.core.IPipeline;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class CGameSystemPipeline implements IPipeline, IDisposable {

    /** @private */
    private var m_pGameSystem : CECSLoop;
    /** @private */
    private var m_listHandlers : Vector.<IGameSystemHandler>;
    /** @private temp local vector */
    private var m_listUpdatedHandlers : Vector.<IGameSystemHandler>;

    /**
     * Creates a new CGameSystemPipeline.
     */
    function CGameSystemPipeline( gameSystem : CECSLoop ) {
        super();
        this.m_pGameSystem = gameSystem;
        this.m_listHandlers = new <IGameSystemHandler>[];
        this.m_listUpdatedHandlers = new <IGameSystemHandler>[];
    }

    [Inline]
    final public function get handlers() : Vector.<IGameSystemHandler> {
        return m_listHandlers.slice();
    }

    [Inline]
    final public function add( handler : IGameSystemHandler ) : void {
        m_listHandlers.push( handler );
    }

    [Inline]
    final public function remove( handler : IGameSystemHandler ) : void {
        const index : int = m_listHandlers.indexOf( handler );
        if ( index != -1 ) {
            m_listHandlers.splice( index, 1 );
        }
    }

    [Inline]
    final public function dispose() : void {
        this.m_pGameSystem = null;
    }

    public function tickUpdate( delta : Number, obj : CGameObject ) : void {
        if ( !obj )
            return;

        const listUpdated : Vector.<IGameSystemHandler> = this.m_listUpdatedHandlers;

        if ( m_listHandlers.length > m_listUpdatedHandlers.length )
            m_listUpdatedHandlers.length = m_listHandlers.length;

        var handler : IGameSystemHandler;
        var idxPush : int = 0;

        for each ( handler in m_listHandlers ) {
            if ( handler && handler.isComponentSupported( obj ) ) {
                if ( handler.tickValidate( delta, obj ) ) {
                    listUpdated[idxPush++] = handler;
//                    listUpdated.push( handler );
                }
            }
        }

        if ( obj.isRunning ) {
            for ( var i : int = 0; i < idxPush; ++i ) {
                listUpdated[ i ].tickUpdate( delta, obj );
            }
        }

//        for each ( handler in listUpdated ) {
//            if ( obj.isRunning )
//                handler.tickUpdate( delta, obj );
//        }
//
//        // listUpdated.splice( 0, listUpdated.length ); // clear all.
//        listUpdated.length = 0;
    }

    final public function beforeTick( delta : Number ) : void {
        var handler : IGameSystemHandler;
        for each ( handler in m_listHandlers ) {
            handler.beforeTick( delta );
        }
    }

    final public function afterTick( delta : Number ) : void {
        var handler : IGameSystemHandler;
        for each ( handler in m_listHandlers ) {
            handler.afterTick( delta );
        }
    }
}

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class CEntityLinkList implements IDisposable {

    public var head : CEntityLinkListEntry;
    public var tail : CEntityLinkListEntry;

    /** @private */
    private var m_pCurEntry : CEntityLinkListEntry;
    /** @private */
    public var m_nSize : uint;
    /** @private */
    private var m_mapObjToEntry : Dictionary;

    function CEntityLinkList() {
        super();

        head = new CEntityLinkListEntry();
        tail = new CEntityLinkListEntry();

        head.next = tail;
        tail.prev = head;

        m_pCurEntry = head;
        m_mapObjToEntry = new Dictionary( true ); // Weak reference.
    }

    [Inline]
    final public function get size() : uint {
        return m_nSize;
    }

    [Inline]
    final public function push( obj : CGameObject ) : void {
        const prev : CEntityLinkListEntry = tail.prev;
        const current : CEntityLinkListEntry = new CEntityLinkListEntry( obj );
        current.next = tail;
        current.prev = prev;

        prev.next = current;
        tail.prev = current;

        m_mapObjToEntry[ obj ] = current;
        m_nSize++;
    }

    [Inline]
    public final function find( obj : CGameObject ) : CEntityLinkListEntry {
        if ( obj in m_mapObjToEntry ) {
            return m_mapObjToEntry[ obj ];
        }
        return null;
    }

    public function dispose() : void {
        head.next = null;
        head.prev = null;
        head = null;

        tail.next = null;
        tail.prev = null;
        tail = null;

        m_pCurEntry.next = null;
        m_pCurEntry.prev = null;
        m_pCurEntry = null;

        m_mapObjToEntry = null;
    }
}

class CEntityLinkListEntry {

    public var prev : CEntityLinkListEntry;
    public var next : CEntityLinkListEntry;

    public var obj : *;

    function CEntityLinkListEntry( obj : * = null ) {
        this.obj = obj;
    }

    [Inline]
    final public function remove() : void {
        if ( next ) {
            next.prev = prev;
        }

        if ( prev ) {
            prev.next = next;
        }

        obj = null;
    }

}
