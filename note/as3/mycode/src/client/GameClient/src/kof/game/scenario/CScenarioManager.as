/**
 * Created by auto on 2016/7/21.
 */
package kof.game.scenario {
import QFLib.Framework.CPostEffects;
import QFLib.Interface.IUpdatable;

import flash.display.Sprite;

import kof.framework.CAbstractHandler;
import kof.game.common.CDelayCall;
import kof.game.instance.IInstanceFacade;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.event.CScenarioEvent;
import kof.game.scenario.imp.CScenarioActorManager;
import kof.game.scenario.imp.CScenarioGameObjectManager;
import kof.game.scenario.imp.CScenarioLoadFile;
import kof.game.scenario.info.CScenarioCameraInfo;
import kof.game.scenario.info.CScenarioInfo;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scenario.timeline.CScenarioTimeLine;
import kof.ui.CUISystem;

public class CScenarioManager extends CAbstractHandler implements IUpdatable {
    public function CScenarioManager() {
    }
    public override function dispose()  : void {
        super.dispose();
        clear();

        _gameObjectManager.dispose();
        _timeLine.dispose();
        _actorManager.dispose();
    }
    public function clear() : void {
        _gameObjectManager.clear();
        _timeLine.clear();
        _actorManager.clear();
        _isStart = false;
        _isEndB = false;
        _isLoadFinish = false;
        _isCreateActor = false;
        _hasShowLoadingView = false;
        _isShowEnd = false;
        _isReturnLevel = true;
        _isESCEnable = false;
        _scenarioConfig = null;
        _scenarioOverFun = null;
        _isShowStartMask = true;
        _isShowEndMask = true;
        _isAllStop = false;
        _timeOutFlag = true;
        _levelStartScenarioID = -1;
    }
    override protected function onSetup():Boolean {
        _gameObjectManager = new CScenarioGameObjectManager(this);
        _timeLine = new CScenarioTimeLine(this);
        _actorManager = new CScenarioActorManager(this);

        _mask = new Sprite();
        return true;
    }

    // =================================================enter=================================================

    private var _mask:Sprite;
    private var _levelStartScenarioID:int = -1;
    public function enterScenario(scenarioID:int, controlType:int, scenarioOverCallback:Function, isShowStartMask:Boolean = true,
                                  isShowEndMask:Boolean = true, levelStartScenarioID:int = -1) : void {
        clear();


        _mask.graphics.clear();
        _mask.graphics.beginFill(0, 0.01);
        _mask.graphics.drawRect(0, 0, system.stage.flashStage.stageWidth, system.stage.flashStage.stageHeight);
        _mask.graphics.endFill();
        _mask.visible = true;
        (system.stage.getSystem(CUISystem) as CUISystem).rootContainer.addChild(_mask);

        _levelStartScenarioID = levelStartScenarioID;
        _scenarioOverFun = scenarioOverCallback;
        _isShowStartMask = isShowStartMask;
        _isShowEndMask = isShowEndMask;
        CLevelLog.addDebugLog("start scenario...");
        (this.system as CScenarioSystem).dispatchScenarioUpdate(CScenarioEvent.EVENT_SCENARIO_ENTER, (scenarioID), controlType, false);

        function _onLoadScenarioFail(data:Object) : void {
            if (data.error) {
                CLevelLog.addDebugLog("end scenario by error...");
                (system as CScenarioSystem).dispatchScenarioUpdate(CScenarioEvent.EVENT_SCENARIO_END, (scenarioID), controlType, true);
                 if (_scenarioOverFun) {
                     _scenarioOverFun(scenarioID);
                 }
                _isAllStop = true;
                _isEndB = true;
                if (_mask && _mask.parent) {
                    _mask.parent.removeChild(_mask);
                }

            } else {
                _scenarioConfig = new CScenarioInfo(data);
//                _actorManager.start();
                _isLoadFinish = true;
            }
        }
        CScenarioLoadFile.loadFile(scenarioID.toString(), _onLoadScenarioFail);
    }

    // 开始剧情
    private function _startScenario() : void {
        var isInMainCity : Boolean = (system.stage.getSystem( IInstanceFacade ) as IInstanceFacade).isMainCity;
        if(_isAllStop &&　isInMainCity){
            _endScenario();//这里保险处理，立刻结束剧情（当播放剧情的瞬间，点击退出副本按钮了，会导致剧情继续播放）
            return;
        }
        _onMaskFinish();
        CPostEffects.getInstance().registerPostEffect(CPostEffects.Blur);
    }

    private function _onMaskFinish() : void {

//        (system as CScenarioSystem).dispatchScenarioUpdate(CScenarioEvent.EVENT_SCENARIO_START, (_scenarioConfig.scenarioId), _scenarioConfig.type, false);
        _isStart = true;
        _timeLine.start();
        (system.getBean(CScenarioViewHandler) as CScenarioViewHandler).startKeyboard();
        if(!_isESCEnable){
            (system.getBean(CEscViewHandler) as CEscViewHandler).showEscView();
        }
    }
    private function _endScenario() : void {
        (system.getBean(CScenarioViewHandler) as CScenarioViewHandler).endKeyboard();
        (system.getBean(CScenarioViewHandler) as CScenarioViewHandler).hideScenarioDialog();
        (system.getBean(CEscViewHandler) as CEscViewHandler).hideEscView();

        _isStart = false;
        _timeLine.end();

        var isInMainCity : Boolean = (system.stage.getSystem( IInstanceFacade ) as IInstanceFacade).isMainCity;
        if(isInMainCity || !_isShowEndMask){
            _onMaskProcess();
            _endBlackFinish();
        }else{
            (system.getBean(CScenarioViewHandler) as CScenarioViewHandler).showMaskView(_endBlackFinish,_onMaskStart,_onMaskProcess,3.0);
        }
        _system.setPlayEnable(true);
        _system.setAIEnable(true);
    }

    private function _onMaskStart():void{

    }

    private function _onMaskProcess():void{


        //黑屏中...
        _actorManager.end();//移除剧情中的角色，并且显示主角

        (system as CScenarioSystem).dispatchScenarioUpdate(CScenarioEvent.EVENT_SCENARIO_END, _scenarioConfig.scenarioId, _scenarioConfig.type, false, _scenarioConfig.returnLevel);
        if (_scenarioOverFun) {
            _scenarioOverFun(_scenarioConfig.scenarioId);
        }//剧情结束回调，告诉服务端剧情结束，然后服务端开始刷怪


        var isInMainCity : Boolean = (system.stage.getSystem( IInstanceFacade ) as IInstanceFacade).isMainCity;
        //0显示1隐藏
        if ( _scenarioConfig.hideAvatarEnd != 0 && !isInMainCity) {
            gameObjectManager.setHeroVisible(false);
            gameObjectManager.showTeammatesInSceneByHide(false);
        } else {
            gameObjectManager.setHeroVisible(true);
            gameObjectManager.showTeammatesInSceneByHide();
        }

        if ( _scenarioConfig.isTeleport ) {
            var setTeleportCallback:Function = function () : void {
                _isEndB = true;
                (system as CScenarioSystem).dispatchScenarioUpdate(CScenarioEvent.EVENT_SCENARIO_END_B,
                        _scenarioConfig.scenarioId, _scenarioConfig.type, false, _scenarioConfig.returnLevel);

            };

            //如果瞬移
            gameObjectManager.setHeroTeleport( _scenarioConfig.teleportVec2, _scenarioConfig.teleportDir, setTeleportCallback );
        }

        _gameObjectManager.resetCamera();
        _gameObjectManager.end();

        if ( _scenarioConfig.isTeleport == false) {
            _isEndB = true;
            (system as CScenarioSystem).dispatchScenarioUpdate(CScenarioEvent.EVENT_SCENARIO_END_B,
                    _scenarioConfig.scenarioId, _scenarioConfig.type, false, _scenarioConfig.returnLevel);
        }
    }

    private function _endBlackFinish() : void {
        //黑屏结束...

        if (_mask && _mask.parent) {
            _mask.parent.removeChild(_mask);
        }
        _isAllStop = true;
        CLevelLog.addDebugLog("end scenario...");
        (system as CScenarioSystem).dispatchScenarioUpdate(CScenarioEvent.EVENT_SCENARIO_END_C);
        CPostEffects.getInstance().stop( CPostEffects.Blur );
    }

    // =================================================update=================================================

    public function update(delta:Number) : void {
        if (_isStart) {
            _timeLine.update(delta);
            if (_timeLine.isFinish()) {
                _endScenario();
            }
        } else {
            if (_isLoadFinish) {
                if(_timeOutFlag){
                    _gameObjectManager.resetTimeOut();
                    _timeOutFlag = false;
                }
                if (_gameObjectManager.isAllGameObjectStop( delta )) {
                    //创建剧情角色
                    if(!_isCreateActor && !_hasShowLoadingView){
                        if(_isShowStartMask){
                            scenarioViewHandler.showScenarioStartView(_showLoadingStart);
                        }else{
                            _showLoadingStart();
                        }
                        if (scenarioInfo.scenarioId != _levelStartScenarioID) {
                            (system.getBean(CScenarioLoadingViewHandler2 ) as CScenarioLoadingViewHandler2).addDisplay();

                        }
                        _hasShowLoadingView = true;
                    }

                    if( _isCreateActor && _isShowEnd && actorManager.allActorComplete() && actorManager.allSceneObjectComplete() ){
                        _isLoadFinish = false;
                        _showLoadingEnd();

                    }
                }
            }
        }
    }

    private function _showLoadingStart():void{
        _actorManager.start();
        _isCreateActor = true;
        _isShowEnd = true;

        _isESCEnable = _scenarioConfig.isESCEnable;
        _isReturnLevel = _scenarioConfig.returnLevel;

        var obj:CScenarioCameraInfo = scenarioInfo.camera;
        if(obj && !obj.Default){
            _gameObjectManager.initCamera();
        }

        _gameObjectManager.start();
        if (_scenarioConfig.hideMonster != 0) {
            gameObjectManager.hideAllMonsterInScene();
        }


        if (_scenarioConfig.hideAvatar != 0) {
            //0默认显示1隐藏
            gameObjectManager.setHeroVisible(false);
        }
        _system.setPlayEnable(false);
        _system.setAIEnable(false);

        gameObjectManager.hideTeammates();

    }

    private function _showLoadingEnd():void{

        (system as CScenarioSystem).dispatchScenarioUpdate(CScenarioEvent.EVENT_SCENARIO_START, (_scenarioConfig.scenarioId), _scenarioConfig.type, false);

         (system.getBean(CScenarioLoadingViewHandler2 ) as CScenarioLoadingViewHandler2).removeDisplay();

        if (scenarioInfo.scenarioId == _levelStartScenarioID) {
            // 开场剧情, 因为loading会delay 0.28秒才关闭, 会出现loading没关闭, 剧情就出现了, 在这里，把剧情显示delay 0.5秒
            new CDelayCall(_delayPlayScenario, 0.5);
        } else {
            _delayPlayScenario();
        }


    }
    private function _delayPlayScenario() : void {
        if(_isShowStartMask){
            _startScenario();
            scenarioViewHandler.showScenarioEndView(function():void{
            });
        }else{
            _startScenario();
        }
    }

    // =================================================action=================================================

    public function stopPart(partID:int) : void {
        _timeLine.stopPart(partID);
    }
    public function stopAllPart() : void {
        _timeLine.stopAllPart();
        _isAllStop = true;
    }

    public function removeDialogOption(partInfo:CScenarioPartInfo) : void {
        _timeLine.removeDialogOption(partInfo);
    }

    // =================================================get/set=================================================

    public function get gameObjectManager() : CScenarioGameObjectManager {
        return _gameObjectManager;
    }
    public function get actorManager() : CScenarioActorManager {
        return _actorManager;
    }
    public function get scenarioInfo() : CScenarioInfo {
        return this._scenarioConfig;
    }
    public function get isStart() : Boolean {
        return _isStart;
    }

    public function get isEscEnable():Boolean {
        return _isESCEnable;
    }

    public function get scenarioViewHandler() : CScenarioViewHandler {
        return (system.getBean(CScenarioViewHandler) as CScenarioViewHandler);
    }

    private var _scenarioConfig:CScenarioInfo;
    private var _isStart:Boolean; // 内部使用, 是否开始播放剧情
    private var _timeLine:CScenarioTimeLine;

    private var _gameObjectManager:CScenarioGameObjectManager; // 非剧情对象管理
    private var _actorManager:CScenarioActorManager;
    private var _isLoadFinish:Boolean;
    private var _scenarioOverFun:Function;
    private var _isShowStartMask:Boolean = true;//是否显示开场黑屏
    private var _isShowEndMask:Boolean = true;//是否显示剧情结束黑屏

    private var _hasShowLoadingView:Boolean = false; // 是否已显示loading动画
    private var _isCreateActor:Boolean;
    private var _isShowEnd:Boolean;

    private var _isESCEnable:Boolean = false;//是否过滤掉ESC快捷键（ESC键会强制退出剧情）
    private var _isReturnLevel:Boolean = true;

    private var _timeOutFlag:Boolean = true;

    private var _isAllStop:Boolean = true; // 是否完全结束剧情, 黑幕完全结束
    [Inline]
    public function get isAllStop():Boolean {
        return _isAllStop;
    }

    private var _isEndB:Boolean = true; // 黑幕, 发END事件, 处理完剧情事件之后
    [Inline]
    public function get isEndB():Boolean {
        return _isEndB;
    }
    [Inline]
    private function get _system() : CScenarioSystem {
        return system as CScenarioSystem;
    }
}
}
