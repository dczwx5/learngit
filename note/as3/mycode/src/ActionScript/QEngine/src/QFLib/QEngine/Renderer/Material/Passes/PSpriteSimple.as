/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Material.Passes
{
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.Shaders.FColor;
    import QFLib.QEngine.Renderer.Material.Shaders.VTintColor;

    public class PSpriteSimple extends PassBase implements IPass
    {
        public static const sName : String = "PSpriteSimple";

        public function PSpriteSimple()
        {
            super();

            _passName = sName;
        }

        public override function get vertexShader() : String
        {
            return VTintColor.Name;
        }

        public override function get fragmentShader() : String
        {
            return FColor.Name;
        }

        public function set maskColor( value : Vector.<Number> ) : void
        {
            registerVector( "maskColor", value );
        }

        public function set tintColor( value : Vector.<Number> ) : void
        {
            registerVector( "color", value );
        }

        public override function clone() : IPass
        {
            var clonePass : PSpriteSimple = new PSpriteSimple();
            clonePass.copy( this );

            return clonePass;
        }
    }
}