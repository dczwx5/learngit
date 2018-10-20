//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight.catches {

import QFLib.Interface.IDisposable;

import flash.geom.Matrix3D;

import kof.game.core.CGameObject;

/**
 * Catcher Information.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ICatcherInfo extends IDisposable {

    function get owner() : CGameObject;

    function get ownerBoneName() : String;

    function get target() : CGameObject;

    function get targetBoneName() : String;

    function get alignment() : int;

    function get ownerRotationAppend() : Boolean;

    function get targetRotationAppend() : Boolean;

    function get layerPriority() : int;

    function get ownerWorldMat() : Matrix3D;

    function get targetWorldMat() : Matrix3D;

    function get targetFlipX() : Boolean;

    function get targetFlipY() : Boolean;

    function remove() : void;

}
}
