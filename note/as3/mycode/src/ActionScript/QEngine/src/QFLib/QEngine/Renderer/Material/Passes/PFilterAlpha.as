/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */
package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FFilterAlpha;
    import QFLib.QEngine.Renderer.Material.Shaders.VTC;
    import QFLib.QEngine.Renderer.Textures.Texture;

    public class PFilterAlpha extends PassBase implements IPass
    {
        public static const sName : String = "PFilterAlpha";

        public function PFilterAlpha()
        {
            super();

            _passName = sName;

            pma = true;
            registerVector( FFilterAlpha.Alpha, mAlpha );
        }

        protected var mAlpha : Vector.<Number> = new <Number>[ 0, 0, 0, 0 ];

        public override function get vertexShader() : String
        {
            return VTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FFilterAlpha.Name;
        }

        override public function set texture( value : Texture ) : void
        {
            if( value != null )
            {
                setTexture( FBase.mainTexture, value );
            }
        }

        public function get alpha() : Number
        {
            return mAlpha[ 0 ];
        }

        public function set alpha( alpha : Number ) : void
        {
            mAlpha[ 0 ] = mAlpha[ 1 ] = mAlpha[ 2 ] = mAlpha[ 3 ] = alpha;
            registerVector( FFilterAlpha.Alpha, mAlpha );
        }

        public override function copy( other : IPass ) : void
        {
            super.copy( other );
            var otherAlias : PFilterAlpha = other as PFilterAlpha;
            if( otherAlias == null )return;
            for( var i : int = 0; i < 4; ++i )
            {
                mAlpha[ i ] = otherAlias.mAlpha[ i ];
            }
            if( otherAlias.getTexture( FBase.mainTexture ) )
                setTexture( FBase.mainTexture, otherAlias.getTexture( FBase.mainTexture ) );
        }

        public override function clone() : IPass
        {
            var clonePass : PFilterAlpha = new PFilterAlpha();
            clonePass.copy( this );

            return clonePass;
        }
    }
}
