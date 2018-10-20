//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/14.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
import QFLib.Math.CVector3;

public interface ICollisable {
    function get renderableObject () : CBaseObject;
    function get position() : CVector3;
    function get flipX() : Boolean;
    function get flipY() : Boolean;
    function get flipZ() : Boolean;
    function get scale() : CVector3;
    function get dir() : CVector3;
}
}
