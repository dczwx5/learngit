//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.scene {

import QFLib.Foundation.CTimeDog;
import QFLib.Framework.CFramework;
import QFLib.Graphics.Scene.CCamera;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.Event;

import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.framework.IApplication;
import kof.framework.events.CEventPriority;
import kof.game.audio.IAudio;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.fight.emitter.CMissileContainer;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.core.CGameObject;
//import kof.game.scene.grid.CSceneGridHandler;
//import kof.game.scene.grid.astar.CAStar;
import kof.message.Scene.ClientReadyRequest;
import kof.util.CAssertUtils;

/**
 * 场景系统，关乎一切场景或相关逻辑
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSceneSystem extends CAppSystem implements IUpdatable, ISceneFacade {

    /** @private */
    private var m_pRendering : CSceneRendering;
    /** @private */
    private var m_pSpawner : CSpawnHandler;
    /** @private */
    private var m_pGraphicsFramework : CFramework;
    /** @private */
    private var m_pObjectLists : CSceneObjectLists;
    /** @private */
    private var m_pSlowMotionTimeDog : CTimeDog;

    private var m_missileContainer : CMissileContainer;

    /**
     * Creates a new CSceneSystem.
     */
    public function CSceneSystem() {
        super();
    }

    /** @inheritDoc */
    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            ret = ret && addBean( (m_pObjectLists = new CSceneObjectLists()) );
            //ret = ret && addBean( new CSceneGridHandler() );
            //ret = ret && addBean( new CAStar() );
            ret = ret && addBean( (m_pRendering = new CSceneRendering()) ); // Renderer handling
            ret = ret && addBean( (m_pSpawner = new CSpawnHandler()) );
            ret = ret && addBean(m_missileContainer = new CMissileContainer() );
            ret = ret && addBean( new CSceneHandler() );

            m_pRendering.addEventListener( CSceneRendering.SCENE_CFG_COMPLETE, _onSceneCfgCompleteEventHandler, false,
                    CEventPriority.DEFAULT_HANDLER, true );

            if ( !m_pGraphicsFramework ) {
                m_pGraphicsFramework = new CFramework();
                m_pGraphicsFramework.initialize( stage.flashStage, _onGraphicsFrameworkCompleted );
                m_pGraphicsFramework.audioManager = (stage.getSystem( IAudio ) as IAudio).audioManager;
            }
        }

        /** @private */
        function _onGraphicsFrameworkCompleted() : void {
            m_pRendering.graphicsFramework = m_pGraphicsFramework;
        }

        return ret;
    }

    /** @inheritDoc */
    override protected function onShutdown() : Boolean {
        m_pObjectLists = null;
        m_pGraphicsFramework = null;
        m_pSpawner = null;
        m_pRendering = null;
        heroShowList = null;
        return true;
    }

    final public function get graphicsFramework() : CFramework {
        return m_pGraphicsFramework;
    }

    /** @inheritDoc */
    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );

        // 客户端Stage初始完毕自动进入场景
//        var pRoleData : Object = appStage.configuration.getRaw( "role.data" ) || {mapID : 0, x : 0, y : 0};
//        if ( pRoleData.mapID ) {
//            (handler as CSceneHandler).enterTown( pRoleData.mapID, pRoleData.x, pRoleData.y );
//        } else {
//            LOG.logErrorMsg( "RoleData's mapID was invalid !!!" );
//        }
    }

    /** @private catching when scene's cfg load completed. */
    final private function _onSceneCfgCompleteEventHandler( event : Event ) : void {
        _onClientReady();

//        m_pRendering.dispatchEvent( new Event( CSceneRendering.SCENE_CLIENT_READY ) );
    }

    private function _onClientReady() : void {
        var sceneHandler : CSceneHandler = handler as CSceneHandler;
        // Notify to server for ready.
        var readyRequest : ClientReadyRequest = new ClientReadyRequest();
        readyRequest.time = new Date().valueOf();
        sceneHandler.networking.send( readyRequest );
        // _spawnHero();
    }

    /** @private */
    private function _spawnHero() : void {
        LOG.logTraceMsg( "Spawn Hero." );

        var roleData : Object = stage.configuration.getRaw( "role.data" ) || {};
        roleData.type = roleData.type || 1;
        roleData.id = roleData.roleID;

        var hero : CGameObject = (handler as CSceneHandler).addPlayer( roleData );
        CAssertUtils.assertNotNull( hero, "Hero is null." );

        (handler as CSceneHandler).followObject( hero );

        // Retrieves CPlayHandler and set the hero reference to CPlayHandler under control.
        var gameSystem : CECSLoop = stage.getSystem( CECSLoop ) as CECSLoop;
        var playHandler : CPlayHandler = gameSystem.getBean( CPlayHandler ) as CPlayHandler;
        if ( playHandler ) {
            playHandler.hero = hero;
        }
    }

    [Inline]
    final public function get allGameObjectIterator() : Object {
        return m_pObjectLists.iterator;
    }

    [Inline]
    final public function findHeroAsList() : Vector.<CGameObject> {
        if( heroShowList == null || heroShowList.length == 0){
            heroShowList = m_pObjectLists.getOwnHeroList()/**.sort(function(o1 : CGameObject , o2 : CGameObject):Boolean{
                return CCharacterDataDescriptor.getOperateIndex(o1.data) < CCharacterDataDescriptor.getOperateIndex( o2.data);
            })*/;
        }
        return heroShowList;
    }

    final public function swapHeroShowIndex( swapfrom : int , to : int = 0 ) : void {
        popAndQueue(swapfrom);
        return;
        if( heroShowList == null || heroShowList.length <= 1) return;
        if( swapfrom >= heroShowList.length  || to >= heroShowList.length  ) return;
        var swapObj : CGameObject = heroShowList[swapfrom];
        heroShowList[swapfrom] = heroShowList[to];
        heroShowList[to] = swapObj;
    }

    final private function popAndQueue( dir : int ) : void{
        var pop : Vector.<CGameObject>;
        if( dir == 1 ) {
           pop  = heroShowList.splice( 0 , 1);
//           heroShowList = heroShowList.concat(pop);
            for( var i0 : int = 0 ;i0<pop.length;i0++) {
                heroShowList.push(pop[i0]);
            }
        }else if(dir == -1){
            pop  = heroShowList.splice( 0, heroShowList.length - 1);
            for( var i1 : int = 0 ;i1<pop.length;i1++) {
                heroShowList.push(pop[i1]);
            }
//            heroShowList = heroShowList.concat(pop);
        }
    }

    private var heroShowList : Vector.<CGameObject>;
    public function initialHeroShowList() : void{
        if( heroShowList)
            heroShowList.splice(0,heroShowList.length);
    }

    [Inline]
    final public function findTargetHeroList( pTarget : CGameObject ) : Vector.<CGameObject> {
        if ( !pTarget )
            return null;
        var operateSide : int = CCharacterDataDescriptor.getOperateSide( pTarget.data );
        if ( operateSide ) {
            return m_pObjectLists.getGroupedList( operateSide );
        }
        return null;
    }

    [Inline]
    final public function findGameObject( type : int, id : Number ) : CGameObject {
        return m_pObjectLists.getGameObject( type, id );
    }

    [Inline]
    final public function findPlayer( roleID : Number ) : CGameObject {
        return m_pObjectLists.getPlayer( roleID );
    }

    [Inline]
    final public function findMonster( monsterID : Number ) : CGameObject {
        return m_pObjectLists.getMonster( monsterID );
    }

    [inline]
    final public function  findMissile( missileSeq : Number ) : CGameObject{
        return m_missileContainer.findMissileByUniqID( missileSeq );
    }

    [inline]
    final public function findAllMissile() : Object{
        if( m_missileContainer )
            return m_missileContainer.iterator;
        return null;
    }

    [Inline]
    final public function findAllMonster() : Vector.<Object> {
        return m_pObjectLists.getMonsters();
    }

    [Inline]
    final public function get gameObjectIterator() : Object {
        return m_pObjectLists.iterator;
    }

    [Inline]
    final public function get playerIterator() : Object {
        return m_pObjectLists.getPlayerList();
    }

    [Inline]
    final public function get monsterIterator() : Object {
        return m_pObjectLists.getMonsters();
    }

    [Inline]
    final public function findMapObject( mapObjectID : Number ) : CGameObject {
        return m_pObjectLists.getMapObject( mapObjectID );
    }

    [Inline]
    final public function get NPCIterator() : Object {
        return m_pObjectLists.getNPCs();
    }

    [Inline]
    final public function findNPC( id:Number ) : CGameObject {
        return m_pObjectLists.getNPC(id);
    }

    [Inline]
    final public function findNPCByPrototypeID( id:Number ) : CGameObject {
        return m_pObjectLists.getNPCByPrototypeID(id);
    }

    /**获取所有玩家*/
    [Inline]
    final public function findAllPlayer() : Vector.<Object> {
        return m_pObjectLists.getPlayerList();
    }

    /**获取所有场景物件*/
    [Inline]
    final public function findAllMapObjects() : Vector.<Object> {
        return m_pObjectLists.getMapObjects();
    }

    /**
     * @inheritDoc
     */
    final public function get scenegraph() : CSceneRendering {
        return m_pRendering;
    }

    /**
     * Makes the mainCam following the specified CGameObject <code>obj</code>.
     */
    [Inline]
    final public function followObject( obj : CGameObject ) : void {
        (handler as CSceneHandler).followObject( obj );
    }

    /**
     * A facade function delegate for CSceneHandler#isWalkable(...).
     *
     * @param f3DPosX The x-axis value in 3D-world.
     * @param f3DPosZ The z-axis value in 3D-world.
     */
    [Inline]
    final public function isWalkable( f3DPosX : Number, f3DPosZ : Number, f3DHeight : Number = NaN ) : Boolean {
        return (handler as CSceneHandler).isWalkable( f3DPosX, f3DPosZ, f3DHeight );
    }

    /**
     * A facade function delegate for CSceneHandler#toPixel(...).
     *
     * @param i2DGridX The x-axis value in grid.
     * @param i2DGridY The y-axis value in grid.
     */
    [Inline]
    final public function toPixel( i2DGridX : int, i2DGridY : int ) : CVector2 {
        return (handler as CSceneHandler).toPixel( i2DGridX, i2DGridY );
    }

    /**
     * A facade function delegate for CSceneHandler#toGrid(...).
     *
     * @param f3DPosX The x-axis value in pixel.
     * @param f3DPosY The y-axis value in pixel.
     * @param f3DHeight The height.
     */
    [Inline]
    final public function toGrid( f3DPosX : Number, f3DPosY : Number, f3DHeight : Number = 0.0 ) : CVector2 {
        return (handler as CSceneHandler).toGrid( f3DPosX, f3DPosY, f3DHeight );
    }

    final public function getTerrainHeight( f3DPosX : Number, f3DPosY : Number ) : Number {
        return (handler as CSceneHandler).getTerrainHeight( f3DPosX, f3DPosY );
    }

    final public function getGridPosition( i2DPosX : int, i2DPosY : int ) : CVector3 {
        return (handler as CSceneHandler).getGridPosition( i2DPosX, i2DPosY );
    }

    public function slowMotionWithDuration( fDuration : Number, fFactor : Number, pfnFinished : Function = null ) : void {
        var pApp : IApplication = stage.getBean( IApplication ) as IApplication;
        if ( pApp ) {
            pApp.deltaFactor = fFactor;
        }

        m_pSlowMotionTimeDog = new CTimeDog( _onSlowMotionEnd );
        m_pSlowMotionTimeDog.start( fDuration );

        function _onSlowMotionEnd() : void {
            var pApp : IApplication = stage.getBean( IApplication ) as IApplication;
            if ( pApp ) {
                pApp.deltaFactor = 1.0;
            }

            if ( m_pSlowMotionTimeDog ) {
                m_pSlowMotionTimeDog.dispose();
                m_pSlowMotionTimeDog = null;
            }

            if ( pfnFinished != null )
                pfnFinished();
        }
    }

    /** @inheritDoc */
    public function update( delta : Number ) : void {
        if ( !m_pRendering || !m_pRendering.graphicsFramework )
            return;

        if ( m_pSlowMotionTimeDog )
            m_pSlowMotionTimeDog.update( delta );

        if ( m_pSpawner )
            m_pSpawner.update( delta );

        if ( handler is IUpdatable )
            IUpdatable( handler ).update( delta );

        if ( m_pRendering )
            m_pRendering.update( delta );
    }

    public function shake( offSetX : Number, offSetY : Number, fDuaration : Number, fDeltaTimePeriod : Number = 0.02 ) : void {
        pCamera.shakeXY( offSetX, offSetY, fDuaration, fDeltaTimePeriod );
    }

    /**
     *
     * @param vCenter  以该中心点zoom
     * @param vExt 相对于当前camera的的比率
     * @param fTimeDuration
     */
    public function zoomCenterExt( vCenter : CVector2 = null, vRateExt : CVector2 = null, fTimeDuration : Number = -1.0 ) : void {
        var center : CVector2 = vCenter;
        var ext : CVector2;

//        pCamera.unZoom();

        if ( vCenter == null )
            center = new CVector2( pCamera.center.x, pCamera.center.y );

        if ( null == vRateExt )
            ext = new CVector2( 1, 1 );
        else
            ext = vRateExt.clone();

        ext.x = pCamera.ext.x * ( 1 + ext.x );
        ext.y = pCamera.ext.y * ( 1 + ext.y );

        pCamera.moveToTargetAtOnce();
        pCamera.zoomCenterExt( false, center, ext, fTimeDuration );
    }

    public function zoomShake(fIn : Number ,  fDurantion : Number , fFreq : Number  ) : void{
        pCamera.zoomShake( fIn , fDurantion , fFreq );
    }

    public function unZoom() : void {
        pCamera.unZoom();
    }

    public function get pCamera() : CCamera {
        return scenegraph.scene.mainCamera;
    }

}
}
