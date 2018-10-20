     package QFLib.Graphics.RenderCore.render
{
	import flash.geom.Matrix3D;
	
	import QFLib.Graphics.RenderCore.starling.textures.Texture;

	public interface IPass
	{
        function get name():String;

		function get vertexShader():String;
		function get fragmentShader():String;
		function get shaderName():Number;

		function set mainTexture( value:Texture):void;
		function getTexture(name:String):Texture;
		
		function getVector(name:String):Vector.<Number>;
		function getMatrix(name:String):Matrix3D;

		function set enable ( value : Boolean ) : void;
		function get enable () : Boolean;

		function set blendMode(value:String):void;
		function get blendMode():String;	//see class BlendMode;

        function set pma(value:Boolean):void;
		function get pma():Boolean;
		
		function get srcOp():String;
		function get dstOp():String;
		
		function get renderTarget():Texture;
		function get usingRTT():Boolean;
		function get isClearRT():Boolean;
		function get texFlagList():Vector.<String>;

		function equal(other:IPass):Boolean;
        function copy(other:IPass):void;
        function clone():IPass;
        function dispose():void;
	}
}
