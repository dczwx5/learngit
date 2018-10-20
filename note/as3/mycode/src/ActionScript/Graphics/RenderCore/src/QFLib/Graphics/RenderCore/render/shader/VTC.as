package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IVertexShader;

	public final class VTC extends VBase implements IVertexShader
	{
		public static const Name:String = "tc";

		static private const cMatrixMVP:String	= "vc0";
		
		public function VTC()
		{
			registerParam(0, matrixMVP, true);
		}
		
		public function get name():String
		{
			return Name;
		}
		
		public function get code():String
		{
			return	GA.m44(GA.outPos,	inPosition,		cMatrixMVP) +	// 4x4 matrix transform to output space
					GA.mov(outTexCoord,	inTexCoord);					// pass texture coordinates to fragment program;
		}
	}
}