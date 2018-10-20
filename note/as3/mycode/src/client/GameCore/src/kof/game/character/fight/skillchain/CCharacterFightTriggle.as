//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/14.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

import flash.events.Event;
import flash.events.IEventDispatcher;

import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.core.CGameComponent;

/**
*战斗相关事件组件
 */
public class CCharacterFightTriggle extends CGameComponent implements IEventDispatcher{

    public function CCharacterFightTriggle( name : String = null ) {
        super( "fight" );
        m_fightTriggle = new CFightingTriggle();
    }

    override public function dispose() : void {
        m_fightTriggle = null;
        super.dispose();
    }

    override protected function onEnter() : void
    {
        super.onEnter();
    }

    override protected function onExit() : void
    {
        m_fightTriggle.dispose();
        super.onExit();
    }

    public function dispatchEvent( event : Event ) : Boolean
    {
        var fightEvent : CFightTriggleEvent = event as CFightTriggleEvent;
        return m_fightTriggle.dispatchEvent( fightEvent );
    }

    public function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int = 0,useWeakReference:Boolean = false):void
    {
        if( m_fightTriggle != null )
            m_fightTriggle.addEventListener( type ,listener,false,priority,false );
    }
    public function removeEventListener(type:String,listener:Function,useCapture:Boolean = false):void
    {
        if( m_fightTriggle != null )
            m_fightTriggle.removeEventListener( type , listener,false );
    }

    public function hasEventListener(type:String):Boolean
    {
        return m_fightTriggle.hasEventListener( type );
    }

    public function willTrigger(type:String):Boolean
    {
        return m_fightTriggle.willTrigger( type );
    }

    final public function get fightTriggle() : CFightingTriggle
    {
        return m_fightTriggle;
    }

    private var m_fightTriggle : CFightingTriggle;
}
}
