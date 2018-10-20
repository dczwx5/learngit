package QFLib.Graphics.RenderCore.render
{
	public class VertexDecl
	{
		public var sematic:int = 0;		//enum: 0=position 1=color 2:uv;
		public var stream:int = 0;		//index of source stream array
		public var dataType:int = 0;	//float2 float4 byte4
		public var offset:int = 0;		//stride in stream.
		
		public function VertexDecl()
		{
		}
		
		public static function getDefPositionDecl():VertexDecl
		{
			return null;
		}
		public static function getDefColor4Decl():VertexDecl
		{
			return null;
		}
		public static function getDefColor32Decl():VertexDecl
		{
			return null;
		}
		public static function getDefTexcoordDecl():VertexDecl
		{
			return null;
		}
	}
}