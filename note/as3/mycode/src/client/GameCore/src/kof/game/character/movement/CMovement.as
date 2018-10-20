//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.movement {

import flash.events.Event;
import flash.geom.Point;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameComponent;
import kof.util.CAssertUtils;

/**
 * <code>CMovement</code>, A component for character moving supported.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CMovement extends CGameComponent {

//    static public const DEFAULT_SPEED : Number = 500.0;
    static public const DEFAULT_SPEED : Number = 0.0;

    /** @private */
    internal var m_bSpeedDirty : Boolean;
    /** @private */
    internal var m_bSpeedFactorDirty : Boolean;
    /** @private */
    private var m_fMoveSpeed : Number;
    /** @private */
    internal var m_bDirectionDirty : Boolean;
    /** @private */
    internal var m_pLastDirection : Point;
    /** @private */
    private var m_bMoving : Boolean;
    /** @private */
    private var m_bMovable : Boolean;
    /** @private */
    private var m_pDirection : Point;
    //fixme
    private var m_boBlockInScene : Boolean;
    /** @private */
    private var m_pMotionActions : Vector.<CMotionAction>;
    /** @private */
    private var m_bCollision : Boolean;

    /**
     * Creates a new CMovement.
     */
    public function CMovement() {
        super( 'movement' );

        m_pMotionActions = new <CMotionAction>[];
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();
    }

    /** @inheritDoc */
    override protected virtual function onEnter() : void {
        if ( !CCharacterDataDescriptor.getMoveSpeed( owner.data ) )
            this.moveSpeed = DEFAULT_SPEED;

        this.m_pDirection = new Point();
        this.m_pLastDirection = new Point();
        this.m_bCollision = true;
    }

    /** @inheritDoc */
    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        var pProperty : ICharacterProperty = getComponent( ICharacterProperty ) as ICharacterProperty;
        if ( pProperty ) {
            this.moveSpeed = pProperty.moveSpeed;
        }

        this.m_bMovable = this.moveSpeed > 0;
    }

    /** @inheritDoc */
    override protected virtual function onExit() : void {
        this.m_pDirection = null;
        this.m_pLastDirection = null;

        if ( this.m_pMotionActions && this.m_pMotionActions.length ) {
            this.m_pMotionActions.splice( 0, this.m_pMotionActions.length );
        }
        this.m_pMotionActions = null;
    }

    final public function get direction() : Point {
        return m_pDirection;
    }

    final public function set direction( value : Point ) : void {
        if ( this.direction.equals( value ) )
            return;
        m_pLastDirection.setTo( this.direction.x, this.direction.y );
        m_pDirection.setTo( value.x, value.y );
        m_bDirectionDirty = true;

        // Update moving state.
        if ( m_pLastDirection.length == 0 ) {
            m_bMoving = true;
        } else if ( value.length == 0 ) {
            m_bMoving = false;
        }
    }

    final public function get collisionEnabled() : Boolean {
        return m_bCollision;
    }

    final public function set collisionEnabled( value : Boolean ) : void {
        m_bCollision = value;
    }

    final public function get moveSpeed() : Number {
        return m_fMoveSpeed;
    }

    final public function set moveSpeed( value : Number ) : void {
        if ( this.moveSpeed == value )
            return;
        m_fMoveSpeed = value;
        this.m_bSpeedDirty = true;
    }

    final public function get speedFactor() : Number {
        return owner.data.moveSpeedFactor || 1.0;
    }

    final public function set speedFactor( value : Number ) : void {
        if ( owner.data.moveSpeedFactor == value )
            return;
        owner.data.moveSpeedFactor = value;
        m_bSpeedFactorDirty = true;
    }

    final public function get movable() : Boolean {
        return m_bMovable;
    }

    final public function set movable( value : Boolean ) : void {
        m_bMovable = value;
    }

    final public function get moving() : Boolean {
        return m_bMoving;
    }

    final public function get boBlockInScene() : Boolean {
        return m_boBlockInScene;
    }

    final public function set boBlockInScene( value : Boolean ) : void {
        m_boBlockInScene = value;
    }

    [Inline]
    final internal function setMoving( value : Boolean ) : void {
        m_bMoving = value;
    }

    [Inline]
    final public function getOffsetByDelta( fDeltaDetect : Number ) : Number {
        return this.speedFactor * this.moveSpeed * fDeltaDetect;
    }

    final public function get motionActions() : Vector.<CMotionAction> {
        return m_pMotionActions;
    }

    /**
     * @return the size of the current action queue.
     */
    final public function addMotionAction( pAction : CMotionAction ) : int {
        CAssertUtils.assertNotNull( m_pMotionActions );

        if ( !pAction )
            return m_pMotionActions.length;

        var idx : int = m_pMotionActions.indexOf( pAction );
        if ( -1 == idx ) {
            m_pMotionActions.push( pAction );
        }

        return m_pMotionActions.length;
    }

    final public function removeMotionAction( pAction : CMotionAction ) : int {
        if ( !m_pMotionActions )
            return 0;

        if ( !pAction )
            return m_pMotionActions.length;

        var idx : int = m_pMotionActions.indexOf( pAction );
        if ( -1 != idx )
            m_pMotionActions.splice( idx, 1 );

        return m_pMotionActions.length;
    }

    final public function clearAllMotionActions() : void {
        if ( !m_pMotionActions )
            return;

        m_pMotionActions.splice( 0, m_pMotionActions.length );
    }

}
}
