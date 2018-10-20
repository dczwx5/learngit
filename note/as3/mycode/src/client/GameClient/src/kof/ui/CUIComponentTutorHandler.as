//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import QFLib.Foundation.CWeakRef;

import flash.events.Event;
import flash.utils.Dictionary;

import kof.framework.CAbstractHandler;
import kof.framework.events.CEventPriority;
import kof.util.CAssertUtils;

import morn.core.components.Component;

[Event(name="compRegistered", type="flash.events.Event")]
[Event(name="compUnRegistered", type="flash.events.Event")]
/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CUIComponentTutorHandler extends CAbstractHandler {

    public static const EVENT_COMP_REGISTERED : String = "compRegistered";
    public static const EVENT_COMP_UNREGISTERED : String = "compUnRegistered";

    public static const TAG_KEY : String = "tutorCompID";

    private var _compList : Dictionary;

    public function CUIComponentTutorHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        _compList = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            _compList = new Dictionary();
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        return ret;
    }

    public function visitUIComponent( comp : Component ) : void {
        if ( !comp || !comp.tag ) {
            return;
        }

        if ( comp.tag.hasOwnProperty( TAG_KEY ) ) {
            comp.addEventListener( Event.ADDED_TO_STAGE, _comp_onAddedToStageEventHandler, false,
                    CEventPriority.BINDING, true );
        }
    }

    /**
     * Tells whether the specifiy <code>tutorCompID</code> ref component is registered.
     *
     * return True if the specifiy <code>tutorCompID</code> ref component is registered, false otherwise.
     */
    public function isCompRegistered( tutorCompID : String ) : Boolean {
        if ( !tutorCompID )
            return false;
        if ( tutorCompID in _compList ) {
            return Boolean( CWeakRef( _compList[ tutorCompID ] ).ptr );
        }
        return false;
    }

    public function getCompByTutorID( tutorCompID : String ) : Component {
        if (!tutorCompID)
            return null;
        if ( tutorCompID in _compList ) {
            return CWeakRef( _compList[ tutorCompID ]).ptr as Component;
        }
        return null;
    }

    private function _comp_onAddedToStageEventHandler( event : Event ) : void {
        var comp : Component = event.currentTarget as Component;
        comp.removeEventListener( Event.ADDED_TO_STAGE, _comp_onAddedToStageEventHandler );
        var tutorCompID : String = comp.tag[ TAG_KEY ];
        CAssertUtils.assertTrue( tutorCompID );
        if ( !(tutorCompID in _compList )) {
            _compList[ tutorCompID ] = new CWeakRef( comp ); // 弱引用包装该组件，避免内存问题
            comp.addEventListener( Event.REMOVED_FROM_STAGE, _comp_onRemovedFromStageEventHandler, false,
                    CEventPriority.BINDING, true );
            var evt : Event = new Event( EVENT_COMP_REGISTERED );
            dispatchEvent( evt );
        }
    }

    private function _comp_onRemovedFromStageEventHandler( event : Event ) : void {
        var comp : Component = event.currentTarget as Component;
        comp.removeEventListener( Event.REMOVED_FROM_STAGE, _comp_onRemovedFromStageEventHandler );
        comp.addEventListener( Event.ADDED_TO_STAGE, _comp_onAddedToStageEventHandler, false, CEventPriority.BINDING, true );

        var tutorCompID : String = comp.tag[ TAG_KEY ];
        CAssertUtils.assertTrue( tutorCompID );
        delete _compList[ tutorCompID ];

        var evt : Event = new Event( EVENT_COMP_UNREGISTERED );
        dispatchEvent( evt );
    }

}
}

// vim:ft=as3 tw=120 sw=4 ts=4 expandtab
