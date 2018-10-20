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
    import QFLib.QEngine.ThirdParty.Spine.Slot;
    import QFLib.QEngine.ThirdParty.Spine.attachments.MeshAttachment;

    public class MeshAttachmentExt extends MeshAttachment
    {
        public function MeshAttachmentExt( name : String )
        {
            super( name );
        }

        override public function computeWorldVertices( x : Number, y : Number, slot : Slot, worldVertices : Vector.<Number> ) : void
        {
            var bone : Bone = slot.bone;
            x += bone.worldX;
            y += bone.worldY;
            var m00 : Number = bone.a;
            var m01 : Number = bone.b;
            var m10 : Number = bone.c;
            var m11 : Number = bone.d;
            var vertices : Vector.<Number> = this.vertices;
            var verticesCount : int = vertices.length;
            if( slot.attachmentVertices.length == verticesCount ) vertices = slot.attachmentVertices;
            for( var i : int = 0, ii : int = 0; i < verticesCount; i += 2, ii += 2 )
            {
                var vx : Number = vertices[ i ];
                var vy : Number = vertices[ int( i + 1 ) ];
                worldVertices[ ii ] = vx * m00 + vy * m01 + x;
                worldVertices[ int( ii + 1 ) ] = vx * m10 + vy * m11 + y;
            }
        }

        public function computeWorldVertexData( x : Number, y : Number, slot : Slot, worldVertices : VertexData ) : void
        {
            var bone : Bone = slot.bone;
            x += bone.worldX;
            y += bone.worldY;
            var m00 : Number = bone.a;
            var m01 : Number = bone.b;
            var m10 : Number = bone.c;
            var m11 : Number = bone.d;
            var vertices : Vector.<Number> = this.vertices;
            var verticesCount : int = vertices.length;
            if( slot.attachmentVertices.length == verticesCount ) vertices = slot.attachmentVertices;

            var vx : Number = 0.0, vy : Number = 0.0;
            var wvx : Number = 0.0, wvy : Number = 0.0;
            for( var i : int = 0, ii : int = 0; i < verticesCount; i += 2, ii += 1 )
            {
                vx = vertices[ i ];
                vy = vertices[ int( i + 1 ) ];
                wvx = vx * m00 + vy * m01 + x;
                wvy = vx * m10 + vy * m11 + y;

                worldVertices.setPosition( ii, wvx * 0.01, -wvy * 0.01, 0.0 );
            }
        }
    }
}
