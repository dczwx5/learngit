//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/11/16.
 */
package QFLib.Graphics.RenderCore.render.shader {

import QFLib.Graphics.RenderCore.render.IVertexShader;

public class VColorMultiply extends VBase implements IVertexShader{
    public static const Name:String = "v.colorMultiply";
    static private const cMatrixMVP:String	= "vc0";

    public function VColorMultiply()
    {
        registerParam(0, matrixMVP, true);
    }

    public function get name():String
    {
        return Name;
    }

    public function get code():String
    {
        return	GA.m44(outPos,		inPosition,		cMatrixMVP) +
                GA.mov(outTexCoord, inTexCoord);
                //GA.mov(outColor,	inColor) ;
    }
}
}
