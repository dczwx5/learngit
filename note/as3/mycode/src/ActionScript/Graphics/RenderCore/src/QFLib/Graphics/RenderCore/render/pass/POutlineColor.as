////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Graphics.RenderCore.render.pass
{

    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FOutlineColor;
    import QFLib.Graphics.RenderCore.render.shader.VTC;

    public class POutlineColor extends PassBase implements IPass
    {
        public static const sName : String = "POutlineColor";

        private static const _bias : Vector.<Number> = Vector.<Number> ( [ 0.01, 0.0, 0.0, 0.0 ] );
        private static const _sobelWeight : Vector.<Number> = Vector.<Number> ( [ 1.0, -1.0, 2.0, -2.0 ] );

        public function POutlineColor ( ...args )
        {
            _passName = sName;
            registerVector ( "bias", _bias );
            registerVector ( "sobelWeight", _sobelWeight );
            registerVector ( "uvExpand", _uvExpand );
            registerVector ( "outlineColor", _outlineColor );
        }

        override public function dispose () : void
        {
            super.dispose ();
            _uvExpand.length = 0;
            _outlineColor.length = 0;
        }

        [Inline]
        override public function get vertexShader () : String
        {
            return VTC.Name;
        }

        [Inline]
        override public function get fragmentShader () : String
        {
            return FOutlineColor.Name;
        }

        [Inline] public function set outlineColor ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 4; i++ )
            {
                _outlineColor[ i ] = value[ i ];
            }
        }

        [Inline] public function set uvExpand ( value : Vector.<Number> ) : void
        {
            for ( var i : int = 0; i < 2; i++ )
            {
                _uvExpand[ i ] = value[ i ];
            }
        }

        override public function copy ( other : IPass ) : void
        {
            super.copy ( other );
        }

        override public function clone () : IPass
        {
            return super.clone ();
        }

        private var _uvExpand : Vector.<Number> = Vector.<Number> ( [ 0.01, 0.01, -1.0, 0.0 ] );
        private var _outlineColor : Vector.<Number> = Vector.<Number> ( [ 1.0, 1.0, 1.0, 1.0 ] );
    }
}
