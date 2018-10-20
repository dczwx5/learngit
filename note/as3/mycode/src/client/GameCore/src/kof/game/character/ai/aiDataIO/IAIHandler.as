//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/31.
 * Time: 18:53
 */
package kof.game.character.ai.aiDataIO {

    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.CResource;

    import flash.events.IEventDispatcher;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import kof.framework.CAppSystem;

    import kof.game.character.ai.CAIComponent;
    import kof.game.core.CGameObject;
    import kof.table.AI;
    import kof.table.Level;

    public interface IAIHandler extends IEventDispatcher {
        function get componentResource() : CResource;

        //-----------------------------------------
        //-------------------移动相关---------------
        //-----------------------------------------
        /**相对自己移动*/
        function move( owner : CGameObject, ptArr : Array, offsetX : Number, offsetY : Number, moveEndCallBack : Function ) : Boolean;

        /**相对目标移动*/
        function moveTo( owner : CGameObject, distanceX : Number, distanceY : Number, targetPosition : Point, movetoEndCallBack : Function, type : String, isFarawayAttack : Boolean = false, fleeType : String = "", axesType : String = "" ) : Boolean;

        /**没有攻击目标时移到到某个点*/
        function moveToPos( owner : CGameObject, targetPosition : Point, movetoEndCallBack : Function ) : Boolean;

        /**跟随玩家*/
        function follow( owner : CGameObject, movetoEndCallBack : Function, offsetX : Number = 100, offsetY : Number = 20, followDistance : Number = 150, followType : String = "", followBoolDistance : Boolean = false ) : Boolean;

        /**是否正在移动*/
        function isMoving( owner : CGameObject ) : Boolean;

        /**引怪*/
        function moveAttractMonster( owner : CGameObject, ptArr : Array, offsetX : Number, offsetY : Number, moveEndCallBack : Function ) : Boolean;

        //-------------------------------------------------------
        // -----------------------战斗相关------------------------
        //-------------------------------------------------------
        /**是否处于攻击状态*/
        function isAttacking( owner : CGameObject ) : Boolean;

        /**是否处于防御状态*/
        function isDefensing( owner : CGameObject ) : Boolean;

        /**是否处于受伤状态*/
        function isHurting( owner : CGameObject ) : Boolean;

        /**是否处于倒地状态*/
        function isLaying( owner : CGameObject ) : Boolean;

        /**调用技能攻击*/
        function attackWithSkillID( owner : CGameObject, skillId : int ) : void;

        /**闪避*/
        function dodge( owner : CGameObject ) : Boolean;

        /**无视消耗闪避*/
        function dodgeIgnore( owner : CGameObject ) : void;

        /**判断和玩家的距离，是否在攻击范围内*/
        function judegeDistanceAttack( distanceX : Number, distanceY : Number, onwer : CGameObject ) : Boolean;

        /**直接调用无视消耗放技能**/
        function attackIgnoreWithSkillIdx( owner : CGameObject, skillIdx : int ) : void;

        /**自己是否已经死亡*/
        function isDead( owner : CGameObject ) : Boolean;

        /**将AI面向调整和当前选择的目标一样*/
        function setDirectionToGameObj( owner : CGameObject ) : void;

        /**传送到关卡指定位置*/
        function teleportToPosition( owner : CGameObject, vec : CVector2, callBackFunc : Function ) : void;

        /**清除移动完成的回调函数列表*/
        function clearMoveFinishCallBackFunction(owner:CGameObject):void;

        //-------------------------------------------------------
        // -------------------------功能相关----------------------
        //-------------------------------------------------------
        /**是否主控角色*/
        function isHero( owner : CGameObject ) : Boolean;

        /**是否玩家的小弟*/
        function isTeamMate( owner : CGameObject ) : Boolean;

        /**返回玩家*/
        function getPlayer( aiOwnerObj : CGameObject ) : CGameObject;

        /**获取AI可以攻击的对象*/
        function findAttackable( owner : CGameObject, campType : String, roleType : String, filterCondtion : String, baseOnRole : String, campID : String, serialID : String ) : CGameObject;

        function findAttackableByCriteriaID( owner : CGameObject , criteriaID : int ) : CGameObject;

        /**获取json文件*/
        function getAIJsonID( id : String, aiCompnent : CAIComponent, aiParams : String ) : void;

        /**获取关卡指定位置坐标*/
        function getLevelPosTag( tagName : int ) : Object;

        /**转向某个点的方向*/
        function setDirectionToPoint( owner : CGameObject, ptx : Number, pty : Number ) : void;

        /**设置角色状态*/
        function setCharacterState( owner : CGameObject, stateType : String, bool : Boolean ) : void;

        /**重置角色状态*/
        function resetCharacterState( owner : CGameObject ) : void;

        /**重置霸体*/
        function resetPATI( owner : CGameObject ) : void;

        /**重置刚体*/
        function resetGANGTI( owner : CGameObject ) : void;

        /**重置无敌*/
        function resetWUDI( owner : CGameObject ) : void;

        /**判断角色是否处于某个状态*/
        function getCharacterState( owner : CGameObject, value : int ) : Boolean;

        /**播放对话或者音效*/
        function play( gameObj : CGameObject, type : String, id : int, duration : Number, playMode : String ) : void;

        /**select target search range*/
//        function selectTargetSR():Vector.<CGameObject>;
        /**获取表数据*/
        function getAITableData( id : int ) : AI;

        /**获取技能攻击距离*/
        function getSkillDistance( ower : CGameObject, skillIndex : int ) : Object;

        /**是否触发警戒范围*/
        function isTriggerWarnRange( owner : CGameObject ) : Boolean;

        /**物件状态的切换*/
        function stateChange( owner : CGameObject, state : String = "Idle_2", action : String = "Change_1", hurt : String = "Hurt_1" ) : void;

        /**查找队友角色*/
        function findTeammateObj( owner : CGameObject ) : Vector.<CGameObject>;

        /**找敌方单位在基于角色的范围内是否超过指定数量*/
        function findNuOfEnemyObjInRange( baseObj : CGameObject, rangeValue : Number, nu : int ) : Boolean;

        /**获取所有敌方单位*/
        function findAllEnemyObj( owner : CGameObject ) : Vector.<CGameObject>;

        /**获取关卡trunk的rect信息*/
        function getLevelCurTrunk() : Rectangle;

        /**复活*/
        function revive( owner : CGameObject ) : void;

        /**获取通过当前trunk的目标*/
        function getLevelCurTrunkPass() : Object;

        /**获取传送门*/
        function getLevelPortal() : Array;

        /**trunk是否激活*/
        function get bTrunkActive() : Boolean;

        function set bTrunkActive( value : Boolean ) : void;

        /**trunk目标*/
        function get iTrunkTarget() : int;

        function set iTrunkTarget( value : int ) : void;

        /**获取当前关卡通过的方式*/
        function currentTrunkPassWay() : int;

        /**获取区域触发器的范围*/
        function getEntityRange() : Object;

        /**获取所在system*/
        function get m_system() : CAppSystem;
    }
}
