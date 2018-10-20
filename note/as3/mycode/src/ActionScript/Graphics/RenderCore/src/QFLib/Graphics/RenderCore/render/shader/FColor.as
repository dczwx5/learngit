package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IFragmentShader;

	public final class FColor extends FBase implements IFragmentShader
	{
		public static const Name:String = "color";

		private static const cMaskColor:String = "fc0";
		private static const cDstBlendFactor:String = "fc0.www";

		public function FColor()
		{
			registerParam(0, "maskColor");
		}

		public function get name():String
		{
			return Name;
		}

		public function get code():String
		{
			return GA.mov("ft0", inColor) +
					GA.muls("ft0.xyz", cDstBlendFactor) +
					GA.adds("ft0.xyz", cMaskColor + ".xyz") +
					GA.mov(outColor, "ft0");
	 	}
	}
}