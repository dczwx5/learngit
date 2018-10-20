/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    public class Bone implements Updatable
    {
        static public var yDown : Boolean;

        /** @param parent May be null. */
        public function Bone( data : BoneData, skeleton : Skeleton, parent : Bone )
        {
            if( data == null ) throw new ArgumentError( "data cannot be null." );
            if( skeleton == null ) throw new ArgumentError( "skeleton cannot be null." );
            this.data = data;
            this.skeleton = skeleton;
            this.parent = parent;
            setToSetupPose();
        }
        public var data : BoneData;
        public var skeleton : Skeleton;
        public var parent : Bone;
        public var x : Number;
        public var y : Number;
        public var rotation : Number;
        public var scaleX : Number;
        public var scaleY : Number;
        public var appliedRotation : Number;
        public var appliedScaleX : Number;
        public var appliedScaleY : Number;
        public var a : Number;
        public var b : Number;
        public var c : Number;
        public var d : Number;
        public var worldX : Number;
        public var worldY : Number;
        public var worldSignX : Number;
        public var worldSignY : Number;

        final public function get worldRotationX() : Number
        {
            return Math.atan2( c, a ) * MathUtils.radDeg;
        }

        final public function get worldRotationY() : Number
        {
            return Math.atan2( d, b ) * MathUtils.radDeg;
        }

        final public function get worldScaleX() : Number
        {
            return Math.sqrt( a * a + b * b ) * worldSignX;
        }

        final public function get worldScaleY() : Number
        {
            return Math.sqrt( c * c + d * d ) * worldSignY;
        }

        /** Computes the world SRT using the parent bone and this bone's local SRT. */
        public function updateWorldTransform() : void
        {
            updateWorldTransformWith( x, y, rotation, scaleX, scaleY );
        }

        /** Same as updateWorldTransform(). This method exists for Bone to implement Updatable. */
        public function update() : void
        {
            updateWorldTransformWith( x, y, rotation, scaleX, scaleY );
        }

        /** Computes the world SRT using the parent bone and the specified local SRT. */
        public function updateWorldTransformWith( x : Number, y : Number, rotation : Number, scaleX : Number, scaleY : Number ) : void
        {
            appliedRotation = rotation;
            appliedScaleX = scaleX;
            appliedScaleY = scaleY;

            var radians : Number = rotation * MathUtils.degRad;
            var cos : Number = Math.cos( radians ), sin : Number = Math.sin( radians );
            var la : Number = cos * scaleX, lb : Number = -sin * scaleY, lc : Number = sin * scaleX, ld : Number = cos * scaleY;
            var parent : Bone = this.parent;
            var skeleton : Skeleton = this.skeleton;
            if( !parent )
            { // Root bone.
                if( skeleton.flipX )
                {
                    x = -x;
                    la = -la;
                    lb = -lb;
                }
                if( skeleton.flipY != yDown )
                {
                    y = -y;
                    lc = -lc;
                    ld = -ld;
                }
                a = la;
                b = lb;
                c = lc;
                d = ld;
                worldX = x;
                worldY = y;
                worldSignX = scaleX < 0 ? -1 : 1;
                worldSignY = scaleY < 0 ? -1 : 1;
                return;
            }

            var pa : Number = parent.a, pb : Number = parent.b, pc : Number = parent.c, pd : Number = parent.d;
            worldX = pa * x + pb * y + parent.worldX;
            worldY = pc * x + pd * y + parent.worldY;
            worldSignX = parent.worldSignX * (scaleX < 0 ? -1 : 1);
            worldSignY = parent.worldSignY * (scaleY < 0 ? -1 : 1);

            if( data.inheritRotation && data.inheritScale )
            {
                a = pa * la + pb * lc;
                b = pa * lb + pb * ld;
                c = pc * la + pd * lc;
                d = pc * lb + pd * ld;
            } else
            {
                if( data.inheritRotation )
                { // No scale inheritance.
                    pa = 1;
                    pb = 0;
                    pc = 0;
                    pd = 1;
                    do {
                        radians = parent.appliedRotation * MathUtils.degRad;
                        cos = Math.cos( radians );
                        sin = Math.sin( radians );
                        var temp1 : Number = pa * cos + pb * sin;
                        pb = pa * -sin + pb * cos;
                        pa = temp1;
                        temp1 = pc * cos + pd * sin;
                        pd = pc * -sin + pd * cos;
                        pc = temp1;

                        if( !parent.data.inheritRotation ) break;
                        parent = parent.parent;
                    } while( parent != null );
                    a = pa * la + pb * lc;
                    b = pa * lb + pb * ld;
                    c = pc * la + pd * lc;
                    d = pc * lb + pd * ld;
                } else if( data.inheritScale )
                { // No rotation inheritance.
                    pa = 1;
                    pb = 0;
                    pc = 0;
                    pd = 1;
                    do {
                        radians = parent.rotation * MathUtils.degRad;
                        cos = Math.cos( radians );
                        sin = Math.sin( radians );
                        var psx : Number = parent.appliedScaleX, psy : Number = parent.appliedScaleY;
                        var za : Number = cos * psx, zb : Number = -sin * psy, zc : Number = sin * psx, zd : Number = cos * psy;
                        var temp2 : Number = pa * za + pb * zc;
                        pb = pa * zb + pb * zd;
                        pa = temp2;
                        temp2 = pc * za + pd * zc;
                        pd = pc * zb + pd * zd;
                        pc = temp2;

                        if( psx < 0 ) radians = -radians;
                        cos = Math.cos( -radians );
                        sin = Math.sin( -radians );
                        temp2 = pa * cos + pb * sin;
                        pb = pa * -sin + pb * cos;
                        pa = temp2;
                        temp2 = pc * cos + pd * sin;
                        pd = pc * -sin + pd * cos;
                        pc = temp2;

                        if( !parent.data.inheritScale ) break;
                        parent = parent.parent;
                    } while( parent != null );
                    a = pa * la + pb * lc;
                    b = pa * lb + pb * ld;
                    c = pc * la + pd * lc;
                    d = pc * lb + pd * ld;
                } else
                {
                    a = la;
                    b = lb;
                    c = lc;
                    d = ld;
                }
                if( skeleton.flipX )
                {
                    a = -a;
                    b = -b;
                }
                if( skeleton.flipY != yDown )
                {
                    c = -c;
                    d = -d;
                }
            }
        }

        public function setToSetupPose() : void
        {
            x = data.x;
            y = data.y;
            rotation = data.rotation;
            scaleX = data.scaleX;
            scaleY = data.scaleY;
        }

        public function worldToLocal( world : Vector.<Number> ) : void
        {
            var x : Number = world[ 0 ] - worldX, y : Number = world[ 1 ] - worldY;
            var a : Number = a, b : Number = b, c : Number = c, d : Number = d;
            var invDet : Number = 1 / (a * d - b * c);
            world[ 0 ] = (x * d * invDet - y * b * invDet);
            world[ 1 ] = (y * a * invDet - x * c * invDet);
        }

        public function localToWorld( local : Vector.<Number> ) : void
        {
            var localX : Number = local[ 0 ], localY : Number = local[ 1 ];
            local[ 0 ] = localX * a + localY * b + worldX;
            local[ 1 ] = localX * c + localY * d + worldY;
        }

        public function toString() : String
        {
            return data._name;
        }
    }

}
