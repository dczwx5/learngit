//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/5/15.
 */
package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FRimLight;
    import QFLib.Graphics.RenderCore.render.shader.VRimLight;

    public class PRimLight extends PassBase implements IPass
    {
        public static const sName : String = "PRimlight";

        private static const sConstVal : Vector.<Number> = Vector.<Number> ( [ 0.1, 0.2, 1.0, 0.5 ] );

        public function PRimLight ()
        {
            super ();
            _passName = sName;

            registerVector ( "uvExpand", _uvExpand );
            registerVector ( "constVal", sConstVal );
        }

        override public function dispose () : void
        {
            super.dispose ();
            _uvExpand.length = 0;
        }

        [Inline]
        override public function get vertexShader () : String
        {
            return VRimLight.Name;
        }

        [Inline]
        override public function get fragmentShader () : String
        {
            return FRimLight.Name;
        }

        override public function copy ( other : IPass ) : void
        {
            super.copy ( other );
        }

        override public function clone () : IPass
        {
            return super.clone ();
        }

        private var _uvExpand : Vector.<Number> = Vector.<Number> ( [ 0.1, -0.1, 0.0, 0.00001 ] );
    }
}
