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

import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
import QFLib.Graphics.RenderCore.starling.core.Starling;
import QFLib.Graphics.RenderCore.starling.textures.SubTexture;
import QFLib.Graphics.RenderCore.starling.textures.Texture;
import QFLib.Graphics.RenderCore.starling.textures.TextureSmoothing;
import QFLib.Graphics.RenderCore.starling.utils.VertexData;

import flash.display.Bitmap;
import flash.display3D.Context3DVertexBufferFormat;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/** An Image is a quad with a texture mapped onto it.
     *  
     *  <p>The Image class is the Starling equivalent of Flash's Bitmap class. Instead of 
     *  BitmapData, Starling uses textures to represent the pixels of an image. To display a 
     *  texture, you have to map it onto a quad - and that's what the Image class is for.</p>
     *  
     *  <p>As "Image" inherits from "Quad", you can give it a color. For each pixel, the resulting  
     *  color will be the result of the multiplication of the color of the texture with the color of 
     *  the quad. That way, you can easily tint textures with a certain color. Furthermore, images 
     *  allow the manipulation of texture coordinates. That way, you can move a texture inside an 
     *  image without changing any vertex coordinates of the quad. You can also use this feature
     *  as a very efficient way to create a rectangular mask.</p> 
     *  
     *  @see QFLib.Graphics.RenderCore.starling.textures.Texture
     *  @see Quad
     */ 
    public class Image extends Quad
    {
        private var mTexture:Texture;
        private var mVertexDataCache:VertexData;
        private var mSmoothing:String;
		private var mUVAnimationEnable:Boolean;
        private var mVertexDataCacheInvalid:Boolean;
        
        /** Creates a quad with a texture mapped onto it. */
        public function Image(texture:Texture)
        {
            var pma:Boolean = false;
			// default empty texture width = 128, height = 128
            var width:Number = 128;
            var height:Number = 128;
            if (texture)
            {
                var frame:Rectangle = texture.frame;
                width = frame ? frame.width : texture.width;
                height = frame ? frame.height : texture.height;
                pma = texture.premultipliedAlpha;
            }

            super(width, height, 0xffffff, pma);

            mVertexData.setTexCoords(0, 0.0, 0.0);
            mVertexData.setTexCoords(1, 1.0, 0.0);
            mVertexData.setTexCoords(2, 0.0, 1.0);
            mVertexData.setTexCoords(3, 1.0, 1.0);

            mTexture = texture;
            mSmoothing = TextureSmoothing.BILINEAR;

            mVertexDataCache = new VertexData(4, pma);
            mVertexDataCacheInvalid = true;

            mMaterial.mainTexture = mTexture;
            mMaterial.pma = pma;
        }
        
		override public function dispose():void{
			mTexture = null;
			mSmoothing = null;
			if(mVertexDataCache){
				mVertexDataCache.dispose();
				mVertexDataCache = null;
			}
			
			super.dispose();
		}

        public function get uvAnimationEnable():Boolean { return mUVAnimationEnable; }
        public function set uvAnimationEnable( enable:Boolean):void
        {
            mUVAnimationEnable = enable;
            mMaterial.uvAnimationEnable = enable;
        }

        public function updateMargin(marginX:Number=0.01, marginY:Number=0.01):void
        {
            mMaterial.updateMargin(marginX, marginY);
        }

        public function updateTiling(tilingX:int=0, tilingY:int=0, offsetX:Number=0.0, offsetY:Number=0.0):void
        {
            mMaterial.updateTiling(tilingX, tilingY, offsetX, offsetY);
        }

        public function updateOffsetUV(offsetU:Number=0.0, offsetV:Number=0.0):void
        {
            mMaterial.updateOffsetUV(offsetU, offsetV);
        }

        /** Creates an Image with a texture that is created from a bitmap object. */
        public static function fromBitmap(bitmap:Bitmap, generateMipMaps:Boolean=true, 
                                          scale:Number=1):Image
        {
            return new Image(Texture.fromBitmap(bitmap, generateMipMaps, false, scale));
        }
        
        /** @inheritDoc */
        protected override function onVertexDataChanged():void
        {
            mVertexDataCacheInvalid = true;
            mIsDirty = true;
        }
        
        /** Readjusts the dimensions of the image according to its current texture. Call this method 
         *  to synchronize image and texture size after assigning a texture with a different size.*/
        public function readjustSize():void
        {
            var frame:Rectangle = texture.frame;
            var width:Number  = frame ? frame.width  : texture.width;
            var height:Number = frame ? frame.height : texture.height;
            
            mVertexData.setPosition(0, 0.0, 0.0);
            mVertexData.setPosition(1, width, 0.0);
            mVertexData.setPosition(2, 0.0, height);
            mVertexData.setPosition(3, width, height);

            onVertexDataChanged();
        }

        /** Sets the position of a vertex */
        public function setVertexPosition( vertexID : int, pos : Point) : void
        {
            mVertexData.setPosition( vertexID, pos.x, pos.y );
            onVertexDataChanged();
        }

        /** Sets the position of a vertex */
        public function setVertexPositionTo( vertexID : int, x : Number, y : Number ) : void
        {
            mVertexData.setPosition( vertexID, x, y );
            onVertexDataChanged();
        }

        /** Gets the position of a vertex
         *  If you pass a 'resultPoint', the result will be stored in this point instead of
         *  creating a new object.*/
        public function getVertexPosition( vertexID:int, resultPoint : Point = null) : Point
        {
            if( resultPoint == null ) resultPoint = new Point();
            mVertexData.getPosition(vertexID, resultPoint);
            return resultPoint;
        }

        /** Sets the texture coordinates of a vertex. Coordinates are in the range [0, 1]. */
        public function setTexCoords(vertexID:int, coords:Point):void
        {
            mVertexData.setTexCoords(vertexID, coords.x, coords.y);
            onVertexDataChanged();
        }
        
        /** Sets the texture coordinates of a vertex. Coordinates are in the range [0, 1]. */
        public function setTexCoordsTo(vertexID:int, u:Number, v:Number):void
        {
            mVertexData.setTexCoords(vertexID, u, v);
            onVertexDataChanged();
        }
        
        /** Gets the texture coordinates of a vertex. Coordinates are in the range [0, 1]. 
         *  If you pass a 'resultPoint', the result will be stored in this point instead of 
         *  creating a new object.*/
        public function getTexCoords(vertexID:int, resultPoint:Point=null):Point
        {
            if (resultPoint == null) resultPoint = new Point();
            mVertexData.getTexCoords(vertexID, resultPoint);
            return resultPoint;
        }
        
        /** Copies the raw vertex data to a VertexData instance.
         *  The texture coordinates are already in the format required for rendering. */ 
        public override function copyVertexDataTo(targetData:VertexData, targetVertexID:int=0):void
        {
            copyVertexDataTransformedTo(targetData, targetVertexID, null);
        }
        
        /** Transforms the vertex positions of the raw vertex data by a certain matrix
         *  and copies the result to another VertexData instance.
         *  The texture coordinates are already in the format required for rendering. */
        public override function copyVertexDataTransformedTo(targetData:VertexData,
                                                             targetVertexID:int=0,
                                                             matrix:Matrix=null):void
        {
            if (mVertexDataCacheInvalid && mTexture)
            {
                mVertexDataCacheInvalid = false;
                mVertexData.copyTo(mVertexDataCache);
                mTexture.adjustVertexData(mVertexDataCache, 0, 4);
            }
            
            mVertexDataCache.copyTransformedTo(targetData, targetVertexID, matrix, 0, 4);
        }
		        
        /** The texture that is displayed on the quad. */
        public function get texture():Texture { return mTexture; }
        public function set texture(value:Texture):void 
        { 
            if (value == null)
            {
                mTexture = value;
            }
            else if (value != mTexture)
            {
                mTexture = value;
				mMaterial.mainTexture = value;
				mMaterial.pma = mTexture.premultipliedAlpha;
                mVertexData.setPremultipliedAlpha(mTexture.premultipliedAlpha);
                mVertexDataCache.setPremultipliedAlpha(mTexture.premultipliedAlpha, false);
				readjustSize();
            }
        }
        
        /** The smoothing filter that is used for the texture. 
        *   @default bilinear
        *   @see QFLib.Graphics.RenderCore.starling.textures.TextureSmoothing */
        public function get smoothing():String { return mSmoothing; }
        public function set smoothing(value:String):void 
        {
            if (TextureSmoothing.isValid(value))
                mSmoothing = value;
            else
                throw new ArgumentError("Invalid smoothing mode: " + value);
        }
        
        /** @inheritDoc */
        public override function render(support:RenderSupport, parentAlpha:Number):void
        {
            var subTex : SubTexture = mTexture as SubTexture;
            if ( subTex != null )
            {
                var rootTex : Texture = subTex.root;
                if ( rootTex != null && ( rootTex.disposed || !rootTex.uploaded || rootTex.base == null ) )
                    return;
            }
            else if ( mTexture != null && ( mTexture.disposed || !mTexture.uploaded || mTexture.base == null ) )
                return;

            if (mVertexDataCacheInvalid)
            {
                mVertexDataCacheInvalid = false;
                mVertexData.copyTo(mVertexDataCache);

                if( mTexture != null ) mTexture.adjustVertexData(mVertexDataCache, 0, 4);
            }

            super.render(support, parentAlpha);
        }

        override public function setVertexBuffers() : void
        {
            var pStarling : Starling = Starling.current;
            pStarling.setVertexBuffer ( 0, _vertextBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
            pStarling.setVertexBuffer ( 1, _vertextBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4 );
            if ( mTexture != null )
                pStarling.setVertexBuffer ( 2, _vertextBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
        }

        override public function draw() : int
        {
            var pStarling : Starling = Starling.current;
            pStarling.drawTriangles ( _indexBuffer, 0, 2 );
            pStarling.clearVertexBuffer ( 0 );
            pStarling.clearVertexBuffer ( 1 );
            if ( mTexture != null )
                pStarling.clearVertexBuffer ( 2 );
            return 1;
        }

        override protected function uploadVertexBuffer () : void
        {
            var pStarling : Starling = Starling.current;
            if ( mIsStatic )
            {
                if ( !mIsDirty ) return;
                pStarling.uploadVertexBufferData ( _vertextBuffer, mVertexDataCache.rawData, 0, 4 );
                mIsDirty = false;
            }
            else
            {
                pStarling.uploadVertexBufferData ( _vertextBuffer, mVertexDataCache.rawData, 0, 4 );
            }
        }
    }
}