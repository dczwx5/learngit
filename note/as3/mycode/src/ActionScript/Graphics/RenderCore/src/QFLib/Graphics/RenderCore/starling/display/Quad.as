// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.RenderCore.starling.display
{

    import QFLib.Graphics.RenderCore.render.IGeometry;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.material.MSprite;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.core.StaticBuffers;
    import QFLib.Graphics.RenderCore.starling.core.starling_internal;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;

    import flash.display3D.Context3DBufferUsage;

    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    /** A Quad represents a rectangle with a uniform color or a color gradient.
     *  
     *  <p>You can set one color per vertex. The colors will smoothly fade into each other over the area
     *  of the quad. To display a simple linear color gradient, assign one color to vertices 0 and 1 and 
     *  another color to vertices 2 and 3. </p> 
     *
     *  <p>The indices of the vertices are arranged like this:</p>
     *  
     *  <pre>
     *  0 - 1
     *  | / |
     *  2 - 3
     *  </pre>
     * 
     *  @see Image
     */
    public class Quad extends DisplayObject implements IGeometry
    {
		protected static var _indices:Vector.<uint> = Vector.<uint>([0,1,2,1,3,2]);

        protected var _vertextBuffer : VertexBuffer3D = null;
        protected var _indexBuffer : IndexBuffer3D = null;

        /** The raw vertex data of the quad. */
        protected var mVertexData:VertexData;
		protected var mMaterial:MSprite = new MSprite();
		protected var mTintColor:Vector.<Number> = Vector.<Number>([1.0, 1.0, 1.0, 1.0]);
        protected var mMaskColor:Vector.<Number> = Vector.<Number>([0.0, 0.0, 0.0, 0.0]);
        protected var mIsStatic : Boolean = true;
        protected var mIsDirty : Boolean = true;

        private var mTinted:Boolean;

        /** Creates a quad with a certain size and color. The last parameter controls if the 
         *  alpha value should be premultiplied into the color values on rendering, which can
         *  influence blending output. You can use the default value in most cases.  */
        public function Quad(width:Number, height:Number, color:uint=0xffffff,
                             premultipliedAlpha:Boolean=true)
        {
            if (width == 0.0 || height == 0.0)
                throw new ArgumentError("Invalid size: width and height must not be zero");

            mTinted = color != 0xffffff;
			
			if(mTinted)
			{
				mTintColor[3] = finalAlpha;
			}
			
			mMaterial.tintColor = mTintColor;
            mMaterial.pma = premultipliedAlpha;
            mVertexData = new VertexData(4, premultipliedAlpha);
            mVertexData.setPosition(0, 0.0, 0.0);
            mVertexData.setPosition(1, width, 0.0);
            mVertexData.setPosition(2, 0.0, height);
            mVertexData.setPosition(3, width, height);
            mVertexData.setUniformColor(color);

            onVertexDataChanged();

            Starling.addContext3DCreateCallback( this, onContextCreated );
        }
		
		override public function dispose():void
        {
            Starling.removeContext3DCreateCallback( this, onContextCreated );
            destroyBuffers ();
            if ( mVertexData )
            {
                mVertexData.dispose();
                mVertexData = null;
            }

            if ( mMaterial )
            {
                mMaterial.dispose();
                mMaterial = null;
            }

            if ( mTintColor )
            {
                mTintColor.length = 0;
                mTintColor = null;
            }

            super.dispose();
		}

        public function get isStatic () : Boolean { return mIsStatic; }
        public function set isStatic ( value : Boolean ) : void { mIsStatic = value; }

		public override function set blendMode(value:String):void 
		{
			mMaterial.blendMode = value;
			super.blendMode = value;
		}
        
        /** Call this method after manually changing the contents of 'mVertexData'. */
        protected function onVertexDataChanged():void
        {
            // override in subclasses, if necessary
            mIsDirty = true;
        }
        
        /** @inheritDoc */
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null) resultRect = new Rectangle();
            
            if (targetSpace == this) // optimization
            {
//                mVertexData.getPosition(3, sHelperPoint);
//                resultRect.setTo(0.0, 0.0, sHelperPoint.x, sHelperPoint.y);
                mVertexData.getBounds(null, 0, 4, resultRect);
            }
            else if (targetSpace == parent && rotation == 0.0) // optimization
            {
                var scaleX:Number = this.scaleX;
                var scaleY:Number = this.scaleY;
                mVertexData.getPosition(3, sHelperPoint);
                resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
                                 sHelperPoint.x * scaleX, sHelperPoint.y * scaleY);
                if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
                if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
            }
            else
            {
                getTransformationMatrix(targetSpace, sHelperMatrix);
                mVertexData.getBounds(sHelperMatrix, 0, 4, resultRect);
            }
            
            return resultRect;
        }
        
        /** Returns the color of a vertex at a certain index. */
        public function getVertexColor(vertexID:int):uint
        {
            return mVertexData.getColor(vertexID);
        }
        
        /** Sets the color of a vertex at a certain index. */
        public function setVertexColor(vertexID:int, color:uint):void
        {
            mVertexData.setColor(vertexID, color);
            onVertexDataChanged();
			
			mTinted = color != 0xffffff || finalAlpha != 1.0 || mVertexData.tinted;
        }
        
        /** Returns the alpha value of a vertex at a certain index. */
        public function getVertexAlpha(vertexID:int):Number
        {
            return mVertexData.getAlpha(vertexID);
        }
        
        /** Sets the alpha value of a vertex at a certain index. */
        public function setVertexAlpha(vertexID:int, alpha:Number):void
        {
            mVertexData.setAlpha(vertexID, alpha);
            onVertexDataChanged();
            
			mTinted = alpha != 1.0 || finalAlpha != 1.0 || mVertexData.tinted;
        }
        
        /** Returns the color of the quad, or of vertex 0 if vertices have different colors. */
        public function get verticesColor():uint
        { 
            return mVertexData.getColor(0); 
        }
        
        /** Sets the colors of all vertices to a certain value. */
        public function set verticesColor( value:uint):void
        {
            mVertexData.setUniformColor(value);
            onVertexDataChanged();
			
			mTinted = value != 0xffffff || finalAlpha != 1.0 || mVertexData.tinted;
        }
        
        /** @inheritDoc **/
        public override function set alpha(value:Number):void
        {
			if (alpha != value)
			{
	            super.alpha = value;
			}
        }

        public function setColor ( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            if ( !masking )
            {
                mTintColor[ 0 ] = r;
                mTintColor[ 1 ] = g;
                mTintColor[ 2 ] = b;
                mTintColor[ 3 ] = this.alpha = alpha;
                mMaskColor[ 3 ] = 0.0;
            }
            else
            {
                mMaskColor[ 0 ] = r;
                mMaskColor[ 1 ] = g;
                mMaskColor[ 2 ] = b;
                mMaskColor[ 3 ] = alpha;
            }

            mMaterial.tintColor = mTintColor;
            mMaterial.maskColor = mMaskColor;
        }
        public function resetColor():void
        {
            mMaskColor[0] = mMaskColor[1] = mMaskColor[2] = 0.0;
            mMaskColor[3] = 0.0;
            this.alpha = mTintColor[0] = mTintColor[1] = mTintColor[2] = mTintColor[3] = 1.0;

            mMaterial.tintColor = mTintColor;
            mMaterial.maskColor = mMaskColor;
        }


        /** Returns true if the quad (or any of its vertices) is non-white or non-opaque. */
        public function get tinted():Boolean { return mTinted; }

        /** Indicates if the rgb values are stored premultiplied with the alpha value; this can
         *  affect the rendering. (Most developers don't have to care, though.) */
        public function get premultipliedAlpha():Boolean { return mVertexData.premultipliedAlpha; }

        /** Copies the raw vertex data to a VertexData instance. */
        public function copyVertexDataTo(targetData:VertexData, targetVertexID:int=0):void
        {
            mVertexData.copyTo(targetData, targetVertexID);
        }

        /** Transforms the vertex positions of the raw vertex data by a certain matrix and
         *  copies the result to another VertexData instance. */
        public function copyVertexDataTransformedTo(targetData:VertexData, targetVertexID:int=0,
                                                    matrix:Matrix=null):void
        {
            mVertexData.copyTransformedTo(targetData, targetVertexID, matrix, 0, 4);
        }
		        
        /** @inheritDoc */
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
			if (finalAlphaDirty)
			{
				applyAlpha();
			}

            syncBuffers ();
			mMaterial.parentAlpha = parentAlpha;
			var rcmd:RenderCommand = genRenderCommand();
			Starling.current.addToRender(rcmd);
        }


        public function setVertexBuffers() : void
        {
            var pStarling : Starling = Starling.current;
            pStarling.setVertexBuffer ( 0, _vertextBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
            pStarling.setVertexBuffer ( 1, _vertextBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4 );
        }

        public function draw() : int
        {
            var pStarling : Starling = Starling.current;
            pStarling.drawTriangles ( _indexBuffer, 0, 2 );
            pStarling.clearVertexBuffer ( 0 );
            pStarling.clearVertexBuffer ( 1 );
            return 1;
        }

        protected function syncBuffers () : void
        {
            var pStarling : Starling = Starling.current;
            if ( _vertextBuffer == null )
            {
                if ( mIsStatic )
                {
                    _vertextBuffer = pStarling.createVertexBuffer ( 4, 8, Context3DBufferUsage.DYNAMIC_DRAW );
                }
                else
                {
                    _vertextBuffer = StaticBuffers.getInstance().imgStaticVertexBuffer;
                }
            }
            else
            {
                var staticBuf : VertexBuffer3D = StaticBuffers.getInstance().imgStaticVertexBuffer;
                if ( !mIsStatic && _vertextBuffer != staticBuf )
                {
                    pStarling.destroyVertexBuffer ( _vertextBuffer );
                    _vertextBuffer = staticBuf;
                }
                else if ( mIsStatic && _vertextBuffer == staticBuf )
                {
                    _vertextBuffer = pStarling.createVertexBuffer (4, 8, Context3DBufferUsage.DYNAMIC_DRAW );
                }
            }

            uploadVertexBuffer ();
            if ( _indexBuffer == null ) _indexBuffer = StaticBuffers.getInstance().imgStaticIndexBuffer;
        }

        protected function uploadVertexBuffer () : void
        {
            var pStarling : Starling = Starling.current;
            if ( mIsStatic )
            {
                if ( !mIsDirty ) return;
                pStarling.uploadVertexBufferData ( _vertextBuffer, mVertexData.rawData, 0, 4 );
                mIsDirty = false;
            }
            else
            {
                pStarling.uploadVertexBufferData ( _vertextBuffer, mVertexData.rawData, 0, 4 );
            }
        }

        protected function genRenderCommand():RenderCommand
		{
			var rcmd:RenderCommand = RenderCommand.assign(worldTransform);
            rcmd.geometry = this;
			rcmd.material = mMaterial;
			return rcmd;
		}
		
		protected function applyAlpha():void
		{
            var _finalAlpha:Number = finalAlpha;
            mTinted = _finalAlpha < 1.0 ? true : mVertexData.tinted;
			if(mTinted)
				mTintColor[3] = _finalAlpha;
			else
				mTintColor[3] = 1.0;

			mMaterial.tintColor = mTintColor;
		}

        private function onContextCreated ( event : Object ) : void
        {
            destroyBuffers ();
        }

        private function destroyBuffers () : void
        {
            var pStarling : Starling = Starling.current;
            var staticBuf : VertexBuffer3D = StaticBuffers.getInstance().imgStaticVertexBuffer;
            if ( _vertextBuffer != null && _vertextBuffer != staticBuf )
            {
                pStarling.destroyVertexBuffer ( _vertextBuffer );
            }
            _vertextBuffer = null;
            _indexBuffer = null;
            mIsDirty = true;
        }
    }
}