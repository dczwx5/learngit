//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.movement {

import flash.geom.Point;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CMotionAction {

    private var m_pDirection : Point;
    // Movement speed, x pixel / 1 secs.
    private var m_fMoveSpeed : Number;
    private var m_fMoveSpeedFactor : Number;
    internal var m_bRunning : Boolean;

    public function CMotionAction() {
        super();
    }

    final public function isRunning() : Boolean {
        return m_bRunning;
    }

    final public function get moveSpeed() : Number {
        return m_fMoveSpeed;
    }

    final public function set moveSpeed( value : Number ) : void {
        if ( isNaN( value ) )
            value = 0.0;
        m_fMoveSpeed = value;
    }

    final public function get moveSpeedFactor() : Number {
        return m_fMoveSpeedFactor;
    }

    final public function set moveSpeedFactor( value : Number ) : void {
        if ( isNaN( value ) )
            value = 0.0;
        m_fMoveSpeedFactor = value;
    }

    final public function get direction() : Point {
        return m_pDirection;
    }

    final public function set direction( value : Point ) : void {
        if (m_pDirection == value)
            return;
        m_pDirection = value;
    }

    [Inline]
    final public function getOffsetByDelta( delta : Number ) : Number {
        return this.moveSpeed * this.moveSpeedFactor * delta;
    }

}
}
