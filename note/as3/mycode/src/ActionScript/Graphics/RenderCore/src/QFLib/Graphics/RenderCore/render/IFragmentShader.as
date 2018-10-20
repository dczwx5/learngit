package QFLib.Graphics.RenderCore.render
{
	public interface IFragmentShader
	{
		function get name():String;
		
		function get code():String;
		
		function get textureLayout():Vector.<ParamTex>;
		
		function get paramLayout():Vector.<ParamConst>;
	}
}