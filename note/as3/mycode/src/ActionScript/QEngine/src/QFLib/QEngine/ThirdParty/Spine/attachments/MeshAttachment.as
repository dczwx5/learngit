/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.attachments
{
    import QFLib.QEngine.ThirdParty.Spine.Bone;
    import QFLib.QEngine.ThirdParty.Spine.Slot;

    public dynamic class MeshAttachment extends Attachment implements FfdAttachment
    {
        public function MeshAttachment( name : String )
        {
            super( name );
        }
        public var vertices : Vector.<Number>;
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

        private var _parentMesh : MeshAttachment;

        public function get parentMesh() : MeshAttachment
        {
            return _parentMesh;
        }

        public function set parentMesh( parentMesh : MeshAttachment ) : void
        {
            _parentMesh = parentMesh;
            if( parentMesh != null )
            {
                vertices = parentMesh.vertices;
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

        public function applyFFD( sourceAttachment : Attachment ) : Boolean
        {
            return this == sourceAttachment || (inheritFFD && _parentMesh == sourceAttachment);
        }
    }

}
