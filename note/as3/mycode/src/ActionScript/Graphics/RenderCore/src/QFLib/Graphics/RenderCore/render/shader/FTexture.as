package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IFragmentShader;

	public final class FTexture extends FBase implements IFragmentShader
	{
		public static const Name:String = "texture";
		public function FTexture()
		{
			registerTex(0, mainTexture);
		}
		
		public function get name():String
		{
			return Name;
		}
		
		public function get code():String
		{
			return GA.tex(outColor, inTexCoord, 0);
		}
		
	}
}