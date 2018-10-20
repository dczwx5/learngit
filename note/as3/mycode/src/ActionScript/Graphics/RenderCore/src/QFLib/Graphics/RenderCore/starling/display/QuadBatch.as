// =================================================================================================
//
//	Starling Framework
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.RenderCore.starling.display
{
    import QFLib.Graphics.RenderCore.render.IGeometry;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.material.MSprite;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.core.starling_internal;
    import QFLib.Graphics.RenderCore.starling.errors.MissingContextError;
    import QFLib.Graphics.RenderCore.starling.events.Event;
    import QFLib.Graphics.RenderCore.starling.filters.ObjectFilter;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.textures.TextureSmoothing;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;

    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;

    use namespace starling_internal;
    
    /** Optimizes rendering of a number of quads with an identical state.
     * 
     *  <p>The majority of all rendered objects in Starling are quads. In fact, all the default
     *  leaf nodes of Starling are quads (the Image and Quad classes). The rendering of those 
     *  quads can be accelerated by a big factor if all quads with an identical state are sent 
     *  to the GPU in just one call. That's what the QuadBatch class can do.</p>
     *  
     *  <p>The 'flatten' method of the Sprite class uses this class internally to optimize its 
     *  rendering performance. In most situations, it is recommended to stick with flattened
     *  sprites, because they are easier to use. Sometimes, however, it makes sense
     *  to use the QuadBatch class directly: e.g. you can add one quad multiple times to 
     *  a quad batch, whereas you can only add it once to a sprite. Furthermore, this class
     *  does not dispatch <code>ADDED</code> or <code>ADDED_TO_STAGE</code> events when a quad
     *  is added, which makes it more lightweight.</p>
     *  
     *  <p>One QuadBatch object is bound to a specific render state. The first object you add to a 
     *  batch will decide on the QuadBatch's state, that is: its texture, its settings for 
     *  smoothing and blending, and if it's tinted (colored vertices and/or transparency). 
     *  When you reset the batch, it will accept a new state on the next added quad.</p> 
     *  
     *  <p>The class extends DisplayObject, but you can use it even without adding it to the
     *  display tree. Just call the 'renderCustom' method from within another render method,
     *  and pass appropriate values for transformation matrix, alpha and blend mode.</p>
     *
     *  @see Sprite  
     */ 
    public class QuadBatch extends DisplayObject implements IGeometry
    {
        /** The maximum number of quads that can be displayed by one QuadBatch. */
        public static const MAX_NUM_VERTICES:int = 65535;
        
        private static const QUAD_PROGRAM_NAME:String = "QB_q";
        private static var sColorHelper:Vector.<Number> = Vector.<Number>([1.0, 1.0, 1.0, 1.0]);
		        
        private var _numTriangles:int;
		private var _numVertices:int;
        protected var mSyncRequired:Boolean;
        private var mBatchable:Boolean;

        private var mTinted:Boolean;
        private var mTexture:Texture;
        private var mSmoothing:String;
        
        protected var mVertexBuffer:VertexBuffer3D;
        private var mIndexData:Vector.<uint>;
		private var _indexBufferSize:int;
        private var mIndexBuffer:IndexBuffer3D;
        
        /** The raw vertex data of the quad. After modifying its contents, call
         *  'onVertexDataChanged' to upload the changes to the vertex buffers. Don't change the
         *  size of this object manually; instead, use the 'capacity' property of the QuadBatch. */
        protected var mVertexData:VertexData;

        /** Helper objects. */
        public static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        private static var sRenderMatrix:Matrix3D = new Matrix3D();
        private static var sProgramNameCache:Dictionary = new Dictionary();
        
		public var _material:MSprite;
		
		public function setVertexBuffers():void
		{
            var instance:Starling = Starling.current;
            instance.setVertexBuffer(0, mVertexBuffer,	VertexData.POSITION_OFFSET,	Context3DVertexBufferFormat.FLOAT_2);
            instance.setVertexBuffer(1, mVertexBuffer,	VertexData.COLOR_OFFSET,	Context3DVertexBufferFormat.FLOAT_4);
			
			if (_material.hasTexture)
			{
                instance.setVertexBuffer(2, mVertexBuffer,	VertexData.TEXCOORD_OFFSET,	Context3DVertexBufferFormat.FLOAT_2);
			}
		}
		
		public function draw():int
		{
            var instance:Starling = Starling.current;
			if(mIndexBuffer !=null)
			{
                instance.drawTriangles(mIndexBuffer, 0, _numTriangles);
                instance.clearVertexBuffer(0);
                instance.clearVertexBuffer(1);
                instance.clearVertexBuffer(2);
				return 1;
			}
			else
			{
                instance.clearVertexBuffer(0);
                instance.clearVertexBuffer(1);
                instance.clearVertexBuffer(2);
				return 0;
			}
		}
		
        /** Creates a new QuadBatch instance with empty batch data. */
        public function QuadBatch()
        {
            mVertexData = new VertexData(0, true );
            mIndexData = new <uint>[];
            _numVertices = 0;
			_numTriangles = 0;
            mTinted = false;
            mSyncRequired = false;
            mBatchable = false;
			
			_material = new MSprite();
            
            // Handle lost context. We use the conventional event here (not the one from Starling)
            // so we're able to create a weak event listener; this avoids memory leaks when people 
            // forget to call "dispose" on the QuadBatch.
            Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, 
                                                      onContextCreated, false, 0, true);
        }
        
        /** Disposes vertex- and index-buffer. */
        public override function dispose():void
        {
            Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            destroyBuffers();
            
			if(mVertexData){
            	mVertexData.dispose();
				mVertexData = null;
			}
            mIndexData.length = 0;
            _numVertices = 0;
			_numTriangles = 0;
            
			if(_material){
				_material.dispose();
				_material = null;
			}
			
            super.dispose();
        }
		
		public function renderQueue():void
		{
			if (mSyncRequired)
                syncBuffers();

			var command:RenderCommand = RenderCommand.assign();
			command.geometry = this;
            command.matWorld2D = this.worldTransform;
//            if(_material.texture != null)
//            {
//                _material.pma = _material.texture.premultipliedAlpha;
//            }
            _material.pma = false;
            sColorHelper[3] = alpha;
            _material.tintColor = sColorHelper;
			command.material = _material;
			Starling.current.addToRender(command);
		}
		
        private function onContextCreated(event:Object):void
        {
			destroyBuffers();
			mSyncRequired = true;
        }
        
        /** Call this method after manually changing the contents of 'mVertexData'. */
        protected function onVertexDataChanged():void
        {
            mSyncRequired = true;
        }

        private function expand():void
        {
            var oldCapacity:int = this.capacity;
            this.capacity = oldCapacity < 8 ? 16 : oldCapacity * 2;
        }
        
        private function createBuffers():void
        {
            destroyBuffers();

            var numVertices:int = mVertexData.numVertices;
            if (numVertices == 0) return;

            var instance:Starling = Starling.current;
            if (!instance.contextValid)  throw new MissingContextError();

            mVertexBuffer = instance.createVertexBuffer(numVertices, VertexData.ELEMENTS_PER_VERTEX);
            instance.uploadVertexBufferData(mVertexBuffer, mVertexData.rawData, 0, numVertices);

            _indexBufferSize = mIndexData.length;
            mIndexBuffer = instance.createIndexBuffer(_indexBufferSize);
            instance.uploadIndexBufferData(mIndexBuffer, mIndexData, 0, mIndexData.length);
            
            mSyncRequired = false;
        }
        
        private function destroyBuffers():void
        {
            Starling.current.destroyVertexBuffer(mVertexBuffer);
            mVertexBuffer = null;
            Starling.current.destroyIndexBuffer(mIndexBuffer);
            mIndexBuffer = null;
        }

        /** Uploads the raw data of all batched quads to the vertex buffer. */
        protected function syncBuffers():void
        {
            var instance:Starling = Starling.current;
            if (mVertexBuffer == null)
            {
                createBuffers();
            }
            else
            {
                instance.uploadVertexBufferData(mVertexBuffer, mVertexData.rawData, 0, _numVertices);
				
				var totalIndices:int = _numTriangles * 3;
				if (totalIndices > _indexBufferSize) {
                    instance.destroyIndexBuffer(mIndexBuffer);

					_indexBufferSize = mIndexData.length;
					mIndexBuffer = instance.createIndexBuffer(_indexBufferSize);
				}

                instance.uploadIndexBufferData(mIndexBuffer, mIndexData, 0, _numTriangles * 3);
                mSyncRequired = false;
            }
        }
        
        /** Resets the batch. The vertex- and index-buffers remain their size, so that they
         *  can be reused quickly. */  
        public function reset():void
        {
            _numVertices = 0;
			_numTriangles = 0;
            mTexture = null;
            mSmoothing = null;
            mSyncRequired = true;
        }
        
        /** Adds an image to the batch. This method internally calls 'addQuad' with the correct
         *  parameters for 'texture' and 'smoothing'. */ 
        public function addImage(image:Image, parentAlpha:Number=1.0, modelViewMatrix:Matrix=null,
                                 blendMode:String=null):void
        {
            addQuad(image, parentAlpha, image.texture, image.smoothing, modelViewMatrix, blendMode);
        }
        
        /** Adds a quad to the batch. The first quad determines the state of the batch,
         *  i.e. the values for texture, smoothing and blendmode. When you add additional quads,  
         *  make sure they share that state (e.g. with the 'isStateChange' method), or reset
         *  the batch. */ 
        public function addQuad(quad:Quad, parentAlpha:Number=1.0, texture:Texture=null, 
                                smoothing:String=null, modelViewMatrix:Matrix=null, 
                                blendMode:String=null):void
        {
            if (modelViewMatrix == null)
                modelViewMatrix = quad.localTransform;
            
            var alpha:Number = parentAlpha * quad.alpha;
            var vertexID:int = _numVertices;
            
            if (_numVertices + 4 > mVertexData.numVertices) expand();
            if (_numVertices == 0) 
            {
                this.blendMode = blendMode ? blendMode : quad.blendMode;
                mTexture = texture;
                _material.mainTexture = texture; // new render process need to set the material's texture
                mTinted = texture ? (quad.tinted || parentAlpha != 1.0) : true;
                mSmoothing = smoothing;
                mVertexData.setPremultipliedAlpha(quad.premultipliedAlpha);
            }
            
            quad.copyVertexDataTransformedTo(mVertexData, vertexID, modelViewMatrix);
			setQuadIndices();
            mVertexData.scaleAlpha(vertexID, alpha, 4);

            mSyncRequired = true;
            _numVertices += 4;
			_numTriangles += 2;
        }
		        
        /** Adds another QuadBatch to this batch. Just like the 'addQuad' method, you have to
         *  make sure that you only add batches with an equal state. */
        public function addQuadBatch(quadBatch:QuadBatch, parentAlpha:Number=1.0, 
                                     modelViewMatrix:Matrix=null, blendMode:String=null):void
        {
            if (modelViewMatrix == null)
                modelViewMatrix = quadBatch.localTransform;
            
            var tinted:Boolean = quadBatch.mTinted || parentAlpha != 1.0;
            var alpha:Number = parentAlpha * quadBatch.alpha;
            var vertexID:int = _numVertices;
            var numVertices:int = quadBatch._numVertices;
            
            if (numVertices + _numVertices > capacity) capacity = numVertices + _numVertices;
            if (_numVertices == 0) 
            {
                this.blendMode = blendMode ? blendMode : quadBatch.blendMode;
                mTexture = quadBatch.mTexture;
                mTinted = tinted;
                mSmoothing = quadBatch.mSmoothing;
                mVertexData.setPremultipliedAlpha(quadBatch.mVertexData.premultipliedAlpha, false);
            }
            
            quadBatch.mVertexData.copyTransformedTo(mVertexData, vertexID, modelViewMatrix,
                                                    0, numVertices);
													
			var offset:int = _numTriangles * 3;
			var length:int = quadBatch.numTriangles * 3;
			
			for (var i:int = 0; i < length; i++)
			{
				mIndexData[offset + i] = quadBatch.mIndexData[i] + _numVertices;
			}
            
            mVertexData.scaleAlpha(vertexID, alpha, numVertices);
            
            mSyncRequired = true;
			_numVertices += numVertices;
			_numTriangles += quadBatch.numTriangles;
        }
		
		private function setQuadIndices():void {
			var offset:int = _numTriangles * 3;
			var base:int = _numVertices;
			
			mIndexData[offset] = base;
			mIndexData[offset + 1] = base + 1;
			mIndexData[offset + 2] = base + 2;
			mIndexData[offset + 3] = base + 1;
			mIndexData[offset + 4] = base + 3;
			mIndexData[offset + 5] = base + 2;
		}
        
        /** Indicates if specific quads can be added to the batch without causing a state change. 
         *  A state change occurs if the quad uses a different base texture, has a different 
         *  'tinted', 'smoothing', 'repeat' or 'blendMode' setting, or if the batch is full
         *  (one batch can contain up to 8192 quads). */
        public function isStateChange(tinted:Boolean, parentAlpha:Number, texture:Texture, smoothing:String, blendMode:String, numVertices:int=1):Boolean
        {
            if (_numVertices == 0) return false;

            if (_numVertices + numVertices > MAX_NUM_VERTICES) return true; // maximum buffer size
            else if (mTexture == null && texture == null) 
                return this.blendMode != blendMode;
            else if (mTexture != null && texture != null)
                return mTexture.base != texture.base ||
                       mTexture.repeat != texture.repeat ||
                       mSmoothing != smoothing ||
                       mTinted != (tinted || parentAlpha != 1.0) ||
                       this.blendMode != blendMode
            else return true;
        }
        
        // utility methods for manual vertex-modification
        
        /** Transforms the vertices of a certain quad by the given matrix. */
        public function transformQuad(quadID:int, matrix:Matrix):void
        {
            mVertexData.transformVertex(quadID * 4, matrix, 4);
            mSyncRequired = true;
        }
        
        /** Returns the color of one vertex of a specific quad. */
        public function getVertexColor(quadID:int, vertexID:int):uint
        {
            return mVertexData.getColor(quadID * 4 + vertexID);
        }
        
        /** Updates the color of one vertex of a specific quad. */
        public function setVertexColor(quadID:int, vertexID:int, color:uint):void
        {
            mVertexData.setColor(quadID * 4 + vertexID, color);
            mSyncRequired = true;
        }
        
        /** Returns the alpha value of one vertex of a specific quad. */
        public function getVertexAlpha(quadID:int, vertexID:int):Number
        {
            return mVertexData.getAlpha(quadID * 4 + vertexID);
        }
        
        /** Updates the alpha value of one vertex of a specific quad. */
        public function setVertexAlpha(quadID:int, vertexID:int, alpha:Number):void
        {
            mVertexData.setAlpha(quadID * 4 + vertexID, alpha);
            mSyncRequired = true;
        }
        
        /** Returns the color of the first vertex of a specific quad. */
        public function getQuadColor(quadID:int):uint
        {
            return mVertexData.getColor(quadID * 4);
        }
        
        /** Updates the color of a specific quad. */
        public function setQuadColor(quadID:int, color:uint):void
        {
            for (var i:int=0; i<4; ++i)
                mVertexData.setColor(quadID * 4 + i, color);
            
            mSyncRequired = true;
        }
        
        /** Returns the alpha value of the first vertex of a specific quad. */
        public function getQuadAlpha(quadID:int):Number
        {
            return mVertexData.getAlpha(quadID * 4);
        }
        
        /** Updates the alpha value of a specific quad. */
        public function setQuadAlpha(quadID:int, alpha:Number):void
        {
            for (var i:int=0; i<4; ++i)
                mVertexData.setAlpha(quadID * 4 + i, alpha);
            
            mSyncRequired = true;
        }
        
        /** Calculates the bounds of a specific quad, optionally transformed by a matrix.
         *  If you pass a 'resultRect', the result will be stored in this rectangle
         *  instead of creating a new object. */
        public function getQuadBounds(quadID:int, transformationMatrix:Matrix=null,
                                      resultRect:Rectangle=null):Rectangle
        {
            return mVertexData.getBounds(transformationMatrix, quadID * 4, 4, resultRect);
        }
        
        // display object methods
        
        /** @inheritDoc */
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null) resultRect = new Rectangle();
            
            var transformationMatrix:Matrix = targetSpace == this ?
                null : getTransformationMatrix(targetSpace, sHelperMatrix);
            
            return mVertexData.getBounds(transformationMatrix, 0, _numVertices, resultRect);
        }
        
        /** @inheritDoc */
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
            if (_numVertices)
            {
                if (mBatchable)
				{
                    support.batchQuadBatch(this, parentAlpha);
				}
                else
                {
                    support.finishQuadBatch();
                    support.raiseDrawCount();
					
					renderQueue();
                }
            }
        }
        
        // compilation (for flattened sprites)
        
        /** Analyses an object that is made up exclusively of quads (or other containers)
         *  and creates a vector of QuadBatch objects representing it. This can be
         *  used to render the container very efficiently. The 'flatten'-method of the Sprite 
         *  class uses this method internally. */
        public static function compile(object:DisplayObject, 
                                       quadBatches:Vector.<QuadBatch>):void
        {
            compileObject(object, quadBatches, -1, new Matrix());
        }
        
        private static function compileObject(object:DisplayObject,
                                              quadBatches:Vector.<QuadBatch>,
                                              quadBatchID:int,
                                              transformationMatrix:Matrix,
                                              alpha:Number=1.0,
                                              blendMode:String=null,
                                              ignoreCurrentFilter:Boolean=false):int
        {
            var i:int;
            var quadBatch:QuadBatch;
            var isRootObject:Boolean = false;
            var objectAlpha:Number = object.alpha;
            
            var container:DisplayObjectContainer = object as DisplayObjectContainer;
            var quad:Quad = object as Quad;
            var batch:QuadBatch = object as QuadBatch;
            var filter:ObjectFilter = object.objectFilter;
            
            if (quadBatchID == -1)
            {
                isRootObject = true;
                quadBatchID = 0;
                objectAlpha = 1.0;
                blendMode = object.blendMode;
                ignoreCurrentFilter = true;
                if (quadBatches.length == 0) quadBatches.push(new QuadBatch());
                else quadBatches[0].reset();
            }

            /**滤镜结构被修改了，Object使用滤镜加入到QuadBatch后期修复 Date:2017-05-18 */
/*
            if (filter.itemCount > 0 && !ignoreCurrentFilter)
            {
                quadBatchID = compileObject(filter.compile(object),
                        quadBatches, quadBatchID,
                        transformationMatrix, alpha, blendMode);
            }
            else
*/
            if (container)
            {
                var numChildren:int = container.numChildren;
                var childMatrix:Matrix = new Matrix();
                
                for (i=0; i<numChildren; ++i)
                {
                    var child:DisplayObject = container.getChildAt(i);
                    if (child.hasVisibleArea)
                    {
                        var childBlendMode:String = child.blendMode == BlendMode.AUTO ?
                                                    blendMode : child.blendMode;
                        childMatrix.copyFrom(transformationMatrix);
                        RenderSupport.transformMatrixForObject(childMatrix, child);
                        quadBatchID = compileObject(child, quadBatches, quadBatchID, childMatrix, 
                                                    alpha*objectAlpha, childBlendMode);
                    }
                }
            }
            else if (quad || batch)
            {
                var texture:Texture;
                var smoothing:String;
                var tinted:Boolean;
                var numVertices:int;
                
                if (quad)
                {
                    var image:Image = quad as Image;
                    texture = image ? image.texture : null;
                    smoothing = image ? image.smoothing : null;
                    tinted = quad.tinted;
                    numVertices = 4;
                }
                else
                {
                    texture = batch.mTexture;
                    smoothing = batch.mSmoothing;
                    tinted = batch.mTinted;
                    numVertices = batch._numVertices;
                }
                
                quadBatch = quadBatches[quadBatchID];
                
                if (quadBatch.isStateChange(tinted, alpha*objectAlpha, texture, 
                                            smoothing, blendMode, numVertices))
                {
                    quadBatchID++;
                    if (quadBatches.length <= quadBatchID) quadBatches.push(new QuadBatch());
                    quadBatch = quadBatches[quadBatchID];
                    quadBatch.reset();
                }
                
                if (quad)
                    quadBatch.addQuad(quad, alpha, texture, smoothing, transformationMatrix, blendMode);
                else
                    quadBatch.addQuadBatch(batch, alpha, transformationMatrix, blendMode);
            }
            else
            {
                throw new Error("Unsupported display object: " + getQualifiedClassName(object));
            }
            
            if (isRootObject)
            {
                // remove unused batches
                for (i=quadBatches.length-1; i>quadBatchID; --i)
                    quadBatches.pop().dispose();
            }
            
            return quadBatchID;
        }
        
        // properties
        
        /** Returns the number of vertices that have been added to the batch. */
        public function get numVertices():int { return _numVertices; }
		
		/** Returns the number of triangles that have been added to the batch. */
        public function get numTriangles():int { return _numTriangles; }
        
        /** Indicates if any vertices have a non-white color or are not fully opaque. */
        public function get tinted():Boolean { return mTinted; }
        
        /** The texture that is used for rendering, or null for pure quads. Note that this is the
         *  texture instance of the first added quad; subsequently added quads may use a different
         *  instance, as long as the base texture is the same. */ 
        public function get texture():Texture { return mTexture; }
		public function set texture(v:Texture):void { mTexture = v; }
        
        /** The TextureSmoothing used for rendering. */
        public function get smoothing():String { return mSmoothing; }
        
        /** Indicates if the rgb values are stored premultiplied with the alpha value. */
        public function get premultipliedAlpha():Boolean { return mVertexData.premultipliedAlpha; }

        /** Indicates if the batch itself should be batched on rendering. This makes sense only
         *  if it contains only a small number of quads (we recommend no more than 16). Otherwise,
         *  the CPU costs will exceed any gains you get from avoiding the additional draw call.
         *  @default false */
        public function get batchable():Boolean { return mBatchable; }
        public function set batchable(value:Boolean):void { mBatchable = value; } 
        
        /** Indicates the number of vertices for which space is allocated (vertex- and index-buffers).
         *  If you add more quads than what fits into the current capacity, the QuadBatch is
         *  expanded automatically. However, if you know beforehand how many vertices you need,
         *  you can manually set the right capacity with this method. */
        public function get capacity():int { return mVertexData.numVertices; }
        public function set capacity(value:int):void
        {
            var oldCapacity:int = capacity;
            
            if (value == oldCapacity) return;
            else if (value == 0) throw new Error("Capacity must be > 0");
            else if (value > MAX_NUM_VERTICES) value = MAX_NUM_VERTICES;
            if (_numVertices > value) _numVertices = value;
            
            mVertexData.numVertices = value;
			// for quads
            mIndexData.length += ((value - oldCapacity) >> 1) * 3;

            destroyBuffers();
            mSyncRequired = true;
        }
		
		// program management
        
        public function getTexture():Texture
        {
            return mTexture;
        }
        
        private static function getImageProgramName(tinted:Boolean, mipMap:Boolean=true, 
                                                    repeat:Boolean=false, format:String="compressedAlpha",
                                                    smoothing:String="bilinear"):String
        {
            var bitField:uint = 0;
            
            if (tinted) bitField |= 1;
            if (mipMap) bitField |= 1 << 1;
            if (repeat) bitField |= 1 << 2;
            
            if (smoothing == TextureSmoothing.NONE)
                bitField |= 1 << 3;
            else if (smoothing == TextureSmoothing.TRILINEAR)
                bitField |= 1 << 4;
            
            if (format == Context3DTextureFormat.COMPRESSED)
                bitField |= 1 << 5;
            else if (format == "compressedAlpha")
                bitField |= 1 << 6;
			
            var name:String = sProgramNameCache[bitField];
            
            if (name == null)
            {
                name = "QB_i." + bitField.toString(16);
                sProgramNameCache[bitField] = name;
            }
            
            return name;
        }
    }
}