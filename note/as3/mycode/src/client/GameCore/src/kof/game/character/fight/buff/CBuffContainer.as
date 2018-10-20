//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/27.
//----------------------------------------------------------------------
package kof.game.character.fight.buff {

import QFLib.Collision.common.IIterator;
import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.framework.IDatabase;
import kof.game.character.fight.IIterable;

import kof.game.character.fight.buff.buffentity.CAbstractBuff;
import kof.game.character.fight.buff.buffentity.CBuff;

import kof.game.character.fight.buff.buffentity.IBuff;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;

import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneHandler;

public class CBuffContainer extends CGameComponent implements IUpdatable , IBuffEffectContainer ,IIterable{
    public function CBuffContainer( scendHdl : CSceneHandler ) {
        super();
        m_pSceneHandler = scendHdl;
    }

    override public function dispose() : void
    {
        if( m_buffList )
            m_buffList.splice( 0 , m_buffList.length );

        m_buffList = null;
    }

    override protected function onEnter() : void
    {
        m_buffList = new Vector.<IBuff>();
        super.onEnter();
    }

    override protected function onExit() : void
    {
        super.onExit();
    }

    public function update( delta : Number ) : void
    {
        for each ( var buff : IBuff in m_buffList )
        {
            CAbstractBuff( buff ).update( delta );
        }
    }

    public function addBuffListFromSev( buffList : Array , buffSkillOwner : CGameObject = null ) : void
    {
        if( buffList == null ) return ;
        var newBuff : CBuff;
        for each( var buffData : Object in buffList )
        {
            if( hasBuff( buffData.buffId )) continue;
            newBuff = new CBuff( buffData.buffId , buffData.buffIndex , pDatabase , buffSkillOwner);
            addBuff( newBuff );
        }
    }

    /**
     * need sync to sev
     */
    public function addBuff( buff : IBuff ) : void{
        var boSussecd : Boolean;
        boSussecd = _addBuffInList( buff );
        if( !boSussecd ) return;
        if(_pBuffEffectComponent)
            _pBuffEffectComponent.addBuff( buff as CBuff );
    }

    /**
     * need sync to sev
     * @param buff
     */
    public function removeBuff( buff : IBuff ) : void{
        if(_pBuffEffectComponent)
            _pBuffEffectComponent.removeBuff( buff as CBuff );
        _removeBuffInList( buff );
    }

    public function triggerBuff( buff : IBuff ) : void{
        var theBuff : CBuff = buff as CBuff;
        if( theBuff )
        {
            theBuff.addToTriggerEffectQueue();
        }
    }

    public function removeBuffByID( id : int ) : void
    {
        var theBuff : IBuff = getBuff( id );
        if( !theBuff ){
            Foundation.Log.logMsg( " Server data error , removed Buff dose not exist which ID="  + id );
            return;
        }
       return  removeBuff( getBuff( id ) );
    }

    public function triggerBuffByID( id : int , buffIndex : int , randomseed : int ) : void
    {
        var buff : CAbstractBuff = getBuff( id ) as CAbstractBuff;
        buff.randomSeed = randomseed;
        return triggerBuff( buff );
    }

    public function getIterator() : IIterator{
        return new _BuffIterator( m_buffList );
    }

    public function getBuff( id : Number ) : IBuff
    {
        for each ( var buff : IBuff in m_buffList) {
            if( buff.id == id )
                    return buff;
        }
        return null;
    }

    public function addBuffGameObject( data : Object  ) : CGameObject
    {
        return m_pSceneHandler.addBuff( data );
    }

    public function removeBuffGameObject( id : int ) : void
    {
        m_pSceneHandler.removeBuff( id );
    }

    public function getBuffByGroud( nGroupID : int ) : Array
    {
        var buffsByGroup : Array = [];
        for each( var buff : IBuff in m_buffList )
        {
            if( buff.buffData.GroupID == nGroupID )
            {
                buffsByGroup.push( buff );
            }
        }

        return buffsByGroup;
    }

    public function hasBuff( id : Number ) : Boolean{
        for each( var buff : IBuff in m_buffList ){
            if( buff.id == id )
                    return true;
        }
        return false
    }

    public function hasBuffID( buffId : int ) : Boolean{
        for each( var buff : IBuff in m_buffList ){
            if( buff.buffId == buffId )
                    return true;
        }
        return false
    }

    private function _broadcastEvent( e : CFightTriggleEvent ) : void
    {
        if( _pFightTrigger )
        {
            _pFightTrigger.dispatchEvent( e );
        }
    }

    private function _removeBuffInList( buff : IBuff ) : Boolean{
        if( !buff )
                return false;
        var idx : int = m_buffList.indexOf( buff );
        if( idx != -1 )
        {
            m_buffList.splice( idx , 1 );
            if( buff is CAbstractBuff )
                    CAbstractBuff( buff ).setParent( null );
            return true;
        }else{
            CSkillDebugLog.logTraceMsg("the buff no exist in List , need not to remove");
        }
        return false;
    }

    private function _addBuffInList( buff : IBuff ) : Boolean {
        if( !buff )
            return false;
        var idx : int = m_buffList.indexOf( buff );
        if( idx == -1 && !hasBuff( buff.id ))
        {
            m_buffList.push( buff );
            if( buff is CAbstractBuff ) {
                CAbstractBuff( buff ).setParent( this );
            }
            return true;
        } else {
            CSkillDebugLog.logTraceMsg( "buff has exist in the list , can not add twice!" );
        }
        return false;
    }

    final private function get pDatabase() : IDatabase
    {
        return getComponent( IDatabase , true ) as IDatabase;
    }

    final private function get _pFightTrigger( ) : CCharacterFightTriggle
    {
        return getComponent( CCharacterFightTriggle , true  ) as CCharacterFightTriggle;
    }

    final private function get _pBuffEffectComponent() : CBuffEffectComponent
    {
        return getComponent( CBuffEffectComponent , true ) as CBuffEffectComponent ;
    }
    private var m_buffList : Vector.<IBuff>;
    private var m_pSceneHandler : CSceneHandler;
}
}

import QFLib.Collision.common.IIterator;

import kof.game.character.fight.buff.buffentity.IBuff;


class _BuffIterator implements IIterator{
    public function _BuffIterator( buffList : Vector.<IBuff> ){
        m_pbuffList = buffList;
    }

    public function hasNext() : Boolean
    {
        return m_pbuffList && m_nIndex < m_pbuffList.length ;
    }

    public function next() : Object{
        return m_pbuffList[m_nIndex++];
    }

    private var m_pbuffList : Vector.<IBuff>;
    private var m_nIndex : int = 0 ;
}
