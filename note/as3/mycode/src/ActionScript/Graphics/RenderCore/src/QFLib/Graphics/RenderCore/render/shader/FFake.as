/**
 * Created by xandy on 2015/9/7.
 */
package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IFragmentShader;

	public class FFake extends FBase implements IFragmentShader
	{
		public static const Name:String = "f.fake";
		public static const GrayFactor:String = "grayFactor";

		static private const cGrayFactor:String	= "fc0";

		public function FFake()
		{
			registerTex(0, mainTexture);
			registerParam(0, GrayFactor);
		}

		public function get name():String
		{
			return Name;
		}

		public function get code():String
		{
			var fragmentProgramCode:String =
					GA.tex("ft0", inTexCoord, 0) +
					GA.dot3s("ft0.xyz", cGrayFactor + ".xyz") +
					GA.mov("ft0.w", cGrayFactor + ".w") +
					GA.mov(outColor, "ft0");

			return fragmentProgramCode;
		}
	}
}
