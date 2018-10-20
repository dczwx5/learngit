package QFLib.Graphics.RenderCore.render.shader
{
	import QFLib.Graphics.RenderCore.render.ParamConst;
	import QFLib.Graphics.RenderCore.render.ParamTex;
	
	public class FBase
	{
		protected static const outColor:String		= "oc";
		//以下SVBase是互相对应的
		protected static const inColor:String		= VBase.outColor;
		protected static const inTexCoord:String	= VBase.outTexCoord;
		
		public static const mainTexture:String		= "texture";
		
		private var _paramLayout:Vector.<ParamConst> = new Vector.<ParamConst>();
		private var _textureLayout:Vector.<ParamTex> = new Vector.<ParamTex>();
		
		protected function registerTex(index:int, name:String):void
		{
			var textureParam:ParamTex = new ParamTex();
			textureParam.index = index;
			textureParam.name = name;
			_textureLayout.push(textureParam);
		}
		
		protected function registerParam(index:int, name:String, isMatrix:Boolean = false, transpose:Boolean = true):void
		{
			var param:ParamConst = new ParamConst();
			param.index = index;
			param.name = name;
			param.isMatrix = isMatrix;
			param.transpose = transpose;
			_paramLayout.push(param);
		}
		
		public function get paramLayout():Vector.<ParamConst>
		{
			return _paramLayout;
		}
		
		public function get textureLayout():Vector.<ParamTex>
		{
			return _textureLayout;
		}
		
	}
}