////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2016/12/12.
 */
package QFLib.Graphics.RenderCore.render.pass
{

    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FSmooth;
    import QFLib.Graphics.RenderCore.render.shader.VSmooth;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

    public class PSmooth extends PassBase implements IPass
    {
        public static const sName : String = "p.smooth";

        public function PSmooth ( ...args )
        {
            super ();

            _passName = sName;

            _blendMode = "custom";
        }

        public override function get vertexShader () : String
        {
            return VSmooth.Name;
        }

        public override function get fragmentShader () : String
        {
            return FSmooth.Name;
        }

        public function set uvOffsets ( value : Vector.<Number> ) : void
        {
            registerVector ( "uvOffsets", value );
        }

        public override function dispose () : void
        {
            super.dispose ();
        }
    }
}
