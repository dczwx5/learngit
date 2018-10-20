//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.ai {

    import QFLib.AI.CAISystem;
    import QFLib.DashBoard.CDashBoard;
    import QFLib.Foundation;
    import QFLib.Foundation.CLog;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CPackedQsonLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.events.Event;

    import flash.geom.Point;
    import flash.geom.Rectangle;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.framework.INetworking;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
    import kof.game.character.CEventMediator;
    import kof.game.character.CFacadeMediator;
import kof.game.character.CSimulationPlayer;
import kof.game.character.CSkillList;
    import kof.game.character.ai.actions.CAttractMonsterMoveAction;
    import kof.game.character.ai.actions.CCalculationDurationDamadgeAction;
    import kof.game.character.ai.actions.CCastSkillAction;
    import kof.game.character.ai.actions.CDoTriggerAction;
import kof.game.character.ai.actions.CEvaluateCoolTimeAction;
import kof.game.character.ai.actions.CEventOverAction;
    import kof.game.character.ai.actions.CEventTrrigerAction;
    import kof.game.character.ai.actions.CExecuteAIAction;
    import kof.game.character.ai.actions.CFindPassTargetAction;
    import kof.game.character.ai.actions.CFindPassWayAction;
    import kof.game.character.ai.actions.CFollowAction;
    import kof.game.character.ai.actions.CIdleAction;
    import kof.game.character.ai.actions.CMergeAIAction;
    import kof.game.character.ai.actions.CMoveAction;
    import kof.game.character.ai.actions.CMoveToAction;
    import kof.game.character.ai.actions.CPatrolAction;
    import kof.game.character.ai.actions.CPlayAction;
import kof.game.character.ai.actions.CPlayerUltimateSkillAction;
import kof.game.character.ai.actions.CRandomMoveAction;
    import kof.game.character.ai.actions.CRecoveryAction;
    import kof.game.character.ai.actions.CResetStateAction;
    import kof.game.character.ai.actions.CReviveAction;
    import kof.game.character.ai.actions.CSelectTargetAction;
    import kof.game.character.ai.actions.CSelectTargetForValueAction;
import kof.game.character.ai.actions.CSequenceTeleportAction;
import kof.game.character.ai.actions.CSetDirectionAction;
    import kof.game.character.ai.actions.CSetStateAction;
    import kof.game.character.ai.actions.CStateChangeAction;
    import kof.game.character.ai.actions.CStopAction;
    import kof.game.character.ai.actions.CTelesportAction;
    import kof.game.character.ai.actions.CTimeTrrigerAction;
    import kof.game.character.ai.actions.CWaitAction;
    import kof.game.character.ai.actions.CWorldBossSkillAction;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.ai.conditions.CEventTriggerCondition;
    import kof.game.character.ai.conditions.CEventTrueCondition;
    import kof.game.character.ai.conditions.CJudgeDistanceTargetCondition;
    import kof.game.character.ai.conditions.CRandomProbabilityCondition;
    import kof.game.character.ai.conditions.CSelfCondCondition;
    import kof.game.character.ai.conditions.CSelfResCondition;
    import kof.game.character.ai.conditions.CSkillExecuteIsSuccessCondition;
import kof.game.character.ai.conditions.CSwitchCondition;
import kof.game.character.ai.conditions.CTargetCondCondition;
    import kof.game.character.ai.conditions.CTargetRESCondition;
    import kof.game.character.ai.conditions.CTimeTriggerAutoPassCondition;
    import kof.game.character.ai.conditions.CTimeTriggerCondition;
    import kof.game.character.ai.conditions.CWheatherTriggerChangeAIEventCondition;
    import kof.game.character.ai.conditions.CWheatherTriggerEventCondition;
    import kof.game.character.ai.conditions.CWhetherHitTheTargetCondition;
    import kof.game.character.ai.conditions.CWhetherHitedByPlayerCondtion;
    import kof.game.character.ai.jsonData.CAIJsonFilePath;
    import kof.game.character.ai.methods.CFightCategory;
    import kof.game.character.ai.methods.CFunctionCategory;
    import kof.game.character.ai.methods.CMoveCategory;
    import kof.game.character.ai.paramsTypeEnum.ECampType;
    import kof.game.character.ai.paramsTypeEnum.EFightStateType;
    import kof.game.character.ai.paramsTypeEnum.EPlayType;
    import kof.game.character.animation.IAnimation;
    import kof.game.character.display.IDisplay;
    import kof.game.character.dynamicBlock.CDynamicBlockComponent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.character.scene.CBubblesMediator;
import kof.game.character.scripts.CMonsterAppear;
import kof.game.character.scripts.CMonsterSprite;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.core.CGameObject;
    import kof.game.core.CGameSystemHandler;
    import kof.game.core.IGameSystemHandler;
    import kof.game.level.ILevelFacade;
    import kof.game.scene.CSceneSystem;
    import kof.message.CAbstractPackMessage;
    import kof.message.Map.SwitchAIResponse;
    import kof.table.AI;
    import kof.table.Dialogue;
    import kof.table.Level;
    import kof.table.Skill;
    import kof.util.CAssertUtils;

    /**
     * @author Jeremy (jeremy@qifun.com)
     */
    public final class CAIHandler extends CGameSystemHandler implements IGameSystemHandler,IAIHandler {
        private var m_pAiSystem : CAISystem;
        private var m_pAILog : CLog = null;

        //AI调用方法归类
        private var m_moveCategory : CMoveCategory = null;
        private var m_functionCategory : CFunctionCategory = null;
        private var m_fightCategory : CFightCategory = null;

        private var nElapsedTime : Number = 0;
        private var nSearchWaitTime : Number = 5;

        public var aiResource : CResource = null;
        private var _componentResource : CResource = null;

        private var _bAutoFight : Boolean = false;//自动战斗
        private var _bTrunkActive : Boolean = false;//trunk激活
        private var _bEnterTrunk : Boolean = false;//进入trunk
        private var _iTrunkTarget : int = 0;//trunk的完成目标,0击杀所有,1击杀指定敌人,2击杀任意敌人,3完成指定触发器
        public var keyDown:Boolean = false;

        public function get componentResource() : CResource {
            return _componentResource;
        }

        public function get bAutoFight():Boolean{
            return _bAutoFight;
        }

        private var _lastAutoFightState:Boolean = false;
        public function set bAutoFight(value:Boolean):void{
            _bAutoFight = value;
            if(_bAutoFight==false&&_lastAutoFightState!=value){
                dispatchEvent(new CAIEvent(CAIEvent.STOP_AUTO_FIGHT));
            }else if(_bAutoFight==true&&_lastAutoFightState!=value){
                dispatchEvent(new CAIEvent(CAIEvent.START_AUTO_FIGHT));
            }
            _lastAutoFightState = value;
        }

        /**
         * Creates a new CAIHandler.
         */
        public function CAIHandler() {
            super( CAIComponent );
            m_pAILog = new CLog( "AI" );
        }

        final private function _loadPackedConfigFile( loader : CJsonLoader, idError : int ) : void {
            if ( idError == 0 ) {
                aiResource = loader.createResource();
            }
        }

        final private function _loadComponentPackedConfigFile( loader : CJsonLoader, idError : int ) : void {
            if ( idError == 0 ) {
                _componentResource = loader.createResource();
            }
        }

        override protected function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            if ( ret ) {
                //是否需要加载打包AIjson
                if ( CPackedQsonLoader.enablePackedQsonLoading ) {
                    CResourceLoaders.instance().startLoadFile( CAIJsonFilePath.AI_JSON_FILE_PATH + "ai_packed.json", _loadPackedConfigFile, CJsonLoader.NAME, ELoadingPriority.NORMAL, false );
                    CResourceLoaders.instance().startLoadFile( CAIJsonFilePath.AI_COMPONENT_JSON_FILE_PATH + "component_packed.json", _loadComponentPackedConfigFile, CJsonLoader.NAME, ELoadingPriority.NORMAL, false );
                }
                m_moveCategory = new CMoveCategory( this );
                m_functionCategory = new CFunctionCategory( this );
                m_fightCategory = new CFightCategory( this );
                m_pAiSystem = new CAISystem();
                registerAIClass();
                //监听服务器切换AI的消息
                var networking : INetworking = system.stage.getSystem( INetworking ) as INetworking;
                CAssertUtils.assertNotNull( networking, "INetworking required in CAIHandler." );
                if ( networking ) {
                    networking.bind( SwitchAIResponse ).toHandler( _onSwitchAIResponse );
                }

                var pDashBoard : CDashBoard = system.stage.getBean( CDashBoard ) as CDashBoard;
                if ( pDashBoard ) {
                    if ( !pDashBoard.findPage( "AIInfoPage" ) ) {
                        pDashBoard.addPage( new CAIInfoPage( pDashBoard, m_pAILog ) );
                    }
                }
                var aiLog : CAILog = new CAILog( m_pAILog );
                (system.stage.getSystem( ILevelFacade ) as ILevelFacade).listenEvent( _trunkActive );
            }
            return ret;
        }

        private function _trunkActive( e : Event ) : void {
            if ( e.type == "activeTrunk" ) {
//                _bTrunkActive = true;
                _bTrunkActive = true;
                _bEnterTrunk = false;
            } else if ( e.type == "enterTrunk" ) {
                _bTrunkActive = false;
                _bEnterTrunk = true;
            }
        }

        public function get bEnterTrunk() : Boolean {
            return _bEnterTrunk;
        }

        public function set bEnterTrunk( value : Boolean ) : void {
            _bEnterTrunk = value;
        }

        public function get bTrunkActive() : Boolean {
            return _bTrunkActive
        }

        public function set bTrunkActive( value : Boolean ) : void {
            _bTrunkActive = value;
        }

        public function get iTrunkTarget() : int {
            return _iTrunkTarget;
        }

        public function set iTrunkTarget( value : int ) : void {
            _iTrunkTarget = value;
        }

        private function _onSwitchAIResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var response : SwitchAIResponse = message as SwitchAIResponse;
            dispatchEvent( new CAIEvent( CAIEvent.CHANGE_AI_ID, {entityID : response.entityID, id : response.AIID }));//,type : response.type } ) );
        }

        private function _GMChangeAI( e : CAIEvent ) : void {
//            var obj : Object = e.data;
//            dispatchEvent( new CAIEvent( CAIEvent.CHANGE_AI_ID, {objID : obj.uid, aiID : obj.id} ) );
        }

        override protected virtual function onShutdown() : Boolean {
            var ret : Boolean = super.onShutdown();
            if ( ret ) {
                var networking : INetworking = system.stage.getSystem( INetworking ) as INetworking;
                CAssertUtils.assertNotNull( networking, "INetworking required in CAIHandler." );
                if ( networking ) {
                    networking.unbind( SwitchAIResponse );
                }
                CAILog.clear();
                m_pAiSystem.dispose();
                m_pAiSystem = null;
                m_moveCategory = null;
                m_functionCategory = null;
            }
            return ret;
        }

        override protected function onEnabled( value : Boolean ) : void {
            dispatchEvent( new CAIEvent( CAIEvent.REASET_AI_STATE ) );
            if ( value ) {
                //Foundation.Log.logMsg("AIHandler启用");
            }
            else {
                //Foundation.Log.logMsg("AIHandler禁用");
            }
        }

        override public function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
            var bValidated : Boolean = super.tickValidate( delta, obj );
            if ( !bValidated )
                return false;
            var pAIComponent : CAIComponent = obj.getComponentByClass( CAIComponent, true ) as CAIComponent;
            var pSkillCaster : CSkillCaster = obj.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
            if ( pAIComponent && !pAIComponent.loaded && !pAIComponent.loading ) {
                var pFacadeProperty : ICharacterProperty = obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                if ( pFacadeProperty.aiID <= 0 ) {
                    return false;
                }
                var aiData : AI = getAITableData( pFacadeProperty.aiID );
                if ( !aiData ) {
                    return false;
                }
                var aiFileName : String = aiData.AIFileName;
                var aiParams : String = aiData.AIParams;
                pAIComponent.loading = true;
                getAIJsonID( aiFileName, pAIComponent, aiParams );
                pAIComponent.loading = true;
            }
            var ishero : Boolean = isHero( obj );
            var bSimulationPlayer : Boolean =  isSimulationPlayer(obj);
            if ( ishero && bAutoFight ) {
                pAIComponent.enabled = true;
            }else if(ishero&&!bAutoFight){
                pAIComponent.enabled = false;
            }
            var isDead : Boolean = this.getFacadeMediator( obj ).isDead;
            if(isDead){
                if(pAIComponent)
                {
                    pAIComponent.resetAllState();
                }
            }
//            var pmFacadeProperty : CMonsterProperty = obj.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
//            if(pmFacadeProperty)
//            pmFacadeProperty.AttackPower = 0;
            var pDisplay : IDisplay = obj.getComponentByClass( IDisplay, true ) as IDisplay;
            var isDisplayReady : Boolean = pDisplay ? pDisplay.isReady : true;
            if ( pAIComponent && !isDead && isDisplayReady && obj.isRunning ) {
                if ( pAIComponent.enabled ) {
                    if ( !ishero || bAutoFight ) {
                        if ( pAIComponent.aiObj ) {
                            if ( pSkillCaster.boSkillReady ) {
                                pAIComponent.update( delta, this );
                                if ( pAIComponent.appearComplete && (pAIComponent.isTriggerWarn || isTeammate( pAIComponent.owner ) || ishero || bSimulationPlayer ) ) {
                                    if(pAIComponent.isChangeEnable){
                                        var m_pGameStateRef : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
                                        if(m_pGameStateRef.actionFSM.currentState.name==CCharacterActionStateConstants.IDLE){
                                            pAIComponent.isChangeEnable = false;
                                            m_pAiSystem.updateAIObj( pAIComponent.aiObj, pAIComponent.aiObjUpdateTime, delta );
                                        }
                                    }else{
                                        m_pAiSystem.updateAIObj( pAIComponent.aiObj, pAIComponent.aiObjUpdateTime, delta );
                                    }
                                }
                            }
                            else {
                                Foundation.Log.logTraceMsg( "AI技能数据准备中" );
                            }
                        }
                        else {
                            //Foundation.Log.logMsg("pAIComponent.aiObj为null");
                        }
                    }
                }else{
                    if(!ishero){
                        if(pAIComponent.appearComplete){
                            pAIComponent.enabled = true;
                        }
                    }
                }
            }
//            CONFIG::debug{//注释掉为了在外网看剧情副本和竞技AI为啥呆掉的bug 2017/8/31 18:03 110103201
            /**AILog检测场景中的活动gameobj，5秒一次*/
            nElapsedTime += delta;
            if ( executableSearch ) {
                CAILog.clear();
                nElapsedTime -= nSearchWaitTime;
                var all : Object = (system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
                if ( all ) {
                    var property : ICharacterProperty = null;
                    for each ( var gobj : CGameObject in all ) {
                        if ( !gobj.isRunning || this.isDead( gobj ) )
                            continue;
                        property = gobj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                        pAIComponent = gobj.getComponentByClass( CAIComponent, true ) as CAIComponent;
                        if ( pAIComponent ) {
                            CAILog.gameObjInfo( property, getObjEntityID( gobj ), pAIComponent.currentAIID );
                        }
                    }
                }
            }
//            }
            return false;
        }

        private function get executableSearch() : Boolean {
            return nElapsedTime - nSearchWaitTime >= 0;
        }

        public final function getAIJsonID( id : String, aiCompnent : CAIComponent, aiParams : String ) : void {
            if ( aiResource && aiResource.theObject.hasOwnProperty( id ) ) {
                var obj : Object = aiResource.theObject[ id ];
                aiCompnent.createAI( m_pAiSystem, obj[ id ], id, aiParams, this );
                trace( aiResource.refCounts );
            } else {
                Foundation.Log.logTraceMsg( "开始加载AI文件：" + id + ".json" );
                var hander : CAIHandler = this;
                CResourceLoaders.instance().startLoadFile( CAIJsonFilePath.AI_JSON_FILE_PATH + id + ".json", _loadJsonData, CJsonLoader.NAME, ELoadingPriority.NORMAL, false );
                function _loadJsonData( loader : CJsonLoader, idError : int ) : void {
                    if ( idError == 0 ) {
//                Foundation.Log.logTraceMsg("加载AI文件："+id+".json成功");
                        aiCompnent.createAI( m_pAiSystem, loader.createResource().theObject[ id ], id, aiParams, hander );
                    }
                    else {
                        Foundation.Log.logErrorMsg( "加载AI文件：" + id + ".json失败" );
                    }
                }
            }
        }

        //-----------------------------------------------------------------------------------
        //--------------------------------------移动相关--------------------------------------
        //-----------------------------------------------------------------------------------
        /**引怪*/
        public final function moveAttractMonster( owner : CGameObject, ptArr : Array, offsetX : Number, offsetY : Number, moveEndCallBack : Function ) : Boolean {
            return m_moveCategory.moveAttractMonster( owner, ptArr, offsetX, offsetY, moveEndCallBack );
        }

        /**相对自己移动*/
        public final function move( owner : CGameObject, ptArr : Array, offsetX : Number, offsetY : Number, moveEndCallBack : Function ) : Boolean {
            return m_moveCategory.move( owner, ptArr, offsetX, offsetY, moveEndCallBack );
        }

        /**相对目标移动*/
        public final function moveTo( owner : CGameObject, distanceX : Number, distanceY : Number, targetPosition : Point, movetoEndCallBack : Function, type : String, isFarawayAttack : Boolean = false, fleeType : String = "", axesType : String = "" ) : Boolean {
            return m_moveCategory.moveTo( owner, distanceX, distanceY, targetPosition, movetoEndCallBack, type, isFarawayAttack, fleeType, axesType );
        }

        /**没有攻击目标时移动到某个点*/
        public final function moveToPos( owner : CGameObject, targetPos : Point, movetoEndCallBack : Function ) : Boolean {
            return m_moveCategory.moveToPos( owner, targetPos, movetoEndCallBack );
        }

        /**跟随目标移动*/
        public final function follow( owner : CGameObject, movetoEndCallBack : Function, offsetX : Number = 100, offsetY : Number = 20, followDistance : Number = 150, followType : String = "", followBoolDistance : Boolean = false ) : Boolean {
            return m_moveCategory.follow( owner, movetoEndCallBack, offsetX, offsetY, followDistance, followType, followBoolDistance );
        }

        //------------------------------------------------------------------------------------------------
        //-----------------------------------------------战斗相关------------------------------------------
        //------------------------------------------------------------------------------------------------
        /**是否处于攻击状态*/
        public final function isAttacking( owner : CGameObject ) : Boolean {
            return this.getFacadeMediator( owner ).isAttacking;
        }

        /**是否处于防御状态*/
        public final function isDefensing( owner : CGameObject ) : Boolean {
            return this.getFacadeMediator( owner ).isDefensing;
        }

        /**是否处于移动状态*/
        public final function isMoving( owner : CGameObject ) : Boolean {
            return this.getFacadeMediator( owner ).isMoving;
        }

        /**是否处于受伤状态*/
        public final function isHurting( owner : CGameObject ) : Boolean {
            return this.getFacadeMediator( owner ).isHurting;
        }

        /**是否处于倒地状态*/
        public final function isLaying( owner : CGameObject ) : Boolean {
            return this.getFacadeMediator( owner ).isLaying;
        }

        /**释放技能*/
        public final function attackWithSkillID( owner : CGameObject, skillId : int ) : void {
//            trace("消耗释放："+skillId);
            setDirectionToGameObj( owner );
            var pSimulator : CSimulateSkillCaster = owner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
//            if ( pSimulator )
                pSimulator.clearIngnoreConditions();
            m_fightCategory.attackWithSkillID( owner, skillId );
        }

        public final function  castUpWithSkillIndex( owner : CGameObject , skillIndex : int ) : void{
             setDirectionToGameObj( owner );
            var pSimulator : CSimulateSkillCaster = owner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
                pSimulator.clearIngnoreConditions();
            m_fightCategory.castUpWithSkillIndex( owner, skillIndex );
        }

        /**释放技能，无视消耗*/
        public final function attackIgnoreWithSkillIdx( owner : CGameObject, skillIdx : int ) : void {
//            trace("无消耗释放："+skillIdx);
            setDirectionToGameObj( owner );
//            var pSimulator : CSimulateSkillCaster = owner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
//            if ( pSimulator )
//                pSimulator.clearIngnoreConditions();
            m_fightCategory.attackIgnoreWithSkillIdx( owner, skillIdx );
        }
        /**在释放技能的节点中，每次调用技能前先清理一次，以免受到前一个回调的影响，比如距离不够，AI要跑过去，然后放技能，在跑到位那刻发生了行为覆盖，此时要释放另一个技能，接着前一个行为的回调又触发了*/
        public final function clearMoveFinishCallBackFunction(owner : CGameObject):void{
            this.getFacadeMediator( owner ).clearMoveFinishFunction();
        }

        /**闪避*/
        public function dodge( owner : CGameObject ) : Boolean {
            return m_fightCategory.dodge( owner );
        }

        /**无视消耗闪避*/
        public function dodgeIgnore( owner : CGameObject ) : void {
            return m_fightCategory.dodgeIgnore( owner );
        }

        /**判断和玩家的距离，是否在攻击范围内*/
        public final function judegeDistanceAttack( distanceX : Number, distanceY : Number, owner : CGameObject ) : Boolean {
            return m_fightCategory.judegeDistanceAttack( distanceX, distanceY, owner );
        }

        /**获取技能攻击距离*/
        public final function getSkillDistance( owner : CGameObject, skillIndex : int ) : Object {
            var skillList : CSkillList = owner.getComponentByClass( CSkillList, true ) as CSkillList;
            var skillId : int = skillList.getSkillIDByIndex( skillIndex );
            var skillTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            skillTable = pDatabaseSystem.getTable( KOFTableConstants.SKILL ) as CDataTable;
            var skillData : Skill = skillTable.findByPrimaryKey( skillId );
            if ( skillData ) {
                var rangeData : Object = new Object();
                rangeData.x = skillData.UseRangeX;
                rangeData.z = skillData.UseRangeY;
                return rangeData;
            }
            return {x : 200, z : 100};
        }

        public final function teleportToPosition( owner : CGameObject, vec : CVector2, callBackFunc : Function ) : void {
            var ownerCaster : CSkillCaster = owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
            ownerCaster.castTeleportToPosition( 10000, vec, callBackFunc );
        }

        //-----------------------------------------------------------------------------------------
        //-------------------------------------------------游戏对象状态相关--------------------------
        //-----------------------------------------------------------------------------------------
        /**是否已经死亡*/
        public function isDead( owner : CGameObject ) : Boolean {
            var facadeMediator : CFacadeMediator = this.getFacadeMediator( owner );
            if ( facadeMediator ) {
                return facadeMediator.isDead;
            }
            else {
                return true;
            }
        }

        /**转向当前选择的目标*/
        public final function setDirectionToGameObj( owner : CGameObject ) : void {
            var pFacadeMediator : CFacadeMediator = this.getFacadeMediator( owner );
            var aiComponent : CAIComponent = (owner.getComponentByClass( CAIComponent, true ) as CAIComponent);
            var attackable : CGameObject = aiComponent.currentAttackable;
            pFacadeMediator.directionTo( attackable );
        }

        //转向某个点
        public final function setDirectionToPoint( owner : CGameObject, ptx : Number, pty : Number ) : void {
            var pFacadeMediator : CFacadeMediator = this.getFacadeMediator( owner );
//        var vec3:CVector3 = CObject.get3DPositionFrom2D(ptx,pty);
            var offsetX : Number = ptx - owner.transform.x;
            var directionX : int = offsetX > 0 ? 1 : -1;
            pFacadeMediator.setDisplayDirection( directionX );
        }

        /**设置角色状态*/
        public final function setCharacterState( owner : CGameObject, stateType : String, bool : Boolean ) : void {
            var characterState : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            const tag : int = CCharacterStateBoard.TAG_AI;
            if ( stateType == EFightStateType.NOT_BE_ATTACK ) {
                characterState.setValue( CCharacterStateBoard.CAN_BE_ATTACK, false , tag );
            }
            else if ( stateType == EFightStateType.NOT_BE_BREAK ) {
                characterState.setValue( CCharacterStateBoard.PA_BODY, true , tag );
            }
            else if ( stateType == EFightStateType.NOT_BE_BREAK_AND_CATCH ) {
                characterState.setValue( CCharacterStateBoard.PA_BODY, true , tag );
                characterState.setValue( CCharacterStateBoard.CAN_BE_CATCH, false , tag );
            }
        }

        /**重置角色状态*/
        public final function resetCharacterState( owner : CGameObject ) : void {
            var characterState : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            const tag : int = CCharacterStateBoard.TAG_AI;
            characterState.resetValue( CCharacterStateBoard.CAN_BE_ATTACK , tag );
            characterState.resetValue( CCharacterStateBoard.PA_BODY , tag );
            characterState.resetValue( CCharacterStateBoard.CAN_BE_CATCH , tag);
        }

        public final function resetPATI( owner : CGameObject ) : void {
            var characterState : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

            const tag :int = CCharacterStateBoard.TAG_AI;
            characterState.resetValue( CCharacterStateBoard.PA_BODY, tag );
        }

        public final function resetGANGTI( owner : CGameObject ) : void {
            var characterState : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

            const tag :int = CCharacterStateBoard.TAG_AI;
            characterState.resetValue( CCharacterStateBoard.PA_BODY, tag );
            characterState.resetValue( CCharacterStateBoard.CAN_BE_CATCH , tag );
        }

        public final function resetWUDI( owner : CGameObject ) : void {
            var characterState : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

            const tag :int = CCharacterStateBoard.TAG_AI;
            characterState.resetValue( CCharacterStateBoard.CAN_BE_ATTACK, tag);
        }

        /**获取角色状态*/
        public final function getCharacterState( owner : CGameObject, value : int ) : Boolean {
            var characterState : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            return characterState.getValue( value );
        }

        public final function revive( owner : CGameObject ) : void {
            var pFacadeMediator : CFacadeMediator = this.getFacadeMediator( owner );
            if ( pFacadeMediator ) {
                pFacadeMediator.revive( owner );
            }
        }

        //--------------------------------------------------------------------------
        //--------------------------------功能相关-----------------------------------
        //--------------------------------------------------------------------------
        /**是否是英雄*/
        public function isHero( owner : CGameObject ) : Boolean {
            var pFacadeMediator : CFacadeMediator = this.getFacadeMediator( owner );
            if ( pFacadeMediator ) {
                return pFacadeMediator.isHero( owner.data );
            }
            return false;
        }

        /**是否是假人*/
        public function isSimulationPlayer( owner : CGameObject ) : Boolean {
            var simCompnent : CSimulationPlayer = owner.getComponentByClass( CSimulationPlayer , true )  as CSimulationPlayer;
            if( simCompnent != null )
                    return true;
            return false;
        }

        public function isTeamMate( owner : CGameObject ) : Boolean {
            var pFacadeMediator : CFacadeMediator = this.getFacadeMediator( owner );
            if ( pFacadeMediator ) {
                return pFacadeMediator.isTeammate( owner.data );
            }
            return false;
        }

        /**是否是队友*/
        public function isTeammate( owner : CGameObject ) : Boolean {
            var pFacadeMediator : CFacadeMediator = this.getFacadeMediator( owner );
            if ( pFacadeMediator ) {
                return pFacadeMediator.isTeammate( owner.data );
            }
            return false;
        }

        /**播放对话或音频*/
        public function play( owner : CGameObject, type : String, id : int, duration : Number, playMode : String ) : void {
            if ( type == EPlayType.AUDIO ) {

            }
            else if ( type == EPlayType.DAILOGUE ) {
                var dialogueTable : CDataTable;
                var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
                dialogueTable = pDatabaseSystem.getTable( KOFTableConstants.DIALOGUE ) as CDataTable;
                var dialogue : Dialogue = dialogueTable.findByPrimaryKey( id );
                (owner.getComponentByClass( CBubblesMediator, true ) as CBubblesMediator).bubblesTalk( dialogue.content, duration );
            }
        }

        /**获取传送门
         * [{"location" : {"x" : 1800.0,"y" : 600.0},"effect":"无","size": {"x" : 200.0,"y" : 200.0},"triggerTime":1.5}]
         * */
        public function getLevelPortal() : Array {
            var arr : Array = (system.stage.getSystem( ILevelFacade ) as ILevelFacade).getPortal();
            return arr;
        }

        /**
         * 获取trunk目标
         * targetType : int 目标类型
         * target : Array 目标数组
         * */
        public function getLevelCurTrunkPass() : Object {
            var obj : Object = (system.stage.getSystem( ILevelFacade ) as ILevelFacade).getTrunkGoals();
            return obj;
        }

        /**获取关卡trunk的rect信息*/
        public function getLevelCurTrunk() : Rectangle {
            var rec : Rectangle = (system.stage.getSystem( ILevelFacade ) as ILevelFacade).getCurTrunkRec();
            return rec;
        }

        /**获取关卡出场后的路径点*/
        public final function getLevelRoadPath( owner : CGameObject ) : Array {
            var id : int = getObjEntityID( owner );
            var levelFacade : ILevelFacade = this.system.stage.getSystem( ILevelFacade ) as ILevelFacade;
            var pathFindArr : Array = levelFacade.getAIPosition( id );
            return pathFindArr;
        }

        private var _range : Number = 200; //暂时不清楚，坐标转3d后
        /**获取关卡中AI的警戒范围*/
        private final function _getLevelAIWarnRange( owner : CGameObject ) : Object {
            if ( owner.data.warnRangeObj ) {
                return owner.data.warnRangeObj;
            }
            var id : int = getObjEntityID( owner );
            var levelFacade : ILevelFacade = this.system.stage.getSystem( ILevelFacade ) as ILevelFacade;
            var warnRangeObj : Object = levelFacade.getWarnRange( id );
            if ( warnRangeObj ) {
                if ( warnRangeObj.hasOwnProperty( "frontDistance" ) ) {
                    if ( warnRangeObj.frontDistance is Number ) {
                        delete warnRangeObj[ "frontDistance" ];
                        warnRangeObj.frontDistance = new Object();
                        warnRangeObj.frontDistance.x = 2000;
                        warnRangeObj.frontDistance.y = 600;
                    }
                }
                else {
                    warnRangeObj.frontDistance = new Object();
                    warnRangeObj.frontDistance.x = 2000;
                    warnRangeObj.frontDistance.y = 600;
                }
                if ( warnRangeObj.hasOwnProperty( "backDistance" ) ) {
                    if ( warnRangeObj.backDistance is Number ) {
                        delete warnRangeObj[ "backDistance" ];
                        warnRangeObj.backDistance = new Object();
                        warnRangeObj.backDistance.x = 2000;
                        warnRangeObj.backDistance.y = 600;
                    }
                }
                else {
                    warnRangeObj.backDistance = new Object();
                    warnRangeObj.backDistance.x = 2000;
                    warnRangeObj.backDistance.y = 600;
                }
                owner.data.warnRangeObj = warnRangeObj;
                return owner.data.warnRangeObj;
            }
            else {
                owner.data.warnRangeObj = new Object();
                owner.data.warnRangeObj.frontDistance = new Object();
                owner.data.warnRangeObj.backDistance = new Object();
                owner.data.warnRangeObj.frontDistance.x = 2000;
                owner.data.warnRangeObj.frontDistance.y = 600;
                owner.data.warnRangeObj.backDistance.x = 2000;
                owner.data.warnRangeObj.backDistance.y = 600;
                return owner.data.warnRangeObj;
            }
        }

        /**
         * 获取区域触发器范围{location:{x:111,y:111},size:{x:111,y:111}}
         * */
        public function getEntityRange() : Object {
            var obj : Object = getLevelCurTrunkPass();
            var entityObj : Object = obj.target[ 0 ] as Object;
            var entityID : int = entityObj.object[ 0 ].entityID;
            var levelFacade : ILevelFacade = this.system.stage.getSystem( ILevelFacade ) as ILevelFacade;
            return levelFacade.getTriggerRange( entityID );
        }

        public function currentTrunkPassWay() : int {
            var levelFacade : ILevelFacade = this.system.stage.getSystem( ILevelFacade ) as ILevelFacade;
            if ( levelFacade.curTrunkID == 100 ) {
                return levelFacade.currentLevel.trunkpassway[ 0 ];
            } else if ( levelFacade.curTrunkID == 200 ) {
                return levelFacade.currentLevel.trunkpassway[ 1 ];
            } else if ( levelFacade.curTrunkID == 300 ) {
                return levelFacade.currentLevel.trunkpassway[ 2 ];
            }
            return 0;
        }

        public function isTriggerWarnRange( owner : CGameObject ) : Boolean {
            var warnRangeObj : Object = _getLevelAIWarnRange( owner );
            return m_functionCategory.isTriggerWarnRange( owner, warnRangeObj );
        }

        public function stateChange( owner : CGameObject, state : String = "Idle_2", action : String = "Change_1" ,hurt:String="Hurt_1") : void {
            var dynamicBlock : CDynamicBlockComponent = owner.getComponentByClass( CDynamicBlockComponent, true ) as CDynamicBlockComponent;
            if ( !action ) {
                dynamicBlock.stateChanged();
            } else {
                (owner.getComponentByClass( CEventMediator, false ) as CEventMediator).addEventListener( CCharacterEvent.ANIMATION_TIME_END, chengeState, false, 0, true );
                var iAnimation : IAnimation = dynamicBlock.getComponent( IAnimation ) as IAnimation;
                iAnimation.addSkillAnimationState( action.toUpperCase(), action );
                iAnimation.playAnimation( action.toUpperCase() );
            }

            function chengeState( e : CCharacterEvent ) : void {
                (owner.getComponentByClass( CEventMediator, false ) as CEventMediator).removeEventListener( CCharacterEvent.ANIMATION_TIME_END, chengeState );
//                trace(state,hurt);
                dynamicBlock.stateChanged( state, hurt );
            }
        }

        public final function playWarnEffect( owner : CGameObject, warnEffectCallBack : Function ) : void {
            var playEffect : CMonsterSprite = owner.getComponentByClass( CMonsterSprite, true ) as CMonsterSprite;
            playEffect.showWarn( warnEffectCallBack );
        }

        /**获取关卡标记点*/
        public final function getLevelPosTag( tagName : int ) : Object {
            var levelFacade : ILevelFacade = this.system.stage.getSystem( ILevelFacade ) as ILevelFacade;
            var location : Object = levelFacade.getSingPoins( tagName );
            return location;
        }

        /**获取游戏对象的刷怪点ID*/
        private final function getObjEntityID( owner : CGameObject ) : int {
            return owner.data.entityID;
        }

        /**获取AI Data*/
        public final function getAITableData( id : int ) : AI {
            var aiTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            aiTable = pDatabaseSystem.getTable( KOFTableConstants.AI ) as CDataTable;
            return aiTable.findByPrimaryKey( id );
        }

        private function isAiIgnoreTarget(obj :  CGameObject ) : Boolean{
            var pMonsterProperty : CMonsterProperty = obj.getComponentByClass( CMonsterProperty , true ) as CMonsterProperty;
            if( pMonsterProperty != null && CCharacterDataDescriptor.isMonster( obj.data )) {
                return pMonsterProperty.BeTargeted == 0;
            }
            return false;
        }
        /**筛选对象
         *
         * 流程：基准角色——阵营——角色类型——属性筛选
         *
         * */
        public final function findAttackable( owner : CGameObject, campType : String, roleType : String, filterCondtion : String, baseOnRole : String, campID : String, serialID : String ) : CGameObject {
          return m_functionCategory.findAttackable( owner, campType, roleType, filterCondtion, baseOnRole, campID, serialID );
        }

        public final function findAttackableByCriteriaID( owner : CGameObject , criteriaID : int ) : CGameObject{
            return m_functionCategory.findAttackableByCriteriaId( owner , criteriaID );
        }

        /**找队友*/
        public function findTeammateObj( owner : CGameObject ) : Vector.<CGameObject> {
            return m_functionCategory.filterCamp( ECampType.FRIENDY, owner );
        }

        /**找敌方单位是否在基于角色的范围内*/
        public function findNuOfEnemyObjInRange( gameobj : CGameObject, rangeValue : Number, nu : int ) : Boolean {
            var objVec : Vector.<CGameObject> = m_functionCategory.filterCamp( ECampType.ENEMY, gameobj );
            var count : int = 0;
            for each ( var obj : CGameObject in objVec ) {
                var zrang : Number = rangeValue * 0.4;
                if ( obj.transform.x < gameobj.transform.x + rangeValue && obj.transform.x > gameobj.transform.x - rangeValue && obj.transform.y < gameobj.transform.y + zrang && obj.transform.y > gameobj.transform.y - zrang ) {
                    count++;
                }
            }
            if ( count >= nu ) {
                return true;
            }
            return false;
        }

        /**返回所有敌方单位*/
        public function findAllEnemyObj( owner : CGameObject ) : Vector.<CGameObject> {
            var objVec : Vector.<CGameObject> = m_functionCategory.filterCamp( ECampType.ENEMY, owner );
            return objVec;
        }

        /**按阵营筛选
         *
         * 取出当前场景的全部gameObj，再按阵营筛选
         *
         * */
        private function _filterCamp( type : String, gameObj : CGameObject ) : Vector.<CGameObject> {
            return m_functionCategory.filterCamp( type, gameObj );
        }

        /**筛选角色
         *
         * 内部逻辑：
         * 拿到阵营筛选的结果，再进行角色类型筛选
         *
         * */
        private function _filterRole( campType : String, roleType : String, gameObj : CGameObject ) : Vector.<CGameObject> {
            return m_functionCategory.filterRole( campType, roleType, gameObj );
        }

        /**按属性筛选
         *
         * 内部逻辑：
         *  拿到角色筛选的结果，再按属性筛选
         *
         * */
        private function _filterProperty( type : String, campType : String, roleType : String, gameObj : CGameObject ) : CGameObject {
            return m_functionCategory.filterProperty( type, campType, roleType, gameObj );
        }

        /**获取player*/
        public final function getPlayer( aiOwnerObj : CGameObject ) : CGameObject {
            return m_functionCategory.getPlayer( aiOwnerObj );
        }

        /**找当前可攻击目标*/
        public function findCurrentAttackable( owner : CGameObject ) : CGameObject {
            var aiComponent : CAIComponent = (owner.getComponentByClass( CAIComponent, true ) as CAIComponent);
            var attackable : CGameObject = aiComponent.currentAttackable;
            return attackable;
        }

        public function get m_system() : CAppSystem {
            return this.system;
        }

        public var isShowRoadLine : Boolean = false;

        public function getFacadeMediator( owner : CGameObject ) : CFacadeMediator {
            var pFacadeMediator : CFacadeMediator = owner.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
            if ( pFacadeMediator ) {
                if ( isShowRoadLine ) {
                    pFacadeMediator.isShowRoadLine = true;
                } else {
                    pFacadeMediator.isShowRoadLine = false;
                }
            }
            return pFacadeMediator;
        }

        //注册AI条件、行为类
        private function registerAIClass() : void {
            var actionVector : Vector.<Class> = new Vector.<Class>();
            actionVector.push( CFollowAction, CIdleAction, CMoveToAction, CCastSkillAction, CSelectTargetAction, CDoTriggerAction,
                    CExecuteAIAction, CEventOverAction, CMoveAction, CSetDirectionAction, CPlayAction, CMergeAIAction, CTimeTrrigerAction, CEventTrrigerAction,
                    CStateChangeAction, CAttractMonsterMoveAction, CPatrolAction, CRecoveryAction, CSelectTargetForValueAction, CCalculationDurationDamadgeAction,
                    CSetStateAction, CResetStateAction, CStopAction, CRandomMoveAction, CWaitAction, CTelesportAction, CWorldBossSkillAction, CReviveAction,
                    CFindPassTargetAction, CFindPassWayAction ,CPlayerUltimateSkillAction , CEvaluateCoolTimeAction,CSequenceTeleportAction );
            m_pAiSystem.registerAction( actionVector );

            var conditionVector : Vector.<Class> = new Vector.<Class>();
            conditionVector.push( CWhetherHitedByPlayerCondtion, CEventTriggerCondition, CTimeTriggerCondition, CWhetherHitTheTargetCondition,
                    CSelfResCondition, CJudgeDistanceTargetCondition, CSelfCondCondition, CWheatherTriggerEventCondition, CTargetCondCondition, CWheatherTriggerChangeAIEventCondition,
                    CTargetRESCondition, CEventTrueCondition, CRandomProbabilityCondition, CTimeTriggerAutoPassCondition, CSkillExecuteIsSuccessCondition ,CSwitchCondition );
            m_pAiSystem.registerCondition( conditionVector );
        }

        public function setEnable( v : Boolean ) : void {
            this.enabled = v;
        }
    }
}
