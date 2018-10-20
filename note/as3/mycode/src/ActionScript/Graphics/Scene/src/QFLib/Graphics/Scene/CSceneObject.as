//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/5/20.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Scene
{
	import QFLib.Foundation;
	import QFLib.Foundation.CPath;
	import QFLib.Graphics.RenderCore.CBaseObject;
	import QFLib.Graphics.RenderCore.CRenderer;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.CBaseLoader;
    import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    public class CSceneObject extends CBaseObject
	{
		public function CSceneObject( theRenderer : CRenderer )
		{
			super( theRenderer );
			this.attachToRoot();

            m_theMainCamera = new CCamera( m_theRenderer );
        }

		public override function dispose() : void
		{
            if( m_theSceneInfo )
            {
                m_theSceneInfo.dispose();
                m_theSceneInfo = null;
            }

			if( m_theMainCamera )
			{
				m_theMainCamera.dispose();
				m_theMainCamera = null;
			}
            if( m_theStartPointObject )
            {
                m_theStartPointObject.dispose();
                m_theStartPointObject = null;
            }

			for each( var layer : CSceneLayer in m_vectLayers )
			{
                layer.setParent( null );
                layer.dispose();
			}
			m_vectLayers.length = 0;

			for each (var camera:CSceneLayerCamera in m_vectLayerCameras)
			{
				m_theRenderer.removeCamera(camera);
				camera.dispose();
			}
			m_vectLayerCameras.length = 0;

            if( m_theTerrainData != null )
            {
                m_theTerrainData.dispose();
                m_theTerrainData = null;
            }

            if( m_theResource != null )
            {
                m_theResource.dispose();
                m_theResource = null;
            }

			super.dispose();
		}

        // try getting all used resources
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;
            for each( var layer : CSceneLayer in m_vectLayers )
            {
                iCount += layer.retrieveAllResources( vResources, iBeginIndex + iCount );
            }

            return iCount;
        }

        //
        // callback: function fnOnLoadFinished( theSceneObject : CSceneObject, iResult : int ) : void
        //
		public virtual function loadFile( sFilename : String, iPriority : int = ELoadingPriority.NORMAL,
                                              fnOnLoadFinished : Function = null, bKeepSceneInfo :Boolean = false ) : void
		{
            if( CPath.ext( sFilename ).length == 0 ) sFilename += ".json";

			m_sDir = CPath.driverDir( sFilename );
            m_fnOnLoadFinished = fnOnLoadFinished;
            m_bKeepSceneInfo = bKeepSceneInfo;

            CResourceLoaders.instance().startLoadFile( sFilename, _onLoadFinished, CJsonLoader.NAME, iPriority );
        }

        public override function set opaque( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;

            for each( var layer : CSceneLayer in m_vectLayers )
            {
                layer.opaque = fOpaque;
            }
        }

        public override function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            super.setColor( r, g, b, alpha, masking );

            for each( var layer : CSceneLayer in m_vectLayers )
            {
                layer.setColor( r, g, b, alpha, masking );
            }
        }

        public function addObjectToLayer( layerIndex : int, obj : CBaseObject ) : Boolean
        {
            var layer : CSceneLayer = getLayerByIndex( layerIndex );
            if( layer )
            {
                layer.addChild( obj );
                return true;
            }
            else return false;
        }
        public function addObjectToEntityLayer( object : CBaseObject ) : Boolean
        {
            if( m_iEntityLayerIndex == -1 )
            {
                Foundation.Log.logErrorMsg( " the scene is not ready to add objects!" );
                return false;
            }

            return addObjectToLayer( m_iEntityLayerIndex, object );
        }

        public function removeObjectFromLayer( layerIndex : int, obj : CBaseObject ) : Boolean
        {
            var layer : CSceneLayer = getLayerByIndex( layerIndex );
            if( layer )
            {
                layer.removeChild( obj );
                return true;
            }
            else return false;
        }
        public function removeObjectFromEntityLayer( object : CBaseObject ) : Boolean
        {
            if( m_iEntityLayerIndex == -1 )
            {
                Foundation.Log.logErrorMsg( " the scene is not ready to remove objects!" );
                return false;
            }

            return removeObjectFromLayer( m_iEntityLayerIndex, object );
        }
        public function removeObject( object : CBaseObject ) : Boolean
        {
            if( object == null ) return false;

            var theParent : CBaseObject = object.parent;
            if( theParent != null && theParent is CSceneLayer )
            {
                CSceneLayer( theParent ).removeChild( object );
                return true;
            }
            return false;
        }

        public function setAllLayersVisible( bVisible : Boolean ) : void
        {
            for each( var layer : CSceneLayer in m_vectLayers )
            {
                layer.visible = bVisible;
            }
        }
        [Inline]
        public function setLayerVisible( iLayerIdx : int, bVisible : Boolean ) : void
        {
            if( iLayerIdx >= m_vectLayers.length ) return ;
            m_vectLayers[ iLayerIdx ].visible = bVisible;
        }
        [Inline]
        public function getLayerVisible( iLayerIdx : int ) : Boolean
        {
            if( iLayerIdx >= m_vectLayers.length ) return false;
            return m_vectLayers[ iLayerIdx ].visible;
        }
        [Inline]
        public function setEntityLayerVisible( bVisible : Boolean ) : void
        {
            if( m_iEntityLayerIndex == -1 ) return;
            m_vectLayers[ m_iEntityLayerIndex ].visible = bVisible;
        }

        [Inline]
		public function getEntityLayer() : CSceneLayer
        {
			if( m_iEntityLayerIndex == -1 ) return null;
			return m_vectLayers[m_iEntityLayerIndex];
		}

        [Inline]
        public function getLastForegroundLayer () : CSceneLayer
        {
            if ( m_vectLayers != null )
            {
                var layer : CSceneLayer = null;
                for ( var i : int = m_vectLayers.length - 1; i >=0; i-- )
                {
                    layer = m_vectLayers[ i ];
                    if ( layer != null ) return layer;
                }
            }

            return null;
        }

        public function getLayerByIndex( layerIndex : int ) : CSceneLayer
        {
            if ((layerIndex < 0 || layerIndex >= m_vectLayers.length ))
            {
                Foundation.Log.logErrorMsg( "layerIndex out of bound!(" + layerIndex + ")" );
            }

            return m_vectLayers[ layerIndex ];
        }

        public function numSceneLayers() : int
        {
            return m_vectLayers.length
        }

        //
        // start / stop / control the rolling effect
        // param fToThrottle: 0.0 - 1.0(stop - full)
        // param fTimePeriod: speed up / down time
        //
        public function setLayerRollingThrottle( fToThrottle : Number, fTimePeriod : Number, iLayerIdx : int = -1 ) : void
        {
            if( iLayerIdx < 0 )
            {
                for each( var layer : CSceneLayer in m_vectLayers ) layer.setRollingThrottle( fToThrottle, fTimePeriod );
            }
            else
            {
                if( iLayerIdx >= m_vectLayers.length ) return ;
                m_vectLayers[ iLayerIdx ].setRollingThrottle( fToThrottle, fTimePeriod );
            }
        }

        public function getLayerRollingThrottle( iLayerIdx : int = -1 ) : Number
        {
            if( iLayerIdx < 0 )
            {
                var fBiggestRollingThrottle : Number = 0.0;
                for each( var layer : CSceneLayer in m_vectLayers )
                {
                    if( layer.rollingThrottle > fBiggestRollingThrottle ) fBiggestRollingThrottle = layer.rollingThrottle;
                }

                return fBiggestRollingThrottle;
            }
            else
            {
                if( iLayerIdx >= m_vectLayers.length ) return 0.0;
                return m_vectLayers[ iLayerIdx ].rollingThrottle;
            }
        }

        [Inline]
        public function get startPoint() : CVector2
        {
            return m_theStartPoint;
        }

        [Inline]
		public function get mainCamera() : CCamera
		{
			return m_theMainCamera;
		}

        [Inline]
        final public function get scenePath() : String
        {
            return m_sDir;
        }
        [Inline]
        public function get filename() : String
        {
            return m_sFilename;
        }
        [Inline]
        public function get name() : String
        {
            return m_sName;
        }

        [Inline]
        public static function get customImagePath() : String
        {
            return m_sCustomImageDir;
        }
        [Inline]
        public static function set customImagePath( sPath : String ) : void
        {
            m_sCustomImageDir = sPath;
            m_sCustomImageDir = CPath.addRightSlash( m_sCustomImageDir );
        }

        [Inline]
        public final function isBlocked( f3DPosX : Number, f3DPosY : Number, f3DPosZ : Number,
                                      bConsider3DPosY : Boolean = true, boxRange : CAABBox2 = null ) : Boolean
        {
            if( m_theTerrainData == null ) return false;
            return m_theTerrainData.isBlocked( f3DPosX, f3DPosY, f3DPosZ, bConsider3DPosY, boxRange );
        }
        [Inline]
        public final function isBlockedGrid( iGridX : int, iGridY : int, boxRange : CAABBox2 = null ) : Boolean
        {
            if( m_theTerrainData == null ) return false;
            return m_theTerrainData.isBlockedGrid( iGridX, iGridY, boxRange );
        }
        [Inline]
        public final function isLineBlocked( f3DPosX1 : Number, f3DPosY1 : Number, f3DPosZ1 : Number,
                                         f3DPosX2 : Number, f3DPosY2 : Number, f3DPosZ2 : Number,
                                         bConsider3DPosY : Boolean = true, boxRange : CAABBox2 = null ) : Boolean
        {
            if( m_theTerrainData == null ) return false;
            return m_theTerrainData.isLineBlocked( f3DPosX1, f3DPosY1, f3DPosZ1, f3DPosX2, f3DPosY2, f3DPosZ2, bConsider3DPosY, boxRange );
        }

        [Inline]
        public final function getTerrainHeight( f3DPosX : Number, f3DPosZ : Number, fStepHeight : Number = -1.0 ) : Number
        {
            if( m_theTerrainData == null ) return 0.0;
            return m_theTerrainData.getTerrainHeight( f3DPosX, f3DPosZ, fStepHeight );
        }

        [Inline]
        public function get terrainData() : CTerrainData { return m_theTerrainData; }

        [Inline]
        public function get sceneInfo() : Object { return m_theSceneInfo; }
        [Inline]
        public function clearSceneInfo() : void { m_theSceneInfo = null; m_bKeepSceneInfo = false; }

        public override function get currentBound() : CAABBox2
        {
            if( m_bCurrentBoundDirty )
            {
                var bFirst : Boolean = true;
                for each( var layer : CSceneLayer in m_vectLayers )
                {
                    if( layer.currentBound != null )
                    {
                        if( bFirst )
                        {
                            if( m_theAABB == null ) m_theAABB = layer.currentBound.clone();
                            else m_theAABB.set( layer.currentBound );
                            bFirst = false;
                            m_bCurrentBoundDirty = false;
                        }
                        else m_theAABB.merge( layer.currentBound );
                    }
                }
            }

            return m_theAABB;
        }

        public override function update( fDeltaTime : Number ) : void
        {
            if( m_theMainCamera != null ) m_theMainCamera.update( fDeltaTime );

            for each( var layer : CSceneLayer in m_vectLayers )
            {
                layer.update( fDeltaTime );
            }

            super.update( fDeltaTime );
        }

		//
		//
        protected function _onLoadFinished( loader : CJsonLoader, idErrorCode : int ) : void
        {
            if( this.disposed ) return ;

            if( idErrorCode == 0 )
            {
                m_theResource = loader.createResource();
                if( m_theResource == null ) return;
                var theJson : Object = m_theResource.theObject;
                if( theJson == null )
                {
                    Foundation.Log.logErrorMsg( "Load Scene Failed: " + loader.filename );
                    return;
                }

                var iResult : int = 0;
                if( _loadFromSceneInfo( theJson ) == false )
                {
                    iResult = -2;
                    Foundation.Log.logErrorMsg( "CScene._onLoadFinished(): Error happened while parsing scene file: " + loader.filename );
                }
                else
                {
                    m_sFilename = loader.filename;
                    Foundation.Log.logMsg( "Scene loaded: " + m_sFilename );
                }

                // move camera to start point
                var orgFollowingTarget : CBaseObject = m_theMainCamera.followingTarget;
                m_theMainCamera.setFollowingTarget( m_theStartPointObject );
                m_theMainCamera.moveToTargetAtOnce();
                m_theMainCamera.setFollowingTarget( orgFollowingTarget );

                if( _loadSceneLayerImages( theJson ) == false )
                {
                    iResult = -3;
                    Foundation.Log.logErrorMsg( "CScene._onLoadFinished(): Error happened while loading scene background images: " + loader.filename );
                }

                if( m_bKeepSceneInfo ) m_theSceneInfo = theJson;
                else m_theSceneInfo = null;

                _setCurrentBoundDirty();
                if( m_fnOnLoadFinished != null ) m_fnOnLoadFinished( this, iResult );
            }
            else
            {
                if( m_fnOnLoadFinished != null ) m_fnOnLoadFinished( this, -999 );
            }
        }

        protected virtual function _loadFromSceneInfo( sceneInfo : Object ) : Boolean
		{
			if( _loadBasicSceneInfo( sceneInfo ) == false ) return false;
            if( _loadSceneLayers( sceneInfo, false ) == false ) return false;
            //if( _loadSceneLayerImages( sceneInfo ) == false ) return false; // load images later

			return true;
		}

		private function _loadBasicSceneInfo( sceneInfo : Object ) : Boolean
		{
			if( sceneInfo.hasOwnProperty( "name" ) == false )
			{
				Foundation.Log.logErrorMsg( "CScene._loadBasicSceneInfo(): Can not get 'name' param!" );
				return false;
			}
			else
			{
				m_sName = sceneInfo[ "name" ];
			}

            m_theTerrainData = new CTerrainData();
            if( m_theTerrainData.load( sceneInfo ) == false )
            {
                Foundation.Log.logErrorMsg( "CScene._loadBasicSceneInfo(): load terrain data failed!" );
                return false;
            }

			if( sceneInfo.hasOwnProperty( "startPoint" ) )
			{
				var startPointInfo : Object = sceneInfo[ "startPoint" ];
				m_theStartPoint = new CVector2( startPointInfo.x, startPointInfo.y );
                m_theStartPointObject = new CBaseObject( m_theRenderer );
                m_theStartPointObject.moveTo( m_theStartPoint.x, m_theStartPoint.y, 0.0 );
			}

			if( sceneInfo.hasOwnProperty( "cameraPairInfo" ) )
            {
                var aCameraAnchorPairs : Array = sceneInfo[ "cameraPairInfo" ];
                for each ( var cameraAnchorPair : Object in aCameraAnchorPairs )
                {
                    var thePair : Object = cameraAnchorPair.cameraPair;
                    var vCenter : CVector2 = new CVector2( thePair[0].x, thePair[0].y );
                    var vExt : CVector2 = new CVector2( thePair[0].width * 0.5, thePair[0].height * 0.5 );
                    var vOuterExt : CVector2 = new CVector2( thePair[1].width * 0.5, thePair[1].height * 0.5 );
                    m_theMainCamera.addCameraAnchor( vCenter, vExt, vOuterExt );
                }
            }

            if( sceneInfo.hasOwnProperty( "cameraMovableBox" ) )
            {
                var camMovableBox : Object = sceneInfo.cameraMovableBox;
                m_theMainCamera.sceneMovableBox = new CAABBox2( CVector2.ZERO );
                m_theMainCamera.sceneMovableBox.setCenterExtValue( camMovableBox.x, camMovableBox.y, camMovableBox.width * 0.5, camMovableBox.height * 0.5 );
            }

			return true;
		}

		private function _loadSceneLayers( sceneInfo : Object, bLoadImages : Boolean ) : Boolean
		{
			var layerInfo : Object;

			for( var i : int = 0; i < sceneInfo.layers.length; i++ )
			{
				layerInfo = sceneInfo.layers[ i ];

                var iLayerID : int;
                if( layerInfo.hasOwnProperty( "id" ) ) iLayerID = layerInfo.id;
                else if( layerInfo.hasOwnProperty( "index" ) ) iLayerID = layerInfo.index; // for backward compatibility
                else
                {
                    Foundation.Log.logErrorMsg( "CScene._loadSceneLayers(): Can not get 'id' or 'index' param!" );
                    return false;
                }

                var camera : CSceneLayerCamera = new CSceneLayerCamera();
                camera.depth = i;
                camera.cullingMask = 1 << i;
                m_theRenderer.addCamera( camera );

                var layer : CSceneLayer = new CSceneLayer( i, iLayerID, this, camera );
				layer.layer = i + 1;

				if( layerInfo.isTouchable || layerInfo.isTouch ) // means a touchable layer where the gameplay interacts happened
				{
                    if( m_iEntityLayerIndex != -1 )
                    {
                        Foundation.Log.logErrorMsg( "There is only 1 touchable layer allowed in a scene...!" );
                        return false;
                    }
                    else m_iEntityLayerIndex = i;
				}
				else
				{
					layer.touchable = false;
					layer.useHandCursor = false;
				}

				/*if( layerInfo.hasOwnProperty( "renderQueueID" ) )
				{
					layer.inheritRenderQueue = false;
					layer.renderQueueID = layerInfo.renderQueueID;
				}*/

				this.addChild( layer );
				m_vectLayers.push( layer );
                m_theMainCamera.addSubCamera( camera );
				m_vectLayerCameras.push(camera);

                if( layer.load( layerInfo, bLoadImages ) == false ) return false;
			}

            return true;
		}

        private function _loadSceneLayerImages( sceneInfo : Object ) : Boolean
        {
            var layerInfo : Object;

            for( var i : int = 0; i < sceneInfo.layers.length; i++ )
            {
                layerInfo = sceneInfo.layers[ i ];
                if( m_vectLayers[ i ].loadBackgroundImages( layerInfo, m_theMainCamera ) == false ) return false;
            }
            return true;
        }

        //
        [Inline]
        final public function _setCurrentBoundDirty() : void
        {
            m_bCurrentBoundDirty = true;
        }


        //
		//
        protected static var m_sCustomImageDir : String = null;

		protected var m_sFilename : String = null;
		protected var m_sName : String = null;
        protected var m_sDir : String = null;

        protected var m_theTerrainData : CTerrainData = null;
		protected var m_theStartPoint : CVector2 = null;
        protected var m_theStartPointObject : CBaseObject = null;

		protected var m_vectLayers : Vector.<CSceneLayer> = new Vector.<CSceneLayer>();
        protected var m_theAABB : CAABBox2 = null;
		protected var m_iEntityLayerIndex : int = -1;
        protected var m_fnOnLoadFinished : Function = null;

		protected var m_vectLayerCameras : Vector.<CSceneLayerCamera> = new Vector.<CSceneLayerCamera>();
		protected var m_theMainCamera : CCamera = null;

        protected var m_theSceneInfo : Object = null;
        protected var m_bKeepSceneInfo : Boolean = false;
        protected var m_bCurrentBoundDirty : Boolean = true;

        protected var m_theResource : CResource = null;
	}
}
