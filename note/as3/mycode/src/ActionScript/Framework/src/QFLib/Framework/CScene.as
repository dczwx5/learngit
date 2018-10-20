//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------

package QFLib.Framework
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CPath;
    import QFLib.Foundation.CSet;
    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.CUILayer;
    import QFLib.Graphics.Scene.CCamera;
    import QFLib.Graphics.Scene.CSceneLayer;
    import QFLib.Graphics.Scene.CSceneObject;
    import QFLib.Graphics.Scene.CTerrainData;
    import QFLib.Graphics.Sprite.CSprite;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CMath;
    import QFLib.Math.CVector2;
    import QFLib.Math.CVector3;
    import QFLib.Math.CVector4;
    import QFLib.Memory.CResourcePools;
    import QFLib.Node.EDirtyFlag;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.ELoadingPriority;

    public class CScene extends CObject
	{
        private var E_FX : int = 1;
        private var E_CHARACTER : int = 2;

		public function CScene( theBelongFramework : CFramework )
		{
			super( theBelongFramework );

            m_bEnablePhysics = false;
            m_theSceneObject = new CSceneObject( theBelongFramework.renderer );
            m_theSceneObject.mainCamera.onCameraEnabled = _onCameraEnabled;
            m_theSceneObject.mainCamera.onCameraTargetChanged = _onCameraTargetChanged;
            m_theSceneObject.mainCamera.onCameraFollowingModeChanged = _onCameraFollowingModeChanged;
		}

		public override function dispose() : void
		{
            if ( this.disposed ) return;
            if( m_theBelongFramework.currentCameraScene == this )
            {
                m_theBelongFramework._setCurrentCameraScene( null );
            }

            if( m_spCamVisibleBound != null )
            {
                m_spCamVisibleBound.dispose();
                m_spCamVisibleBound = null;
            }

            if( m_mapStaticObjects != null )
            {
                var aStaticObjects : Array = m_mapStaticObjects.toArray();
                for each( var obj : CObject in aStaticObjects )
                {
                    m_theSceneObject.removeObject( obj.theObject );
                    obj.dispose();
                }

                m_mapStaticObjects.clear();
                m_mapStaticObjects = null;
            }

            if ( m_setAttachedObjects != null )
            {
                var fx : CFX = null;
                for each ( var object : Object in m_setAttachedObjects )
                {
                    fx = object as CFX;
                    if ( fx != null )
                    {
                        fx.stop ();
                    }
                }
                m_setAttachedObjects.clear ();
                m_setAttachedObjects = null;
            }

            m_theSceneObject.dispose();
            m_theSceneObject = null;

            m_sName = null;
            super.dispose();
		}

        // try getting all used resources
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;

            // count scene object itself
            iCount += m_theSceneObject.retrieveAllResources( vResources, iBeginIndex + iCount );

            // count static objects of this scene
            for each ( var obj : CObject in m_mapStaticObjects )
            {
                iCount += obj.retrieveAllResources( vResources, iBeginIndex + iCount );
            }

            return iCount;
        }

        //
        [Inline]
        public static function get customImagePath() : String
        {
            return CSceneObject.customImagePath;
        }
        [Inline]
        public static  function set customImagePath( sPath : String ) : void
        {
            CSceneObject.customImagePath = sPath;
        }

        [Inline]
        public static function get customFXPath() : String
        {
            return m_sCustomFXDir;
        }
        [Inline]
        public static function set customFXPath( sPath : String ) : void
        {
            m_sCustomFXDir = sPath;
            m_sCustomFXDir = CPath.addRightSlash( m_sCustomFXDir );
        }

        [Inline]
        public static function get customCharacterPath() : String
        {
            return m_sCustomCharacterDir;
        }
        [Inline]
        public static function set customCharacterPath( sPath : String ) : void
        {
            m_sCustomCharacterDir = sPath;
            m_sCustomCharacterDir = CPath.addRightSlash( m_sCustomCharacterDir );
        }

        //
        // callback: function fnOnLoadFinished( theScene : CScene, iResult : int ) : void
        //
        public virtual function loadFile( sFilename : String, iPriority : int = ELoadingPriority.NORMAL, fnOnLoadFinished : Function = null ) : void
        {
            m_fnOnLoadFinished = fnOnLoadFinished;
            m_theSceneObject.loadFile( sFilename, iPriority, _onLoadFinished, true );
        }

        [Inline]
        final public function get collisionData() : CSceneCollisionData
        {
            return m_theCollisionData;
        }

        [Inline]
        final public function get filename() : String {
            if ( m_theSceneObject )
                return m_theSceneObject.filename;
            return null;
        }

        [Inline]
        final public function isLoading() : Boolean
        {
            if( m_fnOnLoadFinished != null && isLoadFinished() == false ) return true;
            else return false;
        }

        [Inline]
        final public function isLoadFinished() : Boolean
        {
            if( this.name == null || this.name.length == 0 ) return false;
            else return true;
        }

        [Inline]
        final public function get cameraEnabled() : Boolean
        {
            return m_theSceneObject.mainCamera.enabled;
        }
        [Inline]
        final public function set cameraEnabled( bEnabled : Boolean ) : void
        {
            m_theSceneObject.mainCamera.enabled = bEnabled;
        }

        //
        // mode 0: just target to an object
        // mode 1: interpolate camera's position and viewport size among all camera anchors
        // fSpringFactor: the bigger the camera move faster to the destination point
        // fCounterResistanceFactor: the bigger the camera counter the resistance faster
        //
        [Inline]
        final public function setCameraFollowingMode( iFollowingMode : int, fSpringFactor : Number = 3.0, fCounterResistanceFactor : Number = 3.0,
                                                         fCenterShiftFactor : Number = 0.8, bKeepAspectRatio: Boolean = true ) : void
        {
            return m_theSceneObject.mainCamera.setFollowingMode( iFollowingMode, fSpringFactor, fCounterResistanceFactor, fCenterShiftFactor, bKeepAspectRatio );
        }
        public function setCameraFollowingTarget( target : CObject, target2 : CObject = null ) : void
        {
            if( target != null && target2 != null )
            {
                target.updateMatrix();
                target2.updateMatrix();
                m_theSceneObject.mainCamera.setFollowingTarget( target.theObject, target2.theObject );
                m_theBelongFramework._setCurrentCameraTarget( target, target2 );
            }
            else if( target != null )
            {
                target.updateMatrix();
                m_theSceneObject.mainCamera.setFollowingTarget( target.theObject );
                m_theBelongFramework._setCurrentCameraTarget( target );
            }
            else
            {
                m_theSceneObject.mainCamera.setFollowingTarget( null );
                m_theBelongFramework._setCurrentCameraTarget( null );
            }
        }

        [Inline]
        final public function moveCameraToTargetAtOnce() : void
        {
            m_theSceneObject.mainCamera.moveToTargetAtOnce();
        }

        public function numSceneLayers() : int
        {
            return m_theSceneObject.numSceneLayers();
        }
        public function addObjectToLayer( layerIndex : int, object : CObject, bSetObjectParent : Boolean = true ) : Boolean
        {
            if( m_theSceneObject.addObjectToLayer( layerIndex, object.theObject ) )
            {
                if( bSetObjectParent ) object.setParent( this );
                return true;
            }
            else return false;
        }
        public function addObjectToEntityLayer( object : CObject, bSetObjectParent : Boolean = true ) : Boolean
        {

            if( m_theSceneObject.addObjectToEntityLayer( object.theObject ) )
            {
                if( bSetObjectParent ) object.setParent( this );
                return true;
            }
            else return false;
        }
        public function addObjectToUILayer ( object : CObject ) : Boolean
        {
            if ( m_theBelongFramework == null ) return false;
            var uiLayer : CUILayer = m_theBelongFramework.uiLayer;
            if ( uiLayer != null)
            {
                uiLayer.addChild ( object.theObject, true );
                return true;
            }

            return false;
        }

        //[Inline]
        final public function removeObjectFromLayer( layerIndex : int, obj : CObject, bSetObjectParent : Boolean = true ) : Boolean
        {
            if( obj == null ) return false;
            if( m_theSceneObject.removeObjectFromLayer( layerIndex, obj.theObject ) )
            {
                if( bSetObjectParent ) obj.setParent( null );
                return true;
            }
            else return false;
        }
        //[Inline]
        final public function removeObjectFromEntityLayer( object : CObject, bSetObjectParent : Boolean = true ) : Boolean
        {
            if( object == null ) return false;
            if( m_theSceneObject.removeObjectFromEntityLayer( object.theObject ) )
            {
                if( bSetObjectParent ) object.setParent( null );
                return true;
            }
            else return false;
        }
        //[Inline]
        final public function removeObjectFromUILayer ( object : CObject ) : Boolean
        {
            if ( m_theBelongFramework == null ) return false;
            var uiLayer : CUILayer = m_theBelongFramework.uiLayer;
            if ( uiLayer != null)
            {
                uiLayer.removeChild ( object.theObject, true );
                return true;
            }

            return false;
        }

        //
        // start / stop / control the rolling effect
        // param fToThrottle: 0.0 - 1.0(stop - full)
        // param fTimePeriod: speed up / down time
        //
        [Inline]
        final public function setLayerRollingThrottle( fToThrottle : Number, fTimePeriod : Number, iLayerIdx : int = -1 ) : void
        {
            m_theSceneObject.setLayerRollingThrottle( fToThrottle, fTimePeriod, iLayerIdx );
        }
        [Inline]
        final public function getLayerRollingThrottle( iLayerIdx : int = -1 ) : Number
        {
            return m_theSceneObject.getLayerRollingThrottle( iLayerIdx );
        }

        [Inline]
        final public function setAllLayersVisible( bVisible : Boolean ) : void
        {
            m_theSceneObject.setAllLayersVisible( bVisible );
        }
        [Inline]
        final public function setLayerVisible( iLayerIdx : int, bVisible : Boolean ) : void
        {
            m_theSceneObject.setLayerVisible( iLayerIdx, bVisible );
        }
        [Inline]
        final public function getLayerVisible( iLayerIdx : int ) : Boolean
        {
            return m_theSceneObject.getLayerVisible( iLayerIdx );
        }
        [Inline]
        final public function setEntityLayerVisible( bVisible : Boolean ) : void
        {
            m_theSceneObject.setEntityLayerVisible( bVisible );
        }
        [Inline]
        final public function getEntityLayer () : CSceneLayer
        {
            return m_theSceneObject.getEntityLayer ();
        }

        [Inline]
        final public function getLastForegroundLayer () : CSceneLayer
        {
            return m_theSceneObject.getLastForegroundLayer ();
        }

        [Inline]
        final public function findStaticObject( sName : String ) : CObject
        {
            return m_mapStaticObjects.find( sName );
        }

        //[Inline]
        final public function findStaticObjects( sName : String ) : Vector.<CObject>
        {
            var vecObject : Vector.<CObject> = new Vector.<CObject>();
            for each( var obj : CObject in m_mapStaticObjects )
            {
                if( obj.name.indexOf( sName ) > -1 )
                {
                    vecObject.push( obj );
                }
            }

            return vecObject;
        }

        [Inline]
        final public function get staticObjectsMap() : CMap
        {
            return m_mapStaticObjects;
        }

        //
        [Inline]
        final public function get terrainData() : CTerrainData
        {
            return m_theSceneObject.terrainData;
        }

        [Inline]
        final public function get startPoint() : CVector2
        {
            return m_theSceneObject.startPoint;
        }

        [Inline]
        final public function get mainCamera() : CCamera
        {
            return m_theSceneObject.mainCamera;
        }

        public override function set visible( bVisible : Boolean ) : void
        {
            setVisible( bVisible, true );
        }

        public function setVisible( bVisible : Boolean, bCheck : Boolean ) : void
        {
            if( bCheck && m_bVisible == bVisible ) return ;

            var bVisibleApplied : Boolean = bVisible && m_bEnabled;
            m_theSceneObject.visible = bVisibleApplied;

            super.visible = bVisible;
        }

        public override function set opaque( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;
            m_theSceneObject.opaque = fOpaque * m_fInnerOpaque;
        }

        public override function set innerOpaque( fInnerOpaque : Number ) : void
        {
            super.innerOpaque = fInnerOpaque;
            m_theSceneObject.opaque = fInnerOpaque * m_fOpaque;
        }

        public override function set enabled( bEnable : Boolean ) : void
        {
            if( m_bEnabled == bEnable ) return ;

            super.enabled = bEnable;
            for each ( var obj : CObject in m_mapStaticObjects )
            {
                obj.enabled = bEnable;
            }
            m_theSceneObject.mainCamera.enabled = bEnable;

            setVisible( m_bVisible, false );
        }

        public override function get theObject() : CBaseObject
        {
            return m_theSceneObject;
        }
        [Inline]
        final public function get sceneObject() : CSceneObject
        {
            return m_theSceneObject;
        }

        public override function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            m_theSceneObject.setColor( r, g, b, alpha, masking );

            for each ( var obj : CObject in m_mapStaticObjects )
            {
                obj.setColor ( r, g, b, alpha, masking );
            }
        }
        override public function resetColor () : void
        {
            m_theSceneObject.setColor( 1.0, 1.0, 1.0, 1.0, false );

            for each ( var obj : CObject in m_mapStaticObjects )
            {
                obj.resetColor ();
            }
        }

        [Inline]
        final public function get hasCameraVisibleBound() : Boolean
        {
            return ( m_spCamVisibleBound != null ) ? true : false;
        }
        public virtual function setCameraVisibleBound( bShow : Boolean, vColor : CVector4 = null, fBackoffScale : Number = 2.0 ) : void
        {
            if( bShow )
            {
                if( m_spCamVisibleBound == null )
                {
                    m_spCamVisibleBound = new CSprite( m_theBelongFramework.spriteSystem, true );
                    if( vColor != null )
                    {
                        m_spCamVisibleBound.setColor( vColor.r, vColor.g, vColor.b );
                        m_spCamVisibleBound.opaque = vColor.a;
                    }
                    else
                    {
                        m_spCamVisibleBound.setColor( 0.8, 0.8, 1.0 );
                        m_spCamVisibleBound.opaque = 0.2;
                    }

                    //var iNumLayers : int = m_theSceneObject.numSceneLayers();
                    //if( iNumLayers > 0 ) m_theSceneObject.addObjectToLayer( iNumLayers - 1, m_spCamVisibleBound );
                    m_theSceneObject.addObjectToEntityLayer( m_spCamVisibleBound );
                    _setupCameraVisibleBoundBox();
                }
                this.mainCamera.backoff( fBackoffScale );
            }
            else
            {
                if( m_spCamVisibleBound != null )
                {
                    m_theSceneObject.removeObject( m_spCamVisibleBound );
                    m_spCamVisibleBound.dispose();
                    m_spCamVisibleBound = null;
                }
                this.mainCamera.backoff( 1.0 );
            }
        }

        //
        // terrain and collision functions
        //
        //[Inline]
        public final function findNearbyGridPosition3D( f3DPosX : Number, f3DPosY : Number, f3DPosZ : Number, vPos3D : CVector3 = null, iMovableBoxID : int = 0 ) : CVector3
        {
            if( m_theCollisionData.movableBoxLockImmediately || iMovableBoxID == m_theCollisionData.movableBoxID )
            {
                return m_theSceneObject.terrainData.findNearbyGridPosition3D( f3DPosX, f3DPosY, f3DPosZ, vPos3D, m_theCollisionData.movableBox );
            }
            else
            {
                return m_theSceneObject.terrainData.findNearbyGridPosition3D( f3DPosX, f3DPosY, f3DPosZ, vPos3D );
            }
        }
        //[Inline]
        public final function findNearbyTerrainGridPosition3D( f3DPosX : Number, f3DPosY : Number, f3DPosZ : Number, vPos3D : CVector3 = null, iMovableBoxID : int = 0 ) : CVector3
        {
            if( m_theCollisionData.movableBoxLockImmediately || iMovableBoxID == m_theCollisionData.movableBoxID )
            {
                return m_theSceneObject.terrainData.findNearbyTerrainGridPosition3D( f3DPosX, f3DPosY, f3DPosZ, vPos3D, m_theCollisionData.movableBox );
            }
            else
            {
                return m_theSceneObject.terrainData.findNearbyTerrainGridPosition3D( f3DPosX, f3DPosY, f3DPosZ, vPos3D );
            }
        }
        //[Inline]
        public final function isBlocked( f3DPosX : Number, f3DPosY : Number, f3DPosZ : Number, bConsider3DPosY : Boolean = true, iMovableBoxID : int = 0 ) : Boolean
        {
            if( m_theCollisionData.movableBoxLockImmediately || iMovableBoxID == m_theCollisionData.movableBoxID )
            {
                return m_theSceneObject.isBlocked( f3DPosX, f3DPosY, f3DPosZ, bConsider3DPosY, m_theCollisionData.movableBox );
            }
            else
            {
                return m_theSceneObject.isBlocked( f3DPosX, f3DPosY, f3DPosZ, bConsider3DPosY );
            }
        }
        //[Inline]
        public final function isBlockedGrid( iGridX : int, iGridY : int, iMovableBoxID : int = 0 ) : Boolean
        {
            if( m_theCollisionData.movableBoxLockImmediately || iMovableBoxID == m_theCollisionData.movableBoxID )
            {
                return m_theSceneObject.isBlockedGrid( iGridX, iGridY, m_theCollisionData.movableBox );
            }
            else
            {
                return m_theSceneObject.isBlockedGrid( iGridX, iGridY );
            }
        }
        //[Inline]
        public final function isLineBlocked( f3DPosX1 : Number, f3DPosY1 : Number, f3DPosZ1 : Number,
                                                f3DPosX2 : Number, f3DPosY2 : Number, f3DPosZ2 : Number,
                                                bConsider3DPosY : Boolean = true, iMovableBoxID : int = 0 ) : Boolean
        {
            if( m_theCollisionData.movableBoxLockImmediately || iMovableBoxID == m_theCollisionData.movableBoxID )
            {
                return m_theSceneObject.isLineBlocked( f3DPosX1, f3DPosY1, f3DPosZ1, f3DPosX2, f3DPosY2, f3DPosZ2, bConsider3DPosY, m_theCollisionData.movableBox );
            }
            else
            {
                return m_theSceneObject.isLineBlocked( f3DPosX1, f3DPosY1, f3DPosZ1, f3DPosX2, f3DPosY2, f3DPosZ2, bConsider3DPosY );
            }
        }

        // the update function
        public override function update( fDeltaTime : Number ) : void
        {
            super.update( fDeltaTime );
            m_theSceneObject.update( fDeltaTime );

            updateMatrix();

            if( m_spCamVisibleBound != null ) _setupCameraVisibleBoundBox();
        }

        public override function updateMatrix( bCheckDirty : Boolean = true ) : void
        {
            super.updateMatrix( bCheckDirty );

            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_UPDATED ) || bCheckDirty == false )
            {
                _unsetDirtyFlags( EDirtyFlag.MX_FLAG_UPDATED );

                // set matrix to character object
                var vPosition : CVector3 = this.position;
                m_theSceneObject.setPosition3D( vPosition.x, vPosition.y, vPosition.z );

                // set 2D position again due to the customized depth value,
                if( this.depth2D != 0.0 ) m_theSceneObject.setPosition( m_theSceneObject.x, m_theSceneObject.y, this.depth2D );

                m_theSceneObject.setRotation( CMath.degToRad( this.localRotation.z ) );

                var vScale : CVector3 = this.scale;
                m_theSceneObject.setScale( this.flipX ? -vScale.x : vScale.x, this.flipY ? -vScale.y : vScale.y );

                m_theSceneObject.flipX = this.flipX;
                m_theSceneObject.flipY = this.flipY;
            }
        }

        //
        protected virtual function _onLoadFinished( theSceneObject : CSceneObject, iResult : int ) : void
        {
            if( this.disposed )
            {
                theSceneObject.dispose();
                return;
            }

            if( iResult == 0 )
            {
                this.setVisible( m_bVisible, false );
                this.opaque = m_fOpaque;

                _startLoadingLayerStaticObjects( theSceneObject );
                theSceneObject.clearSceneInfo();
                this.name = theSceneObject.name;
            }

            if( m_fnOnLoadFinished != null ) m_fnOnLoadFinished( this, iResult );
        }

		//
        private function _startLoadingLayerStaticObjects( theSceneObject : CSceneObject ) : void
        {
            var iLoadingPriority : int;
            var sceneInfo : Object = theSceneObject.sceneInfo;

            var layerInfo : Object;
            for( var j : int = 0; j < sceneInfo.layers.length; j++ )
            {
                layerInfo = sceneInfo.layers[ j ];
                if( layerInfo.hasOwnProperty("entities" ))
                {
                    var aObjects : Array = layerInfo[ "entities" ];
                    for( var i : int = 0; i < aObjects.length; i++ )
                    {
                        var parentDir : String;
                        var obj : CObject = null;
                        var jsonObj : Object = aObjects[ i ];

                        var boundObject : Object = jsonObj.bound;
                        var theBound : CAABBox2 = CAABBox2.ZERO;
                        if( boundObject != null ) theBound.setCenterExtValue( boundObject.center.x, boundObject.center.y, boundObject.width * 0.5, boundObject.height * 0.5 );

                        switch ( jsonObj.type )
                        {
                            case E_FX:
                            {
                                var sFXPath : String;
                                if( m_sCustomFXDir != null ) sFXPath = m_sCustomFXDir;
                                else
                                {
                                    parentDir = CPath.driverDirParent( theSceneObject.scenePath );
                                    parentDir = CPath.driverDirParent( parentDir );
                                    sFXPath = parentDir + "fx/";
                                }

                                iLoadingPriority = ELoadingPriority.HIGH;
                                if( this.mainCamera.isCollided( theBound, j ) == false )
                                {
                                    iLoadingPriority = ELoadingPriority.LOW;
                                }

                                /*
                                if( this.mainCamera.isCollidedPointValue( jsonObj.position.x, jsonObj.position.y, j ) == false )
                                {
                                    iLoadingPriority = ELoadingPriority.NORMAL;
                                    //continue;
                                }*/

                                var fx : CFX = new CFX( this.belongFramework );
                                fx.enableViewingCheckAnimation( true );
                                fx.loadFile( sFXPath + jsonObj.fileName + ".json", iLoadingPriority, onSceneFXLoadFinished );
                                fx.setAutoRecycle( true );

                                if( jsonObj.playOnAwake )
                                {
                                    fx.play( jsonObj.loop, jsonObj.loopTime );
                                }

                                obj = fx;
                                break;
                            }
                            case E_CHARACTER:
                            {
                                var sCharPath : String;
                                if( m_sCustomCharacterDir != null ) sCharPath = m_sCustomCharacterDir;
                                else
                                {
                                    parentDir = CPath.driverDirParent( theSceneObject.scenePath );
                                    parentDir = CPath.driverDirParent( parentDir );
                                    sCharPath = parentDir + "character/";
                                }

                                var character : CCharacter = new CCharacter( this.belongFramework, null );
                                character.enableViewingCheckAnimation( true );

                                var theDefaultState : CAnimationState = new CAnimationState( jsonObj.animation, jsonObj.animation, jsonObj.loop, false, false );
                                theDefaultState.randomStart = jsonObj.randomStart;
                                var theController : CAnimationController = new CAnimationController( theDefaultState );
                                character.animationController = theController;

                                var characterSkin : String = null;

                                if( jsonObj.playOnAwake )
                                {
                                    character.playState( jsonObj.animation );
                                }
                                if(jsonObj.hasOwnProperty("skinName") && jsonObj.skinName != "")
                                {
                                    var fileName : String = jsonObj.fileName;
                                    var subIndex : int = fileName.lastIndexOf("/");
                                    var skinName : String = new CPath(jsonObj.skinName ).name;
                                    characterSkin = sCharPath + fileName.substring(0, subIndex + 1) + skinName;
                                }

                                iLoadingPriority = ELoadingPriority.HIGH;
                                if( this.mainCamera.isCollided( theBound, layerInfo.id ) == false )
                                {
                                    iLoadingPriority = ELoadingPriority.LOW;
                                }
                                /*
                                if( this.mainCamera.isCollidedPointValue( jsonObj.position.x, jsonObj.position.y, j ) == false )
                                {
                                    iLoadingPriority = ELoadingPriority.NORMAL;
                                    //continue;
                                }*/

                                character.loadCharacterFile( sCharPath + jsonObj.fileName + ".json", characterSkin, null, iLoadingPriority, onSceneCharacterLoadFinished );

                                obj = character;
                                break;
                            }
                            default:
                            {
                                Foundation.Log.logWarningMsg( "CSceneLayer._startLoadingObjects(): object type not support: " + jsonObj.type );
                                break;
                            }
                        }

                        if( obj != null )
                        {
                            obj.isStatic = true;
                            obj.enablePhysics = false;

                            if( jsonObj.hasOwnProperty( "visible" ) )
                            {
                                obj._setInitiallyEnabled( jsonObj.visible );
                                obj.enabled = jsonObj.visible;
                            }

                            if( jsonObj.hasOwnProperty( "alpha" ) )
                            {
                                obj.opaque = jsonObj.alpha;
                            }

                            // negate the depth because of the opposite of the Z axis in between Unity and Flash
                            obj.setPositionToFrom2D( jsonObj.position.x, jsonObj.position.y, 0.0, -jsonObj.position.z );
                            obj.setScale( jsonObj.scale.x, jsonObj.scale.y, jsonObj.scale.z );
                            obj.localRotation.z = ( CMath.degToRad(jsonObj.rotation) );
                            theSceneObject.addObjectToLayer( j, obj.theObject );

                            if( jsonObj.name != null && jsonObj.name != "" )
                            {
                                obj.name = jsonObj.name;
                                m_mapStaticObjects.add( jsonObj.name, obj );
                            }
                        }
                    }
                }
            }
        }

        private function onSceneCharacterLoadFinished( theCharacter : CCharacter, iResult : int ) : void
        {
            if( this.disposed )
            {
                theCharacter.dispose();
                return ;
            }

            if( iResult == 0 )
            {
                var vAnimationNames : Vector.<String> = new Vector.<String>();
                theCharacter.retrieveAllAnimationClipNames( vAnimationNames );

                for each( var sAnimationName : String in vAnimationNames )
                {
                    if( theCharacter.animationController.findState( sAnimationName ) == null )
                    {
                        theCharacter.animationController.addState( new CAnimationState( sAnimationName, sAnimationName, false ) );
                    }
                }

                // make it fade in smoothly
                theCharacter.innerOpaque = 0.0;
                m_theBelongFramework.tweenSystem.addSequentialTweener( theCharacter, CTweener.innerOpaqueTo, 0.0, 0.5, 1.0 );
            }
        }

        private function onSceneFXLoadFinished( theFX : CFX, iResult : int ) : void
        {
            if( this.disposed )
            {
                theFX.dispose();
                return ;
            }

            if( iResult == 0 )
            {
                // make it fade in smoothly
                theFX.innerOpaque = 0.0;
                m_theBelongFramework.tweenSystem.addSequentialTweener( theFX, CTweener.innerOpaqueTo, 0.0, 0.5, 1.0 );
            }
            else
            {
                m_mapStaticObjects.remove(theFX.name);
            }
        }

        //[Inline]
        final public function _onCameraEnabled() : void
        {
            if( m_theSceneObject.mainCamera.enabled ) m_theBelongFramework._setCurrentCameraScene( this );
            else m_theBelongFramework._setCurrentCameraScene( null );
        }
        //[Inline]
        final public function _onCameraTargetChanged() : void
        {
        }
        //[Inline]
        final public function _onCameraFollowingModeChanged() : void
        {
            if( m_theSceneObject.mainCamera.enabled ) m_theBelongFramework._setCurrentCameraScene( this );
        }

        private function _setupCameraVisibleBoundBox() : void
        {
            var theCurrentCamBox : CAABBox2 = this.mainCamera.currentCameraBox;
            if( theCurrentCamBox != null )
            {
                var fX : Number = theCurrentCamBox.center.x;
                var fY : Number = theCurrentCamBox.center.y;
                var fWidth : Number = theCurrentCamBox.ext.x * 2.0;
                var fHeight : Number = theCurrentCamBox.ext.y * 2.0;
                m_spCamVisibleBound.resize( fWidth, fHeight );
                m_spCamVisibleBound.moveTo( fX, fY, 0.0 );
            }
            else
            {
                m_spCamVisibleBound.resize( 0, 0 );
            }
        }

        override public function _notifyAttached ( object : Object ) : void
        {
            m_setAttachedObjects.add ( object );
        }

        override public function _notifyDetached ( object : Object ) : void
        {
            m_setAttachedObjects.remove ( object );
        }
//
        //
        protected static var m_sCustomFXDir : String = null;
        protected static var m_sCustomCharacterDir : String = null;

        protected var m_theSceneObject : CSceneObject = null;
        protected var m_fnOnLoadFinished : Function = null;

        protected var m_mapStaticObjects : CMap = new CMap();
        protected var m_setAttachedObjects : CSet = new CSet();

        protected var m_theCollisionData :  CSceneCollisionData = new CSceneCollisionData();

        protected var m_spCamVisibleBound : CSprite = null; // just for displaying(debug)
    }
}

