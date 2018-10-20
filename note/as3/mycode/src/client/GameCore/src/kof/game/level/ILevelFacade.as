//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.level {

import flash.events.Event;
import flash.geom.Rectangle;

import kof.game.bubbles.IBubblesFacade;
    import kof.table.Level;

    public interface ILevelFacade {
    /**
     * @param entityID
     * @return {x, y}...以后会扩展
     */
    function getAppearData( entityID : int ) : Object;

    function getHerotAppearData( entityID : int ) : Object;

    // 播放背景音乐
    function playBgMusic() : void ;

    function getNpcByID(id:int):Object;

    function showSceneClickFX(x:Number, y:Number, z:Number):void;

    function hideSceneClickFX():void;

    function isInstancePass() : Boolean;

    function listenEvent( func : Function ) : void;

    function unListenEvent( func : Function ) : void;

    function getBubblesFacade() : IBubblesFacade;

    function getSingPoins( id : int ) : Object;

    function getHideFootEffect( entityID : int ) : Boolean;

    function isPlayingScenario() : Boolean;

    function get isStart() : Boolean;

    function get curTrunkID():int;

    /**
     * 获取警戒范围{frontDistance,backDistance}
     * */
    function getWarnRange( entityID : int ) : Object;

    /**
     * 获取区域触发器范围{location:{x:111,y:111},size:{x:111,y:111}}
     * */
    function getTriggerRange( entityID : int ) : Object;

    /**
     * 获取trunk目标
     * targetType : int 目标类型
     * target : Array 目标数组
     * */
    function getTrunkGoals() : Object;

    /**
     * 获取转送门
     * */
    function getPortal() : Array;

    /**
    * 获取ai巡逻路经[{x,y},{x,y}]
    * */
    function getAIPosition( entityID : int ) : Array;

    function getCurReallyTrunkRect() : Rectangle;
    function getCurTrunkRec():Rectangle;
    /**
     * 查询阵营关系值
     *
     * @param myCampID 我方阵营ID
     * @param targetCampID 对方阵营ID
     * @return 关系值
     */
    function findCampRefValue( myCampID : int, targetCampID : int ) : int;

    /**
     * 判定是否可以进行攻击
     *
     * @param myCampID 我方阵营ID
     * @param targetCampID 敌方阵营ID
     * @return true or false
     */
    function isAttackable( myCampID : int, targetCampID : int ) : Boolean;

    /**
     * 判定是否是友方关系
     *
     * @param myCampID 我方阵营ID
     * @param targetCampID 敌方阵营ID
     * @return true or false
     */
    function isFriendly( myCampID : int, targetCampID : int ) : Boolean;

    /**
     * 向关卡发送事件
     *
     * @param event 事件
     * @return true or false
     */
    function sendEvent( event : Event ) : Boolean;

    function showMasterComingCommon(closeCallback:Function) : void ;
    function get currentLevel() : Level;


}
}
