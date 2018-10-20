/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.attachments
{
    import QFLib.QEngine.ThirdParty.Spine.Bone;
    import QFLib.QEngine.ThirdParty.Spine.Slot;

    public dynamic class WeightedMeshAttachment extends Attachment implements FfdAttachment
    {
        public function WeightedMeshAttachment( name : String )
        {
            super( name );
        }
        public var bones : Vector.<int>;
        public var weights : Vector.<Number>;
        public var uvs : Vector.<Number>;
        public var regionUVs : Vector.<Number>;
        public var triangles : Vector.<uint>;
        public var hullLength : int;
        public var r : Number = 1;
        public var g : Number = 1;
        public var b : Number = 1;
        public var a : Number = 1;
        public var inheritFFD : Boolean;

        public var path : String;
        public var rendererObject : Object;
        public var regionU : Number;
        public var regionV : Number;
        public var regionU2 : Number;
        public var regionV2 : Number;
        public var regionRotate : Boolean;
        public var regionOffsetX : Number; // Pixels stripped from the bottom left, unrotated.
        public var regionOffsetY : Number;
        public var regionWidth : Number; // Unrotated, stripped size.
        public var regionHeight : Number;
        public var regionOriginalWidth : Number; // Unrotated, unstripped size.
        public var regionOriginalHeight : Number;

        // Nonessential.
        public var edges : Vector.<int>;
        public var width : Number;
        public var height : Number;

        private var _parentMesh : WeightedMeshAttachment;

        public function get parentMesh() : WeightedMeshAttachment
        {
            return _parentMesh;
        }

        public function set parentMesh( parentMesh : WeightedMeshAttachment ) : void
        {
            _parentMesh = parentMesh;
            if( parentMesh != null )
            {
                bones = parentMesh.bones;
                weights = parentMesh.weights;
                regionUVs = parentMesh.regionUVs;
                triangles = parentMesh.triangles;
                hullLength = parentMesh.hullLength;
                edges = parentMesh.edges;
                width = parentMesh.width;
                height = parentMesh.height;
            }
        }

        public function updateUVs() : void
        {
            var width : Number = regionU2 - regionU, height : Number = regionV2 - regionV;
            var i : int, n : int = regionUVs.length;
            if( !uvs || uvs.length != n ) uvs = new Vector.<Number>( n, true );
            if( regionRotate )
            {
                for( i = 0; i < n; i += 2 )
                {
                    uvs[ i ] = regionU + regionUVs[ int( i + 1 ) ] * width;
                    uvs[ int( i + 1 ) ] = regionV + height - regionUVs[ i ] * height;
                }
            } else
            {
                for( i = 0; i < n; i += 2 )
                {
                    uvs[ i ] = regionU + regionUVs[ i ] * width;
                    uvs[ int( i + 1 ) ] = regionV + regionUVs[ int( i + 1 ) ] * height;
                }
            }
        }

        public function computeWorldVertices( x : Number, y : Number, slot : Slot, worldVertices : Vector.<Number> ) : void
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
            } else
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

        public function applyFFD( sourceAttachment : Attachment ) : Boolean
        {
            return this == sourceAttachment || (inheritFFD && _parentMesh == sourceAttachment);
        }
    }

}
