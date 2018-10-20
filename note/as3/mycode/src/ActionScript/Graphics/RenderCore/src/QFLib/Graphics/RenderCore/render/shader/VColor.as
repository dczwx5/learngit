package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IVertexShader;
	
	public final class VColor extends VBase implements IVertexShader
	{
		public static const Name:String = "color";

		static private const cMatrixMVP:String	= "vc0";
		
		public function VColor()
		{
			registerParam(0, matrixMVP, true);
		}
		
		public function get name():String
		{
			return Name;
		}
		
		public function get code():String
		{
			return	GA.m44(outPos,		inPosition,		cMatrixMVP) +
					GA.mov(outColor,	inColor);
		}
	}
}