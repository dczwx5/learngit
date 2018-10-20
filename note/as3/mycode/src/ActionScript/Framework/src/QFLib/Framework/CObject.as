//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------
package QFLib.Framework
{

    import QFLib.Foundation;
    import QFLib.Foundation.CPath;
    import QFLib.Foundation.CTimer;
import QFLib.Graphics.FX.IFXModify;
    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.IPass;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.Scene.CLightData;
    import QFLib.Graphics.Sprite.CSprite;
    import QFLib.Interface.IRecyclable;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CMath;
    import QFLib.Math.CVector2;
    import QFLib.Math.CVector3;
    import QFLib.Math.CVector4;
    import QFLib.Node.CNode;
import QFLib.Node.EDirtyFlag;
import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.ELoadingPriority;

import flash.utils.getQualifiedClassName;

//
    //
    //
    public class CObject extends CNode implements IRecyclable, IFXModify
    {
        public static var sEnabledInnerUpdate : Boolean = true;

        private static var sPosition2DHelper : CVector2 = new CVector2 ();

        public function CObject( theBelongFramework : CFramework )
        {
            if (theBelongFramework) theBelongFramework._addObject( this );
            m_theBelongFramework = theBelongFramework;
        }

        public override function dispose() : void
        {
            if( m_bRecycled ) return ; // do not dispose recycled object
            //{
            //    Foundation.Log.logErrorMsg( "CObject: Do not dispose a 'Recycled' object!" );
            //    throw new Error( "CObject: Do not dispose a 'Recycled' object!" );
            //}

            if( m_spVisibleBound != null )
            {
                m_spVisibleBound.dispose();
                m_spVisibleBound = null;
            }

            if( m_theBelongFramework.currentCameraTarget == this )
            {
                m_theBelongFramework._setCurrentCameraTarget( null );
            }
            else if( m_theBelongFramework.currentCameraTarget2 == this )
            {
                m_theBelongFramework._setCurrentCameraTarget( m_theBelongFramework.currentCameraTarget, null );
            }

            m_theBelongFramework._removeObject( this );
            m_theBelongFramework = null;
            super.dispose();

            m_bDisposed = true;
        }

        [Inline]
        final public function get disposed() : Boolean
        {
            return m_bDisposed;
        }

        public virtual function recycle() : void
        {
            if( m_bDisposed )
            {
                Foundation.Log.logErrorMsg( "CObject: Do not recycle a 'Disposed' object!" );
                throw new Error( "CObject: Do not recycle a 'Disposed' object!" );
            }
            if( m_bRecycled )
            {
                Foundation.Log.logErrorMsg( "CObject: Do not recycle a 'Recycled' object!" );
                throw new Error( "CObject: Do not recycle a 'Recycled' object!" );
            }

            this.visible = false;
            m_bRecycled = true;
        }
        public virtual function revive() : void
        {
            if( m_bDisposed )
            {
                Foundation.Log.logErrorMsg( "CObject: Revive a 'Disposed' object!" );
                throw new Error( "CObject: Revive a 'Disposed' object!" );
            }

            this.visible = true;
            m_bRecycled = false;
        }

        public virtual function disposeRecyclable() : void
        {
            m_bRecycled = false;
            dispose();
        }

        [Inline]
        final public function get isRecycled() : Boolean
        {
            return m_bRecycled;
        }

        //
        [Inline]
        final public function get belongFramework() : CFramework
        {
            return m_theBelongFramework;
        }

        [Inline]
        final public function get parentObject() : CObject
        {
            return this.parent as CObject;
        }

        // try getting all used resources - implement by the derived classes
        public virtual function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            return 0;
        }

        [Inline]
        final public function get name() : String
        {
            return m_sName;
        }
        [Inline]
        final public function set name( sName : String ) : void
        {
            m_sName = sName;
        }

        [Inline]
        final public function get loadingPriority() : int
        {
            return m_iLoadingPriority;
        }

        public override function set flipX( bFlip : Boolean ) : void
        {
            if( super.flipX == bFlip ) return ;

            super.flipX = bFlip;
            //if( theObject != null ) theObject.flipX = bFlip; // do this in updateMatrix() of subclasses
        }
        public override function set flipY( bFlip : Boolean ) : void
        {
            if( super.flipY == bFlip ) return;

            super.flipY = bFlip;
            //if( theObject != null ) theObject.flipY = bFlip; // do this in updateMatrix() of subclasses
        }

        [Inline]
        final public function get depth2D() : Number
        {
            return m_fDepth2D;
        }

        [Inline]
        final public function set depth2D ( value : Number ) : void
        {
            m_fDepth2D = value;
        }

        [Inline]
        final public function get opaque() : Number
        {
            return m_fOpaque;
        }
        public virtual function set opaque( fOpaque : Number ) : void
        {
            if( fOpaque < 0.0 ) fOpaque = 0.0;
            m_fOpaque = fOpaque;
        }

        [Inline]
        final public function get innerOpaque() : Number
        {
            return m_fInnerOpaque;
        }
        public virtual function set innerOpaque( fInnerOpaque : Number ) : void
        {
            if( fInnerOpaque < 0.0 ) fInnerOpaque = 0.0;
            m_fInnerOpaque = fInnerOpaque;
        }

        [Inline]
        final public function get visible() : Boolean
        {
            return m_bVisible;
        }
        public virtual function set visible( bVisible : Boolean ) : void
        {
            if( m_bVisible == bVisible ) return ;
            m_bVisible = bVisible;
            if( bVisible ) update( 0.0 ); // update once just in case this function is called after the update
        }
        [Inline]
        final public function get enabled() : Boolean
        {
            return m_bEnabled;
        }
        public virtual function set enabled( bEnable : Boolean ) : void
        {
            if( m_bEnabled == bEnable ) return ;

            m_theBelongFramework._removeObject( this );
            m_bEnabled = bEnable;
            m_theBelongFramework._addObject( this );

            if( bEnable ) update( 0.0 ); // update once just in case this function is called after the update
        }
        [Inline]
        final public function get initiallyEnabled() : Boolean
        {
            return m_bInitiallyEnabled;
        }

        [Inline]
        final public function get isStatic() : Boolean // whether this object is belong to the static objects of a scene
        {
            return m_bStatic;
        }
        public virtual function set isStatic( bStatic : Boolean ) : void
        {
            m_bStatic = bStatic;
        }

        [Inline]
        final public function get color() : CVector3
        {
            return m_vColor;
        }

        //
        [Inline]
        final public function get castShadow() : Boolean
        {
            return m_bCastShadow;
        }
        public virtual function set castShadow( bCast : Boolean ) : void
        {
            m_bCastShadow = bCast;
        }

        [Inline]
        final public virtual function get currentBound() : CAABBox2
        {
            return theObject.currentBound;
        }
        [Inline]
        final public function get currentGlobalBound() : CAABBox2
        {
            return theObject.currentGlobalBound;
        }

        [Inline]
        final public function get isInViewRange() : Boolean
        {
            return m_bInViewRange;
        }

        [Inline]
        final public function get bIsCheckInViewRange() : Boolean
        {
            return m_bIsCheckInViewRange;
        }

        [Inline]
        final public function set bIsCheckInViewRange( value : Boolean ) : void
        {
            m_bIsCheckInViewRange = value;
        }

        [Inline]
        final public function enableViewingCheckAnimation( bEnable : Boolean ) : void
        {
            m_bEnableViewingCheckAnimation = bEnable;
        }

        [Inline]
        final public function get hasVisibleCurrentBound() : Boolean
        {
            return ( m_spVisibleBound != null ) ? true : false;
        }
        public virtual function setVisibleCurrentBound( bShow : Boolean, vColor : CVector4 = null ) : void
        {
            if( bShow )
            {
                if( m_spVisibleBound == null )
                {
                    m_spVisibleBound = new CSprite( m_theBelongFramework.spriteSystem, true );
                    if( vColor != null )
                    {
                        m_spVisibleBound.setColor( vColor.r, vColor.g, vColor.b );
                        m_spVisibleBound.opaque = vColor.a;
                    }
                    else
                    {
                        m_spVisibleBound.setColor( 1.0, 1.0, 1.0 );
                        m_spVisibleBound.opaque = 0.5;
                    }

                    this.theObject.addChild( m_spVisibleBound );
                    _setupVisibleBoundBox();
                }
            }
            else
            {
                if( m_spVisibleBound != null )
                {
                    this.theObject.removeChild( m_spVisibleBound );
                    m_spVisibleBound.dispose();
                    m_spVisibleBound = null;
                }
            }
        }

        //
        public function findBelongScene() : CScene
        {
            var theScene : CScene;

            var theObject : CObject = this;
            while( theObject != null )
            {
                theScene = theObject.parent as CScene;
                if( theScene != null ) return theScene;
                else theObject = theObject.parentObject;
            }

            return null;
        }

        public override function setScreenPosition ( x : Number, y : Number, depth : Number ) : void
        {
            if ( this.theObject != null )
            {
                var pCamera : ICamera = theObject.usingCamera;
                pCamera.screenToWorld( x, y, sPosition2DHelper );

                this.setPosition ( sPosition2DHelper.x, sPosition2DHelper.y, 0 );
                this.depth2D = depth;
            }
        }

        // movement function
        public virtual function moveTo( x : Number, y : Number, z : Number, bCollision : Boolean = false, bOnTerrain : Boolean = false,
                                           bCheckHeightState : Boolean = true, bEnableSliding : Boolean = true,
                                           iSlideFactor : int = 3, bSlideLineCheck : Boolean = true ) : Boolean
        {
            if( _moveTo( x, y, z, bCollision, bOnTerrain, bCheckHeightState ) ) return true;

            if( bEnableSliding == false ) return false;

            var vPosition : CVector3 = this.position;
            if( x != this.position.x && z != this.position.z )
            {
                if( _moveTo( x, y, vPosition.z, bCollision, bOnTerrain, bCheckHeightState ) ) return true;
                else
                {
                    if( _moveTo( vPosition.x, y, z, bCollision, bOnTerrain, bCheckHeightState ) ) return true;
                }
            }

            // get offset length
            var fMoveX : Number = x - vPosition.x;
            var fMoveY : Number = y - vPosition.y;
            var fMoveZ : Number = z - vPosition.z;
            return _slideMove( fMoveX, fMoveY, fMoveZ, bCollision, bOnTerrain, bCheckHeightState, iSlideFactor, bSlideLineCheck );
        }
        public virtual function move( x : Number, y : Number, z : Number, bCollision : Boolean = false, bOnTerrain : Boolean = false,
                                         bCheckHeightState : Boolean = true, bEnableSliding : Boolean = true,
                                         iSlideFactor : int = 3, bSlideLineCheck : Boolean = true ) : Boolean
        {
            var vPosition : CVector3 = this.position;

            // begin of debug
            //if( _moveTo( vPosition.x, vPosition.y, vPosition.z, true, false, false, false ) == false )
            //{
            //    Foundation.Log.logErrorMsg( "Shit! Shit! Shit! Shit! I'm in trouble!" );
            //}
            // end of debug

            if( _moveTo( vPosition.x + x, vPosition.y + y, vPosition.z + z, bCollision, bOnTerrain, bCheckHeightState ) ) return true;

            if( bEnableSliding == false ) return false;

            if( x != 0.0 && z != 0.0 ) // special case for this kind of XY collision grids
            {
                if( _moveTo( vPosition.x + x, vPosition.y + y, vPosition.z, bCollision, bOnTerrain, bCheckHeightState ) ) return true;
                else
                {
                    if( _moveTo( vPosition.x, vPosition.y + y, vPosition.z + z, bCollision, bOnTerrain, bCheckHeightState ) ) return true;
                }
            }

            return _slideMove( x, y, z, bCollision, bOnTerrain, bCheckHeightState, iSlideFactor, bSlideLineCheck );
        }

        final public function setPositionTo( x : Number, y : Number, z : Number, bCollision : Boolean = false, bOnTerrain : Boolean = false,
                                                bMoveToAvailablePosition : Boolean = false, bResetMovableBoxState : Boolean = true ) : Boolean
        {
            if( bMoveToAvailablePosition ) bCollision = false;

            if( _moveTo( x, y, z, bCollision, bOnTerrain, false, false, false ) == false ) return false;

            var vPos : CVector3 = this.position;
            x = vPos.x;
            y = vPos.y;
            z = vPos.z;

            if( bMoveToAvailablePosition )
            {
                if( _moveTo( x, y, z, true, bOnTerrain, false ) == false )
                {
                    var vNewPos : CVector3 = null;
                    var theScene : CScene = findBelongScene();
                    if( theScene == null )
                    {
                        for each( theScene in m_theBelongFramework.sceneSet )
                        {
                            vNewPos = theScene.findNearbyTerrainGridPosition3D( x, y, z );
                            break;
                        }
                    }
                    else
                    {
                        vNewPos = theScene.findNearbyTerrainGridPosition3D( x, y, z );
                    }

                    if( vNewPos != null )
                    {
                        return setPositionTo( vNewPos.x, vNewPos.y, vNewPos.z, false, false, false, false );
                    }
                }
            }

            m_vLastPosition.setValueXYZ( x, y, z );
            m_vVelocityPerSec.zero();
            if( bResetMovableBoxState ) m_iMovableBoxID = 0;
            return true;
        }
        public override function setPosition( fGlobalX : Number, fGlobalY : Number, fGlobalZ : Number ) : void
        {
            super.setPosition( fGlobalX, fGlobalY, fGlobalZ );
            m_fTerrainHeight = getTerrainHeight( fGlobalX, fGlobalZ, m_fStepHeight );
            if( ( fGlobalY - m_fTerrainHeight ) > CMath.BIG_EPSILON ) m_bInAir = true;
            else m_bInAir = false;
        }
        public function setPositionIgnoreHeight( fGlobalX : Number, fGlobalY : Number, fGlobalZ : Number ) : void
        {
            super.setPosition( fGlobalX, fGlobalY, fGlobalZ );
        }
        /*public virtual function moveToFrom2D( x : Number, y : Number, fHeightToGround : Number = 0.0, f2DDepth : Number = 0.0,
                                                 bCollision : Boolean = false, bOnTerrain : Boolean = false ) : Boolean
        {
            var vPos : CVector3 = get3DPositionFrom2D( this, x, y, fHeightToGround, m_vTempBuffer );
            m_fDepth2D = f2DDepth;
            return moveTo( vPos.x, vPos.y, vPos.z, bCollision, bOnTerrain );
        }*/
        public function setPositionToFrom2D( x : Number, y : Number, fHeightToGround : Number = 0.0, f2DDepth : Number = 0.0,
                                               bCollision : Boolean = false, bOnTerrain : Boolean = false,
                                               bMoveToAvailablePosition : Boolean = false, bResetMovableBoxState : Boolean = true ) : void
        {
            var vPos : CVector3 = get3DPositionFrom2D( this, x, y, fHeightToGround, m_vTempBuffer );
            m_fDepth2D = f2DDepth;
            setPositionTo( vPos.x, vPos.y, vPos.z, bCollision, bOnTerrain, bMoveToAvailablePosition, bResetMovableBoxState );
        }

        public function getTerrainHeight(  x : Number, z : Number, fStepHeight : Number = -1.0  ) : Number
        {
            if( m_theBelongFramework == null ) return -Number.MAX_VALUE;

            var fTheHighest : Number = -Number.MAX_VALUE;
            var fHeight : Number;
            for each( var scene : CScene in m_theBelongFramework.sceneSet )
            {
                if( scene.terrainData != null )
                {
                    fHeight = scene.terrainData.getTerrainHeight( x, z, fStepHeight );
                    if( fHeight > fTheHighest ) fTheHighest = fHeight;
                }
            }

            return fTheHighest;
        }

        public function getTerrainLight(  x : Number, z : Number ) : CLightData
        {
            if( m_theBelongFramework == null ) return null;

            var lightData : CLightData;
            for each( var scene : CScene in m_theBelongFramework.sceneSet )
            {
                if( scene.terrainData != null )
                {
                    lightData = scene.terrainData.getTerrainLightData( x, z );
                    break;
                }
            }

            return lightData;
        }

        // jump functions
        public function jump( fEstimatedHeight : Number, vExtraVelocity : CVector3 = null ) : void
        {
            m_fEstimatedJumpHeight =  fEstimatedHeight;
            if( vExtraVelocity == null ) m_vExtraJumpVelocity.zero();
            else m_vExtraJumpVelocity.setValueXYZ( vExtraVelocity.x, vExtraVelocity.y, vExtraVelocity.z );
        }
        [Inline]
        final public function jumpWithExtraVelocityXYZ( fEstimatedHeight : Number, fExtraVelocityPerSecX : Number, fExtraVelocityPerSecY : Number, fExtraVelocityPerSecZ : Number ) : void
        {
            m_fEstimatedJumpHeight =  fEstimatedHeight;
            m_vExtraJumpVelocity.setValueXYZ( fExtraVelocityPerSecX, fExtraVelocityPerSecY, fExtraVelocityPerSecZ );
        }

        // speed / state
        [Inline]
        final public function get terrainHeight() : Number
        {
            return m_fTerrainHeight;
        }
        [Inline]
        final public function get stepHeight() : Number
        {
            return m_fStepHeight;
        }
        [Inline]
        final public function set stepHeight( fStepHeight : Number ) : void
        {
            m_fStepHeight = fStepHeight;
        }
        [Inline]
        final public function get velocity() : CVector3
        {
            return m_vVelocityPerSec;
        }
        [Inline]
        final public function get inAir() : Boolean
        {
            return m_bInAir;
        }
        [Inline]
        final public function get enablePhysics() : Boolean
        {
            return m_bEnablePhysics;
        }
        public function set enablePhysics( bEnable : Boolean ) : void
        {
            m_bEnablePhysics = bEnable;
            if( bEnable )
            {
                var vCurrentPosition : CVector3 = this.position;
                var fHeight : Number = getTerrainHeight( vCurrentPosition.x, vCurrentPosition.z, m_fStepHeight );
                if( ( vCurrentPosition.y - fHeight ) > CMath.BIG_EPSILON )
                    m_bInAir = true;
            }
        }
        [Inline]
        final public function get isShaking() : Boolean
        {
            return m_fShakeTime > 0.0;
        }

        [Inline]
        final public function setUpdateSpeed( fUpdateSpeed : Number, fShakeSpeed : Number = -1.0 ) : void
        {
            m_fUpdateSpeed = fUpdateSpeed;
            if( fShakeSpeed < 0.0 ) m_fShakeSpeed = m_fUpdateSpeed;
            else m_fShakeSpeed = fShakeSpeed;
        }

        [Inline]
        final public function get updateSpeed() : Number
        {
            return m_fUpdateSpeed;
        }
        [Inline]
        final public function set updateSpeed( fSpeed : Number ) : void
        {
            m_fUpdateSpeed = fSpeed;
        }
        [Inline]
        final public function get shakeSpeed() : Number
        {
            return m_fShakeSpeed;
        }
        [Inline]
        final public function set shakeSpeed( fSpeed : Number ) : void
        {
            m_fShakeSpeed = fSpeed;
        }

        // shake functions
        [Inline]
        final public function shake( fIntensity : Number, fTimeDuration : Number, fShakeDeltaTimePeriod : Number = 0.02 ) : void
        {
            shakeXY( fIntensity, fIntensity, fTimeDuration, fShakeDeltaTimePeriod );
        }
        public function shakeXY( fIntensityX : Number, fIntensityY : Number, fTimeDuration : Number, fShakeDeltaTimePeriod : Number = 0.02 ) : void
        {
            m_fShakeTimeDuration = m_fShakeTime = fTimeDuration;

            var fScreenRatioX : Number = m_theBelongFramework.renderer.stageWidth / 1500.0;
            var fScreenRatioY : Number = m_theBelongFramework.renderer.stageHeight / ( 1500.0 / m_theBelongFramework.renderer.stageScreenRatio );
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

        //
        public virtual function get theObject() : CBaseObject
        {
            return null;
        }

        /**
         *
         * @param fDeltaTime
         */
        public virtual function update( fDeltaTime : Number ) : void
        {
            var fUpdateDeltaTime : Number = fDeltaTime * m_fUpdateSpeed;
            _update( fUpdateDeltaTime );
            var fShakeUpdateDeltaTime : Number = fDeltaTime * m_fShakeSpeed;
            _shakeUpdate( fShakeUpdateDeltaTime );

            m_bInViewRange = m_bIsCheckInViewRange ? _viewRangeChecking() : true;

            if( m_spVisibleBound != null ) _setupVisibleBoundBox();
        }

        public virtual function updateMatrix( bCheckDirty : Boolean = true ) : void
        {
            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_UPDATED ) || bCheckDirty == false )
            {
                _trackCurrentMovableBox();
            }
        }

        [Inline]
        final public function get2DPosition() : CVector3 { return get2DPositionFrom3D( position.x, position.y, position.z, m_v2DPosition ); }

        [Inline]
        public static function get TAN_THETA_OF_CAMERA() : Number
        {
            return CBaseObject.TAN_THETA_OF_CAMERA; // around 22 degrees of camera angle to the ground
        }

        /**
         *
         * @param objRef
         * @param x
         * @param y
         * @param fHeightToGround
         * @param v3DPosition
         * @return
         */
        public static function get3DPositionFrom2D( objRef : CObject, x : Number, y : Number, fHeightToGround : Number = 0.0, v3DPosition : CVector3 = null ) : CVector3
        {
            var z : Number = ( y + fHeightToGround ) / TAN_THETA_OF_CAMERA; // to convert 2D position to 3D screen space

            var fHeight : Number = objRef.getTerrainHeight( x, z ) + fHeightToGround;
            z = ( y + fHeight ) / TAN_THETA_OF_CAMERA;

            y = fHeight;
            //y = objRef.getTerrainHeight( x, z ) + fHeightToGround;
            if( v3DPosition == null ) v3DPosition = new CVector3( x, y, z );
            else v3DPosition.setValueXYZ( x, y, z );

            return v3DPosition
        }
        public static function get2DPositionFrom3D( x : Number, y : Number, z : Number, v2DPosition : CVector3 = null ) : CVector3
        {
            z *= TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space

            if( v2DPosition == null ) v2DPosition = new CVector3( x, -y + z, z );
            else v2DPosition.setValueXYZ( x, -y + z, z );

            return v2DPosition;
        }

        /**
         * Implement IFXModify Interface: set tint color
         * @param r
         * @param g
         * @param b
         * @param alpha
         * @param masking
         */
        public virtual function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            m_vColor.r = r;
            m_vColor.g = g;
            m_vColor.b = b;
            m_fOpaque = alpha;
        }

        /**
         * reset tint color
         */
        public function resetColor () : void { theObject.resetColor (); }

        /**
         * implement IFXModify interface
         */
        public function get renderableObject():DisplayObject
        {
            return theObject.renderableObject;
        }

        [Inline] public function get material () : IMaterial { return null; }

        /**
         * implement IFXModify interface
         */
        public function _notifyAttached ( object : Object ) : void { return; }

        /**
         * implement IFXModify interface
         */
        public function _notifyDetached ( object : Object ) : void { return; }

        /**
         *
         * @param fDeltaTime
         */
        protected virtual function _update( fDeltaTime : Number ) : void
        {
            if( m_bStatic || sEnabledInnerUpdate == false ) return ;

            if( !isNaN(m_fEstimatedJumpHeight) )
            {
                if( m_bEnablePhysics )
                {
                    _jumpWithExtraVelocity( m_fEstimatedJumpHeight, m_vExtraJumpVelocity );
                }
                m_fEstimatedJumpHeight = NaN;
                m_vExtraJumpVelocity.zero();
            }

            var vCurrentPosition : CVector3 = this.position;
            if( vCurrentPosition.equals( m_vLastPosition ) == false )
            {
                m_fTerrainHeight = getTerrainHeight( vCurrentPosition.x, vCurrentPosition.z, m_fStepHeight );
            }

            if( m_bInAir && m_bEnablePhysics )
            {
                if( fDeltaTime != 0.0 ) {
                    m_vAirMovement.set( m_vGravityAcceleration );
                    m_vAirMovement.mulOnValue( fDeltaTime * fDeltaTime * 0.5 );
                    m_vAirMovement.addOnValueXYZ( m_vVelocityPerSec.x * fDeltaTime, m_vVelocityPerSec.y * fDeltaTime, m_vVelocityPerSec.z * fDeltaTime );

                    m_vVelocityPerSec.addOnValueXYZ( m_vGravityAcceleration.x * fDeltaTime, m_vGravityAcceleration.y * fDeltaTime, m_vGravityAcceleration.z * fDeltaTime );

                    var bDown : Boolean = m_vAirMovement.y < 0.0;
                    if ( bDown ) {
                        if ( vCurrentPosition.y + m_vAirMovement.y <= m_fTerrainHeight ) {
                            m_vAirMovement.y = m_fTerrainHeight - vCurrentPosition.y;
                        }
                        if ( move( m_vAirMovement.x, m_vAirMovement.y, m_vAirMovement.z, true, !m_bInAir ) == false ) {
                            m_vAirMovement.x = 0.0;
                            m_vAirMovement.z = 0.0;
                            move( m_vAirMovement.x, m_vAirMovement.y, m_vAirMovement.z, true, !m_bInAir );
                        }
                    }
                    else {
                        if ( move( m_vAirMovement.x, m_vAirMovement.y, m_vAirMovement.z, true, false ) == false ) {
                            m_vAirMovement.x = 0.0;
                            m_vAirMovement.z = 0.0;
                            move( m_vAirMovement.x, m_vAirMovement.y, m_vAirMovement.z, true, false );
                        }
                    }

                    // error check
                    if( m_vAirMovement.y < -10000.0 )
                    {
                        var sFilename : String = _getObjectFilename();
                        Foundation.Log.logWarningMsg( "..hell man... why do you have an object that keeps falling down...? object name: " + sFilename + "(" + getQualifiedClassName( this ) + ")" );

                        this.enablePhysics = false;
                    }
                }
            }
            else
            {
                if( m_bEnablePhysics && ( vCurrentPosition.y - m_fTerrainHeight ) > CMath.BIG_EPSILON )
                    m_bInAir = true;

                if( fDeltaTime != 0.0 )
                {
                    m_vVelocityPerSec.set( vCurrentPosition );
                    m_vVelocityPerSec.subOn( m_vLastPosition );
                    m_vVelocityPerSec.divOnValue( fDeltaTime );
                    //if( this.name == "hero" ) Foundation.Log.logErrorMsg( "name: " + this.name + " fDeltaTime: " + fDeltaTime + " m_vVelocityPerSec: " + m_vVelocityPerSec.toFixed( 3 ) );
                }
                else
                    m_vVelocityPerSec.zero();
            }

            //
            // begin of debug
            //
            var vDebugCurrentPosition : CVector3 = this.position;
            if( ( vDebugCurrentPosition.y - m_fTerrainHeight ) > CMath.BIG_EPSILON )
            {
                if( vDebugCurrentPosition.equals( m_vLastPosition ) ) // no movement
                {
                    if( m_bEnablePhysics && m_bEnabled && m_bVisible && this is CCharacter )
                    {
                        if( this.theObject != null && CMath.isZero( vDebugCurrentPosition.x ) == false && CMath.isZero( vDebugCurrentPosition.z ) == false )
                        {
                            if( m_theDebugTimer.seconds() > 2.0 )
                            {
                                var vMoveToPosition : CVector3 = new CVector3( vDebugCurrentPosition.x, vDebugCurrentPosition.y, vDebugCurrentPosition.z );
                                vMoveToPosition.addOn( m_vAirMovement );

                                var sFilename : String = (this as CCharacter).filename;
                                if( sFilename == null ) sFilename = "";
                                else sFilename = CPath.nameExt( sFilename );
                                Foundation.Log.logWarningMsg( sFilename + ", m_bInAir: " + m_bInAir + ", fDeltaTime: " + fDeltaTime + ", fUpdateSpeed: " + m_fUpdateSpeed + ", #scenes= " + m_theBelongFramework.sceneSet.count );
                                Foundation.Log.logWarningMsg( "Position: " + vDebugCurrentPosition + ", vMoveToPosition: " + vMoveToPosition + ", fTerrainHeight: " + m_fTerrainHeight );
                                for each( var scene : CScene in m_theBelongFramework.sceneSet )
                                {
                                    if( scene.collisionData != null )
                                    {
                                        var bInMovableBox : Boolean = scene.collisionData.isInMovableBox( vDebugCurrentPosition.x, vDebugCurrentPosition.y, vDebugCurrentPosition.z );
                                        var bMoveToInMovableBox : Boolean = scene.collisionData.isInMovableBox( vMoveToPosition.x, vMoveToPosition.y, vMoveToPosition.z );
                                        var bTerrainInMovableBox : Boolean = scene.collisionData.isInMovableBox( vDebugCurrentPosition.x, m_fTerrainHeight, vDebugCurrentPosition.z );
                                        var sMovableBoxInfo : String = scene.collisionData.movableBox ? scene.collisionData.movableBox.toString() : "";
                                        Foundation.Log.logWarningMsg( "scene: " + scene.name + ", bInMovableBox: " + bInMovableBox + ", bMoveToInMovableBox: " + bTerrainInMovableBox +
                                                                    ", bTerrainInMovableBox: " + bMoveToInMovableBox + ", movableBox: " + sMovableBoxInfo );
                                    }
                                    if( scene.terrainData != null )
                                    {
                                        var bLineCollided : Boolean = false;
                                        if( scene.isLineBlocked(  vDebugCurrentPosition.x, m_fTerrainHeight, vDebugCurrentPosition.z ,vMoveToPosition.x, m_fTerrainHeight, vMoveToPosition.z ) ) bLineCollided = true;
                                        Foundation.Log.logWarningMsg( "scene: " + scene.name + ", bLineCollided: " + bLineCollided + ", #2D Boxes: " + scene.terrainData.numDynamic2DBoxes + ", #3D Boxes: " + scene.terrainData.numDynamic3DBoxes );
                                    }
                                }

                                // B Plan: if an object is stuck in the air, try move it to an available position
                                setPositionTo( vMoveToPosition.x, vMoveToPosition.y, vMoveToPosition.z, true, false, true, false );
                                m_theDebugTimer.reset();
                            }
                        }
                        else m_theDebugTimer.reset();
                    }
                    else m_theDebugTimer.reset();
                }
                else m_theDebugTimer.reset();
            }
            else m_theDebugTimer.reset();
            //
            // end of debug
            //

            m_vLastPosition.set( vCurrentPosition );
        }

        protected function _shakeUpdate( fDeltaTime : Number ) : void
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
                        m_fShakeTime = 0.0;
                        m_vShakeOffset.setValueXY( 0.0, 0.0 );
                    }
                }
            }
        }

        private function _jumpWithExtraVelocity( fEstimatedHeight : Number, vExtraVelocity : CVector3 ) : void
        {
            m_vVelocityPerSec.addOn( vExtraVelocity );

            var UpVelocity : Number = CMath.sqrt( 2.0 * -GRAVITY_ACC * fEstimatedHeight );
            if( m_bInAir )
            {
                m_vVelocityPerSec.y += UpVelocity * 0.6;
            }
            else
            {
                m_vVelocityPerSec.y += UpVelocity;
                m_bInAir = true;
            }
        }

        private function _slideMove( x : Number, y : Number, z : Number, bCollision : Boolean, bOnTerrain : Boolean,
                                       bCheckHeight : Boolean, iSlideFactor : int, bLineCheck : Boolean ) : Boolean
        {
            // begin of debug
            //if( _moveTo( vPosition.x, vPosition.y, vPosition.z, true, false, false, false ) == false )
            //{
            //    Foundation.Log.logErrorMsg( "Shit! Shit! Shit! I'm in trouble!" );
            //}
            // end of debug

            // get offset length
            m_vTempBuffer.setValueXYZ( x, y, z );
            var fLen : Number = m_vTempBuffer.length();

            // get suggested sliding unit vector - use m_vTempBuffer as the buffer
            m_vTempBuffer.normalize( fLen );
            m_vTempBuffer.crossProduct( CVector3.Y_AXIS, m_vTempBuffer );
            if( m_vTempBuffer.isNearZero() ) return false;

            var fMaxGridSize : Number = _findMaxTerrainGridSize();
            var fLenLeft : Number = fLen;

            // try shifting the object to the edge of the available point
            var vPosition : CVector3;
            var fShiftLen : Number = fMaxGridSize * 0.2;
            var fShiftX : Number = x / fLen * fShiftLen;
            var fShiftY : Number = y / fLen * fShiftLen;
            var fShiftZ : Number = z / fLen * fShiftLen;
            var fShiftDis : Number = 0.0;
            while( fShiftDis <= fLen )
            {
                vPosition = this.position;
                if( _moveTo( vPosition.x + fShiftX, vPosition.y + fShiftY, vPosition.z + fShiftZ, bCollision, bOnTerrain, bCheckHeight ) ) fShiftDis += fShiftLen;
                else break;
            }
            fLenLeft -= fShiftDis;
            if( CMath.isZero( fLenLeft ) ) return true;

            // prepare data for  2 ways suggestion direction testing
            var fSuggestOffsetLen : Number;
            var fSuggestOffsetX : Number;
            var fSuggestOffsetY : Number;
            var fSuggestOffsetZ : Number;

            vPosition = this.position;
            var fOrgX : Number = vPosition.x;
            var fOrgY : Number = vPosition.y;
            var fOrgZ : Number = vPosition.z;
            var fTestOffsetX : Number = x / fLen * fMaxGridSize;
            var fTestOffsetY : Number = y / fLen * fMaxGridSize;
            var fTestOffsetZ : Number = z / fLen * fMaxGridSize;

            // begin of debug
            //if( _moveTo( fOrgX, fOrgY, fOrgZ, true, false, false, false ) == false )
            //{
            //    Foundation.Log.logErrorMsg( "Shit! I'm in trouble! Position move failed: " + fOrgX + ", " + fOrgY + ", " + fOrgZ + " != " + this.position.x + ", " + this.position.y + ", " + this.position.z );
            //}
            // end of debug

            // begin of debug
            //if( fOrgX != this.position.x || fOrgY != this.position.y || fOrgZ != this.position.z )
            //{
            //    Foundation.Log.logErrorMsg( "I'm in trouble! Position not the same: " + fOrgX + ", " + fOrgY + ", " + fOrgZ + " != " + this.position.x + ", " + this.position.y + ", " + this.position.z );
            //}
            // end of debug

            var i : int = 1;
            var iSlideFactorStep : int = ( ( iSlideFactor - 1 ) / 3 ) + 1;
            while( i <= iSlideFactor )
            {
                for( var j : int = -1; j <= 1; j += 2 )
                {
                    // apply a length to the suggested sliding vector
                    fSuggestOffsetLen = fMaxGridSize * i * j;
                    fSuggestOffsetX = m_vTempBuffer.x * fSuggestOffsetLen;
                    fSuggestOffsetY = m_vTempBuffer.y * fSuggestOffsetLen;
                    fSuggestOffsetZ = m_vTempBuffer.z * fSuggestOffsetLen;

                    if( _moveTo( fOrgX + fSuggestOffsetX, fOrgY + fSuggestOffsetY, fOrgZ + fSuggestOffsetZ, bCollision, bOnTerrain, bCheckHeight, bLineCheck ) )
                    {
                        vPosition = this.position;
                        if( _moveTo( vPosition.x + fTestOffsetX, vPosition.y + fTestOffsetY, vPosition.z + fTestOffsetZ, bCollision, bOnTerrain, bCheckHeight, bLineCheck ) )
                        {
                            // begin of debug
                            //if( _moveTo( fOrgX, fOrgY, fOrgZ, true, false, false, false ) == false )
                            //{
                            //    Foundation.Log.logErrorMsg( "I'm in trouble! Position: " + fOrgX + ", " + fOrgY + ", " + fOrgZ + " != " + this.position.x + ", " + this.position.y + ", " + this.position.z );
                            //}
                            // end of debug

                            _moveTo( fOrgX, fOrgY, fOrgZ, false, false, false, false );

                            fSuggestOffsetLen = fLenLeft * j;
                            fSuggestOffsetX = m_vTempBuffer.x * fSuggestOffsetLen;
                            fSuggestOffsetY = m_vTempBuffer.y * fSuggestOffsetLen;
                            fSuggestOffsetZ = m_vTempBuffer.z * fSuggestOffsetLen;
                            return _moveTo( fOrgX + fSuggestOffsetX, fOrgY + fSuggestOffsetY, fOrgZ + fSuggestOffsetZ, bCollision, bOnTerrain, bCheckHeight, bLineCheck )
                        }
                        else
                        {
                            // begin of debug
                            //if( _moveTo( fOrgX, fOrgY, fOrgZ, true, false, false, false ) == false )
                            //{
                            //    Foundation.Log.logErrorMsg( "I'm in trouble! Position: " + fOrgX + ", " + fOrgY + ", " + fOrgZ + " != " + this.position.x + ", " + this.position.y + ", " + this.position.z );
                            //}
                            // end of debug

                            _moveTo( fOrgX, fOrgY, fOrgZ, false, false, false, false );
                        }
                    }
                }

                if( i == iSlideFactor ) break;
                i += iSlideFactorStep;
                if( i > iSlideFactor ) i = iSlideFactor;
            }

            return false;
        }

        //
        protected virtual function _moveTo( x : Number, y : Number, z : Number, bCollision : Boolean, bOnTerrain : Boolean,
                                                bCheckHeightState : Boolean, bLineCheck : Boolean = true, bForceCheckCollision : Boolean = true ) : Boolean
        {
            if( m_theBelongFramework == null ) return false;

            var vPos : CVector3 = this.position;
            var fOrgPosX : Number = vPos.x;
            var fOrgPosY : Number = vPos.y;
            var fOrgPosZ : Number = vPos.z;

            //
            // begin of debug
            //
            var bAlreadyCollision : Boolean = false;
            if( bCollision )
            {
                if( vPos.isZero() == false )
                {
                    for each( var scene : CScene in m_theBelongFramework.sceneSet )
                    {
                        if( scene.isBlocked( fOrgPosX, fOrgPosY, fOrgPosZ, true, m_iMovableBoxID ) )
                        {
                            bAlreadyCollision = true;
                        }
                    }
                }
            }
            //
            // end of debug
            //

            if( bCheckHeightState )
            {
                if( m_bInAir ) bOnTerrain = false;
            }

            if( bOnTerrain )
            {
                var fTerrainHeight : Number = getTerrainHeight( x, z, m_fStepHeight );
                if( fTerrainHeight == -Number.MAX_VALUE ) return false;

                if( m_fStepHeight >= 0.0 )
                {
                    var fDiffTerrainHeight : Number = fOrgPosY - fTerrainHeight;
                    if( fDiffTerrainHeight > 0.0 )
                    {
                        if( fDiffTerrainHeight > m_fStepHeight ) bOnTerrain = false;
                    }
                }

                y = fTerrainHeight;
            }

            // set to new position, and get its new position to do collision check
            var vOrgLocalPos : CVector3 = this.localPosition;
            var fOrgLocalPosX : Number = vOrgLocalPos.x;
            var fOrgLocalPosY : Number = vOrgLocalPos.y;
            var fOrgLocalPosZ : Number = vOrgLocalPos.z;
            var fOrgTerrainHeight : Number = m_fTerrainHeight;
            var bOrgInAir : Boolean = m_bInAir;
            setPosition( x, y, z ); // m_bInAir & m_fTerrainHeight will be updated in setPosition()
            vPos = this.position;
            x = vPos.x;
            y = vPos.y;
            z = vPos.z;

            //
            // begin of debug
            //
            //if( m_bStatic == false && this is CCharacter ) {
            //    var sFilename : String = (this as CCharacter).filename;
            //    if ( sFilename == null ) sFilename = "";
            //    if( sFilename.indexOf( "z_caotijing_dz_0001" ) >= 0 )
            //        sFilename = sFilename;
            //}
            //
            // end of debug
            //

            var bOK : Boolean = true;
            if( bCollision )
            {
                for each( var scene : CScene in m_theBelongFramework.sceneSet )
                {
                    //if( y > -10 )
                    //    y = y;

                    if( bLineCheck )
                    {
                        if( bOnTerrain )
                        {
                            if( scene.isLineBlocked( fOrgPosX, fOrgPosY, fOrgPosZ, x, m_fTerrainHeight, z, true, m_iMovableBoxID ) )
                            {
                                bOK = false;
                                break;
                            }
                        }
                        else
                        {
                            // use fHeight as the y of the object when bOnTerrain flag is off to avoid the collision issue
                            // due to the collision data is actually 2D's terrain data(considering the object is in air, object should not be collided with terrain's collision grids)
                            if( scene.isLineBlocked( fOrgPosX, m_fTerrainHeight, fOrgPosZ, x, m_fTerrainHeight, z, true, m_iMovableBoxID ) )
                            {
                                bOK = false;
                                break;
                            }
                        }
                    }
                    else
                    {
                        if( scene.isBlocked( x, m_fTerrainHeight, z, true, m_iMovableBoxID ) )
                        {
                            bOK = false;
                            break;
                        }
                    }
                }
            }
            //
            // begin of debug
            //
            else if( bForceCheckCollision )
            {
                if( m_bStatic == false && this is CCharacter )
                {
                    var sFilename : String = (this as CCharacter).filename;
                    if( sFilename == null ) sFilename = "";

                    if( sFilename.indexOf( "missile" ) < 0 && sFilename.indexOf( "monster" ) < 0 )
                    {
                        var bCollided : Boolean = false;
                        for each( var scene : CScene in m_theBelongFramework.sceneSet )
                        {
                            if( bLineCheck )
                            {
                                if( bOnTerrain )
                                {
                                    if( scene.isLineBlocked( fOrgPosX, fOrgPosY, fOrgPosZ, x, m_fTerrainHeight, z, true, m_iMovableBoxID ) )
                                    {
                                        bCollided = true;
                                        break;
                                    }
                                }
                                else
                                {
                                    // use fHeight as the y of the object when bOnTerrain flag is off to avoid the collision issue
                                    // due to the collision data is actually 2D's terrain data(considering the object is in air, object should not be collided with terrain's collision grids)
                                    if( scene.isLineBlocked( fOrgPosX, m_fTerrainHeight, fOrgPosZ, x, m_fTerrainHeight, z, true, m_iMovableBoxID ) )
                                    {
                                        bCollided = true;
                                        break;
                                    }
                                }
                            }
                            else
                            {
                                if( scene.isBlocked( x, m_fTerrainHeight, z, true, m_iMovableBoxID ) )
                                {
                                    bCollided = true;
                                    break;
                                }
                            }
                        }
                        if( bCollided == true )
                        {
                            if( m_bInAir ) Foundation.Log.logMsg( "object: '" + sFilename + "' move into an air - blocking point: " + x + ", " + y + ", " + z );
                            else Foundation.Log.logMsg( "object: '" + sFilename + "' move into a blocking point: " + x + ", " + y + ", " + z );

                            var theStackTrace : Error = new Error();
                            Foundation.Log.logMsg( "stack trace: " + theStackTrace.getStackTrace() );

                            for each( var scene : CScene in m_theBelongFramework.sceneSet )
                            {
                                if( scene.collisionData != null )
                                {
                                    var bInMovableBox : Boolean = scene.collisionData.isInMovableBox( x, y, z );
                                    var bTerrainInMovableBox : Boolean = scene.collisionData.isInMovableBox( x, m_fTerrainHeight, z );
                                    var sMovableBoxInfo : String = scene.collisionData.movableBox ? scene.collisionData.movableBox.toString() : "";
                                    Foundation.Log.logMsg( "scene: " + scene.name + ", bInMovableBox: " + bInMovableBox + ", bMoveToInMovableBox: " + bTerrainInMovableBox +
                                                           ", movableBox: " + sMovableBoxInfo );
                                }
                                if( scene.terrainData != null )
                                {
                                    Foundation.Log.logMsg( "scene: " + scene.name + ", #2D Boxes: " + scene.terrainData.numDynamic2DBoxes + ", #3D Boxes: " + scene.terrainData.numDynamic3DBoxes );
                                }
                            }
                        }
                    }
                }
            }
            //
            // end of debug
            //

            if( bOK == false )
            {
                setLocalPosition( fOrgLocalPosX, fOrgLocalPosY, fOrgLocalPosZ );
                m_fTerrainHeight = fOrgTerrainHeight;
                m_bInAir = bOrgInAir;

                //
                // begin of debug
                //
                vPos = this.position;
                if( bAlreadyCollision == false && vPos.isZero() == false && this is CCharacter )
                {
                    for each( var scene : CScene in m_theBelongFramework.sceneSet )
                    {
                        if( scene.isBlocked( vPos.x, vPos.y, vPos.z, true, m_iMovableBoxID ) )
                        {
                            Foundation.Log.logTraceMsg( "internal _moveTo error: rollback into a blocking point: " +  vPos.x + ", " + vPos.y + ", " + vPos.z + ", " + _getObjectFilename() );
                        }
                    }
                }
                //
                // end of debug
                //

                return false;
            }
            else
            {
                //
                // begin of debug
                //
                if( bCollision )
                {
                    vPos = this.position;
                    if( vPos.isZero() == false && this is CCharacter )
                    {
                        for each( var scene : CScene in m_theBelongFramework.sceneSet )
                        {
                            if( scene.isBlocked( vPos.x, m_fTerrainHeight, vPos.z, true, m_iMovableBoxID ) )
                            {
                                Foundation.Log.logWarningMsg( "internal _moveTo error: move into a blocking point: " +  vPos.x + ", " + vPos.y + ", " + vPos.z + ", " + _getObjectFilename() );
                            }
                        }
                    }
                }
                //
                // end of debug
                //

                return true;
            }
        }

        protected function _trackCurrentMovableBox() : void
        {
            for each( var scene : CScene in m_theBelongFramework.sceneSet )
            {
                if( scene.collisionData.movableBoxID != 0 )
                {
                    if ( m_iMovableBoxID != scene.collisionData.movableBoxID )
                    {
                        var vCurPos : CVector3 = this.position;

                        // check until object's m_iMovableBoxID == scene.collisionData.movableBoxID --> the time entering the movable box
                        if ( scene.collisionData.isInMovableBox( vCurPos.x, vCurPos.y, vCurPos.z ) )
                        {
                            m_iMovableBoxID = scene.collisionData.movableBoxID;
                            break;
                        }
                    }
                }
            }
        }

        protected function _viewRangeChecking() : Boolean
        {
            if( m_theBelongFramework.currentCameraScene != null )
            {
                return m_theBelongFramework.currentCameraScene.mainCamera.isCollidedWithObject( this.theObject );
            }
            return false;
        }

        [Inline]
        final internal function _setInitiallyEnabled( bVisible : Boolean ) : void
        {
            m_bInitiallyEnabled = bVisible;
        }

        protected function _setupVisibleBoundBox() : void
        {
            var theCurrentVisibleBound : CAABBox2 = this.currentBound;
            if( theCurrentVisibleBound != null )
            {
                var fX : Number = theCurrentVisibleBound.center.x;
                var fY : Number = theCurrentVisibleBound.center.y;
                var fWidth : Number = theCurrentVisibleBound.ext.x * 2.0;
                var fHeight : Number = theCurrentVisibleBound.ext.y * 2.0;
                m_spVisibleBound.resize( fWidth, fHeight );
                m_spVisibleBound.moveTo( fX, fY, 0.0 );
            }
            else
            {
                m_spVisibleBound.resize( 0, 0 );
            }
        }

        private function _findMaxTerrainGridSize() : Number
        {
            var fMaxGridSize : Number = 20.0;
            var fGridSize : Number;
            for each( var theScene : CScene in m_theBelongFramework.sceneSet )
            {
                fGridSize = theScene.terrainData.gridUnitSize;
                if( fGridSize > fMaxGridSize ) fMaxGridSize = fGridSize;
            }

            return fMaxGridSize;
        }

        private function _getObjectFilename() : String
        {
            var sFilename : String = "";
            if ( this is CCharacter ) sFilename = (this as CCharacter).filename;
            else if ( this is CImage ) sFilename = (this as CImage).filename;
            else if ( this is CFX ) sFilename = (this as CFX).filename;
            else if ( this is CScene ) sFilename = (this as CScene).filename;

            if ( sFilename == null ) sFilename = "";
            else sFilename = CPath.nameExt( sFilename );

            return sFilename;
        }
        //
        //
        protected var m_theBelongFramework : CFramework = null;
        protected var m_sName : String = null;
        protected var m_iLoadingPriority : int = ELoadingPriority.NORMAL;

        /**
         * general update related parameters
         */
        protected var m_fUpdateSpeed : Number = 1.0;
        protected var m_fShakeSpeed : Number = 1.0;

        protected static const GRAVITY_ACC : Number = -9.8 * 100.0 * ( 2.0 ); // gravity per meter to gravity per unit in game:
                                                                                       //    assuming 1 cm = 1.5 unit and plus 1.0 for speed up the tempo
        protected var m_vGravityAcceleration : CVector3 = new CVector3( 0.0, GRAVITY_ACC, 0.0 );
        protected var m_vVelocityPerSec : CVector3 = new CVector3();
        protected var m_vLastPosition : CVector3 = new CVector3();
        protected var m_vAirMovement : CVector3 = new CVector3();
        protected var m_v2DPosition : CVector3 = new CVector3();
        protected var m_vTempBuffer : CVector3 = new CVector3();
        protected var m_fDepth2D : Number = 0.0;

        protected var m_vExtraJumpVelocity : CVector3 = new CVector3();
        protected var m_fEstimatedJumpHeight : Number = NaN;

        protected var m_fTerrainHeight : Number = -Number.MAX_VALUE;
        protected var m_fStepHeight : Number = -1.0;

        protected var m_bInAir : Boolean = false;
        protected var m_bEnablePhysics : Boolean = true;

        /**
         * bounding box
         */
        protected var m_spVisibleBound : CSprite = null; // just for displaying(debug)

        protected var m_bInViewRange : Boolean = false;
        protected var m_bIsCheckInViewRange : Boolean = true;
        protected var m_bEnableViewingCheckAnimation : Boolean = false;

        protected var m_iMovableBoxID : int = 0;

        protected var m_fOpaque : Number = 1.0;
        protected var m_fInnerOpaque : Number = 1.0;
        protected var m_vColor : CVector3 = new CVector3( 1.0, 1.0, 1.0 );
        protected var m_bInitiallyEnabled : Boolean = true;
        protected var m_bVisible : Boolean = true;
        protected var m_bEnabled : Boolean = true;
        protected var m_bStatic : Boolean = false;
        protected var m_bCastShadow : Boolean = false;

        protected var m_bDisposed : Boolean = false;
        protected var m_bRecycled : Boolean = false;

        /**
         * shaking parameters
         */
        protected var m_vShakeOffset : CVector2 = new CVector2();
        private var m_vShakeIntensity : CVector2 = new CVector2();
        private var m_fShakeTimeDuration : Number = 0.0;
        private var m_fShakeTime : Number = 0.0;
        private var m_fShakeDeltaTime : Number = 0.0;
        private var m_fShakeDeltaTimePeriod : Number = 0.02;
        private var m_iShakeRandomIndex : Number = 0;
        private static var s_vShakeRandomOffsets : Vector.< Number > = null;

        public var AssetsSize : int = 0;
        public var RelatedAssetsSize : int = 0;

    private var m_theDebugTimer : CTimer = new CTimer();
    }
}
