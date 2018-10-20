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
public interface ITransform extends IGameComponent {

    function get x() : Number;

    function set x( value : Number ) : void;

    function get y() : Number;

    function set y( value : Number ) : void;

    function get z() : Number;

    function set z( value : Number ) : void;

    function get position() : CVector3;

    function get rotationX() : Number;

    function set rotationX( value : Number ) : void;

    function get rotationY() : Number;

    function set rotationY( value : Number ) : void;

    function get rotationZ() : Number;

    function set rotationZ( value : Number ) : void;

    function get rotationW() : Number;

    function set rotationW( value : Number ) : void;

    function get rotation() : CVector4;

    function get scale() : CVector3;

    function get scaleX() : Number;

    function set scaleX( value : Number ) : void;

    function get scaleY() : Number;

    function set scaleY( value : Number ) : void;

    function get scaleZ() : Number;

    function set scaleZ( value : Number ) : void;

}
}
