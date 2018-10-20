//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Framework.CCharacter;
import QFLib.Math.CVector3;
import QFLib.Math.CVector4;

import kof.game.character.display.IDisplay;
import kof.game.core.CGameComponent;
import kof.game.core.ITransform;
import kof.util.CAssertUtils;

/**
 * 角色Transform组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterTransform extends CGameComponent implements ITransform {

    private var m_pCharacter : CCharacter;

    public function CCharacterTransform() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        m_pCharacter = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        var pDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
        CAssertUtils.assertNotNull( pDisplay, "IDisplay required by CCharacterTransform." );

        this.m_pCharacter = pDisplay.modelDisplay;
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();

        this.m_pCharacter = null;
    }

    final public function get x() : Number {
        return m_pCharacter.position.x;
    }

    public function set x( value : Number ) : void {
        m_pCharacter.position.x = value;
    }

    public function get y() : Number {
        return m_pCharacter.position.z;
    }

    public function set y( value : Number ) : void {
        m_pCharacter.position.z = value;
    }

    public function get z() : Number {
        return m_pCharacter.position.y;
    }

    public function set z( value : Number ) : void {
        m_pCharacter.position.y = value;
    }

    public function get position() : CVector3 {
        return new CVector3( this.x, this.y, this.z );
    }

    public function get rotationX() : Number {
        return m_pCharacter.localRotation.x;
    }

    public function set rotationX( value : Number ) : void {
        m_pCharacter.localRotation.x = value;
    }

    public function get rotationY() : Number {
        return m_pCharacter.localRotation.y;
    }

    public function set rotationY( value : Number ) : void {
        m_pCharacter.localRotation.y = value;
    }

    public function get rotationZ() : Number {
        return m_pCharacter.localRotation.z;
    }

    public function set rotationZ( value : Number ) : void {
        m_pCharacter.localRotation.z = value;
    }

    public function get rotationW() : Number {
        return 0;
    }

    public function set rotationW( value : Number ) : void {
        // NOOP.
    }

    public function get rotation() : CVector4 {
        return new CVector4( this.rotationX, this.rotationY, this.rotationZ, this.rotationW );
    }

    public function get scale() : CVector3 {
        return m_pCharacter.scale;
    }

    public function get scaleX() : Number {
        return m_pCharacter.scale.x;
    }

    public function set scaleX( value : Number ) : void {
        m_pCharacter.scale.x = value;
    }

    public function get scaleY() : Number {
        return m_pCharacter.scale.y;
    }

    public function set scaleY( value : Number ) : void {
        m_pCharacter.scale.y = value;
    }

    public function get scaleZ() : Number {
        return m_pCharacter.scale.z;
    }

    public function set scaleZ( value : Number ) : void {
        m_pCharacter.scale.z = value;
    }

    public function move( x : Number, y : Number, z : Number, bCollision : Boolean = false, bOnTerrain : Boolean = false,
                          bCheckHeight : Boolean = true, bEnableSliding : Boolean = true, iSlideFactor : int = 3,
                          bSlideLineCheck : Boolean = true ) : Boolean {
        return m_pCharacter.move( x, y, z, bCollision, bOnTerrain, bCheckHeight, bEnableSliding, iSlideFactor, bSlideLineCheck );
    }

    public function moveTo( x : Number, y : Number, z : Number, bCollision : Boolean = false, bOnTerrain : Boolean = false,
                            bCheckHeight : Boolean = true, bEnableSliding : Boolean = true, iSlideFactor : int = 3,
                            bSlideLineCheck : Boolean = true ) : Boolean {
        return m_pCharacter.moveTo( x, y, z, bCollision, bOnTerrain, bCheckHeight, bEnableSliding, iSlideFactor, bSlideLineCheck );
    }

    /*public function moveToFrom2D( x : Number, y : Number, fHeight : Number, f2DDepth : Number = 0.0,
                                  bOnTerrain : Boolean = false ) : Boolean {
        return m_pCharacter.moveToFrom2D( x, y, fHeight, f2DDepth, bOnTerrain );
    }*/

}
}
