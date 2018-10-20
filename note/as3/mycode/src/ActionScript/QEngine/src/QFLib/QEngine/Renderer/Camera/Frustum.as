/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/15.
 */
package QFLib.QEngine.Renderer.Camera
{
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CMatrix4;
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.*;

    /**
     * Left Hand Coordinate System
     */
    public class Frustum extends MovableObject implements IDisposable
    {
        public static const ORTHO : int = 0;
        public static const PERSPECTIVE : int = 1;

        private static const sRawDataHelper : Vector.<Number> = new Vector.<Number>( 16 );

        public function Frustum( parent : SceneNode, frustumType : int )
        {
            super( parent );

            m_matProjection = new CMatrix4();
            m_FrustumType = frustumType;
        }
        /**
         * projection matrix, ortho or perspective
         */
        protected var m_matProjection : CMatrix4;
        protected var m_Near : Number = 0.3;
        protected var m_Far : Number = 1000.0;
        protected var m_Left : Number = -7.50;
        protected var m_Right : Number = 7.50;
        protected var m_Bottom : Number = -4.50;
        protected var m_Top : Number = 4.50;
        protected var m_FrustumType : int;
        protected var m_EnableCulling : Boolean = true;
        protected var m_FrustumDirty : Boolean = true;
        protected var m_VPDirty : Boolean = true;

        public function set left( value : Number ) : void
        {
            if( m_Left != value )
            {
                m_Left = value;
                m_FrustumDirty = true;
            }
        }

        public function set right( value : Number ) : void
        {
            if( m_Right != value )
            {
                m_Right = value;
                m_FrustumDirty = true;
            }
        }

        public function set bottom( value : Number ) : void
        {
            if( m_Bottom != value )
            {
                m_Bottom = value;
                m_FrustumDirty = true;
            }
        }

        public function set top( value : Number ) : void
        {
            if( m_Top != value )
            {
                m_Top = value;
                m_FrustumDirty = true;
            }
        }

        public function set near( value : Number ) : void
        {
            if( m_Near != value )
            {
                m_Near = value;
                m_FrustumDirty = true;
            }
        }

        public function set far( value : Number ) : void
        {
            if( m_Far != value )
            {
                m_Far = value;
                m_FrustumDirty = true;
            }
        }

        public function set frustumType( value : int ) : void
        {
            if( m_FrustumType != value )
            {
                m_FrustumType = value;
                m_FrustumDirty = true;
            }
        }

        [Inline]
        final public function get enableCulling() : Boolean
        { return m_EnableCulling; }

        [Inline]
        final public function set enableCulling( value : Boolean ) : void
        { m_EnableCulling = value; }

        override public function dispose() : void
        {
            m_matProjection = null;
        }

        /**
         *
         * @param aspect : right / top
         * @param fovY : must be radian, not degree
         * @param zNear
         * @param zFar
         */
        public function buildPerspectiveFrustum( aspect : Number, fovY : Number, zNear : Number, zFar : Number ) : void
        {
            m_Near = zNear;
            m_Far = zFar;

            var halfFovY : Number = fovY * 0.5;
            m_Top = Math.tan( halfFovY ) * zNear;
            m_Bottom = -m_Top;

            m_Right = m_Top * aspect;
            m_Left = -m_Right;

            m_FrustumDirty = true;
            m_FrustumType = Frustum.PERSPECTIVE;
        }

        /**
         *
         * @param right
         * @param top
         * @param zNear
         * @param zFar
         */
        public function buildOrthoFrustum( ratioHW : Number, right : Number, zNear : Number, zFar : Number ) : void
        {
            m_Right = right;
            m_Left = -right;
            m_Top = right * ratioHW;
            m_Bottom = -m_Top;
            m_Near = zNear;
            m_Far = zFar;

            m_FrustumDirty = true;
            m_FrustumType = Frustum.ORTHO;
        }

        public function getProjectionMatrix() : CMatrix4
        {
            if( m_FrustumDirty )
            {
                if( m_FrustumType == PERSPECTIVE )
                    computePerspectiveProjection();
                else
                    computeOrthoProjection();

                m_FrustumDirty = false;
                m_VPDirty = true;
            }

            return m_matProjection;
        }

        /**
         * ortho projection matrix:
         * x-[l, r] ---> [-1, 1]; y-[b, t] ---> [-1, 1]; z-[n, f] ---> [0, 1];
         * x1 = 2x0 / (r - l) - (r + l) / (r - l);
         * y1 = 2y0 / (t - b) - (t + b) / (t - b);
         * z1 = 1 / (f - n) - n / (f - n);
         */
        private function computeOrthoProjection() : void
        {
            var width : Number = m_Right - m_Left;
            var height : Number = m_Top - m_Bottom;
            var zDistance : Number = m_Far - m_Near;

            var rawData : Vector.<Number> = sRawDataHelper;
            rawData[ 0 ] = 2 / width;
            rawData[ 4 ] = 0;
            rawData[ 8 ] = 0;
            rawData[ 12 ] = -( m_Left + m_Right ) / width;

            rawData[ 1 ] = 0;
            rawData[ 5 ] = 2 / height;
            rawData[ 9 ] = 0;
            rawData[ 13 ] = -( m_Bottom + m_Right ) / height;

            rawData[ 2 ] = 0;
            rawData[ 6 ] = 0;
            rawData[ 10 ] = 1 / zDistance;
            rawData[ 14 ] = -m_Near / zDistance;

            rawData[ 15 ] = 1;
            rawData[ 3 ] = rawData[ 7 ] = rawData[ 11 ] = 0;
            m_matProjection.matrix3D.copyRawDataFrom( rawData );
        }

        /**
         * perspective projection matrix:
         * x1-[-1, 1], x2 = x0 * n/z, x1 = 2 * x2/(r - l) - (r + l)/(r - l) => x1 = 2 * x0 * n/z * (r - l) - (r + l)/(r - l)
         * y1-[-1, 1], y2 = y0 * n/z, y2 = 2 * y2/(t - b) - (t + b)/(t - b) ......
         * z1 = A/z + B = (A + B * z) / z, z1-[0, 1] => A = -f * n / (f - n), B = f / (f - n) => z1 = -f * n/z * (f - n) + f/(f - n)
         * make w1 = z, p1->(x1, y1, z1, 1) == (x2 = x1*w1, y2 = y1*w1, z2 = z1*w1, w1)
         */
        private function computePerspectiveProjection() : void
        {
            var width : Number = m_Right - m_Left;
            var height : Number = m_Top - m_Bottom;
            var zDistance : Number = m_Far - m_Near;

            var rawData : Vector.<Number> = sRawDataHelper;
            rawData[ 0 ] = ( 2 * m_Near ) / width;
            rawData[ 4 ] = 0;
            rawData[ 8 ] = -( m_Left + m_Right ) / width;
            rawData[ 12 ] = 0;

            rawData[ 1 ] = 0;
            rawData[ 5 ] = ( 2 * m_Near ) / height;
            rawData[ 9 ] = -( m_Bottom + m_Top ) / height;
            rawData[ 13 ] = 0;

            rawData[ 2 ] = 0;
            rawData[ 6 ] = 0;
            rawData[ 10 ] = ( m_Far ) / zDistance;
            rawData[ 14 ] = ( -m_Far * m_Near ) / zDistance;

            rawData[ 11 ] = 1;
            rawData[ 3 ] = rawData[ 7 ] = rawData[ 15 ] = 0;
            m_matProjection.matrix3D.copyRawDataFrom( rawData );
        }
    }
}