/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Utils
{
    import QFLib.Math.CAABBox3;
    import QFLib.Math.CMatrix4;
    import QFLib.Math.CVector2;
    import QFLib.Math.CVector3;
    import QFLib.Math.CVector4;
    import QFLib.Math.MatrixUtil;

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
        public static const ELEMENTS_PER_VERTEX : int = 9;

        /** The offset of position data (x, y, z) within a vertex. */
        public static const POSITION_OFFSET : int = 0;

        /** The offset of color data (r, g, b, a) within a vertex. */
        public static const COLOR_OFFSET : int = 3;

        /** The offset of texture coordinates (u, v) within a vertex. */
        public static const TEXCOORD_OFFSET : int = 7;

        /** Helper object. */
        private static var sPositionHelper : CVector4 = new CVector4();
        private static var sPositionResult : CVector4 = new CVector4();
        private static var sVectorNumberPool : Array = [];

        private static function getVectorNumber() : Vector.<Number>
        {
            if( sVectorNumberPool.length > 0 )
            {
                return sVectorNumberPool.pop();
            }
            return new Vector.<Number>();
        }

        private static function recycleVectorNumber( value : Vector.<Number> ) : void
        {
            sVectorNumberPool.push( value );
        }

        /** Create a new VertexData object with a specified number of vertices. */
        public function VertexData( numVertices : int, premultipliedAlpha : Boolean = false, useVectorNumberPool : Boolean = false )
        {
            mUseVectorNumberPool = useVectorNumberPool;
            if( mUseVectorNumberPool )
            {
                mRawData = getVectorNumber();
            }
            else
            {
                mRawData = new Vector.<Number>();
            }
            mPremultipliedAlpha = premultipliedAlpha;
            this.numVertices = numVertices;
            mTinted = false;
            mTintedDirty = true;
        }
        private var mRawData : Vector.<Number>;
        private var mNumVertices : int;
        private var mPremultipliedAlpha : Boolean;
        private var mTinted : Boolean;
        private var mTintedDirty : Boolean;

        // functions
        private var mUseVectorNumberPool : Boolean;
        private var mAABBox3Dirty : Boolean = true;

        /** Indicates if any vertices have a non-white color or are not fully opaque. */
        public function get tinted() : Boolean
        {
            if( mTintedDirty )
            {
                var offset : int = COLOR_OFFSET;
                for( var i : int = 0; i < mNumVertices; ++i )
                {
                    for( var j : int = 0; j < 4; ++j )
                    {
                        if( mRawData[ int( offset + j ) ] != 1.0 )
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

        /** Indicates if the rgb values are stored premultiplied with the alpha value.
         *  If you change this value, the color data is updated accordingly. If you don't want
         *  that, use the 'setPremultipliedAlpha' method instead. */
        public function get premultipliedAlpha() : Boolean
        {
            return mPremultipliedAlpha;
        }

        public function set premultipliedAlpha( value : Boolean ) : void
        {
            setPremultipliedAlpha( value );
        }

        /** The total number of vertices. */
        public function get numVertices() : int
        {
            return mNumVertices;
        }

        public function set numVertices( value : int ) : void
        {
            var newLen : int = value * ELEMENTS_PER_VERTEX;
            var oldLen : int = mRawData.length;
            if( newLen > oldLen )
            {
                mRawData.fixed = false;
                mRawData.length = newLen;

                //set default alpha.
                var startIndex : int = mNumVertices * ELEMENTS_PER_VERTEX + COLOR_OFFSET + 3;	//3 for r.g.b
                // alpha should be '1' per default
                for( var i : int = startIndex; i < newLen; i += ELEMENTS_PER_VERTEX )
                    mRawData[ i ] = 1.0;

                mRawData.fixed = true;
            }

            mNumVertices = value;
        }

        /** The raw vertex data; not a copy! */
        [inline]
        public function get rawData() : Vector.<Number>
        {
            return mRawData;
        }

        [inline]
        public function set tintedDirty( value : Boolean ) : void
        {
            mTintedDirty = value;
        }

        // utility functions

        public function dispose() : void
        {
            if( mRawData )
            {
                if( mUseVectorNumberPool )
                    recycleVectorNumber( mRawData );
                mRawData = null;
            }
        }

        /** Creates a duplicate of either the complete vertex data object, or of a subset.
         *  To clone all vertices, set 'numVertices' to '-1'. */
        public function clone( vertexID : int = 0, numVertices : int = -1 ) : VertexData
        {
            if( numVertices < 0 || vertexID + numVertices > mNumVertices )
                numVertices = mNumVertices - vertexID;

            var clone : VertexData = new VertexData( 0, mPremultipliedAlpha );
            clone.mNumVertices = numVertices;
            clone.mRawData = mRawData.slice( vertexID * ELEMENTS_PER_VERTEX,
                    numVertices * ELEMENTS_PER_VERTEX );
            clone.mRawData.fixed = true;
            return clone;
        }

        /** Copies the vertex data (or a range of it, defined by 'vertexID' and 'numVertices')
         *  of this instance to another vertex data object, starting at a certain index. */
        public function copyTo( targetData : VertexData, targetVertexID : int = 0,
                                vertexID : int = 0, numVertices : int = -1 ) : void
        {
            copyTransformedTo( targetData, targetVertexID, null, vertexID, numVertices );
        }

        /** Transforms the vertex position of this instance by a certain matrix and copies the
         *  result to another VertexData instance. Limit the operation to a range of vertices
         *  via the 'vertexID' and 'numVertices' parameters. */
        public function copyTransformedTo( targetData : VertexData, targetVertexID : int = 0,
                                           matrix : CMatrix4 = null,
                                           vertexID : int = 0, numVertices : int = -1 ) : void
        {
            if( numVertices < 0 || vertexID + numVertices > mNumVertices )
                numVertices = mNumVertices - vertexID;

            var x : Number, y : Number, z : Number;
            var targetRawData : Vector.<Number> = targetData.mRawData;
            var targetIndex : int = targetVertexID * ELEMENTS_PER_VERTEX;
            var sourceIndex : int = vertexID * ELEMENTS_PER_VERTEX;
            var sourceEnd : int = (vertexID + numVertices) * ELEMENTS_PER_VERTEX;

            if( matrix )
            {
                while( sourceIndex < sourceEnd )
                {
                    x = mRawData[ sourceIndex ];
                    ++sourceIndex;
                    y = mRawData[ sourceIndex ];
                    ++sourceIndex;
                    z = mRawData[ sourceIndex ];
                    ++sourceIndex;

                    sPositionHelper.setValueXYZW( x, y, z, 1.0 );
                    QFLib.Math.MatrixUtil.matrixPremultipyVector4( matrix, sPositionHelper, sPositionResult );

                    targetRawData[ targetIndex++ ] = sPositionResult.x;
                    targetRawData[ targetIndex++ ] = sPositionResult.y;
                    targetRawData[ targetIndex++ ] = sPositionResult.z;
                    targetRawData[ targetIndex++ ] = mRawData[ sourceIndex++ ];
                    targetRawData[ targetIndex++ ] = mRawData[ sourceIndex++ ];
                    targetRawData[ targetIndex++ ] = mRawData[ sourceIndex++ ];
                    targetRawData[ targetIndex++ ] = mRawData[ sourceIndex++ ];
                    targetRawData[ targetIndex++ ] = mRawData[ sourceIndex++ ];
                    targetRawData[ targetIndex++ ] = mRawData[ sourceIndex++ ];
                }
            }
            else
            {
                while( sourceIndex < sourceEnd )
                {
                    targetRawData[ int( targetIndex++ ) ] = mRawData[ int( sourceIndex++ ) ];
                }
            }

            targetData.tintedDirty = true;
        }

        /** Appends the vertices from another VertexData object. */
        public function append( data : VertexData ) : void
        {
            mRawData.fixed = false;

            var targetIndex : int = mNumVertices * ELEMENTS_PER_VERTEX;
            var rawData : Vector.<Number> = data.mRawData;
            var rawDataLength : int = rawData.length;

            for( var i : int = 0; i < rawDataLength; ++i )
                mRawData[ targetIndex++ ] = rawData[ i ];

            mNumVertices += data.numVertices;
            mRawData.fixed = true;

            if( !tinted )
            {
                mTinted = data.tinted;
            }
        }

        /** Updates the position values of a vertex. */
        [Inline]
        final public function setPosition( vertexID : int, x : Number, y : Number, z : Number ) : void
        {
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            mRawData[ offset ] = x;
            mRawData[ offset + 1 ] = y;
            mRawData[ offset + 2 ] = z;
        }

        [Inline]
        /** Returns the position of a vertex. */
        final public function getPosition( vertexID : int, position : CVector3 ) : void
        {
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            position.x = mRawData[ offset ];
            position.y = mRawData[ offset + 1 ];
            position.z = mRawData[ offset + 2 ];
        }

        public function setColor( color : uint ) : void
        {
            var i : int = 0;
            while( i < mNumVertices )
            {
                setVertexColor( i, color );
                ++i;
            }
        }

        public function setColorAndAlphaRGBA( red : Number = 1.0, green : Number = 1.0, blue : Number = 1.0, alpha : Number = 1.0 ) : void
        {
            var multiplier : Number = mPremultipliedAlpha ? alpha : 1.0;

            red *= multiplier;
            green *= multiplier;
            blue *= multiplier;

            var index : int = 0;
            var i : int = 0;
            while( i < mNumVertices )
            {
                index = i * ELEMENTS_PER_VERTEX + COLOR_OFFSET;
                mRawData[ index ] = red;
                mRawData[ index + 1 ] = green;
                mRawData[ index + 2 ] = blue;
                mRawData[ index + 3 ] = alpha;
                ++i;
            }

            if( multiplier != 1.0 ) mTinted = true;
            else if( !tinted ) mTinted = ( red != 1.0 && green != 1.0 && blue != 1.0 );
        }

        public function setColorWithAlpha( color : uint, alpha : Number ) : void
        {
            var i : int = 0;
            while( i < mNumVertices )
            {
                setVertexColorAndAlpha( i, color, alpha );
                ++i;
            }
        }

        /** Updates the RGB color and alpha value of a vertex in one step. */
        public function setVertexColorAndAlpha( vertexID : int, color : uint, alpha : Number ) : void
        {
            if( alpha < 0.001 )    alpha = 0.001; // zero alpha would wipe out all color data
            else if( alpha > 1.0 ) alpha = 1.0;

            var offset : int = vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET;
            var multiplier : Number = mPremultipliedAlpha ? alpha : 1.0;

            mRawData[ offset ] = ((color >> 16) & 0xff) / 255.0 * multiplier;
            mRawData[ offset + 1 ] = ((color >> 8) & 0xff) / 255.0 * multiplier;
            mRawData[ offset + 2 ] = ( color & 0xff) / 255.0 * multiplier;
            mRawData[ offset + 3 ] = alpha;

            if( multiplier != 1.0 ) mTinted = true;
            else if( !tinted ) mTinted = color != 0xffffff;
        }

        /** Updates the RGB color values of a vertex (alpha is not changed). */
        [Inline]
        final public function setVertexColor( vertexID : int, color : uint ) : void
        {
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET;
            var multiplier : Number = mPremultipliedAlpha ? mRawData[ int( offset + 3 ) ] : 1.0;
            mRawData[ offset ] = ((color >> 16) & 0xff) / 255.0 * multiplier;
            mRawData[ offset + 1 ] = ((color >> 8) & 0xff) / 255.0 * multiplier;
            mRawData[ offset + 2 ] = ( color & 0xff) / 255.0 * multiplier;

            if( multiplier != 1.0 )
            {
                mTinted = true;
            }
            else if( !tinted )
            {
                mTinted = color != 0xffffff;
            }
        }

        public function setAlpha( alpha : Number ) : void
        {
            var i : int = 0;
            while( i < mNumVertices )
            {
                setVertexAlpha( i, alpha );
                i++;
            }
        }

        /** Updates the alpha value of a vertex (range 0-1). */
        public function setVertexAlpha( vertexID : int, alpha : Number ) : void
        {
            if( mPremultipliedAlpha )
            {
                setVertexColorAndAlpha( vertexID, getColor( vertexID ), alpha );
            }
            else
            {
                mRawData[ int( vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET + 3 ) ] = alpha;

                if( !tinted && alpha != 1.0 )
                {
                    mTinted = true;
                }
            }
        }

        /** Returns the RGB color of a vertex (no alpha). */
        public function getColor( vertexID : int ) : uint
        {
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET;
            var divisor : Number = mPremultipliedAlpha ? mRawData[ int( offset + 3 ) ] : 1.0;

            if( divisor == 0 ) return 0;
            else
            {
                var red : Number = mRawData[ offset ] / divisor;
                var green : Number = mRawData[ offset + 1 ] / divisor;
                var blue : Number = mRawData[ offset + 2 ] / divisor;

                return (int( red * 255 ) << 16) | (int( green * 255 ) << 8) | int( blue * 255 );
            }
        }

        /** Returns the alpha value of a vertex in the range 0-1. */
        public function getAlpha( vertexID : int ) : Number
        {
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + COLOR_OFFSET + 3;
            return mRawData[ offset ];
        }

        /** Updates the texture coordinates of a vertex (range 0-1). */
        [Inline]
        final public function setTexCoords( vertexID : int, u : Number, v : Number ) : void
        {
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + TEXCOORD_OFFSET;
            mRawData[ offset ] = u;
            mRawData[ offset + 1 ] = v;
        }

        /** Returns the texture coordinates of a vertex in the range 0-1. */
        public function getTexCoords( vertexID : int, texCoords : CVector2 ) : void
        {
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + TEXCOORD_OFFSET;
            texCoords.x = mRawData[ offset ];
            texCoords.y = mRawData[ offset + 1 ];
        }

        /** Translate the position of a vertex by a certain offset. */
        public function translateVertex( vertexID : int, deltaX : Number, deltaY : Number, deltaZ : Number ) : void
        {
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;
            mRawData[ offset ] += deltaX;
            mRawData[ offset + 1 ] += deltaY;
            mRawData[ offset + 2 ] += deltaZ;
        }

        /** Transforms the position of subsequent vertices by multiplication with a
         *  transformation matrix. */
        public function transformVertex( vertexID : int, matrix : CMatrix4, numVertices : int = 1 ) : void
        {
            var x : Number, y : Number, z : Number;
            var offset : int = vertexID * ELEMENTS_PER_VERTEX + POSITION_OFFSET;

            for( var i : int = 0; i < numVertices; ++i )
            {
                x = mRawData[ offset ];
                y = mRawData[ offset + 1 ];
                z = mRawData[ offset + 2 ];

                sPositionHelper.setValueXYZW( x, y, z, 1.0 );
                QFLib.Math.MatrixUtil.matrixPremultipyVector4( matrix, sPositionHelper, sPositionResult );

                mRawData[ offset ] = sPositionResult.x;
                mRawData[ offset + 1 ] = sPositionResult.y;
                mRawData[ offset + 2 ] = sPositionResult.z;

                offset += ELEMENTS_PER_VERTEX;
            }
        }

        /** Sets all vertices of the object to the same color values. */
        public function setUniformColor( color : uint ) : void
        {
            var colorReverse : Number = 1.0 / 255.0;
            var r : Number = ((color >> 16) & 0xff) * colorReverse;
            var g : Number = ((color >> 8) & 0xff) * colorReverse;
            var b : Number = ( color & 0xff) * colorReverse;

            var offset : int = COLOR_OFFSET;
            var multiplier : Number;

            if( mPremultipliedAlpha )
            {
                for( var i : int = 0; i < mNumVertices; ++i )
                {
                    multiplier = mRawData[ int( offset + 3 ) ];
                    mRawData[ offset ] = r * multiplier;
                    mRawData[ int( offset + 1 ) ] = g * multiplier;
                    mRawData[ int( offset + 2 ) ] = b * multiplier;
                    offset += ELEMENTS_PER_VERTEX;

                    if( multiplier != 1.0 )
                    {
                        mTinted = true;
                    }
                }
            }
            else
            {
                for( i = 0; i < mNumVertices; ++i )
                {
                    mRawData[ offset ] = r;
                    mRawData[ int( offset + 1 ) ] = g;
                    mRawData[ int( offset + 2 ) ] = b;
                    offset += ELEMENTS_PER_VERTEX;
                }
            }

            if( !tinted )
            {
                mTinted = color != 0xffffff;
            }
        }

        /** Sets all vertices of the object to the same alpha values. */
        public function setUniformAlpha( alpha : Number ) : void
        {
            for( var i : int = 0; i < mNumVertices; ++i )
                setVertexAlpha( i, alpha );
        }

        /** Multiplies the alpha value of subsequent vertices with a certain factor. */
        public function scaleAlpha( vertexID : int, factor : Number, numVertices : int = 1 ) : void
        {
            if( factor == 1.0 ) return;
            if( numVertices < 0 || vertexID + numVertices > mNumVertices )
                numVertices = mNumVertices - vertexID;

            var i : int;

            for( i = 0; i < numVertices; ++i )
                setVertexAlpha( vertexID + i, getAlpha( vertexID + i ) * factor );
        }

        public function getAABBox3( transformMatrix : CMatrix4 = null, result : CAABBox3 = null ) : CAABBox3
        {
            if( result == null ) result = new CAABBox3( CVector3.zero() );

            if( mAABBox3Dirty )
            {
                computeLocalAABBox3( result );
                if( transformMatrix == null )
                {

                }
                else
                {

                }
            }

            return result;
        }

        /** Creates a string that contains the values of all included vertices. */
        public function toString() : String
        {
            var result : String = "[VertexData \n";
            var position : CVector3 = new CVector3();
            var texCoords : CVector2 = new CVector2();
            var color : uint;

            for( var i : int = 0; i < numVertices; ++i )
            {
                getPosition( i, position );
                getTexCoords( i, texCoords );
                result += "  [Vertex " + i + ": " +
                        "x=" + position.x.toFixed( 1 ) + ", " +
                        "y=" + position.y.toFixed( 1 ) + ", " +
                        "rgb=" + getColor( i ).toString( 16 ) + ", " +
                        "a=" + getAlpha( i ).toFixed( 2 ) + ", " +
                        "u=" + texCoords.x.toFixed( 4 ) + ", " +
                        "v=" + texCoords.y.toFixed( 4 ) + "]" +
                        (i == numVertices - 1 ? "\n" : ",\n");
            }

            return result + "]";
        }

        /** Changes the way alpha and color values are stored. Optionally updates all exisiting
         *  vertices. */
        public function setPremultipliedAlpha( value : Boolean, updateData : Boolean = true ) : void
        {
            if( value == mPremultipliedAlpha ) return;

            if( updateData )
            {
                var dataLength : int = mNumVertices * ELEMENTS_PER_VERTEX;

                // src:
                for( var i : int = COLOR_OFFSET; i < dataLength; i += ELEMENTS_PER_VERTEX )
                {
                    var alpha : Number = mRawData[ int( i + 3 ) ];
                    var divisor : Number = mPremultipliedAlpha ? alpha : 1.0;
                    var multiplier : Number = value ? alpha : 1.0;

                    if( divisor != 0 )
                    {
                        mRawData[ i ] = mRawData[ i ] / divisor * multiplier;
                        mRawData[ i + 1 ] = mRawData[ i + 1 ] / divisor * multiplier;
                        mRawData[ i + 2 ] = mRawData[ i + 2 ] / divisor * multiplier;
                    }
                }

                mTintedDirty = true;
            }

            mPremultipliedAlpha = value;
        }

        private function computeLocalAABBox3( result : CAABBox3 ) : void
        {

        }
    }
}
