//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/11/16.
 */
package QFLib.Graphics.RenderCore.render.pass {

import QFLib.Graphics.RenderCore.render.IPass;
import QFLib.Graphics.RenderCore.render.shader.FColorMultiply;
import QFLib.Graphics.RenderCore.render.shader.VColorMultiply;75

public class PColorMultiply extends PassBase implements IPass
{
    public static const sName : String = "PMultiplyColor";

    private var mColor : Vector.<Number> = new <Number>[ 0.5, 0.5 , 0.0, 1 ];
    private var mConstHelper : Vector.<Number> = new<Number>[0.5 , 1.0, 2.0, 3.0];
    public function PColorMultiply()
    {
        super ();

        _passName = sName;
        registerVector ( FColorMultiply.MultiplyColor, mColor );
        registerVector( FColorMultiply.ConstHelper, mConstHelper);
    }

    public override function get vertexShader () : String
    {
        return VColorMultiply.Name;
    }

    public override function get fragmentShader () : String
    {
        return FColorMultiply.Name;
    }
    public function get color () : Vector.<Number>
    {
        return mColor;
    }
    public function set color ( color : Vector.<Number> ) : void
    {
        mColor = color;
        registerVector ( FColorMultiply.MultiplyColor, mColor );
    }

    public function set constHelper( consts : Vector.<Number> ) : void
    {
        mConstHelper = consts;
        registerVector( FColorMultiply.ConstHelper, mConstHelper);
    }

    public override function clone () : IPass
    {
        var clonePass : PAlpha = new PAlpha ();
        clonePass.copy ( this );

        return clonePass;
    }
}
}
