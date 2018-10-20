package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IVertexShader;
	
	public final class VTintTC extends VBase implements IVertexShader
	{
		public static const Name:String = "tint.tc";

		static private const cColor:String		= "vc0";
		static private const cMatrixMVP:String	= "vc1";
		
		public function VTintTC()
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
					GA.mov(outColor,	cColor) +
					GA.mov(outTexCoord,	inTexCoord);
		}
	}
}