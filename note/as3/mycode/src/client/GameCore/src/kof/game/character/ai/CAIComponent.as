//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/21.
 * Time: 11:47
 */
package kof.game.character.ai {

    import QFLib.AI.CAIObject;
    import QFLib.AI.CAISystem;
    import QFLib.AI.events.CAIEvent;
    import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Foundation.CURLJson;
import QFLib.Math.CVector2;
import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.events.EventDispatcher;
    import flash.geom.Point;
    import flash.utils.Dictionary;
import flash.utils.setTimeout;

import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
    import kof.game.character.CFacadeMediator;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.ai.jsonData.CAIJsonFilePath;
    import kof.game.character.ai.paramsTypeEnum.ESkillBreakType;
    import kof.game.character.fight.skillchain.CCharacterFightTriggle;
    import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.character.state.CCharacterActionStateConstants;
    import kof.game.character.state.CCharacterStateBoard;
    import kof.game.character.state.CCharacterStateMachine;
    import kof.game.core.CGameComponent;
    import kof.game.core.CGameObject;
    import kof.table.AI;
import kof.table.NPC.FUN;

public class CAIComponent extends CGameComponent {

        private var m_bLoaded : Boolean;
        private var m_bLoading : Boolean;
        private var m_aiSystem : CAISystem = null;
        private var m_aiObj : CAIObject = null;
        private var m_sCurrentCastSkillNodeName : String = "";
        private var m_sCurrentEventNodeName : String = "";//（包含时间触发节点和时间触发节点）
        private var m_sCurrentSelfConditionNodeName : String = '';
        private var m_pAIHandler : CAIHandler = null;

        //移动状态,重置回调,当移动过程中，被击中
        public var resetMoveCallBakcFunc : Function = null;

        //AI释放技能状态
        private var m_bUseSkillEnd : Boolean = false;
        private var m_bExcutingSkill : Boolean = false;
        //连招没有命中，是否也继续释放完后续技能
        private var m_pNotHitButAttack : Vector.<int> = new Vector.<int>();

        public var bSkillHit : Boolean = false;//是否击中目标
        public var bComboSkill : Boolean = false;//连击技能(独立技能命中后，是否可以接着释放后续技能)
        public var bCanComboSkill : Boolean = false;//是否可以连击下个技能
        public var bSkillFailed:Boolean=false;//当前技能节点中，有没有技能执行失败的
        public var bSkillCompleteBeforeSkillFailed:Boolean=false;
        public var iSkillIndex : int = 0;
        public var iPreSkillIndex:int=0;
        public var isExcutedNextSkill:Boolean=false;//下一个技能是否已经执行了
        public var bSkillConsume : String = "1";
        public var nWaitTime:Number=0;
        public var bMoveToDistance : Boolean;
        public var piSkillIndexVec : Vector.<int> = new Vector.<int>();
        public var psSkillIndexConsumeVec : Vector.<String> = new Vector.<String>();
        public var pnSkillWaitTimeVec:Vector.<Number> = new Vector.<Number>();
        public var pnSkillMoveToDistance:Vector.<int> = new Vector.<int>();
        public var iSkillCount : int = 0;
        public var useSkillType : String = "";
        public var bSkillExecuteSuccess : Boolean = false;


        public var bTargetAttack : Boolean = false;//目标发起攻击
        public var bTargetHited : Boolean = false;//目标被攻击

        public var aiObjUpdateTime : Number = 0.5;

        /**是否触发事件(作为事件触发的行为（不含时间触发）和常规行为的开关)*/
        public var bWheatherTriggerEvent : Boolean = false;//用于控制常规行为是否可以执行

        //控制事件的开关
        public var dicIdToEventNodeState : Dictionary = new Dictionary();

        //AI事件收发器
        public var eventDispatcher : EventDispatcher = new EventDispatcher();

        private var _pEventMediator : CEventMediator = null;
        private var _pCharacterMediator : CCharacterFightTriggle = null;
        private var _pAttackableCharacter : CCharacterFightTriggle = null;
        private var _pAttackableEventMediator : CEventMediator = null;

        private var _isF9 : Boolean = false;
        //当前可以攻击目标
        private var _pCurrentAttackable : CGameObject = null;
        //当前的主人
        private var _pCurrentMaster : CGameObject = null;

        //是否首次进入切换AI模板，用于默认执行模板第一个AI
        public var bIsFirstInMasterAI : Boolean = true;
        //是否触发了切换AI的事件
        public var bIsTrrigerChangeAIEvent : Boolean = false;
        //当前需要切换AI的id索引数组
        public var iCurrentAIIdToIndexArr : Array = [];
        //当前正在执行的ai的id
        private var iCurrentAIid : int = 0;
        //当前执行事件的优先级
        public var iCrrentEventPriority : int = 0;
        //是否正在向通关目标移动
        public var isMovingPassTarget:Boolean=false;
        /**是否正在移动向传送门*/
        public var isMovingPassWay:Boolean=false;

        /**是否触发警戒*/
        private var _isTriggerWarn : Boolean = false;
        /**首次被攻击，也会触发警戒（因为如果对方是远程角色，发技能打中自己，而对方在自己的警戒范围外，这时也要触发警戒）*/
        private var _bIsBeAttacked : Boolean = false;
        private var _bIsPatrol : Boolean = false;

        private var m_eventManager : CEventManager = null;

        /**是否正在回到玩家身边*/
        public var isBackIngToMaster : Boolean = false;

        /**calculationDurationDamadgeCondition相关*/
        public var calculationDuration : Number = 0;
        public var calculationValue : Number = 0;
        public var calculationType : String;
        public var calculationResult : int = 0;//1是false,2是true
        public var calculationElapsedTime : Number = 0;
        public var recordCurHP : Number = 0;

        /**是否重置角色战斗状态*/
        public var bCanResetState_PATI : Boolean = false;
        public var bCanResetState_GANGTI : Boolean = false;
        public var bCanResetState_WUDI : Boolean = false;
        /**是否一直是某个状态*/
        public var bSetStateAlways_PATI : Boolean = false;
        public var bSetStateAlways_GANGTI : Boolean = false;
        public var bSetStateAlways_WUDI : Boolean = false;

        public var currentAIID : int = 0;
        /**是否触发起身*/
        public var isTrrigerGetUp : Boolean = false;
        /**是否服务器触发*/
        public var isServerTrrigger:Boolean = false;
        /**绘制警戒范围*/
        public var isDrawWarningRange : Boolean = false;

        private var _bAppearComplete : Boolean = false;

        /**用于多个条件判断节点的时候表示开启运行，则自身属性条件的判断条件要根据这个字段标识来evaluator**/
        private var _bSeqConditionPassAndExecuting : Boolean = false;
        private const TEMPLATES_FOR_MUL_ENTERS : Array = ["condbigskill",'condtimecastskill','sequeceteleport'];

        /**随机移动时间限制*/
        public var fRandomMoveTime : Number ;
        private var m_nodeInCoolingTimeMap : CMap;
        public var actionNodeCoolTimeCMap : CMap;
        public var delayTimeMap : CMap;
        public var m_bNeedCoolDown : Boolean;
        private var m_prevTemplateIndex : int;

        public var selectTargetType : int;
        public var selectTargetParam: Number;
        public var selectTargetCountTime : Number;

        /**瞬移时间**/
        public var teleportProcedureAction : ProcedureRunningAction;
        public var teleportList : Array;
        public var telewaittimes : Array;
        public var currentTeleIndex : int;

        public function CAIComponent() {
            super( "AI", true );
            enabled = false;//默认关闭
        }

        private var _bLastEnabled : Boolean = false;
        //是否发生AI组件启用/禁用的切换
        public var isChangeEnable:Boolean = false;

        /**AI组件启动时，重置AI的内部状态，防止托管角色频繁QE切换造成AI内部状态错乱*/
        override protected function onEnabled( value : Boolean ) : void {
            if(_bLastEnabled==value)return;
            resetAllState();
            _bLastEnabled = value;
            isChangeEnable = true;
        }

        public function get eventManager():CEventManager{
            return m_eventManager;
        }

        public function set appearComplete( value : Boolean ) : void {
            _bAppearComplete = value;
        }

        //出场完成
        public function get appearComplete() : Boolean {
            return _bAppearComplete;
        }

        public function set isBeAttacked( value : Boolean ) : void {
            _bIsBeAttacked = value;
        }

        public function get isBeAttacked() : Boolean {
            return _bIsBeAttacked;
        }

        public function get isTriggerWarn() : Boolean {
            return _isTriggerWarn;
        }

        public function set isTriggerWarn( value : Boolean ) : void {
            _isTriggerWarn = value;
        }

        /**角色唯一ID*/
        final public function get objId() : int {
            if ( owner ) {
                return (owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty).ID;
            }
            else {
                return 0;
            }
        }

        final public function get loaded() : Boolean {
            return m_bLoaded;
        }

        final public function set loaded( value : Boolean ) : void {
            m_bLoaded = value;
        }

        final public function get loading() : Boolean {
            return m_bLoading;
        }

        final public function set loading( value : Boolean ) : void {
            m_bLoading = value;
        }

        override public function dispose() : void {
            super.dispose();
        }

        override protected function onEnter() : void {
            m_eventManager = new CEventManager( this );
            m_nodeInCoolingTimeMap = new CMap();
            actionNodeCoolTimeCMap = new CMap();
            delayTimeMap = new CMap();

            teleportProcedureAction = new ProcedureRunningAction();
        }

        override protected function onExit() : void {
            if ( m_aiSystem ) {
                if ( m_aiObj ) {
                    m_aiObj.removeEventListener( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, _recordActionOverride );
                    m_aiObj.dispose();
                    m_aiSystem.removeAIObj( m_aiObj );
                }
            }
            m_aiObj = null;
            for ( var i : * in dicIdToEventNodeState ) {
                dicIdToEventNodeState[ i ] = null;
                delete dicIdToEventNodeState[ i ];
            }
            removeEventListeners();
            if ( m_eventManager ) {
                m_eventManager.dispose();
            }
            if ( m_pAIHandler ) {
                m_pAIHandler.removeEventListener( kof.game.character.ai.CAIEvent.CHANGE_AI_ID, _responesServerChangeAIEvent );
                m_pAIHandler.removeEventListener( kof.game.character.ai.CAIEvent.REASET_AI_STATE, _resetAIState );
                m_pAIHandler = null;
            }
            dicIdToEventNodeState = null;
            m_aiSystem = null;
            resetMoveCallBakcFunc = null;
            _pEventMediator = null;
            _pCharacterMediator = null;
            _pAttackableCharacter = null;
            m_eventManager = null;
            if( m_nodeInCoolingTimeMap ){
                m_nodeInCoolingTimeMap.clear();
            }
            m_nodeInCoolingTimeMap = null;

            if( actionNodeCoolTimeCMap ){
                actionNodeCoolTimeCMap.clear();
            }
            actionNodeCoolTimeCMap = null;

            if( delayTimeMap )
                    delayTimeMap.clear();
            delayTimeMap = null;

            if( teleportProcedureAction )
                    teleportProcedureAction.dispose();
            teleportProcedureAction = null;

            super.onExit();
        }

        final public function createAI( aiSystem : CAISystem, jsonData : Object, id : String, aiParams : String, handler : CAIHandler ) : void {
            if ( !owner )return;
            m_bLoaded = true;
            m_bLoading = false;
            var dataObj : Object = new Object();
            dataObj.handler = handler;
            dataObj.owner = owner;
            m_aiSystem = aiSystem;
            aiObjUpdateTime = 0.1;
            this.m_pAIHandler = handler;
            m_eventManager.initHitTable();

            var aiObj : CAIObject = new CAIObject( jsonData, aiParams, dataObj );
            m_aiObj = aiObj;
            m_aiObj.addEventListener( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, _recordActionOverride );
            currentAIID = (owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty).aiID;
            _pEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
            _pCharacterMediator = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            addEventListeners();
            m_pAIHandler.addEventListener( kof.game.character.ai.CAIEvent.REASET_AI_STATE, _resetAIState );
            m_pAIHandler.addEventListener( kof.game.character.ai.CAIEvent.CHANGE_AI_ID, _responesServerChangeAIEvent );
            _levelPathArr = m_pAIHandler.getLevelRoadPath( owner );

            //如果是机器人直接触发发警戒
            var pFacadeMediator : CFacadeMediator = owner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
            if ( pFacadeMediator ) {
                _isTriggerWarn = pFacadeMediator.isRobot( owner.data );
            }
            //侦听起身完成
            (owner.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine).actionFSM.addEventListener( CStateEvent.LEAVE, _onGetUpEvent );
        }

        private function _onGetUpEvent( e : CStateEvent ) : void {
            if ( e.from == CCharacterActionStateConstants.GETUP ) {
                isTrrigerGetUp = true;
            }
        }

        private var _levelPathArr : Array = [];
        private var _pathLength : int = 0;

        private function _moveLevelRoadPath() : void {
            if ( 0 >= _pathLength || isTriggerWarn ) {
                return;
            }
            if ( _levelPathArr.length > 0 ) {
                var obj : Object = _levelPathArr[ 0 ];
                if ( obj.x == owner.data.x && obj.y == owner.data.y ) {
                    _levelPathArr.splice( 0, 1 );
                    _moveLevelRoadPath();

                } else {
                    m_pAIHandler.move( owner, _levelPathArr, 0, 0, null );
                }
            }
        }

        private function _responesServerChangeAIEvent( e : kof.game.character.ai.CAIEvent ) : void {
            if ( e.data.uid && e.data.uid == this.objId ) {
                CAILog.logMsg( "接收到GM切换AI的消息，切换目标UID为：" + e.data.uid + "，目标AI ID为：" + e.data.id, this.objId );
                _changeAIObj( e.data.id );
            }
            if ( e.data.hasOwnProperty( "entityID" ) && e.data.entityID == owner.data.entityID && CCharacterDataDescriptor.isMonster(owner.data)) {
                CAILog.logMsg( "接收到服务器切换AI的消息，切换目标entityID为：" + e.data.entityID + "，目标AI ID为：" + e.data.id, this.objId );
                _changeAIObj( e.data.id );
                isServerTrrigger = true;
            }
        }

        public function addEventListeners() : void {
            addOwnEventListeners();
        }

        private function addAttackableEventListener() : void {
            m_eventManager.addAttackableEventListener();
        }

        public final function addOwnEventListeners() : void {
            m_eventManager.addOwnEventListeners();
        }

        /**切换AI模板*/
        private function _changeAIObj( tID : int ) : void {
            var targetAIid : int = tID;
            if ( iCurrentAIid == targetAIid )return;
            iCurrentAIid = targetAIid;
            var aiTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = m_pAIHandler.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            aiTable = pDatabaseSystem.getTable( KOFTableConstants.AI ) as CDataTable;

            var aiData : AI = aiTable.findByPrimaryKey( targetAIid );
            if ( !aiData )
                return;
            currentAIID = targetAIid;
            if ( aiData ) {
                var dataObj : Object = new Object();
                dataObj.handler = m_pAIHandler;
                dataObj.owner = owner;
                var aiFileName : String = aiData.AIFileName;
                var aiParams : String = aiData.AIParams;
                if ( aiHandler.aiResource && aiHandler.aiResource.theObject.hasOwnProperty( aiFileName ) ) {
                    var obj : Object = aiHandler.aiResource.theObject[ aiFileName ];
                    _changeAIReset();
                    m_pAIHandler.resetCharacterState( dataObj.owner );
                    var aiObj : CAIObject = new CAIObject( obj[ aiFileName ], aiParams, dataObj );
                    m_aiObj = aiObj;
                    m_aiObj.addEventListener( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, _recordActionOverride );
                    CAILog.logMsg( "切换AI成功，AI名为：" + aiFileName, objId );
                } else {
                    CResourceLoaders.instance().startLoadFile( CAIJsonFilePath.AI_JSON_FILE_PATH + aiFileName + ".json", _loadJsonData, CJsonLoader.NAME, ELoadingPriority.NORMAL, true );
                    function _loadJsonData( file : CJsonLoader, idError : int ) : void {
                        if ( idError == 0 ) {
                            _changeAIReset();
                            m_pAIHandler.resetCharacterState( dataObj.owner );
                            var jsonData : Object = file.createResource().theObject[ aiFileName ];
                            var aiObj : CAIObject = new CAIObject( jsonData, aiParams, dataObj );
                            m_aiObj = aiObj;
                            m_aiObj.addEventListener( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, _recordActionOverride );
                            CAILog.logMsg( "切换AI成功，AI名为：" + aiFileName, objId );
                        }
                    }
                }
            }
        }

        public function skillComplete() : void {
            m_bUseSkillEnd = true;
            m_bExcutingSkill = false;
            bComboSkill = false;
        }

        public function skillFailed() : void {
            m_bUseSkillEnd = true;
            m_bExcutingSkill = false;
            bComboSkill = false;
//        CAILog.logMsg("技能释放失败，重置skillEnd=true,excutingSkill=false",objId);
//        m_sCurrentCastSkillNodeName = "";
        }

        public function skillBegin() : void {
            if ( resetMoveCallBakcFunc ) {
                resetMoveCallBakcFunc.apply();
                resetMoveCallBakcFunc = null;
            }
            m_bUseSkillEnd = false;
            m_bExcutingSkill = true;
            m_bNeedCoolDown = true;
//        CAILog.logMsg("技能释放开始，重置skillEnd=false,excutingSkill=true",objId);
        }

        public function get bObjIsDead() : Boolean {
            var pFacadeMediator : CFacadeMediator = owner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
            return pFacadeMediator.isDead;
        }

        public final function get aiObj() : CAIObject {
            return m_aiObj;
        }

        public final function set aiObj( value : CAIObject ) : void {
            m_aiObj = value;
            m_aiObj.addEventListener( QFLib.AI.events.CAIEvent.OVERRIDE_ACTION, _recordActionOverride );
        }

        private function _recordActionOverride(e:QFLib.AI.events.CAIEvent):void{
            _overrideAction = true;
            m_eventManager.resetCastComboSkillCountTime();
            var coolNodeIndex : int;
            if( e.data.hasOwnProperty("prevIndex") )
                    coolNodeIndex = e.data["prevIndex"];
            if( coolNodeIndex > 0 )
                coolTimeByNodeIndex( coolNodeIndex );

            CAILog.logExistUnSatisfyInfo("prevNode : " + coolNodeIndex , "行为覆盖", objId );
        }

        private var _overrideAction:Boolean=false;
        public function get isOverrideAction():Boolean{
            return _overrideAction;
        }

        public function set isOverrideAction(value:Boolean):void{
            _overrideAction = value;
        }

        public final function externalUpdateForSyncSkillTime(delta : Number ) : void{
            m_eventManager.externalUpdate( delta );
            if( !isNaN( fRandomMoveTime ))
                    fRandomMoveTime += delta;
        }

        public function coolTimeByNodeIndex( nodeIndex : int ) : void{
            var coolTime : Number;
            if( m_bNeedCoolDown ) {
                coolTime = actionNodeCoolTimeCMap.find( nodeIndex );
                if ( !isNaN( coolTime ) && coolTime > 0.0 ) {
                    addNodeCoolTime( nodeIndex, coolTime );
                    CAILog.logEnterSubNodeInfo( nodeIndex + "-Next Cool Time" , "执行成功 进入 -长长长长长- Cooling CD为：" + coolTime, objId );
                }
                m_bNeedCoolDown = false;
            }else{
                coolTime = delayTimeMap.find( nodeIndex );
                if( !isNaN( coolTime ) && coolTime >0.0 ){
                    addNodeCoolTime( nodeIndex, coolTime );
                    CAILog.logEnterSubNodeInfo( nodeIndex + "-Next Cool Time" , "执行成功 进入 -短短短短短- delayTime CD为：" + coolTime, objId );
                }

            }
        }

        private function _updateNodeCoolingTime( delta : Number )  : void{
            if( m_nodeInCoolingTimeMap != null ) {
                var leftCoolTime : Number
                for( var key : int in m_nodeInCoolingTimeMap ) {
                    leftCoolTime = getNodeCoolTime( key );

                    if( leftCoolTime > 0.0 ) {
                        leftCoolTime -= delta;
                        addNodeCoolTime( key, leftCoolTime );
                    }
                }
            }
        }

        private function _updateSelectTargetCountTime( delta : Number ) : void{
            if( !isNaN( selectTargetCountTime ) && selectTargetCountTime > 0.0 )
                    selectTargetCountTime -= delta;
        }

        private var m_teleElapseTime : Number;
        private var m_bTeleNext : Boolean;

        public function beginTeleport( tags : Array , times : Array ) : void{
            m_teleElapseTime = 0.0;
            currentTeleIndex = 0;
            m_bTeleNext = true ;
            teleportList = tags;
            telewaittimes = times;
        }

        public function endTeleport() : void{
            m_teleElapseTime = NaN;
            currentTeleIndex = 0;
            m_bTeleNext = false;
            teleportList = null;
            telewaittimes = null;
            m_bNeedCoolDown = true;
        }

        public function get bTeleCompleted() : Boolean{
            return teleportList == null || currentTeleIndex >= teleportList.length;
        }

        private function _updateTeleports( delta : Number ) : void{
             if(!isNaN(m_teleElapseTime))
             {
                 m_teleElapseTime += delta;
                 if( currentTeleIndex >= teleportList.length ){
                     return;
                 }
                 var nextTime : Number = 0.0;
                 if( currentTeleIndex < telewaittimes.length ){
                     nextTime = telewaittimes[currentTeleIndex];
                 }
                 if( m_bTeleNext && m_teleElapseTime >= nextTime )
                 {
                     m_bTeleNext = false;
                     _teleport( teleportList[currentTeleIndex]);
                 }
             }
        }

        private function _teleport( tag : int ) : void{
            var location: Object =aiHandler.getLevelPosTag( tag );
            if( location == null ) {
                Foundation.Log.logWarningMsg("AI 传送的关卡点位置不存在，自动跳过 tag ；" + tag);
                _teleportNext();
            }else {
                aiHandler.teleportToPosition( owner, new CVector2( location.x, location.y ), _teleportNext );
            }
        }

        private function _teleportNext() : void{
            m_bTeleNext = true;
            m_teleElapseTime = 0.0;
            currentTeleIndex++;
        }

        public final function update( delta : Number, dataIO : IAIHandler ) : void {
            m_eventManager.update(delta);

            _updateNodeCoolingTime( delta );
             _updateSelectTargetCountTime( delta );
             _updateTeleports( delta );
            /**
             *触发警戒的两种情况：
             * 1、是正常触发，敌方走进自己警戒范围（检查自己警戒范围内中有没有敌方阵营）；
             * 2、对方在警戒范围外，发动远程攻击，击中自己，触发警戒（监听被击打事件判断自己是否处于被击中）;
             **/
            //是否触发警戒
            if ( !_isTriggerWarn ) {
                //如果还没有巡逻就执行巡逻
                if ( !_bIsPatrol ) {
                    _bIsPatrol = true;
                    if ( _levelPathArr ) {
                        _pathLength = _levelPathArr.length;
                        if ( !m_pAIHandler.isHero( owner ) ) {
                            _moveLevelRoadPath();//所有模板默认初始化后，都要拿关卡的路径点，有就执行，没有就不执行
                        }
                    }
                }
                if ( m_pAIHandler.isTriggerWarnRange( owner ) || _bIsBeAttacked ) {
                    _isTriggerWarn = true;
                    m_pAIHandler.playWarnEffect( owner, null );
                }
            }

            /**计算calculationDurationDamadge相关
            if ( calculationDuration != 0 ) {
                calculationElapsedTime += delta;
//                if ( dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL ) == false ) {
                    var bool : Boolean = executableCalculationDuration();
                    if ( bool ) {
                        if ( calculationValue != 0 ) {
                            var pFacadeProperty : ICharacterProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                            var curPercent : Number = (recordCurHP - pFacadeProperty.HP) / pFacadeProperty.MaxHP;
                            if ( curPercent > calculationValue ) {
                                calculationResult = 2;
                                calculationDuration = 0;
                                calculationElapsedTime = 0;
                            }
                            else {
                                calculationResult = 1;
                                calculationDuration = 0;
                                calculationElapsedTime = 0;
                            }
                        }
                        else {
                            calculationResult = 2;
                            calculationDuration = 0;
                            calculationElapsedTime = 0;
                        }
                    }
//                }
//                else {
//                    calculationResult = 1;
//                    calculationDuration = 0;
//                    calculationElapsedTime = 0;
//                }
            }*/
        }



        private function warnEffectCallBack() : void {
            _isTriggerWarn = true;
        }

        //重置所有状态
        public function resetAllState() : void {
            if ( resetMoveCallBakcFunc ) {
                resetMoveCallBakcFunc.apply();
                resetMoveCallBakcFunc = null;
            }
            isMovingPassTarget = false;
            bComboSkill = false;
            m_bExcutingSkill = false;
            m_bUseSkillEnd = true;
            isBeAttacked = false;
            iSkillCount = 0;
            useSkillType = "";

            bSkillHit = false;//是否击中目标
            iSkillIndex = 0;

            bTargetAttack = false;//目标发起攻击
            bTargetHited = false;//目标被攻击
            bWheatherTriggerEvent = false;
            iCrrentEventPriority = 0;

            _bSeqConditionPassAndExecuting = false;
            iPreSkillIndex=0;
            isExcutedNextSkill=false;//下一个技能是否已经执行了
            bSkillConsume = "1";
            nWaitTime=0;
            useSkillType = "";
            bSkillExecuteSuccess = false;
            m_sCurrentCastSkillNodeName = '';
            endTeleport();

            if( m_eventManager )
                m_eventManager.resetCastComboSkillCountTime();
            if(m_pAIHandler)
            {
                bCanResetState_GANGTI = false;
                m_pAIHandler.resetGANGTI( owner );
                bCanResetState_WUDI = false;
                m_pAIHandler.resetWUDI( owner );
                bCanResetState_PATI = false;
                m_pAIHandler.resetPATI( owner );
            }
            _stopMove()
        }

        public function resetInFightingState() : void{
            if( m_pAIHandler ) {
                if( !bSetStateAlways_GANGTI ) {
                    bCanResetState_GANGTI = false;
                    m_pAIHandler.resetGANGTI( owner );
                }
                if( !bSetStateAlways_WUDI ) {
                    bCanResetState_WUDI = false;
                    m_pAIHandler.resetWUDI( owner );
                }

                if( !bSetStateAlways_PATI && !bSetStateAlways_GANGTI ) {
                    bCanResetState_PATI = false;
                    m_pAIHandler.resetPATI( owner );
                }
            }
        }

        private function _stopMove() : void{
            if( m_pAIHandler == null )
                    return;
            if( m_pAIHandler.isTeammate( owner ))  {
                var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
                if ( pEventMediator )
                    pEventMediator.dispatchEvent( new CCharacterEvent( CCharacterEvent.STOP_MOVE, null ) );
            }
        }

        public function removeEventListeners() : void {
            m_eventManager.removeEventListeners();
        }

        private function _changeAIReset() : void {
            m_sCurrentCastSkillNodeName = "";
            m_sCurrentEventNodeName = "";
            m_sCurrentSelfConditionNodeName="";
            dicIdToEventNodeState = new Dictionary();
            if ( resetMoveCallBakcFunc ) {
                resetMoveCallBakcFunc.apply();
                resetMoveCallBakcFunc = null;
            }
            isMovingPassTarget = false;
            bComboSkill = false;
            m_bExcutingSkill = false;
            m_bUseSkillEnd = true;
            isBeAttacked = false;
            iSkillCount = 0;
            useSkillType = "";

            bSkillHit = false;//是否击中目标
            iSkillIndex = 0;

            bTargetAttack = false;//目标发起攻击
            bTargetHited = false;//目标被攻击
            bWheatherTriggerEvent = false;
            iCrrentEventPriority = 0;

            iPreSkillIndex=0;
            isExcutedNextSkill=false;//下一个技能是否已经执行了
            bSkillConsume = "1";
            nWaitTime=0;
            useSkillType = "";
            bSkillExecuteSuccess = false;
            bSetStateAlways_PATI = false;
            bSetStateAlways_GANGTI = false;
            bSetStateAlways_WUDI = false;
            if(m_pAIHandler)
            {
                bCanResetState_GANGTI = false;
                m_pAIHandler.resetGANGTI( owner );
                bCanResetState_WUDI = false;
                m_pAIHandler.resetWUDI( owner );
                bCanResetState_PATI = false;
                m_pAIHandler.resetPATI( owner );
            }
            _resetDelayAndCoolTime();
        }

        private function _resetAIState( e : kof.game.character.ai.CAIEvent ) : void {
            resetAllState();
            CAILog.logMsg( "收到AI启动的事件，重置AI状态", objId );
        }

        private function _resetDelayAndCoolTime() : void{
            actionNodeCoolTimeCMap.clear();
            delayTimeMap.clear();
        }

        public final function get useSkillEnd() : Boolean {
            return m_bUseSkillEnd;
        }

        public final function set useSkillEnd( value : Boolean ) : void {
            m_bUseSkillEnd = value;
        }

        public final function set excutingSkill( value : Boolean ) : void {
            m_bExcutingSkill = value;
        }

        public final function get excutingSkill() : Boolean {
            return m_bExcutingSkill;
        }

        public function addNodeCoolTime( nodeIndex : int , coolTime : Number ) : void{
            m_nodeInCoolingTimeMap.add( nodeIndex , coolTime , true);
        }

        public function removeNodeCoolTime( nodeIndex : int ) : void{
            delete m_nodeInCoolingTimeMap[nodeIndex];
        }

        public function getNodeCoolTime( nodeIndex : int )  : Number{
            return m_nodeInCoolingTimeMap.find(nodeIndex) as Number;
        }

        public function findNodeCoolTime( nodeIndex : int ) : Boolean{
            return m_nodeInCoolingTimeMap.find( nodeIndex ) != null;
        }

        public function resetNodeCoolTime() : void {
            m_nodeInCoolingTimeMap.clear();
        }

        public final function set notHitButAttackVec( value : Vector.<int> ) : void {
            m_pNotHitButAttack = value;
        }

        public final function get notHitButAttackVec() : Vector.<int> {
            return m_pNotHitButAttack;
        }

        public final function set currentCastSkillNodeName( value : String ) : void {
            m_sCurrentCastSkillNodeName = value;
        }

        public final function get currentCastSkillNodeName() : String {
            return m_sCurrentCastSkillNodeName;
        }

        public final function set currentEventNodeName( value : String ) : void {
            m_sCurrentEventNodeName = value;
        }

        public final function get currentSelfConditionNodeName():String {
            return m_sCurrentSelfConditionNodeName;
        }

        public final function set currentSelfConditionNodeName( value : String ):void{
            m_sCurrentSelfConditionNodeName = value;
        }

        public final function get currentEventNodeName() : String {
            return m_sCurrentEventNodeName;
        }

        public final function get currentNodeIndex() : int{
            if( m_sCurrentEventNodeName == null || m_sCurrentEventNodeName == "" )
                    return 0;
            return int( m_sCurrentEventNodeName.charAt(0));
        }

        public function get isF9() : Boolean {
            return _isF9;
        }

        public function set isF9( value : Boolean ) : void {
            _isF9 = value;
        }

        public function set currentAttackable( value : CGameObject ) : void {
            if ( _pCurrentAttackable != value ) {
                CAILog.logMsg( "AI攻击目标发生变换，切换攻击目标侦听的战斗事件！", objId );
                m_eventManager.removeAttackableEvent( null );
                _pCurrentAttackable = value;
                if ( _pCurrentAttackable ) {
                    _pAttackableCharacter = _pCurrentAttackable.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
                    _pAttackableEventMediator = _pCurrentAttackable.getComponentByClass( CEventMediator, true ) as CEventMediator;
                    m_eventManager.resetAttackableEventMediatorListener();
                    addAttackableEventListener();
                }
            }
        }

        public function get currentAttackable() : CGameObject {
            return _pCurrentAttackable;
        }

        public function get currentMaster() : CGameObject {
            return _pCurrentMaster;
        }

        public function set currentMaster( value : CGameObject ) : void {
            _pCurrentMaster = value;
        }

        public final function get eventMediator() : CEventMediator {
            return _pEventMediator;
        }

        public final function get characterFightTriggle() : CCharacterFightTriggle {
            return _pCharacterMediator;
        }

        public final function set attackableFightTriggle( value : CCharacterFightTriggle ) : void {
            _pAttackableCharacter = value;
        }

        public final function get attackableFightTriggle() : CCharacterFightTriggle {
            return _pAttackableCharacter;
        }

        public final function set attackableEventMediator( value : CEventMediator ) : void {
            _pAttackableEventMediator = value;
        }

        public final function get attackableEventMediator() : CEventMediator {
            return _pAttackableEventMediator;
        }

        public final function get bSeqConditionPassAndExecuting() : Boolean{
            return _bSeqConditionPassAndExecuting;
        }

        public final function set bSeqConditionPassAndExecuting( value : Boolean ) : void{
            _bSeqConditionPassAndExecuting = value;
        }

        public final function get aiHandler() : CAIHandler {
            return m_pAIHandler;
        }

        public function isMulEnterTemplate( name : String ) : Boolean{
            return TEMPLATES_FOR_MUL_ENTERS.indexOf(name ) > -1;
        }

        public function addTeleportProcedureAction( action : Function , procedureArgs : Object ) :void {
            if( teleportProcedureAction ) {
                teleportProcedureAction.addSequenceAction( action , procedureArgs );
            }
        }
    }

}

import QFLib.Foundation.CProcedureManager;


class ProcedureRunningAction{
    public var _procedureMgr : CProcedureManager;

    public function ProcedureRunningAction() : void
    {
        _procedureMgr = new CProcedureManager(20);
    }

    public function dispose() : void{
        if( _procedureMgr ){
            _procedureMgr.dispose();
        }

        _procedureMgr = null;
    }

    public function addSequenceAction( action : Function , actionArg : Object ) : void{
        _procedureMgr.addSequential( action , actionArg );
    }

}


