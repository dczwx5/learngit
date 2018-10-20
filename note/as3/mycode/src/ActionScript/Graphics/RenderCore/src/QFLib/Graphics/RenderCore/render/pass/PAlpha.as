// =================================================================================================
//
//	Qifun Framework
//	Copyright 2015 Qifun. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package QFLib.Graphics.RenderCore.render.pass
{
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.render.shader.FBase;
    import QFLib.Graphics.RenderCore.render.shader.FAlpha;
    import QFLib.Graphics.RenderCore.render.shader.VTC;

    public class PAlpha extends PassBase implements IPass
    {
        public static const sName : String = "PAlpha";

        public function PAlpha ( ...args )
        {
            super ();

            _passName = sName;
            _premultiplyAlpha = true;
            registerVector ( FAlpha.Alpha, mAlpha );
        }
        protected var mAlpha : Vector.<Number> = new <Number>[ 0, 0, 0, 0 ];

        public override function get vertexShader () : String
        {
            return VTC.Name;
        }

        public override function get fragmentShader () : String
        {
            return FAlpha.Name;
        }

        public function get alpha () : Number
        {
            return mAlpha[ 0 ];
        }

        public function set alpha ( alpha : Number ) : void
        {
            mAlpha[ 0 ] = mAlpha[ 1 ] = mAlpha[ 2 ] = mAlpha[ 3 ] = alpha;
            registerVector ( FAlpha.Alpha, mAlpha );
        }

        public override function copy ( other : IPass ) : void
        {
            super.copy ( other );
            var otherAlias : PAlpha = other as PAlpha;
            if ( otherAlias == null )return;
            for ( var i : int = 0; i < 4; ++i )
            {
                mAlpha[ i ] = otherAlias.mAlpha[ i ];
            }
            if ( otherAlias.getTexture ( FBase.mainTexture ) )
                setTexture ( FBase.mainTexture, otherAlias.getTexture ( FBase.mainTexture ) );
        }

        public override function clone () : IPass
        {
            var clonePass : PAlpha = new PAlpha ();
            clonePass.copy ( this );

            return clonePass;
        }
    }
}
