//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/5/20
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Scene
{

    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.CRenderer;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CMath;
    import QFLib.Math.CVector2;

    public class CCamera
	{
		public function CCamera( theRenderer : CRenderer )
		{
            m_theRenderer = theRenderer;
            m_theCurrentCameraBox.setExtValue( Number( m_theRenderer.stageWidth ) / 2.0, Number( m_theRenderer.stageHeight ) / 2.0 );
		}
        public function dispose() : void
        {
            m_vSceneLayerCameras.length = 0;
            m_theFollowingTarget = m_theFollowingTarget2 = null;
        }

        //
        // mode 0: just target to an object
        // mode 1: interpolate camera's position and viewport size among all camera anchors
        // fSpringFactor: the bigger the camera move faster to the destination point
        // fCounterResistanceFactor: the bigger the camera counter the resistance faster
        //
        public function setFollowingMode( iFollowingMode : int, fSpringFactor : Number = 3.0, fCounterResistanceFactor : Number = 3.0,
                                            fCenterShiftFactor : Number = 0.8, bKeepAspectRatio: Boolean = true ) : void
        {
            m_iFollowingMode = iFollowingMode;

            m_fSpringFactor = m_fSpringFactorInZoom = fSpringFactor;
            m_fCounterResistanceFactor = m_fCounterResistanceFactorInZoom = fCounterResistanceFactor;
            m_fCenterShiftFactor = fCenterShiftFactor;
            m_bKeepAspectRatio = bKeepAspectRatio;

            if( m_fnOnCameraFollowingModeChanged != null ) m_fnOnCameraFollowingModeChanged();
        }
        [Inline]
        public function get followingMode() : int
        {
            return m_iFollowingMode;
        }

        // get / set of camera's following target
        [Inline]
        public function get followingTarget() : CBaseObject
        {
            return m_theFollowingTarget;
        }
        [Inline]
        public function get followingTarget2() : CBaseObject
        {
            return m_theFollowingTarget2;
        }

        public function setFollowingTarget( target : CBaseObject, target2 : CBaseObject = null ) : void
        {
            m_theFollowingTarget = target;
            m_theFollowingTarget2 = target2;

            if( m_fnOnCameraTargetChanged != null ) m_fnOnCameraTargetChanged();
        }

        // enable / disable the camera
        [Inline]
        public function get enabled() : Boolean
        {
            return m_bEnabled;
        }
        public function set enabled( bEnable : Boolean ) : void
        {
            if( m_bEnabled == bEnable ) return ;

            m_bEnabled = bEnable;
            var iNumCameras : int = m_vSceneLayerCameras.length;
            for( var i : int = 0; i < iNumCameras; ++i )
            {
                m_vSceneLayerCameras[ i ].enabled = bEnable;
            }

            if( m_fnOnCameraEnabled != null ) m_fnOnCameraEnabled();
        }

        [Inline]
        public function moveToTargetAtOnce() : void
        {
            m_bDisableSmoothMovingOnce = true;

            var bEnable : Boolean = m_bEnabled;
            m_bEnabled = true;
            update( 0.0 );
            m_bEnabled = bEnable;
        }

        //
        // external callbacks
        //
        public function set onCameraEnabled( fnOnCameraEnabled : Function ) : void
        {
            m_fnOnCameraEnabled = fnOnCameraEnabled;
        }
        public function set onCameraFollowingModeChanged( fnOnCameraFollowingModeChanged : Function ) : void
        {
            m_fnOnCameraFollowingModeChanged = fnOnCameraFollowingModeChanged;
        }
        public function set onCameraTargetChanged( fnOnCameraTargetChanged : Function ) : void
        {
            m_fnOnCameraTargetChanged = fnOnCameraTargetChanged;
        }

        // current camera's center / ext / min / max
        public function get center() : CVector2
        {
            return m_theCurrentCameraBox.center;
        }
        public function get ext() : CVector2
        {
            return m_theCurrentCameraBox.ext;
        }
        public function get min() : CVector2
        {
            return m_theCurrentCameraBox.min;
        }
        public function get max() : CVector2
        {
            return m_theCurrentCameraBox.max;
        }

        //
        public function get numEffectiveCameraAnchors() : int
        {
            return m_iNumEffectiveCamAnchors;
        }

        // set / get movable constrain box
        public function setMovableBoxCenterExtValue( fCenterX: Number, fCenterY: Number, fExtX: Number, fExtY: Number, bLockMovableConstrainBoxImmediately : Boolean ) : void
        {
            if( m_theMovableBox == null ) m_theMovableBox = new CAABBox2( CVector2.ZERO );
            m_theMovableBox.setCenterExtValue( fCenterX, fCenterY, fExtX, fExtY );

            m_bLockMovableBoxImmediately = bLockMovableConstrainBoxImmediately;

            if( m_bLockMovableBoxImmediately ) m_bCheckMovableBox = true;
            else m_bCheckMovableBox = false;
        }
        public function set movableBox( theAABB : CAABBox2 ) : void
        {
            m_theMovableBox = theAABB;

            // reset the resistance factor
            m_fCurrentResistance = DEFAULT_RESISTANCE;

            if( m_theMovableBox != null )
            {
                if( m_bLockMovableBoxImmediately ) m_bCheckMovableBox = true;
                else m_bCheckMovableBox = false;
            }
            else m_bCheckMovableBox = false;
        }
        [Inline]
        final public function get movableBox() : CAABBox2
        {
            return m_theMovableBox;
        }

        public function setMovableBoxLockMode( bLockImmediate : Boolean ) : void
        {
            m_bLockMovableBoxImmediately = bLockImmediate;
        }

        public function set sceneMovableBox( theAABB : CAABBox2 ) : void
        {
            m_theSceneMovableBox = theAABB;
        }
        public function get sceneMovableBox() : CAABBox2
        {
            return m_theSceneMovableBox;
        }

        // custom camera offset that user can specify
        public function setOffset( x : Number, y : Number ) : void
        {
            m_vOffset.x = x;
            m_vOffset.y = y;
            _applyToFinalCameraBox( m_theCurrentCameraBox );
        }

        [Inline]
        final public function get currentCameraBox() : CAABBox2
        {
            return m_theFinalCameraBox;
        }

        // shake camera with the XY intensity for a period of time
        public function shake( fIntensity : Number, fTimeDuration : Number, fShakeDeltaTimePeriod : Number = 0.02 ) : void
        {
            shakeXY( fIntensity, fIntensity, fTimeDuration, fShakeDeltaTimePeriod );
        }
        public function shakeXY( fIntensityX : Number, fIntensityY : Number, fTimeDuration : Number, fShakeDeltaTimePeriod : Number = 0.02 ) : void
        {
            m_fShakeTimeDuration = m_fShakeTime = fTimeDuration;
            var fScreenRatioX : Number = m_theRenderer.stageWidth / 1500.0;
            var fScreenRatioY : Number = m_theRenderer.stageHeight / ( 1500.0 / m_theRenderer.stageScreenRatio );
            m_vShakeIntensity.x = fIntensityX * fScreenRatioX;
            m_vShakeIntensity.y = fIntensityY * fScreenRatioY;

            m_fShakeDeltaTimePeriod = fShakeDeltaTimePeriod;

            if( s_vShakeRandomOffsets == null )
            {
                s_vShakeRandomOffsets = CMath.generateRandomVector( 64, -1.0, 1.0, 2.0 );
                for( var i : int = 0; i < s_vShakeRandomOffsets.length; i++ )
                {
                    if( i >= 2 )
                    {
                        if( s_vShakeRandomOffsets[ i - 2 ] > 0.0 && s_vShakeRandomOffsets[ i ] > 0.0 ) s_vShakeRandomOffsets[ i ] = -s_vShakeRandomOffsets[ i ];
                        else if( s_vShakeRandomOffsets[ i - 2 ] < 0.0 && s_vShakeRandomOffsets[ i ] < 0.0 ) s_vShakeRandomOffsets[ i ] = -s_vShakeRandomOffsets[ i ];
                    }
                }
            }
        }
        public function stopShake() : void
        {
            m_fShakeTime = 0.0;
            m_vShakeOffset.setValueXY( 0.0, 0.0 );
        }

        // zoom shake camera for a period of time
        public function zoomShake( fIntensity : Number, fTimeDuration : Number, fShakeDeltaTimePeriod : Number = 0.02 ) : void
        {
            zoomShakeWithTargetScreenPosition( m_theRenderer.nativeStageWidth * 0.5, m_theRenderer.nativeStageHeight * 0.5, fIntensity, fTimeDuration, fShakeDeltaTimePeriod );
        }
        public function zoomShakeWithTargetScreenPosition( fScreenPosX : Number, fScreenPosY : Number, fIntensity : Number, fTimeDuration : Number, fShakeDeltaTimePeriod : Number = 0.02 ) : void
        {
            m_fZoomShakeTimeDuration = m_fZoomShakeTime = fTimeDuration;
            var fScreenRatioX : Number = m_theRenderer.stageWidth / 1500.0;
            var fScreenRatioY : Number = m_theRenderer.stageHeight / ( 1500.0 / m_theRenderer.stageScreenRatio );
            m_vZoomShakeIntensity.x = fIntensity * fScreenRatioX;
            m_vZoomShakeIntensity.y = fIntensity * fScreenRatioY;

            m_vZoomShakeDirection.x = ( fScreenPosX - ( m_theRenderer.nativeStageWidth * 0.5 ) ) / ( m_theRenderer.nativeStageWidth * 0.5 );
            if( m_vZoomShakeDirection.x > 1.0 ) m_vZoomShakeDirection.x = 1.0;
            else if( m_vZoomShakeDirection.x < -1.0 ) m_vZoomShakeDirection.x = -1.0;
            m_vZoomShakeDirection.y = ( fScreenPosY - ( m_theRenderer.nativeStageHeight * 0.5 ) ) / ( m_theRenderer.nativeStageHeight * 0.5 );
            if( m_vZoomShakeDirection.y > 1.0 ) m_vZoomShakeDirection.y = 1.0;
            else if( m_vZoomShakeDirection.y < -1.0 ) m_vZoomShakeDirection.y = -1.0;

            m_fZoomShakeDeltaTimePeriod = fShakeDeltaTimePeriod;

            if( s_vShakeRandomOffsets == null )
            {
                s_vShakeRandomOffsets = CMath.generateRandomVector( 64, -1.0, 1.0, 2.0 );
                for( var i : int = 0; i < s_vShakeRandomOffsets.length; i++ )
                {
                    if( i >= 2 )
                    {
                        if( s_vShakeRandomOffsets[ i - 2 ] > 0.0 && s_vShakeRandomOffsets[ i ] > 0.0 ) s_vShakeRandomOffsets[ i ] = -s_vShakeRandomOffsets[ i ];
                        else if( s_vShakeRandomOffsets[ i - 2 ] < 0.0 && s_vShakeRandomOffsets[ i ] < 0.0 ) s_vShakeRandomOffsets[ i ] = -s_vShakeRandomOffsets[ i ];
                    }
                }
            }
        }
        public function stopZoomShake() : void
        {
            m_fZoomShakeTime = 0.0;
            m_vZoomShakeExtOffset.setValueXY( 0.0, 0.0 );
        }

        // zoom / unzoom the camera for a period of time( fTimeDuration < 0 means infinity )
        public function zoomTo( fCenterX : Number, fCenterY : Number, fExtX : Number = -1.0, fExtY : Number = -1.0 ) : int
        {
            return zoomCenterExtValue( false, fCenterX, fCenterY, fExtX, fExtY );
        }
        public function zoomCenterExt( bZoomRelatively : Boolean, vCenter : CVector2, vExt : CVector2 = null, fTimeDuration : Number = -1.0 ) : int
        {
            if( vExt == null ) return zoomCenterExtValue( bZoomRelatively, vCenter.x, vCenter.y, -1.0, -1.0, fTimeDuration );
            else return zoomCenterExtValue( bZoomRelatively, vCenter.x, vCenter.y, vExt.x, vExt.y, fTimeDuration );
        }
        public function zoomCenterExtValue( bZoomRelatively : Boolean, fCenterX : Number, fCenterY : Number, fExtX : Number = -1.0, fExtY : Number = -1.0, fZoomTimeDuration : Number = -1.0,
                                              fSpringFactorInZoom : Number = -1.0, fCounterResistanceFactorInZoom : Number = -1.0 ) : int
        {
            if( m_fZoomTime != 0.0 ) _pushCurrentZoomFactors();

            if( fZoomTimeDuration == 0.0 ) fZoomTimeDuration = -1.0; // it is meaningless that user give fTimeDuration = 0.0, so set to -1.0 ( infinity )
            m_fZoomTime = fZoomTimeDuration;

            m_bZoomRelatively = bZoomRelatively;

            if( m_theZoomBox == null ) m_theZoomBox = new CAABBox2( CVector2.ZERO );

            if( fExtX < 0.0 ) fExtX = m_theCurrentCameraBox.ext.x;
            if( fExtY < 0.0 ) fExtY = m_theCurrentCameraBox.ext.y;
            m_theZoomBox.setCenterExtValue( fCenterX, fCenterY, fExtX, fExtY );

            if( fSpringFactorInZoom > 0.0 ) m_fSpringFactorInZoom = fSpringFactorInZoom;
            else m_fSpringFactorInZoom = m_fSpringFactor;
            if( fCounterResistanceFactorInZoom > 0.0 ) m_fCounterResistanceFactorInZoom = fCounterResistanceFactorInZoom;
            else m_fCounterResistanceFactorInZoom = m_fCounterResistanceFactor;

            return m_vZoomLayers.length;
        }
        public function unZoom( bUnZoomAll : Boolean = false ) : void
        {
            if( bUnZoomAll ) m_vZoomLayers.length = 0;

            if( m_vZoomLayers.length > 0 )
            {
                var theZoom : _CZoomLayers = m_vZoomLayers.pop();
                m_theZoomBox = theZoom.m_theZoomBox;
                m_bZoomRelatively = theZoom.m_bZoomRelatively;
                m_fZoomTime = theZoom.m_fZoomTime;
            }
            else
            {
                m_theZoomBox = null;
                m_fZoomTime = 0.0;
            }
        }
        public function unZoomToLayer( iUnZoomToLayer : int = -1 ) : void
        {
            if( iUnZoomToLayer < -1 ) iUnZoomToLayer = -1;
            m_vZoomLayers.length = iUnZoomToLayer + 1;
            unZoom( false );
        }
        public function isZooming( iZoomLayer : int = -1 ) : Boolean
        {
            if( m_fZoomTime == 0.0 ) return false;

            if( iZoomLayer < 0 ) return true;
            else
            {
                if( m_vZoomLayers.length >= iZoomLayer ) return true;
                else return false
            }
        }
        public function get currentZoomLayer() : int
        {
            if( m_fZoomTime == 0.0 ) return -1;
            else return m_vZoomLayers.length;
        }

        public function addSubCamera( camera : CSceneLayerCamera ) : void
        {
            camera.enabled = m_bEnabled;
            m_vSceneLayerCameras.push( camera );
            _applyToFinalCameraBox( m_theCurrentCameraBox );
        }

        public function addCameraAnchor( vCenter : CVector2, vExt : CVector2, vOuterExt : CVector2 ) : void
        {
            m_vCameraAnchors.push( new CCameraAnchor( vCenter, vExt, vOuterExt ) );
            m_vCamAnchorVectors.push( new _CCamAnchorVector( m_vCamAnchorVectors.length, new CVector2() ) );
        }

        public function screenToWorld( thePoint : CVector2 ) : void
        {
            screenToWorldValueXY( thePoint.x, thePoint.y, thePoint );
        }
        public function screenToWorldValueXY( x : Number, y : Number, theWorldPoint : CVector2 ) : void
        {
            var vCenter : CVector2 = m_theFinalCameraBox.center;
            var vExt : CVector2 = m_theFinalCameraBox.ext;

            var fScaleW : Number = vExt.x * 2.0 / m_theRenderer.nativeStageWidth;
            var fScaleH : Number = vExt.y * 2.0 / m_theRenderer.nativeStageHeight;
            theWorldPoint.x = ( x - m_theRenderer.nativeStageWidth * 0.5 ) * fScaleW + vCenter.x;
            theWorldPoint.y = ( y - m_theRenderer.nativeStageHeight * 0.5 ) * fScaleH + vCenter.y;
        }

        public function worldToScreen( thePoint : CVector2 ) : void
        {
            worldToScreenValueXY( thePoint.x, thePoint.y, thePoint );
        }
        public function worldToScreenValueXY( x : Number, y : Number, theScreenPoint : CVector2 ) : void
        {
            var vCenter : CVector2 = m_theFinalCameraBox.center;
            var vExt : CVector2 = m_theFinalCameraBox.ext;

            var fScaleW : Number = vExt.x * 2.0 / m_theRenderer.nativeStageWidth;
            var fScaleH : Number = vExt.y * 2.0 / m_theRenderer.nativeStageHeight;
            theScreenPoint.x = ( x - vCenter.x ) / fScaleW + m_theRenderer.nativeStageWidth * 0.5;
            theScreenPoint.y = ( y - vCenter.y ) / fScaleH + m_theRenderer.nativeStageHeight * 0.5;
        }

        public function enlargeCollsionCameraSize( vEnlargeCamBoxSize : CVector2 ) : void
        {
            if( vEnlargeCamBoxSize != null )
            {
                m_vEnlargeCollisionCamBoxSize = vEnlargeCamBoxSize.clone();
                m_theEnlargedFinalCamBox = new CAABBox2( CVector2.ZERO );
            }
            else
            {
                m_vEnlargeCollisionCamBoxSize = null;
                m_theEnlargedFinalCamBox = null;
            }
        }

        public function isCollided( theGlobalBound : CAABBox2, iLayerIndex : int = -1 ) : Boolean
        {
            var theFinalCameraBox : CAABBox2;
            if( iLayerIndex < 0 || iLayerIndex >= m_vSceneLayerCameras.length ) theFinalCameraBox = m_theFinalCameraBox;
            else theFinalCameraBox = m_vSceneLayerCameras[ iLayerIndex ].cameraBox;

            if( m_vEnlargeCollisionCamBoxSize != null )
            {
                m_theEnlargedFinalCamBox.set( theFinalCameraBox );
                m_theEnlargedFinalCamBox.enlargeExt( m_vEnlargeCollisionCamBoxSize );
                return m_theEnlargedFinalCamBox.isCollided( theGlobalBound );
            }
            else return theFinalCameraBox.isCollided( theGlobalBound );
        }

        public function isCollidedWithObject( obj : CBaseObject ) : Boolean
        {
            var theParent : CBaseObject = obj.parent;
            while( theParent != null )
            {
                if( theParent is CSceneLayer ) break;
                else theParent = theParent.parent;
            }

            var theFinalCameraBox : CAABBox2;
            if( theParent == null ) theFinalCameraBox = m_theFinalCameraBox;
            else
            {
                var iLayerIndex : int = ( theParent as CSceneLayer ).index;
                theFinalCameraBox = m_vSceneLayerCameras[ iLayerIndex ].cameraBox;
            }

            if( m_vEnlargeCollisionCamBoxSize != null )
            {
                m_theEnlargedFinalCamBox.set( theFinalCameraBox );
                m_theEnlargedFinalCamBox.enlargeExt( m_vEnlargeCollisionCamBoxSize );
                return m_theEnlargedFinalCamBox.isCollided( obj.currentGlobalBound );
            }
            else return theFinalCameraBox.isCollided( obj.currentGlobalBound );
        }

        public function isCollidedPointValue( f2DPosX : int, f2DPosY : int, iLayerIndex : int = -1 ) : Boolean
        {
            var theFinalCameraBox : CAABBox2;
            if( iLayerIndex < 0 || iLayerIndex >= m_vSceneLayerCameras.length ) theFinalCameraBox = m_theFinalCameraBox;
            else theFinalCameraBox = m_vSceneLayerCameras[ iLayerIndex ].cameraBox;

            if( m_vEnlargeCollisionCamBoxSize != null )
            {
                m_theEnlargedFinalCamBox.set( theFinalCameraBox );
                m_theEnlargedFinalCamBox.enlargeExt( m_vEnlargeCollisionCamBoxSize );
                return m_theEnlargedFinalCamBox.isCollidedVertexValue( f2DPosX, f2DPosY );
            }
            else return theFinalCameraBox.isCollidedVertexValue( f2DPosX, f2DPosY );
        }

        public function setFinalCameraBox( aabb : CAABBox2 ) : void
        {
            _applyToFinalCameraBox( aabb );
        }

        public function backoff( fBackoffScale : Number ) : void
        {
            var iNumCameras : int = m_vSceneLayerCameras.length;
            for( var i : int = 0; i < iNumCameras; ++i )
            {
                m_vSceneLayerCameras[ i ].backoff( fBackoffScale );
            }
        }

        public virtual function update( fDeltaTime : Number ) : void
		{
            if( m_bEnabled == false ) return;

            _shakeUpdate( fDeltaTime );
            _zoomShakeUpdate( fDeltaTime );
            _zoomUpdate( fDeltaTime );

            if( m_theFollowingTarget != null && m_theFollowingTarget.disposed ) this.setFollowingTarget( null );
            if( m_theFollowingTarget2 != null && m_theFollowingTarget2.disposed ) this.setFollowingTarget( m_theFollowingTarget, null );

            if( m_theFollowingTarget != null )
            {
                if( m_iFollowingMode == 0 )
                {
                    m_theCurrentCameraBox.setCenterValue(  m_theFollowingTarget.x,  m_theFollowingTarget.y );
                    _applyToFinalCameraBox( m_theCurrentCameraBox );
                }
                else if( m_iFollowingMode == 1 )
                {
                    var fXDiff : Number = 0.0;
                    var fYDiff : Number = 0.0;
                    if( m_theFollowingTarget2 != null )
                    {
                        _calculateCameraBox( m_theFollowingTarget.x,  m_theFollowingTarget.y );
                        var fMaxXDiff : Number = m_theCameraBox.ext.x;
                        var fMaxYDiff : Number = m_theCameraBox.ext.y;
                        if( m_theFollowingTarget.currentBound != null )
                        {
                            fMaxXDiff -= m_theFollowingTarget.currentBound.ext.x;
                            if( fMaxXDiff < 0.0 ) fMaxXDiff = -fMaxXDiff;
                            fMaxYDiff -= m_theFollowingTarget.currentBound.ext.y;
                            if( fMaxYDiff < 0.0 ) fMaxYDiff = -fMaxYDiff;
                        }
                        fMaxXDiff *= m_fCenterShiftFactor;
                        fMaxYDiff *= m_fCenterShiftFactor;

                        fXDiff = ( m_theFollowingTarget2.x - m_theFollowingTarget.x ) * 0.5;
                        if( CMath.abs( fXDiff ) > fMaxXDiff )
                        {
                            if( fXDiff > 0.0 ) fXDiff = fMaxXDiff;
                            else fXDiff = -fMaxXDiff;
                        }
                        fYDiff = ( m_theFollowingTarget2.y - m_theFollowingTarget.y ) * 0.5;
                        if( CMath.abs( fYDiff ) > fMaxYDiff )
                        {
                            if( fYDiff > 0.0 ) fYDiff = fMaxYDiff;
                            else fYDiff = -fMaxYDiff;
                        }
                    }

                    var fFollowingPositionX : Number = m_theFollowingTarget.x + fXDiff;
                    var fFollowingPositionY : Number = m_theFollowingTarget.y + fYDiff;
                    _calculateCameraBox( fFollowingPositionX, fFollowingPositionY );
                    _calculateSpringCameraBox( fDeltaTime );
                    _calculateCurrentCameraBox( fDeltaTime, fFollowingPositionX, fFollowingPositionY );

                    _applyToFinalCameraBox( m_theCurrentCameraBox );

                    // do resistance calculation
                    if( m_bCameraMoved )
                    {
                        if( m_fCurrentResistance > 0.0 )
                        {
                            if( m_fZoomTime != 0.0 ) m_fCurrentResistance -= fDeltaTime * m_fCounterResistanceFactorInZoom;
                            else m_fCurrentResistance -= fDeltaTime * m_fCounterResistanceFactor;

                            if( m_fCurrentResistance < 0.0 ) m_fCurrentResistance = 0.0;
                        }
                        m_bCameraMoved = false;
                    }
                    else m_fCurrentResistance = DEFAULT_RESISTANCE;
                }

                if( m_bDisableSmoothMovingOnce ) m_bDisableSmoothMovingOnce = false;
            }
        }

        //
        //
        private function _shakeUpdate( fDeltaTime : Number ) : void
        {
            if( m_fShakeTime > 0.0 )
            {
                m_fShakeDeltaTime += fDeltaTime;
                if( m_fShakeDeltaTime > m_fShakeDeltaTimePeriod )
                {
                    m_vShakeOffset.x = s_vShakeRandomOffsets[ m_iShakeRandomIndex++ ] * m_vShakeIntensity.x;
                    if( m_iShakeRandomIndex >= s_vShakeRandomOffsets.length ) m_iShakeRandomIndex = 0;
                    m_vShakeOffset.y = s_vShakeRandomOffsets[ m_iShakeRandomIndex++ ] * m_vShakeIntensity.y;
                    if( m_iShakeRandomIndex >= s_vShakeRandomOffsets.length ) m_iShakeRandomIndex = 0;

                    m_vShakeOffset.mulOnValue( m_fShakeTime / m_fShakeTimeDuration );

                    m_fShakeTime -= m_fShakeDeltaTime;
                    m_fShakeDeltaTime %= m_fShakeDeltaTimePeriod;
                    if( m_fShakeTime <= 0.0 )
                    {
                        stopShake();
                    }
                }
            }
        }
        private function _zoomShakeUpdate( fDeltaTime : Number ) : void
        {
            if( m_fZoomShakeTime > 0.0 )
            {
                m_fZoomShakeDeltaTime += fDeltaTime;
                if( m_fZoomShakeDeltaTime > m_fZoomShakeDeltaTimePeriod )
                {
                    m_vZoomShakeExtOffset.x = s_vShakeRandomOffsets[ m_iZoomShakeRandomIndex++ ] * m_vZoomShakeIntensity.x;
                    if( m_iZoomShakeRandomIndex >= s_vShakeRandomOffsets.length ) m_iZoomShakeRandomIndex = 0;
                    m_vZoomShakeExtOffset.y = s_vShakeRandomOffsets[ m_iZoomShakeRandomIndex++ ] * m_vZoomShakeIntensity.y;
                    if( m_iZoomShakeRandomIndex >= s_vShakeRandomOffsets.length ) m_iZoomShakeRandomIndex = 0;

                    m_vZoomShakeExtOffset.mulOnValue( m_fZoomShakeTime / m_fZoomShakeTimeDuration );

                    m_vZoomShakeCenterOffset.x = -m_vZoomShakeDirection.x * m_vZoomShakeExtOffset.x;
                    m_vZoomShakeCenterOffset.y = -m_vZoomShakeDirection.y * m_vZoomShakeExtOffset.y;

                    m_fZoomShakeTime -= m_fZoomShakeDeltaTime;
                    m_fZoomShakeDeltaTime %= m_fZoomShakeDeltaTimePeriod;
                    if( m_fZoomShakeTime <= 0.0 )
                    {
                        stopZoomShake();
                    }
                }
            }
        }

        private function _zoomUpdate( fDeltaTime : Number ) : void
        {
            if( m_fZoomTime > 0.0 )
            {
                m_fZoomTime -= fDeltaTime;
                if( m_fZoomTime <= 0.0 ) unZoom();
            }
        }

        private function _findNearestCameraPair( x : Number, y : Number ) : CCameraAnchor
        {
            var fLengthSqr : Number;
            var fNearest : Number = Number.MAX_VALUE;
            var fNearestCamPair : CCameraAnchor = null;
            for each( var camPair : CCameraAnchor in m_vCameraAnchors )
            {
                fLengthSqr = CMath.lengthSqrVector2( x, y, camPair.m_theCenter.x, camPair.m_theCenter.y );
                if( fLengthSqr < fNearest )
                {
                    fNearest = fLengthSqr;
                    fNearestCamPair = camPair;
                }
            }

            return fNearestCamPair;
        }

        private function _calculateCameraBox( fTargetPosX : Number, fTargetPosY : Number ) : void
        {
            if( m_fZoomTime != 0.0 && m_theZoomBox != null && m_bZoomRelatively == false )
            {
                m_theCameraBox.set( m_theZoomBox );
                m_theOuterCameraBox.set( m_theZoomBox );
                return;
            }
            else if( m_vCameraAnchors.length == 0 )
            {
                m_theCameraBox.setCenterValue( fTargetPosX, fTargetPosY );
                m_theOuterCameraBox.setCenterValue( fTargetPosX, fTargetPosY );
                return;
            }

            // calculate and sort all the distances of the xy position and the camera pairs' position
            var i : int;
            for( i = 0; i < m_vCameraAnchors.length; i++ )
            {
                m_vCamAnchorVectors[ i ].m_iIdx = i;

                var camPair : CCameraAnchor = m_vCameraAnchors[ i ];
                m_vCamAnchorVectors[ i ].m_theVector.setValueXY( camPair.m_theCenter.x - fTargetPosX, camPair.m_theCenter.y - fTargetPosY );
                m_vCamAnchorVectors[ i ].m_fLengthSqr = m_vCamAnchorVectors[ i ].m_theVector.lengthSqr();
            }

            m_vCamAnchorVectors.sort( _compare );

            // pick up effective camera pairs
            // calculate each cam pair's weight, interpolate them to a new rectangle
            m_iNumEffectiveCamAnchors = 1;
            var iLastCamPairIdx : int = 0;
            var fWeight : Number = 0.0;
            var fCenterX : Number = m_vCameraAnchors[ m_vCamAnchorVectors[ iLastCamPairIdx ].m_iIdx ].m_theCenter.x;
            var fCenterY : Number = m_vCameraAnchors[ m_vCamAnchorVectors[ iLastCamPairIdx ].m_iIdx ].m_theCenter.y;
            var fExtX : Number = m_vCameraAnchors[ m_vCamAnchorVectors[ iLastCamPairIdx ].m_iIdx ].m_theExt.x;
            var fExtY : Number = m_vCameraAnchors[ m_vCamAnchorVectors[ iLastCamPairIdx ].m_iIdx ].m_theExt.y;
            var fOuterExtX : Number = m_vCameraAnchors[ m_vCamAnchorVectors[ iLastCamPairIdx ].m_iIdx ].m_theOuterExt.x;
            var fOuterExtY : Number = m_vCameraAnchors[ m_vCamAnchorVectors[ iLastCamPairIdx ].m_iIdx ].m_theOuterExt.y;

            var v1 : CVector2, v2 : CVector2;
            for( i = 0; i < m_vCamAnchorVectors.length; i++ )
            {
                for( var j : int = i + 1; j < m_vCamAnchorVectors.length; j++ )
                {
                    v1 = m_vCamAnchorVectors[ i ].m_theVector;
                    v2 = m_vCamAnchorVectors[ j ].m_theVector;

                    if( v1.angleDeg( v2 ) > 75.0 ) // angle is big enough to calculate the weight
                    {
                        m_vTempDis.set( m_vCameraAnchors[  m_vCamAnchorVectors[ j ].m_iIdx ].m_theCenter );
                        m_vTempDis.subOnValueXY( fCenterX, fCenterY );
                        var fTheta : Number = m_vTempDis.angleDeg( m_vCamAnchorVectors[ j ].m_theVector );
                        fWeight = CMath.cosDeg( fTheta ) * CMath.sqrt( m_vCamAnchorVectors[ j ].m_fLengthSqr ) / m_vTempDis.length();
                        if( fWeight > 1.0 ) fWeight = 1.0;
                        else if( fWeight < 0.0 ) fWeight = 0.0;

                        //var fCamPairLength : Number = CMath.sqrt( m_vCamAnchorVectors[ j ].m_fLengthSqr );
                        //var fTempLength : Number = vTemp.length();
                        //var fCosTheta : Number = CMath.cosDeg( fTheta );
                        //Foundation.Log.logMsg( "[" + m_vCamAnchorVectors[ j ].m_iIdx + " - "+ m_vCamAnchorVectors[ i ].m_iIdx + "] Length: " + fCamPairLength.toFixed( 2 ) + " / " + fTempLength.toFixed( 2 ) + ", fTheta: " + fTheta.toFixed( 2 ) +  ", fWeight: " + fWeight.toFixed( 2 ) );

                        // the nearer camPair carries the more weight
                        fCenterX = fCenterX * fWeight + m_vCameraAnchors[ m_vCamAnchorVectors[ j ].m_iIdx ].m_theCenter.x * ( 1.0 - fWeight );
                        fCenterY = fCenterY * fWeight + m_vCameraAnchors[ m_vCamAnchorVectors[ j ].m_iIdx ].m_theCenter.y * ( 1.0 - fWeight );
                        fExtX = fExtX * fWeight + m_vCameraAnchors[ m_vCamAnchorVectors[ j ].m_iIdx ].m_theExt.x * ( 1.0 - fWeight );
                        fExtY = fExtY * fWeight + m_vCameraAnchors[ m_vCamAnchorVectors[ j ].m_iIdx ].m_theExt.y * ( 1.0 - fWeight );
                        fOuterExtX = fOuterExtX * fWeight + m_vCameraAnchors[ m_vCamAnchorVectors[ j ].m_iIdx ].m_theOuterExt.x * ( 1.0 - fWeight );
                        fOuterExtY = fOuterExtY * fWeight + m_vCameraAnchors[ m_vCamAnchorVectors[ j ].m_iIdx ].m_theOuterExt.y * ( 1.0 - fWeight );

                        m_iNumEffectiveCamAnchors++;
                    }
                }
                break; // only interpolate camPairs that related to the nearest camPair, so break this loop
            }

            if( m_fZoomTime != 0.0 ) // zooming
            {
                if( m_theZoomBox != null && m_bZoomRelatively == true )
                {
                    var vZoomPos : CVector2 = m_theZoomBox.center;
                    var vZoomExt : CVector2 = m_theZoomBox.ext;
                    m_theCameraBox.setCenterExtValue( fCenterX + vZoomPos.x,  fCenterY + vZoomPos.y, vZoomExt.x, vZoomExt.y );
                    m_theOuterCameraBox.setCenterExtValue( fCenterX + vZoomPos.x,  fCenterY + vZoomPos.y, vZoomExt.x, vZoomExt.y );
                }
            }
            else
            {
                m_theOuterCameraBox.setCenterExtValue( fCenterX, fCenterY, fOuterExtX, fOuterExtY );

                // check additional condition
                if( m_theMovableBox != null )
                {
                    if( m_bCheckMovableBox ) m_theOuterCameraBox.encloseIntoAABB( m_theMovableBox );
                    else
                    {
                        // enable checking next time by checking whether the target is inside the m_theMovableBox
                        if( m_theMovableBox.isCollidedVertexValue( fTargetPosX, fTargetPosY ) ) m_bCheckMovableBox = true;
                    }
                }

                // set camera box according to outer camera box
                var vOuterCenter : CVector2 = m_theOuterCameraBox.center;
                var vOuterExt : CVector2 = m_theOuterCameraBox.ext;
                m_theCameraBox.setCenterExtValue( vOuterCenter.x, vOuterCenter.y, fExtX * ( vOuterExt.x / fOuterExtX ),  fExtY * ( vOuterExt.y / fOuterExtY ) );
            }
        }

        private function _compare( camPairV1 : _CCamAnchorVector, camPairV2 : _CCamAnchorVector ) : Number
        {
            return camPairV1.m_fLengthSqr - camPairV2.m_fLengthSqr;
        }

        private function _calculateSpringCameraBox( fDeltaTime : Number ) : void
        {
            var vTargetPos : CVector2 = m_theCameraBox.center;
            var vTargetExt : CVector2 = m_theCameraBox.ext;

            if( m_bDisableSmoothMovingOnce )
            {
                m_theSpringCameraBox.setCenterExt( vTargetPos, vTargetExt );
            }
            else
            {
                var vCurrentPos : CVector2 = m_theSpringCameraBox.center;
                m_vTempDis.set( vTargetPos );
                m_vTempDis.subOn( vCurrentPos );

                if( m_vTempDis.lengthSqr() > 1.0 )
                {
                    _calculateSpringAndResistance( m_vTempDis, fDeltaTime );
                    vCurrentPos.addOn( m_vTempDis );
                    m_bCameraMoved = true;
                }

                var vCurrentExt : CVector2 = m_theSpringCameraBox.ext;
                m_vTempDis.set( vTargetExt );
                m_vTempDis.subOn( vCurrentExt );
                if( m_vTempDis.lengthSqr() > 1.0 )
                {
                    _calculateSpringAndResistance( m_vTempDis, fDeltaTime );
                    vCurrentExt.addOn( m_vTempDis );
                    m_bCameraMoved = true;
                }

                m_theSpringCameraBox.setCenterExt( vCurrentPos, vCurrentExt );
            }
        }

        private function _calculateCurrentCameraBox( fDeltaTime : Number, fTargetPosX : Number, fTargetPosY : Number ) : void
        {
            var vSpringCamPos : CVector2 = m_theSpringCameraBox.center;
            var vSpringCamExt : CVector2 = m_theSpringCameraBox.ext;

            var vCamExt : CVector2 = m_theCameraBox.ext;
            var vOuterCamExt : CVector2 = m_theOuterCameraBox.ext;

            // calculate the offset of the target to the screen
            if( vSpringCamExt.x != 0.0 && vSpringCamExt.y != 0.0 )
            {
                var fXRatio : Number = ( fTargetPosX - vSpringCamPos.x ) / vSpringCamExt.x;
                if( fXRatio > 1.0 ) fXRatio = 1.0;
                var fYRatio : Number = ( fTargetPosY - vSpringCamPos.y ) / vSpringCamExt.y;
                if( fYRatio > 1.0 ) fYRatio = 1.0;

                m_vTempDis.setValueXY( fXRatio * ( vOuterCamExt.x - vCamExt.x ), fYRatio * ( vOuterCamExt.y - vCamExt.y ) );
            }
            else m_vTempDis.zero();

            if( m_bDisableSmoothMovingOnce )
            {
                m_vOuterCamOffset.set( m_vTempDis );
                m_bCameraMoved = true;
            }
            else
            {
                m_vTempDis.subOn( m_vOuterCamOffset );
                if( m_vTempDis.lengthSqr() > 1.0 )
                {
                    _calculateSpringAndResistance( m_vTempDis, fDeltaTime );
                    m_vOuterCamOffset.addOn( m_vTempDis );
                    m_bCameraMoved = true;
                }
            }

            m_theCurrentCameraBox.setCenterExtValue( vSpringCamPos.x + m_vOuterCamOffset.x, vSpringCamPos.y + m_vOuterCamOffset.y,
                                                     vSpringCamExt.x, vSpringCamExt.y );

            // force m_theCurrentCameraBox be fully contained in the m_theSceneMovableBox
            if( m_theSceneMovableBox != null ) m_theCurrentCameraBox.encloseIntoAABB( m_theSceneMovableBox );
        }

        private function _calculateSpringAndResistance( vDis : CVector2, fDeltaTime : Number ) : void
        {
            var fXDis : Number = vDis.x;
            var fYDis : Number = vDis.y;
            if( m_fZoomTime != 0.0 ) vDis.mulOnValue( fDeltaTime * m_fSpringFactorInZoom );
            else vDis.mulOnValue( fDeltaTime * m_fSpringFactor );
            if( CMath.abs( vDis.x ) > CMath.abs( fXDis ) ) vDis.x = fXDis;
            if( CMath.abs( vDis.y ) > CMath.abs( fYDis ) ) vDis.y = fYDis;

            m_vTempResistance.set( vDis );
            m_vTempResistance.mulOnValue( m_fCurrentResistance );
            vDis.subOn( m_vTempResistance );
        }

        private function _applyToFinalCameraBox( aabb : CAABBox2 ) : void
        {
            var bSetSize : Boolean = true;
            if( aabb.isVolumeZero() ) bSetSize = false;

            var vCenter : CVector2 = aabb.center;
            var vExt : CVector2 = aabb.ext;

            var fCenterX : Number = vCenter.x + m_vOffset.x + m_vShakeOffset.x + m_vZoomShakeCenterOffset.x;
            var fCenterY : Number = vCenter.y + m_vOffset.y + m_vShakeOffset.y + m_vZoomShakeCenterOffset.y;
            var fWidth : Number = ( vExt.x + m_vZoomShakeExtOffset.x ) * 2.0;
            var fHeight : Number = ( vExt.y + m_vZoomShakeExtOffset.x ) * 2.0;

            if( m_bKeepAspectRatio )
            {
                var fScale : Number = fHeight / m_theRenderer.stageHeight;
                fWidth = m_theRenderer.stageWidth * fScale;
            }

            m_theFinalCameraBox.setCenterExtValue( fCenterX, fCenterY, fWidth * 0.5, fHeight * 0.5 );

            var iNumCameras : int = m_vSceneLayerCameras.length;
            for( var i : int = 0; i < iNumCameras; ++i )
            {
                m_vSceneLayerCameras[ i ].setPosition( fCenterX, fCenterY );

                if( bSetSize ) m_vSceneLayerCameras[ i ].setOrthoSize( fWidth, fHeight );
                //if( bSetSize ) m_vSceneLayerCameras[ i ].setOrthoSize( fWidth * 4, fHeight * 4 );
                //if( bSetSize ) m_vSceneLayerCameras[ i ].setOrthoSize( fWidth * 2, fHeight * 2 );
            }
        }

        private function _pushCurrentZoomFactors() : void
        {
            var theLastZoom : _CZoomLayers = null;
            if( m_vZoomLayers.length > 0 ) theLastZoom = m_vZoomLayers[ m_vZoomLayers.length - 1 ];

            if( theLastZoom != null && theLastZoom.m_bZoomRelatively == m_bZoomRelatively && theLastZoom.m_theZoomBox.equals( m_theZoomBox ) )
            {
                theLastZoom.m_fZoomTime += m_fZoomTime;
            }
            else m_vZoomLayers.push( new _CZoomLayers( m_theZoomBox, m_fZoomTime, m_bZoomRelatively ) );
        }

        //
        //
        protected var m_vSceneLayerCameras : Vector.<CSceneLayerCamera> = new Vector.<CSceneLayerCamera>();
        protected var m_theFollowingTarget : CBaseObject = null;
        protected var m_theFollowingTarget2 : CBaseObject = null;
        protected var m_iFollowingMode : int = 0;

        protected var m_bEnabled : Boolean = true;

        // parameters for camera spring interpolation
        private static const DEFAULT_RESISTANCE : Number = 0.98;

        private var m_fSpringFactor : Number = 1.0;
        private var m_fCounterResistanceFactor : Number = 1.0;
        private var m_fCenterShiftFactor : Number = 0.8;
        private var m_fSpringFactorInZoom : Number = 1.0;
        private var m_fCounterResistanceFactorInZoom : Number = 1.0;
        private var m_fCurrentResistance : Number = DEFAULT_RESISTANCE;
        private var m_bKeepAspectRatio : Boolean = true;
        private var m_bCameraMoved : Boolean = true;
        private var m_bDisableSmoothMovingOnce : Boolean = false;

        private var m_theCameraBox : CAABBox2 = new CAABBox2( CVector2.ZERO );
        private var m_theOuterCameraBox : CAABBox2 = new CAABBox2( CVector2.ZERO );
        private var m_theSpringCameraBox : CAABBox2 = new CAABBox2( CVector2.ZERO );
        private var m_theCurrentCameraBox : CAABBox2 = new CAABBox2( CVector2.ZERO );
        private var m_theFinalCameraBox : CAABBox2 = new CAABBox2( CVector2.ZERO );
        private var m_vOuterCamOffset : CVector2 = new CVector2();
        private var m_vOffset : CVector2 = new CVector2();

        // indicate a box to constrain the camera's movable range
        private var m_theSceneMovableBox : CAABBox2 = null;
        private var m_theMovableBox : CAABBox2 = null;
        private var m_bLockMovableBoxImmediately : Boolean = true;
        private var m_bCheckMovableBox : Boolean = false;

        // indicate a box to zoom in or out the camera
        private var m_vZoomLayers : Vector.<_CZoomLayers> = new Vector.<_CZoomLayers>();
        private var m_theZoomBox : CAABBox2 = null;
        private var m_fZoomTime : Number = 0.0;
        private var m_bZoomRelatively : Boolean = false;

        // shaking parameters
        private var m_vShakeOffset : CVector2 = new CVector2();
        private var m_vShakeIntensity : CVector2 = new CVector2();
        private var m_fShakeTimeDuration : Number = 0.0;
        private var m_fShakeTime : Number = 0.0;
        private var m_fShakeDeltaTime : Number = 0.0;
        private var m_fShakeDeltaTimePeriod : Number = 0.02;
        private var m_iShakeRandomIndex : Number = 0;
        private static var s_vShakeRandomOffsets : Vector.< Number > = null;

        // shaking parameters
        private var m_vZoomShakeCenterOffset : CVector2 = new CVector2();
        private var m_vZoomShakeExtOffset : CVector2 = new CVector2();
        private var m_vZoomShakeIntensity : CVector2 = new CVector2();
        private var m_vZoomShakeDirection : CVector2 = new CVector2();
        private var m_fZoomShakeTimeDuration : Number = 0.0;
        private var m_fZoomShakeTime : Number = 0.0;
        private var m_fZoomShakeDeltaTime : Number = 0.0;
        private var m_fZoomShakeDeltaTimePeriod : Number = 0.02;
        private var m_iZoomShakeRandomIndex : Number = 0;

        //
        protected var m_vEnlargeCollisionCamBoxSize : CVector2 = null;
        protected var m_theEnlargedFinalCamBox : CAABBox2 = null;

        // camera anchor's information
        private var m_vCameraAnchors : Vector.< CCameraAnchor > = new Vector.< CCameraAnchor >();
        private var m_vCamAnchorVectors : Vector.< _CCamAnchorVector > = new Vector.< _CCamAnchorVector >();
        private var m_iNumEffectiveCamAnchors : int = 0;

        private var m_theRenderer : CRenderer = null;

        private var m_fnOnCameraEnabled : Function = null;
        private var m_fnOnCameraFollowingModeChanged : Function = null;
        private var m_fnOnCameraTargetChanged : Function = null;

        // just for reducing new operator calls in calculation
        private var m_vTempDis : CVector2 = new CVector2();
        private var m_vTempResistance : CVector2 = new CVector2();

    }
}


//
//
//
import QFLib.Math.CAABBox2;
import QFLib.Math.CVector2;

class _CCamAnchorVector
{
    public function _CCamAnchorVector( iIdx : int, v : CVector2 )
    {
        m_theVector = v;
        m_iIdx = iIdx;
        m_fLengthSqr = 0.0;
    }

    public var m_theVector : CVector2;
    public var m_fLengthSqr : Number;
    public var m_iIdx : int;
}

class _CZoomLayers
{
    public function _CZoomLayers( theZoomBox : CAABBox2, fZoomTime : Number, bZoomRelatively : Boolean )
    {
        m_theZoomBox.set( theZoomBox );
        m_fZoomTime = fZoomTime;
        m_bZoomRelatively = bZoomRelatively;
    }

    public var m_theZoomBox : CAABBox2 = new CAABBox2( CVector2.ZERO );
    public var m_fZoomTime : Number;
    public var m_bZoomRelatively : Boolean;
}