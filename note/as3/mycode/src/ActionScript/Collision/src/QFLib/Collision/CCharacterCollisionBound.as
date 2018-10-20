//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/23.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Collision.*;

import QFLib.Collision.common.ICollision;
import QFLib.Foundation.CMap;
import QFLib.Foundation.free;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;
import QFLib.Math.CVector3;

/**
 * extension time & hitEvent for CCollisionBound;
 */
public class CCharacterCollisionBound implements IUpdatable,IDisposable{
    public function CCharacterCollisionBound(  ) {
        super(  );
    }

    public function dispose() : void
    {
        free(m_pCharacterCollision);
        m_pCharacterCollision = null;
        m_sHitEvent = "";
    }

    public function update( delta : Number ) : void
    {
        m_fTickTime += delta;
        m_fLeftTime -= delta;
    }

    public function get isOutDate() : Boolean
    {
        return m_fLeftTime < 0.0;
    }

    final public function get characterCollision() : CCollisionBound{
        return m_pCharacterCollision;
    }

    final public function set characterCollision( value : CCollisionBound) : void {
        this.m_pCharacterCollision = value;
    }

    final public function get hitEvent() : String
    {
        return m_sHitEvent;
    }

    final public function set hitEvent( value : String ) : void
    {
        m_sHitEvent = value;
    }

    final public function set durationTime( time : Number ) : void
    {
        m_fLeftTime = m_fDurationTime = time;
    }

    final public function get durationTime() : Number
    {
        return m_fDurationTime;
    }

    private var m_fDurationTime : Number;
    private var m_pCharacterCollision : CCollisionBound;
    private var m_sHitEvent : String;
    private var m_fTickTime : Number = 0.0;
    private var m_fLeftTime : Number = 0.0;
}
}
