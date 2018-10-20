//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scene {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CTimeDog;
import QFLib.Framework.CFX;
import QFLib.Framework.CFramework;
import QFLib.Framework.CObject;
    import QFLib.Framework.CScene;
    import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.Event;
import flash.utils.Dictionary;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.core.CGameObject;
import kof.game.core.CSubscribeBehaviour;
import kof.game.scene.CSceneHandler;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;
import kof.util.CAssertUtils;

/**
 * 场景组件
 *
 * @author Jeremy (jeremy@qifun.com
 */
public class CSceneMediator extends CSubscribeBehaviour {

    /** @private */
    private var m_pSceneFacade : ISceneFacade;
    /** @private */
    private var m_pFlashTimeDog : CTimeDog;
    /** @private */
    private var m_pFlashIntervalTimeDog : CTimeDog;
    /** @private */
    private var m_pBgColorInTurns : Vector.<uint>;

    /**
     * Creates a new CSceneMediator.
     */
    public function CSceneMediator( pSceneFacade : ISceneFacade ) {
        super( "scene" );
        this.m_pSceneFacade = pSceneFacade;
    }

    override public function dispose() : void {
        super.dispose();
        this.m_pSceneFacade = null;
    }

    override protected function onEnter() : void {
        super.onEnter();
        _attackEventMediator();
    }

    override protected function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected function onExit() : void {
        super.onExit();
        _detackeEventMediator();
    }

    [Inline]
    final public function get graphicFramework() : CFramework {
        return m_pSceneFacade.scenegraph.graphicsFramework;
    }

    [Inline]
    final public function get scene() : CScene {
        return m_pSceneFacade.scenegraph.scene;
    }

    [Inline]
    final public function isWalkable( f3DPosX : Number, f3DPosZ : Number, f3DHeight : Number = NaN ) : Boolean {
        return m_pSceneFacade.isWalkable( f3DPosX, f3DPosZ, f3DHeight );
    }
    [Inline]
    public function isBlockedGrid(gridx:int, gridy:int) : Boolean {
        return m_pSceneFacade.scenegraph.scene.isBlockedGrid(gridx, gridy);
    }

    [Inline]
    final public function toPixel( x : int, y : int ) : CVector2 {
        return m_pSceneFacade.toPixel( x, y );
    }

    /**
     * will modify gridList
     */
    final public function transToPixelList(objRef:CObject, gridList:Array) : void {
        if (gridList == null || gridList.length == 0) return ;
        var gridPos:CVector2;
        var pixelPos:CVector2;
        var pixelPos3D:CVector3;
        var len:int = gridList.length;
        for (var i:int = 0; i < len; i++) {
            gridPos = gridList[i];
            pixelPos3D = m_pSceneFacade.getGridPosition( gridPos.x, gridPos.y );
            gridList[i].setValueXY( pixelPos3D.x, pixelPos3D.z );
            //pixelPos = m_pSceneFacade.toPixel( gridPos.x, gridPos.y );
            //pixelPos3D = CObject.get3DPositionFrom2D(objRef, pixelPos.x, pixelPos.y, 0);
            //pixelPos.setValueXY(pixelPos3D.x, pixelPos3D.z);
            //gridList[i] = pixelPos;
        }
    }

    [Inline]
    final public function toGrid( x : Number, y : Number, f3DHeight : Number = 0.0 ) : CVector2 {
        return m_pSceneFacade.toGrid( x, y, f3DHeight );
    }

    [Inline]
    final public function getTerrainHeight( f3DPosX : Number, f3DPosY : Number ) : Number {
        return m_pSceneFacade.getTerrainHeight( f3DPosX, f3DPosY );
    }

    [Inline]
    final public function findPlayer( id : Number ) : CGameObject {
        return m_pSceneFacade.findPlayer( id );
    }

    [Inline]
    final public function findMonster( id : Number ) : CGameObject {
        return m_pSceneFacade.findMonster( id );
    }

    final public function findMissile( seqID : Number ) : CGameObject{
        return m_pSceneFacade.findMissile( seqID );
    }

    final public function findGameObj( type : int , id : Number ) : CGameObject{
        if( type == CCharacterDataDescriptor.TYPE_MONSTER ){
            return findMonster( id );
        }

        if( type == CCharacterDataDescriptor.TYPE_PLAYER ){
            return findPlayer( id );
        }

        Foundation.Log.logTraceMsg( " Can not Find Target that Type : " + type + " ID : " + id );

        return null;
    }

    public function addDisplayObject( pDisplayObject : CObject, layer : int = -1 ) : void {
        this.m_pSceneFacade.scenegraph.addDisplayObject( pDisplayObject, layer );
    }

    /**
     * 屏幕镜头抖动
     * @param fOffX 偏移X
     * @param fOffY 偏移Y
     * @param fDuaration 持续时间
     * @param fDeltaTimePeriod
     */
    public function shakeXY( fOffX : Number, fOffY : Number, fDuaration : Number, fDeltaTimePeriod : Number = 0.02 ) : void {
        m_pSceneFacade.shake( fOffX, fOffY, fDuaration, fDeltaTimePeriod );
    }

    /**
     *
     * @param vCenter
     * @param vExt
     * @param fDurationTime
     */
    public function zoomCamare( vCenter : CVector2, vExt : CVector2, fDurationTime : Number ) : void {
        m_pSceneFacade.zoomCenterExt( vCenter, vExt, fDurationTime );
    }

    public function unZoom() : void {
        m_pSceneFacade.unZoom();
    }

    public function zoomShake( fDens: Number , fDuration : Number , fFreq : Number ) : void
    {
        m_pSceneFacade.zoomShake(fDens  ,  fDuration , fFreq );
    }

    public function attachFXToScene( pFx : CFX , flip : Boolean = false, flipSelf : Boolean = true, type : int = -1 ,
                                     position : CVector3 = null ,scale : CVector3 = null, isTopDisplaye : Boolean = false ) : void
    {
        CAssertUtils.assertNotNull( pFx );

        pFx.attachToTarget( m_pSceneFacade.scenegraph.scene ,flip , flipSelf, type , position , scale , isTopDisplaye);
    }
    /**
     * 技能打击效果设定好的震屏效果
     * @param type
     */
    public function shakeByType( type : int ) : void {
        var offSetX : Number = 6.0;
        var offSetY : Number = 6.0;
        var fDuration : Number = 0.06;
        var fFPS : Number;

        if ( type == 0 ) return;
        switch ( type ) {
            case  1 :
                offSetX = offSetY = 6.0;
                fDuration = 0.06;
                break;
            case  2 :
                offSetX = offSetY = 9.0;
                fDuration = 0.1;
                break;
            case  3 :
                offSetX = offSetY = 15.0;
                fDuration = 0.12;
                break;
        }

        shakeXY( offSetX * 5, offSetY * 5, fDuration );
    }

    /**
     * 分派场景广播事件
     */
    public function sendEvent( event : Event ) : Boolean {
        return m_pSceneFacade.dispatchEvent( event );
    }

    /**
     * 慢镜头给定一段时间
     */
    public function slowMotionWithDuration( fDuration : Number, fFactor : Number = 0.2, pfnFinished : Function = null ) : void {
        m_pSceneFacade.slowMotionWithDuration( fDuration, fFactor, pfnFinished );
    }

    /**
     * 红白闪
     *
     * @param fDuration 时长
     * @param fInterval 间隔
     * @param color1 颜色1
     * @param color2 颜色2
     */
    public function backgroundFlashInTurns( fDuration : Number, fInterval : Number, color1 : uint, color2 : uint ) : void {
        m_pSceneFacade.scenegraph.scene.setAllLayersVisible( false );
        m_pSceneFacade.scenegraph.scene.setEntityLayerVisible( true );
        m_pSceneFacade.scenegraph.graphicsFramework.renderer.backGroundColor = color1;

        if ( m_pFlashIntervalTimeDog )
            m_pFlashIntervalTimeDog.dispose();
        if ( m_pFlashTimeDog )
            m_pFlashTimeDog.dispose();

        m_pFlashIntervalTimeDog = new CTimeDog();
        m_pFlashIntervalTimeDog.start( fInterval );

        m_pFlashTimeDog = new CTimeDog( _onFlashTimeEnd );
        m_pFlashTimeDog.start( fDuration );

        m_pBgColorInTurns = new <uint>[];
        m_pBgColorInTurns.push( color2 );
        m_pBgColorInTurns.push( color1 );

        function _onFlashTimeEnd() : void {
            if ( m_pFlashIntervalTimeDog )
                m_pFlashIntervalTimeDog.dispose();
            m_pFlashIntervalTimeDog = null;

            if ( m_pFlashTimeDog )
                m_pFlashTimeDog.dispose();
            m_pFlashTimeDog = null;

            m_pBgColorInTurns = null;

            if ( m_pSceneFacade ) {
                m_pSceneFacade.scenegraph.graphicsFramework.renderer.backGroundColor = 0;
                m_pSceneFacade.scenegraph.scene.setAllLayersVisible( true );
            }
        }
    }

    /** @inheritDoc */
    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( m_pFlashIntervalTimeDog ) {
            m_pFlashIntervalTimeDog.update( delta );
            if ( !m_pFlashIntervalTimeDog.running ) { // just hit the interval.
                m_pFlashIntervalTimeDog.start();

                m_pSceneFacade.scenegraph.graphicsFramework.renderer.backGroundColor = m_pBgColorInTurns[ 0 ];
                m_pBgColorInTurns = m_pBgColorInTurns.reverse();
            }
        }

        if ( m_pFlashTimeDog ) {
            m_pFlashTimeDog.update( delta );
        }
    }

    public function findHeroAsList() : Vector.<CGameObject> {

        return m_pSceneFacade.findHeroAsList();
    }

    public function  swapHeroShowIndex( fromIndex : int , toIndex : int = 0) :void{
        return m_pSceneFacade.swapHeroShowIndex(fromIndex , toIndex);
    }

    public function updateCharacter( data : Object ) : void {
        var pSystem : CSceneSystem = m_pSceneFacade as CSceneSystem;
        if ( pSystem ) {
            var pHandler : CSceneHandler = pSystem.handler as CSceneHandler;
            if ( pHandler ) {
                pHandler.testCharacterUpdate( data );
            }
        }
    }

    private function _attackEventMediator() : void {
        const pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.OUT_OF_VIEW, _characterOutOfView );
            pEventMediator.addEventListener( CCharacterEvent.BE_IN_VIEW, _characterInView );
        }
    }

    private function _detackeEventMediator() : void {
        const pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.OUT_OF_VIEW, _characterOutOfView );
            pEventMediator.removeEventListener( CCharacterEvent.BE_IN_VIEW, _characterInView );
        }
    }

    private function _characterOutOfView( e : Event ) : void {
        var pSystem : CSceneSystem = m_pSceneFacade as CSceneSystem;
        if ( pSystem ) {
            var pHandler : CSceneHandler = pSystem.handler as CSceneHandler;
            if ( pHandler )
                pHandler.notifyCharacterOutView( owner );
        }
    }

    private function _characterInView( e : Event ) : void {
        var pSystem : CSceneSystem = m_pSceneFacade as CSceneSystem;
        if ( pSystem ) {
            var pHandler : CSceneHandler = pSystem.handler as CSceneHandler;
            if ( pHandler )
                pHandler.notifyCharacterInView( owner );
        }
    }

}
}
