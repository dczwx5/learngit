/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.attachments
{
    import QFLib.QEngine.ThirdParty.Spine.Bone;

    public dynamic class BoundingBoxAttachment extends Attachment
    {
        public function BoundingBoxAttachment( name : String )
        {
            super( name );
        }
        public var vertices : Vector.<Number> = new Vector.<Number>();

        public function computeWorldVertices( x : Number, y : Number, bone : Bone, worldVertices : Vector.<Number> ) : void
        {
            x += bone.worldX;
            y += bone.worldY;
            var m00 : Number = bone.a;
            var m01 : Number = bone.b;
            var m10 : Number = bone.c;
            var m11 : Number = bone.d;
            var vertices : Vector.<Number> = this.vertices;
            for( var i : int = 0, n : int = vertices.length; i < n; i += 2 )
            {
                var ii : int = i + 1;
                var px : Number = vertices[ i ];
                var py : Number = vertices[ ii ];
                worldVertices[ i ] = px * m00 + py * m01 + x;
                worldVertices[ ii ] = px * m10 + py * m11 + y;
            }
        }
    }

}
