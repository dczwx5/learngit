//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.movement {

import QFLib.Interface.IUpdatable;

import flash.geom.Point;

import kof.game.core.CGameComponent;

/**
 * 导航，给定目标点移动，给定路径分成若干目标点步进
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CNavigation extends CGameComponent implements IUpdatable {

    private var m_pListeners : Vector.<INavigationListener>;

    private var m_pPathList : Vector.<Point>;
    private var m_bPathListDirty : Boolean;

    internal var m_fCurrentDistance : Number;

    /** Creates a CNavigation */
    public function CNavigation() {
        super( "navigation" );
    }

    override public function dispose() : void {
        super.dispose();

        m_pListeners = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        if ( !m_pListeners )
            m_pListeners = new <INavigationListener>[];

        m_pListeners.splice( 0, m_pListeners.length );
    }

    override protected virtual function onExit() : void {
        super.onExit();

        m_pListeners.splice( 0, m_pListeners.length );
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    final public function get currentDistance() : Number {
        return m_fCurrentDistance;
    }

    final public function get targetPoint() : Point {
        return m_pPathList && m_pPathList.length ? m_pPathList[0] : null;
    }

    final public function get nextPoint() : Point {
        return m_pPathList && m_pPathList.length > 1 ? m_pPathList[1] : null;
    }

    final public function get isPathListDirty() : Boolean {
        return m_bPathListDirty;
    }

    public function advancedNext() : void {
        if ( !m_pPathList || !m_pPathList.length )
            return;
        m_pPathList.shift();
    }

    /**
     * 3D地表坐标路径
     */
    final public function get pathList() : Vector.<Point> {
        return m_pPathList;
    }

    /** @private */
    final public function set pathList( value : Vector.<Point> ) : void {
        if ( m_pPathList == value )
            return;

        if ( m_pPathList && m_pPathList.length && !value )
            m_pPathList.splice( 0, m_pPathList.length );

        m_pPathList = value;
        m_bPathListDirty = true;
    }

    final public function setPathListWithArray( value : Array ) : void {
        if ( !value )
            return;

        var pTempPath : Vector.<Point> = new <Point>[];

        for each ( var p : Object in value ) {
            if ( !p )
                continue;
            pTempPath.push( new Point (p.x, p.y ));
        }

        this.pathList = pTempPath;
    }

    public function clearDirty() : void {
        this.m_bPathListDirty = false;
    }

    public function clearPath( bNotifyAll : Boolean = false ) : void {
        this.pathList = null;

        this.m_fCurrentDistance = NaN;

        if ( bNotifyAll ) {
            this.notifyEnd();
        }
    }

    public function newListener() : INavigationListener {
        return new CDefaultListener( this );
    }

    public function deleteListener( pListener : INavigationListener ) : void {
        if ( !pListener )
            return;
        this.removeListener( pListener );
    }

    public function addListener( pListener : INavigationListener ) : void {
        if ( !pListener )
            return;
        var idx : int = m_pListeners.indexOf( pListener );
        if ( -1 == idx )
            m_pListeners.push( pListener );
    }

    public function removeListener( pListener : INavigationListener ) : void {
        if ( !pListener )
            return;
        var idx : int = m_pListeners.indexOf( pListener );
        if ( -1 != idx )
            m_pListeners.splice( idx, 1 );
    }

    internal function notifyBegin() : void {
        if ( !m_pListeners || !m_pListeners.length )
            return;

        for each ( var l : INavigationListener in m_pListeners ) {
            l.dispatchEvent( new CNavigationEvent( CNavigationEvent.EVENT_BEGIN, null ) );
        }
    }

    internal function notifyCheckPoint() : void {
        if ( !m_pListeners || !m_pListeners.length )
            return;

        for each ( var l : INavigationListener in m_pListeners ) {
            l.dispatchEvent( new CNavigationEvent( CNavigationEvent.EVENT_CHECKPOINT,
                    new Point( targetPoint.x, targetPoint.y ) ) );
        }
    }

    internal function notifyEnd() : void {
        if ( !m_pListeners || !m_pListeners.length )
            return;

        for each ( var l : INavigationListener in m_pListeners ) {
            l.dispatchEvent( new CNavigationEvent( CNavigationEvent.EVENT_END, null ) );
        }
    }

    /**
     * @inheritDoc
     */
    public function update( delta : Number ) : void {

    }

}
}

import QFLib.Interface.IDisposable;
import QFLib.Memory.CSmartObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import kof.game.character.movement.CNavigation;
import kof.game.character.movement.INavigationListener;

CONFIG::debug {
//noinspection JSDuplicatedDeclaration
    class CDefaultListener extends CSmartObject implements INavigationListener, IDisposable {

        private var m_pDelegate : IEventDispatcher;
        private var m_pContainer : CNavigation;

        public function CDefaultListener( pContainer : CNavigation ) {
            super();

            this.m_pDelegate = new EventDispatcher();
            this.m_pContainer = pContainer;
        }

        override public function dispose() : void {
            super.dispose();
            m_pContainer.removeListener( this );

            m_pDelegate = null;
            m_pContainer = null;
        }

        public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false ) : void {
            m_pDelegate.addEventListener( type, listener, useCapture, priority, useWeakReference );
        }

        public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void {
            m_pDelegate.removeEventListener( type, listener, useCapture );
        }

        public function dispatchEvent( event : Event ) : Boolean {
            return m_pDelegate.dispatchEvent( event );
        }

        public function hasEventListener( type : String ) : Boolean {
            return m_pDelegate.hasEventListener( type );
        }

        public function willTrigger( type : String ) : Boolean {
            return m_pDelegate.willTrigger( type );
        }
    }
}

CONFIG::release {
//noinspection JSDuplicatedDeclaration
    class CDefaultListener extends EventDispatcher implements INavigationListener, IDisposable {

        private var m_pContainer : CNavigation;

        public function CDefaultListener( pContainer : CNavigation ) {
            super();

            this.m_pContainer = pContainer;
        }

        public function dispose() : void {
            // NOOP.
            m_pContainer.removeListener( this );
            m_pContainer = null;
        }

    }
}

// vim:ft=as3 ts=4 sw=4 et tw=0

