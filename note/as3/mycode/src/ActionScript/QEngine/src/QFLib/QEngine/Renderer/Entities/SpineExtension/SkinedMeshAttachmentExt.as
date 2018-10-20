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
    import QFLib.QEngine.ThirdParty.Spine.attachments.WeightedMeshAttachment;

    public class SkinedMeshAttachmentExt extends WeightedMeshAttachment
    {
        public function SkinedMeshAttachmentExt( name : String )
        {
            super( name );
        }

        override public function computeWorldVertices( x : Number, y : Number, slot : Slot, worldVertices : Vector.<Number> ) : void
        {
            var skeletonBones : Vector.<Bone> = slot.skeleton.bones;
            var weights : Vector.<Number> = this.weights;
            var bones : Vector.<int> = this.bones;

            var w : int = 0, v : int = 0, b : int = 0, f : int = 0, n : int = bones.length, nn : int;
            var wx : Number, wy : Number, bone : Bone, vx : Number, vy : Number, weight : Number;
            if( slot.attachmentVertices.length == 0 )
            {
                for( ; v < n; w += 2 )
                {
                    wx = 0;
                    wy = 0;
                    nn = bones[ v++ ] + v;
                    for( ; v < nn; v++, b += 3 )
                    {
                        bone = skeletonBones[ bones[ v ] ];
                        vx = weights[ b ];
                        vy = weights[ int( b + 1 ) ];
                        weight = weights[ int( b + 2 ) ];
                        wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
                        wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
                    }
                    worldVertices[ w ] = wx + x;
                    worldVertices[ int( w + 1 ) ] = wy + y;
                }
            }
            else
            {
                var ffd : Vector.<Number> = slot.attachmentVertices;
                for( ; v < n; w += 2 )
                {
                    wx = 0;
                    wy = 0;
                    nn = bones[ v++ ] + v;
                    for( ; v < nn; v++, b += 3, f += 2 )
                    {
                        bone = skeletonBones[ bones[ v ] ];
                        vx = weights[ b ] + ffd[ f ];
                        vy = weights[ int( b + 1 ) ] + ffd[ int( f + 1 ) ];
                        weight = weights[ int( b + 2 ) ];
                        wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
                        wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
                    }
                    worldVertices[ w ] = wx + x;
                    worldVertices[ int( w + 1 ) ] = wy + y;
                }
            }
        }

        public function computeWorldVertexData( x : Number, y : Number, slot : Slot, worldVertices : VertexData ) : void
        {
            var skeletonBones : Vector.<Bone> = slot.skeleton.bones;
            var weights : Vector.<Number> = this.weights;
            var bones : Vector.<int> = this.bones;

            var w : int = 0, v : int = 0, b : int = 0, f : int = 0, n : int = bones.length, nn : int;
            var wx : Number, wy : Number, bone : Bone, vx : Number, vy : Number, weight : Number;
            if( slot.attachmentVertices.length == 0 )
            {
                for( ; v < n; w += 1 )
                {
                    wx = 0;
                    wy = 0;
                    nn = bones[ v++ ] + v;
                    for( ; v < nn; v++, b += 3 )
                    {
                        bone = skeletonBones[ bones[ v ] ];
                        vx = weights[ b ];
                        vy = weights[ int( b + 1 ) ];
                        weight = weights[ int( b + 2 ) ];
                        wx += ( vx * bone.a + vy * bone.b + bone.worldX ) * weight;
                        wy += ( vx * bone.c + vy * bone.d + bone.worldY ) * weight;
                    }
                    worldVertices.setPosition( w, ( wx + x ) * 0.01, -( wy + y ) * 0.01, 0.0 );
                }
            }
            else
            {
                var ffd : Vector.<Number> = slot.attachmentVertices;
                for( ; v < n; w += 1 )
                {
                    wx = 0;
                    wy = 0;
                    nn = bones[ v++ ] + v;
                    for( ; v < nn; v++, b += 3, f += 2 )
                    {
                        bone = skeletonBones[ bones[ v ] ];
                        vx = weights[ b ] + ffd[ f ];
                        vy = weights[ int( b + 1 ) ] + ffd[ int( f + 1 ) ];
                        weight = weights[ int( b + 2 ) ];
                        wx += ( vx * bone.a + vy * bone.b + bone.worldX ) * weight;
                        wy += ( vx * bone.c + vy * bone.d + bone.worldY ) * weight;
                    }
                    worldVertices.setPosition( w, ( wx + x ) * 0.01, -( wy + y ) * 0.01, 0.0 );
                }
            }
        }
    }
}
