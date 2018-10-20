// =================================================================================================
//
//  Starling Framework
//  Copyright 2011 Gamua OG. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.RenderCore.starling.utils
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /** The VertexData class manages a raw list of vertex information, allowing direct upload
     *  to Stage3D vertex buffers. <em>You only have to work with this class if you create display 
     *  objects with a custom render function. If you don't plan to do that, you can safely 
     *  ignore it.</em>
     * 
     *  <p>To render objects with Stage3D, you have to organize vertex data in so-called
     *  vertex buffers. Those buffers reside in graphics memory and can be accessed very 
     *  efficiently by the GPU. Before you can move data into vertex buffers, you have to 
     *  set it up in conventional memory - that is, in a Vector object. The vector contains
     *  all vertex information (the coordinates, color, and texture coordinates) - one
     *  vertex after the other.</p>
     *  
     *  <p>To simplify creating and working with such a bulky list, the VertexData class was 
     *  created. It contains methods to specify and modify vertex data. The raw Vector managed 
     *  by the class can then easily be uploaded to a vertex buffer.</p>
     * 
     *  <strong>Premultiplied Alpha</strong>
     *  
     *  <p>The color values of the "BitmapData" object contain premultiplied alpha values, which 
     *  means that the <code>rgb</code> values were multiplied with the <code>alpha</code> value 
     *  before saving them. Since textures are created from bitmap data, they contain the values in 
     *  the same style. On rendering, it makes a difference in which way the alpha value is saved; 
     *  for that reason, the VertexData class mimics this behavior. You can choose how the alpha 
     *  values should be handled via the <code>premultipliedAlpha</code> property.</p>
     * 
     */ 
    public class VertexData 
    {
        /** The total number of elements (Numbers) stored per vertex. */
        public static const ELEMENTS_PER_VERTEX:int = 8;
        
        /** The offset of position data (x, y) within a vertex. */
        public static const POSITION_OFFSET:int = 0;
        
        /** The offset of color data (r, g, b, a) within a vertex. */
        public static const COLOR_OFFSET:int = 2;
        
        /** The offset of texture coordinates (u, v) within a vertex. */
        public static const TEXCOORD_OFFSET:int = 6;

        /** Helper object. */
        private static var sHelperPoint:Point = new Point();
        private static var sVectorNumberPool:Array = [];

        private var mRawData:Vector.<Number>;
        private var mNumVertices:int;

        private var mPremultipliedAlpha:Boolean;
        private var mTinted:Boolean;
        private var mTintedDirty:Boolean;
		private var mUseVectorNumberPool:Boolean;
		
		private static function getVectorNumber():Vector.<Number>
        {
			if(sVectorNumberPool.length > 0){
				return sVectorNumberPool.pop();
			}
			return new Vector.<Number>();
		}
		
		private static function recycleVectorNumber(value:Vector.<Number>):void
        {
			sVectorNumberPool.push(value);
		}
		
        /** Create a new VertexData object with a specified number of vertices. */
        public function VertexData(numVertices:int, premultipliedAlpha:Boolean = false, useVectorNumberPool:Boolean = false)
        {
			mUseVectorNumberPool = useVectorNumberPool;
			if(mUseVectorNumberPool){
            	mRawData = getVectorNumber();
			}
			else{
				mRawData = new Vector.<Number>();
			}
            mPremultipliedAlpha = premultipliedAlpha;
            this.numVertices = numVertices;
            mTinted = false;
            mTintedDirty = true;
        }

		public function dispose():void{
			if(mRawData){
				if(mUseVectorNumberPool)
					recycleVectorNumber(mRawData);
				mRawData = null;
			}
		}
		
        /** Creates a duplicate of either the complete vertex data object, or of a subset. 
         *  To clone all vertices, set 'numVertices' to '-1'. */
        public function clone(vertexID:int=0, numVertices:int=-1):VertexData
        {
            if (numVertices < 0 || vertexID + numVertices > mNumVertices)
                numVertices = mNumVertices - vertexID;
            
            var clone:VertexData = new VertexData(0, mPremultipliedAlpha);
            clone.mNumVertices = numVertices;
            clone.mRawData = mRawData.slice(vertexID * ELEMENTS_PER_VERTEX,
                                         numVertices * ELEMENTS_PER_VERTEX);
            clone.mRawData.fixed = true;
            return clone;
        }
        
        /** Copies the vertex data (or a range of it, defined by 'vertexID' and 'numVertices') 
         *  of this instance to another vertex data object, starting at a certain index. */
        public function copyTo(targetData:VertexData, targetVertexID:int=0,
                               vertexID:int=0, numVertices:int=-1):void
        {
            copyTransformedTo(targetData, targetVertexID, null, vertexID, numVertices);
        }
        
        /** Transforms the vertex position of this instance by a certain matrix and copies the
         *  result to another VertexData instance. Limit the operation to a range of vertices
         *  via the 'vertexID' and 'numVertices' parameters. */
        public function copyTransformedTo(targetData:VertexData, targetVertexID:int=0,
                                          matrix:Matrix=null,
                                          vertexID:int=0, numVertices:int=-1):void
        {
            if (numVertices < 0 || vertexID + numVertices > mNumVertices)
                numVertices = mNumVertices - vertexID;
            
            var x:Number, y:Number;
            var targetRawData:Vector.<Number> = targetData.mRawData;
            var targetIndex:int = targetVertexID * ELEMENTS_PER_VERTEX;
            var sourceIndex:int = vertexID * ELEMENTS_PER_VERTEX;
            var sourceEnd:int = (vertexID + numVertices) * ELEMENTS_PER_VERTEX;
            
            if (matrix)
            {
                while (sourceIndex < sourceEnd)
                {
					x = mRawData[sourceIndex];	++sourceIndex;
					y = mRawData[sourceIndex];	++sourceIndex;
                    
                    targetRawData[int(targetIndex++)] = matrix.a * x + matrix.c * y + matrix.tx;
                    targetRawData[int(targetIndex++)] = matrix.d * y + matrix.b * x + matrix.ty;
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                }
            }
            else
            {
                while (sourceIndex < sourceEnd)
                {
                    targetRawData[int(targetIndex++)] = mRawData[int(sourceIndex++)];
                }
            }

            targetData.tintedDirty = true;
        }
        
        /** Appends the vertices from another VertexData object. */
        public function append(data:VertexData):void
        {
            mRawData.fixed = false;
            
            var targetIndex:int = mNumVertices * ELEMENTS_PER_VERTEX;
            var rawData:Vector.<Number> = data.mRawData;
            var rawDataLength:int = rawData.length;
            
            for (var i:int=0; i<rawDataLength; ++i)
                mRawData[int(targetIndex++)] = rawData[i];
            
            mNumVertices += data.numVertices;
            mRawData.fixed = true;

            if (!tinted)
            {
                mTinted = data.tinted;
            }
        }
        
        // functions
        
        /** Updates the position values of a vertex. */
        [Inline]
        final public function setPosition(vertexID:int, x:Number, y:Number):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            mRawData[offset] = x;
            mRawData[int(offset+1)] = y;
        }

        [Inline]
        /** Returns the position of a vertex. */
        final public function getPosition(vertexID:int, position:Point):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            position.x = mRawData[offset];
            position.y = mRawData[int(offset+1)];
        }
        
        /** Updates the RGB color and alpha value of a vertex in one step. */
        public function setColorAndAlpha(vertexID:int, color:uint, alpha:Number):void
        {
            if (alpha < 0.001)    alpha = 0.001; // zero alpha would wipe out all color data
            else if (alpha > 1.0) alpha = 1.0;
            
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET;
            var multiplier:Number = mPremultipliedAlpha ? alpha : 1.0;
            
            mRawData[offset]        = ((color >> 16) & 0xff) / 255.0 * multiplier;
            mRawData[int(offset+1)] = ((color >>  8) & 0xff) / 255.0 * multiplier;
            mRawData[int(offset+2)] = ( color        & 0xff) / 255.0 * multiplier;
            mRawData[int(offset+3)] = alpha;

            if (multiplier != 1.0)
            {
                mTinted = true;
            }
            else if (!tinted)
            {
                mTinted = color != 0xffffff;
            }
        }
        
        /** Updates the RGB color values of a vertex (alpha is not changed). */
        [Inline]
        final public function setColor(vertexID:int, color:uint):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET;
            var multiplier:Number = mPremultipliedAlpha ? mRawData[int(offset+3)] : 1.0;
            mRawData[offset]        = ((color >> 16) & 0xff) / 255.0 * multiplier;
            mRawData[int(offset+1)] = ((color >>  8) & 0xff) / 255.0 * multiplier;
            mRawData[int(offset+2)] = ( color        & 0xff) / 255.0 * multiplier;

            if (multiplier != 1.0)
            {
                mTinted = true;
            }
            else if (!tinted)
            {
                mTinted = color != 0xffffff;
            }
        }
        
        /** Returns the RGB color of a vertex (no alpha). */
        public function getColor(vertexID:int):uint
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET;
            var divisor:Number = mPremultipliedAlpha ? mRawData[int(offset+3)] : 1.0;
            
            if (divisor == 0) return 0;
            else
            {
                var red:Number   = mRawData[offset]        / divisor;
                var green:Number = mRawData[int(offset+1)] / divisor;
                var blue:Number  = mRawData[int(offset+2)] / divisor;
                
                return (int(red*255) << 16) | (int(green*255) << 8) | int(blue*255);
            }
        }
        
        /** Updates the alpha value of a vertex (range 0-1). */
        public function setAlpha(vertexID:int, alpha:Number):void
        {
            if (mPremultipliedAlpha)
            {
                setColorAndAlpha(vertexID, getColor(vertexID), alpha);
            }
            else
            {
                mRawData[int(vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET + 3)] = alpha;

                if (!tinted && alpha != 1.0)
                {
                    mTinted = true;
                }
            }
        }
        
        /** Returns the alpha value of a vertex in the range 0-1. */
        public function getAlpha(vertexID:int):Number
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET + 3;
            return mRawData[offset];
        }
        
        /** Updates the texture coordinates of a vertex (range 0-1). */
        [Inline]
        final public function setTexCoords(vertexID:int, u:Number, v:Number):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + TEXCOORD_OFFSET;
            mRawData[offset]        = u;
            mRawData[int(offset+1)] = v;
        }
        
        /** Returns the texture coordinates of a vertex in the range 0-1. */
        public function getTexCoords(vertexID:int, texCoords:Point):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + TEXCOORD_OFFSET;
            texCoords.x = mRawData[offset];
            texCoords.y = mRawData[int(offset+1)];
        }
        
        // utility functions
        
        /** Translate the position of a vertex by a certain offset. */
        public function translateVertex(vertexID:int, deltaX:Number, deltaY:Number):void
        {
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            mRawData[offset]        += deltaX;
            mRawData[int(offset+1)] += deltaY;
        }

        /** Transforms the position of subsequent vertices by multiplication with a 
         *  transformation matrix. */
        public function transformVertex(vertexID:int, matrix:Matrix, numVertices:int=1):void
        {
            var x:Number, y:Number;
            var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            
            for (var i:int=0; i<numVertices; ++i)
            {
                x = mRawData[offset];
                y = mRawData[int(offset+1)];
                
                mRawData[offset]        = matrix.a * x + matrix.c * y + matrix.tx;
                mRawData[int(offset+1)] = matrix.d * y + matrix.b * x + matrix.ty;
                
                offset += ELEMENTS_PER_VERTEX;
            }
        }
        
        /** Sets all vertices of the object to the same color values. */
        public function setUniformColor(color:uint):void
        {
            var colorReverse:Number = 1.0 / 255.0;
            var r:Number = ((color >> 16) & 0xff) * colorReverse;
            var g:Number = ((color >>  8) & 0xff) * colorReverse;
            var b:Number = ( color        & 0xff) * colorReverse;

            var offset:int = COLOR_OFFSET;
            var multiplier:Number;

            if (mPremultipliedAlpha)
            {
                for (var i:int = 0; i < mNumVertices; ++i)
                {
                    multiplier = mRawData[int(offset+3)];
                    mRawData[offset]        = r * multiplier;
                    mRawData[int(offset+1)] = g * multiplier;
                    mRawData[int(offset+2)] = b * multiplier;
                    offset += ELEMENTS_PER_VERTEX;

                    if (multiplier != 1.0)
                    {
                        mTinted = true;
                    }
                }
            }
            else
            {
                for (i = 0; i < mNumVertices; ++i)
                {
                    mRawData[offset]        = r;
                    mRawData[int(offset+1)] = g;
                    mRawData[int(offset+2)] = b;
                    offset += ELEMENTS_PER_VERTEX;
                }
            }

            if (!tinted)
            {
                mTinted = color != 0xffffff;
            }
        }
        
        /** Sets all vertices of the object to the same alpha values. */
        public function setUniformAlpha(alpha:Number):void
        {
            for (var i:int=0; i<mNumVertices; ++i)
                setAlpha(i, alpha);
        }
        
        /** Multiplies the alpha value of subsequent vertices with a certain factor. */
        public function scaleAlpha(vertexID:int, factor:Number, numVertices:int=1):void
        {
            if (factor == 1.0) return;
            if (numVertices < 0 || vertexID + numVertices > mNumVertices)
                numVertices = mNumVertices - vertexID;
             
            var i:int;
			
			for (i=0; i<numVertices; ++i)
				setAlpha(vertexID+i, getAlpha(vertexID+i) * factor);
        }
        
        /** Calculates the bounds of the vertices, which are optionally transformed by a matrix. 
         *  If you pass a 'resultRect', the result will be stored in this rectangle 
         *  instead of creating a new object. To use all vertices for the calculation, set
         *  'numVertices' to '-1'. */
        public function getBounds(transformationMatrix:Matrix=null, 
                                  vertexID:int=0, numVertices:int=-1,
                                  resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null) resultRect = new Rectangle();
            if (numVertices < 0 || vertexID + numVertices > mNumVertices)
                numVertices = mNumVertices - vertexID;
            
            if (numVertices == 0)
            {
                if (transformationMatrix == null)
                    resultRect.setEmpty();
                else
                {
                    MatrixUtil.transformCoords(transformationMatrix, 0, 0, sHelperPoint);
                    resultRect.setTo(sHelperPoint.x, sHelperPoint.y, 0, 0);
                }
            }
            else
            {
                var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
                var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
                var offset:int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
                var x:Number, y:Number, i:int;
				
				for (i=0; i<numVertices; ++i)
				{
					x = mRawData[offset];
					y = mRawData[int(offset+1)];
					offset += ELEMENTS_PER_VERTEX;
					
					if (minX > x) minX = x;
					if (maxX < x) maxX = x;
					if (minY > y) minY = y;
					if (maxY < y) maxY = y;
				}
				
				resultRect.setTo(minX, minY, maxX - minX, maxY - minY);

				if (transformationMatrix != null)
				{
					MatrixUtil.transformRectangle(transformationMatrix, resultRect);
				}
            }
            
            return resultRect;
        }
        
        /** Creates a string that contains the values of all included vertices. */
        public function toString():String
        {
            var result:String = "[VertexData \n";
            var position:Point = new Point();
            var texCoords:Point = new Point();
            var color:uint;
            
            for (var i:int=0; i<numVertices; ++i)
            {
                getPosition(i, position);
                getTexCoords(i, texCoords);
                result += "  [Vertex " + i + ": " +
                    "x="   + position.x.toFixed(1)    + ", " +
                    "y="   + position.y.toFixed(1)    + ", " +
                    "rgb=" + getColor(i).toString(16) + ", " +
                    "a="   + getAlpha(i).toFixed(2)   + ", " +
                    "u="   + texCoords.x.toFixed(4)   + ", " +
                    "v="   + texCoords.y.toFixed(4)   + "]"  +
                    (i == numVertices-1 ? "\n" : ",\n");
            }
            
            return result + "]";
        }
        
        // properties
        
        /** Indicates if any vertices have a non-white color or are not fully opaque. */
        public function get tinted():Boolean
        {
            if (mTintedDirty)
            {
                var offset:int = COLOR_OFFSET;

                for (var i:int = 0; i < mNumVertices; ++i)
                {
                    for (var j:int = 0; j < 4; ++j)
                    {
                        if (mRawData[int(offset + j)] != 1.0)
                        {
                            mTinted = true;
                            mTintedDirty = false;
                            return mTinted;
                        }
                    }

                    offset += ELEMENTS_PER_VERTEX;
                }

                mTinted = false;
                mTintedDirty = false;
            }
            
            return mTinted;
        }
        
        /** Changes the way alpha and color values are stored. Optionally updates all exisiting 
         *  vertices. */
        public function setPremultipliedAlpha(value:Boolean, updateData:Boolean=true):void
        {
            if (value == mPremultipliedAlpha) return;
            
            if (updateData)
            {
                var dataLength:int = mNumVertices * ELEMENTS_PER_VERTEX;
                
				// src:
//                for (var i:int=COLOR_OFFSET; i<dataLength; i += ELEMENTS_PER_VERTEX)
//                {
//                    var alpha:Number = mRawData[int(i+3)];
//                    var divisor:Number = mPremultipliedAlpha ? alpha : 1.0;
//
//                    if (divisor != 0)
//                    {
//                        var multiplier:Number = ( value ? alpha : 1.0 ) / divisor;
//                        mRawData[i]        = mRawData[i]        * multiplier;
//                        mRawData[int(i+1)] = mRawData[int(i+1)] * multiplier;
//                        mRawData[int(i+2)] = mRawData[int(i+2)] * multiplier;
//                    }
//                }

                // optimize:
                if ( mPremultipliedAlpha )
                {
                    for (var i:int=COLOR_OFFSET; i<dataLength; i += ELEMENTS_PER_VERTEX)
                    {
                        var alpha:Number = mRawData[int(i+3)];
                        if (alpha != 0)
                        {
                            var multiplier:Number = 1 / alpha;
                            mRawData[i]        = mRawData[i]        * multiplier;
                            mRawData[int(i+1)] = mRawData[int(i+1)] * multiplier;
                            mRawData[int(i+2)] = mRawData[int(i+2)] * multiplier;
                        }
                    }
                }
                else
                {
                    for (i=COLOR_OFFSET; i<dataLength; i += ELEMENTS_PER_VERTEX)
                    {
                        alpha = mRawData[int(i+3)];
                        mRawData[i]        = mRawData[i] * alpha;
                        mRawData[int(i+1)] = mRawData[int(i+1)] * alpha;
                        mRawData[int(i+2)] = mRawData[int(i+2)] * alpha;
                    }
                }

                mTintedDirty = true;
            }
            
            mPremultipliedAlpha = value;
        }
        
       /** Indicates if the rgb values are stored premultiplied with the alpha value.
        *  If you change this value, the color data is updated accordingly. If you don't want
        *  that, use the 'setPremultipliedAlpha' method instead. */
        public function get premultipliedAlpha():Boolean { return mPremultipliedAlpha; }
        public function set premultipliedAlpha(value:Boolean):void
        {
            setPremultipliedAlpha(value);
        }
        
        /** The total number of vertices. */
        public function get numVertices():int { return mNumVertices; }
        public function set numVertices(value:int):void
        {
			var newLen:int = value * ELEMENTS_PER_VERTEX;
			var oldLen:int = mRawData.length;
			if(newLen > oldLen){
				mRawData.fixed = false;
				mRawData.length = newLen;
				
				//set default alpha.
				var startIndex:int = mNumVertices * ELEMENTS_PER_VERTEX + COLOR_OFFSET + 3;	//3 for r.g.b
				
				for (var i:int = startIndex; i < newLen; i += ELEMENTS_PER_VERTEX)
					mRawData[i] = 1.0; // alpha should be '1' per default
				
            	mRawData.fixed = true;
			}
            
            mNumVertices = value;
        }
        
        /** The raw vertex data; not a copy! */
        [Inline]
        public function get rawData():Vector.<Number> { return mRawData; }

        [Inline]
        public function set tintedDirty(value:Boolean):void { mTintedDirty = value; }
    }
}
