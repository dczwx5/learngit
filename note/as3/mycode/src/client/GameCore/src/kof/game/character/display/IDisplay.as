//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.display {

import QFLib.Framework.CCharacter;
import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox2;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IDisplay extends IDisposable, IUpdatable {

    /// Testing structure.
    /// @{
    function showQuaq( quad : DisplayObject, isShow : Boolean ) : void;
    /// @}

    function get modelDisplay() : CCharacter;

    function get direction() : int;
    function set direction( value : int ) : void;

    function get directionY() : int;
    function set directionY( value : int ) : void;

    function get skin() : String;
    function set skin( value : String ) : void;

    function get isReady() : Boolean;

    function shake( fIntensity : Number, fTimeDuration : Number ) : void;

    function shakeXY( fIntensityX : Number, fIntensityY : Number, fTimeDuration
            : Number , fPeriodTime : Number = 0.02) : void;

    function get modelCurrentBound() : CAABBox2;

    function get defaultBound() : CAABBox2;

    function get boInView() : Boolean;
    function set boInView( isViewRange : Boolean ) : void;
    function getCharacterBaseURI() : String;

    function get loadingPriority() : int;
    function set loadingPriority( value : int ) : void;

}
}
