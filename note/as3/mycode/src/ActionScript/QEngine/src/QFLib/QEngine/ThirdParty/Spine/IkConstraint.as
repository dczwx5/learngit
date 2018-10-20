/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{
    public class IkConstraint implements Updatable
    {
        /** Adjusts the bone rotation so the tip is as close to the target position as possible. The target is specified in the world
         * coordinate system. */
        static public function apply1( bone : Bone, targetX : Number, targetY : Number, alpha : Number ) : void
        {
            var parentRotation : Number = bone.parent == null ? 0 : bone.parent.worldRotationX;
            var rotation : Number = bone.rotation;
            var rotationIK : Number = Math.atan2( targetY - bone.worldY, targetX - bone.worldX ) * MathUtils.radDeg - parentRotation;
            if( (bone.worldSignX != bone.worldSignY) != (bone.skeleton.flipX != (bone.skeleton.flipY != Bone.yDown)) )
                rotationIK = 360 - rotationIK;
            if( rotationIK > 180 ) rotationIK -= 360;
            else if( rotationIK < -180 ) rotationIK += 360;
            bone.updateWorldTransformWith( bone.x, bone.y, rotation + (rotationIK - rotation) * alpha, bone.appliedScaleX, bone.appliedScaleY );
        }

        /** Adjusts the parent and child bone rotations so the tip of the child is as close to the target position as possible. The
         * target is specified in the world coordinate system.
         * @param child Any descendant bone of the parent. */
        static public function apply2( parent : Bone, child : Bone, targetX : Number, targetY : Number, bendDir : int, alpha : Number ) : void
        {
            if( alpha == 0 ) return;
            var px : Number = parent.x, py : Number = parent.y, psx : Number = parent.appliedScaleX, psy : Number = parent.appliedScaleY;
            var o1 : int, o2 : int, s2 : int;
            if( psx < 0 )
            {
                psx = -psx;
                o1 = 180;
                s2 = -1;
            } else
            {
                o1 = 0;
                s2 = 1;
            }
            if( psy < 0 )
            {
                psy = -psy;
                s2 = -s2;
            }
            var cx : Number = child.x, cy : Number = child.y, csx : Number = child.appliedScaleX;
            var u : Boolean = Math.abs( psx - psy ) <= 0.0001;
            if( !u && cy != 0 )
            {
                child.worldX = parent.a * cx + parent.worldX;
                child.worldY = parent.c * cx + parent.worldY;
                cy = 0;
            }
            if( csx < 0 )
            {
                csx = -csx;
                o2 = 180;
            } else
                o2 = 0;
            var pp : Bone = parent.parent;
            var tx : Number, ty : Number, dx : Number, dy : Number;
            if( !pp )
            {
                tx = targetX - px;
                ty = targetY - py;
                dx = child.worldX - px;
                dy = child.worldY - py;
            } else
            {
                var ppa : Number = pp.a, ppb : Number = pp.b, ppc : Number = pp.c, ppd : Number = pp.d;
                var invDet : Number = 1 / (ppa * ppd - ppb * ppc);
                var wx : Number = pp.worldX, wy : Number = pp.worldY, twx : Number = targetX - wx, twy : Number = targetY - wy;
                tx = (twx * ppd - twy * ppb) * invDet - px;
                ty = (twy * ppa - twx * ppc) * invDet - py;
                twx = child.worldX - wx;
                twy = child.worldY - wy;
                dx = (twx * ppd - twy * ppb) * invDet - px;
                dy = (twy * ppa - twx * ppc) * invDet - py;
            }
            var l1 : Number = Math.sqrt( dx * dx + dy * dy ), l2 : Number = child.data.length * csx, a1 : Number, a2 : Number;
            outer:
                    if( u )
                    {
                        l2 *= psx;
                        var cos : Number = (tx * tx + ty * ty - l1 * l1 - l2 * l2) / (2 * l1 * l2);
                        if( cos < -1 ) cos = -1;
                        else if( cos > 1 ) cos = 1;
                        a2 = Math.acos( cos ) * bendDir;
                        var ad : Number = l1 + l2 * cos, o : Number = l2 * Math.sin( a2 );
                        a1 = Math.atan2( ty * ad - tx * o, tx * ad + ty * o );
                    } else
                    {
                        var a : Number = psx * l2, b : Number = psy * l2, ta : Number = Math.atan2( ty, tx );
                        var aa : Number = a * a, bb : Number = b * b, ll : Number = l1 * l1, dd : Number = tx * tx + ty * ty;
                        var c0 : Number = bb * ll + aa * dd - aa * bb, c1 : Number = -2 * bb * l1, c2 : Number = bb - aa;
                        var d : Number = c1 * c1 - 4 * c2 * c0;
                        if( d >= 0 )
                        {
                            var q : Number = Math.sqrt( d );
                            if( c1 < 0 ) q = -q;
                            q = -(c1 + q) / 2;
                            var r0 : Number = q / c2, r1 : Number = c0 / q;
                            var r : Number = Math.abs( r0 ) < Math.abs( r1 ) ? r0 : r1;
                            if( r * r <= dd )
                            {
                                var y1 : Number = Math.sqrt( dd - r * r ) * bendDir;
                                a1 = ta - Math.atan2( y1, r );
                                a2 = Math.atan2( y1 / psy, (r - l1) / psx );
                                break outer;
                            }
                        }
                        var minAngle : Number = 0, minDist : Number = Number.MAX_VALUE, minX : Number = 0, minY : Number = 0;
                        var maxAngle : Number = 0, maxDist : Number = 0, maxX : Number = 0, maxY : Number = 0;
                        var x : Number = l1 + a, dist : Number = x * x;
                        if( dist > maxDist )
                        {
                            maxAngle = 0;
                            maxDist = dist;
                            maxX = x;
                        }
                        x = l1 - a;
                        dist = x * x;
                        if( dist < minDist )
                        {
                            minAngle = Math.PI;
                            minDist = dist;
                            minX = x;
                        }
                        var angle : Number = Math.acos( -a * l1 / (aa - bb) );
                        x = a * Math.cos( angle ) + l1;
                        var y : Number = b * Math.sin( angle );
                        dist = x * x + y * y;
                        if( dist < minDist )
                        {
                            minAngle = angle;
                            minDist = dist;
                            minX = x;
                            minY = y;
                        }
                        if( dist > maxDist )
                        {
                            maxAngle = angle;
                            maxDist = dist;
                            maxX = x;
                            maxY = y;
                        }
                        if( dd <= (minDist + maxDist) / 2 )
                        {
                            a1 = ta - Math.atan2( minY * bendDir, minX );
                            a2 = minAngle * bendDir;
                        } else
                        {
                            a1 = ta - Math.atan2( maxY * bendDir, maxX );
                            a2 = maxAngle * bendDir;
                        }
                    }
            var os : Number = Math.atan2( cy, cx ) * s2;
            a1 = (a1 - os) * MathUtils.radDeg + o1;
            a2 = (a2 + os) * MathUtils.radDeg * s2 + o2;
            if( a1 > 180 ) a1 -= 360;
            else if( a1 < -180 ) a1 += 360;
            if( a2 > 180 ) a2 -= 360;
            else if( a2 < -180 ) a2 += 360;
            var rotation : Number = parent.rotation;
            parent.updateWorldTransformWith( px, py, rotation + (a1 - rotation) * alpha, parent.appliedScaleX, parent.appliedScaleY );
            rotation = child.rotation;
            child.updateWorldTransformWith( cx, cy, rotation + (a2 - rotation) * alpha, child.appliedScaleX, child.appliedScaleY );
        }

        public function IkConstraint( data : IkConstraintData, skeleton : Skeleton )
        {
            if( data == null ) throw new ArgumentError( "data cannot be null." );
            if( skeleton == null ) throw new ArgumentError( "skeleton cannot be null." );
            _data = data;
            mix = data.mix;
            bendDirection = data.bendDirection;

            bones = new Vector.<Bone>();
            for each ( var boneData : BoneData in data.bones )
                bones[ bones.length ] = skeleton.findBone( boneData.name );
            target = skeleton.findBone( data.target._name );
        }
        public var bones : Vector.<Bone>;
        public var target : Bone;
        public var bendDirection : int;
        public var mix : Number;

        internal var _data : IkConstraintData;

        public function get data() : IkConstraintData
        {
            return _data;
        }

        public function apply() : void
        {
            update();
        }

        public function update() : void
        {
            switch( bones.length )
            {
                case 1:
                    apply1( bones[ 0 ], target.worldX, target.worldY, mix );
                    break;
                case 2:
                    apply2( bones[ 0 ], bones[ 1 ], target.worldX, target.worldY, bendDirection, mix );
                    break;
            }
        }

        public function toString() : String
        {
            return _data._name;
        }
    }

}
