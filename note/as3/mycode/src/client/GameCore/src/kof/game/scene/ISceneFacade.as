//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.scene {

import QFLib.Graphics.Scene.CCamera;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.IEventDispatcher;

import kof.game.core.CGameObject;

/**
 * 有关场景的Facade API
 * - 主操CGameObject到场景的数据
 * - 场景信息的报告
 * - 场景相关数据逻辑的换算
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ISceneFacade extends IEventDispatcher {

    function get scenegraph() : CSceneRendering;

    function followObject( obj : CGameObject ) : void;

    function isWalkable( f3DPosX : Number, f3DPosZ : Number, f3DHeight : Number = NaN ) : Boolean;

    function toPixel( i2DGridX : int, i2DPosY : int ) : CVector2;

    function toGrid( f3DPosX : Number, f3DPosY : Number, f3DHeight : Number = 0.0 ) : CVector2;

    function getTerrainHeight( f3DPosX : Number, f3DPosY : Number ) : Number;

    function getGridPosition( i2DGridX : int, i2DGridY : int ) : CVector3;

    function findPlayer( id : Number ) : CGameObject;

    function findMonster( id : Number ) : CGameObject;

    function findMissile( id : Number )  : CGameObject;

    function findNPC( id:Number ) : CGameObject;

    function get gameObjectIterator() : Object;

    function get playerIterator() : Object;

    function get monsterIterator() : Object;

    function get NPCIterator() : Object;

    function slowMotionWithDuration( fDuration : Number, fFactor : Number, pfnFinished : Function = null ) : void;

    function shake( offSetX : Number, offSetY : Number , fDuaration : Number ,fDeltaTimePeriod : Number = 0.02) : void;

    //以camera中心为原点缩放
    function zoomCenterExt( vCenter : CVector2 = null,  vExt : CVector2 = null, fTimeDuration : Number = -1.0 ) : void;

    function unZoom() : void ;

    function zoomShake( fDen : Number , fDuration : Number  , fFreq : Number) : void ;


    function get pCamera() : CCamera;

    /**
     * 查找玩家当前的战场上的英雄列表
     */
    function findHeroAsList() : Vector.<CGameObject>;

    function  swapHeroShowIndex( swapfrom : int , to : int = 0 ) : void;

    function  initialHeroShowList() : void;
    /**
     * 根据指定的CGameObject查找所关联的英雄列表
     */
    function findTargetHeroList( pTarget : CGameObject ) : Vector.<CGameObject>;

}
}
