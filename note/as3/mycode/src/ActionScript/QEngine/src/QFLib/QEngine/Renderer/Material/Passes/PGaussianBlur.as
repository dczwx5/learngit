/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/30.
 */
package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FGaussianBlur;
    import QFLib.QEngine.Renderer.Material.Shaders.VGaussianBlur;
    import QFLib.QEngine.Renderer.Textures.Texture;

    import flash.display3D.Context3DBlendFactor;

    public class PGaussianBlur extends PassBase implements IPass
    {
        public static const sName : String = "PCompositorGaussianBlur";

        public function PGaussianBlur()
        {
            super();

            _passName = sName;

            _blendMode = "custom";
        }

        public override function get vertexShader() : String
        {
            return VGaussianBlur.Name;
        }

        public override function get fragmentShader() : String
        {
            return FGaussianBlur.Name;
        }

        public override function get srcOp() : String
        {
            return Context3DBlendFactor.ONE;
        }

        public override function get dstOp() : String
        {
            return Context3DBlendFactor.ZERO;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public function set uvExpand( value : Vector.<Number> ) : void
        {
            registerVector( "uvExpand", value );
        }

        public function set weights( value : Vector.<Number> ) : void
        {
            registerVector( "weights", value );
        }

        public function set centerWeightAndOffsets( value : Vector.<Number> ) : void
        {
            registerVector( "centerWeightAndOffsets", value );
        }

        override public function dispose() : void
        {
            super.dispose();
        }

        override public function equal( other : IPass ) : Boolean
        {
            var otherAlias : PGaussianBlur = other as PGaussianBlur;
            return otherAlias != null && innerEqual( otherAlias );
        }

        override public function clone() : IPass
        {
            var clonePass : PGaussianBlur = new PGaussianBlur();
            clonePass.copy( this );

            return clonePass;
        }
    }
}
