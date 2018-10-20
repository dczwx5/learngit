// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.RenderCore.starling.core
{
    import QFLib.Graphics.RenderCore.render.IRenderer;
    import QFLib.Graphics.RenderCore.starling.display.BlendMode;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.display.Image;
    import QFLib.Graphics.RenderCore.starling.display.QuadBatch;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.textures.TextureSmoothing;
    import QFLib.Graphics.RenderCore.starling.utils.Color;
    import QFLib.Graphics.RenderCore.starling.utils.MatrixUtil;
    import QFLib.Graphics.RenderCore.starling.utils.RectangleUtil;

    import flash.display3D.Context3DTextureFormat;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /** A class that contains helper methods simplifying Stage3D rendering.
     *
     *  A RenderSupport instance is passed to any "render" method of display objects. 
     *  It allows manipulation of the current transformation matrix (similar to the matrix 
     *  manipulation methods of OpenGL 1.x) and other helper methods.
     */
    public class RenderSupport
    {
        private var mProjectionMatrix:Matrix;
        private var mModelViewMatrix:Matrix;
        private var mMvpMatrix:Matrix;
        private var mMvpMatrix3D:Matrix3D;
		private var _matrixProject:Matrix3D;
        private var mMatrixStack:Vector.<Matrix>;
        private var mMatrixStackSize:int;
        
        private var mDrawCount:int;
        private var mBlendMode:String;
        private var mRenderTarget:Texture;

        private var mRenderTargetStack:Vector.<RenderTargetInfo>;
        private var mRTInfoPool : Vector.<RenderTargetInfo>;
        private var mCurValidRTIndex : int = -1;
        
        private var mClipRectStack:Vector.<Rectangle>;
        private var mClipRectStackSize:int;
        
        private var mQuadBatches:Vector.<QuadBatch>;
        private var mCurrentQuadBatchID:int;
						
        /** helper objects */
        private static var sPoint:Point = new Point();
        private static var sClipRect:Rectangle = new Rectangle();
        private static var sBufferRect:Rectangle = new Rectangle();
        private static var sScissorRect:Rectangle = new Rectangle();
		
		/** TextureLookupFlags helper */
		private static var sTextureFormats:Vector.<String> = new <String>[Context3DTextureFormat.COMPRESSED, Context3DTextureFormat.COMPRESSED_ALPHA, ""];
		private static var sIsMipMapping:Vector.<Boolean> = new <Boolean>[true, false];
		private static var sIsRepeat:Vector.<Boolean> = new <Boolean>[true, false];
		private static var sSmoothings:Vector.<String> = new <String>[TextureSmoothing.NONE, TextureSmoothing.BILINEAR, ""];		
		private static var sTextureFlagTables:Vector.<String> = null;
		private static var sFlag:int;
		private static var sSmoothingIndex:int;
        
        // construction
        
        /** Creates a new RenderSupport object with an empty matrix stack. */
        public function RenderSupport()
        {
            mProjectionMatrix = new Matrix();
            mModelViewMatrix = new Matrix();
            mMvpMatrix = new Matrix();
            mMvpMatrix3D = new Matrix3D();
			_matrixProject= new Matrix3D();
            mMatrixStack = new <Matrix>[];
            mMatrixStackSize = 0;
            mDrawCount = 0;
            mRenderTarget = null;
            mBlendMode = BlendMode.NORMAL;
            mClipRectStack = new <Rectangle>[];

            mRenderTargetStack = new <RenderTargetInfo>[];
            mRTInfoPool = new Vector.<RenderTargetInfo>( 8 );
            
            mCurrentQuadBatchID = 0;
            mQuadBatches = new <QuadBatch>[new QuadBatch()];
						
            loadIdentity();
        }
		
        /** Disposes all quad batches. */
        public function dispose():void
        {
            for each (var quadBatch:QuadBatch in mQuadBatches)
                quadBatch.dispose();

            mRenderTargetStack.length = 0;
            mRenderTargetStack = null;

            mRTInfoPool.length = 0;
            mRTInfoPool = null;
        }
        
        // matrix manipulation        
        /** Sets up the projection matrix for ortographic 2D rendering. */
		public function setOrthographicProjection(x:Number, y:Number, width:Number, height:Number):void
        {
			mProjectionMatrix.setTo(2.0/width, 0, 0, -2.0/height, 
				-(2*x + width) / width, (2*y + height) / height);
			
			applyClipRect();
        }
		
        /** Changes the modelview matrix to the identity matrix. */
        public function loadIdentity():void
        {
            mModelViewMatrix.identity();
        }
        
        /** Prepends a translation to the modelview matrix. */
        public function translateMatrix(dx:Number, dy:Number):void
        {
            MatrixUtil.prependTranslation(mModelViewMatrix, dx, dy);
        }
        
        /** Prepends a rotation (angle in radians) to the modelview matrix. */
        public function rotateMatrix(angle:Number):void
        {
            MatrixUtil.prependRotation(mModelViewMatrix, angle);
        }
        
        /** Prepends an incremental scale change to the modelview matrix. */
        public function scaleMatrix(sx:Number, sy:Number):void
        {
            MatrixUtil.prependScale(mModelViewMatrix, sx, sy);
        }
        
        /** Prepends a matrix to the modelview matrix by multiplying it with another matrix. */
        public function prependMatrix(matrix:Matrix):void
        {
            MatrixUtil.prependMatrix(mModelViewMatrix, matrix);
        }
        
        /** Prepends translation, scale and rotation of an object to the modelview matrix. */
        public function transformMatrix(object:DisplayObject):void
        {
            MatrixUtil.prependMatrix(mModelViewMatrix, object.localTransform);
        }
        
        /** Pushes the current modelview matrix to a stack from which it can be restored later. */
        public function pushMatrix():void
        {
            if (mMatrixStack.length < mMatrixStackSize + 1)
                mMatrixStack.push(new Matrix());
            
            mMatrixStack[int(mMatrixStackSize++)].copyFrom(mModelViewMatrix);
        }
        
        /** Restores the modelview matrix that was last pushed to the stack. */
        public function popMatrix():void
        {
            mModelViewMatrix.copyFrom(mMatrixStack[int(--mMatrixStackSize)]);
        }
        
        /** Empties the matrix stack, resets the modelview matrix to the identity matrix. */
        public function resetMatrix():void
        {
            mMatrixStackSize = 0;
            loadIdentity();
        }
        
        /** Prepends translation, scale and rotation of an object to a custom matrix. */
        public static function transformMatrixForObject(matrix:Matrix, object:DisplayObject):void
        {
            MatrixUtil.prependMatrix(matrix, object.localTransform);
        }
        
        /** Calculates the product of modelview and projection matrix. 
         *  CAUTION: Use with care! Each call returns the same instance. */
        public function get mvpMatrix():Matrix
        {
            mMvpMatrix.copyFrom(mModelViewMatrix);
            mMvpMatrix.concat(mProjectionMatrix);
            return mMvpMatrix;
        }
        
        /** Calculates the product of modelview and projection matrix and saves it in a 3D matrix. 
         *  CAUTION: Use with care! Each call returns the same instance. */
        public function get mvpMatrix3D():Matrix3D
        {
			mMvpMatrix3D=MatrixUtil.convertTo3D(mvpMatrix, mMvpMatrix3D);
			return mMvpMatrix3D;
        }	
		
        /** Returns the current modelview matrix.
         *  CAUTION: Use with care! Each call returns the same instance. */
        public function get modelViewMatrix():Matrix 
		{
			return mModelViewMatrix; 
		}
		
		public function set modelViewMatrix(value:Matrix):void
		{
			mModelViewMatrix.copyFrom(value);
		}
        
        /** Returns the current projection matrix.
         *  CAUTION: Use with care! Each call returns the same instance. */
        public function get projectionMatrix():Matrix { return mProjectionMatrix; }
		public function get matrixProject():Matrix3D
		{
			
			return MatrixUtil.convertTo3D(mProjectionMatrix, _matrixProject);
		}
        public function set projectionMatrix(value:Matrix):void 
        {
            mProjectionMatrix.copyFrom(value);
            applyClipRect();
        }
        
        // blending
        
        /** Activates the current blend mode on the active rendering context. */
        public function applyBlendMode(premultipliedAlpha:Boolean):void
        {
            setBlendFactors(premultipliedAlpha, mBlendMode);
        }
        
        /** The blend mode to be used on rendering. To apply the factor, you have to manually call
         *  'applyBlendMode' (because the actual blend factors depend on the PMA mode). */
        public function get blendMode():String { return mBlendMode; }
        public function set blendMode(value:String):void
        {
            if (value != BlendMode.AUTO) mBlendMode = value;
        }
        
        // render targets
        
        /** The texture that is currently being rendered into, or 'null' to render into the 
         *  back buffer. If you set a new target, it is immediately activated. */
        public function get renderTarget():Texture { return mRenderTarget; }

        /** Changes the the current render target.
         *  @param target       Either a texture or 'null' to render into the back buffer.
         *  @param antiAliasing Only supported for textures, beginning with AIR 13, and only on
         *                      Desktop. Values range from 0 (no antialiasing) to 4 (best quality).
         */
        private function setRenderTarget(target:Texture, antiAliasing:int=0):void
        {
            mRenderTarget = target;
            applyClipRect();
            
            if (target)
			{
				Starling.current.setRenderToTexture(target.base, false, antiAliasing, 0, 0);
			}
            else
			{
				Starling.current.setRenderToBackBuffer();
			}
        }
        
        // clipping
        
        /** The clipping rectangle can be used to limit rendering in the current render target to
         *  a certain area. This method expects the rectangle in stage coordinates. Internally,
         *  it uses the 'scissorRectangle' of stage3D, which works with pixel coordinates. 
         *  Any pushed rectangle is intersected with the previous rectangle; the method returns
         *  that intersection. */ 
        public function pushClipRect(rectangle:Rectangle):Rectangle
        {
            if (mClipRectStack.length < mClipRectStackSize + 1)
                mClipRectStack.push(new Rectangle());
            
            mClipRectStack[mClipRectStackSize].copyFrom(rectangle);
            rectangle = mClipRectStack[mClipRectStackSize];
            
            // intersect with the last pushed clip rect
            if (mClipRectStackSize > 0)
                RectangleUtil.intersect(rectangle, mClipRectStack[mClipRectStackSize-1], 
                                        rectangle);
            
            ++mClipRectStackSize;
            applyClipRect();
            
            // return the intersected clip rect so callers can skip draw calls if it's empty
            return rectangle;
        }
        
        /** Restores the clipping rectangle that was last pushed to the stack. */
        public function popClipRect():void
        {
            if (mClipRectStackSize > 0)
            {
                --mClipRectStackSize;
                applyClipRect();
            }
        }
        
        /** Updates the context3D scissor rectangle using the current clipping rectangle. This
         *  method is called automatically when either the render target, the projection matrix,
         *  or the clipping rectangle changes. */
        public function applyClipRect():void
        {
			finishQuadBatch();

            var instance:Starling = Starling.current;
            if (!instance.contextValid) return;
            
            if (mClipRectStackSize > 0)
            {
                var width:int, height:int;
                var rect:Rectangle = mClipRectStack[mClipRectStackSize-1];
                
                if (mRenderTarget)
                {
                    width  = mRenderTarget.root.nativeWidth;
                    height = mRenderTarget.root.nativeHeight;
                }
                else
                {
                    width  = Starling.current.backBufferWidth;
                    height = Starling.current.backBufferHeight;
                }
                
                // convert to pixel coordinates (matrix transformation ends up in range [-1, 1])
                MatrixUtil.transformCoords(mProjectionMatrix, rect.x, rect.y, sPoint);
                sClipRect.x = (sPoint.x * 0.5 + 0.5) * width;
                sClipRect.y = (0.5 - sPoint.y * 0.5) * height;
                
                MatrixUtil.transformCoords(mProjectionMatrix, rect.right, rect.bottom, sPoint);
                sClipRect.right  = (sPoint.x * 0.5 + 0.5) * width;
                sClipRect.bottom = (0.5 - sPoint.y * 0.5) * height;
                
                sBufferRect.setTo(0, 0, width, height);
                RectangleUtil.intersect(sClipRect, sBufferRect, sScissorRect);
                
                // an empty rectangle is not allowed, so we set it to the smallest possible size
                if (sScissorRect.width < 1 || sScissorRect.height < 1)
                    sScissorRect.setTo(0, 0, 1, 1);
                
                instance.setScissorRectangle(sScissorRect);
            }
            else
            {
                instance.setScissorRectangle(null);
            }
        }
        
        // optimized quad rendering
        /** Adds a batch of quads to the current batch of unrendered quads. If there is a state 
         *  change, all previous quads are rendered at once. 
         *  
         *  <p>Note that you should call this method only for objects with a small number of quads 
         *  (we recommend no more than 16). Otherwise, the additional CPU effort will be more
         *  expensive than what you save by avoiding the draw call.</p> */
        public function batchQuadBatch(quadBatch:QuadBatch, parentAlpha:Number):void
        {
            if (mQuadBatches[mCurrentQuadBatchID].isStateChange(
                quadBatch.tinted, parentAlpha, quadBatch.texture, quadBatch.smoothing, mBlendMode))
            {
                finishQuadBatch();
            }
            
            mQuadBatches[mCurrentQuadBatchID].addQuadBatch(quadBatch, parentAlpha, 
				modelViewMatrix, mBlendMode);
        }

        /** Renders the current quad batch and resets it. */
        public function finishQuadBatch():void
        {
            var currentBatch:QuadBatch = mQuadBatches[mCurrentQuadBatchID];
            
            if (currentBatch.numTriangles != 0)
            {
				currentBatch.renderQueue();
				currentBatch.reset();
                
                ++mCurrentQuadBatchID;
                ++mDrawCount;
                
                if (mQuadBatches.length <= mCurrentQuadBatchID)
                    mQuadBatches.push(new QuadBatch());
            }			
        }
		
		public function resetQueues():void
		{
			for each (var quadBatch:QuadBatch in mQuadBatches)
				quadBatch.reset();
		}
        
        /** Resets matrix stack, blend mode, quad batch index, and draw count. */
        public function nextFrame():void
        {
			resetQueues();
            resetMatrix();
            trimQuadBatches();
            
            mCurrentQuadBatchID = 0;
			
            mBlendMode = BlendMode.NORMAL;
            mDrawCount = 0;
        }

        /** Disposes redundant quad batches if the number of allocated batches is more than
         *  twice the number of used batches. Only executed when there are at least 16 batches. */
        private function trimQuadBatches():void
        {
            var numUsedBatches:int  = mCurrentQuadBatchID + 1;
            var numTotalBatches:int = mQuadBatches.length;
            
            if (numTotalBatches >= 16 && numTotalBatches > 2*numUsedBatches)
            {
                var numToRemove:int = numTotalBatches - numUsedBatches;
                for (var i:int=0; i<numToRemove; ++i)
                    mQuadBatches.pop().dispose();
            }
        }
        
        // other helper methods
       
        /** Sets up the blending factors that correspond with a certain blend mode. */
        public static function setBlendFactors(premultipliedAlpha:Boolean, blendMode:String="normal"):void
        {
			if(blendMode == BlendMode.AUTO)
				blendMode = BlendMode.NORMAL;
            var blendFactors:Array = BlendMode.getBlendFactors(blendMode, premultipliedAlpha); 
			Starling.current.renderer.clearCachedBlendMode();
            Starling.current.setBlendFactors(blendFactors[0], blendFactors[1]);
        }
        
        /** Clears the render context with a certain color and alpha value. */
        public static function clear(rgb:uint=0, alpha:Number=0.0, depth:Number = 1.0, stencil:uint = 0, mask:uint = 0xffffffff):void
        {
            Starling.current.clear(
                Color.getRed(rgb)   / 255.0, 
                Color.getGreen(rgb) / 255.0, 
                Color.getBlue(rgb)  / 255.0,
                alpha,
                depth,
                stencil,
                mask);
        }
        
        /** Clears the render context with a certain color and alpha value. */
        public function clear(rgb:uint=0, alpha:Number=0.0):void
        {
            RenderSupport.clear(rgb, alpha);
        }
        
        /** Returns the flags that are required for AGAL texture lookup, 
         *  including the '&lt;' and '&gt;' delimiters. */
        public static function getTextureLookupFlags(format:String, mipMapping:Boolean,
                                                     repeat:Boolean=false,
                                                     smoothing:String="bilinear"):String
        {
			if (sTextureFlagTables == null)
			{
				sTextureFlagTables = generateTextureLookupFlags();
			}
			
			sFlag = sTextureFormats.indexOf(format);

			if (sFlag < 0)
			{
				sFlag = 2;
			}
			
			sFlag = sFlag * sIsMipMapping.length + sIsMipMapping.indexOf(mipMapping);
			sFlag = sFlag * sIsRepeat.length + sIsRepeat.indexOf(repeat);
			sFlag = sFlag * sSmoothings.length;
			
			sSmoothingIndex = sSmoothings.indexOf(smoothing);
			if (sSmoothingIndex < 0)
			{
				sSmoothingIndex = 2;
			}
			
			sFlag += sSmoothingIndex;
			
			return sTextureFlagTables[sFlag];
		}
		
		private static function generateTextureLookupFlags():Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>();
			
			for (var i:int = 0; i < sTextureFormats.length; ++i)
			{
				for (var j:int = 0; j < sIsMipMapping.length; ++j)
				{
					for (var k:int = 0; k < sIsRepeat.length; ++k)
					{
						for (var l:int = 0; l < sSmoothings.length; ++l)
						{
							result.push(calcTextureLookupFlags(sTextureFormats[i], sIsMipMapping[j], sIsRepeat[k], sSmoothings[l]));
						}
					}
				}
			}
			

			return result;
		}
		
		public static function calcTextureLookupFlags(format:String, mipMapping:Boolean,
													 repeat:Boolean=false,
													 smoothing:String="bilinear"):String
		{
			var options:Array = ["2d", repeat ? "repeat" : "clamp"];
			
			if (format == Context3DTextureFormat.COMPRESSED)
				options.push("dxt1");
			else if (format == "compressedAlpha")
				options.push("dxt5");
			
			if (smoothing == TextureSmoothing.NONE)
				options.push("nearest", mipMapping ? "mipnearest" : "mipnone");
			else if (smoothing == TextureSmoothing.BILINEAR)
				options.push("linear", mipMapping ? "mipnearest" : "mipnone");
			else
				options.push("linear", mipMapping ? "miplinear" : "mipnone");
			
			return "<" + options.join() + ">";
		}
        
        // statistics
        
        /** Raises the draw count by a specific value. Call this method in custom render methods
         *  to keep the statistics display in sync. */
        public function raiseDrawCount(value:uint=1):void { mDrawCount += value; }
        
        /** Indicates the number of stage3D draw calls. */
        public function get drawCount():int { return mDrawCount; }

        public function pushRenderTarget(target:Texture, antiAliasing:int=0):void
        {
            var renderTargetInfo : RenderTargetInfo = null;
            if ( mCurValidRTIndex >= 0 )
            {
                renderTargetInfo = mRTInfoPool[ mCurValidRTIndex-- ];
                renderTargetInfo.texture = target;
                renderTargetInfo.antiAliasing = antiAliasing;
            }
            else
            {
                renderTargetInfo = new RenderTargetInfo( target, antiAliasing );
            }

            mRenderTargetStack.push( renderTargetInfo );
            setRenderTarget(target, antiAliasing);

            //�л�render target ��opengl�»ᶪʧ���е� state
            var renderer:IRenderer = Starling.current.renderer;
            renderer.clearCachedProgram();
            renderer.clearCachedBlendMode();
        }

        public function popRenderTarget():void
        {
            var rtInfo : RenderTargetInfo = mRenderTargetStack.pop () as RenderTargetInfo;
            mRTInfoPool[++mCurValidRTIndex] = rtInfo;

            var length : int = mRenderTargetStack.length;
            if ( length > 0 )
            {
                var renderTargetInfo : RenderTargetInfo = mRenderTargetStack[ mRenderTargetStack.length - 1 ];
                setRenderTarget ( renderTargetInfo.texture, renderTargetInfo.antiAliasing);
            }
            else
            {
                setRenderTarget ( null );
            }

            //�л�render target ��opengl�»ᶪʧ���е� state
            var renderer:IRenderer = Starling.current.renderer;
            renderer.clearCachedProgram();
            renderer.clearCachedBlendMode();
        }

	    public function batchQuad(image:Image, alpha:Number, texture:Texture, filterMode:String):void
	    {
		    throw new DefinitionError("Can't use this function. " +
				    "It use to make spine.starling.PolygonBatch happy!");
	    }

        private function isTargetExist ( target : Texture ) : Boolean
        {
            var len : int = mRenderTargetStack.length;
            var info : RenderTargetInfo = null;
            for ( var i : int = 0; i < len; i++ )
            {
                info = mRenderTargetStack[ i ];
                if ( info.texture == target )
                    return true;
            }

            return false;
        }
    }
}

import QFLib.Graphics.RenderCore.starling.textures.Texture;

class RenderTargetInfo
{
    public var texture:Texture;
    public var antiAliasing:int;

    public function RenderTargetInfo(_texture:Texture, _antiAliasing:int)
    {
        texture = _texture;
        antiAliasing = _antiAliasing;
    }
}