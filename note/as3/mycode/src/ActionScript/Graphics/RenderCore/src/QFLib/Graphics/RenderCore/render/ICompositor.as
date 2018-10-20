/**
 * Created by xandy on 2015/9/2.
 */
package QFLib.Graphics.RenderCore.render
{
	import QFLib.Graphics.RenderCore.starling.textures.Texture;

	import flash.geom.Matrix;

	import flash.geom.Point;

	public interface ICompositor
	{
		function get name():String;

		function set preRenderTarget(preTarget:Texture):void;

		function get enable():Boolean;

		function set enable(value:Boolean):void;

		function get geometry():IGeometry;

		function get material():IMaterial;

		function get worldMatrix () : Matrix;

        function get textureWidth () : int;

        function get textureHeight () : int;

        function set gradualChangeTime ( value : Number ) : void;

		function update ( deltaTime : Number ) : void;

		function dispose():void;
	}
}
