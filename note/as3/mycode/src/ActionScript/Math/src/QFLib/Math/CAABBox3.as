//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/5/19
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Math
{

    public class CAABBox3
    {
        public static const ZERO : CAABBox3 = new CAABBox3( CVector3.ZERO, CVector3.ZERO );

        public function CAABBox3( vMin : CVector3, vMax : CVector3 = null )
        {
            this.min.set( vMin );
            if( vMax == null ) this.max.set( vMin );
            else this.max.set( vMax );
        }

        public function clone() : CAABBox3
        {
            return new CAABBox3( this.min, this.max );
        }

        public function toString() : String
        {
            var s : String = "";
            s += min.toString();
            s += ", ";
            s += max.toString();
            return s;
        }
        public function toFixed( numFixed : * = 0 ) : String
        {
            var s : String = "";
            s += min.toFixed( numFixed );
            s += ", ";
            s += max.toFixed( numFixed );
            return s;
        }

        public function set( aabb : CAABBox3 ) : void { this.min.set( aabb.min ); this.max.set( aabb.max ); }
        public function setTo( aabb : CAABBox3 ) : void { this.set( aabb ); }
        public function setVector( vMin : CVector3, vMax : CVector3 ) : void { this.min.set( vMin ); this.max.set( vMax ); }
        public function setValue( xMin : Number, yMin : Number, zMin : Number, xMax : Number, yMax : Number, zMax : Number ) : void
        {
            min.x = xMin; min.y = yMin; min.z = zMin;
            max.x = xMax; max.y = yMax; max.z = zMax;
        }
        public function setCenterExt( vCenter : CVector3, vExt : CVector3 ) : void
        {
            this.min.set( vCenter ); this.min.subOn( vExt );
            this.max.set( vCenter ); this.max.addOn( vExt );
        }

        public function setCenterExtValue( fCenterX : Number, fCenterY : Number, fCenterZ : Number, fExtX : Number, fExtY : Number, fExtZ : Number ) : void
        {
            this.min.setValueXYZ( fCenterX, fCenterY, fCenterZ ); this.min.subOnValueXYZ( fExtX, fExtY, fExtZ );
            this.max.setValueXYZ( fCenterX, fCenterY, fCenterZ ); this.max.addOnValueXYZ( fExtX, fExtY, fExtZ );
        }

        public function merge( aabb : CAABBox3 ) : void
        {
            if( aabb.max.x > this.max.x ) this.max.x = aabb.max.x;
            if( aabb.max.y > this.max.y ) this.max.y = aabb.max.y;
            if( aabb.max.z > this.max.z ) this.max.z = aabb.max.z;

            if( aabb.min.x < this.min.x ) this.min.x = aabb.min.x;
            if( aabb.min.y < this.min.y ) this.min.y = aabb.min.y;
            if( aabb.min.z < this.min.z ) this.min.z = aabb.min.z;
        }
        public function mergeVertex( v : CVector3 ) : void
        {
            if( v.x > this.max.x ) this.max.x = v.x;
            if( v.y > this.max.y ) this.max.y = v.y;
            if( v.z > this.max.z ) this.max.z = v.z;

            if( v.x < this.min.x ) this.min.x = v.x;
            if( v.y < this.min.y ) this.min.y = v.y;
            if( v.z < this.min.z ) this.min.z = v.z;
        }
        public function mergeVertexValue( fX : Number, fY : Number, fZ : Number ) : void
        {
            if( fX > this.max.x ) this.max.x = fX;
            if( fY > this.max.y ) this.max.y = fY;
            if( fZ > this.max.z ) this.max.z = fZ;

            if( fX < this.min.x ) this.min.x = fX;
            if( fY < this.min.y ) this.min.y = fY;
            if( fZ < this.min.z ) this.min.z = fZ;
        }

        [Inline]
        public function move( x : Number, y : Number, z : Number ) : void
        {
            min.addOnValueXYZ( x, y, z );
            max.addOnValueXYZ( x, y, z );
        }

        public function isCollidedVertex( vPoint : CVector3 ) : Boolean
        {
            if( vPoint.x > this.max.x ) return false;
            if( vPoint.y > this.max.y ) return false;
            if( vPoint.z > this.max.z ) return false;

            if( vPoint.x < this.min.x ) return false;
            if( vPoint.y < this.min.y ) return false;
            if( vPoint.z < this.min.z ) return false;
            return true;
        }
        public function isCollidedVertexValue( fX : Number, fY : Number, fZ : Number ) : Boolean
        {
            if( fX > this.max.x ) return false;
            if( fY > this.max.y ) return false;
            if( fZ > this.max.z ) return false;

            if( fX < this.min.x ) return false;
            if( fY < this.min.y ) return false;
            if( fZ < this.min.z ) return false;
            return true;
        }

        [Inline]
        public function isCollidedLine( vPoint1 : CVector3, vPoint2 : CVector3 ) : Boolean
        {
            return CMath.is3DLineIntersectAABB( vPoint1.x, vPoint1.y, vPoint1.z, vPoint2.x, vPoint2.y, vPoint2.z,
                                                 this.min.x, this.min.y, this.min.z, this.max.x, this.max.y, this.max.z );
        }
        [Inline]
        public function isCollidedLineValue( fX1 : Number, fY1 : Number, fZ1 : Number, fX2 : Number, fY2 : Number, fZ2 : Number ) : Boolean
        {
            return CMath.is3DLineIntersectAABB( fX1, fY1, fZ1, fX2, fY2, fZ2, this.min.x, this.min.y, this.min.z, this.max.x, this.max.y, this.max.z );
        }
        public function isCollided( aabb : CAABBox3 ) : Boolean
        {
            if( this.max.x < aabb.min.x || this.max.y < aabb.min.y || this.max.z < aabb.min.z ) return false;
            if( this.min.x > aabb.max.x || this.min.y > aabb.max.y || this.min.z > aabb.max.z ) return false;
            return true;
        }
        public function isContained( aabb : CAABBox3 ) : Boolean
        {
            if( this.max.x < aabb.max.x || this.max.y < aabb.max.y || this.max.z < aabb.max.z ) return false;
            if( this.min.x > aabb.min.x || this.min.y > aabb.min.y || this.min.z > aabb.min.z ) return false;
            return true;
        }
        public function isContainedCenterExt( vCenter : CVector3, vExt : CVector3 ) : Boolean
        {
            if( this.max.x < ( vCenter.x + vExt.x ) || this.max.y < ( vCenter.y + vExt.y ) || this.max.z < vCenter.z + vExt.z ) return false;
            if( this.min.x > ( vCenter.x - vExt.x ) || this.min.y > ( vCenter.y - vExt.y ) || this.min.z > vCenter.z - vExt.z ) return false;
            return true;
        }
        public function isContainedCenterExtValue( fCenterX : Number, fCenterY : Number, fCenterZ : Number, fExtX : Number, fExtY : Number, fExtZ : Number ) : Boolean
        {
            if( this.max.x < ( fCenterX + fExtX ) || this.max.y < ( fCenterY + fExtY ) || this.max.y < ( fCenterZ + fExtZ ) ) return false;
            if( this.min.x > ( fCenterX - fExtX ) || this.min.y > ( fCenterY - fExtY ) || this.min.y > ( fCenterZ - fExtZ ) ) return false;
            return true;
        }

        public function collidedArea( aabb : CAABBox3 ) : CAABBox3
        {
            if( isCollided( aabb ) == false ) return new CAABBox3( CVector3.ZERO, CVector3.ZERO );

            var collidedAABB : CAABBox3 = new CAABBox3( aabb.min, aabb.max );

            if( aabb.max.x > max.x && max.x > aabb.min.x ) collidedAABB.max.x = max.x;
            if( aabb.max.y > max.y && max.y > aabb.min.y ) collidedAABB.max.y = max.y;
            if( aabb.max.z > max.z && max.z > aabb.min.z ) collidedAABB.max.z = max.z;

            if( aabb.min.x < min.x && min.x < aabb.max.x ) collidedAABB.min.x = min.x;
            if( aabb.min.y < min.y && min.y < aabb.max.y ) collidedAABB.min.y = min.y;
            if( aabb.min.z < min.z && min.z < aabb.max.z ) collidedAABB.min.z = min.z;

            return collidedAABB;
        }

        public function isVolumeZero() : Boolean
        {
            if( max.x - min.x == 0.0 ) return true;
            if( max.y - min.y == 0.0 ) return true;
            if( max.z - min.z == 0.0 ) return true;
            return false;
        }
        public function isVolumeNearZero( fEpsilon : Number = CMath.EPSILON ) : Boolean
        {
            if( CMath.abs( max.x - min.x ) < fEpsilon ) return true;
            if( CMath.abs( max.y - min.y ) < fEpsilon ) return true;
            if( CMath.abs( max.z - min.z ) < fEpsilon ) return true;
            return false;
        }
        public function volume() : Number
        {
            var fDiffX : Number = max.x - min.x;
            var fDiffY : Number = max.y - min.y;
            var fDiffZ : Number = max.z - min.z;
            return fDiffX * fDiffY * fDiffZ;
        }

        public function get center() : CVector3
        {
            if( m_vCenter == null ) m_vCenter = new CVector3();

            m_vCenter.set( max );
            m_vCenter.addOn( min );
            m_vCenter.mulOnValue( 0.5 );
            return m_vCenter;
        }
        public function get ext() : CVector3
        {
            if( m_vExt == null ) m_vExt = new CVector3();
            m_vExt.set( max );
            m_vExt.subOn( min );
            m_vExt.mulOnValue( 0.5 );
            return m_vExt;

        }

        public function get extX() : Number
        {
            return ( this.max.x - this.min.x ) * 0.5;
        }
        public function get extY() : Number
        {
            return ( this.max.y - this.min.y ) * 0.5;
        }
        public function get extZ() : Number
        {
            return ( this.max.z - this.min.z ) * 0.5;
        }
        public function get width() : Number
        {
            return this.max.x - this.min.x;
        }
        public function get height() : Number
        {
            return this.max.y - this.min.y;
        }
        public function get depth() : Number
        {
            return this.max.z - this.min.z;
        }

        public function setCenter( vCenter : CVector3 ) : void
        {
            var vExt : CVector3 = new CVector3( max.x, max.y, max.z );
            vExt.subOn( min );
            vExt.mulOnValue( 0.5 );

            this.min.set( vCenter ); this.min.subOn( vExt );
            this.max.set( vCenter ); this.min.addOn( vExt );
        }

        public function setCenterValue( fCenterX : Number, fCenterY : Number, fCenterZ : Number ) : void
        {
            var vExt : CVector3 = new CVector3( max.x, max.y, max.z );
            vExt.subOn( min );
            vExt.mulOnValue( 0.5 );

            this.min.setValueXYZ( fCenterX - vExt.x, fCenterY - vExt.y, fCenterZ - vExt.z );
            this.max.setValueXYZ( fCenterX + vExt.x, fCenterY + vExt.y, fCenterZ + vExt.z );
        }
        public function getCenter() : CVector3
        {
            var vCenter : CVector3 = new CVector3( max.x, max.y, max.z );
            vCenter.addOn( min );
            vCenter.mulOnValue( 0.5 );
            return vCenter;
        }
        public function setExt( vExt : CVector3 ) : void
        {
            var vCenter : CVector3 = new CVector3( max.x, max.y, max.z );
            vCenter.addOn( min );
            vCenter.mulOnValue( 0.5 );

            this.min.set( vCenter ); this.min.subOn( vExt );
            this.max.set( vCenter ); this.min.addOn( vExt );
        }
        public function setExtValue( fExtX : Number, fExtY : Number, fExtZ : Number ) : void
        {
            var vCenter : CVector3 = new CVector3( max.x, max.y, max.z );
            vCenter.addOn( min );
            vCenter.mulOnValue( 0.5 );

            this.min.setValueXYZ( vCenter.x - fExtX, vCenter.y - fExtY, vCenter.z - fExtZ );
            this.max.setValueXYZ( vCenter.x + fExtX, vCenter.y + fExtY, vCenter.z + fExtZ );
        }
        public function getExt() : CVector3
        {
            var vExt : CVector3 = new CVector3( max.x, max.y, max.z );
            vExt.subOn( min );
            vExt.mulOnValue( 0.5 );
            return vExt;
        }
        public function getExtX2() : CVector3
        {
            var vExt : CVector3 = new CVector3( max.x, max.y, max.z );
            vExt.subOn( min );
            return vExt;
        }

        public function enlargeExt( vExtend : CVector3 ) : void
        {
            min.subOn( vExtend );
            max.addOn( vExtend );
        }
        public function enlargeExtValue( fExtend : Number ) : void
        {
            min.subOnValue( fExtend );
            max.addOnValue( fExtend );
        }
        public function enlargeExtValueXYZ( fExtendX : Number, fExtendY : Number, fExtendZ : Number ) : void
        {
            min.x -= fExtendX;
            min.y -= fExtendY;
            min.z -= fExtendZ;
            max.x += fExtendX;
            max.y += fExtendY;
            max.z += fExtendZ;
        }

        public function multiplyXY( fX : Number, fY : Number, fZ : Number ) : void
        {
            min.mulOnValueXYZ( fX, fY, fZ );
            max.mulOnValueXYZ( fX, fY, fZ );

            var fTemp : Number;
            if( fX < 0.0 ) { fTemp = min.x; min.x = max.x; max.x = fTemp; }
            if( fY < 0.0 ) { fTemp = min.y; min.y = max.y; max.y = fTemp; }
            if( fZ < 0.0 ) { fTemp = min.z; min.z = max.z; max.z = fTemp; }
        }

        public function equals( rhs : CAABBox3 ) : Boolean
        {
            if( max.equals( rhs.max ) == false || min.equals( rhs.min ) == false ) return false;
            else return true;
        }
        public function equalsVector( vMin : CVector3, vMax : CVector3 ) : Boolean
        {
            if( max.equals( vMax ) == false || min.equals( vMin ) == false ) return false;
            else return true;
        }
        public function equalsValue( xMin : Number, yMin : Number, zMin : Number, xMax : Number, yMax : Number, zMax : Number ) : Boolean
        {
            if( max.equalsValue( xMax, yMax, zMax ) == false || min.equalsValue( xMin, yMin, zMin ) == false ) return false;
            else return true;
        }

        public function equalsWithinError( rhs : CAABBox3, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( max.equalsWithinError( rhs.max, fError ) == false || min.equalsWithinError( rhs.min, fError ) == false ) return false;
            else return true;
        }
        public function equalsVectorWithinError( vMin : CVector3, vMax : CVector3, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( max.equalsWithinError( vMax, fError ) == false || min.equalsWithinError( vMin, fError ) == false ) return false;
            else return true;
        }
        public function equalsValueWithinError( xMin : Number, yMin : Number, zMin : Number, xMax : Number, yMax : Number, zMax : Number, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( max.equalsValueWithinError( xMax, yMax, zMax, fError ) == false || min.equalsValueWithinError( xMin, yMin, zMin, fError ) == false ) return false;
            else return true;
        }

        public static function zero() : CAABBox3
        {
            return new CAABBox3( CVector3.ZERO, CVector3.ZERO );
        }

        //
        //
        public var min : CVector3 = new CVector3();
        public var max : CVector3 = new CVector3();

        //
        private var m_vCenter : CVector3 = null;
        private var m_vExt : CVector3 = null;
    }

}

