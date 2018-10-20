/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public final class VWater extends VBase implements IVertexShader
    {
        public static const Name : String = "water";

        public function VWater()
        {
            registerParam( 0, matrixMVP, true );
            registerParam( 4, "reflectScaler" );
            registerParam( 5, "waveScaler" );
            registerParam( 6, "waveParam" );
            registerParam( 7, "reflectParam" );
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.m44( "vt0", inPosition, "vc0" ) +
                    GA.mov( outPos, "vt0" ) +
                        //计算屏幕坐标
                    GA.divs( "vt0.xy", "vt0.ww" ) +
                    GA.adds( "vt0.xy", "vc5.zw" ) +
                    GA.mov( "v2", "vt0" ) +
                        //计算倒影扰动因子
                    GA.muls( "vt0.x", "vc7.w" ) +
                    GA.adds( "vt0.x", "vc7.x" ) +
                    GA.sin( "vt1.x", "vt0.x" ) +
                    GA.cos( "vt1.y", "vt0.x" ) +
                    GA.mul( "v3", "vt1.xy", "vc6.zw" ) +
                        //倒影uv
                    GA.mul( "vt0", "va1", "vc4.xy" ) +
                    GA.adds( "vt0.xy", "vc4.zw" ) +
                    GA.adds( "vt0.x", "vc7.z" ) +
                    GA.mul( "vt1", "va2", "vc7.y" ) +
                    GA.add( "v0", "vt0", "vt1" ) +
                        //波浪uv
                    GA.mul( "vt0", "va2", "vc5.xy" ) +
                    GA.add( "v1", "vt0", "vc6.xy" );
        }
    }
}