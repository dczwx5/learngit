package QFLib.Graphics.RenderCore.render.shader
{
	import flash.utils.Dictionary;
	
	import QFLib.Graphics.RenderCore.render.IFragmentShader;
	import QFLib.Graphics.RenderCore.render.IVertexShader;

	public class ShaderLib
	{
		static private var _vertexDic:Dictionary = null;
		static private var _fragmentDic:Dictionary = null;
		
		static public function init():void
		{
			if (!_vertexDic)
			{
				_vertexDic = new Dictionary();
				
				registerVertex(new VTC());
				registerVertex(new VColor());
				registerVertex(new VColorTC());
				registerVertex(new VTint());
				registerVertex(new VTintTC());
				registerVertex(new VTintColor());
				registerVertex(new VTintColorTC());
				registerVertex(new VLightTC());
				registerVertex(new VWater());
				registerVertex(new VColorMultiply());
				registerVertex(new VSkeletonSink());
				registerVertex(new VSkeletonReflection());
				registerVertex(new VGaussianBlur());
				registerVertex(new VSmooth());
                registerVertex(new VRimLight());
			}
			
			if (!_fragmentDic)
			{
				_fragmentDic = new Dictionary();
				
				registerFragment(new FTexture());
				registerFragment(new FColor());
				registerFragment(new FColorAlpha());
				registerFragment(new FColorAlphaPMA());
				registerFragment(new FColorTexture());
				registerFragment(new FLightTexture());
				registerFragment(new FWater());
				registerFragment(new FAlpha());
				registerFragment(new FFake());
				registerFragment(new FColorGrading());
				registerFragment(new FColorMultiply());
				registerFragment(new FColorMatrix());
				registerFragment(new FAdvColorModify());
				registerFragment(new FGaussianBlur());
                registerFragment(new FSmooth());
				registerFragment(new FTritoneColor());
				registerFragment(new FOutlineColor());
                registerFragment(new FRimLight());
				registerFragment(new FUVAnimation());
				registerFragment(new FDistortion());
			}
		}
		
		static public function dispose():void
		{
			_vertexDic = null;
			_fragmentDic = null;
		}

		public static function registerVertex(vertexShader:IVertexShader):void
		{
			if (vertexShader.name in _vertexDic)
			{
				throw new ArgumentError("Duplicate vertex shader name!");
			}
			_vertexDic[vertexShader.name] = vertexShader;
		}
		
		public static function getVertex(name:String):IVertexShader
		{
			if(name in _vertexDic)
			{
				return _vertexDic[name];
			}
			throw new ErrorMissingVertexShaderName(name);
			return null;
		}
		
		public static function registerFragment(fragmentShader:IFragmentShader):void
		{
			if (fragmentShader.name in _fragmentDic)
			{
				throw new ArgumentError("Duplicate fragment shader name!");
			}

			_fragmentDic[fragmentShader.name] = fragmentShader;
		}
		
		public static function getFragment(name:String):IFragmentShader
		{
			if(name in _fragmentDic)
			{
				return _fragmentDic[name];
			}
			throw new ErrorMissingFragmentShaderName(name);
			return null;
		}
	}
}
class ErrorMissingVertexShaderName extends Error
{
	public function ErrorMissingVertexShaderName(name:String)
	{
		super("can not find vertex shader : " + name); 
	}
}

class ErrorMissingFragmentShaderName extends Error
{
	public function ErrorMissingFragmentShaderName(name:String)
	{
		super("can not find fragment shader : " + name); 
	}
}

class ErrorMissingShaderName extends Error
{
	public function ErrorMissingShaderName(name:String)
	{
		super("can not find shader : " + name + " in system."); 
	}
}