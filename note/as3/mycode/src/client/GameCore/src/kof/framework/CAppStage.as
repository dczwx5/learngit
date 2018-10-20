//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import QFLib.Application.Component.CLifeCycleBeanEvent;
import QFLib.Application.Component.ILifeCycleListener;
import QFLib.Application.Component.createLifeCycleListener;
import QFLib.Foundation.CProcedureManager;
import QFLib.Interface.IUpdatable;

import com.adobe.flascc.vfs.IVFS;

import flash.display.Stage;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.utils.Dictionary;

import kof.util.CAssertUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAppStage extends CProcedureLifeCycle {

    private static var __INSTANCE_ID : int = 0;

    public function CAppStage( name : String = null, flashStage : Stage = null ) {
        super( new CProcedureManager( 0 ) );
        this._initialized = false;
        ++__INSTANCE_ID;
        name ? this.name = name : this.name = "AppStage_Unnamed" + __INSTANCE_ID;
        flashStage && this.initWithStage( flashStage );
        _systemRefs = new Dictionary( true );
    }

    private var _initialized : Boolean;
    private var _laterCalls : Dictionary;
    private var _uiTickCalls : Dictionary;
    private var _invalidated : Boolean;
    private var _configRef : IConfiguration;
    private var _vfsRef : IVFS;
    private var _systemRefs : Dictionary;
    private var _app : IApplication;
    private var _flashStage : Stage;

    private var _name : String;

    final public function get name() : String {
        return _name;
    }

    final public function set name( value : String ) : void {
        this._name = value;
    }

    final public function get flashStage() : Stage {
        return _flashStage;
    }

    final public function set flashStage( value : Stage ) : void {
        this._flashStage = value;
    }

    final public function get isInitialized() : Boolean {
        return _initialized;
    }

    final public function get vfs() : IVFS {
        return _vfsRef;
    }

    final public function get configuration() : IConfiguration {
        return _configRef;
    }

    final public function get timer() : IAppTimer {
        if ( _app )
            return _app.timer;
        return null;
    }

    override protected function doStart() : Boolean {
        var beanListener : ILifeCycleListener = createLifeCycleListener( _beanEventCallback, false );

        kof_framework::addBean( new CProcedureManager( flashStage ? flashStage.frameRate : 30 ) );
        kof_framework::addBean( beanListener );

        return super.doStart();
    }

    private function _beanEventCallback( event : CLifeCycleBeanEvent ) : void {
        if ( event.type == CLifeCycleBeanEvent.BEAN_ADDED ) {
            if ( event.child is CAppSystem ) {
                (event.child as CAppSystem).kof_framework::stage = this;
            }

            if ( event.child is IConfiguration ) {
                _configRef = event.child as IConfiguration;
            }

            if ( event.child is IVFS ) {
                _vfsRef = event.child as IVFS;
            }

            if ( event.child is IApplication ) {
                _app = event.child as IApplication;
            }
        } else if ( event.type == CLifeCycleBeanEvent.BEAN_REMOVED ) {
            if ( event.child is CAppSystem ) {
                (event.child as CAppSystem).kof_framework::stage = null;
            }

            if ( event.child is IConfiguration ) {
                _configRef = null;
            }

            if ( event.child is IVFS ) {
                _vfsRef = null;
            }

            if ( event.child is IApplication ) {
                _app = null;
            }
        }
    }

    override protected function setStarted() : void {
        super.setStarted();

        // FIXME(Jeremy): Replaced event dispatching with iterate-loop children notification.
        dispatchEvent( new CAppStageEvent( CAppStageEvent.ENTER, this ) );
    }

    override protected function setStopped() : void {
        super.setStopped();

        dispatchEvent( new CAppStageEvent( CAppStageEvent.EXIT, this ) );
    }

    [Deprecated]
    final override public function addBean( o : *, managed : int = AUTO ) : Boolean {
        throw new Error( "CAppStage hide the LifeCycle's bean behaviors." );
    }

    [Deprecated]
    final override public function updateBean( oldBean : *, newBean : *, managed : int = AUTO ) : void {
        throw new Error( "CAppStage hide the LifeCycle's bean behaviors." );
    }

    [Deprecated]
    final override public function removeBean( o : * ) : Boolean {
        throw new Error( "CAppStage hide the LifeCycle's bean behaviors." );
    }

    public function invalidate() : void {
        if ( _invalidated )
            return;

        this._invalidated = true;

        this.flashStage.addEventListener( Event.RENDER, flashStage_validationEventListener );
        this.flashStage.addEventListener( Event.ENTER_FRAME, flashStage_validationEventListener );
        this.flashStage.invalidate(); // 失效Flash NativeStage
    }

    public function execCallLater( func : Function ) : void {
        if ( _laterCalls[ func ] != null ) {
            var args : Array = _laterCalls[ func ];
            delete _laterCalls[ func ];
            func.apply( null, args );
        }
    }

    public function callLater( func : Function, args : Array = null ) : void {
        if ( _laterCalls[ func ] == null ) {
            _laterCalls[ func ] = args || [];
            invalidate();
        }
    }

    public function addUITick( func : Function ) : void {
        if (null == func)
            return;
        _uiTickCalls[ func ] = true;
    }

    public function removeUITick( func : Function ) : void {
        if ( null == func)
            return;
        if ( func in _uiTickCalls)
            delete _uiTickCalls[ func ];
    }

    public function initWithStage( flashStage : Stage, config : Object = null ) : void {
        if ( _initialized )
            return;
        this._initialized = true;

        if ( !flashStage )
            throw new Error( "Illegal flash stage." );

        this.flashStage = flashStage;

        if ( config ) {
            for ( var key : String in config ) {
                if ( flashStage.hasOwnProperty( key ) ) {
                    flashStage[ key ] = config[ key ];
                }
            }
        }

        this._laterCalls = new Dictionary(); // 不可用WeakReference
        this._uiTickCalls = new Dictionary(); // 不可用WeakReference
    }

    public function tickUpdate( delta : Number ) : void {
        // notify all system.

        if ( procedureManager ) {
            procedureManager.update( delta );
        }

        for ( var s : CAppSystem in _systemRefs ) {
            if ( s is IUpdatable && s.stage == this ) {
                (s as IUpdatable).update( delta );
            }
        }

        // tick ui call.
        if ( _uiTickCalls ) {
            for ( var pfn : Function in _uiTickCalls ) {
                if ( null != pfn ) {
                    pfn( delta );
                }
            }
        }
    }

    public function getSystem( clazz : Class ) : CAppSystem {
        return this.getBean( clazz ) as CAppSystem;
    }

    public function addSystem( system : CAppSystem, managed : Boolean = true ) : Boolean {
        var ret : Boolean = kof_framework::addBean( system, managed ? MANAGED : UNMANAGED );
        if ( ret ) {
            // added to refs cache.
            _systemRefs[ system ] = true;

//            if ( this.isStarted ) {
//                // TODO(Jeremy): notify the system is already entered stage.
//            }
            CAssertUtils.assertFalse( this.isStarted, "The stage adding system in STARTED phase." );
        }

        return ret;
    }

    public function removeSystem( system : CAppSystem ) : Boolean {
        var ret : Boolean = kof_framework::removeBean( system );
        if ( ret ) {
            delete _systemRefs[ system ];
        }
        return ret;
    }

    private function flashStage_validationEventListener( event : Event ) : void {
        this.flashStage.removeEventListener( Event.RENDER, flashStage_validationEventListener );
        this.flashStage.removeEventListener( Event.ENTER_FRAME, flashStage_validationEventListener );

        _invalidated = false;

        // exec all later calls.
        for ( var laterCall : Object in _laterCalls ) {
            execCallLater( laterCall as Function );
        }
    }

    final kof_framework function addBean( o : *, managed : int = AUTO ) : Boolean {
        return super.addBean( o, managed );
    }

    final kof_framework function removeBean( o : * ) : Boolean {
        return super.removeBean( o );
    }

}
}
