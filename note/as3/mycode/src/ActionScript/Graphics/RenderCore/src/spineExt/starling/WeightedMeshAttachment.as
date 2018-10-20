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
    import spine.attachments.WeightedMeshAttachment;

    public class WeightedMeshAttachment extends spine.attachments.WeightedMeshAttachment
    {
        public var texture : Texture = null;

        public function WeightedMeshAttachment ( name : String )
        {
            super ( name );
        }

        public function _computeWorldVertices ( x : Number, y : Number, pSlot : Slot, offset : int, num : int, worldVertices : VertexData ) : void
        {
            var skeletonBones : Vector.<Bone> = pSlot.skeleton.bones;
            var weights : Vector.<Number> = this.weights;
            var bones : Vector.<int> = this.bones;

            var w : int = 0, v : int = 0, b : int = 0, f : int = 0, n : int = bones.length, nn : int;
            var wx : Number, wy : Number, bone : Bone, vx : Number, vy : Number, weight : Number;
            var worldX : Number, worldY : Number;
            if ( pSlot.attachmentVertices.length == 0 )
            {
                for ( ; v < n; w += 1 )
                {
                    wx = 0;
                    wy = 0;
                    nn = bones[ v++ ] + v;
                    for ( ; v < nn; v++, b += 3 )
                    {
                        bone = skeletonBones[ bones[ v ] ];
                        vx = weights[ b ];
                        vy = weights[ int ( b + 1 ) ];
                        weight = weights[ int ( b + 2 ) ];
                        wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
                        wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
                    }

                    worldX = wx + x;
                    worldY = wy + y;
                    worldVertices.setPosition ( w + offset, worldX, worldY );
                }
            }
            else
            {
                var ffd : Vector.<Number> = pSlot.attachmentVertices;
                for ( ; v < n; w += 1 )
                {
                    wx = 0;
                    wy = 0;
                    nn = bones[ v++ ] + v;
                    for ( ; v < nn; v++, b += 3, f += 2 )
                    {
                        bone = skeletonBones[ bones[ v ] ];
                        vx = weights[ b ] + ffd[ f ];
                        vy = weights[ int ( b + 1 ) ] + ffd[ int ( f + 1 ) ];
                        weight = weights[ int ( b + 2 ) ];
                        wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
                        wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
                    }
                    worldX = wx + x;
                    worldY = wy + y;
                    worldVertices.setPosition ( w + offset, worldX, worldY );
                }
            }
        }
    }
}
