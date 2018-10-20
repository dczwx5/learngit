package QFLib.Graphics.RenderCore.render
{
	import flash.display3D.Program3D;

	internal class Program
	{
		private var _program:Program3D;
		private var _vaFlag:uint;
		private var _vertShader:IVertexShader;
		private var _fragShader:IFragmentShader;
		
		public function Program()
		{
		}
		
		public function get program():Program3D
		{
			return _program;
		}
		
		public function set program(value:Program3D):void
		{
			_program = value;
		}

		public function get vertShader():IVertexShader
		{
			return _vertShader;
		}

		public function set vertShader(value:IVertexShader):void
		{
			_vertShader = value;
		}

		public function get fragShader():IFragmentShader
		{
			return _fragShader;
		}

		public function set fragShader(value:IFragmentShader):void
		{
			_fragShader = value;
		}
		
		public function get inFlag():uint
		{
			return _vaFlag;
		}
		
		public function set inFlag(value:uint):void
		{
			_vaFlag = value;
		}
	}
}