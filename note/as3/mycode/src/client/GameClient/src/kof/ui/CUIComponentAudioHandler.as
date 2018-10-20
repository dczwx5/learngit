//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import QFLib.Foundation.CMap;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CAbstractHandler;
import kof.game.audio.IAudio;
import kof.util.CAssertUtils;

import morn.core.components.Component;

public class CUIComponentAudioHandler extends CAbstractHandler {

    private var m_pAudioFacade : IAudio;

    /**
     * Creates a new CUIComponentAudioHandler.
     */
    public function CUIComponentAudioHandler() {
        super();

        _processList = new CMap();
    }

    override public function dispose() : void {
        super.dispose();

        m_pAudioFacade = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            m_pAudioFacade = system.stage.getSystem( IAudio ) as IAudio;

            CAssertUtils.assertNotNull( m_pAudioFacade, "CUIComponentAudioHandler requires IAudio system working before." );
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        return super.onShutdown();
    }

    public function visitUIComponent( comp : Component ) : void {
        if ( !comp || !comp.tag )
            return;

        var keyList:Array;
        var bCurRegistered:Boolean;
        for ( var key : String in comp.tag ) {
            bCurRegistered = visitPropertyParsing( key );
            if (bCurRegistered) {
                if (!keyList) {
                    keyList = new Array();
                    keyList[keyList.length] = key;
                }
            }
        }
        if ( keyList && keyList.length > 0 ) {
            if (_processList.find(comp)) {

            } else {
                var process:ProcessTabHandler = new ProcessTabHandler();
                process.comp = comp;
                process.keyList = keyList;
                process.playAudioHandler = playAudio;
                process.process();

                _processList.add(comp, process);
            }
        }
    }
    private var _processList:CMap;

    protected function visitPropertyParsing( key : String ) : Boolean {
        var bRegistered : Boolean = true;
        switch ( key ) {
            case 'fadeInAudio':
            case 'fadeOutAudio':
                // TODO: More implemented.
            case 'runtime':
            case 'smoothing':
            case 'var':
            case 'align':
                // ignored built-in.
            default:
                /* CONFIG::debug { */
                /* Foundation.Log.logWarningMsg( "Unknown 'prop' in comp.tag declared: " + key + " => " + comp.tag[ key ] ); */
                /* } */
                bRegistered = false;
                break;
            case MouseEvent.CLICK + 'Audio':
            case MouseEvent.ROLL_OVER + "Audio":
            case MouseEvent.ROLL_OUT + "Audio":
            case Event.SELECT + "Audio":
            case "startAudio" :
                bRegistered = true;
                break;

        }

        return bRegistered;
    }


    protected function checkAudioFacade() : void {
        // delegate Audio-System to request the target.
        CAssertUtils.assertNotNull( m_pAudioFacade, "AudioSystem Facade required!" );
    }
    protected function playAudio( audioName : String ) : void {
        if ( !audioName )
            return;
        checkAudioFacade();
        m_pAudioFacade.playAudioByName( audioName, 1, 0.0, 1 );
    }
} // class CUIComponentAudioHandler
}

import QFLib.Utils.StringUtil;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.events.CEventPriority;

import morn.core.components.Component;

// package kof.ui
// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
class ProcessTabHandler {
    public function ProcessTabHandler() {

    }
    public var playAudioHandler:Function;
    public var comp:Component;
    public var keyList:Array;
    public function _comp_onAdded(e:Event) : void {
        for each (var key:String in keyList) {
            _listenEvent(key);
        }
        comp.removeEventListener( Event.ADDED_TO_STAGE, _comp_onAdded );

        comp.removeEventListener( Event.REMOVED_FROM_STAGE, _comp_onRemoved );
        comp.addEventListener( Event.REMOVED_FROM_STAGE, _comp_onRemoved, false, CEventPriority.DEFAULT, true );
    }
    private function _comp_onRemoved( event : Event ) : void {
        var comp : Component = event.currentTarget as Component;
        comp.removeEventListener( Event.REMOVED_FROM_STAGE, _comp_onRemoved );

        comp.removeEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler );
        comp.removeEventListener( MouseEvent.ROLL_OUT, _comp_onRollOutEventHandler );
        comp.removeEventListener( MouseEvent.ROLL_OVER, _comp_onRollOverEventHandler );
        comp.removeEventListener( Event.SELECT, _comp_onSelectEventHandler );
        // TODO: more event detached.

        comp.removeEventListener( Event.ADDED_TO_STAGE, _comp_onAdded );
        comp.addEventListener( Event.ADDED_TO_STAGE, _comp_onAdded, false, CEventPriority.DEFAULT, true );

    }
    public function process() : void {
        if (comp) {
            if (comp.stage) {
                _comp_onAdded(null);
            } else {
                comp.addEventListener( Event.ADDED_TO_STAGE, _comp_onAdded, false, CEventPriority.DEFAULT, true );
            }
        }
    }

    private function _listenEvent( key : String ) : void {
        switch ( key ) {
            case 'fadeInAudio':
            case 'fadeOutAudio':
            // TODO: More implemented.
            case 'runtime':
            case 'smoothing':
            case 'var':
            case 'align':
            // ignored built-in.
            default:
                break;
            case MouseEvent.CLICK + 'Audio': {
                comp.addEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler, false, CEventPriority.CURSOR_MANAGEMENT, true );
                break;
            }
            case MouseEvent.ROLL_OVER + "Audio": {
                comp.addEventListener( MouseEvent.ROLL_OVER, _comp_onRollOverEventHandler, false, CEventPriority.CURSOR_MANAGEMENT, true );
                break;
            }
            case MouseEvent.ROLL_OUT + "Audio": {
                comp.addEventListener( MouseEvent.ROLL_OUT, _comp_onRollOutEventHandler, false, CEventPriority.CURSOR_MANAGEMENT, true );
                break;
            }
            case Event.SELECT + "Audio": {
                comp.addEventListener( Event.SELECT, _comp_onSelectEventHandler, false, CEventPriority.CURSOR_MANAGEMENT, true );
                break;
            }
            case "startAudio" :
                playAudioHandler( getTagValue( comp, "startAudio" ) );
                break;
        }
    }

    private function _comp_onSelectEventHandler( event : Event ) : void {
        var comp : Component = event.currentTarget as Component;
        if ( !comp ) return;

        playAudioHandler( getTagValue( comp, Event.SELECT + "Audio" ) );
    }

    private function _comp_onRollOutEventHandler( event : MouseEvent ) : void {
        var comp : Component = event.currentTarget as Component;
        if ( !comp ) return;

        playAudioHandler( getTagValue( comp, MouseEvent.ROLL_OVER + "Audio" ) );
    }

    private function _comp_onRollOverEventHandler( event : MouseEvent ) : void {
        var comp : Component = event.currentTarget as Component;
        if ( !comp ) return;

        playAudioHandler( getTagValue( comp, MouseEvent.ROLL_OUT + "Audio" ) );
    }

    private function _comp_onMouseClickEventHandler( event : MouseEvent ) : void {
        var comp : Component = event.currentTarget as Component;
        if ( !comp ) return;

        playAudioHandler( getTagValue( comp, MouseEvent.CLICK + 'Audio' ) );
    }
    public function getTagValue( comp : Component, key : String ) : String {
        var tagValue : String = key in comp.tag ? comp.tag[ key ] : null;
        return tagValue ? StringUtil.trim( tagValue ) : null;
    }
}