package QFLib.Graphics.RenderCore.render
{
	public interface IVertexShader
	{
		function get name():String;
		
		function get code():String;
		
		function get paramLayout():Vector.<ParamConst>;
	}
}