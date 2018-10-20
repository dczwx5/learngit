//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/5/20
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Scene
{

	import QFLib.Foundation;
	import QFLib.Foundation.CPath;
	import QFLib.Foundation.CSet;
	import QFLib.Graphics.RenderCore.CBaseObject;
	import QFLib.Graphics.RenderCore.CImageObject;
import QFLib.Math.CAABBox2;
	import QFLib.Math.CMath;
	import QFLib.Math.CVector2;
	import QFLib.Memory.CResourcePool;
	import QFLib.Memory.CResourcePools;
	import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.CXmlLoader;
import QFLib.ResourceLoader.ELoadingPriority;
	import QFLib.Utils.Quality;

	import flash.geom.Point;

	public class CSceneLayer extends CBaseObject
	{
        public function CSceneLayer( iLayerIndex : int, iLayerID : int, theScene : CSceneObject, theCamera : CSceneLayerCamera )
		{
            super( theScene.renderer );

            m_iLayerIndex = iLayerIndex;
            m_iLayerID = iLayerID;
            m_theSceneObjectRef = theScene;

            m_theCamera = theCamera;
            this.usingCamera = theCamera;
        }

        public override function dispose() : void
        {
            if ( this.disposed ) return;
            if( m_theResourcePools != null )
            {
                m_theResourcePools.dispose();
                m_theResourcePools = null;
            }

            if( m_setImages != null )
            {
                for each( var img : CImageObject in m_setImages )
                {
                    removeChild( img );
                    img.dispose();
                }
                m_setImages = null;
            }

            if( m_theCamera != null )
            {
                this.usingCamera = null;
                m_theCamera = null;
            }

            super.dispose();
        }

        // try getting all used resources
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;
            for each( var img : CImageObject in m_setImages )
            {
                iCount += img.retrieveAllResources( vResources, iBeginIndex + iCount );
            }

            return iCount;
        }

        public function get index() : int { return m_iLayerIndex; }
        public function get id() : int { return m_iLayerID; }
        public function get sceneRef() : CSceneObject { return m_theSceneObjectRef; }
        public function get camera () : CSceneLayerCamera { return m_theCamera; }

        public function load( layerInfo : Object, bLoadImages : Boolean ) : Boolean
		{
            if( layerInfo.hasOwnProperty( "scrollSpeed" ) )
            {
                m_theCamera.scrollSpeedX = layerInfo[ "scrollSpeed" ].x / 100.0;
                m_theCamera.scrollSpeedY = layerInfo[ "scrollSpeed" ].y / 100.0;
            }
            else if( layerInfo.hasOwnProperty( "ssx" ) && layerInfo.hasOwnProperty( "ssy" ) )
            {
                m_theCamera.scrollSpeedX = parseFloat( layerInfo["ssx"] ) / 100;
                m_theCamera.scrollSpeedY = parseFloat( layerInfo["ssy"] ) / 100;
            }
            else
            {
                Foundation.Log.logErrorMsg( "CSceneLayer.load(): Can not get 'scrollSpeed' param!" );
                return false;
            }

            visible = m_bInitiallyVisible = layerInfo.hasOwnProperty( "visible" ) ? layerInfo[ "visible" ] : true;

            if( layerInfo.hasOwnProperty( "perspectiveImages" ) )
            {
                m_fPerspectiveFactor = layerInfo[ "perspectiveImages" ].factor;
                m_fPerspectiveCenter = layerInfo[ "perspectiveImages" ].center;
            }

            if( layerInfo.hasOwnProperty( "rollSpeed" ) )
            {
                m_fRollSpeedX = layerInfo[ "rollSpeed" ].x;
                m_fRollSpeedY = layerInfo[ "rollSpeed" ].y;
                if( layerInfo[ "rollSpeed" ].hasOwnProperty( "width" ) ) m_fRollWidth = layerInfo[ "rollSpeed" ].width;
                if( layerInfo[ "rollSpeed" ].hasOwnProperty( "height" ) ) m_fRollHeight = layerInfo[ "rollSpeed" ].height;
                if( layerInfo[ "rollSpeed" ].hasOwnProperty( "throttle" ) )
                {
                    m_fCurrentRollingThrottle = layerInfo[ "rollSpeed" ].throttle;
                    m_fRollingThrottle = m_fCurrentRollingThrottle;
                }
            }

            if( bLoadImages )
            {
                if( loadBackgroundImages( layerInfo ) == false ) return false;
            }
            return true;
		}


        public function loadBackgroundImages( layerInfo : Object, theMainCamera : CCamera = null ) : Boolean
        {
            var aBackgroundInfos : Array = layerInfo[ "bg" ];
            if( aBackgroundInfos == null || aBackgroundInfos.length == 0 ) return true;

            m_iTotalImages = aBackgroundInfos.length;
            var imageName : String;
            for( var i : int = 0; i < m_iTotalImages; i++ )
            {
                var theBackgroundInfo : Object = aBackgroundInfos[ i ];
                if( theBackgroundInfo.hasOwnProperty( "texture" ) == false ) continue;
                if( theBackgroundInfo.texture == null || theBackgroundInfo.texture == "" ) continue;

                var iLoadingPriority : int = ELoadingPriority.CRITICAL;
                if( theMainCamera != null )
                {
                    var boundObject : Object = theBackgroundInfo.bound;
                    var theBound : CAABBox2 = CAABBox2.ZERO;
                    if( boundObject != null ) theBound.setCenterExtValue( boundObject.center.x, boundObject.center.y, boundObject.width * 0.5, boundObject.height * 0.5 );
                    if(theMainCamera.isCollided( theBound, m_iLayerIndex ) == false)
                    {
                        iLoadingPriority = ELoadingPriority.HIGH;
                    }

                    /*
                    var thePosition : Point = new Point( theBackgroundInfo.position.x, theBackgroundInfo.position.y );
                    if( theMainCamera.isCollidedPointValue( thePosition.x, thePosition.y, m_iLayerIndex ) == false )
                    {
                        iLoadingPriority = ELoadingPriority.HIGH;
                        //continue;
                    }*/
                }

                var sBackgroundImagePath : String;
                if( CSceneObject.customImagePath != null ) sBackgroundImagePath = CSceneObject.customImagePath;
                else sBackgroundImagePath = m_theSceneObjectRef.scenePath;

                var theImage : CImageObject = new CImageObject( m_theRenderer );

                var vTextureFilenames : Vector.<String>;
                imageName = CPath.name( theBackgroundInfo.texture );
                if(Quality.isLowQualityOfRender)
                {
                    vTextureFilenames = new Vector.<String>( 2 );
                    if(Quality.knifeImageManualSwitch)
                    {
                        vTextureFilenames[ 0 ] = sBackgroundImagePath + "png_ko\\" + imageName + "_ko.png";
                        vTextureFilenames[ 1 ] = sBackgroundImagePath + imageName + ".png";
                    }
                    else
                    {
                        vTextureFilenames[ 0 ] = sBackgroundImagePath + "png\\" + imageName + ".png";
                        vTextureFilenames[ 1 ] = sBackgroundImagePath + imageName + ".png";
                    }
                }
                else if(!m_bLoadTextureAtlas)
                {
                    vTextureFilenames = new Vector.<String>( 3 );
                    vTextureFilenames[ 0 ] = sBackgroundImagePath + "atf\\" + imageName + ".atf";
                    vTextureFilenames[ 1 ] = sBackgroundImagePath + "png\\" + imageName + ".png";
                    vTextureFilenames[ 2 ] = sBackgroundImagePath + imageName + ".png";
                }

                if (m_bLoadTextureAtlas) {
                    var atlasPath : String = sBackgroundImagePath + "atlas\\" + "atlas.xml";
                    CResourceLoaders.instance().startLoadFile( atlasPath, _onAtlasXmlLoadFinished, null, iLoadingPriority, false, false, null, imageName, theImage, atlasPath, theBackgroundInfo );
                }
                else
                {
                    _setupLayerImage( theBackgroundInfo, theImage );
                    theImage.loadFileFromPathSequence( vTextureFilenames, _onImageLoadFinished, iLoadingPriority );
                }
                function _onAtlasXmlLoadFinished( loader : CXmlLoader, idErrorCode : int ) : void
                {
                    if( idErrorCode != 0 ) return;

                    var imageNameSpec : String = loader.arguments[0];
                    var image : CImageObject = loader.arguments[1];
                    var atlas : String = loader.arguments[2];
                    var backInfo : Object = loader.arguments[3];
                    var resource : CResource = loader.createResource();
                    var theXml : Object = resource.theObject as XML;
                    var listTextureAtlas : XMLList = theXml.descendants( "TextureAtlas" );
                    var iNumTextureAtlases : int = listTextureAtlas.length();

                    var subTexture:XML;
                    if( iNumTextureAtlases == 0 )
                    {
                        resource.dispose();
                        resource = null;
                    }
                    else
                    {
                        for (var i : int = 0; i < iNumTextureAtlases; ++i)
                        {
                            for each ( subTexture in listTextureAtlas[i].SubTexture )
                            {
                                if (subTexture.@name == imageNameSpec)
                                {
                                    vTextureFilenames = new Vector.<String>(2);

                                    var path : String = listTextureAtlas[i ].@imagePath;
                                    vTextureFilenames[ 0 ] = sBackgroundImagePath + "atlas\\" +  path.replace(".png", ".atf");
                                    vTextureFilenames[ 1 ] = sBackgroundImagePath + "atlas\\" +  path;
                                    _setupLayerImage( backInfo, image );

                                    image.loadTextureAtlasFromPathSequence(vTextureFilenames, imageNameSpec,
                                            listTextureAtlas[i], atlas, _onImageLoadFinished, iLoadingPriority);
                                    return;
                                }
                            }
                        }
                    }
//
//                    function onTextureAtlasLoadFinished( loader : CTextureAtlasLoader, idErrorCode : int ) : void
//                    {
//                        if( idErrorCode != 0 )
//                        {
//                            Foundation.Log.logErrorMsg( "onTextureLoadFinished(): Can not load texture: " + loader.loadingFilename );
//                            return ;
//
//                            var theTextureAtlasResource : CResource = loader.createResource();
//                            if( theTextureAtlasResource == null )
//                            {
//                                Foundation.Log.logErrorMsg( "onTextureAtlasLoadFinished(): cannot get texture atlas's data( null): " + loader.loadingFilename );
//                                return ;
//                            }
//
//                            var tex : Texture = (theTextureAtlasResource as TextureAtlas).getTexture(imageName);
//                        }
//                    }

                }


            }

            return true;
        }

        public override function get currentBound() : CAABBox2
        {
            if( m_bCurrentBoundDirty )
            {
                var bFirst : Boolean = true;
                for each( var image : CImageObject in m_setImages )
                {
                    if( image.currentBound != null )
                    {
                        if( bFirst )
                        {
                            if( m_theAABB == null ) m_theAABB = image.currentGlobalBound.clone();
                            else m_theAABB.set( image.currentGlobalBound );
                            bFirst = false;
                        }
                        else m_theAABB.merge( image.currentGlobalBound );
                    }
                }

                m_bCurrentBoundDirty = false;
            }

            return m_theAABB;
        }

        public override function set opaque( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;

            for each( var img : CImageObject in m_setImages )
            {
                img.opaque = fOpaque;
            }
        }

        public override function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            for each( var img : CImageObject in m_setImages )
            {
                img.setColor( r, g, b, alpha, masking );
            }
        }

        //
        // start / stop / control the rolling effect
        // param fToThrottle: 0.0 - 1.0(stop - full)
        // param fTimePeriod: speed up / down time
        //
        [Inline]
        final public function setRollingThrottle( fToThrottle : Number, fTimePeriod : Number ) : void
        {
            m_fRollingThrottle = fToThrottle;
            m_fRollingThrottleTime = fTimePeriod;
        }
        [Inline]
        final public function get rollingThrottle() : Number
        {
            return m_fRollingThrottle;
        }

        public override function update( fDeltaTime : Number ) : void
        {
            super.update( fDeltaTime );
            _adjustImagesPerspective();
            _adjustImagesRolling( fDeltaTime );
        }

        /*public function sortLayerObjects() : void
        {
            var obj : CBaseObject;
            for each( obj in m_vStaticObjects ) removeChild( obj );

            m_vStaticObjects.sort( function ( bg1 : CBaseObject, bg2 : CBaseObject ) : int
            {
                // the smaller z the later drawing
                if( bg1.position.z < bg2.position.z ) return 1;
                else if( bg1.position.z > bg2.position.z ) return -1;
                else
                {
                    // the bigger y the later drawing
                    if( bg1.y > bg2.y ) return 1;
                    else if( bg1.y < bg2.y ) return -1;
                    else
                    {
                        // the bigger x the later drawing
                        return bg1.x - bg2.x;
                    }
                }
            });

            for each( obj in m_vStaticObjects ) addChild( obj );
        }*/

        /*public function hitTest( localPoint : Point, forTouch : Boolean = false ) : DisplayObject
         {
             if( _camera )
             {
                 _camera.screenToWorld( localPoint );
             }
             return m_theDisplayNode.hitTest( localPoint, forTouch );
         }*/

        private function _onImageLoadFinished( theImage : CImageObject, idErrorCode : int ) : void
        {
            if( this.disposed )
            {
                theImage.dispose();
                return;
            }

            if( idErrorCode != 0 )
            {
                Foundation.Log.logErrorMsg( "Image object load failed: " + theImage.filename );
                return ;
            }

            // dispose immediately after unreferenced
            if (theImage.textureResource != null)
                theImage.textureResource.unreferencedTimeInterval = 0.0;
            else
            {
                theImage.textureAtlasResource.unreferencedTimeInterval = 0.0;
            }

            _addLoadedImage( theImage );
            if( m_setImages.length == m_iTotalImages )
            {
                _setCurrentBoundDirty();

                if( m_fPerspectiveFactor != 0.0 ) _prepareImageVerticesForPerspectiveEffect();
                else if( m_fRollSpeedX != 0.0 || m_fRollSpeedY != 0.0 ) _prepareExtraImagesForRollingEffect();
            }
        }

        private function _setupLayerImage( theBackgroundInfo : Object, img : CImageObject ) : void
        {
            var bVisible : Boolean = theBackgroundInfo.visible;
            var theAnchor : Point = new Point( theBackgroundInfo.anchor.x, theBackgroundInfo.anchor.y );
            var thePosition : Point = new Point( theBackgroundInfo.position.x, theBackgroundInfo.position.y );
            var theScale : Point = new Point( theBackgroundInfo.scale.x, theBackgroundInfo.scale.y );
            var fRotation : Number = theBackgroundInfo.rotation;

            // negate the z because of the opposite of the Z axis in between Unity and Flash
            img.setPosition( ( -theAnchor.x * theScale.x ) + thePosition.x, ( -theAnchor.y * theScale.y ) + thePosition.y, -theBackgroundInfo.position.z );

            if(Quality.isLowQualityOfRender && Quality.knifeImageManualSwitch)
            {
                img.setScale( theScale.x*2, theScale.y*2 );
            }
            else
            {
                img.setScale( theScale.x, theScale.y );
            }
            img.setRotation( CMath.degToRad( fRotation ) );
            img.visible = bVisible;
        }

        private function _addLoadedImage( img : CImageObject ) : void
        {
            m_setImages.add( img );
            addChild( img );
        }

        private function _removeLoadedImage( img : CImageObject ) : void
        {
            removeChild( img );
            m_setImages.remove( img );
        }

        private function _prepareImageVerticesForPerspectiveEffect() : void
        {
            if( m_setImages == null || m_setImages.length == 0 ) return ;

            m_vImageVertices = new Vector.<CVector2>( m_setImages.length * 4 );

            var i : int = 0;
            for each( var img : CImageObject in m_setImages.length )
            {
                m_vImageVertices[ i * 4 ] = img.getVertexPosition( 0 );
                m_vImageVertices[ i * 4 + 1 ] = img.getVertexPosition( 1 );
                m_vImageVertices[ i * 4 + 2 ] = img.getVertexPosition( 2 );
                m_vImageVertices[ i * 4 + 3 ] = img.getVertexPosition( 3 );
                i++;
            }
        }

        private function _adjustImagesPerspective() : void
        {
            if( m_vImageVertices == null ) return ;

            var fShift : Number = ( m_theCamera.cameraCenterX - m_fPerspectiveCenter ) * m_fPerspectiveFactor;

            var i : int = 0;
            for each( var img : CImageObject in m_setImages.length )
            {
                m_vTempPoint = img.getVertexPosition( 2, m_vTempPoint );
                m_vTempPoint.x = m_vImageVertices[ i * 4 + 2 ].x - fShift * m_vTempPoint.y / 1024.0;
                img.setVertexPosition( 2, m_vTempPoint );

                m_vTempPoint = img.getVertexPosition( 3, m_vTempPoint );
                m_vTempPoint.x = m_vImageVertices[ i * 4 + 3 ].x - fShift * m_vTempPoint.y / 1024.0;
                img.setVertexPosition( 3, m_vTempPoint );
                i++;
            }
        }

        public function _setCurrentBoundDirty() : void
        {
            m_bCurrentBoundDirty = true;
            m_theSceneObjectRef._setCurrentBoundDirty();
        }

        private function _prepareExtraImagesForRollingEffect() : void
        {
            if( m_setImages.length == 0 ) return ;

            // retrieve maximum width and height of all images
            m_fMaximumImageWidth = m_fMaximumImageHeight = 0.0;
            for each( var img : CImageObject in m_setImages )
            {
                if( img.width > m_fMaximumImageWidth ) m_fMaximumImageWidth = img.width;
                if( img.height > m_fMaximumImageHeight ) m_fMaximumImageHeight = img.height;
            }

            //
            var theOriginalAABB : CAABBox2 = this.currentBound;
            if( m_fRollWidth == 0 ) m_fRollWidth = theOriginalAABB.width;
            if( m_fRollHeight == 0 ) m_fRollHeight = theOriginalAABB.height;
            m_theRollBox = new CAABBox2( CVector2.ZERO );
            m_theRollBox.setValue( theOriginalAABB.min.x, theOriginalAABB.min.y, theOriginalAABB.min.x + m_fRollWidth, theOriginalAABB.min.y + m_fRollHeight );

            m_vImagesToBeRemoved = new Vector.<CImageObject>();
            m_vClonedImagesToBeAdded = new Vector.<CImageObject>();
            m_theResourcePools = new CResourcePools();

            // retrieve the outside box of X-axis due to the rolling direction
            var fMaximumRollX : Number = ( m_fRollSpeedX > 0.0 ) ? 1.0 : ( ( m_fRollSpeedX < 0.0 ) ? -1.0 : 0.0 );
            fMaximumRollX *= m_fMaximumImageWidth;
            if( fMaximumRollX != 0.0 )
            {
                m_theRollOutsideBoxX = new CAABBox2( CVector2.ZERO );
                if( fMaximumRollX < 0.0 ) m_theRollOutsideBoxX.setValue( m_theRollBox.min.x + fMaximumRollX, m_theRollBox.min.y, m_theRollBox.min.x, m_theRollBox.max.y );
                else if( fMaximumRollX > 0.0 ) m_theRollOutsideBoxX.setValue( m_theRollBox.max.x, m_theRollBox.min.y, m_theRollBox.max.x + fMaximumRollX, m_theRollBox.max.y );

                m_setImagesCollidedWithRollOutsideBoxX = new CSet();
            }

            // retrieve the outside box of Y-axis due to the rolling direction
            var fMaximumRollY : Number = ( m_fRollSpeedY > 0.0 ) ? 1.0 : ( ( m_fRollSpeedY < 0.0 ) ? -1.0 : 0.0 );
            fMaximumRollY *= m_fMaximumImageHeight;
            if( fMaximumRollY != 0.0 )
            {
                m_theRollOutsideBoxY = new CAABBox2( CVector2.ZERO );
                if( fMaximumRollY < 0.0 ) m_theRollOutsideBoxY.setValue( m_theRollBox.min.x, m_theRollBox.min.y + fMaximumRollY, m_theRollBox.max.x, m_theRollBox.min.y );
                else if( fMaximumRollY > 0.0 ) m_theRollOutsideBoxY.setValue( m_theRollBox.min.x, m_theRollBox.max.y, m_theRollBox.max.x, m_theRollBox.max.y + fMaximumRollY );

                m_setImagesCollidedWithRollOutsideBoxY = new CSet();
            }
        }

        private function _adjustImagesRolling( fDeltaTime : Number ) : void
        {
            if( m_theRollBox == null ) return ;

            if( m_fRollingThrottleTime >= 0.0 )
            {
                if( fDeltaTime < m_fRollingThrottleTime )
                {
                    var fThrottlePerSec : Number = ( m_fRollingThrottle - m_fCurrentRollingThrottle ) / m_fRollingThrottleTime;
                    m_fCurrentRollingThrottle += fThrottlePerSec * fDeltaTime;
                }
                else m_fCurrentRollingThrottle = m_fRollingThrottle;

                m_fRollingThrottleTime -= fDeltaTime;
                if( m_fRollingThrottleTime <= 0.0 )
                {
                    m_fRollingThrottleTime = -1.0;
                    m_fCurrentRollingThrottle = m_fRollingThrottle;
                }
            }

            var fRollSpeedX : Number = m_fRollSpeedX * fDeltaTime * m_fCurrentRollingThrottle;
            if( fRollSpeedX > m_fMaximumImageWidth ) fRollSpeedX = m_fMaximumImageWidth;
            else if( fRollSpeedX < -m_fMaximumImageWidth ) fRollSpeedX = -m_fMaximumImageWidth;

            var fRollSpeedY : Number = m_fRollSpeedY * fDeltaTime * m_fCurrentRollingThrottle;
            if( fRollSpeedY > m_fMaximumImageHeight ) fRollSpeedY = m_fMaximumImageHeight;
            else if( fRollSpeedY < -m_fMaximumImageHeight ) fRollSpeedY = -m_fMaximumImageHeight;

            var fRollingWidth : Number = ( m_fRollSpeedX > 0.0 ) ? 1.0 : ( ( m_fRollSpeedX < 0.0 ) ? -1.0 : 0.0 );
            fRollingWidth *= ( m_fRollWidth - 0.5 ); // 0.5: avoid boundary issue
            var fRollingHeight : Number = ( m_fRollSpeedY > 0.0 ) ? 1.0 : ( ( m_fRollSpeedY < 0.0 ) ? -1.0 : 0.0 );
            fRollingHeight *= ( m_fRollHeight - 0.5 ); // 0.5: avoid boundary issue

            var theNewImage : CImageObject;
            var img : CImageObject;
            var imgAABB : CAABBox2;
            for each( img in m_setImages )
            {
                img.move( fRollSpeedX, fRollSpeedY, 0.0 );

                imgAABB = img.currentGlobalBound;
                if( m_theRollBox.isContained( imgAABB ) ) continue;
                else if( m_theRollBox.isCollided( imgAABB ) == false )
                {
                    if(m_setImagesCollidedWithRollOutsideBoxX != null && m_setImagesCollidedWithRollOutsideBoxY != null)
                    {
                        if( m_setImagesCollidedWithRollOutsideBoxX.isExisted( img ) || m_setImagesCollidedWithRollOutsideBoxY.isExisted( img ) )
                        {
                            m_vImagesToBeRemoved.push( img );
                            continue;
                        }
                    }
                }

                if( m_theRollOutsideBoxX != null )
                {
                    if( m_setImagesCollidedWithRollOutsideBoxX.isExisted( img ) == false && m_theRollOutsideBoxX.isCollided( imgAABB ) )
                    {
                        theNewImage = _cloneNewImage( img, -fRollingWidth, 0.0 );
                        if( theNewImage != null ) m_vClonedImagesToBeAdded.push( theNewImage );

                        m_setImagesCollidedWithRollOutsideBoxX.add( img );
                    }
                }
                if( m_theRollOutsideBoxY != null )
                {
                    if( m_setImagesCollidedWithRollOutsideBoxY.isExisted( img ) == false && m_theRollOutsideBoxY.isCollided( imgAABB ) )
                    {
                        theNewImage = _cloneNewImage( img, 0.0, -fRollingHeight );
                        if( theNewImage != null ) m_vClonedImagesToBeAdded.push( theNewImage );

                        m_setImagesCollidedWithRollOutsideBoxY.add( img );
                    }
                }
            }

            // remove images
            var thePool : CResourcePool;
            for each( img in m_vImagesToBeRemoved )
            {
                _removeLoadedImage( img );
                if( m_setImagesCollidedWithRollOutsideBoxX != null ) m_setImagesCollidedWithRollOutsideBoxX.remove( img );
                if( m_setImagesCollidedWithRollOutsideBoxY != null ) m_setImagesCollidedWithRollOutsideBoxY.remove( img );

                thePool = m_theResourcePools.getPool( img.filename );
                if( thePool == null )
                {
                    thePool = new CResourcePool( img.filename, null );
                    m_theResourcePools.addPool( img.filename, thePool );
                }
                thePool.recycle( img );
            }
            m_vImagesToBeRemoved.length = 0;

            // clone images if there's any
            for( var i : int = 0; i < m_vClonedImagesToBeAdded.length; i++ )
            {
                _addLoadedImage( m_vClonedImagesToBeAdded[ i ] );
            }
            m_vClonedImagesToBeAdded.length = 0;

            _setCurrentBoundDirty();
            m_theResourcePools.update( fDeltaTime );
        }

        private function _cloneNewImage( theImage : CImageObject, fMoveX : Number, fMoveY : Number ) : CImageObject
        {
            m_tempAABB.set( theImage.currentGlobalBound );
            m_tempAABB.move( fMoveX, fMoveY );

            var img : CImageObject;
            for each( img in m_setImages )
            {
                if( theImage.filename == img.filename && m_tempAABB.equalsWithinError( img.currentGlobalBound ) ) return null; // need not to clone a new image cuz it is already cloned
            }
            for each( img in m_vClonedImagesToBeAdded )
            {
                if( theImage.filename == img.filename && m_tempAABB.equalsWithinError( img.currentGlobalBound ) ) return null; // need not to clone a new image cuz it is already cloned
            }

            var theNewImage : CImageObject = null;
            var thePool : CResourcePool = m_theResourcePools.getPool( theImage.filename );
            if( thePool != null ) theNewImage = thePool.allocate() as CImageObject;

            if( theNewImage == null ) theNewImage = theImage.clone() as CImageObject;
            else theNewImage.cloneFrom( theImage );

            theNewImage.move( fMoveX, fMoveY, 0.0 );
            return theNewImage;
        }

        //
        //
        private var m_setImages : CSet = new CSet();
        private var m_theCamera : CSceneLayerCamera = null;

        private var m_theSceneObjectRef : CSceneObject;
        private var m_iLayerIndex : int;
        private var m_iLayerID : int;
        private var m_iTotalImages : int = 0;

        private var m_vImageVertices : Vector.<CVector2> = null;
        private var m_fPerspectiveCenter : Number = 0.0;
        private var m_fPerspectiveFactor : Number = 0.0;

        private var m_vTempPoint : CVector2 = new CVector2();
        private var m_tempAABB : CAABBox2 = new CAABBox2( CVector2.ZERO );

        private var m_fRollSpeedX : Number = 0.0;
        private var m_fRollSpeedY : Number = 0.0;
        private var m_fRollWidth : Number = 0.0;
        private var m_fRollHeight : Number = 0.0;
        private var m_fMaximumImageWidth : Number = 0.0;
        private var m_fMaximumImageHeight : Number = 0.0;
        private var m_theRollBox : CAABBox2 = null;
        private var m_theRollOutsideBoxX : CAABBox2 = null;
        private var m_theRollOutsideBoxY : CAABBox2 = null;
        private var m_setImagesCollidedWithRollOutsideBoxX : CSet = null;
        private var m_setImagesCollidedWithRollOutsideBoxY : CSet = null;
        private var m_vImagesToBeRemoved : Vector.<CImageObject> = null;
        private var m_vClonedImagesToBeAdded : Vector.<CImageObject> = null;
        private var m_theResourcePools : CResourcePools = null;

        private var m_fCurrentRollingThrottle : Number = 0;
        private var m_fRollingThrottle : Number = 0; // 0.0 - 1.0
        private var m_fRollingThrottleTime : Number = -1.0;

        protected var m_theAABB : CAABBox2 = null;
        protected var m_bCurrentBoundDirty : Boolean = true;

        private var m_bInitiallyVisible : Boolean = true;

        public static var m_bLoadTextureAtlas : Boolean = false;//是否加载场景图集的开关
    }
}
