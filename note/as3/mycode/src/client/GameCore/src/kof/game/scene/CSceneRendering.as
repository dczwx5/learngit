//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.scene {

import QFLib.Foundation;
import QFLib.Foundation.CPath;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;
import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Graphics.Scene.CCamera;
import QFLib.Graphics.Scene.CTerrainData;
import QFLib.Graphics.Sprite.Font.CBitmapFont;
import QFLib.Graphics.Sprite.Font.CTrueTypeFont;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.ELoadingPriority;

import flash.events.Event;
import flash.utils.Dictionary;

import kof.framework.CAbstractHandler;
import kof.framework.CAppSystem;
import kof.util.CAssertUtils;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CSceneRendering extends CAbstractHandler implements IUpdatable {

    /** @private */
    private var m_bInitialized : Boolean;
    /** @private */
    private var m_pGraphicScene : CScene;
    /** @private */
    private var m_pGraphicsFramework : CFramework;
    /** @private */
    private var m_bReady : Boolean;
    /** @private */
    private var m_bCfgReady : Boolean;
    /** @private */
    private var m_thePersistScenes : Object;
    /** @private */
    private var m_thePersistScenesIds : Vector.<Object>;
    /** @private */
    private var m_nNextSceneId : String;
    /** @private */
    private var m_nRunningSceneId : String;
    /** @private */
    private var m_theNextSpawnLocation : CVector2;
    /** @private */
    private var m_fTimeElapsed : Number;
    /** @private */
    private var m_pFollowObject : Dictionary;
    /** @private */
    private var m_bFollowObjectDirty : Boolean;
    private var m_bFontRegistering : Boolean;
    private var m_bFontReady : Boolean;

    /** @private */
    public static const SCENE_CFG_COMPLETE : String = "SCENE_CFG_COMPLETE";
    /** @private */
    public static const SCENE_CHANGED : String = "SCENE_CHANGED";

//    public static const SCENE_CLIENT_READY : String = "SCENE_CLIENT_READY";

    /**
     * Creates a new CSceneRendering.
     */
    public function CSceneRendering() {
        super();
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();

        if ( m_pGraphicScene )
            m_pGraphicScene.dispose();
        m_pGraphicScene = null;

        if ( m_pGraphicsFramework )
            m_pGraphicsFramework.dispose();
        m_pGraphicsFramework = null;

        if ( m_thePersistScenes ) {
            for each ( var cs : CScene in m_thePersistScenes ) {
                if ( cs )
                    cs.dispose();
            }
        }
        m_thePersistScenes = null;

        if ( m_thePersistScenesIds && m_thePersistScenesIds.length ) {
            m_thePersistScenesIds.splice( 0, m_thePersistScenesIds.length );
        }
        m_thePersistScenesIds = null;

        m_pFollowObject = null;
    }


    final public function get isReady() : Boolean {
        return null != m_pGraphicScene && m_bReady;
    }

    final public function get runningSceneId() : String {
        return m_nRunningSceneId;
    }

    final public function get nextSceneId() : String {
        return m_nNextSceneId;
    }

    final public function set nextSceneId( value : String ) : void {
        m_nNextSceneId = value;
    }

    final public function set nextSpawnLocation( value : CVector2 ) : void {
        m_theNextSpawnLocation = value;
    }

    final public function get graphicsFramework() : CFramework {
        return m_pGraphicsFramework;
    }

    final public function set graphicsFramework( value : CFramework ) : void {
        this.m_pGraphicsFramework = value;
        if ( value ) {
            this.setupFonts();
        }
    }

    final public function get terrainData() : CTerrainData {
        if ( m_pGraphicScene )
            return m_pGraphicScene.terrainData;
        return null;
    }

    public function persistCurrentScene() : void {
        if ( m_pGraphicScene ) {
            this.addPersistScene( m_pGraphicScene.name);
        } else {
            Foundation.Log.logWarningMsg("No Graphics Scene expects to persist.")
        }
    }

    public function addPersistScene( id : Object ) : void {
        if ( !id )
            return;

        if ( m_thePersistScenesIds.indexOf( id ) == -1 ) {
            m_thePersistScenesIds.push( id );
        }
    }

    public function removePersistScene( id : Object ) : void {
        if ( !id )
            return;
        var idx : int = m_thePersistScenesIds.indexOf( id );
        if ( idx > -1 ) {
            m_thePersistScenesIds.splice( idx, 1 );
        }
    }

    protected function setupFonts() : void {
        if ( m_bFontReady || m_bFontRegistering )
            return;

        m_bFontRegistering = true;

        var fightFont : CBitmapFont = new CBitmapFont( "FightText" );
        fightFont.loadFile( "assets/ui/font/FightText.xml", onFightLoadFinish );

        var shinningnums : CBitmapFont = new CBitmapFont( "shinningnums" );
        shinningnums.loadFile( "assets/ui/font/shinningnums.xml", onFightLoadFinish );

        var shinningnums1 : CBitmapFont = new CBitmapFont( "shinningnums1" );
        shinningnums1.loadFile( "assets/ui/font/shinningnums1.xml", onFightLoadFinish );

        var criticalnums : CBitmapFont = new CBitmapFont( "criticalnum" );
        var criticalnums1 : CBitmapFont = new CBitmapFont( "criticalnum1" );

        criticalnums.loadFile( "assets/ui/font/criticalnumbers.xml", onFightLoadFinish );
        criticalnums1.loadFile( "assets/ui/font/criticalnumbers1.xml", onFightLoadFinish );

        var greenBitmapNums : CBitmapFont = _loadFont( "GreenNumbers", "assets/ui/font/healnumbers.xml", onFightLoadFinish );

        var enNum : CBitmapFont = _loadFont("ennumbers", "assets/ui/font/ennumbers.xml" , onFightLoadFinish );
        var enCritNum : CBitmapFont = _loadFont("encriticalnum","assets/ui/font/encriticalnumbers.xml", onFightLoadFinish );

        _loadFont("txvipfont", "assets/ui/font/txvipfont.xml",onFightLoadFinish );
        _loadFont("clipvip" , "assets/ui/font/clipvip.xml" , onFightLoadFinish );

        function onFightLoadFinish( font : CBitmapFont, iReturn : int ) : void {
            m_pGraphicsFramework.spriteSystem.registerFont( font );
        }

        var font : CBitmapFont = new CBitmapFont( "Numbers" );
        font.loadFile( "assets/ui/font/Numbers.xml", onFontLoadFinished );
        function onFontLoadFinished( font : CBitmapFont, iReturn : int ) : void {
            m_pGraphicsFramework.spriteSystem.registerFont( font );
            m_pGraphicsFramework.spriteSystem.registerFont( new CTrueTypeFont( "宋体" ) );
            m_pGraphicsFramework.spriteSystem.registerFont( new CTrueTypeFont( "黑体" ) );
            m_bFontReady = true;
            makeStarted();
        }


    }

    private function _loadFont( fontName : String, url : String, onFinish : Function = null ) : CBitmapFont {
        var bitmapFont : CBitmapFont = new CBitmapFont( fontName );
        bitmapFont.loadFile( url, onFinish );
        return bitmapFont;
    }

    /** @inheritDoc */
    override protected function onSetup() : Boolean {
        if ( !m_bInitialized ) {
            m_bInitialized = true;
            m_fTimeElapsed = 0;
            m_thePersistScenes = {};
            m_thePersistScenesIds = new <Object>[];

            if ( this.m_pGraphicsFramework ) {
                this.setupFonts();
            }

            CBaseObject.SORT_TYPE = 1;
        }
        return false;
    }

    override protected function onShutdown() : Boolean {
        m_fTimeElapsed = 0;
        return true;
    }

    override protected function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );

        // NOTE: 设定阴影模式，指定阴影纹理路径
        if ( m_pGraphicsFramework ) {
            m_pGraphicsFramework.setShadowMode( 1, "assets/scene/shadow_circle", 1.25 );
        }
    }

    public function addDisplayObject( display : CObject, layer : int = -1 ) : void {
        CAssertUtils.assertNotNull( m_pGraphicScene, "Scene is null." );

        if ( -1 == layer ) {
            m_pGraphicScene.addObjectToEntityLayer( display );
        } else {
            m_pGraphicScene.addObjectToLayer( layer, display );
        }
    }

    public function removeDisplayObject( display : CObject, layer : int = -1 ) : void {
        if ( -1 == layer && m_pGraphicScene ) {
            m_pGraphicScene.removeObjectFromEntityLayer( display );
        } else {
            m_pGraphicScene.removeObjectFromLayer( layer, display );
        }
    }

    protected function createGraphicScene( sceneName : String ) : void {
        m_bCfgReady = m_bReady = false;

        if ( m_pGraphicScene && m_thePersistScenesIds.indexOf( m_pGraphicScene.name) > -1 ) {
            // Need persisted.
            if ( m_thePersistScenes[ m_pGraphicScene.name] as CScene ) {
                CAssertUtils.assertEquals( m_thePersistScenes[ m_pGraphicScene.name ], m_pGraphicScene );
            } else {
                m_thePersistScenes[ m_pGraphicScene.name ] = m_pGraphicScene;
            }

            m_pGraphicScene.enabled = false;
            m_pGraphicScene = null;
        }

        if ( m_pGraphicScene )
            m_pGraphicScene.dispose();

        if ( m_thePersistScenesIds.indexOf( sceneName ) > -1 ) {
            CAssertUtils.assertNotNull( m_thePersistScenes[ sceneName ] as CScene );
            m_pGraphicScene = m_thePersistScenes[ sceneName ] as CScene;
        } else {
            m_pGraphicScene = new CScene( this.m_pGraphicsFramework );
        }

        m_pGraphicScene.enabled = true;
        m_pGraphicScene.cameraEnabled = false;

        if ( m_pGraphicScene.isLoadFinished() && !m_pGraphicScene.isLoading() ) {
            // The persisted graphics scene instead.
            onGraphicSceneCfgLoadComplete();
        } else {
            var vPath : CPath = new CPath( "assets/scene/" + sceneName + "/" + sceneName + ".json" );
            m_pGraphicScene.loadFile( vPath.full(), ELoadingPriority.CRITICAL, onGraphicSceneCfgLoadComplete );
        }
    }

    protected function onGraphicSceneCfgLoadComplete( ... args ) : void {
        m_bCfgReady = true;

        m_pGraphicScene.mainCamera.setOffset( m_pGraphicScene.startPoint.x, m_pGraphicScene.startPoint.y );
    }

    //noinspection JSUnusedLocalSymbols
    private function onGraphicSceneReady( ... args ) : void {
        m_bReady = true;

        m_pGraphicScene.cameraEnabled = true;

        dispatchEvent( new Event( SCENE_CFG_COMPLETE, false, false ) );
    }

    /** @inheritDoc */
    public function update( delta : Number ) : void {
        if ( m_nNextSceneId && m_nNextSceneId != m_nRunningSceneId ) {
            createGraphicScene( m_nNextSceneId );
            m_nRunningSceneId = m_nNextSceneId;
            m_nNextSceneId = null;

            dispatchEvent( new Event( SCENE_CHANGED, false, false ) );

            if ( m_theNextSpawnLocation )
                m_pGraphicScene.mainCamera.setOffset( m_theNextSpawnLocation.x, m_theNextSpawnLocation.y );
            m_theNextSpawnLocation = null;
        }

        if ( m_bFollowObjectDirty ) {
            if ( m_pGraphicScene ) {
                var pTarget : CCharacter = this.followObject;

                m_pGraphicScene.setCameraFollowingTarget( pTarget );

                if ( pTarget ) {
                    m_pGraphicScene.setCameraFollowingMode( 1, 3.0, 1.5 );
                    m_pGraphicScene.moveCameraToTargetAtOnce();
                }

                m_pGraphicScene.mainCamera.setOffset( 0, 0 );
                m_theNextSpawnLocation = null;
                m_bFollowObjectDirty = false;
            }
        }

        m_fTimeElapsed += delta;

        if ( m_bCfgReady && !m_bReady &&
                m_pGraphicScene && m_pGraphicScene.isLoadFinished() && m_pGraphicScene.cameraEnabled == false ) {
            // waiting the CRITICAL priority loaders all completed.
            var iCntHighLoaders : int =
                    CResourceLoaders.instance().countAllLoaderInstancesWithPriority(
                            ELoadingPriority.CRITICAL );
            if ( iCntHighLoaders == 0 ) {
                onGraphicSceneReady();
            }
        }

        if ( m_pGraphicsFramework ) {
            m_pGraphicsFramework.update( delta );
        }
    }

    final public function get followObject() : CCharacter {
        if ( m_pFollowObject ) {
            var o : CCharacter;
            for ( o in m_pFollowObject ) {
                return o;
            }
        }
        return null;
    }

    final public function setFollowObject( obj : CCharacter ) : void {
        var pCur : CCharacter = this.followObject;
        if ( pCur == obj )
            return;

        if ( !obj ) {
            m_pFollowObject = null;
        } else {
            m_pFollowObject = new Dictionary( true );
            m_pFollowObject[ obj ] = true;
        }
        m_bFollowObjectDirty = true;
    }

    public function get mainCamera() : CCamera {
        if ( !m_pGraphicScene ) return null;
        return this.m_pGraphicScene.mainCamera;
    }

    final public function get scene() : CScene {
        return m_pGraphicScene;
    }

}
}
