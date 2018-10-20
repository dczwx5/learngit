/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FFilterBlurTint;

    public class PFilterBlurFinal extends PFilterBlurInternal
    {
        public static const sName : String = "PFilterBlurFinal";

        public function PFilterBlurFinal()
        {
            super();

            _passName = sName;
        }

        public override function get fragmentShader() : String
        {

            return FFilterBlurTint.Name;
        }

        public function set color( value : Vector.<Number> ) : void
        {
            registerVector( "color", value );
        }

        public override function copy( other : IPass ) : void
        {
            super.copy( other );
            var otherAlias : PFilterBlurFinal = other as PFilterBlurFinal;
            if( otherAlias == null )return;
            if( otherAlias.getVector( "color" ) )registerVector( "color", otherAlias.getVector( "color" ) );
        }

        public override function clone() : IPass
        {
            var clonePass : PFilterBlurFinal = new PFilterBlurFinal();
            clonePass.copy( this );

            return clonePass;
        }
    }
}