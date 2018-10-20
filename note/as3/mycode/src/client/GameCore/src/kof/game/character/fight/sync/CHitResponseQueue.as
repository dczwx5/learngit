//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/5.
//----------------------------------------------------------------------
package kof.game.character.fight.sync {

import QFLib.Graphics.RenderCore.render.pass.PAdvColorModify;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;

import kof.game.character.CKOFTransform;
import kof.game.character.fight.sync.CSyncHitTargetEntity;

import kof.game.core.CGameComponent;

import kof.message.CAbstractPackMessage;
import kof.message.Fight.HitResponse;

public class CHitResponseQueue implements IDisposable,IUpdatable{

    public function CHitResponseQueue() {
        m_msgList = new Vector.<HitResponse>();
    }

    public function dispose() : void
    {
        if( m_msgList )
        {
            m_msgList.splice( 0 , m_msgList.length );
        }

        m_msgList = null;
    }

    public function update( delta : Number ) : void
    {
        if( dirty ){
            var lastMsg : HitResponse;
            var msgList : Vector.<HitResponse> = m_msgList.splice( 0 , m_msgList.length );
            for( var i : int = 0; i< msgList.length ; i++ ) {
                lastMsg = msgList[i];
                if ( lastMsg ) {
                    _syncHitResponse( lastMsg );
                }
            }

            dirty = false;
        }

    }

    private function _syncHitResponse( lastMsg : HitResponse ) : void
    {

    }

    public function pushIncomeMsg( msg : HitResponse ) : void
    {
        if( msg != null)
        {
            m_msgList.push( msg );
            m_dirty = true;
        }
    }

    final public function get dirty() : Boolean
    {
        return m_dirty;
    }

    final public function set dirty( value : Boolean ) : void
    {
         m_dirty = value;
    }

    public var m_msgList : Vector.<HitResponse>;
    public var m_dirty : Boolean;
}
}
