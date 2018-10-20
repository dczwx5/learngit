package QFLib.Graphics.RenderCore
{
    import QFLib.Foundation;
    import QFLib.Foundation.CPath;
import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.display.Image;
    import QFLib.Graphics.RenderCore.starling.textures.SubTexture;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
import QFLib.Graphics.RenderCore.starling.textures.TextureAtlas;
import QFLib.Math.CAABBox2;
    import QFLib.Math.CMath;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.CBaseLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

import flash.geom.Point;

public class CImageObject extends CBaseObject
	{
        public function CImageObject( theRenderer : CRenderer, bCenterAnchor : Boolean = false )
        {
            super( theRenderer );
            m_bCenterAnchor = bCenterAnchor;
        }

        public override function dispose() : void
        {
            if( m_theTextureResource != null )
            {
                m_theTextureResource.dispose();
                m_theTextureResource = null;
            }
            if (m_theTextureAtlasResource != null)
            {
                m_theTextureAtlasResource.dispose();
                m_theTextureAtlasResource = null;
            }
            if( m_theImage != null )
            {
                m_theDisplayNode.removeChild( m_theImage );
                m_theImage.dispose();
                m_theImage = null;
            }

            m_fnOnLoadFinished = null;
            super.dispose();
        }

        // try getting all used resources
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;
            if( m_theTextureResource != null )
            {
                if( vResources != null )
                {
                    vResources[ iBeginIndex + iCount ] = m_theTextureResource;
                }
                iCount++;
            }
            if (m_theTextureAtlasResource != null)
            {
                if( vResources != null )
                {
                    vResources[ iBeginIndex + iCount ] = m_theTextureAtlasResource;
                }
                iCount++;
            }

            return iCount;
        }

        //
        // callback: function fnOnLoadFinished( theSprite : CSpriteObject, iResult : int ) : void
        //
        public virtual function loadFile( sFilename : String, fnOnLoadFinished : Function = null,
                                             iPriority : int = ELoadingPriority.NORMAL ) : void
        {
            var vFilenames : Vector.<String> = new Vector.<String>( 3 );
            vFilenames[ 0 ] = CPath.driverDirName( sFilename ) + ".atf";
            vFilenames[ 1 ] = CPath.driverDirName( sFilename ) + ".png";
            vFilenames[ 2 ] = CPath.driverDirName( sFilename ) + ".jpg";

            loadFileFromPathSequence( vFilenames, fnOnLoadFinished, iPriority );
        }
        public virtual function loadFileFromPathSequence( vFilenames : Vector.<String>, fnOnLoadFinished : Function = null,
                                                             iPriority : int = ELoadingPriority.NORMAL ) : void
        {
            m_fnOnLoadFinished = fnOnLoadFinished;
            CResourceLoaders.instance().startLoadFileFromPathSequence( vFilenames, _onLoadFinished, CTextureLoader.NAME, iPriority );
        }

        public virtual function loadTextureAtlasFromPathSequence( vFilenames : Vector.<String>, imageName :String,xml :XML, atlasUrl : String = null
                                                                     , fnOnLoadFinished : Function = null, iPriority : int = ELoadingPriority.NORMAL) : void
        {
            m_fnOnLoadFinished = fnOnLoadFinished;
            CResourceLoaders.instance().startLoadFileFromPathSequence( vFilenames, _onLoadFinished, CTextureAtlasLoader.NAME, iPriority, false,
                                                                        false, null, 0, xml, atlasUrl, imageName);
        }

        public override function clone() : CBaseObject
        {
            var theImageObject : CImageObject = new CImageObject( m_theRenderer, m_bCenterAnchor );
            theImageObject.cloneFrom( this );
            return theImageObject;
        }
        public override function cloneFrom( srcBaseObject : CBaseObject ) : void
        {
            super.cloneFrom( srcBaseObject );

            var srcImageObject : CImageObject = srcBaseObject as CImageObject;
            if( this.m_theTextureResource == srcImageObject.m_theTextureResource &&
                this.m_bCenterAnchor == srcImageObject.m_bCenterAnchor &&
                this.width == srcImageObject.width && this.height == srcImageObject.height &&
                this.m_theTextureAtlasResource == srcImageObject.m_theTextureAtlasResource)
            {
                return;
            }
            else
            {
                this.m_bCenterAnchor = srcImageObject.m_bCenterAnchor;
                this.m_sFilename = srcImageObject.m_sFilename;
                if( this.m_theTextureResource != null )
                {
                    this.m_theTextureResource.dispose();
                    this.m_theTextureResource = null;
                }

                if ( this.m_theTextureAtlasResource != null)
                {
                    this.m_theTextureAtlasResource.dispose();
                    this.m_theTextureAtlasResource = null;
                }

                if( srcImageObject.m_theTextureResource != null )
                {
                    if (srcImageObject.m_theTextureAtlasResource != null) {
                        this.m_theTextureAtlasResource = srcImageObject.m_theTextureAtlasResource.clone();
                        this._createImage( (this.m_theTextureAtlasResource.theObject as TextureAtlas).getTexture(CPath.name(m_sFilename)) );
                    }
                    else
                    {
                        this.m_theTextureResource = srcImageObject.m_theTextureResource.clone();
                        this._createImage( this.m_theTextureResource.theObject as Texture );
                    }
                }
                else this.createEmpty( srcImageObject.width, srcImageObject.height );

                this.UVAnimationEnable = srcImageObject.UVAnimationEnable;
                if(srcImageObject.UVAnimationEnable)
                {
                    this.setUVAnimationVelocity(srcImageObject.m_velocityX, srcImageObject.m_velocityY);
                    this.setUVAnimationTiling(srcImageObject.m_tilingX, srcImageObject.m_tilingY, srcImageObject.m_UVOffsetX, srcImageObject.m_UVOffsetY);
                    this.setUVAnimationMargin(srcImageObject.m_UVmarginX, srcImageObject.m_UVmarginY);
                }
                this._setCurrentBoundDirty();
            }
        }

        public function setTexCoords( iVertexID : int, vCoords : CVector2 ) : void
        {
            if( m_theImage != null )
            {
                m_theImage.setTexCoordsTo( iVertexID,  vCoords.x, vCoords.y );
            }
        }
        public function setTexCoordsValue( iVertexID : int, fCoordX : Number, fCoordY : Number ) : void
        {
            if( m_theImage != null )
            {
                m_theImage.setTexCoordsTo( iVertexID, fCoordX, fCoordY );
            }
        }

        public function getVertexPosition( iVertexID : int, vPosition : CVector2 = null ) : CVector2
        {
            if( m_theImage != null )
            {
                m_theImage.getVertexPosition( iVertexID, m_tempPoint );
                if( vPosition == null ) vPosition = new CVector2( m_tempPoint.x, m_tempPoint.y );
                else vPosition.setValueXY( m_tempPoint.x, m_tempPoint.y );
                return vPosition;
            }
            else return null;
        }
        public function setVertexPosition( iVertexID : int, vPosition : CVector2 ) : void
        {
            if( m_theImage != null )
            {
                m_theImage.setVertexPositionTo( iVertexID, vPosition.x, vPosition.y );
                _setCurrentBoundDirty();
            }
        }
        public function setVertexPositionValue( iVertexID : int, fPosX : Number, fPosY : Number ) : void
        {
            if( m_theImage != null )
            {
                m_theImage.setVertexPositionTo( iVertexID, fPosX, fPosY );
                _setCurrentBoundDirty();
            }
        }

        public function  get UVAnimationEnable():Boolean {return m_UVAnimationEnable;}
        public function set UVAnimationEnable(enable:Boolean):void
        {
            m_UVAnimationEnable = enable;
            if( m_theImage != null )
            {
                m_theImage.uvAnimationEnable = m_UVAnimationEnable;
            }
            m_currentTime = 0.0;
        }

        public function setUVAnimationVelocity(velocityX:Number=0.0, velocityY:Number = 0.0):void
        {
            m_velocityX = velocityX;
            m_velocityY = velocityY;
        }

        public function setUVAnimationTiling(tilingX:int=1, tilingY:int=1, offsetX:Number=0.0, offsetY:Number=0.0):void
        {
            m_tilingX = tilingX;
            m_tilingX = m_tilingX<1? 1:m_tilingX;
            m_tilingY = tilingY;
            m_tilingY = m_tilingY<1? 1:m_tilingY;
            m_UVOffsetX = offsetX;
            m_UVOffsetY = offsetY;
            if(m_theImage != null)
            {
                m_theImage.updateTiling(m_tilingX, m_tilingY, m_UVOffsetX, m_UVOffsetY);
                setUVAnimationMargin(m_UVmarginX, m_UVmarginY);
            }
        }

        public function setUVAnimationMargin(marginX:Number=0.01,marginY:Number=0.01):void
        {
            m_UVmarginX = marginX;
            m_UVmarginX = m_UVmarginX<0.01? 0.01:m_UVmarginX;
            m_UVmarginX = m_UVmarginX>0.5? 0.5:m_UVmarginX;

            m_UVmarginY = marginY;
            m_UVmarginY = m_UVmarginY<0.01? 0.01:m_UVmarginY;
            m_UVmarginY = m_UVmarginY>0.5? 0.5:m_UVmarginY;
            if(m_theImage != null)
            {
                m_theImage.updateMargin(m_UVmarginX, m_UVmarginY);
                m_theImage.setTexCoordsTo( 0, 0, 0 );
                m_theImage.setTexCoordsTo( 1, m_tilingX, 0 );
                m_theImage.setTexCoordsTo( 2, 0, m_tilingY );
                m_theImage.setTexCoordsTo( 3, m_tilingX, m_tilingY );
            }
        }

        public function get UVAnimationPause():Boolean {return m_UVAnimationPause;}
        public function set UVAnimationPause(pause:Boolean):void
        {
            m_UVAnimationPause = pause;
        }

        public override function update( fDeltaTime : Number ) : void
        {
            super.update(fDeltaTime);

            if(m_theImage != null && m_UVAnimationEnable)
            {
                if(!m_UVAnimationPause)
                {
                    m_currentTime += fDeltaTime;
                    var offsetU:Number = m_velocityX!=0.0? m_tilingX/m_velocityX*m_currentTime:0.0;
                    var offsetV:Number = m_velocityY!=0.0? m_tilingY/m_velocityY*m_currentTime:0.0;
                    offsetU = (offsetU+m_UVOffsetX) % m_tilingX;
                    offsetV = (offsetV+m_UVOffsetY) % m_tilingY;
                    m_theImage.updateOffsetUV(offsetU, offsetV);
                }
            }
        }

        override public function get renderableObject () : DisplayObject
        {
            return m_theImage;
        }

        public function get filename() : String
        {
            return m_sFilename;
        }

        public function get isLoaded() : Boolean
        {
            return m_theImage != null;
        }

        public function get width() : Number
        {
            if( m_theImage == null ) return 0.0;
            else return m_theImage.width;
        }
        public function get height() : Number
        {
            if( m_theImage == null ) return 0.0;
            else return m_theImage.height;
        }

        public override function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, bMasking : Boolean = false ) : void
        {
            if( m_theImage != null ) m_theImage.setColor( r, g, b, alpha, bMasking );
        }
        override public function resetColor () : void
        {
            if ( m_theImage != null ) m_theImage.resetColor();
        }

        public override function set opaque( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;
            if( m_theImage != null ) m_theImage.alpha = m_fOpaque;
        }

        public override function get currentBound() : CAABBox2
        {
            if( m_bCurrentBoundDirty )
            {
                if( m_theImage != null )
                {
                    m_theImage.getVertexPosition( 0, m_tempPoint );
                    if( m_theAABB == null ) m_theAABB = new CAABBox2( CVector2.ZERO );
                    m_theAABB.setCenterExtValue( m_tempPoint.x, m_tempPoint.y, 0.0, 0.0 );

                    m_theImage.getVertexPosition( 1, m_tempPoint );
                    m_theAABB.mergeVertexValue( m_tempPoint.x, m_tempPoint.y );
                    m_theImage.getVertexPosition( 2, m_tempPoint );
                    m_theAABB.mergeVertexValue( m_tempPoint.x, m_tempPoint.y );
                    m_theImage.getVertexPosition( 3, m_tempPoint );
                    m_theAABB.mergeVertexValue( m_tempPoint.x, m_tempPoint.y );

                    m_bCurrentBoundDirty = false;
                }
            }

            return m_theAABB;
        }

        [Inline]
        final public function get textureResource() : CResource
        {
            return m_theTextureResource;
        }
        [Inline]
        final public function get textureAtlasResource() : CResource
        {
            return m_theTextureAtlasResource;
        }


        public function createEmpty( fWidth : Number, fHeight : Number ) : void
        {
            if( m_theImage != null )
            {
                m_theDisplayNode.removeChild( m_theImage );
                m_theImage.dispose();
            }
            m_theImage = new Image( null );
            m_theDisplayNode.addChild( m_theImage );

            m_theImage.setVertexPositionTo( 0, 0.0, 0.0 );
            m_theImage.setVertexPositionTo( 1, fWidth, 0.0 );
            m_theImage.setVertexPositionTo( 2, 0.0, fHeight );
            m_theImage.setVertexPositionTo( 3, fWidth, fHeight );

            _setCurrentBoundDirty();

            if( m_bCenterAnchor )
            {
                var fOffsetX : Number = fWidth * 0.5;
                var fOffsetY : Number = fHeight * 0.5;
                m_theImage.x = -fOffsetX;
                m_theImage.y = -fOffsetY;
            }
            else
            {
                m_theImage.x = 0.0;
                m_theImage.y = 0.0;
            }

            m_theImage.verticesColor = _getIntegerColor();
            m_theImage.alpha = m_fOpaque;
        }

        public function resize( fWidth : Number, fHeight : Number ) : void
        {
            if( m_theImage == null ) createEmpty( fWidth, fHeight );
            else
            {
                var theBound : CAABBox2 = this.currentBound;
                if( CMath.abs( theBound.width - fWidth ) < CMath.EPSILON && CMath.abs( theBound.height - fHeight ) < CMath.EPSILON ) return ;

                m_theImage.setVertexPositionTo( 0, 0.0, 0.0 );
                m_theImage.setVertexPositionTo( 1, fWidth, 0.0 );
                m_theImage.setVertexPositionTo( 2, 0.0, fHeight );
                m_theImage.setVertexPositionTo( 3, fWidth, fHeight );

                if( m_bCenterAnchor )
                {
                    var fOffsetX : Number = fWidth * 0.5;
                    var fOffsetY : Number = fHeight * 0.5;
                    m_theImage.x = -fOffsetX;
                    m_theImage.y = -fOffsetY;
                }
                else
                {
                    m_theImage.x = 0.0;
                    m_theImage.y = 0.0;
                }

                _setCurrentBoundDirty();
            }
        }

        //
        //
        //
        protected function _onLoadFinished( loader : CBaseLoader, idErrorCode : int ) : void
        {
            if( this.disposed ) return ;

            if( idErrorCode != 0 )
            {
                Foundation.Log.logErrorMsg( "_onLoadFinished(): Can not load image: " + loader.filename );
                if( m_fnOnLoadFinished != null ) m_fnOnLoadFinished( this, idErrorCode );
                return ;
            }
            m_sFilename = loader.loadingFilename;

            if (loader is CTextureAtlasLoader)
            {
                var imageName : String = loader.arguments[3];

                m_theTextureAtlasResource = loader.createResource();
                if ( m_theTextureAtlasResource == null || m_theTextureAtlasResource.theObject == null ) {
                    Foundation.Log.logErrorMsg( "_onLoadFinished(): cannot get textureAtlas's data( null): " + loader.filename );
                    return;
                }
                tex = (m_theTextureAtlasResource.theObject as TextureAtlas).getTexture(imageName);
                tex.uploaded = true;
                tex.repeat = false;

                _createImage( tex );
                _setCurrentBoundDirty();
            }
            else  if (loader is CTextureLoader)
            {
                m_theTextureResource = loader.createResource();
                if ( m_theTextureResource == null || m_theTextureResource.theObject == null ) {
                    Foundation.Log.logErrorMsg( "_onLoadFinished(): cannot get image's data( null): " + loader.filename );
                    return;
                }

                // use clamp mode by default to avoid crack edges effects amount images
                var tex : Texture = m_theTextureResource.theObject as Texture;
                tex.repeat = false;

                _createImage( tex );
                _setCurrentBoundDirty();
            }
            if( m_fnOnLoadFinished != null ) m_fnOnLoadFinished( this, 0 );
        }

        public function _createImage( tex : Texture) : void
        {
            if( m_theImage != null )
            {
                m_theDisplayNode.removeChild( m_theImage );
                m_theImage.dispose();
            }
            var subTex : SubTexture = tex as SubTexture;

            if (subTex != null )
            {
                m_theImage = new Image( subTex );
            }
            else
                m_theImage = new Image(tex);
            m_theDisplayNode.addChild( m_theImage );

            // adjust UV if it is a sub texture ( shrink or stretch to 1(the entire texture) )
            if( subTex != null )
            {
                this.setTexCoordsValue(0, 0, 0);
                this.setTexCoordsValue(1, 1, 0);
                this.setTexCoordsValue(2, 0, 1);
                this.setTexCoordsValue(3, 1, 1);
            }


            if( m_bCenterAnchor )
            {
                var fOffsetX : Number = m_theImage.width * 0.5;
                var fOffsetY : Number = m_theImage.height * 0.5;
                m_theImage.x = -fOffsetX;
                m_theImage.y = -fOffsetY;
            }
            else
            {
                m_theImage.x = 0.0;
                m_theImage.y = 0.0;
            }

            m_theImage.verticesColor = _getIntegerColor();
            m_theImage.alpha = m_fOpaque;
            m_theImage.uvAnimationEnable = m_UVAnimationEnable;
            if(m_UVAnimationEnable)
            {
                tex.repeat = true;
                m_theImage.updateTiling(m_tilingX, m_tilingY, m_UVOffsetX, m_UVOffsetY);
                setUVAnimationMargin(m_UVmarginX,m_UVmarginY);
            }
        }

        public function _setCurrentBoundDirty() : void
        {
            m_bCurrentBoundDirty = true;
            if( m_fnOnCurrentBoundChanged != null ) m_fnOnCurrentBoundChanged( this );
        }

        [Inline]
        final private function _getIntegerColor() : uint
        {
            var iR : uint = int( m_vColor.r * 255.0 ) << 16;
            var iG : uint = int( m_vColor.g * 255.0 ) << 8;
            var iB : uint = int( m_vColor.b * 255.0 );
            return iR + iG + iB;
        }


        //
        protected var m_sFilename : String = "";
        protected var m_theTextureResource : CResource = null;
        protected var m_theTextureAtlasResource : CResource = null;
        protected var m_theImage : Image = null;
        protected var m_theAABB : CAABBox2 = null;

        protected  var m_UVAnimationEnable:Boolean = false;
        protected var m_velocityX:Number = 0.0;
        protected var m_velocityY:Number = 0.0;
        protected  var m_tilingX:int = 1;
        protected  var m_tilingY:int = 1;
        protected  var m_UVOffsetX:Number = 0.0;
        protected  var m_UVOffsetY:Number = 0.0;
        protected var m_UVmarginX:Number = 0.01;
        protected var m_UVmarginY:Number = 0.01;
        protected  var m_currentTime:Number = 0.0;
        protected  var m_UVAnimationPause:Boolean = true;

        protected var m_bCurrentBoundDirty : Boolean = true;
        protected var m_bCenterAnchor : Boolean = false;
        protected var m_fnOnLoadFinished : Function = null;
        protected var m_fnOnCurrentBoundChanged : Function = null;

        private var m_tempPoint : Point = new Point();
    }
}
