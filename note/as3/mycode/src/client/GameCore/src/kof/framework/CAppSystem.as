//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import QFLib.Application.Component.CContainerLifeCycle;
import QFLib.Application.Component.CLifeCycleBeanEvent;
import QFLib.Application.Component.createLifeCycleListener;
import QFLib.Foundation.CProcedureManager;
import QFLib.Interface.IDisposable;

import kof.ui.IUICanvas;

/**
 * System Facade.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAppSystem extends CProcedureLifeCycle implements IDisposable {

    public function CAppSystem() {
        super();
    }

    private var _stage : CAppStage;
    private var _handler : CSystemHandler;
    private var _handlers : Vector.<CAbstractHandler>;
    private var _enabled : Boolean;

    public function get stage() : CAppStage {
        return _stage;
    }

    kof_framework function set stage( value : CAppStage ) : void {
        if ( this._stage != value ) {
            if ( this._stage ) {
                this._stage.removeEventListener( CAppStageEvent.ENTER, kof_framework::_onStageEnter );
                this._stage.removeEventListener( CAppStageEvent.EXIT, kof_framework::_onStageExit );
            }

            this._stage = value;
            if ( value )
                this.procedureManager = value.getBean( CProcedureManager ) as CProcedureManager;
        }
    }

    /**
     * A default system handler ref
     */
    public function get handler() : CSystemHandler {
        return _handler;
    }

    kof_framework function set handler( value : CSystemHandler ) : void {
        this._handler = value;
    }

    /**
     * Retrieves a handler iterated in this CAppSystem.
     *
     * @param clazz The class specify by the handler.
     * @return A handler specify by a sub handler class.
     */
    public function getHandler( clazz : Class ) : CAbstractHandler {
        for each ( var h : CAbstractHandler in this._handlers ) {
            if ( h is clazz )
                return h;
        }
        return null;
    }

    /**
     * Acts as a iterator for all handler.
     */
    public function get handlerIterator() : Object {
        return this._handlers;
    }

    override virtual protected function getLogExt( iLogLevel : int ) : String {
        if ( stage )
            return stage.timer.frameCounter.toString() + "  ";
        return null;
    }

    override protected function doStart() : Boolean {
        const pStage : CAppStage = this.stage;
        if ( !pStage ) {
            throw "Null stage in CAppSystem.";
        }

        this.addBean( new CProcedureManager( pStage.flashStage ? pStage.flashStage.frameRate : 30 ) );
        this.addBean( createLifeCycleListener( _systemHandlerSetter, true ) );

        if ( pStage )
            pStage.addEventListener( CAppStageEvent.ENTER, kof_framework::_onStageEnter, false, 0, true );

        _handlers = new <CAbstractHandler>[];

        var ret : Boolean = super.doStart();

        ret && (ret = this.onSetup());

        return ret;
    }

    override protected function setStarted() : void {
        super.setStarted();

        const pStage : CAppStage = this.stage;
        if ( !pStage ) {
            throw "Null stage in CAppSystem.";
        }

        // notify system entered.
        if ( _handlers && _handlers.length ) {
            for each( var h : CAbstractHandler in _handlers ) {
                if ( h ) {
                    h.kof_framework::onSystemEnter( this );
                }
            }
        }

        if ( pStage && pStage.isStarted ) {
            kof_framework::_onStageEnter( null );
        }
    }

    final private function _systemHandlerSetter( event : CLifeCycleBeanEvent ) : void {
        if ( event.type == CLifeCycleBeanEvent.BEAN_ADDED ) {
            if ( event.child is CSystemHandler ) {
                kof_framework::handler = event.child as CSystemHandler;

                (event.child as CSystemHandler).kof_framework::networking = _stage.getSystem( INetworking ) as INetworking;

            } else if ( event.child is CViewHandler ) {
                (event.child as CViewHandler).kof_framework::uiCanvas = _stage.getSystem( IUICanvas ) as IUICanvas;
                (event.child as CViewHandler).kof_framework::_pfnLaterCall = stage.callLater;
                (event.child as CViewHandler).kof_framework::_pfnUITickRegister = stage.addUITick;
                (event.child as CViewHandler).kof_framework::_pfnUITickUnregister = stage.removeUITick;
            }

            if ( event.child is CAbstractHandler ) {
                var pCurSystem : CAppSystem;
                if ( event.parent is CAppSystem ) {
                    pCurSystem = event.parent as CAppSystem;
                } else if ( event.parent is CAbstractHandler ) {
                    pCurSystem = CAbstractHandler( event.parent ).system;
                }

                (event.child as CAbstractHandler).kof_framework::system = pCurSystem;
                _handlers.push( event.child );

                if ( event.child is CProcedureLifeCycle ) {
                    var pSubPM : CProcedureManager = CContainerLifeCycle( event.parent ).getBean( CProcedureManager ) as CProcedureManager;
                    if ( !pSubPM && event.parent is CAbstractHandler ) {
                        pSubPM = new CProcedureManager( stage.flashStage.frameRate );
                        CContainerLifeCycle( event.parent ).addBean( pSubPM );
                    }

                    CProcedureLifeCycle( event.child ).procedureManager = pSubPM;
                }
            }

        } else if ( event.type == CLifeCycleBeanEvent.BEAN_REMOVED ) {
            var index : int = _handlers.indexOf( event.child );
            if ( index != -1 ) {
                (_handlers[ index ] as CAbstractHandler).kof_framework::system = null;
                _handlers.splice( index, 1 );
            }
        }
    }

    protected virtual function onSetup() : Boolean {
        // NOOP
        return true;
    }

    override protected function doStop() : Boolean {
        var ret : Boolean = super.doStop();

        ret && (ret = this.onShutdown());

        if ( this._stage )
            this._stage.removeEventListener( CAppStageEvent.EXIT, kof_framework::_onStageExit );

        return ret;
    }

    override protected function setStopped() : void {
        super.setStopped();

        // notify system entered.
        if ( _handlers && _handlers.length ) {
            for each( var h : CAbstractHandler in _handlers ) {
                if ( h ) {
                    h.kof_framework::onSystemExit( this );
                }
            }
        }
    }

    protected virtual function onShutdown() : Boolean {
        // NOOP.
        return true;
    }

    kof_framework function _onStageEnter( event : CAppStageEvent ) : void {
        this._stage.removeEventListener( CAppStageEvent.ENTER, kof_framework::_onStageEnter );
        this._stage.addEventListener( CAppStageEvent.EXIT, kof_framework::_onStageExit, false, 0, true );

        this.enterStage( event ? event.appStage : this._stage );

        // notify the handlers.
        if ( _handlers && _handlers.length ) {
            for each( var h : CAbstractHandler in _handlers ) {
                if ( h ) {
                    h.kof_framework::onStageEnter( event ? event.appStage : this._stage );
                }
            }
        }
    }

    protected function enterStage( appStage : CAppStage ) : void {
        // NOOP
    }

    kof_framework function _onStageExit( event : CAppStageEvent ) : void {
        this._stage.removeEventListener( CAppStageEvent.EXIT, kof_framework::_onStageExit );

        // notify the handlers.
        if ( _handlers && _handlers.length ) {
            for each( var h : CAbstractHandler in _handlers ) {
                if ( h ) {
                    h.kof_framework::onStageExit( event ? event.appStage : this._stage );
                }
            }
        }

        this.exitStage( event.appStage );
    }

    protected function exitStage( appStage : CAppStage ) : void {
        // NOOP
    }

    override public function dispose() : void {
        super.dispose();

        this.kof_framework::stage = null;
        _handler = null;

        if ( _handlers ) {
            _handlers.splice( 0, _handlers.length );
            _handlers = null;
        }
    }

    public function get enabled() : Boolean {
        return _enabled;
    }

    public function set enabled( value : Boolean ) : void {
        if ( _enabled == value )
            return;
        _enabled = value;
        setEnabled( value );
    }

    virtual protected function setEnabled( value : Boolean ) : void {
        // NOOP.
    }

}

}
