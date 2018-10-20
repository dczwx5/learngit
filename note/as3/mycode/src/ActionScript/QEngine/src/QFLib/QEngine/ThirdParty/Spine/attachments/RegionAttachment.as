/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.attachments
{
    import QFLib.QEngine.ThirdParty.Spine.Bone;

    public dynamic class RegionAttachment extends Attachment
    {
        public static const X1 : int = 0;
        public static const Y1 : int = 1;
        public static const X2 : int = 2;
        public static const Y2 : int = 3;
        public static const X3 : int = 4;
        public static const Y3 : int = 5;
        public static const X4 : int = 6;
        public static const Y4 : int = 7;

        public function RegionAttachment( name : String )
        {
            super( name );
            offset.length = 8;
            uvs.length = 8;
        }
        public var x : Number;
        public var y : Number;
        public var scaleX : Number = 1;
        public var scaleY : Number = 1;
        public var rotation : Number;
        public var width : Number;
        public var height : Number;
        public var r : Number = 1;
        public var g : Number = 1;
        public var b : Number = 1;
        public var a : Number = 1;
        public var path : String;
                public var rendererObject : Object; // Pixels stripped from the bottom left, unrotated.
public var regionOffsetX : Number;
                public var regionOffsetY : Number; // Unrotated, stripped size.
public var regionWidth : Number;
                public var regionHeight : Number; // Unrotated, unstripped size.
public var regionOriginalWidth : Number;
        public var regionOriginalHeight : Number;
        public var offset : Vector.<Number> = new Vector.<Number>();
        public var uvs : Vector.<Number> = new Vector.<Number>();

        public function setUVs( u : Number, v : Number, u2 : Number, v2 : Number, rotate : Boolean ) : void
        {
            if( rotate )
            {
                uvs[ X2 ] = u;
                uvs[ Y2 ] = v2;
                uvs[ X3 ] = u;
                uvs[ Y3 ] = v;
                uvs[ X4 ] = u2;
                uvs[ Y4 ] = v;
                uvs[ X1 ] = u2;
                uvs[ Y1 ] = v2;
            } else
            {
                uvs[ X1 ] = u;
                uvs[ Y1 ] = v2;
                uvs[ X2 ] = u;
                uvs[ Y2 ] = v;
                uvs[ X3 ] = u2;
                uvs[ Y3 ] = v;
                uvs[ X4 ] = u2;
                uvs[ Y4 ] = v2;
            }
        }

        public function updateOffset() : void
        {
            var regionScaleX : Number = width / regionOriginalWidth * scaleX;
            var regionScaleY : Number = height / regionOriginalHeight * scaleY;
            var localX : Number = -width / 2 * scaleX + regionOffsetX * regionScaleX;
            var localY : Number = -height / 2 * scaleY + regionOffsetY * regionScaleY;
            var localX2 : Number = localX + regionWidth * regionScaleX;
            var localY2 : Number = localY + regionHeight * regionScaleY;
            var radians : Number = rotation * Math.PI / 180;
            var cos : Number = Math.cos( radians );
            var sin : Number = Math.sin( radians );
            var localXCos : Number = localX * cos + x;
            var localXSin : Number = localX * sin;
            var localYCos : Number = localY * cos + y;
            var localYSin : Number = localY * sin;
            var localX2Cos : Number = localX2 * cos + x;
            var localX2Sin : Number = localX2 * sin;
            var localY2Cos : Number = localY2 * cos + y;
            var localY2Sin : Number = localY2 * sin;
            offset[ X1 ] = localXCos - localYSin;
            offset[ Y1 ] = localYCos + localXSin;
            offset[ X2 ] = localXCos - localY2Sin;
            offset[ Y2 ] = localY2Cos + localXSin;
            offset[ X3 ] = localX2Cos - localY2Sin;
            offset[ Y3 ] = localY2Cos + localX2Sin;
            offset[ X4 ] = localX2Cos - localYSin;
            offset[ Y4 ] = localYCos + localX2Sin;
        }

        public function computeWorldVertices( x : Number, y : Number, bone : Bone, worldVertices : Vector.<Number> ) : void
        {
            x += bone.worldX;
            y += bone.worldY;
            var m00 : Number = bone.a;
            var m01 : Number = bone.b;
            var m10 : Number = bone.c;
            var m11 : Number = bone.d;
            var x1 : Number = offset[ X1 ];
            var y1 : Number = offset[ Y1 ];
            var x2 : Number = offset[ X2 ];
            var y2 : Number = offset[ Y2 ];
            var x3 : Number = offset[ X3 ];
            var y3 : Number = offset[ Y3 ];
            var x4 : Number = offset[ X4 ];
            var y4 : Number = offset[ Y4 ];
            worldVertices[ X1 ] = x1 * m00 + y1 * m01 + x;
            worldVertices[ Y1 ] = x1 * m10 + y1 * m11 + y;
            worldVertices[ X2 ] = x2 * m00 + y2 * m01 + x;
            worldVertices[ Y2 ] = x2 * m10 + y2 * m11 + y;
            worldVertices[ X3 ] = x3 * m00 + y3 * m01 + x;
            worldVertices[ Y3 ] = x3 * m10 + y3 * m11 + y;
            worldVertices[ X4 ] = x4 * m00 + y4 * m01 + x;
            worldVertices[ Y4 ] = x4 * m10 + y4 * m11 + y;
        }
    }

}
