package QFLib.Graphics.RenderCore.starling.display
{

    import QFLib.Graphics.RenderCore.render.IGeometry;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.textures.TextureSmoothing;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;

    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    public class Mesh extends DisplayObject implements IGeometry
	{
		private static const FAR_POINT:Number = -10000.0;
		
		public var worldMatrix2D:Matrix = null;
		public var material:IMaterial = null;

		private var m_VertexBuffer : VertexBuffer3D = null;
		private var m_IndexBuffer : IndexBuffer3D = null;
		private var _vertexData:VertexData;	
        private var _indices:Vector.<uint>;
        private var _vertexNumDirty : Boolean = true;
        private var _indicesNumDirty : Boolean = true;

        /** The smoothing filter that is used for the texture.
         *   @default bilinear
         *   @see QFLib.Graphics.RenderCore.starling.textures.TextureSmoothing */
        private var _smoothing:String;
        private var _texture:Texture;

        private var _usedNumVertices : int = -1;
        private var _useNumIndices : int = -1;

        private var _tinted:Boolean;

		public function Mesh(texture:Texture) 
		{
            _smoothing = TextureSmoothing.BILINEAR;
            _texture = texture;

            var premultiplyAlpha : Boolean = texture != null ? texture.premultipliedAlpha : false;
            _vertexData = new VertexData ( 0, premultiplyAlpha );
            _indices = new Vector.<uint> ();

			Starling.addContext3DCreateCallback( this, onContextCreated );
		}
		
		override public function dispose():void
		{
			Starling.removeContext3DCreateCallback( this, onContextCreated );
			destroyBuffers ();
			worldMatrix2D = null;
			material = null;
			if(_vertexData){
				_vertexData.dispose();
				_vertexData = null;
			}
			_texture = null;
			_indices = null;
			
			super.dispose();
		}

		[Inline] final public function set texture ( value : Texture ) : void
        {
            if ( _texture != value )
            {
                _texture = value;
                if ( _texture != null )
                    _vertexData.premultipliedAlpha = _texture.premultipliedAlpha;
            }
        }

		public function setMesh(vertices:Vector.<Number>, uvs:Vector.<Number>, triangles:Vector.<uint>, pma:Boolean = false):void 
		{
			if (_vertexData == null || _vertexData.numVertices != (vertices.length >> 1))
			{
				_vertexData = new VertexData(vertices.length >> 1, pma);
			}
			
			for (var i:int = 0; i < _vertexData.numVertices; ++i)
			{
				_vertexData.setPosition(i, vertices[int(2 * i)], vertices[int(2 * i + 1)]);
				_vertexData.setTexCoords(i, uvs[int(2 * i)], uvs[int(2 * i + 1)]);
			}

			if (_indices == null)
			{
				_indices = triangles.concat();
			}
		}
		
		public function copyVertexDataTransformedTo(targetData:VertexData,
														targetVertexID:int = 0,
														matrix:Matrix = null):void {

			_vertexData.copyTransformedTo(targetData, targetVertexID, matrix, 0, numVertices);
		}
				
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			if (_useNumIndices < 3 || _texture == null || _texture.disposed || _texture.base == null )
                return;
			
			var rcmd:RenderCommand = RenderCommand.assign(worldMatrix2D);
			rcmd.geometry = this;
			rcmd.material	= material;
			Starling.current.addToRender( rcmd );
		}

		public function syncBuffers () : void
		{
			var instance : Starling = Starling.current;
			if ( _vertexNumDirty || m_VertexBuffer == null )
			{
				if ( m_VertexBuffer != null ) instance.destroyVertexBuffer ( m_VertexBuffer );
                m_VertexBuffer = instance.createVertexBuffer ( _vertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX );
                _vertexNumDirty = false;
			}
			if ( _indicesNumDirty || m_IndexBuffer == null )
			{
				if ( m_IndexBuffer != null ) instance.destroyIndexBuffer ( m_IndexBuffer );
				m_IndexBuffer = instance.createIndexBuffer ( _indices.length );
                _indicesNumDirty = false;
			}

			if ( m_VertexBuffer != null )
				instance.uploadVertexBufferData ( m_VertexBuffer, _vertexData.rawData, 0, _vertexData.numVertices );
			if ( m_IndexBuffer != null )
				instance.uploadIndexBufferData ( m_IndexBuffer, _indices, 0, _indices.length );
		}

		public function setVertexBuffers () : void
		{
			var instance : Starling = Starling.current;
			instance.setVertexBuffer ( 0, m_VertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
			instance.setVertexBuffer(1, m_VertexBuffer,	VertexData.COLOR_OFFSET,	Context3DVertexBufferFormat.FLOAT_4);
			instance.setVertexBuffer ( 2, m_VertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
		}

		public function draw () : int
		{
			var instance : Starling = Starling.current;
			instance.drawTriangles ( m_IndexBuffer, 0, _useNumIndices / 3 );
			instance.clearVertexBuffer ( 0 );
			instance.clearVertexBuffer ( 1 );
			instance.clearVertexBuffer ( 2 );
			return 1;
		}

        [Inline] final public function set useNumVertices ( value : int ) : void
        {
            _usedNumVertices = value;
        }
        [Inline] final public function set useNumIndices ( value : int ) : void
        {
            _useNumIndices = value;
        }

		[Inline] final public function get numVertices():int { return _vertexData.numVertices; }
        public function set numVertices( value : int ):void
        {
            _vertexNumDirty = ( _vertexData.numVertices != value );
            _vertexData.numVertices = value;
        }
		[Inline] final public function get numIndices():int { return _indices.length; }
        public function set numIndices( value : int ):void
        {
            _indicesNumDirty = _indices.length != value;
            _indices.fixed = false;
            _indices.length = value;
            _indices.fixed = true;
        }

		/** The texture that is displayed on the quad. */		
		public function get texture():Texture { return _texture; }		
		
		/** Returns true if the quad (or any of its vertices) is non-white or non-opaque. */
		public function get tinted():Boolean { return _tinted; }
		
		public override function set alpha(value:Number):void
		{
			super.alpha = value;
			_tinted = value < 1.0 || (_vertexData != null && _vertexData.tinted);
		}
	
				
		/** Indicates if the rgb values are stored premultiplied with the alpha value; this can
		 *  affect the rendering. (Most developers don't have to care, though.) */
		public function get premultipliedAlpha():Boolean { return _vertexData.premultipliedAlpha; }

		/** Returns the color of the quad, or of vertex 0 if vertices have different colors. */
        public function get color():uint 
        { 
            return _vertexData != null && _vertexData.numVertices > 0 ? _vertexData.getColor(0) : 0xffffff; 
        }
        
        /** Sets the colors of all vertices to a certain value. */
        public function set color(value:uint):void 
        {
            _vertexData.setUniformColor(value);            
            
            if (value != 0xffffff || alpha != 1.0) _tinted = true;
            else _tinted = _vertexData.tinted;
        }
		
		public function get indices():Vector.<uint>
		{
			return _indices;
		}
		
		public function get vertices():VertexData
		{
			return _vertexData;
		}
		
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			if (_vertexData == null)
			{
				//设置它到很远的地方直到看不见
				resultRect.setTo(FAR_POINT, FAR_POINT, 0.0, 0.0);
				return resultRect;
			}
			
			if (targetSpace == this) // optimization
			{
				_vertexData.getPosition(3, sHelperPoint);
				resultRect.setTo(0.0, 0.0, sHelperPoint.x, sHelperPoint.y);
			}
			else if (targetSpace == parent && rotation == 0.0) // optimization
			{
				var scaleX:Number = this.scaleX;
				var scaleY:Number = this.scaleY;
				_vertexData.getPosition(3, sHelperPoint);
				resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
					sHelperPoint.x * scaleX, sHelperPoint.y * scaleY);
				if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
				if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
			}
			else
			{
				getTransformationMatrix(targetSpace, sHelperMatrix);
				_vertexData.getBounds(sHelperMatrix, 0, 4, resultRect);
			}
			
			return resultRect;
		}

        public function destroyBuffers () : void
        {
            var instance : Starling = Starling.current;
            if ( m_VertexBuffer != null )
            {
                instance.destroyVertexBuffer ( m_VertexBuffer );
                m_VertexBuffer = null;
            }

            if ( m_IndexBuffer != null )
            {
                instance.destroyIndexBuffer ( m_IndexBuffer );
                m_IndexBuffer = null;
            }
        }

        private function onContextCreated ( event : Object ) : void
        {
            destroyBuffers ();
        }
    }
}