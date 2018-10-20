//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2017/4/13.
 */
package spineExt.starling
{
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;

    import spine.Bone;
    import spine.Slot;
    import spine.attachments.RegionAttachment;

    public class RegionAttachment extends spine.attachments.RegionAttachment
    {
        public var texture : Texture = null;

        public function RegionAttachment ( name : String )
        {
            super ( name );
        }

        public function _computeWorldVertices ( x : Number, y : Number, pSlot : Slot, verticesOffset : int, worldVertices : VertexData ) : void
        {
            var bone : Bone = pSlot.bone;
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

            worldVertices.setPosition ( 0 + verticesOffset, wx2, wy2 );
            worldVertices.setPosition ( 1 + verticesOffset, wx3, wy3 );
            worldVertices.setPosition ( 2 + verticesOffset, wx1, wy1 );
            worldVertices.setPosition ( 3 + verticesOffset, wx4, wy4 );
        }
    }
}