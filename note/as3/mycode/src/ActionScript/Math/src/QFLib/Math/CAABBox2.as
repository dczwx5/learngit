//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/5/19
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Math
{

    public class CAABBox2
    {
        public static const ZERO : CAABBox2 = new CAABBox2( CVector2.ZERO, CVector2.ZERO );

        public function CAABBox2( vMin : CVector2, vMax : CVector2 = null )
        {
            this.min.set( vMin );
            if( vMax == null ) this.max.set( vMin );
            else this.max.set( vMax );
        }

        public function clone() : CAABBox2
        {
            return new CAABBox2( this.min, this.max );
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

        public function set( aabb : CAABBox2 ) : void { this.min.set( aabb.min ); this.max.set( aabb.max ); }
        public function setTo( aabb : CAABBox2 ) : void { this.set( aabb ); }
        public function setVector( vMin : CVector2, vMax : CVector2 ) : void { this.min.set( vMin ); this.max.set( vMax ); }
        public function setValue( xMin : Number, yMin : Number, xMax : Number, yMax : Number ) : void
        {
            min.x = xMin; min.y = yMin;
            max.x = xMax; max.y = yMax;
        }
        public function setCenterExt( vCenter : CVector2, vExt : CVector2 ) : void
        {
            this.min.set( vCenter ); this.min.subOn( vExt );
            this.max.set( vCenter ); this.max.addOn( vExt );
        }

        public function setCenterExtValue( fCenterX : Number, fCenterY : Number, fExtX : Number, fExtY : Number ) : void
        {
            this.min.setValueXY( fCenterX, fCenterY ); this.min.subOnValueXY( fExtX, fExtY );
            this.max.setValueXY( fCenterX, fCenterY ); this.max.addOnValueXY( fExtX, fExtY );
        }

        public function encloseIntoAABB( aabb : CAABBox2 ) : void
        {
            if( this.max.x > aabb.max.x )
            {
                this.min.x -= this.max.x - aabb.max.x; this.max.x = aabb.max.x;
                if( this.min.x < aabb.min.x ) this.min.x = aabb.min.x;
            }
            else if( this.min.x < aabb.min.x )
            {
                this.max.x += aabb.min.x - this.min.x; this.min.x = aabb.min.x;
                if( this.max.x > aabb.max.x ) this.max.x = aabb.max.x;
            }

            if( this.max.y > aabb.max.y )
            {
                this.min.y -= this.max.y - aabb.max.y; this.max.y = aabb.max.y;
                if( this.min.y < aabb.min.y ) this.min.y = aabb.min.y;
            }
            else if( this.min.y < aabb.min.y )
            {
                this.max.y += aabb.min.y - this.min.y; this.min.y = aabb.min.y;
                if( this.max.y > aabb.max.y ) this.max.y = aabb.max.y;
            }
        }

        public function merge( aabb : CAABBox2 ) : void
        {
            if( aabb.max.x > this.max.x ) this.max.x = aabb.max.x;
            if( aabb.max.y > this.max.y ) this.max.y = aabb.max.y;

            if( aabb.min.x < this.min.x ) this.min.x = aabb.min.x;
            if( aabb.min.y < this.min.y ) this.min.y = aabb.min.y;
        }
        public function mergeVertex( v : CVector2 ) : void
        {
            if( v.x > this.max.x ) this.max.x = v.x;
            if( v.y > this.max.y ) this.max.y = v.y;

            if( v.x < this.min.x ) this.min.x = v.x;
            if( v.y < this.min.y ) this.min.y = v.y;
        }
        public function mergeVertexValue( fX : Number, fY : Number ) : void
        {
            if( fX > this.max.x ) this.max.x = fX;
            if( fY > this.max.y ) this.max.y = fY;

            if( fX < this.min.x ) this.min.x = fX;
            if( fY < this.min.y ) this.min.y = fY;
        }

        public function move( x : Number, y : Number ) : void
        {
            min.addOnValueXY( x, y );
            max.addOnValueXY( x, y );
        }

        public function isCollidedVertex( vPoint : CVector2 ) : Boolean
        {
            if( vPoint.x > this.max.x ) return false;
            if( vPoint.y > this.max.y ) return false;

            if( vPoint.x < this.min.x ) return false;
            if( vPoint.y < this.min.y ) return false;
            return true;
        }
        public function isCollidedVertexValue( fX : Number, fY : Number ) : Boolean
        {
            if( fX > this.max.x ) return false;
            if( fY > this.max.y ) return false;

            if( fX < this.min.x ) return false;
            if( fY < this.min.y ) return false;
            return true;
        }

        [Inline]
        public function isCollidedLine( vPoint1 : CVector2, vPoint2 : CVector2 ) : Boolean
        {
            return CMath.is2DLineIntersectAABB( vPoint1.x, vPoint1.y, vPoint2.x, vPoint2.y, this.min.x, this.min.y, this.max.x, this.max.y );
        }
        [Inline]
        public function isCollidedLineValue( fX1 : Number, fY1 : Number, fX2 : Number, fY2 : Number ) : Boolean
        {
            return CMath.is2DLineIntersectAABB( fX1, fY1, fX2, fY2, this.min.x, this.min.y, this.max.x, this.max.y );
        }
        public function isCollided( aabb : CAABBox2 ) : Boolean
        {
            if( this.max.x < aabb.min.x || this.max.y < aabb.min.y ) return false;
            if( this.min.x > aabb.max.x || this.min.y > aabb.max.y ) return false;
            return true;
        }
        public function isCollidedValue( fMinX : Number, fMinY : Number, fMaxX : Number, fMaxY : Number ) : Boolean
        {
            if( this.max.x < fMinX || this.max.y < fMinY ) return false;
            if( this.min.x > fMaxX || this.min.y > fMaxY ) return false;
            return true;
        }
        public function isContained( aabb : CAABBox2 ) : Boolean
        {
            if( this.max.x < aabb.max.x || this.max.y < aabb.max.y ) return false;
            if( this.min.x > aabb.min.x || this.min.y > aabb.min.y ) return false;
            return true;
        }
        public function isContainedCenterExt( vCenter : CVector2, vExt : CVector2 ) : Boolean
        {
            if( this.max.x < ( vCenter.x + vExt.x ) || this.max.y < ( vCenter.y + vExt.y ) ) return false;
            if( this.min.x > ( vCenter.x - vExt.x ) || this.min.y > ( vCenter.y - vExt.y ) ) return false;
            return true;
        }
        public function isContainedCenterExtValue( fCenterX : Number, fCenterY : Number, fExtX : Number, fExtY : Number ) : Boolean
        {
            if( this.max.x < ( fCenterX + fExtX ) || this.max.y < ( fCenterY + fExtY ) ) return false;
            if( this.min.x > ( fCenterX - fExtX ) || this.min.y > ( fCenterY - fExtY ) ) return false;
            return true;
        }

        public function collidedArea( aabb : CAABBox2 ) : CAABBox2
        {
            if( isCollided( aabb ) == false ) return new CAABBox2( CVector2.ZERO, CVector2.ZERO );

            var collidedAABB : CAABBox2 = new CAABBox2( aabb.min, aabb.max );

            if( aabb.max.x > max.x && max.x > aabb.min.x ) collidedAABB.max.x = max.x;
            if( aabb.max.y > max.y && max.y > aabb.min.y ) collidedAABB.max.y = max.y;

            if( aabb.min.x < min.x && min.x < aabb.max.x ) collidedAABB.min.x = min.x;
            if( aabb.min.y < min.y && min.y < aabb.max.y ) collidedAABB.min.y = min.y;

            return collidedAABB;
        }

        public function isVolumeZero() : Boolean
        {
            if( max.x - min.x == 0.0 ) return true;
            if( max.y - min.y == 0.0 ) return true;
            return false;
        }
        public function isVolumeNearZero( fEpsilon : Number = CMath.EPSILON ) : Boolean
        {
            if( CMath.abs( max.x - min.x ) < fEpsilon ) return true;
            if( CMath.abs( max.y - min.y ) < fEpsilon ) return true;
            return false;
        }
        public function volume() : Number
        {
            var fDiffX : Number = max.x - min.x;
            var fDiffY : Number = max.y - min.y;
            return fDiffX * fDiffY;
        }

        public function get center() : CVector2
        {
            if( m_vCenter == null ) m_vCenter = new CVector2();

            m_vCenter.set( max );
            m_vCenter.addOn( min );
            m_vCenter.mulOnValue( 0.5 );
            return m_vCenter;
        }
        public function get ext() : CVector2
        {
            if( m_vExt == null ) m_vExt = new CVector2();
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
        public function get width() : Number
        {
            return this.max.x - this.min.x;
        }
        public function get height() : Number
        {
            return this.max.y - this.min.y;
        }

        public function setCenter( vCenter : CVector2 ) : void
        {
            var extX : Number = max.x;
            var extY : Number = max.y;
            extX -= min.x; extY -= min.y;
            extX *= 0.5; extY *= 0.5;

            this.min.set( vCenter ); this.min.subOnValueXY( extX, extY );
            this.max.set( vCenter ); this.max.addOnValueXY( extX, extY );
        }

        public function setCenterValue( fCenterX : Number, fCenterY : Number ) : void
        {
            var extX : Number = max.x;
            var extY : Number = max.y;
            extX -= min.x; extY -= min.y;
            extX *= 0.5; extY *= 0.5;

            this.min.setValueXY( fCenterX - extX, fCenterY - extY );
            this.max.setValueXY( fCenterX + extX, fCenterY + extY );
        }
        public function getCenter() : CVector2
        {
            var vCenter : CVector2 = new CVector2( max.x, max.y );
            vCenter.addOn( min );
            vCenter.mulOnValue( 0.5 );
            return vCenter;
        }
        public function setExt( vExt : CVector2 ) : void
        {
            var centerX : Number = max.x;
            var centerY : Number = max.y;
            centerX += min.x; centerY += min.y;
            centerX *= 0.5; centerY *= 0.5;

            this.min.setValueXY( centerX, centerY ); this.min.subOn( vExt );
            this.max.setValueXY( centerX, centerY ); this.min.addOn( vExt );
        }
        public function setExtValue( fExtX : Number, fExtY : Number ) : void
        {
            var centerX : Number = max.x;
            var centerY : Number = max.y;
            centerX += min.x; centerY += min.y;
            centerX *= 0.5; centerY *= 0.5;

            this.min.setValueXY( centerX - fExtX, centerY - fExtY );
            this.max.setValueXY( centerX + fExtX, centerY + fExtY );
        }
        public function getExt() : CVector2
        {
            var vExt : CVector2 = new CVector2( max.x, max.y );
            vExt.subOn( min );
            vExt.mulOnValue( 0.5 );
            return vExt;
        }
        public function getExtX2() : CVector2
        {
            var vExt : CVector2 = new CVector2( max.x, max.y );
            vExt.subOn( min );
            return vExt;
        }

        public function enlargeExt( vExtend : CVector2 ) : void
        {
            min.subOn( vExtend );
            max.addOn( vExtend );
        }
        public function enlargeExtValue( fExtend : Number ) : void
        {
            min.subOnValue( fExtend );
            max.addOnValue( fExtend );
        }
        public function enlargeExtValueXY( fExtendX : Number, fExtendY : Number ) : void
        {
            min.x -= fExtendX;
            min.y -= fExtendY;
            max.x += fExtendX;
            max.y += fExtendY;
        }

        public function multiplyXY( fX : Number, fY : Number ) : void
        {
            min.mulOnValueXY( fX, fY );
            max.mulOnValueXY( fX, fY );

            var fTemp : Number;
            if( fX < 0.0 ) { fTemp = min.x; min.x = max.x; max.x = fTemp; }
            if( fY < 0.0 ) { fTemp = min.y; min.y = max.y; max.y = fTemp; }
        }

        public function equals( rhs : CAABBox2 ) : Boolean
        {
            if( max.equals( rhs.max ) == false || min.equals( rhs.min ) == false ) return false;
            else return true;
        }
        public function equalsVector( vMin : CVector2, vMax : CVector2 ) : Boolean
        {
            if( max.equals( vMax ) == false || min.equals( vMin ) == false ) return false;
            else return true;
        }
        public function equalsValue( xMin : Number, yMin : Number, xMax : Number, yMax : Number ) : Boolean
        {
            if( max.equalsValue( xMax, yMax ) == false || min.equalsValue( xMin, yMin ) == false ) return false;
            else return true;
        }

        public function equalsWithinError( rhs : CAABBox2, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( max.equalsWithinError( rhs.max, fError ) == false || min.equalsWithinError( rhs.min, fError ) == false ) return false;
            else return true;
        }
        public function equalsVectorWithinError( vMin : CVector2, vMax : CVector2, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( max.equalsWithinError( vMax, fError ) == false || min.equalsWithinError( vMin, fError ) == false ) return false;
            else return true;
        }
        public function equalsValueWithinError( xMin : Number, yMin : Number, xMax : Number, yMax : Number, fError : Number = CMath.EPSILON ) : Boolean
        {
            if( max.equalsValueWithinError( xMax, yMax, fError ) == false || min.equalsValueWithinError( xMin, yMin, fError ) == false ) return false;
            else return true;
        }

        public static function zero() : CAABBox2
        {
            return new CAABBox2( CVector2.ZERO, CVector2.ZERO );
        }

        //
        //
        public var min : CVector2 = new CVector2();
        public var max : CVector2 = new CVector2();

        //
        private var m_vCenter : CVector2 = null;
        private var m_vExt : CVector2 = null;
    }

}

