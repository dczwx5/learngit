/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public final class VSkeletonReflection extends VBase implements IVertexShader
    {
        public static const Name : String = "sprite.reflection";

        static private var cMatrixMVP : String = "vc0";
        static private var cSinkHeight : String = "vc4.x";
        static private var cRScale : String = "vc4.y";
        static private var cCenter : String = "vc5.xy";
        static private var cMorph : String = "vc5.zw";
        static private var cAlphaScaler : String = "vc6";
        static private var cTintColor : String = "vc7";
        static private var cLightColor : String = "vc8";

        public function VSkeletonReflection()
        {
            registerParam( 0, matrixMVP, true );
            registerParam( 4, "sinkParam" );
            registerParam( 5, "modelParam" );
            registerParam( 6, "alphaScaler" );
            registerParam( 7, "tintColor" );
            registerParam( 8, "lightColor" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.mov( "vt0", inPosition ) +
                    GA.adds( "vt0.y", cSinkHeight ) +
                    GA.subs( "vt0.xy", cCenter ) +
                    GA.muls( "vt0.xy", cMorph ) +
                    GA.muls( "vt0.y", cRScale ) +
                    GA.adds( "vt0.xy", cCenter ) +
                    GA.m44( outPos, "vt0", cMatrixMVP ) +
                    GA.mov( "vt0", cAlphaScaler ) +
                    GA.muls( "vt0", cTintColor ) +
                    GA.muls( "vt0", cLightColor ) +
                    GA.mul( outColor, "vt0", inColor ) +
                    GA.mov( outTexCoord, inTexCoord );
        }
    }
}