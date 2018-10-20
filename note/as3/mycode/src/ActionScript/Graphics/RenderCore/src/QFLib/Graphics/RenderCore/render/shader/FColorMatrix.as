package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IFragmentShader;
	
	public class FColorMatrix extends FBase implements IFragmentShader
	{	
		public static const Name:String = "texture.color.matrix";

		public static const ColorMatrix:String = "colorMatrix";
		public static const ColorOffsets : String = "colorOffsets";
		public static const AlphaBias:String = "alphaBias";
		
		static private const cColorMatrix:String	= "fc3";
		static private const cColorOffset:String	= "fc1";
		static private const cAlphaBias:String		= "fc2.w";
		
		public function FColorMatrix()
		{
			super();
			
			registerTex(0, mainTexture);
			registerParam(1, ColorOffsets );
			registerParam(2, AlphaBias);
            registerParam(3, ColorMatrix );
        }
		
		public function get name():String
		{
			return Name;
		}
		
		public function get code():String
		{
			var fs:String =
				GA.tex("ft0",		inTexCoord,	0)+				// read texture color
                GA.sub("ft1.w", "ft0.w", cAlphaBias)+
                GA.kil("ft1.w") +
				GA.m44("ft2",		"ft0",		cColorMatrix)+ 	// multiply color with 4x4 matrix
				GA.adds("ft2.xyz",		cColorOffset + ".xyz") +				// add color offset
				GA.mov(outColor, 	"ft2");				        // copy to output;
			return fs;
		}
	}
}