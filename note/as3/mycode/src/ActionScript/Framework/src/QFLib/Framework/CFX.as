//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------

package QFLib.Framework
{

    import QFLib.Framework.CharacterExtData.CCharacterFXKey;
    import QFLib.Graphics.FX.CFXObject;
	import QFLib.Graphics.FX.CFxAtlasInfo;
	import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.Scene.CSceneLayer;
    import QFLib.Graphics.Scene.CSceneLayerCamera;
    import QFLib.Math.CMath;
    import QFLib.Math.CVector2;
    import QFLib.Math.CVector3;
    import QFLib.Memory.CResourcePool;
    import QFLib.Node.EDirtyFlag;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.ELoadingPriority;
	import QFLib.Utils.Quality;
	import QFLib.Utils.Random;

    import flash.geom.Rectangle;
    import flash.utils.getTimer;

    /**
     *  功能不太单一
     */
    public class CFX extends CObject
    {
        public static const NOFULLSCREEN : int = 0;
        public static const FULLSCREEN : int = 1;

        private static var sBounds : Rectangle = new Rectangle ();
        private static var sCameraBounds : Rectangle = new Rectangle ();
        private static var sPostionHelper : CVector3 = new CVector3 ();
        private static var sScaleHelper : CVector3 = new CVector3 ( 1.0, 1.0, 1.0 );
        private static var sRotationHelper : Number = 0;
        private static var sPosition2DHelper : CVector2 = new CVector2 ();
        private static var sOneScreenLimitCount : int = 0;
        private static var sCurScreenVisibleCount : int = 0;

        private static const PLAY : int = 1;
        private static const PAUSE : int = 2;
        private static const STOP : int = 3;

        public static function manuallyRecycle ( pFX : CFX ) : void
        {
            if ( pFX.disposed || pFX.isRecycled ) return;
            var pool : CResourcePool = pFX.belongFramework.fxResourcePools.getPool ( pFX.filename );
            if ( null == pool )
            {
                pool = new CResourcePool ( pFX.filename, null, 0 );
                pFX.belongFramework.fxResourcePools.addPool ( pFX.filename , pool );
            }

            pFX.visible = true;
            pool.recycle ( pFX );
        }

        public static function setOneScreenLimitCount ( count : int ) : void
    {
        sOneScreenLimitCount = count;
    }
        public static function resetCurScreenVisibleCount () : void
        {
            sCurScreenVisibleCount = 0;
        }
        private static function get isScreenLimitEnabled () : Boolean { return sOneScreenLimitCount > 0; }

        public function CFX ( theBelongFramework : CFramework )
        {
            super ( theBelongFramework );

            this.enablePhysics = false;
            this.enableViewingCheckAnimation ( true );
            _fxObject = new CFXObject ( theBelongFramework.renderer );
        }

        public override function dispose () : void
        {
            if ( this.disposed ) return;

            detachFromCharacter ();
            _pAttachEffectKey = null;
            _strFileURL = null;
            _fnBeforeUpdate = null;
            _fnStopedCallBack = null;
            _fnLoadFinished = null;

            m_theBelongFramework._removeObject ( this );
            if ( _fxObject != null )
            {
                _fxObject.setParent ( null );
                _fxObject.dispose ();
                _fxObject = null;
            }

            super.dispose ();
        }

        // try getting all used resources - implement by the derived classes
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            if ( null != _fxObject )
            {
                var iCount : int = 0;
                iCount += _fxObject.retrieveAllResources(vResources, iBeginIndex + iCount);

                return iCount;
            }
            return 0;
        }

        public override function revive () : void
        {
            super.revive ();
        }

        public override function recycle () : void
        {
            if ( this.isRecycled ) return;

            // do things before dump to recycle pool
            _fnBeforeUpdate = null;
            _fnLoadFinished = null;
            _fnStopedCallBack = null;
            _curPlayState = STOP;
            _bLoopPlay = false;
            _bAutoRecycle = false;
            reset ();
            detachFromCharacter ();

            super.recycle ();
        }

        [Inline] final public override function get theObject () : CBaseObject { return _fxObject; }

        public override function set opaque ( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;
            _fxObject.opaque = fOpaque;
        }

        public override function set innerOpaque ( fInnerOpaque : Number ) : void
        {
            super.innerOpaque = fInnerOpaque;
            _fxObject.opaque = m_fOpaque * fInnerOpaque;
        }

        public override function set visible ( bVisible : Boolean ) : void
        {
            setVisible( bVisible, true );
        }

        public function setVisible( bVisible : Boolean, bCheck : Boolean ) : void
        {
            if( bCheck && m_bVisible == bVisible ) return ;

            if ( _fxObject != null )
            {
                var bVisibleApplied : Boolean = bVisible && m_bEnabled;
                _fxObject.visible = bVisibleApplied;
            }

            super.visible = bVisible;
        }

        public override function set enabled( bEnable : Boolean ) : void
        {
            if( m_bEnabled == bEnable ) return ;

            super.enabled = bEnable;
            setVisible( m_bVisible, false );
        }

        [Inline] final public function get filename () : String { return _strFileURL; }

        [Inline] final public function get isLoaded () : Boolean { return _fxObject.isLoader; }
        [Inline] final public function get isDead () : Boolean { return _fxObject.isDead; }
        [Inline] final public function get timeScale () : Number { return _timeScale; }
        [Inline] final public function set timeScale ( value : Number ) : void { _timeScale = value; }
        [Inline] final public function set extraDepth ( value : Number) : void { _extraDepth = value; }

        [Inline] final public function get isLoopPlay () : Boolean { return _bLoopPlay; }
        [Inline] final public function get isPlaying () : Boolean { return _curPlayState == PLAY || _curPlayState == PAUSE; }
        [Inline] final public function get isStopped () : Boolean { return _curPlayState == STOP; }
        [Inline] final public function get isStartPlayActually () : Boolean { return _bStartPlayActually; }
        [Inline] final public function get isAutoRecycle () : Boolean { return _bAutoRecycle; }
        [Inline] final public function setAutoRecycle ( value : Boolean ) : void { _bAutoRecycle = value; }
        [Inline] final public function set basedOnScreenLimit ( value : Boolean ) : void { _bBasedOnScreenLimit = value; }

        [Inline] final public function get fxKey () : CCharacterFXKey { return _pAttachEffectKey; }

        [Inline] final public function set onBeforeUpdateCallBack ( fnBeforeUpdateCallBack : Function ) : void { _fnBeforeUpdate = fnBeforeUpdateCallBack; }
        [Inline] final public function set onStopedCallBack ( fnStopedCallBack : Function ) : void { _fnStopedCallBack = fnStopedCallBack; }

        override public virtual function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            super.setColor ( r, g, b, alpha, masking );
            if ( _fxObject != null ) _fxObject.setColor ( r, g, b, alpha, masking );
        }
        override public function resetColor () : void
        {
            if ( _fxObject != null ) _fxObject.resetColor ();
        }

        public function attachToTarget ( object : CObject, flipX : Boolean = false, flipSelfX : Boolean = false, type : int = -1, relativePos : CVector3 = null, scale : CVector3 = null, topDisplay : Boolean = false ) : void
        {
            if ( _pAttachedObject != null )
                detachFromTarget ();

            if ( object != null && !object.disposed ) object._notifyAttached( this );
            else return;

            this._bTopDisplay = topDisplay;
            this._pAttachedObject = object;

            var pScene : CScene = _pAttachedObject as CScene;
            if ( pScene != null )
            {
                _attach2SceneType = type;
                if ( relativePos != null )
                    _attach2ScenePosition.set ( relativePos );
                if ( scale != null )
                    _externalScaleParam.set ( scale );
                _externalFlipXParam = flipX;
                _externalFlipSelfXParam = flipSelfX;

                //场景变色特效不需要设置parent
                if ( _attach2SceneType != -1 )
                {
                    var pLayer : CSceneLayer = null;
                    if ( topDisplay )
                        pLayer = pScene.getLastForegroundLayer ();
                    else
                        pLayer = pScene.getEntityLayer ();
                    _fxObject.setParent ( pLayer );
                }
            }
            else
            {
                var pParent : CBaseObject = _pAttachedObject.theObject.parent;
                if ( pParent == null )
                    _fxObject.attachToRoot ();
                else
                    _fxObject.setParent ( pParent );
            }

            _fxObject.attachToTarget ( object );
        }

        public function detachFromTarget () : void
        {
            if ( _pAttachedObject != null )
                _pAttachedObject._notifyDetached ( this );
            if ( _fxObject != null )
            {
                _fxObject.setParent ( null );
                _fxObject.detachFromTarget ();
            }
            _pAttachedObject = null;
        }

        /**
         *  和attachToTarget很容易引起歧义...
         */
        public function attachToCharacter ( pCharacter : CCharacter, pFXkey : CCharacterFXKey ) : void
        {
            if ( pCharacter == null || pCharacter.disposed ) return;
            _pAttachEffectKey = pFXkey;
            attachToTarget ( pCharacter );
        }

        public function detachFromCharacter () : void
        {
            if ( _pAttachedObject == null ) return;
            detachFromTarget ();
            _pAttachEffectKey = null;
        }

        /**
         * callback: function onLoadFinished( theFX : CFX, iResult : int ) : void
         */
        public function loadFile ( sFilename : String, iLoadingPriority : int = ELoadingPriority.NORMAL, onLoadFinished : Function = null, params : Array = null ) : void
        {
            if(Quality.useFxAtlas)
            {
                CFxAtlasInfo.instance.loadFile();
            }

            m_iLoadingPriority = iLoadingPriority;
            _strFileURL = sFilename;
            _paramsLoadFinished = params;
            _fnLoadFinished = onLoadFinished;
            _loadingStartTime = getTimer ();
            _fxObject.loadFile ( sFilename, iLoadingPriority, _onLoadFinished );
        }

        public function play ( bLoop : Boolean = false, playTime : Number = -1.0,
                               randomMin : Number = 0.0, randomMax : Number = 1.0, timeScale : Number = 1.0 ) : void
        {
            if ( _curPlayState == STOP )
            {
                if ( randomMin < 0.0 ) randomMin = 0.0;
                if ( randomMax < 0.0 ) randomMax = 0.0;

                _randomPlayStartTime = Random.range ( randomMin, randomMax );

                _timeScale = timeScale;
                _playTime = playTime;
                _bLoopPlay = bLoop;
            }

            _curPlayState = PLAY;
        }
        [Inline] final public function pause () : void { _curPlayState = PAUSE; }
        public function stop () : void
        {
            if ( this.disposed || this.isRecycled || _curPlayState == STOP ) return;

            _currentTime = 0.0;
            _playTime = -1.0;
            _randomPlayStartTime = 0.0;
            _curPlayState = STOP;
            _bLoopPlay = false;
            _bStartPlayActually = false;

            reset ();
            detachFromCharacter ();
            autoRecycler ();
        }

        override public function update ( deltaTime : Number ) : void
        {
            if ( _curPlayState != PLAY ) return;
            if ( _pAttachedObject != null && _pAttachedObject.disposed )
            {
                natruallyStopped ();
                return;
            }

            var fUpdateDeltaTime : Number = deltaTime * m_fUpdateSpeed;
            _update( fUpdateDeltaTime );
            var fShakeUpdateDeltaTime : Number = deltaTime * m_fShakeSpeed;
            _shakeUpdate( fShakeUpdateDeltaTime );

            if ( null != _fnBeforeUpdate )
                _fnBeforeUpdate ( this );

            updateTimeScaleWithCharacter ();
            deltaTime *= _timeScale;
            _currentTime += deltaTime;

            //random play
            if ( _currentTime < _randomPlayStartTime ) return;

            //if current time equal to playtime, it will stop or dispose the effect
            if ( _playTime > 0.0 )
            {
                var totalTime : Number = _playTime + _randomPlayStartTime;
                if ( totalTime > 0.0 && _currentTime > totalTime )
                {
                    natruallyStopped ();
                    return;
                }
            }

            if ( !_fxObject.enable ) return;

            //if not loop and effect is dead, stop or dispose effect
            if ( !_bLoopPlay && _fxObject.isDead )
            {
                natruallyStopped ();
                return;
            }
            else
            {
                if ( _bLoopPlay && isDead )
                    _fxObject.reset ();

                _bStartPlayActually = true;

                updateTransform ();
                if ( m_bEnableViewingCheckAnimation && !_fxObject.isModifier )
                {
                    m_bInViewRange = _viewRangeChecking ();
                    //if ( m_bInViewRange ) _fxObject.update ( deltaTime );
                }else if( !m_bEnableViewingCheckAnimation ){
                    //剧情调用播放特效接口的时候，会设置m_bEnableViewingCheckAnimation=false,否则是导致特效播放不显示
                    m_bInViewRange = true;
                }

                _fxObject.update ( deltaTime );

                if ( CFX.isScreenLimitEnabled && _bBasedOnScreenLimit && m_bInViewRange )
                {
                    if ( CFX.sCurScreenVisibleCount < CFX.sOneScreenLimitCount )
                    {
                        _fxObject.setScreenVisible ( true );
                        CFX.sCurScreenVisibleCount++;
                    }
                    else
                        _fxObject.setScreenVisible ( false );
                }
                else if ( !m_bInViewRange )
                    _fxObject.setScreenVisible ( false );
                else
                    _fxObject.setScreenVisible ( true );
            }
            if( m_spVisibleBound != null ) _setupVisibleBoundBox();
        }

        //
        public override function updateMatrix ( bCheckDirty : Boolean = true ) : void
        {
            super.updateMatrix( bCheckDirty );

            if ( _checkDirtyFlags ( EDirtyFlag.MX_FLAG_UPDATED ) || bCheckDirty == false )
            {
                _unsetDirtyFlags ( EDirtyFlag.MX_FLAG_UPDATED );

                _fxObject.setRotation ( this.localRotation.z );

                var vScale : CVector3 = this.scale;
                _fxObject.setScale ( vScale.x, vScale.y );

                _fxObject.flipX = this.flipX;
                _fxObject.flipY = this.flipY;

                // set matrix to character object
                var vPosition : CVector3 = this.position;
                _fxObject.setPosition3D ( vPosition.x, vPosition.y, vPosition.z );

                // set 2D position again due to the customized depth value,
                if ( this.depth2D != 0.0 ) _fxObject.setPosition ( _fxObject.x, _fxObject.y, this.depth2D );
                else _fxObject.setPosition ( _fxObject.x, _fxObject.y, _extraDepth + _fxObject.position.z );
            }
        }

        public function reset () : void
        {
            if ( null != _fxObject )
            {
                _fxObject.setParent( null );
                _fxObject.reset ();
            }
            _currentTime = 0.0;
            _bNeedUpdate = true;
            _bStartPlayActually = false;
        }

        override protected function _viewRangeChecking () : Boolean
        {
            if ( _fxObject == null || _fxObject.usingCamera == null )
                return false;

            var wBounds : Rectangle = getWorldBound ( sBounds );
            if ( wBounds == null )
                return false;

            var camera : ICamera = _fxObject.usingCamera;
            var cameraBounds : Rectangle = sCameraBounds;
            cameraBounds.x = camera.viewportX;
            cameraBounds.y = camera.viewportY;
            cameraBounds.width = camera.viewportWidth;
            cameraBounds.height = camera.viewportHeight;

            return cameraBounds.intersects ( wBounds );
        }

        private function updateTransform () : void
        {
            if ( _fxObject == null || !_fxObject.enable ) return;
            var pCharacter : CCharacter = _pAttachedObject as CCharacter;
            if ( pCharacter != null && !pCharacter.disposed )
                updateWithCharacterTransform ( pCharacter );
            else
            {
                var pScene : CScene = _pAttachedObject as CScene;
                if ( pScene != null && !pScene.disposed )
                    updateWithSceneTransform ( pScene );
                else if ( _pAttachedObject == null )
                    updateMatrix ();
            }
        }

        private function updateWithCharacterTransform ( pCharacter : CCharacter ) : void
        {
            if ( null != _pAttachEffectKey && _bNeedUpdate )
            {
                //Hack:动作特效第一次播放时位置错误修正（暂时这样改吧）
                if ( _checkDirtyFlags ( EDirtyFlag.MX_FLAG_UPDATED ) )
                    _unsetDirtyFlags ( EDirtyFlag.MX_FLAG_UPDATED );

                //scale
                var flipX : int = 1;
                if ( pCharacter.flipX ) flipX = -1;
                var scale : CVector3 = pCharacter.scale;
                _fxObject.setScale ( _pAttachEffectKey.localScale.x * Math.abs ( scale.x ),
                        _pAttachEffectKey.localScale.y * scale.y );
                _fxObject.flipX = pCharacter.flipX;

                //rotation
                _fxObject.setRotation ( _pAttachEffectKey.localRotation.z * -flipX );

                //position
                var position : CVector3 = boneWorldPosition ( _pAttachEffectKey.boneIndex, flipX );
                _fxObject.setPosition ( _pAttachEffectKey.localPosition.x * scale.x * flipX + position.x,
                        _pAttachEffectKey.localPosition.y * scale.y + position.y,
                        _pAttachEffectKey.localPosition.z + position.z );

                // set 2D position again due to the customized depth value,
                if ( this.depth2D != 0.0 ) _fxObject.setPosition ( _fxObject.x, _fxObject.y, this.depth2D );

                _bNeedUpdate = _pAttachEffectKey.playFollowTRS;
            }
        }

        private function updateWithSceneTransform ( pScene : CScene ) : void
        {
            if ( _checkDirtyFlags ( EDirtyFlag.MX_FLAG_UPDATED ) )
                _unsetDirtyFlags ( EDirtyFlag.MX_FLAG_UPDATED );

            var pSceneLayer : CSceneLayer = !_bTopDisplay ? pScene.getEntityLayer () : pScene.getLastForegroundLayer ();
            var pCamera : CSceneLayerCamera = pSceneLayer.camera;
            var cameraX : Number = pCamera.cameraCenterX;
            var cameraY : Number = pCamera.cameraCenterY;
            var cameraLeftX : Number = pCamera.viewportX;
            var cameraLeftY : Number = pCamera.viewportY;
            var layerPosition : CVector3 = pSceneLayer.position;
            var posX : Number = cameraLeftX;
            var flipX : int = _externalFlipXParam ? -1 : 1;

            if ( _externalFlipXParam )
                posX += pCamera.viewportWidth;

            var positionZ : Number = layerPosition.z;
            if ( !_bTopDisplay ) positionZ -= 5;
            else positionZ += 5;
            switch ( _attach2SceneType )
            {
                case FULLSCREEN:
                    _fxObject.setPosition ( posX, cameraLeftY, positionZ );
                    break;
                case NOFULLSCREEN:
                    _fxObject.setPosition ( cameraX + _attach2ScenePosition.x * flipX, cameraY - _attach2ScenePosition.y, positionZ );
                    break;
                default:
                    break;
            }

            if ( _fxObject.flipX != _externalFlipSelfXParam )
                _fxObject.flipX = _externalFlipSelfXParam;

//            var scale : Number = 1.0;
//            if ( _attach2SceneType == NOFULLSCREEN )
//                scale = pCamera.viewportWidth / 1500.0;
//            else
            var scale : Number = pCamera.viewportWidth / 1500.0;
            _fxObject.setScale ( _externalScaleParam.x * scale, _externalScaleParam.y * scale, 1.0 );
        }

        private function updateTimeScaleWithCharacter () : void
        {
            var pCharacter : CCharacter = _pAttachedObject as CCharacter;
            if ( pCharacter == null || pCharacter.disposed ) return;
            if ( _pAttachEffectKey == null ) return;
            if ( _pAttachEffectKey.fxType != CCharacterFXKey.NORMAL_FX ) return;
            var updateSpeed : Number = pCharacter.updateSpeed;
            if ( updateSpeed < CMath.EPSILON )
            {
                if ( _bStartPlayActually && _pAttachEffectKey.playOneTime )
                    _timeScale = 1.0;
                else _timeScale = 0.0;
            }
            else
            {
                if ( !_pAttachEffectKey.playOneTime )
                {
                    if ( !_bStartPlayActually ) _timeScale = 1.0;
                    else _timeScale = pCharacter.animationSpeed;
                }
                else
                {
                    _timeScale = 1.0;
                }
            }
        }

        final private function boneWorldPosition ( boneIndex : int, flipX : int ) : CVector3
        {
            var pCharacter : CCharacter = _pAttachedObject as CCharacter;
            pCharacter.retrieveBonePosition ( boneIndex, sPosition2DHelper, false, false );
            var scale : CVector3 = pCharacter.characterObject.scale;
            sPosition2DHelper.x *= Math.abs ( scale.x ) * flipX;
            sPosition2DHelper.y *= scale.y;

            sPostionHelper.setValueXYZ ( pCharacter.characterObject.x + sPosition2DHelper.x,
                    pCharacter.characterObject.y + sPosition2DHelper.y,
                    pCharacter.characterObject.position.z );

            return sPostionHelper;
        }

        [Inline]
        final private function boneWorldRotation ( boneIndex : int ) : Number
        {
            var pCharacter : CCharacter = _pAttachedObject as CCharacter;
            sRotationHelper = pCharacter.retrieveBoneRotation ( boneIndex );
            return sRotationHelper;
        }

        [Inline]
        final private function boneWorldScale ( boneIndex : int ) : CVector3
        {
            return sScaleHelper;
        }

        private function autoRecycler () : void
        {
            if ( _bAutoRecycle )
                CFX.manuallyRecycle ( this );
        }

        private function _onLoadFinished (loadSuccess:Boolean = true) : void {
            if ( !loadSuccess )
            {
                if(_fnLoadFinished != null)
                {
                    if ( _paramsLoadFinished != null )
                        _fnLoadFinished ( this, 1, _paramsLoadFinished);
                    else
                        _fnLoadFinished ( this, 1 );
                }
                if(!this.isRecycled && !this.disposed)
                    dispose();
                return;
            }

            this.setVisible( m_bVisible, false );
            this.opaque = m_fOpaque;

            AssetsSize = _fxObject.assetsSize;
            if ( _fnLoadFinished != null )
            {
                if ( _paramsLoadFinished != null )
                    _fnLoadFinished ( this, 0, _paramsLoadFinished);
                else
                    _fnLoadFinished ( this, 0 );
            }

            var endTime : Number = getTimer ();
            var duration : Number = ( endTime -_loadingStartTime ) * 0.001;
            if ( _curPlayState == PLAY && duration > _randomPlayStartTime )
            {
                _fxObject.update( duration - _randomPlayStartTime );
            }
        }

        private function natruallyStopped () : void
        {
            this.stop ();
            if ( _fnStopedCallBack )
            {
                _paramsStopedCallBack = [ this ];
                _fnStopedCallBack ( _paramsStopedCallBack );
            }
        }

        private function getWorldBound ( result : Rectangle ) : Rectangle
        {
            if ( _fxObject!= null ) return _fxObject.getWorldBound ( result );
            return result;
        }

        //
        //
        private var _fxObject : CFXObject = null;
        private var _strFileURL : String = null;

        private var _playTime : Number = -1.0;
        private var _currentTime : Number = 0.0;
        private var _randomPlayStartTime : Number = 0.0;
        private var _timeScale : Number = 1.0;
        private var _loadingStartTime : Number = 0.0;
        private var _extraDepth : Number = 0.0;

        private var _pAttachedObject : CObject = null;
        private var _pAttachEffectKey : CCharacterFXKey = null;
        private var _externalScaleParam : CVector3 = CVector3.one ();
        private var _externalFlipXParam : Boolean = false;
        private var _externalFlipSelfXParam : Boolean = false;

        private var _curPlayState : int = STOP;

        private var _attach2SceneType : int = -1;                             //NOFULLSCREEN / FULLSCREEN
        private var _attach2ScenePosition : CVector3 = CVector3.zero ();

        private var _paramsStopedCallBack : Array = null;
        private var _paramsLoadFinished : Array = null;
        private var _fnLoadFinished : Function = null;              //特效加载完成
        private var _fnStopedCallBack : Function = null;                  //干么用的？
        private var _fnBeforeUpdate : Function = null;

        private var _bLoopPlay : Boolean = false;
        private var _bStartPlayActually : Boolean = false;          //特效真正开始播放了
        private var _bAutoRecycle : Boolean = false;
        private var _bNeedUpdate : Boolean = true;                  //主要是特效绑定时，几种绑定类型判定是否需要更新：诸如位置、旋转、缩放等等
        private var _bTopDisplay : Boolean = false;

        private var _bBasedOnScreenLimit : Boolean = true;
    }
}