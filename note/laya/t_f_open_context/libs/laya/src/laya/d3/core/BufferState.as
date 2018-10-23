package laya.d3.core {
	import laya.d3.graphics.IndexBuffer3D;
	import laya.d3.graphics.VertexBuffer3D;
	import laya.d3.graphics.VertexDeclaration;
	import laya.renders.Render;
	import laya.layagl.LayaGL;
	import laya.webgl.WebGLContext;
	
	/**
	 * @private
	 * <code>BufferState</code> 类用于实现渲染所需的Buffer状态集合。
	 */
	public class BufferState {
		/**@private [只读]*/
		public var _vertexArrayObject:*;
		
		/**
		 * 创建一个 <code>BufferState</code> 实例。
		 */
		public function BufferState() {
			/*[DISABLE-ADD-VARIABLE-DEFAULT-VALUE]*/
			_vertexArrayObject = LayaGL.instance.createVertexArray();
		}
		
		/**
		 * @private
		 */
		public function bindBufferState():void {
			WebGLContext.bindVertexArray(LayaGL.instance, _vertexArrayObject);
		}
		
		/**
		 * @private
		 * vertexBuffer的vertexDeclaration不能为空,该函数比较消耗性能，建议初始化时使用。
		 */
		public function applyVertexBuffer(vertexBuffer:VertexBuffer3D):void {//TODO:动态合并是否需要使用对象池机制
			var gl:* = LayaGL.instance;
			var verDec:VertexDeclaration = vertexBuffer.vertexDeclaration;
			var valueData:Array = null;
			if (Render.isConchApp)
				valueData = verDec._shaderValues._nativeArray;
			else
				valueData = verDec._shaderValues._data;
			vertexBuffer.bind();
			for (var k:String in valueData) {
				var loc:int = parseInt(k);
				var attribute:Array = valueData[k];
				gl.enableVertexAttribArray(loc);
				gl.vertexAttribPointer(loc, attribute[0], attribute[1], attribute[2], attribute[3], attribute[4]);
			}
		}
		
		/**
		 * @private
		 * vertexBuffers中的vertexDeclaration不能为空,该函数比较消耗性能，建议初始化时使用。
		 */
		public function applyVertexBuffers(vertexBuffers:Vector.<VertexBuffer3D>):void {
			var gl:* = LayaGL.instance;
			for (var i:int = 0, n:int = vertexBuffers.length; i < n; i++) {
				var verBuf:VertexBuffer3D = vertexBuffers[i];
				var verDec:VertexDeclaration = verBuf.vertexDeclaration;
				var valueData:Array = null;
				if (Render.isConchApp)
					valueData = verDec._shaderValues._nativeArray;
				else
					valueData = verDec._shaderValues._data;
				verBuf.bind();
				for (var k:String in valueData) {
					var loc:int = parseInt(k);
					var attribute:Array = valueData[k];
					gl.enableVertexAttribArray(loc);
					gl.vertexAttribPointer(loc, attribute[0], attribute[1], attribute[2], attribute[3], attribute[4]);
				}
			}
		}
		
		/**
		 * @private
		 */
		public function applyIndexBuffer(indexBuffer:IndexBuffer3D):void {
			indexBuffer._bindForVAO();
		}
		
		/**
		 * @private
		 */
		public function unBindBufferState():void {
			WebGLContext.bindVertexArray(LayaGL.instance, null);
		}
		
		/**
		 * @private
		 */
		public function destroy():void {
			LayaGL.instance.deleteVertexArray(_vertexArrayObject);
		}
	}

}