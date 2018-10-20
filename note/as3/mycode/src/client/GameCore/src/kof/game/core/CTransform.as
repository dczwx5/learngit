//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

import QFLib.Math.CVector3;
import QFLib.Math.CVector4;

/**
 * Character ECS Component: Transform, providing position, rotation, scale.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTransform extends CGameComponent implements ITransform {

    private var m_pos : CVector3;
    private var m_rot : CVector4;
    private var m_scale : CVector3;

    private var m_bDataDirty : Boolean;

    public function CTransform() {
        super( "transform" );
        m_bDataDirty = false;
        m_pos = new CVector3();
        m_rot = new CVector4();
        m_scale = new CVector3( 1.0, 1.0, 1.0 );
    }

    override public function dispose() : void {
        super.dispose();

        m_pos = null;
        m_rot = null;
        m_scale = null;
    }

    override protected virtual function onEnter() : void {
        // NOOP.
    }

    override protected virtual function onDataUpdated() : void {
        // Persisted data.
        if ( data && 'position' in data ) {
            m_pos.setValueXYZ(
                    Number( data.position.x ),
                    Number( data.position.y ),
                    Number( data.position.z )
            );
        }

        // Runtime data.
        if ( data && 'rotation' in data ) {
            m_rot.setValueXYZW(
                    Number( data.rotation.x ),
                    Number( data.rotation.y ),
                    Number( data.rotation.z ),
                    Number( data.rotation.w )
            );
        }

        if ( data && 'scale' in data ) {
            m_scale.setValueXYZ(
                    Number( data.scale.x ),
                    Number( data.scale.y ),
                    Number( data.scale.z )
            );
        }
    }

    override protected virtual function onExit() : void {
        m_pos = null;
        m_rot = null;
        m_scale = null;
    }

    final public function get x() : Number {
        return m_pos.x;
    }

    final public function set x( value : Number ) : void {
        if ( m_pos.x == value )
            return;
        m_pos.x = value;
        m_bDataDirty = true;
    }

    final public function get y() : Number {
        return m_pos.y;
    }

    final public function set y( value : Number ) : void {
        if ( m_pos.y == value )
            return;
        m_pos.y = value;
        m_bDataDirty = true;
    }

    final public function get z() : Number {
        return m_pos.z;
    }

    final public function set z( value : Number ) : void {
        if ( value == m_pos.z )
            return;
        m_pos.z = value;
        m_bDataDirty = true;
    }

    final public function get position() : CVector3 {
        return m_pos;
    }

    final public function set position( value : CVector3 ) : void {
        if ( value && m_pos.equals( value ) )
            return;
        m_pos.set( value );
        m_bDataDirty = true;
    }

    final public function get rotationX() : Number {
        return m_rot.x;
    }

    final public function set rotationX( value : Number ) : void {
        if ( m_rot.x == value )
            return;
        m_rot.x = value;
        m_bDataDirty = true;
    }

    final public function get rotationY() : Number {
        return m_rot.y;
    }

    final public function set rotationY( value : Number ) : void {
        if ( value == m_rot.y )
            return;
        m_rot.y = value;
        m_bDataDirty = true;
    }

    final public function get rotationZ() : Number {
        return m_rot.z;
    }

    final public function set rotationZ( value : Number ) : void {
        if ( value == m_rot.z )
            return;
        m_rot.z = value;
        m_bDataDirty = true;
    }

    final public function get rotationW() : Number {
        return m_rot.w;
    }

    final public function set rotationW( value : Number ) : void {
        if ( value == m_rot.w )
            return;
        m_rot.w = value;
        m_bDataDirty = true;
    }

    final public function get rotation() : CVector4 {
        return m_rot;
    }

    final public function set rotation( value : CVector4 ) : void {
        if ( value && m_rot.equals( value ) )
            return;
        m_rot.set( value );
        m_bDataDirty = true;
    }

    final public function get scaleX() : Number {
        return m_scale.x;
    }

    final public function set scaleX( value : Number ) : void {
        if ( value == m_scale.x ) {
            return;
        }
        m_scale.x = value;
        m_bDataDirty = true;
    }

    final public function get scaleY() : Number {
        return m_scale.y;
    }

    final public function set scaleY( value : Number ) : void {
        if ( value == m_scale.y )
            return;
        m_scale.y = value;
        m_bDataDirty = true;
    }

    final public function get scaleZ() : Number {
        return m_scale.z;
    }

    final public function set scaleZ( value : Number ) : void {
        if ( m_scale.z == value )
            return;
        m_scale.z = value;
        m_bDataDirty = true;
    }

    final public function get scale() : CVector3 {
        return m_scale;
    }

    final public function set scale( value : CVector3 ) : void {
        if ( value && m_scale.equals( value ) )
            return;
        m_scale.set( value );
        m_bDataDirty = true;
    }

    internal function update() : void {
        if ( !m_bDataDirty )
            return;

        var data : Object = this.data;

        if ( 'position' in data ) {
            //noinspection JSUnresolvedVariable
            data.position.x = m_pos.x;
            //noinspection JSUnresolvedVariable
            data.position.y = m_pos.y;
            //noinspection JSUnresolvedVariable
            data.position.z = m_pos.z;
        }

        if ( 'rotation' in data ) {
            data.rotation.x = m_rot.x;
            data.rotation.y = m_rot.y;
            data.rotation.z = m_rot.z;
            data.rotation.w = m_rot.w;
        }

        if ( 'scale' in data ) {
            data.scale.x = m_scale.x;
            data.scale.y = m_scale.y;
            data.scale.z = m_scale.z;
        }
    }

}
}
