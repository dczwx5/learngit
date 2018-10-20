package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IVertexShader;
	
	public final class VSkeletonSink extends VBase implements IVertexShader
	{
		public static const Name:String = "sprite.sink";

		static private var cMatrixMVP:String		= "vc0";
		static private var cSinkHeight:String		= "vc4.x";
		static private var cLightColor:String		= "vc5";
		static private var cTintColor:String 		= "vc6";
		
		public function VSkeletonSink()
		{
			registerParam(0, matrixMVP, true);
			registerParam(4, "sinkParam");
			registerParam(5, "lightColor");
			registerParam(6, "tintColor");
		}
		
		public function get name():String
		{
			return Name;
		}
		
		public function get code():String
		{
			return GA.mov("vt0", inPosition) +
					GA.adds("vt0.y", cSinkHeight) +
					GA.m44(outPos, "vt0", cMatrixMVP) +
					GA.mov("vt0", cLightColor) +
					GA.muls("vt0", cTintColor) +
					GA.mul(outColor, "vt0", inColor) +
					GA.mov(outTexCoord, inTexCoord);
		}
	}
}