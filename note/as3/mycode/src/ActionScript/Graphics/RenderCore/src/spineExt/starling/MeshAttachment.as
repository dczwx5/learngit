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
    import spine.attachments.MeshAttachment;

    public class MeshAttachment extends spine.attachments.MeshAttachment
    {
        public var texture : Texture = null;

        public function MeshAttachment ( name : String )
        {
            super ( name );
        }

        public function _computeWorldVertices ( x : Number, y : Number, pSlot : Slot, offset : int, num : int, worldVertices : VertexData ) : void
        {
            var bone : Bone = pSlot.bone;
            x += bone.worldX;
            y += bone.worldY;
            var m00 : Number = bone.a;
            var m01 : Number = bone.b;
            var m10 : Number = bone.c;
            var m11 : Number = bone.d;
            var vertices : Vector.<Number> = this.vertices;
            var verticesCount : int = vertices.length;
            if ( pSlot.attachmentVertices.length == verticesCount ) vertices = pSlot.attachmentVertices;
            for ( var i : int = 0, ii : int = 0; i < verticesCount; i += 2, ii += 1 )
            {
                var vx : Number = vertices[ i ];
                var vy : Number = vertices[ int ( i + 1 ) ];
                var wx : Number = vx * m00 + vy * m01 + x;
                var wy : Number = vx * m10 + vy * m11 + y;

                worldVertices.setPosition ( offset + ii, wx, wy );
            }
        }
    }
}
