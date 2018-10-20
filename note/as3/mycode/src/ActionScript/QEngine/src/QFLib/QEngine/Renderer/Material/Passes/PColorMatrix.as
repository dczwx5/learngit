/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FColorMatrix;
    import QFLib.QEngine.Renderer.Material.Shaders.VTintColorTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PColorMatrix extends PassBase implements IPass
    {
        public static const sName : String = "PColorMatrix";

        static private var _minColor : Vector.<Number> = new <Number>[ 0, 0, 0, 0.0001 ];

        public function PColorMatrix()
        {
            super();

            _passName = sName;

            registerVector( "minColor", _minColor );
        }

        public override function get vertexShader() : String
        {
            return VTintColorTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FColorMatrix.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public function set maskColor( value : Vector.<Number> ) : void
        {
            registerVector( "maskColor", value );
        }

        public function set tintColor( value : Vector.<Number> ) : void
        {
            registerVector( "color", value );
        }

        public function set colorMatrix( value : Vector.<Number> ) : void
        {
            registerVector( FColorMatrix.ColorMatrix, value );
        }

        public override function clone() : IPass
        {
            var clonePass : PColorMatrix = new PColorMatrix();
            clonePass.copy( this );

            return clonePass;
        }
    }
}