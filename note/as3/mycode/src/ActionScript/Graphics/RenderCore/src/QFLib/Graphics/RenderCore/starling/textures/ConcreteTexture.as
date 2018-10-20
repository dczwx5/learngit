// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.RenderCore.starling.textures
{
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.core.starling_internal;
    import QFLib.Graphics.RenderCore.starling.errors.MissingContextError;
    import QFLib.Graphics.RenderCore.starling.events.Event;
    import QFLib.Graphics.RenderCore.starling.utils.Color;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.textures.TextureBase;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import mx.utils.NameUtil;

    use namespace starling_internal;
	
	/** A ConcreteTexture wraps a Stage3D texture object, storing the properties of the texture. */
	public class ConcreteTexture extends Texture
	{
		private var mBase:TextureBase;
		private var mFormat:String;
		private var mWidth:int;
		private var mHeight:int;
		private var mMipMapping:Boolean;
		private var mPremultipliedAlpha:Boolean;
		private var mOptimizedForRenderTexture:Boolean;
		private var mScale:Number;
		private var mRepeat:Boolean;
		private var mOnRestore:Function;
		private var mDataUploaded:Boolean;
		
		/** helper object */
		private static var sOrigin:Point = new Point();
		private static var sMatrix:Matrix = new Matrix();
		
		public static var Stastics:Object = new Object();
		public static var EnableStackTrace:Boolean = false;
		protected var mUniqueName:String;
		
		/** Creates a ConcreteTexture object from a TextureBase, storing information about size,
		 *  mip-mapping, and if the channels contain premultiplied alpha values. */
		public function ConcreteTexture(format:String, width:int, height:int,
										mipMapping:Boolean, premultipliedAlpha:Boolean,
										optimizedForRenderTexture:Boolean=false,
										scale:Number=1, repeat:Boolean=false)
		{
			mScale = scale <= 0 ? 1.0 : scale;
			mFormat = format;
			mWidth = width;
			mHeight = height;
			mMipMapping = mipMapping;
			mPremultipliedAlpha = premultipliedAlpha;
			mOptimizedForRenderTexture = optimizedForRenderTexture;
			mRepeat = repeat;
			mOnRestore = null;
			mDataUploaded = false;
			
			if (Starling.current.contextValid)
			{
				createBaseIfNull();
			}
			
			if (EnableStackTrace)
			{
				mUniqueName = NameUtil.createUniqueName(this);
				Stastics[mUniqueName] = new Error().getStackTrace();
			}
		}
		
		private function createBaseIfNull():void
		{
			if (mBase == null)
			{
				mBase = Starling.current.createTexture(mWidth, mHeight, mFormat, mOptimizedForRenderTexture);
			}
		}
		
		/** Disposes the TextureBase object. */
		public override function dispose():void
		{
			if (mBase)
			{
				mBase.dispose();
				mBase = null;
			}
			
			this.onRestore = null; // removes event listener 
			super.dispose();
			
			if (EnableStackTrace)
			{
				delete Stastics[mUniqueName];
			}
		}
		
		// texture data upload
		
		/** Uploads a bitmap to the texture. The existing contents will be replaced.
		 *  If the size of the bitmap does not match the size of the texture, the bitmap will be
		 *  cropped or filled up with transparent pixels */
		public function uploadBitmap(bitmap:Bitmap):void
		{
			uploadBitmapData(bitmap.bitmapData);
		}
		
		private static const bdDic:Dictionary = new Dictionary();
		/** Uploads bitmap data to the texture. The existing contents will be replaced.
		 *  If the size of the bitmap does not match the size of the texture, the bitmap will be
		 *  cropped or filled up with transparent pixels */
		public function uploadBitmapData(data:BitmapData):void
		{
			if (!Starling.current.contextValid)
			{
				return;
			}

			createBaseIfNull();

			var potData:BitmapData;


            try
            {
                if ( data.width != mWidth || data.height != mHeight )
                {
                    try
                    {
                        var key : String = mWidth + "_" + mHeight;
                        if ( !bdDic.hasOwnProperty ( key ) )
                        {
                            potData = new BitmapData ( mWidth, mHeight, true, 0 );
                            bdDic[ key ] = potData;
                        }
                        else
                        {
                            potData = bdDic[ key ];
                            potData.fillRect ( potData.rect, 0 );
                        }
                    }
                    catch ( e : Error )
                    {
                        if ( e.errorID == 2015 )
                        {
                            // 内存不足
//						var msg:String = "无效的 BitmapData异常，BitmapData的宽、度分别是：" + mWidth + ", " + mHeight;;
//						EventManager.dispatchEvent(GMTraceEvent, GMTraceEvent.GM_Trace, {msg:msg, isTrace:true, isTips:true});
                        }
                        else
                        {
                            throw e;
                        }
                    }

                    if ( data.rect.width > mWidth || data.rect.height > mHeight )
                    {
                        scaleBitmapData ( data, potData );
                    }
                    else
                    {
                        potData.copyPixels ( data, data.rect, sOrigin );
                    }
                    data = potData;
                }
            }
            catch ( e : Error )
            {
                trace ( e.errorID );
                if ( e.errorID == 2015 )
                {
                    // 内存不足
//						var msg:String = "无效的 BitmapData异常，BitmapData的宽、度分别是：" + mWidth + ", " + mHeight;;
//						EventManager.dispatchEvent(GMTraceEvent, GMTraceEvent.GM_Trace, {msg:msg, isTrace:true, isTips:true});
                }
                else
                {
                    throw e;
                }
            }

                if (mBase is flash.display3D.textures.Texture)
			{
				var potTexture:flash.display3D.textures.Texture = 
					mBase as flash.display3D.textures.Texture;
				
				potTexture.uploadFromBitmapData(data);
				
				if (mMipMapping && data.width > 1 && data.height > 1)
				{
					var currentWidth:int  = data.width  >> 1;
					var currentHeight:int = data.height >> 1;
					var level:int = 1;
					//var canvas:BitmapData = new BitmapData(currentWidth, currentHeight, true, 0);
					var canvas:BitmapData;
					key = currentWidth + "_" + currentHeight;
					if(!bdDic.hasOwnProperty(key)){
						canvas = new BitmapData(currentWidth, currentHeight, true, 0);
						bdDic[key] = canvas;
					}
					else{
						canvas = bdDic[key];
						canvas.fillRect(canvas.rect, 0);
					}
					
					var transform:Matrix = new Matrix(.5, 0, 0, .5);
					var bounds:Rectangle = new Rectangle();
					
					while (currentWidth >= 1 || currentHeight >= 1)
					{
						bounds.width = currentWidth; bounds.height = currentHeight;
						canvas.fillRect(bounds, 0);
						canvas.draw(data, transform, null, null, null, true);
						potTexture.uploadFromBitmapData(canvas, level++);
						transform.scale(0.5, 0.5);
						currentWidth  = currentWidth  >> 1;
						currentHeight = currentHeight >> 1;
					}
					
					//canvas.dispose();
				}
			}
			else // if (mBase is RectangleTexture)
			{
				mBase["uploadFromBitmapData"](data);
			}

            uploaded = true;
			mDataUploaded = true;
		}

		private function scaleBitmapData(sourceBmpData:BitmapData, destBmpData:BitmapData):void
		{
			var sourceRect:Rectangle = sourceBmpData.rect;
			var sourceWidth:Number = sourceRect.width;
			var sourceHeight:Number = sourceRect.height;

			var destRect:Rectangle = destBmpData.rect;
			var destWidth:Number = destRect.width;
			var destHeight:Number = destRect.height;

			sMatrix.a = destWidth / sourceWidth;
			sMatrix.b = 0.0;
			sMatrix.c = 0.0;
			sMatrix.d = destHeight / sourceHeight;
			sMatrix.tx = 0.0;
			sMatrix.ty = 0.0;

			destBmpData.draw(sourceBmpData, sMatrix, null, null, null, true);
		}
		
		/** Uploads ATF data from a ByteArray to the texture. Note that the size of the
		 *  ATF-encoded data must be exactly the same as the original texture size.
		 *  
		 *  <p>The 'async' parameter may be either a boolean value or a callback function.
		 *  If it's <code>false</code> or <code>null</code>, the texture will be decoded
		 *  synchronously and will be visible right away. If it's <code>true</code> or a function,
		 *  the data will be decoded asynchronously. The texture will remain unchanged until the
		 *  upload is complete, at which time the callback function will be executed. This is the
		 *  expected function definition: <code>function(texture:Texture):void;</code></p>
		 */
		public function uploadAtfData(data:ByteArray, offset:int=0, async:*=null):void
		{
			if (!Starling.current.contextValid)
			{
				return;
			}
			
			createBaseIfNull();
			
			const eventType:String = "textureReady"; // defined here for backwards compatibility
			
			var self:ConcreteTexture = this;
			var isAsync:Boolean = async is Function || async === true;
			var potTexture:flash.display3D.textures.Texture = 
				mBase as flash.display3D.textures.Texture;
			
			if (potTexture == null)
				throw new Error("This texture type does not support ATF data");
			
			if (async is Function)
				potTexture.addEventListener(eventType, onTextureReady);

			function onTextureReady(event:Object):void
			{
				potTexture.removeEventListener(eventType, onTextureReady);

				var callback:Function = async as Function;
				if (callback != null)
				{
					if (callback.length == 1) callback(self);
					else callback();
				}
			}

			potTexture.uploadCompressedTextureFromByteArray(data, offset, isAsync);
			mDataUploaded = true;
		}

		// texture backup (context loss)
		
		private function onContextCreated():void
		{
			// recreate the underlying texture & restore contents
			createBase();
			mOnRestore();
			
			// if no texture has been uploaded above, we init the texture with transparent pixels.
			if (!mDataUploaded) clear();
		}
		
		/** Recreates the underlying Stage3D texture object with the same dimensions and attributes
		 *  as the one that was passed to the constructor. You have to upload new data before the
		 *  texture becomes usable again. Beware: this method does <strong>not</strong> dispose
		 *  the current base. */
		starling_internal function createBase():void
		{
			mBase = Starling.current.createTexture(mWidth, mHeight, mFormat, mOptimizedForRenderTexture);
			
			mDataUploaded = false;
		}
		
		/** Clears the texture with a certain color and alpha value. The previous contents of the
		 *  texture is wiped out. Beware: this method resets the render target to the back buffer; 
		 *  don't call it from within a render method. */ 
		public function clear(color:uint=0x0, alpha:Number=0.0):void
		{
			var instance:Starling = Starling.current;
			if (!instance.contextValid) throw new MissingContextError();
			
			if (mPremultipliedAlpha && alpha < 1.0)
				color = Color.rgb(Color.getRed(color)   * alpha,
					Color.getGreen(color) * alpha,
					Color.getBlue(color)  * alpha);

			instance.support.pushRenderTarget(this);
			
			// we wrap the clear call in a try/catch block as a workaround for a problem of
			// FP 11.8 plugin/projector: calling clear on a compressed texture doesn't work there
			// (while it *does* work on iOS + Android).
			
			try { instance.clear(color, alpha); }
			catch (e:Error) {}

			instance.support.popRenderTarget();
			mDataUploaded = true;
		}
		
		// properties
		
		/** Indicates if the base texture was optimized for being used in a render texture. */
		public function get optimizedForRenderTexture():Boolean { return mOptimizedForRenderTexture; }
		
		/** If Starling's "handleLostContext" setting is enabled, the function that you provide
		 *  here will be called after a context loss. On execution, a new base texture will
		 *  already have been created; however, it will be empty. Call one of the "upload..."
		 *  methods from within the callbacks to restore the actual texture data. */
		public function get onRestore():Function { return mOnRestore; }
		public function set onRestore(value:Function):void
		{
			Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			if (Starling.handleLostContext && value != null)
			{
				mOnRestore = value;
				Starling.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			}
			else mOnRestore = null;
		}
		
		/** @inheritDoc */
		public override function get base():TextureBase { return mBase; }
		
		/** @inheritDoc */
		public override function get root():ConcreteTexture { return this; }
		
		/** @inheritDoc */
		public override function get format():String { return mFormat; }
		
		/** @inheritDoc */
		public override function get width():Number  { return mWidth / mScale;  }
		
		/** @inheritDoc */
		public override function get height():Number { return mHeight / mScale; }
		
		/** @inheritDoc */
		public override function get nativeWidth():Number { return mWidth; }
		
		/** @inheritDoc */
		public override function get nativeHeight():Number { return mHeight; }
		
		/** The scale factor, which influences width and height properties. */
		public override function get scale():Number { return mScale; }
		
		/** @inheritDoc */
		public override function get mipMapping():Boolean { return mMipMapping; }
		
		/** @inheritDoc */
		public override function get premultipliedAlpha():Boolean { return mPremultipliedAlpha; }
		
		/** @inheritDoc */
		public override function get repeat():Boolean { return mRepeat; }
		
		public override function set repeat(value:Boolean):void { mRepeat = value; }
	}
}