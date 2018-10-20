//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/29.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base {

import QFLib.Foundation;
import QFLib.Interface.IDisposable;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.fight.sync.synctimeline.base.action.CBaseFighterKeyAction;
import kof.game.character.fight.sync.synctimeline.base.action.CFighterDodgeAction;

import kof.game.character.fight.sync.synctimeline.base.action.CFighterPositionAction;
import kof.game.character.fight.sync.synctimeline.base.action.CFighterSkillAction;
import kof.game.character.fight.sync.synctimeline.base.action.CFighterStatusAction;

import kof.game.character.fight.sync.synctimeline.base.action.EFighterActionType;

import kof.game.character.fight.sync.synctimeline.base.action.IFighterKeyAction;

import kof.game.core.CGameObject;
import kof.message.CAbstractPackMessage;

public class CCharacterFightData implements IDisposable{
    public function CCharacterFightData() {
        m_theFighterActions = new Vector.<IFighterKeyAction>( 10 );
    }

    public function dispose() : void{
        m_pOwner = null;
       for each( var action : IFighterKeyAction in m_theFighterActions )
       {
           action.clear();
           action = null;
       }
        m_theFighterActions.splice( 0 , m_theFighterActions.length );
        m_theFighterActions = null;

    }

    public function set owner( owner : CGameObject ) : void
    {
        m_pOwner = owner;
    }

    public function get owner() : CGameObject{
        return m_pOwner;
    }

    public function recordActionsToData( actionType : int , msg : CAbstractPackMessage ) : CBaseFighterKeyAction{
        var action : CBaseFighterKeyAction;
        action = EFighterActionType.CreateActionByTye( actionType );
        action.actionData = msg;
        _addActionToList( action );
        return action;
    }

    private function _addActionToList( action : IFighterKeyAction ) : Boolean
    {
        if( action == null )
                return false;

        if( m_nextActionIndex >= m_theFighterActions.length ) {
            Foundation.Log.logTraceMsg("the record action queue is full");
            return false;
        }

        m_theFighterActions[ m_nextActionIndex++ ] = action;
        return true;
    }

    public function get fighterActions() : Vector.<IFighterKeyAction>{
       return m_theFighterActions;
    }

    public function get fightNodeMsg() : String
    {
        var msg : String = "fightData:{";
        if( owner == null ){
            msg = "Node's owner is Null";
        }else{
            msg += "ID: " + CCharacterDataDescriptor.getID( owner.data );
            for each( var keyAction : IFighterKeyAction in m_theFighterActions ){
                if( !keyAction )
                    continue;
                msg += ",ActionType: " + keyAction.type +
                       ",ActionCategory: " + keyAction.actionCategory;
            }

        }

       return msg+"}";
    }

    private var m_pOwner : CGameObject;
    private var m_theFighterActions : Vector.<IFighterKeyAction>;
    private var m_nextActionIndex : int;
}
}
