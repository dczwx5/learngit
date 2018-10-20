//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/11/16.
 */
package QFLib.Graphics.RenderCore.render.shader {

import QFLib.Graphics.RenderCore.render.IFragmentShader;

public class FColorMultiply extends FBase implements IFragmentShader{
    public static const Name : String = "f.colorMultiply";
    public static const MultiplyColor : String = "multiplyColor";
    public static const ConstHelper : String = "constHelper";

    public function FColorMultiply()
    {
        registerTex ( 0, mainTexture );
        registerParam(0, MultiplyColor);
        registerParam(1, ConstHelper);
    }

    public function get name () : String
    {
        return Name;
    }
    public function get code () : String// fto: col1/valA,  ft1: result,  fc0: valB, fc1: constHelper
    {
        return GA.tex("ft0", inTexCoord, 0) +
                GA.slt("ft1", "fc1.xxxx", "ft0") +
                GA.sub("ft2", "fc1.yyyy", "ft1") +
                GA.mul("ft2", "ft2", "fc1.zzzz") +
                GA.mul("ft2", "ft2", "ft0") +
                GA.mul("ft2", "ft2", "fc0") +
                GA.sub("ft3", "fc1.yyyy", "ft0") +
                GA.mov("ft5", "fc1.yyyy") +
                GA.sub("ft4", "ft5", "fc0") +
                GA.mul("ft3", "ft3", "ft4") +
                GA.mul("ft3", "ft3", "fc1.zzzz") +
                GA.sub("ft3", "fc1.yyyy", "ft3") +
                GA.mul("ft3", "ft1", "ft3") +
                GA.add("ft2", "ft2", "ft3") +
                GA.mov(outColor, "ft2") ;
    }

}
}
