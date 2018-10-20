package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IVertexShader;

	public final class VTintColor extends VBase implements IVertexShader
	{
		public static const Name:String = "tint.color";

		static private const cColor:String		= "vc0";
		static private const cMatrixMVP:String	= "vc1";
			
		public function VTintColor()
		{
			registerParam(0, "color");
			registerParam(1, matrixMVP, true);
		}
		
		public function get name():String
		{
			return Name;
		}
		
		public function get code():String
		{
			return	GA.m44(outPos,		inPosition,		cMatrixMVP)+
					GA.mul(outColor,	inColor,		cColor);
		}
	}
}