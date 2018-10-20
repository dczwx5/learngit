////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2017/5/26.
 */
package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FDistortion;
    import QFLib.Graphics.RenderCore.render.shader.VTC;

    public class PDistortion extends PassBase implements IPass
    {
        public static const sName : String = "PDistortion";

        private static var sConstVal : Vector.<Number> = Vector.<Number> ( [ 0.0, -1.0, 6.28, 1.0 ] );

        public function PDistortion ()
        {
            super ();
            _passName = sName;
            registerVector ( "constVal", sConstVal );
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        [Inline]
        override public function get vertexShader () : String
        {
            return VTC.Name;
        }

        [Inline]
        override public function get fragmentShader () : String
        {
            return FDistortion.Name;
        }

        public function set distortionSize ( value : Vector.<Number> ) : void
        {
            registerVector ( "distortionSize", value );
        }

        public function set range ( value : Vector.<Number> ) : void
        {
            registerVector ( "range", value );
        }

        public function set currentPos ( value : Vector.<Number> ) : void
        {
            registerVector ( "currentPos", value );
        }

        public function set direction ( value : Vector.<Number> ) : void
        {
            registerVector ( "direction", value );
        }

        override public function copy ( other : IPass ) : void
        {
            super.copy ( other );
        }

        override public function clone () : IPass
        {
            return super.clone ();
        }
    }
}
