//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------

package QFLib.Framework
{

    import QFLib.Audio.CAudioManager;
    import QFLib.Collision.CCollisionDisplaySystem;
    import QFLib.Collision.CCollisionManager;
    import QFLib.Foundation;
    import QFLib.Foundation.CSet;
    import QFLib.Foundation.free;
    import QFLib.Framework.CharacterExtData.CCharacterAudioDataLoader;
    import QFLib.Framework.CharacterExtData.CCharacterCollisionDataLoader;
    import QFLib.Framework.CharacterExtData.CCharacterFXDataLoader;
    import QFLib.Graphics.RenderCore.CRenderer;
    import QFLib.Graphics.RenderCore.CUILayer;
    import QFLib.Graphics.Sprite.CSpriteSystem;
    import QFLib.Interface.IUpdatable;
    import QFLib.Math.CVector3;
    import QFLib.Memory.CResourcePools;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;

    import flash.display.Stage;

    public class CFramework
	{
        public static var StatisticsResourceOn : Boolean = false;

		public function CFramework()
		{
        }
        public function dispose() : void
        {
            _unsetShadowCircle();

            if( m_theSpriteSystem.numSprites > 0 )
            {
                Foundation.Log.logErrorMsg( "There are resource leaks in sprite system: " + m_theSpriteSystem.numSprites );
                m_theSpriteSystem.dispose();
            }

            var i : int;

            for( i = 0; i < 2; i++ )
            {
                if( m_setScenes[ i ].count > 0 )
                {
                    Foundation.Log.logErrorMsg( "There are resource leaks in m_setScenes[ " + i + " ]: " + m_setScenes[ i ].count );
                }
                m_setScenes[ i ].clear();
            }
            m_setScenes = null;

            for( i = 0; i < 2; i++ )
            {
                if( m_setCharacters[ i ].count > 0 )
                {
                    Foundation.Log.logErrorMsg( "There are resource leaks in m_setCharacters[ " + i + " ]: " + m_setCharacters[ i ].count );
                }
                m_setCharacters[ i ].clear();
            }
            m_setCharacters = null;

            for( i = 0; i < 2; i++ )
            {
                if( m_setFXs[ i ].count > 0 )
                {
                    Foundation.Log.logErrorMsg( "There are resource leaks in m_setFXs[ " + i + " ]: " + m_setFXs[ i ].count );
                }
                m_setFXs[ i ].clear();
            }
            m_setFXs = null;

            for( i = 0; i < 2; i++ )
            {
                if( m_setImages[ i ].count > 0 )
                {
                    Foundation.Log.logErrorMsg( "There are resource leaks in m_setImages[ " + i + " ]: " + m_setImages[ i ].count );
                }
                m_setImages[ i ].clear();
            }
            m_setImages = null;

            for( i = 0; i < 2; i++ )
            {
                if( m_setTexts[ i ].count > 0 )
                {
                    Foundation.Log.logErrorMsg( "There are resource leaks in m_setTexts[ " + i + " ]: " + m_setTexts[ i ].count );
                }
                m_setTexts[ i ].clear();
            }
            m_setTexts = null;

            for( i = 0; i < 2; i++ )
            {
                if( m_setCollisionQuads[ i ].count > 0 )
                {
                    Foundation.Log.logErrorMsg( "There are resource leaks in m_setCollisions[ " + i + " ]: " + m_setCollisionQuads[ i ].count );
                }
                m_setCollisionQuads[ i ].clear();
            }
            m_setCollisionQuads = null;

            if( m_CombineEffectDataResource != null )
            {
                m_CombineEffectDataResource.dispose ();
                m_CombineEffectDataResource = null;
            }

            if ( m_BuffEffectDataResource != null )
            {
                m_BuffEffectDataResource.dispose ();
                m_BuffEffectDataResource = null;
            }

            if( m_CollisionMgr != null )
            {
                free( m_CollisionMgr );
                m_CollisionMgr =  null;
            }

            if( m_CollisionDisplaySys != null )
            {
                free( m_CollisionDisplaySys );
                m_CollisionDisplaySys = null;
            }

            if ( m_UILayer != null )
            {
                m_UILayer.dispose();
                m_UILayer = null;
            }

            m_theFXResourcePools.dispose();
            m_thePostEffects.dispose();
            m_theRenderer.dispose();
            m_thePostEffects = null;
            m_theFXResourcePools = null;
            m_theRenderer = null;
        }

        //
        //
        public function initialize( stage : Stage, fnFrameworkInitialized : Function , onInitializing : Function = null) : Boolean
        {
            m_theRenderer = new CRenderer( stage );
            m_theFXResourcePools = new CResourcePools();

            m_fnFrameworkInitialized = fnFrameworkInitialized;

            m_theRenderer.initialize( _onRendererInitialized , null, 0x0, onInitializing);
            m_CollisionDisplaySys = new CCollisionDisplaySystem( this.renderer );
            m_CollisionMgr = new CCollisionManager( collisionDisplaySys );

            // register loaders
            CResourceLoaders.instance().registerLoader( CCharacterCollisionDataLoader );
            CResourceLoaders.instance().registerLoader( CCharacterFXDataLoader );
            CResourceLoaders.instance().registerLoader( CCharacterAudioDataLoader );

            return true;
        }

        public function get3DPositionFrom2D( x : Number, y : Number, fHeightToGround : Number = 0.0, fStepHeight : Number = -1.0, v3DPosition : CVector3 = null ) : CVector3
        {
            var z : Number = ( y + fHeightToGround ) / CObject.TAN_THETA_OF_CAMERA; // to convert 2D position to 3D space

            var fTheHighestTerrain : Number = -Number.MAX_VALUE;
            var fHeight : Number;
            for each( var scene : CScene in this.sceneSet )
            {
                if( scene.terrainData != null )
                {
                    fHeight = scene.terrainData.getTerrainHeight( x, z, fStepHeight );
                    if( fHeight > fTheHighestTerrain ) fTheHighestTerrain = fHeight;
                }
            }

            fHeight = fTheHighestTerrain + fHeightToGround;
            z = ( y + fHeight ) / CObject.TAN_THETA_OF_CAMERA;

            y = fHeight;
            if( v3DPosition == null ) v3DPosition = new CVector3( x, y, z );
            else v3DPosition.setValueXYZ( x, y, z );

            return v3DPosition
        }

        public function get2DPositionFrom3D( x : Number, y : Number, z : Number, v2DPosition : CVector3 = null ) : CVector3
        {
            z *= CObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D space

            if( v2DPosition == null ) v2DPosition = new CVector3( x, -y + z, z );
            else v2DPosition.setValueXYZ( x, -y + z, z );

            return v2DPosition;
        }

        public function hitTestTerrain( f2DPosX : Number, f2DPosY : Number, v3DPos : CVector3 = null ) : CVector3
        {
            for each( var scene : CScene in this.sceneSet )
            {
                if( scene.terrainData != null )
                {
                    return scene.terrainData.hitTest( f2DPosX, f2DPosY, v3DPos );
                }
            }

            return null;
        }

        [Inline]
        final public function get collisionMgr () : CCollisionManager
        { return m_CollisionMgr; }

        [Inline]
        final public function get autoRendering() : Boolean {
            return m_bAutoRendering;
        }

        final public function set autoRendering( value : Boolean ) : void {
            m_bAutoRendering = value;
        }

        [Inline]
        final public function get isInitialized() : Boolean
        {
            return m_bInitialized;
        }
        [Inline]
        final public function get renderer() : CRenderer
        {
            return m_theRenderer;
        }
        [Inline]
        final public function get spriteSystem() : CSpriteSystem
        {
            return m_theSpriteSystem;
        }
        [Inline]
        final public function get tweenSystem() : CTweenSystem
        {
            return m_theTweenSystem;
        }
        [Inline]
        final public function get fxResourcePools() : CResourcePools
        {
            return m_theFXResourcePools;
        }
        [Inline]
        final public function set fxPoolUpdateSwitchOn ( value : Boolean ) : void
        {
            m_theFXResourcePools.updateSwitchOn = value;
        }
        [Inline]
        final public function set fxPoolUpdateTimeInterval ( value : Number ) : void
        {
            m_theFXResourcePools.updateTimeInterval = value;
        }

        [Inline]
        final public function set audioManager( audio : Object) : void
        {
            m_thaAudioManagerRef = audio as CAudioManager;
        }
        [Inline]
        final public function get audioManager() : Object
        {
            return m_thaAudioManagerRef;
        }

        [Inline]
        final public function get uiLayer () : CUILayer
        {
            return m_UILayer;
        }

        [Inline]
        final public function get combineEffectDataResource () : CResource { return m_CombineEffectDataResource; }
        [Inline]
        final public function set combineEffectDataResource ( value : CResource ) : void { m_CombineEffectDataResource = value; }

        [Inline]
        final public function get buffEffectDataResource () : CResource { return m_BuffEffectDataResource; }
        [Inline]
        final public function set buffEffectDataResource ( value : CResource ) : void { m_BuffEffectDataResource = value;}

        public function setShadowMode( iShadowMode : int, sShadowCircleFile : String = "shadow_circle", fShadowCircleScaleFactor : Number = 1.0 ) : void
        {
            if( m_iShadowMode == iShadowMode && sShadowCircleFile == m_sShadowCircleFilename ) return;

            if( m_iShadowMode == 1 ) _unsetShadowCircle();
            m_iShadowMode = 0;

            if( iShadowMode == 1 ) // a simple circle
            {
                _setShadowCircle( sShadowCircleFile, fShadowCircleScaleFactor );
            }

            m_iShadowMode = iShadowMode;
        }
        [Inline]
        final public function get shadowMode() : int
        {
            return m_iShadowMode;
        }
        [Inline]
        final public function get shadowCircleFilename() :String
        {
            return m_sShadowCircleFilename;
        }
        [Inline]
        final public function get shadowCircleScaleFactor() :Number
        {
            return m_fShadowCircleScaleFactor;
        }

        [Inline]
        final public function get currentCameraScene() : CScene
        {
            return m_theCurrentCameraScene;
        }
        [Inline]
        final public function get currentCameraTarget() : CObject
        {
            return m_theCurrentCameraTarget;
        }
        [Inline]
        final public function get currentCameraTarget2() : CObject
        {
            return m_theCurrentCameraTarget2;
        }

        final public function get collisionPool() : CCollisionManager
        {
            return m_CollisionMgr;
        }

        final public function get collisionDisplaySys() : CCollisionDisplaySystem
        {
            return m_CollisionDisplaySys;
        }

        final public function addObjectToUILayer ( object : CObject, screenX : Number, screenY : Number, depth : Number = 0.0 ) : Boolean
        {
            if ( object == null || object.theObject == null || m_UILayer == null ) return false;
            if ( object.theObject.parent != m_UILayer )
                m_UILayer.addChild ( object.theObject, true );

            object.setScreenPosition ( screenX, screenY, depth );
            return true;
        }
        final public function removeObjectFromUILayer ( object : CObject ) : Boolean
        {
            if ( object == null || object.theObject == null || m_UILayer == null ) return false;
            if ( object.theObject.parent == null ) return true;
            m_UILayer.removeChild ( object.theObject, true );
            return true;
        }

        //
        public function update( fDeltaTime : Number ) : void
        {
            if( !m_bInitialized ) return ;

            Foundation.Perf.sectionBegin( "Framework_Update" );

            for each( var character : CCharacter in m_setCharacters[ 1 ] )
            {
                Foundation.Perf.sectionBegin( "Framework_Character_Update" );
                character.update( fDeltaTime );
                Foundation.Perf.sectionEnd( "Framework_Character_Update" );
            }
            for each( var fx : CFX in m_setFXs[ 1 ] )
            {
                Foundation.Perf.sectionBegin( "Framework_FX_Update" );
                fx.update( fDeltaTime );
                Foundation.Perf.sectionEnd( "Framework_FX_Update" );
            }
            for each( var img : CImage in m_setImages[ 1 ] )
            {
                Foundation.Perf.sectionBegin( "Framework_Image_Update" );
                img.update( fDeltaTime );
                Foundation.Perf.sectionEnd( "Framework_Image_Update" );
            }
            for each( var text : CText in m_setTexts[ 1 ] )
            {
                Foundation.Perf.sectionBegin( "Framework_Text_Update" );
                text.update( fDeltaTime );
                Foundation.Perf.sectionEnd( "Framework_Text_Update" );
            }
            for each( var scene : CScene in m_setScenes[ 1 ] )
            {
                Foundation.Perf.sectionBegin( "Framework_Scene_Update" );
                scene.update( fDeltaTime );
                Foundation.Perf.sectionEnd( "Framework_Scene_Update" );
            }

            for each( var collision : CCollisionQuad in m_setCollisionQuads[ 1 ] )
            {
                Foundation.Perf.sectionBegin( "Framework_Collision_Update" );
                collision.update( fDeltaTime );
                Foundation.Perf.sectionEnd( "Framework_Collision_Update" );
            }

            Foundation.Perf.sectionBegin( "Framework_FXResourcePools_Update" );
            m_theFXResourcePools.update( fDeltaTime );
            Foundation.Perf.sectionEnd( "Framework_FXResourcePools_Update" );

            Foundation.Perf.sectionBegin( "Framework_SpriteSystem_Update" );
            m_theSpriteSystem.update( fDeltaTime );
            Foundation.Perf.sectionEnd( "Framework_SpriteSystem_Update" );

            Foundation.Perf.sectionBegin( "Framework_TweenSystem_Update" );
            m_theTweenSystem.update( fDeltaTime );
            Foundation.Perf.sectionEnd( "Framework_TweenSystem_Update" );

            Foundation.Perf.sectionBegin( "Framework_PostEffect_Update" );
            m_thePostEffects.updatePostEffects( fDeltaTime );
            Foundation.Perf.sectionEnd( "Framework_PostEffect_Update" );

            Foundation.Perf.sectionBegin( "Framework_collision_Update" );
            (m_CollisionMgr as IUpdatable).update( fDeltaTime );
            Foundation.Perf.sectionEnd( "Framework_collision_Update" );

            Foundation.Perf.sectionBegin( "Framework_collisiondisplay_Update" );
            (m_CollisionDisplaySys as IUpdatable).update( fDeltaTime );
            Foundation.Perf.sectionEnd( "Framework_collisiondisplay_Update" );

            if ( this.autoRendering )
                render();

            CFX.resetCurScreenVisibleCount ();

            Foundation.Perf.sectionEnd( "Framework_Update" );
        }

        public function render() : void {
            if( m_theRenderer && m_bInitialized )
            {
                Foundation.Perf.sectionBegin( "Framework_Render" );
                m_theRenderer.render();
                Foundation.Perf.sectionEnd( "Framework_Render" );
            }
        }

        [Inline]
        final public function get sceneSet() : CSet
        {
            return m_setScenes[ 1 ];
        }
        [Inline]
        final public function get fxSet() : CSet
        {
            return m_setFXs[ 1 ];
        }
        [Inline]
        final public function get imageSet() : CSet
        {
            return m_setImages[ 1 ];
        }
        [Inline]
        final public function get textSet() : CSet
        {
            return m_setTexts[ 1 ];
        }
        [Inline]
        final public function get characterSet() : CSet
        {
            return m_setCharacters[ 1 ];
        }
        [Inline]
        final public function getSceneSet( bEnable : Boolean ) : CSet
        {
            if( bEnable ) return m_setScenes[ 1 ];
            else return m_setScenes[ 0 ];
        }
        [Inline]
        final public function getFxSet( bEnable : Boolean ) : CSet
        {
            if( bEnable ) return m_setFXs[ 1 ];
            else return m_setFXs[ 0 ];
        }
        [Inline]
        final public function getImageSet( bEnable : Boolean ) : CSet
        {
            if( bEnable ) return m_setImages[ 1 ];
            else return m_setImages[ 0 ];
        }
        [Inline]
        final public function getTextSet( bEnable : Boolean ) : CSet
        {
            if( bEnable ) return m_setTexts[ 1 ];
            else return m_setTexts[ 0 ];
        }
        [Inline]
        final public function getCharacterSet( bEnable : Boolean ) : CSet
        {
            if( bEnable ) return m_setCharacters[ 1 ];
            else return m_setCharacters[ 0 ];
        }
        [Inline]
        final public function set fxScreenLimitCount ( count : int ) : void
        {
            CFX.setOneScreenLimitCount ( count );
        }

        //
        //
        internal function _addObject( obj : CObject ) : void
        {
            if( obj is CScene )
            {
                if( obj.enabled ) m_setScenes[ 1 ].add( CScene( obj ) );
                else m_setScenes[ 0 ].add( CScene( obj ) );
            }
            else if( obj is CCharacter )
            {
                if( obj.enabled ) m_setCharacters[ 1 ].add( CCharacter( obj ) );
                else  m_setCharacters[ 0 ].add( CCharacter( obj ) );
            }
            else if( obj is CFX )
            {
                if( obj.enabled ) m_setFXs[ 1 ].add( CFX( obj ) );
                else m_setFXs[ 0 ].add( CFX( obj ) );
            }
            else if( obj is CImage )
            {
                if( obj.enabled ) m_setImages[ 1 ].add( CImage( obj ) );
                else m_setImages[ 0 ].add( CImage( obj ) );
            }
            else if( obj is CText )
            {
                if( obj.enabled ) m_setTexts[ 1 ].add( CText( obj ) );
                else m_setTexts[ 0 ].add( CText( obj ) );
            }else if( obj is CCollisionQuad )
            {
                if( obj.enabled ) m_setCollisionQuads[ 1 ].add( CCollisionQuad( obj ) );
                else m_setCollisionQuads[ 0 ].add( CCollisionQuad( obj ) );
            }
        }
        internal function _removeObject( obj : CObject ) : void
        {
            if( obj is CScene )
            {
                if( obj.enabled ) m_setScenes[ 1 ].remove( CScene( obj ) );
                else m_setScenes[ 0 ].remove( CScene( obj ) );
            }
            else if( obj is CCharacter )
            {
                if( obj.enabled ) m_setCharacters[ 1 ].remove( CCharacter( obj ) );
                else m_setCharacters[ 0 ].remove( CCharacter( obj ) );
            }
            else if( obj is CFX )
            {
                if( obj.enabled ) m_setFXs[ 1 ].remove( CFX( obj ) );
                else m_setFXs[ 0 ].remove( CFX( obj ) );
            }
            else if( obj is CImage )
            {
                if( obj.enabled ) m_setImages[ 1 ].remove( CImage( obj ) );
                else m_setImages[ 0 ].remove( CImage( obj ) );
            }
            else if( obj is CText )
            {
                if( obj.enabled ) m_setTexts[ 1 ].remove( CText( obj ) );
                else m_setTexts[ 0 ].remove( CText( obj ) );
            }
        }

        [Inline]
        final internal function _setCurrentCameraScene( theCameraScene : CScene ) : void
        {
            m_theCurrentCameraScene = theCameraScene;
        }
        //[Inline], 导致编译器生成byte code是 over flow，所以注释掉该Inline
        final internal function _setCurrentCameraTarget( theCameraTarget : CObject, theCameraTarget2 : CObject = null ) : void
        {
            m_theCurrentCameraTarget = theCameraTarget;
            m_theCurrentCameraTarget2 = theCameraTarget2;
        }

        //
        private function _onRendererInitialized() : void
        {
            m_theSpriteSystem = new CSpriteSystem( m_theRenderer );
            m_theTweenSystem = new CTweenSystem();

            if( m_fnFrameworkInitialized != null ) m_fnFrameworkInitialized();

            m_UILayer = new CUILayer ( m_theRenderer );
            m_UILayer.attachToRoot();

            m_bInitialized = true;
        }

        private function _setShadowCircle( sFilename : String, fShadowCircleScaleFactor : Number ) : void
        {
            m_sShadowCircleFilename = sFilename;
            m_fShadowCircleScaleFactor = fShadowCircleScaleFactor;

            var char : CCharacter;
            for( var i : int = 0; i < 2; i++ )
            {
                for each( char in m_setCharacters[ i ] )
                {
                    char._setShadowImage( sFilename, m_fShadowCircleScaleFactor );
                }
            }
        }
        private function _unsetShadowCircle() : void
        {
            var char : CCharacter;
            for( var i : int = 0; i < 2; i++ )
            {
                for each( char in m_setCharacters[ i ] )
                {
                    char._setShadowImage( null );
                }
            }
        }


        //
        //
        protected var m_theRenderer : CRenderer = null;
        protected var m_theSpriteSystem : CSpriteSystem = null;
        protected var m_theTweenSystem : CTweenSystem = null;
        protected var m_theFXResourcePools : CResourcePools = null;

        protected var m_setScenes : Array = [ new CSet(), new CSet() ];
        protected var m_setCharacters : Array = [ new CSet(), new CSet() ];
        protected var m_setFXs : Array = [ new CSet(), new CSet() ];
        protected var m_setImages : Array = [ new CSet(), new CSet() ];
        protected var m_setTexts : Array = [ new CSet(), new CSet() ];
        protected var m_setCollisionQuads : Array = [ new CSet(), new CSet() ];

        protected var m_thePostEffects : CPostEffects = CPostEffects.getInstance();

        protected var m_theCurrentCameraScene : CScene = null;
        protected var m_theCurrentCameraTarget : CObject = null;
        protected var m_theCurrentCameraTarget2 : CObject = null;

        protected var m_sShadowCircleFilename : String = null;
        protected var m_fShadowCircleScaleFactor : Number = 1.0;
        protected var m_iShadowMode : int = 0;

        protected var m_thaAudioManagerRef : CAudioManager = null;

        protected var m_fnFrameworkInitialized : Function = null;
        protected var m_bInitialized : Boolean = false;
        protected var m_bAutoRendering : Boolean = true;

        //for combine effect
        protected var m_CombineEffectDataResource : CResource = null;

        //for buff effect
        protected var m_BuffEffectDataResource : CResource = null;

        //for collision
        protected var m_CollisionMgr : CCollisionManager;
        protected var m_CollisionDisplaySys : CCollisionDisplaySystem;

        //ui layer
        protected var m_UILayer : CUILayer = null;
    }
}


//
//
//
/*import QFLib.Math.CVector2;

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
}*/
