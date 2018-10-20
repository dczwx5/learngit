/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FFilterBlur;
    import QFLib.QEngine.Renderer.Material.Shaders.VFilterBlur;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PFilterBlurInternal extends PassBase implements IPass
    {
        public static const sName : String = "PFilterBlurInternal";

        public function PFilterBlurInternal()
        {
            _passName = sName;
        }

        public override function get vertexShader() : String
        {
            return VFilterBlur.Name;
        }

        public override function get fragmentShader() : String
        {
            return FFilterBlur.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            setTexture( FBase.mainTexture, value );
        }

        public function set expands( value : Vector.<Number> ) : void
        {
            registerVector( "uvExpand", value );
        }

        public function set weights( value : Vector.<Number> ) : void
        {
            registerVector( "weights", value );
        }

        public override function copy( other : IPass ) : void
        {
            super.copy( other );
            var otherAlias : PFilterBlurInternal = other as PFilterBlurInternal;
            if( otherAlias == null )return;
            if( otherAlias.getVector( "uvExpand" ) )registerVector( "uvExpand", otherAlias.getVector( "uvExpand" ) );
            if( otherAlias.getVector( "weights" ) )registerVector( "weights", otherAlias.getVector( "weights" ) );
            if( otherAlias.getTexture( FBase.mainTexture ) )
                setTexture( FBase.mainTexture, otherAlias.getTexture( FBase.mainTexture ) );
        }

        public override function clone() : IPass
        {
            var clonePass : PFilterBlurInternal = new PFilterBlurInternal();
            clonePass.copy( this );

            return clonePass;
        }
    }
}

