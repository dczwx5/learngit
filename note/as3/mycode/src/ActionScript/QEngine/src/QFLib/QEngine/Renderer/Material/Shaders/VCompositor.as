/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by xandy on 2015/9/7.
 */
package QFLib.QEngine.Renderer.Material.Shaders
{
    import QFLib.QEngine.Renderer.Material.IVertexShader;

    public class VCompositor extends VBase implements IVertexShader
    {
        public static const Name : String = "compositor";

        public function VCompositor()
        {
        }

        public function get name() : String
        {
            return Name;
        }

        public function get code() : String
        {
            return GA.mov( outPos, inPosition ) +
                    GA.mov( outTexCoord, inTexCoord );
        }
    }
}
