/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/8.
 */
package QFLib.QEngine.Renderer.Camera
{
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CMath;
    import QFLib.Math.CMatrix4;
    import QFLib.Math.CVector3;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Core.SceneNode;
    import QFLib.QEngine.Renderer.*;
    import QFLib.QEngine.Renderer.Device.RenderDevice;
    import QFLib.QEngine.Renderer.Device.RenderDeviceManager;
    import QFLib.QEngine.Renderer.Textures.RenderTexture;
    import QFLib.QEngine.SceneManage.SceneManager;

    public class Camera extends Frustum implements IDisposable
    {
        use namespace Engine_Internal;

        private static const sRawDataHelper : Vector.<Number> = new <Number>[ 1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0 ];

        function Camera( pRenderTarget : RenderTarget, pSceneMgr : SceneManager, frustumType : int = PERSPECTIVE, pParent : SceneNode = null, cullingMask : uint = 0x00, clearMask : uint = 0xffffffff, backGroundColor : uint = 0xffffffff, order : int = 0 )
        {
            if( pParent == null )
                pParent = m_pSceneMgr.root;

            super( pParent, frustumType );

            m_pRenderTarget = pRenderTarget;
            m_pSceneMgr = pSceneMgr;
            m_matView = new CMatrix4();
            m_matVP = new CMatrix4();

            m_CullingMask = cullingMask;
            m_ClearMask = clearMask;

            this.backGroundColor = backGroundColor;
            m_Order = order;
        }
        private var m_matView : CMatrix4;
        private var m_matVP : CMatrix4;
        private var m_ViewVector : CVector3 = new CVector3( 0, 0, 1 );
        private var m_UpVector : CVector3 = new CVector3( 0, 1, 0 );
        private var m_RightVector : CVector3 = new CVector3( 1, 0, 0 );
        private var m_Scale : CVector3 = CVector3.one();
        private var m_Position : CVector3 = CVector3.zero();
        private var m_pRenderTarget : RenderTarget = null;
        private var m_pSceneMgr : SceneManager = null;
        /**
         * clear color
         */
        private var m_BackGroundR : Number = 0.0;
        private var m_BackGroundG : Number = 0.0;
        private var m_BackGroundB : Number = 0.0;
        private var m_BackGroundAlpha : Number = 0.0;
        private var m_ViewportX : int = 0;
        private var m_ViewportY : int = 0;
        private var m_ViewportWidth : int = 1500;
        private var m_ViewportHeight : int = 900;
        private var m_Order : int = 0;
        /**
         * nothing would be culled by the camera
         */
        private var m_CullingMask : uint = 0x00;
        /**
         * would clear: color/depth/stencil buffers etc.
         */
        private var m_ClearMask : uint = 0xffffffff;
        private var m_ViewDirty : Boolean = true;

        [inline]
        public function get renderTarget() : RenderTarget
        { return m_pRenderTarget; }

        [inline]
        public function set renderTarget( target : RenderTarget ) : void
        { m_pRenderTarget = target; }

        [inline]
        public function get cullingMask() : uint
        { return m_CullingMask; }

        [inline]
        public function set cullingMask( value : uint ) : void
        { m_CullingMask = value; }

        [inline]
        public function get clearMask() : uint
        { return m_ClearMask; }

        [inline]
        public function set clearMask( value : uint ) : void
        { m_ClearMask = value; }

        [inline]
        public function get order() : int
        { return m_Order; }

        [inline]
        public function set order( value : int ) : void
        { m_Order = value; }

        public function set backGroundColor( value : uint ) : void
        {
            m_BackGroundR = ( ( value >> 24 ) & 0xff ) / 255.0;
            m_BackGroundG = ( ( value >> 16 ) & 0xff ) / 255.0;
            m_BackGroundB = ( ( value >> 8 ) & 0xff ) / 255.0;
            m_BackGroundAlpha = ( value & 0xff ) / 255.0;
        }

        public function set scale( value : CVector3 ) : void
        {
            if( m_Scale.equals( value ) ) return;

            m_Scale.x = value.x;
            m_Scale.y = value.y;
            m_Scale.z = value.z;

            m_ViewDirty = true;
        }

        public function set position( value : CVector3 ) : void
        {
            if( m_Position.equals( value ) ) return;

            m_Position.x = value.x;
            m_Position.y = value.y;
            m_Position.z = value.z;

            m_ViewDirty = true;
        }

        override public function dispose() : void
        {
            m_pRenderTarget = null;
            m_pSceneMgr = null;

            m_matView = null;
            m_matVP = null;

            m_Scale = null;
            m_Position = null;
            m_ViewVector = null;
            m_RightVector = null;
            m_UpVector = null;

            super.dispose();
        }

        public function setScale( value : CVector3 ) : void
        {
            if( !m_Scale.equals( value ) )
            {
                m_Scale.set( value );
                m_ViewDirty = true;
            }
        }

        public function setOrientation( value : CVector3 ) : void
        {
            if( !m_ViewVector.equals( value ) )
            {
                m_ViewVector.set( value );
                m_ViewDirty = true;
            }
        }

        public function setPosition( value : CVector3 ) : void
        {
            if( !m_Position.equals( value ) )
            {
                m_Position.set( value );
                m_ViewDirty = true;
            }
        }

        public function translate( value : CVector3 ) : void
        {
            if( !value.equals( CVector3.zero() ) )
            {
                m_Position.addOn( value );
                m_ViewDirty = true;
            }
        }

        /**
         * euler -- heading
         * @param radian
         */
        public function yaw( radian : Number ) : void
        {
            if( Math.abs( radian ) < CMath.BIG_EPSILON ) return;

            var r : Number = CMath.wrapPi( radian );
            var sr : Number = Math.sin( r );
            var cr : Number = Math.cos( r );

            m_ViewVector.setValueXYZ( m_ViewVector.x * cr + m_RightVector.x * sr,
                    m_ViewVector.y * cr + m_RightVector.y * sr,
                    m_ViewVector.z * cr + m_RightVector.z * sr );

            m_RightVector.setValueXYZ( m_RightVector.x * cr - m_ViewVector.x * sr,
                    m_RightVector.y * cr - m_ViewVector.y * sr,
                    m_RightVector.z * cr - m_ViewVector.z * sr );

            m_ViewVector.normalize();
            m_RightVector.normalize();

            m_ViewDirty = true;
        }

        /**
         * euler -- pitch: radian(-pi * 0.5, pi * 0.5)
         */
        public function pitch( radian : Number ) : void
        {
            if( Math.abs( radian ) < CMath.BIG_EPSILON ) return;

            var r : Number = CMath.wrapPi( radian );
            var sr : Number = Math.sin( r );
            var cr : Number = Math.cos( r );

            m_UpVector.setValueXYZ( m_UpVector.x * cr + m_ViewVector.x * sr,
                    m_UpVector.y * cr + m_ViewVector.y * sr,
                    m_UpVector.z * cr + m_ViewVector.z * sr );

            m_ViewVector.setValueXYZ( m_ViewVector.x * cr - m_UpVector.x * sr,
                    m_ViewVector.y * cr - m_UpVector.y * sr,
                    m_ViewVector.z * cr - m_UpVector.z * sr );

            m_UpVector.normalize();
            m_ViewVector.normalize();

            m_ViewDirty = true;
        }

        /**
         * euler -- bank
         * @param radian
         */
        public function roll( radian : Number ) : void
        {
            if( Math.abs( radian ) < CMath.BIG_EPSILON ) return;

            var r : Number = CMath.wrapPi( radian );
            var sr : Number = Math.sin( r );
            var cr : Number = Math.cos( r );

            m_RightVector.setValueXYZ( m_RightVector.x * cr + m_UpVector.x * sr,
                    m_RightVector.y * cr + m_UpVector.y * sr,
                    m_RightVector.z * cr + m_UpVector.z * sr );

            m_UpVector.setValueXYZ( m_UpVector.x * cr - m_RightVector.x * sr,
                    m_UpVector.y * cr - m_RightVector.y * sr,
                    m_UpVector.z * cr - m_RightVector.z * sr );

            m_RightVector.normalize();
            m_UpVector.normalize();

            m_ViewDirty = true;
        }

        /**
         *
         * @param target: target position
         * @param up: help for decide the camera orientation, and the camera axis system
         */
        public function lookAt( target : CVector3, up : CVector3 ) : void
        {
            m_ViewVector.setValueXYZ( target.x - m_Position.x,
                    target.y - m_Position.y,
                    target.z - m_Position.z );
            m_ViewVector.normalize();

            m_UpVector.set( up );
            m_UpVector.crossProduct( m_ViewVector, m_RightVector );
            m_RightVector.normalize();

            m_ViewVector.crossProduct( m_RightVector, m_UpVector );
            m_UpVector.normalize();

            m_ViewDirty = true;
        }

        public function getViewMatrix() : CMatrix4
        {
            if( m_ViewDirty )
            {
                computeViewMatrix();
                m_ViewDirty = false;
                m_VPDirty = true;
            }

            return m_matView;
        }

        /**
         *
         * @return: Get projection * view matrix
         */
        public function getVPMatrix() : CMatrix4
        {
            getProjectionMatrix();
            getViewMatrix();

            if( m_VPDirty )
            {
                m_matVP.copy( m_matView );
                m_matVP.append( m_matProjection );
                m_VPDirty = false;
            }

            return m_matVP;
        }

        public function setBackGroundColor( red : Number, green : Number, blue : Number, alpha : Number ) : void
        {
            m_BackGroundR = red;
            m_BackGroundG = green;
            m_BackGroundB = blue;
            m_BackGroundAlpha = alpha;
        }

        public function setViewport( x : int, y : int, width : int, height : int ) : void
        {
            m_ViewportX = x;
            m_ViewportY = y;
            m_ViewportWidth = width;
            m_ViewportHeight = height;
        }

        private function computeViewMatrix() : void
        {
            var dx : Number = ( -m_Position.x * m_RightVector.x - m_Position.y * m_RightVector.y - m_Position.z * m_RightVector.z ) * m_Scale.x;
            var dy : Number = ( -m_Position.x * m_UpVector.x - m_Position.y * m_UpVector.y - m_Position.z * m_UpVector.z ) * m_Scale.y;
            var dz : Number = ( -m_Position.x * m_ViewVector.x - m_Position.y * m_ViewVector.y - m_Position.z * m_ViewVector.z ) * m_Scale.z;

            var rawData : Vector.<Number> = sRawDataHelper;
            //we can build world to camera view matrix
            rawData[ 0 ] = m_RightVector.x * m_Scale.x;
            rawData[ 4 ] = m_RightVector.y * m_Scale.x;
            rawData[ 8 ] = m_RightVector.z * m_Scale.x;
            rawData[ 12 ] = dx;

            rawData[ 1 ] = m_UpVector.x * m_Scale.y;
            rawData[ 5 ] = m_UpVector.y * m_Scale.y;
            rawData[ 9 ] = m_UpVector.z * m_Scale.y;
            rawData[ 13 ] = dy;

            rawData[ 2 ] = m_ViewVector.x * m_Scale.z;
            rawData[ 6 ] = m_ViewVector.y * m_Scale.z;
            rawData[ 10 ] = m_ViewVector.z * m_Scale.z;
            rawData[ 14 ] = dz;

            rawData[ 15 ] = 1;
            rawData[ 3 ] = rawData[ 7 ] = rawData[ 11 ] = 0;
            m_matView.matrix3D.copyRawDataFrom( rawData );
        }

        Engine_Internal function _startRendering() : void
        {
            var renderDevice : RenderDevice = m_pRenderTarget.renderDevice;
            if( !renderDevice.contextValid ) return;

            var renderTexture : RenderTexture = m_pRenderTarget as RenderTexture;
            var isRenderTexture : Boolean = ( renderTexture != null );
            RenderDeviceManager.getInstance().makeCurrent( renderDevice );
            renderDevice.setViewport( m_ViewportX, m_ViewportY, m_ViewportWidth, m_ViewportHeight );
            if( isRenderTexture )
            {
                renderTexture.updateTexture();
                renderDevice.setRenderToTexture( renderTexture.texture.base );
            }
            else
            {
                renderDevice.setRenderToBackBuffer();
            }

            renderDevice.setClearColorAndMask( m_BackGroundR, m_BackGroundG, m_BackGroundB, m_BackGroundAlpha, Number.MAX_VALUE, 0, m_ClearMask );

            getVPMatrix();
        }

        Engine_Internal function _endRendering( present : Boolean ) : void
        {
            var renderDevice : RenderDevice = m_pRenderTarget.renderDevice;
            if( !renderDevice.contextValid ) return;

            if( present )
                renderDevice.present();
        }
    }
}
