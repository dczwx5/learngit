/**
 * Created by auto on 2016/5/17.
 * 只是需要这么一个类而已, 以后移入gameDemo中, 使用CGameStage替换
 */
package preview.game {
import QFLib.Application.Component.CLifeCycleEvent;
import QFLib.Foundation;
import QFLib.Foundation.CKeyboard;
import QFLib.Foundation.CPath;
import QFLib.Foundation.CURLQson;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFX;
import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.ResourceLoader.CPackedQsonLoader;
import QFLib.ResourceLoader.CQbinLoader;
import QFLib.ResourceLoader.CQsonLoader;
import QFLib.ResourceLoader.CResourceLoaders;

import flash.events.TimerEvent;
import flash.ui.Keyboard;

import flash.utils.Timer;

import kof.data.CDatabaseSystem;
import kof.dummy.CDummyServer;

import kof.framework.CAppStage;
import kof.framework.events.CEventPriority;
import kof.game.config.CKOFConfigSystem;
import kof.game.core.CECSLoop;
import kof.game.instance.CInstanceSystem;
import kof.game.audio.CAudioSystem;

import kof.game.levelCommon.CLevelLog;
import kof.game.player.CPlayerSystem;
import kof.game.scenario.CScenarioSystem;
import kof.game.scene.CSceneRendering;
import kof.io.CVFSSystem;
import kof.login.CLoginSystem;
import kof.ui.CUISystem;

import preview.game.level.CLevelPreviewHandler;

import preview.game.levelServer.CLevelServer;
import kof.game.level.CLevelSystem;
import kof.game.scene.CSceneSystem;
import kof.net.CNetworkSystem;

import preview.game.bootstrap.CBootstrapSystem;
import preview.game.levelServer.CLevelServerSystem;

import preview.game.level.CLevelPreviewSystem;

public class CLevelStage extends CAppStage {
    public function CLevelStage() {
        super();

    }

    protected override function doStart() : Boolean {
        var ret:Boolean = super.doStart();
        if (ret) {
            this.addSystem( new CKOFConfigSystem() );

            var pConfigSystem : CKOFConfigSystem = this.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
            pConfigSystem.addEventListener( CLifeCycleEvent.AFTER_STARTING, _afterConfigSystemStartingEventHandler, false,
                    CEventPriority.DEFAULT, true );

//            this.addSystem( new CUISystem() );
//           // this.addSystem( new CFightUISystem() );
            this.addSystem( new CDatabaseSystem() );
//this.addSystem( new CVFSSystem() );
            this.addSystem( new CUISystem() );
            this.addSystem(new CAudioSystem());
//            this.addSystem(new CECSLoop());
//            this.addSystem(new CSceneSystem());
//            this.addSystem( new CPlayerSystem() );
//
//            // this.addSystem(new CLoginSystem());
//
//            this.addSystem(new CScenarioSystem());
//            var levelSystem:CLevelSystem = new CLevelSystem();
//            this.addSystem(levelSystem);
//            this.addSystem(new CInstanceSystem());
//
//            this.addSystem(new CBootstrapSystem()); // 游戏启动系统，协调各个核心系统
//
//
//            this.addSystem(new CLevelServerSystem());

            // this.addSystem(new CUISystem());


            // this.addSystem( new CFightUISystem() );


            system = new CLevelPreviewSystem();
            this.addSystem( system );

        }
        onSetup();
        return ret;
    }

    private function _afterConfigSystemStartingEventHandler( event : CLifeCycleEvent ) : void {
        var pConfigSystem : CKOFConfigSystem = this.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
//        var bEnableQsonLoading : Boolean = pConfigSystem.configuration.getBoolean( "enableQsonLoading" );
        CQsonLoader.enableQsonLoading = false;
        CURLQson.enableQsonLoading = false;
        CQbinLoader.enableQbinLoading = false;
        CPackedQsonLoader.enablePackedQsonLoading = false;
        //QFLib.ResourceLoader.CQsonLoader.enableQsonLoading = false;
        //QFLib.Foundation.CURLQson.enableQsonLoading = false;

        var sCdnURI : String = pConfigSystem.configuration.getString( "CdnURI", null );
        CResourceLoaders.instance().absoluteURI = sCdnURI;

        var sUIAssetsURI : String = pConfigSystem.configuration.getString("uiAssetsURI", "assets/ui");
        Config.resPath = CPath.addRightSlash( sCdnURI || "" ) + CPath.addRightSlash( sUIAssetsURI );
    }

    private function onSetup():Boolean {
        configuration.setConfig("role.data", {
            roleID: 10086,
            name: "Hero [Dummy]",
            profession: 10,
            level: 1,
            curExp: 0,
            money: 0,
            diamond: 0,
            x: 0,
            y: 0,
            dirX: 1,
            dirY: 0,
            line: 1,
            mapID: 0,
            battleValue: 0,
            atk: 10000,
            moveSpeed: 500,
            hp: 10000,
            mp: 1000
        });


        m_pKeyboard = new CKeyboard(flashStage);
        m_pKeyboard.registerKeyCode(true, Keyboard.C, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.V, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.X, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.Z, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.F1, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.F2, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.F3, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.F10, _onKeyDown); // auto test
        m_pKeyboard.registerKeyCode(true, Keyboard.F11, _onKeyDown); // auto test
        m_pKeyboard.enabled = true;




        return true;
    }

    protected override function setStarted() : void {
        super.setStarted();
        _isSetup = true;
        // 所有都启动完了
        // preview额外添加的对象
//        var levelSystem : CLevelSystem = this.getSystem(CLevelSystem) as CLevelSystem;
//        levelSystem.addBean(new CLevelPreviewHandler(), MANAGED);
//        (levelSystem.getBean(CLevelPreviewHandler) as CLevelPreviewHandler).start();
    }

    public override function tickUpdate(delta:Number) : void {
        super.tickUpdate(delta);

//        if (_firstStart && _isSetup) {
//            var dummyServer:CDummyServer = this.getSystem(CDummyServer) as CDummyServer;
//            if (dummyServer && dummyServer.channel) {
//                CLevelLog.addDebugLog("system setup completed");
//
//                if (getSystem(CBootstrapSystem)) {
//                    sendEnterLevel(); // 后台发起。要进入关卡
//                    _firstStart = false;
//                }
//            }
//        }
    }

//    private function sendEnterLevel() : void {
//        // to do
//        var timer:Timer = new Timer(1000, 1);
//        timer.addEventListener(TimerEvent.TIMER, onTimer);
//
//        // 创建网络连接。
//        configuration.setConfig('dummy', true);
//        (getSystem(CNetworkSystem) as CNetworkSystem).connect("", 0, function (param:Object) : void {
//            if (param is Error) {
//                CLevelLog.addDebugLog("connect error", true);
//            } else {
//                CLevelLog.addDebugLog("connect completed");
//                timer.start();
//
//            }
//
//        });
//
//        function onTimer(e:TimerEvent) : void {
//            timer.removeEventListener(TimerEvent.TIMER, onTimer);
//            timer.stop();
//            timer = null;
//
//            var levelServerSystem:CLevelServerSystem = getSystem(CLevelServerSystem) as CLevelServerSystem;
//            var  levelServer:CLevelServer = levelServerSystem.getBean(CLevelServer) as CLevelServer;
//            levelServer.enterLevel(CExeParam._instance.fbName, CExeParam._instance.heroId);
//        }
//    }


    private function _onKeyDown(keyCode:uint):void {
        var scene:CScene;
        var obj:CObject;
//        var PreviewSystem:CLevelPreviewSystem = getSystem(CLevelPreviewSystem) as CLevelPreviewSystem;
        var PreviewHandler:CLevelPreviewHandler = system.hadler;
        switch (keyCode) {
            case Keyboard.C:
                PreviewHandler.killOneMonster();
                break;
            case Keyboard.V:
                PreviewHandler.killAllEnemy();
                break;
            case Keyboard.X:
                PreviewHandler.killAllTeammates();
                break;
            case Keyboard.Z:
                PreviewHandler.killOneTeammates();
                break;
            case Keyboard.F1:
                CUILayer.getInstance().reverseShow();
                break;
            case Keyboard.F2:
                CUILayer.getInstance().reverseTrunkAreaShow();
                break;
            case Keyboard.F3:
                CUILayer.getInstance().reverseDebugShow();
                break;
            case Keyboard.F10:
                scene = (getSystem(CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
                for each( obj in  scene.staticObjectsMap) {
                    if (obj is CFX) {
                        var fx:CFX = obj as CFX;
                        if (fx.visible) {
                            fx.stop();
                            fx.play();
                        }
                    }
                }
                break;
            case Keyboard.F11:
                scene = (getSystem(CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
                for each( obj in  scene.staticObjectsMap) {
                    if( obj is CCharacter )
                    {
                        var character : CCharacter = obj as CCharacter;
                        if( character.visible )
                        {
                            if( character.animationController != null )
                            {
                                var iIdx : int = character.animationController.currentStateIndex;
                                if( iIdx == character.animationController.numStates - 1 ) iIdx = 0;
                                else iIdx++;

                                var sNextStateName : String = character.animationController.getStateByIndex( iIdx ).stateName;
                                Foundation.Log.logMsg( "Character name: " + character.name + " is playing state: " + sNextStateName );
                                character.playState( sNextStateName, false, true );
                            }
                        }
                    }
                }
                break;
        }
    }

    private var _isSetup:Boolean = false;
    private var _firstStart:Boolean = true;

    private var m_pKeyboard:CKeyboard;

    private var system:CLevelPreviewSystem;
}
}

