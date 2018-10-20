//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import flash.events.Event;
import flash.events.IEventDispatcher;

import kof.game.core.CGameComponent;

[Event(name="character_startMove", type="flash.events.Event")]
[Event(name="character_stopMove", type="flash.events.Event")]
[Event(name="character_directionChanged", type="flash.events.Event")]
[Event(name="character_animationTimeEnd", type="flash.events.Event")]
[Event(name="character_property_update", type="flash.events.Event")]
[Event(name="character_target_changed", type="flash.events.Event")]
[Event(name="character_ready", type="flash.events.Event")]
[Event(name="character_removed", type="flash.events.Event")]
[Event(name="character_dodge_begin", type="flash.events.Event")]
[Event(name="character_dodge_failed", type="flash.events.Event")]
[Event(name="character_dodge_end", type="flash.events.Event")]
[Event(name="character_block_in_scene", type="flash.events.Event")]
[Event(name="character_instance_statted", type="flash.events.Event")]
/**
 * 角色ECS组件：事件调配
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CEventMediator extends CGameComponent implements IEventDispatcher {

    /** @private */
    private var m_pEventDispatcher : IEventDispatcher;

    public function CEventMediator( eventDispatcher : IEventDispatcher = null ) {
        super( "events" );

        m_pEventDispatcher = eventDispatcher;
    }

    override public function dispose() : void {
        super.dispose();
        m_pEventDispatcher = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
        if ( !m_pEventDispatcher ) {
            m_pEventDispatcher = this.owner as IEventDispatcher;
        }
    }

    override protected virtual function onExit() : void {
        super.onExit();
        this.dispatchEvent( new Event( CCharacterEvent.REMOVED, false, false ) );
    }

    final public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false ) : void {
        m_pEventDispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
    }

    final public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void {
        m_pEventDispatcher.removeEventListener( type, listener, useCapture );
    }

    [Inline]
    final public function dispatchEvent( event : Event ) : Boolean {
        return m_pEventDispatcher.dispatchEvent( event );
    }

    [Inline]
    final public function hasEventListener( type : String ) : Boolean {
        return m_pEventDispatcher.hasEventListener( type );
    }

    [Inline]
    final public function willTrigger( type : String ) : Boolean {
        return m_pEventDispatcher.willTrigger( type );
    }
}
}
