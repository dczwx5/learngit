// =================================================================================================
//
//	Qifun Framework
//	Copyright 2015 Qifun. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package QFLib.Graphics.RenderCore.render.shader
{
    import QFLib.Graphics.RenderCore.render.IFragmentShader;

    public class FAlpha extends FBase implements IFragmentShader
    {
        public static const Name : String = "f.alpha";
        public static const Alpha : String = "alpha";

        private static const cAlpha : String = "fc0.x";

        public function FAlpha ()
        {
            registerTex ( 0, mainTexture );
            registerParam ( 0, Alpha );
        }

        public function get name () : String
        {
            return Name;
        }

        public function get code () : String
        {
            var fragmentProgramCode : String =
                    GA.tex ( "ft0", inTexCoord, 0 ) +
                    GA.mov ( "ft1.a", "ft0.a" ) +
                    GA.muls ( "ft0.xyz", "ft1.aaa" ) +
                    GA.muls ( "ft0", cAlpha ) +
                    GA.mov ( outColor, "ft0" );
            return fragmentProgramCode;
        }
    }
}
