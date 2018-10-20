package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.IFragmentShader;
	
	public final class FWater extends FBase implements IFragmentShader
	{
		public static const Name:String = "water";

		public function FWater()
		{
			registerTex(0, "reflectTex");
			registerTex(1, "waveTex");
			registerParam(0, "turbParam");
			registerParam(1, "waveColor");
		}
		
		public function get name():String
		{
			return Name;
		}
		
		public function get code():String
		{
			return	GA.mul("ft0.xy",	"v2.xy",	"fc0.xy")+
					GA.mul("ft0.zw",	"v2.xy",	"fc0.yx")+
					GA.add("ft1.x",		"ft0.x",	"ft0.y")+
					GA.add("ft1.y",		"ft0.z",	"ft0.w")+
					GA.sin("ft0.x",		"ft1.x")+
					GA.cos("ft0.y",		"ft1.y")+
					GA.mul("ft0.xy", 	"ft0.xy",	"v3.xy")+
					//计算倒影uv
					GA.add("ft0.xy",	"v0.xy",	"ft0.xy")+
					//采图
					GA.tex("ft0",		"ft0",	0)+
					GA.tex("ft1",		"v1",	1)+
					//波浪颜色
					GA.mul("ft1.rgb",	"ft1.rgb",	"fc1.rgb")+
					//lerp
					GA.sub("ft3.rgb",	"ft1.rgb",	"ft0.rgb")+
					GA.muls("ft3",		"fc1.www")+
					GA.add("ft0.rgb",	"ft0.rgb",	"ft3.rgb")+
					GA.mov(outColor,	"ft0");
		}
	}
}