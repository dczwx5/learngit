package QFLib.Graphics.RenderCore.render
{

	import QFLib.Math.CVector2;

	import flash.geom.Matrix3D;
	import flash.geom.Point;

	public interface ICamera
	{
        function get enabled():Boolean;
        function set enabled(bEnabled:Boolean):void;

		function get matrixProj():Matrix3D;
		
		function set matrixProj(matrix:Matrix3D):void;
		
		function setPosition(x:Number, y:Number):void;
		
		function setOrthoSize( width : Number, height : Number ) : void;

		function get viewportWidth():Number;
		
		function get viewportHeight():Number;
		
		function get viewportX():Number;
		
		function get viewportY():Number;
		
		function get scale():Number;
		
		function screenToWorld( x : Number, y : Number, worldPos : CVector2 ):void;

		function get cullingMask():uint;
		function set cullingMask(value:uint):void;

		function get depth():int;
		function set depth(value:int):void;

		function get clearMask():int;
		function set clearMask(value:int):void;
	}
}