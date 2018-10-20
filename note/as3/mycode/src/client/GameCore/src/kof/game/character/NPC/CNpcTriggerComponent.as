//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/7/3.
 */
package kof.game.character.NPC {

import flash.events.Event;
import flash.events.IEventDispatcher;

import kof.game.core.CGameComponent;

public class CNpcTriggerComponent extends CGameComponent implements IEventDispatcher {
        public function CNpcTriggerComponent( name : String = null ) {
            super( "npc" );
            m_npcTrigger = new CNpcTrigger();
        }

        override public function dispose() : void {
            m_npcTrigger = null;
            super.dispose();
        }

        override protected function onEnter() : void
        {
            super.onEnter();
        }

        override protected function onExit() : void
        {
            m_npcTrigger.dispose();
            super.onExit();
        }

        public function dispatchEvent( event : Event ) : Boolean
        {
            var npcEvent : CNPCEvent = event as CNPCEvent;
            return m_npcTrigger.dispatchEvent( npcEvent );
        }

        public function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int = 0,useWeakReference:Boolean = false):void
        {
            m_npcTrigger.addEventListener( type ,listener,false,0,false );
        }
        public function removeEventListener(type:String,listener:Function,useCapture:Boolean = false):void
        {
            m_npcTrigger.removeEventListener( type , listener,false );
        }

        public function hasEventListener(type:String):Boolean
        {
            return m_npcTrigger.hasEventListener( type );
        }

        public function willTrigger(type:String):Boolean
        {
            return m_npcTrigger.willTrigger( type );
        }

        final public function get npcTrigger() : CNpcTrigger
        {
            return m_npcTrigger;
        }

        private var m_npcTrigger : CNpcTrigger;
    }
}
