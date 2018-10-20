//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/8/17.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Sprite
{
    import QFLib.Foundation;
    import QFLib.Foundation.CSet;
    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.CRenderer;
    import QFLib.Graphics.Sprite.Font.CFont;
    import QFLib.Graphics.Sprite.Font.CFontManager;
    import QFLib.Interface.IDisposable;
    import QFLib.Interface.IUpdatable;
    import QFLib.Memory.CResourcePool;
    import QFLib.Memory.CResourcePools;

    public class CSpriteSystem implements IDisposable, IUpdatable
	{
        public static const SPRITESYSTEM_LAYER_INDEX : int = 20;

		public function CSpriteSystem( theRenderer : CRenderer, iDepth : int = SPRITESYSTEM_LAYER_INDEX, iCullingMask : int = 1 << SPRITESYSTEM_LAYER_INDEX )
		{
            m_theSpriteRootNode = new CBaseObject( theRenderer );
            m_theSpriteRootNode.attachToRoot();
            m_theSpriteRootNode.layer = iDepth + 1;
            m_theRendererRef = theRenderer;

            m_theCamera = new CSpriteCamera( theRenderer.nativeStageWidth, theRenderer.nativeStageHeight );
            m_theRendererRef.addCamera( m_theCamera );

            setCameraDepth( iDepth );
            setCameraCullingMask( iCullingMask );
        }

		public function dispose() : void
		{
            reset();

            m_theResourcePools.dispose();

            m_setVisibleSprites = null;
            m_setInvisibleSprites = null;

            if( m_theFontManager != null )
            {
                m_theFontManager.dispose();
                m_theFontManager = null;
            }

            if( m_theCamera != null )
            {
                m_theSpriteRootNode.usingCamera = null;
                m_theCamera = null;
            }

            m_theSpriteRootNode.dispose();
            m_theSpriteRootNode = null;
        }

        public function reset() : void
        {
            m_theResourcePools.clearAll();

            if( m_setVisibleSprites.count > 0 )
            {
                Foundation.Log.logErrorMsg( "There are resource leaks in sprite system: " + m_setVisibleSprites.count );
            }
            m_setVisibleSprites.clear();

            if( m_setInvisibleSprites.count > 0 )
            {
                Foundation.Log.logErrorMsg( "There are resource leaks in sprite system: " + m_setInvisibleSprites.count );
            }
            m_setInvisibleSprites.clear();

            m_theFontManager.reset();
        }

        public function get texturePath() : String
        {
            return m_sTextureDir;
        }

        public function get renderer() : CRenderer
        {
            return m_theRendererRef;
        }

        public function get glyphManager() : CFontManager
        {
            return m_theFontManager;
        }

        public function get numSprites() : int
        {
            return m_setVisibleSprites.count + m_setInvisibleSprites.count;
        }
        public function get visibleSprites() : CSet
        {
            return m_setVisibleSprites;
        }
        public function get invisibleSprites() : CSet
        {
            return m_setInvisibleSprites;
        }

        public function addToSpriteLayer( sprite : CSprite ) : void
        {
            m_theSpriteRootNode.addChild( sprite );
        }
        public function removeFromSpriteLayer( sprite : CSprite ) : void
        {
            m_theSpriteRootNode.removeChild( sprite );
        }

        public function createSpriteFromPool( sPoolName : String ) : CSprite
        {
            var theResPool : CResourcePool =  m_theResourcePools.getPool( sPoolName );
            if( theResPool == null ) return null;

            return theResPool.allocate() as CSprite;
        }
        public function recycleSpriteToPool( sPoolName : String,  theSprite : CSprite ) : void
        {
            var theResPool : CResourcePool =  m_theResourcePools.getPool( sPoolName );
            if( theResPool == null )
            {
                theResPool = new CResourcePool( sPoolName, null );
                m_theResourcePools.addPool( sPoolName, theResPool );
            }

            theResPool.recycle( theSprite );
        }

        public function setCameraDepth( iDepth : int ) : void
        {
            m_theCamera.depth = iDepth;
        }

        public function setCameraCullingMask( iCullingMask : int ) : void
        {
            m_theCamera.cullingMask = iCullingMask;
        }

        public function registerFont( theFont : CFont ) : void
        {
            m_theFontManager.registerFont( theFont );
        }

        public function update( fDeltaTime : Number ) : void
        {
            m_theSpriteRootNode.update( fDeltaTime );

            for each( var sprite : CSprite in m_setVisibleSprites )
            {
                sprite.update( fDeltaTime );
            }

            m_theResourcePools.update( fDeltaTime );
        }

        //
        internal function _addSprite( sprite : CSprite ) : void
        {
            if( sprite.visible ) m_setVisibleSprites.add( sprite );
            else m_setInvisibleSprites.add( sprite );
        }
        internal function _removeSprite( sprite : CSprite ) : void
        {
            if( sprite.visible ) m_setVisibleSprites.remove( sprite );
            else m_setInvisibleSprites.remove( sprite );
        }


        //
		//
        protected var m_sTextureDir : String = null;

        protected var m_theSpriteRootNode : CBaseObject = null;
        protected var m_theCamera : CSpriteCamera = null;
        protected var m_setVisibleSprites : CSet = new CSet();
        protected var m_setInvisibleSprites : CSet = new CSet();

        protected var m_theFontManager : CFontManager = new CFontManager();
        protected var m_theResourcePools : CResourcePools = new CResourcePools();
        protected var m_theRendererRef : CRenderer;
    }
}

