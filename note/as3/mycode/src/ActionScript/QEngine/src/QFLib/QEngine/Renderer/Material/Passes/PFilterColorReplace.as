/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FBase;
    import QFLib.QEngine.Renderer.Material.Shaders.FFilterColor;
    import QFLib.QEngine.Renderer.Material.Shaders.VTC;

    public class PFilterColorReplace extends PassBase implements IPass
    {
        public static const sName : String = "PFilterColorReplace";

        private static var _minColor : Vector.<Number> = new <Number>[ 0, 0, 0, 0.0001 ];

        public function PFilterColorReplace()
        {
            super();

            _passName = sName;

            registerVector( "minColor", _minColor );
            //registerVector(FFilterColor.ColorMatrix, _colorMatrix);
        }

        public override function get vertexShader() : String
        {
            return VTC.Name;
        }

        public override function get fragmentShader() : String
        {
            return FFilterColor.Name;
        }

        public function set colorMatrix( value : Vector.<Number> ) : void
        {
            registerVector( FFilterColor.ColorMatrix, value );
        }

        public override function copy( other : IPass ) : void
        {
            super.copy( other );
            var otherAlias : PFilterColorReplace = other as PFilterColorReplace;
            if( otherAlias == null )return;
            if( otherAlias.getVector( FFilterColor.ColorMatrix ) )
                registerVector( FFilterColor.ColorMatrix, otherAlias.getVector( FFilterColor.ColorMatrix ) );
            if( otherAlias.getTexture( FBase.mainTexture ) )
                setTexture( FBase.mainTexture, otherAlias.getTexture( FBase.mainTexture ) );
        }

        public override function clone() : IPass
        {
            var clonePass : PFilterColorReplace = new PFilterColorReplace();
            clonePass.copy( this );

            return clonePass;
        }
    }
}