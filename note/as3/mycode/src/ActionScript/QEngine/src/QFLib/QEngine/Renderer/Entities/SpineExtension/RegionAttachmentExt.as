/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/23.
 */
package QFLib.QEngine.Renderer.Entities.SpineExtension
{
    import QFLib.QEngine.Renderer.Utils.VertexData;
    import QFLib.QEngine.ThirdParty.Spine.Bone;
    import QFLib.QEngine.ThirdParty.Spine.attachments.RegionAttachment;

    public class RegionAttachmentExt extends RegionAttachment
    {
        public function RegionAttachmentExt( name : String )
        {
            super( name );
        }

        override public function computeWorldVertices( x : Number, y : Number, bone : Bone, worldVertices : Vector.<Number> ) : void
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

        public function computeWorldVertexData( x : Number, y : Number, bone : Bone, worldVertices : VertexData ) : void
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

            var wx1 : Number = x1 * m00 + y1 * m01 + x;
            var wy1 : Number = x1 * m10 + y1 * m11 + y;
            var wx2 : Number = x2 * m00 + y2 * m01 + x;
            var wy2 : Number = x2 * m10 + y2 * m11 + y;
            var wx3 : Number = x3 * m00 + y3 * m01 + x;
            var wy3 : Number = x3 * m10 + y3 * m11 + y;
            var wx4 : Number = x4 * m00 + y4 * m01 + x;
            var wy4 : Number = x4 * m10 + y4 * m11 + y;
            worldVertices.setPosition( 0, wx1 * 0.01, -wy1 * 0.01, 0.0 );
            worldVertices.setPosition( 1, wx4 * 0.01, -wy4 * 0.01, 0.0 );
            worldVertices.setPosition( 2, wx2 * 0.01, -wy2 * 0.01, 0.0 );
            worldVertices.setPosition( 3, wx3 * 0.01, -wy3 * 0.01, 0.0 );
        }
    }
}
