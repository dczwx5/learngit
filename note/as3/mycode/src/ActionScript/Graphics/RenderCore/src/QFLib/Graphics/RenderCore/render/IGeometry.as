package QFLib.Graphics.RenderCore.render
{
	public interface IGeometry
	{
		function setVertexBuffers():void;
		
		//请不要改变matrix的值
		function draw():int;
		
		/*
		function get vertexBuffers():Vector<VertexBuffer3D>;
		function get indexBuffer():IndexBuffer3D;
		function get vertexDeclaration():Vector<VertexDeclaration>;
		*/
	}
}