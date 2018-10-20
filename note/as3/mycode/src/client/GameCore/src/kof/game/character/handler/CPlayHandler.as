//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.handler {

import QFLib.Foundation.CKeyboard;
import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.display.Stage;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import kof.data.KOFTableConstants;

import kof.framework.CAppSystem;
import kof.framework.IApplication;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.NPC.CNPCHandler;
import kof.game.character.ai.CAIHandler;
import kof.game.character.ai.CAILog;
import kof.game.character.collision.CCollisionHandler;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.sync.synctimeline.CFightTimeLineFacade;
import kof.game.character.movement.CMovementHandler;
import kof.game.character.movement.CNavigation;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.config.CKOFConfigSystem;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.IGameSetting;
import kof.game.level.ILevelFacade;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;
import kof.table.ButtonMapping;
import kof.table.ButtonMapping.EButtonFunctionType;

/**
 * Hero事件、状态等控制子系统
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPlayHandler extends CGameSystemHandler {

    static private var s_nFrameAlignRange : Array = [ 60, 30, 24, 12, 8 ];
    static private var s_nFrameAlignIndex : int = 0;

    /** 按键模式(左手方向键/右手方向键) */
    public static var CtrlMode:int = 0;

    /** @private */
    private var m_pHero : CGameObject;
    /** @private */
    private var m_pKeyboard : CKeyboard;

    /** @private */
    private var m_pMovingVector : Point;
    /** @private */
    private var m_bMovingVectorDirty : Boolean;
    /** @private */
    private var m_fLastPressedTime : Number = 0;
    /** @private */
    private var m_fLastReleasedTime : Number = 0;
    /** @private */
    private var m_nLastPressedKeyCode : uint;
    /** @private */
    private var m_nLastReleasedKeyCode : uint;

    /** @private */
    private var m_pNetworking : INetworking;
    /** @private */
    private var m_pSceneFacade : ISceneFacade;
    /** @private */
    private var m_pTableArr:Array;

    /** Creates a new CPlayHandler */
    public function CPlayHandler() {
        super( CCharacterInput );
    }

    /** Returns or set the hero reference. */
    final public function get hero() : CGameObject {
        return m_pHero;
    }

    /** @private */
    final public function set hero( value : CGameObject ) : void {
        if ( m_pHero == value )
            return;
        m_pHero = value;
    }

    public function setEnable(v:Boolean) : void {
        this.enabled = v;
    }

    override protected function onEnabled( value : Boolean ) : void {
        super.onEnabled( value );
        if ( value ) {
            dispatchEvent( new Event( "resetPlayState" ) );
        }
//        if ( m_pKeyboard )
//            m_pKeyboard.enabled = value;
    }

    /** @inheritDoc */
    override protected function onSetup() : Boolean {
        if ( !m_pKeyboard ) {
            m_pKeyboard = new CKeyboard( system.stage.flashStage );

            m_pTableArr = (system.stage.getSystem(IDatabase ) as IDatabase).getTable(KOFTableConstants.ButtonMapping ).toArray();

            /*
            m_pKeyboard.registerKeyCode( true, Keyboard.W, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.A, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.D, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.S, _onKeyDown );
            m_pKeyboard.registerKeyCode( false, Keyboard.W, _onKeyUp );
            m_pKeyboard.registerKeyCode( false, Keyboard.A, _onKeyUp );
            m_pKeyboard.registerKeyCode( false, Keyboard.D, _onKeyUp );
            m_pKeyboard.registerKeyCode( false, Keyboard.S, _onKeyUp );

            m_pKeyboard.registerKeyCode( true, Keyboard.UP, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.LEFT, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.RIGHT, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.DOWN, _onKeyDown );
            m_pKeyboard.registerKeyCode( false, Keyboard.UP, _onKeyUp );
            m_pKeyboard.registerKeyCode( false, Keyboard.LEFT, _onKeyUp );
            m_pKeyboard.registerKeyCode( false, Keyboard.RIGHT, _onKeyUp );
            m_pKeyboard.registerKeyCode( false, Keyboard.DOWN, _onKeyUp );
            */

            if(CKOFConfigSystem.GMSwitch) {
                // FIXME: 监听F12，打开和取消格子阻挡移动判定

                m_pKeyboard.registerKeyCode( false, Keyboard.F12, _onSkyWalkInputEvent );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMPAD_ADD, _onApplicationSpeedTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMPAD_SUBTRACT, _onApplicationSpeedTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMPAD_DIVIDE, _onApplicationSpeedTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMPAD_MULTIPLY, _onCharacterFrameAlignTester );

                // FIXME: 动作测试按键
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_1, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_2, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_3, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_4, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_5, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_6, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_7, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_8, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_9, _onActionStateTester );
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_0, _onActionStateTester );

                //FIXME:自动战斗
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_1, _onAutoFight );
                //FIXME:显示寻路路径
                m_pKeyboard.registerKeyCode( false, Keyboard.NUMBER_2, _showRoadLine );
            }

            /*
            m_pKeyboard.registerKeyCode( true, Keyboard.L, _onKeyDown ); // 闪

            // 技能1~10
            m_pKeyboard.registerKeyCode( true, Keyboard.J, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.K, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.U, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.I, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.O, _onKeyDown );
//            m_pKeyboard.registerKeyCode( true, Keyboard.P, _onKeyDown );
//            m_pKeyboard.registerKeyCode( true, Keyboard.N, _onKeyDown );
//            m_pKeyboard.registerKeyCode( true, Keyboard.M, _onKeyDown );
//            m_pKeyboard.registerKeyCode( true, Keyboard.COMMA, _onKeyDown );
//            m_pKeyboard.registerKeyCode( true, Keyboard.SEMICOLON, _onKeyDown );

            // 功能相关 Q/E 切换操作角色
            m_pKeyboard.registerKeyCode( true, Keyboard.Q, _onKeyDown );
            m_pKeyboard.registerKeyCode( true, Keyboard.E, _onKeyDown );

            // 测试：空格=>跳跃
             m_pKeyboard.registerKeyCode( true, Keyboard.SPACE, _onKeyDown );
             */

//            if(m_pTableArr && m_pTableArr.length)
//            {
//                for each(var info:ButtonMapping in m_pTableArr)
//                {
//                    m_pKeyboard.registerKeyCode( true, info.ID, _onKeyDown );
//                }
//            }
//
//            m_pKeyboard.registerKeyCode( true, Keyboard.NUMPAD_7, _onKeyDown );
//            m_pKeyboard.registerKeyCode( true, Keyboard.NUMPAD_8, _onKeyDown );
//            m_pKeyboard.registerKeyCode( true, Keyboard.NUMPAD_9, _onKeyDown );

            // 字母
            for(var i:int = 65; i <= 90; i++)
            {
                m_pKeyboard.registerKeyCode( true, i, _onKeyDown );
            }

            //up
            for( i = 65; i <= 90; i++)
            {
                m_pKeyboard.registerKeyCode( false , i , _onKeyUp );
            }

            // 小键盘
            for(i = 96; i <= 105; i++)
            {
                m_pKeyboard.registerKeyCode( true, i, _onKeyDown );
            }

            // 空格
            m_pKeyboard.registerKeyCode( true, Keyboard.SPACE, _onKeyDown );

            m_pKeyboard.enabled = false;
        }

        system.stage.flashStage.addEventListener( MouseEvent.CLICK, _onMouseClick, false, 0, true );
        system.stage.flashStage.addEventListener( MouseEvent.RIGHT_CLICK, _onMouseClick, false, 0, true );
        system.stage.flashStage.addEventListener( FocusEvent.FOCUS_OUT, resetKeyBoardStates, false, 0, true );
        return true;
    }

    /** @inheritDoc */
    override protected function onShutdown() : Boolean {
        if ( m_pKeyboard ) {
            m_pKeyboard.unregisterKeyCode( true, Keyboard.W, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.A, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.D, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.S, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.W, _onKeyUp );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.A, _onKeyUp );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.D, _onKeyUp );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.S, _onKeyUp );

            m_pKeyboard.unregisterKeyCode( true, Keyboard.UP, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.LEFT, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.RIGHT, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.DOWN, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.UP, _onKeyUp );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.LEFT, _onKeyUp );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.RIGHT, _onKeyUp );
            m_pKeyboard.unregisterKeyCode( false, Keyboard.DOWN, _onKeyUp );

            CONFIG::debug {
                m_pKeyboard.unregisterKeyCode( false, Keyboard.F12, _onSkyWalkInputEvent );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMPAD_ADD, _onApplicationSpeedTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMPAD_SUBTRACT, _onApplicationSpeedTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMPAD_DIVIDE, _onApplicationSpeedTester );

                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_1, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_2, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_3, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_4, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_5, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_6, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_7, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_8, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_9, _onActionStateTester );
                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_0, _onActionStateTester );

                m_pKeyboard.unregisterKeyCode( true, Keyboard.SPACE, _onKeyDown );

                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_1, _onAutoFight );

                m_pKeyboard.unregisterKeyCode( false, Keyboard.NUMBER_2, _showRoadLine );
            }

            /*
            m_pKeyboard.unregisterKeyCode( true, Keyboard.L, _onKeyDown ); // 闪

            // 技能1~10
            m_pKeyboard.unregisterKeyCode( true, Keyboard.J, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.K, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.U, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.I, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.O, _onKeyDown );
//            m_pKeyboard.unregisterKeyCode( true, Keyboard.P, _onKeyDown );
//            m_pKeyboard.unregisterKeyCode( true, Keyboard.N, _onKeyDown );
//            m_pKeyboard.unregisterKeyCode( true, Keyboard.M, _onKeyDown );
//            m_pKeyboard.unregisterKeyCode( true, Keyboard.COMMA, _onKeyDown );
//            m_pKeyboard.unregisterKeyCode( true, Keyboard.SEMICOLON, _onKeyDown );

            // 功能相关 Q/E 切换操作角色
            m_pKeyboard.unregisterKeyCode( true, Keyboard.Q, _onKeyDown );
            m_pKeyboard.unregisterKeyCode( true, Keyboard.E, _onKeyDown );
            */

//            if(m_pTableArr && m_pTableArr.length)
//            {
//                for each(var info:ButtonMapping in m_pTableArr)
//                {
//                    m_pKeyboard.unregisterKeyCode( true, info.ID, _onKeyDown );
//                }
//            }
//
//            m_pKeyboard.unregisterKeyCode( true, Keyboard.NUMPAD_7, _onKeyDown );
//            m_pKeyboard.unregisterKeyCode( true, Keyboard.NUMPAD_8, _onKeyDown );
//            m_pKeyboard.unregisterKeyCode( true, Keyboard.NUMPAD_9, _onKeyDown );

            // 字母
            for(var i:int = 65; i <= 90; i++)
            {
                m_pKeyboard.unregisterKeyCode( true, i, _onKeyDown );
            }

            // 小键盘
            for(i = 96; i <= 105; i++)
            {
                m_pKeyboard.unregisterKeyCode( true, i, _onKeyDown );
            }

            // 空格
            m_pKeyboard.unregisterKeyCode( true, Keyboard.SPACE, _onKeyDown );

            m_pKeyboard.dispose();
        }

        m_pKeyboard = null;

        system.stage.flashStage.removeEventListener( MouseEvent.CLICK, _onMouseClick );
        system.stage.flashStage.removeEventListener( MouseEvent.RIGHT_CLICK, _onMouseClick );

        m_pHero = null;

        return true;
    }

    private function _onMouseClick( event : MouseEvent ) : void {

        if ( !this.enabled )
            return;
        if((system.getBean(CNPCHandler) as CNPCHandler).isClickNpc()){
            return;
        }

        var obj:Object = event.target as Stage;
        if(obj == null) return;
        var targetPoint:CVector2  = new CVector2(event.stageX, event.stageY);
        var m_pSceneFacade:ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        if( m_pSceneFacade.scenegraph.mainCamera ){
            m_pSceneFacade.scenegraph.mainCamera.screenToWorld(targetPoint);
        }
        else{
            return;
        }

//        Starling.current.defaultCamera.screenToWorld( targetPoint );
//        LOG.logMsg( "Target point: " + targetPoint.toString() );
        var pDisplay : IDisplay = m_pHero.getComponentByClass( IDisplay, true ) as IDisplay;
        var vec3:CVector3 = CObject.get3DPositionFrom2D(pDisplay.modelDisplay,targetPoint.x,targetPoint.y);

        var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
        vec3 = scene.findNearbyGridPosition3D( vec3.x, vec3.y, vec3.z, vec3,scene.collisionData.movableBoxID);
//        var newTargetPoint:CVector2 = new CVector2(vec3.x,vec3.z);
        targetPoint.x = vec3.x;
        targetPoint.y = vec3.z;

        var _level:ILevelFacade = system.stage.getSystem(ILevelFacade) as ILevelFacade;
        var pFacadeMediator : CFacadeMediator = m_pHero.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
        var bool:Boolean = pFacadeMediator.moveTo( targetPoint, function():void{ _level.hideSceneClickFX(); } );//
        if(bool){
            _level.showSceneClickFX(vec3.x, vec3.y, vec3.z);
        }
        dispatchEvent( new Event( "clickTurnToMove" ) );
        var aiHandler:CAIHandler = system.getBean(CAIHandler) as CAIHandler;
        aiHandler.keyDown = false;
    }

    private function _onSkyWalkInputEvent( keyCode : uint ) : void {
        if ( keyCode == Keyboard.F12 ) {
            // Sky walk switch.

            var movementHandler : CMovementHandler = system.getBean( CMovementHandler ) as CMovementHandler;
            if ( movementHandler ) {
                movementHandler.skyWalk = !movementHandler.skyWalk;
            }
        }
    }

    private function _onCharacterFrameAlignTester( keyCode : uint ) : void {
        s_nFrameAlignIndex++;

        if ( s_nFrameAlignIndex >= s_nFrameAlignRange.length )
            s_nFrameAlignIndex = 0;

        var all : Object = m_pSceneFacade.gameObjectIterator;
        if ( all ) {
            for each ( var obj : CGameObject in all ) {
                var pDisplay : IDisplay = obj.getComponentByClass( IDisplay, true ) as IDisplay;
                if ( pDisplay ) {
                    pDisplay.modelDisplay.alignToFramePerSec = s_nFrameAlignRange[ s_nFrameAlignIndex ];
                }
            }
        }
    }

    private function _showRoadLine(keyCode:uint):void{
        if(m_pKeyboard.isKeyPressed(Keyboard.CONTROL)){
            var aiHandler:CAIHandler = system.getBean(CAIHandler) as CAIHandler;
            if(aiHandler.isShowRoadLine){
                aiHandler.isShowRoadLine = false;
            }else{
                aiHandler.isShowRoadLine = true;
            }
        }
    }

    private function _onAutoFight(keyCode:uint):void{
        var aiHandler:CAIHandler = system.getBean(CAIHandler) as CAIHandler;
        if(aiHandler.bAutoFight){
            aiHandler.bAutoFight = false;
        }else{
            aiHandler.bAutoFight = true;
        }
    }

    private function _onApplicationSpeedTester( keyCode : uint ) : void {
        var pApp : Object = system.stage.getBean( IApplication ) as IApplication;
        switch ( keyCode ) {
            case Keyboard.NUMPAD_ADD:
                // speed up
                pApp._baseDeltaFactor += 0.2;
                break;
            case Keyboard.NUMPAD_SUBTRACT:
                // speed down
                if ( pApp._baseDeltaFactor - 0.2 > 0 )
                    pApp._baseDeltaFactor -= 0.2;
                break;
            case Keyboard.NUMPAD_DIVIDE:
                // reset
                pApp._baseDeltaFactor = 1.0;
                break;
            default:
                break;
        }
    }

    private function _onActionStateTester( keyCode : uint ) : void {
        var pFacadeMediator : CFacadeMediator = m_pHero.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
        var pTimeLineFacade : CFightTimeLineFacade = m_pHero.getComponentByClass( CFightTimeLineFacade , true ) as CFightTimeLineFacade;
        if ( !pFacadeMediator )
            return;

        switch ( keyCode ) {
            case Keyboard.NUMBER_3:
//                pTimeLineFacade.traceTimeLineMsg();
//                    pFacadeMediator._testAddBuffToSelf([602101]);//( [126401,601305,103002]  601303 );
//                    pFacadeMediator._testShotMissile( 117401 );
//                    pFacadeMediator._testSetStateBoard( CCharacterStateBoard.PA_BODY , true , CCharacterStateBoard.TAG_AI);
                    pFacadeMediator._testLeaveDodge();
                break;
            case Keyboard.NUMBER_4:

                pFacadeMediator._testSetStateBoard( CCharacterStateBoard.PA_BODY , false , CCharacterStateBoard.TAG_AI);
//                pFacadeMediator._testTeleToTarget();
                break;
            case Keyboard.NUMBER_5:
                pFacadeMediator._testBorn();
                break;
            case Keyboard.NUMBER_6:
                pFacadeMediator._testDead();
                break;
            case Keyboard.NUMBER_7:
                pFacadeMediator._testRandomHurt(0 ,3);
                break;
            case Keyboard.NUMBER_8:
//                CAILog.enabledFailLog = !CAILog.enabledFailLog;
                pFacadeMediator._testKnockUp();
                break;
            case Keyboard.NUMBER_9: {
                // Toggle AI handler.
                var pAISystem : CAIHandler = system.getBean( CAIHandler );
                if ( pAISystem ) {
                    pAISystem.setEnable( !pAISystem.enabled);
                }
                break;
            }
            case Keyboard.NUMBER_0: {
                // toggle collision bound.
                var pCollisionSystem : CCollisionHandler = system.getBean( CCollisionHandler );
                if ( pCollisionSystem ) {
                    pCollisionSystem.showDebug = !pCollisionSystem.showDebug;
                }
                break;
            }
            default:
                break;
        }
    }

    [inline]
    final private function get pGameSettingData() : CGameSettingData {
        return system.stage.getSystem(IGameSetting )["gameSettingData"];
    }

    private function _onKeyUp( keyCode : uint ) : void {
        if (keyCode == Keyboard.Z) {
            return ;
        }

        var gameSettingData : CGameSettingData = pGameSettingData;


        switch ( keyCode ) {
            case Keyboard.W:
            case Keyboard.UP:
                m_pMovingVector.y += 1;
                m_bMovingVectorDirty = true;
                break;
            case Keyboard.S:
            case Keyboard.DOWN:
                m_pMovingVector.y -= 1;
                m_bMovingVectorDirty = true;
                break;
            case Keyboard.A:
            case Keyboard.LEFT:
                m_pMovingVector.x += 1;
                m_bMovingVectorDirty = true;
                break;
            case Keyboard.D:
            case Keyboard.RIGHT:
                m_pMovingVector.x -= 1;
                m_bMovingVectorDirty = true;
                break;

            default:
                break;
        }

        if( m_pHero && m_pHero.isRunning ) {
            var pInput : CCharacterInput = m_pHero.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
            if ( pInput !== null ) {
                switch ( keyCode ) {
                    case gameSettingData.attackKeyValue:// 攻击
                        pInput.addSkillUpRequest( 0 );
                        break;
                    case gameSettingData.dodgeKeyValue:// 闪避
                        break;
                    case gameSettingData.jumpKeyValue:// 跳跃
                        pInput.addSkillUpRequest( 1 );
                        break;
                    case gameSettingData.skill1KeyValue:// 1技能
                        pInput.addSkillUpRequest( 2 );
                        break;
                    case gameSettingData.skill2KeyValue:// 2技能
                        pInput.addSkillUpRequest( 3 );
                        break;
                    case gameSettingData.skill3KeyValue:// 3技能
                        pInput.addSkillUpRequest( 4 );
                        break;
                    case Keyboard.SPACE:// 大招
                        pInput.addSkillUpRequest( 5 );
                        break;
                    default:
                        break;
                }
            }
        }

        m_fLastReleasedTime = getTimer();
        m_nLastReleasedKeyCode = keyCode;
    }

    private function _onKeyDown( keyCode : uint ) : void {
        var bJump : Boolean = false;
        var actionCall : Boolean = false;
        if (keyCode == Keyboard.Z) {
            return ;
        }
            /*
            switch ( keyCode ) {
                case Keyboard.W:
                case Keyboard.UP:
                    m_pMovingVector.y -= 1;
                    m_bMovingVectorDirty = true;
                    break;
                case Keyboard.S:
                case Keyboard.DOWN:
                    m_pMovingVector.y += 1;
                    m_bMovingVectorDirty = true;
                    break;
                case Keyboard.A:
                case Keyboard.LEFT:
                    m_pMovingVector.x -= 1;
                    m_bMovingVectorDirty = true;
                    break;
                case Keyboard.D:
                case Keyboard.RIGHT:
                    m_pMovingVector.x += 1;
                    m_bMovingVectorDirty = true;
                    break;
                case Keyboard.J:
                    // Attack
                case Keyboard.L:
                    // Escape
                case Keyboard.K:
                case Keyboard.U:
                case Keyboard.I:
                case Keyboard.O:
    //            case Keyboard.P:
                case Keyboard.SPACE:
    //            case Keyboard.N:
    //            case Keyboard.M:
    //            case Keyboard.COMMA:
    //            case Keyboard.SEMICOLON:
                    // skill release
                    actionCall = true;
                    break;
    //            case Keyboard.SPACE:
                    // Jump
    //                bJump = true;
    //                break;
                case Keyboard.Q:
                case Keyboard.E:
                    // switch hero
                    actionCall = true;
                    break;
                default:
                    break;
            }
    //         */

        var buttonMapping:ButtonMapping = getInfoByKeyCode(keyCode);
        if(buttonMapping)
        {
            actionCall = buttonMapping.CtrlType == CPlayHandler.CtrlMode;
        }
        else
        {
            /*
            switch ( keyCode ) {
                case Keyboard.W:
                case Keyboard.UP:
                    m_pMovingVector.y -= 1;
                    m_bMovingVectorDirty = true;
                    break;
                case Keyboard.S:
                case Keyboard.DOWN:
                    m_pMovingVector.y += 1;
                    m_bMovingVectorDirty = true;
                    break;
                case Keyboard.A:
                case Keyboard.LEFT:
                    m_pMovingVector.x -= 1;
                    m_bMovingVectorDirty = true;
                    break;
                case Keyboard.D:
                case Keyboard.RIGHT:
                    m_pMovingVector.x += 1;
                    m_bMovingVectorDirty = true;
                    break;
            }
            */
        }

        m_fLastPressedTime = getTimer();
        m_nLastPressedKeyCode = keyCode;

        if ( !m_pHero ) {
            return;
        }

        var pInput : CCharacterInput = m_pHero.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        var pFacadeMediator : CFacadeMediator = m_pHero.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;

        //发布键盘事件

        if ( !this.enabled )
            return;

//        if ( actionCall ) {
            if ( pFacadeMediator ) {
                if ( !m_pHero || !m_pHero.isRunning )
                    return;

//                /*
                var gameSettingData:CGameSettingData = system.stage.getSystem(IGameSetting )["gameSettingData"];
                switch ( keyCode ) {
                    case gameSettingData.attackKeyValue:// 攻击
                        pInput.addSkillRequest( 0 );
                        break;
                    case gameSettingData.dodgeKeyValue:// 闪避
                        pInput.addActionCall( pFacadeMediator.dodgeSudden );
                        // pFacadeMediator.dodgeSudden();
                        break;
                    case gameSettingData.jumpKeyValue:// 跳跃
                        pInput.addSkillRequest( 1 );
                        break;
                    case gameSettingData.skill1KeyValue:// 1技能
                        pInput.addSkillRequest( 2 );
                        break;
                    case gameSettingData.skill2KeyValue:// 2技能
                        pInput.addSkillRequest( 3 );
                        break;
                    case gameSettingData.skill3KeyValue:// 3技能
                        pInput.addSkillRequest( 4 );
                        break;
                    case Keyboard.SPACE:// 大招
                        pInput.addSkillRequest( 5 );
                        break;
//                    case Keyboard.N:
//                        pInput.addSkillRequest( 6 );
//                        break;
//                    case Keyboard.M:
//                        pInput.addSkillRequest( 7 );
//                        break;
//                    case Keyboard.COMMA:
//                        pInput.addSkillRequest( 8 );
//                        break;
//                    case Keyboard.SEMICOLON:
//                        pInput.addSkillRequest( 9 );
//                        break;
                    case gameSettingData.keySwitchValue:// 切换格斗家
                        pInput.addActionCall( pFacadeMediator.switchPrevHero );
                        break;
                    case Keyboard.E:
                        pInput.addActionCall( pFacadeMediator.switchNextHero );
                        break;
                    default:
                        break;
                }
                var aiHandler:CAIHandler = system.getBean(CAIHandler) as CAIHandler;
                aiHandler.keyDown = true;
//                */

                /*
                var funcType:int = buttonMapping.FunctionType;
                if(funcType == EButtonFunctionType.E_ROLL)// 翻滚
                {
                    pInput.addActionCall( pFacadeMediator.dodgeSudden );
                }
                else if(funcType == EButtonFunctionType.SWITCH_PREV_HERO)
                {
                    pInput.addActionCall( pFacadeMediator.switchPrevHero );
                }
                else if(funcType == EButtonFunctionType.SWITCH_NEXT_HERO)
                {
                    pInput.addActionCall( pFacadeMediator.switchNextHero );
                }
                else if(funcType == EButtonFunctionType.MAP)
                {
                }
                else
                {
                    pInput.addSkillRequest(funcType - 1);
                }
                */
            }
//        } else if ( bJump ) {
//            if ( pFacadeMediator ) {
//                pFacadeMediator._testJump();
//            }
//        }
    }

    /** @inheritDoc */
    override protected function enterSystem( system : CAppSystem ) : void {
        // GameSystem started.
        m_pKeyboard.enabled = true;
        m_pMovingVector = new Point();

        m_pNetworking = system.stage.getSystem( INetworking ) as INetworking;
        m_pSceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
    }

    override protected function exitSystem( system : CAppSystem ) : void {
        if ( m_pKeyboard ) {
            m_pKeyboard.enabled = false;
        }

        m_pMovingVector = null;
        m_pNetworking = null;
        m_pSceneFacade = null;
    }

    /** @inheritDoc */
    override public function isComponentSupported( obj : CGameObject ) : Boolean {
        return obj == m_pHero; // 只处理当前的Hero对象
    }

    override public function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        var pInput : CCharacterInput = obj.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        if ( !pInput || !pInput.enabled ) {
            m_pMovingVector.x = 0;
            m_pMovingVector.y = 0;
            m_bMovingVectorDirty = false;
            return false;

        }

        var bValidated : Boolean = super.tickValidate( delta, obj );
        if ( !bValidated ) {
            return bValidated;
        }

        if ( m_pKeyboard && m_pKeyboard.enabled ) {
            const vTempVector : Point = new Point();
//            if ( m_pKeyboard.isKeyPressed( Keyboard.A ) || m_pKeyboard.isKeyPressed( Keyboard.LEFT ) )
//                vTempVector.x -= 1;
//            if ( m_pKeyboard.isKeyPressed( Keyboard.D ) || m_pKeyboard.isKeyPressed( Keyboard.RIGHT ))
//                vTempVector.x += 1;
//            if ( m_pKeyboard.isKeyPressed( Keyboard.W ) || m_pKeyboard.isKeyPressed( Keyboard.UP ))
//                vTempVector.y -= 1;
//            if ( m_pKeyboard.isKeyPressed( Keyboard.S ) || m_pKeyboard.isKeyPressed( Keyboard.DOWN ))
//                vTempVector.y += 1;

            var gameSettingData:CGameSettingData = system.stage.getSystem(IGameSetting )["gameSettingData"];
            if(gameSettingData.isDefaultUpKey())
            {
                if ( m_pKeyboard.isKeyPressed( Keyboard.W ) || m_pKeyboard.isKeyPressed( Keyboard.UP ) )
                    vTempVector.y -= 1;
            }
            else
            {
                if(m_pKeyboard.isKeyPressed(gameSettingData.keyUpValue))
                {
                    vTempVector.y -= 1;
                }
            }

            if(gameSettingData.isDefaultLeftKey())
            {
                if ( m_pKeyboard.isKeyPressed( Keyboard.A ) || m_pKeyboard.isKeyPressed( Keyboard.LEFT ) )
                    vTempVector.x -= 1;
            }
            else
            {
                if(m_pKeyboard.isKeyPressed(gameSettingData.keyLeftValue))
                {
                    vTempVector.x -= 1;
                }
            }

            if(gameSettingData.isDefaultDownKey())
            {
                if ( m_pKeyboard.isKeyPressed( Keyboard.S ) || m_pKeyboard.isKeyPressed( Keyboard.DOWN ) )
                    vTempVector.y += 1;
            }
            else
            {
                if(m_pKeyboard.isKeyPressed(gameSettingData.keyDownValue))
                {
                    vTempVector.y += 1;
                }
            }

            if(gameSettingData.isDefaultRightKey())
            {
                if ( m_pKeyboard.isKeyPressed( Keyboard.D ) || m_pKeyboard.isKeyPressed( Keyboard.RIGHT ) )
                    vTempVector.x += 1;
            }
            else
            {
                if(m_pKeyboard.isKeyPressed(gameSettingData.keyRightValue))
                {
                    vTempVector.x += 1;
                }
            }

            if ( vTempVector.subtract( m_pMovingVector ).length != 0 ) {
                m_fLastPressedTime = getTimer();
                m_pMovingVector.copyFrom( vTempVector );
                m_bMovingVectorDirty = true;
            }
        }

        // Normalize, fixed multi handle.
        if ( m_bMovingVectorDirty ) {
            m_bMovingVectorDirty = false;

            // clear CNavigation if pathlist running.
            var pNavigation : CNavigation = obj.getComponentByClass( CNavigation, true ) as CNavigation;
            var pEventMediator : CEventMediator = obj.getComponentByClass( CEventMediator, true ) as CEventMediator;

            if ( pNavigation && pNavigation.targetPoint ) {
                if ( pEventMediator ) {
                    pEventMediator.dispatchEvent( new Event( CCharacterEvent.STOP_MOVE, false, false ) );
                }

                pNavigation.clearPath( true );
            }

            pInput.wheel = m_pMovingVector;
        }


        return true;
    }

    private function getInfoByKeyCode(keyCode:int):ButtonMapping
    {
        if(m_pTableArr && m_pTableArr.length)
        {
            for each(var info:ButtonMapping in m_pTableArr)
            {
                if(info && info.ID == keyCode)
                {
                    return info;
                }
            }
        }

        return null;
    }

    /**
     * 因为TextEvent触发后舞台焦点丢失，无法响应keyUp事件，所以此处重置一次键位状态
     * =================add by Lune 18-06-12==========================
     */
    public function resetKeyBoardStates(e:FocusEvent):void
    {
        m_pKeyboard.enabled = m_pKeyboard.enabled;
    }
    [Inline]
    public function get lastControlTime() : Number {
        return m_fLastPressedTime > m_fLastReleasedTime ? m_fLastPressedTime : m_fLastReleasedTime;
    }
}
}
