//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/17.
//----------------------------------------------------------------------
package QFLib.Framework.Util {

import QFLib.Foundation;
import QFLib.Framework.*;

import QFLib.Collision.CCollisionManager;
import QFLib.Framework.CharacterExtData.CCharacterCollisionBoundInfo;
import QFLib.Framework.CharacterExtData.CCharacterCollisionKey;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector3;

public class CCollisionTimeLine implements IUpdatable , IDisposable{

    public function CCollisionTimeLine( collisionSystem : CCollisionManager, pCollision : CCollisionObject  ) {
        m_pCollisinoMgr = collisionSystem;
        m_pCollision = pCollision;
    }

    public function setCollisionData( collisionData : Vector.<CCharacterCollisionKey> ) : void{
        _clear();
        m_CollisionData = collisionData;
        _initTrigger();
    }

    public function update( delta : Number ) : void {
        m_fTickTime += delta;

        if( hasNext() ){
            _traTriggers( m_fTickTime );
        }
    }

    public function dispose() : void
    {
        this.m_CollisionData = null;
        this.m_triggerList.splice(0 , m_triggerList.length );
        m_triggerList = null;
    }

    public function start() : void
    {
        onStart();
    }

    public function stop() : void
    {
        _clear();
    }

    protected function onStart() : void
    {
        m_boStarted = true;
    }

    public function onNext() : void
    {
        var trigger : CCollisionTimerLineTrigger;
        if( !hasNext() ) return;
        trigger = m_triggerList[ m_popIndex ];
        _createColBound( trigger );
        m_popIndex++;
    }

    public function hasNext() : Boolean
    {
        return m_popIndex < m_triggerList.length;
    }

    private function _createColBound( trigger : CCollisionTimerLineTrigger ) : void
    {
        var boundInfos : Vector.<CCharacterCollisionBoundInfo>;
        var abBox : CAABBox3 ;
        boundInfos = trigger.datas;
        for each( var boundInfo : CCharacterCollisionBoundInfo in boundInfos )
        {
            abBox = CAABBox3.ZERO.clone();
            var offset : CVector3 = new CVector3( boundInfo.v3Position.x, boundInfo.v3Position.z, boundInfo.v3Position.y);
            var size : CVector3 = new CVector3( boundInfo.v3Size.x, boundInfo.v3Size.z * 0.8, boundInfo.v3Size.y );
            offset.mulOn( UNITY_TO_FLASH );
            abBox.setCenterExt( offset , size );
            //fixme To Create The CCollisionBounds
            m_pCollision.createCollisionBound( boundInfo.nType , abBox ,boundInfo.sHitEvent , boundInfo.fDuaration );
        }
    }

    private function _traTriggers( time : Number ) : void
    {
        var trigger : CCollisionTimerLineTrigger;
        var popTime : Number;
        if( !hasNext() ) return;
        trigger  = m_triggerList[ m_popIndex ];
        popTime = trigger.startTime;
        if( popTime > time ) return;
        onNext();
        _traTriggers( time );
    }

    /**
     * 合并同一时间的碰撞框
     */
    private function _initTrigger() : void
    {
        var trigger : CCollisionTimerLineTrigger;
        var pushIndex : int ;
        for each( var keyData : CCharacterCollisionKey in m_CollisionData )
        {
           trigger = _getTriggerByTime( keyData.keyTime );
            trigger.startTime = keyData.keyTime;
            trigger.datas = trigger.datas.concat( keyData.boundsList );
            pushIndex = m_triggerList.indexOf( trigger );
            if( pushIndex < 0 )
                    m_triggerList.push( trigger );
        }
        m_triggerList.sortOn("startTime");
    }

    private function _getTriggerByTime( time : Number): CCollisionTimerLineTrigger
    {
        var trigger : CCollisionTimerLineTrigger;
        for( var i : int = 0 ; i< m_triggerList.length ;i++ )
        {
            trigger = m_triggerList[ i ];
            if( trigger.startTime == time )
                    return trigger;
        }
        trigger = new CCollisionTimerLineTrigger();
        return trigger;
    }

    protected function _clear() : void
    {
        m_CollisionData = null;
        m_fTickTime = 0.0;
        m_boStarted = false;
        m_popIndex = 0;
        if( m_triggerList )
            m_triggerList.splice(0, m_triggerList.length );
        m_triggerList = [];
    }

    private var m_fTickTime : Number = 0.0;
    private var m_CollisionData : Vector.<CCharacterCollisionKey>;
    private var m_boStarted : Boolean;
    private var m_triggerList : Array = [] ;
    private var m_popIndex : int;
    private var m_pCollisinoMgr : CCollisionManager;
    private var m_pCollision : CCollisionObject;
    private var m_sPrevTag : String;
    public static const UNITY_TO_FLASH : CVector3 = new CVector3( 1.0 , 1.0 , 1.0 );
}
}

import QFLib.Framework.CharacterExtData.CCharacterCollisionBoundInfo;

class CCollisionTimerLineTrigger {
    public function CCollisionTimerLineTrigger(  ) {
        datas = new Vector.<CCharacterCollisionBoundInfo>();
    }

    public var startTime : Number;
    public var datas : Vector.<CCharacterCollisionBoundInfo>;


}

