//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/5.
 */
package kof.game.level.imp {
    import QFLib.Interface.IDisposable;
    import QFLib.Utils.StringUtil;

    import flash.events.Event;

    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.IDataTable;
import kof.framework.events.CEventPriority;
import kof.game.common.CTest;
import kof.game.instance.enum.EInstanceType;
import kof.game.level.CLevelManager;
    import kof.game.levelCommon.CLevelLog;
    import kof.game.levelCommon.Enum.ETrunkEventType;
    import kof.game.levelCommon.info.CLevelConfigInfo;
    import kof.game.levelCommon.info.CLevelScenarioConfigInfo;
    import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
    import kof.game.levelCommon.info.event.CSceneEventInfo;
    import kof.game.levelCommon.info.levelScenario.CLevelScenarioScenarioInfo;
    import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
    import kof.game.scene.CSceneHandler;
    import kof.game.scene.CSceneRendering;
    import kof.game.scene.CSceneSystem;
    import kof.message.Level.EnterLevelResponse;
    import kof.table.Level;

    public class CLevelEnterProxy implements IDisposable {
    public function CLevelEnterProxy(levelManager:CLevelManager) {
        _levelManager = levelManager;
    }

    public function dispose() : void {
        _levelManager = null;
    }
    // for preview
    public function enterLevelForPreview(response:*) : void {
        _isLoadFinish = false;

        _levelManager.setCurrentTrunkID(100);
        CLevelLoadFile.loadFile(response.fileName, _onLoadFile, _levelManager.isScenarioInstance);
    }
    // client
    public function loadLevelFile(response:EnterLevelResponse) : Boolean {
        _isLoadFinish = false;

        CTest.log("加载关卡文件1");
        var levelTable:IDataTable = (_levelManager.system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.LEVEL);
        var lv:Level = levelTable.findByPrimaryKey(response.levelID) as Level;
        _levelManager.setCurrentTrunkID(response.truckID);
        var levelFileName:String = lv.Filename;
        CLevelLoadFile.loadFile(levelFileName, _onLoadFile, _levelManager.isScenarioInstance);

        return true;
    }

    private function _onLoadFile(levelJsonData:Object, levelScenarioJsonData:Object) : void {
        CLevelLog.addDebugLog("loadLevelFinish...");
        CTest.log("加载关卡文件完毕");

        var lvCfgInfo:CLevelConfigInfo = _levelManager.levelConfigInfo = CLevelParseInfo.parseJsonData(levelJsonData);
        if(_levelManager.m_instanceTypeTable.playtheplot){
            var lvScenarioCfgInfo:CLevelScenarioConfigInfo = new CLevelScenarioConfigInfo(levelScenarioJsonData);
            _joinScenarioInLevel(lvCfgInfo, lvScenarioCfgInfo); // 将剧情合并到关卡

            // 检查有没有开场剧情
            if (_levelManager.isScenarioInstance) {
                var startByScenarioEvent:CSceneEventInfo = this._findStartByScenario(lvCfgInfo);
                var isStartByScenario:Boolean = startByScenarioEvent != null;
                if (isStartByScenario) {
                    _levelManager.startSceneScenarioID = startByScenarioEvent.getParameterArray()[0];
                }
            }
        }

        CLevelLog.addDebugLog("create.level...");

        _createGameLevel(lvCfgInfo);
        var sceneRendering:CSceneRendering = (_levelManager.system.stage.getSystem(CSceneSystem).getBean(CSceneRendering) as CSceneRendering);
        sceneRendering.addEventListener( CSceneRendering.SCENE_CFG_COMPLETE, _onLoadSceneCompleted, false, CEventPriority.DEFAULT_HANDLER, false );
        _createScene(lvCfgInfo.map, 0, 0);
//        _levelManager._levelEffect.addEffect();
    }
    private function _onLoadSceneCompleted(e:Event) : void {
        CLevelLog.addDebugLog("sceneRendering.scene_cfg_complete");
        var sceneRendering:CSceneRendering = (_levelManager.system.stage.getSystem(CSceneSystem).getBean(CSceneRendering) as CSceneRendering);
        sceneRendering.removeEventListener( CSceneRendering.SCENE_CFG_COMPLETE, _onLoadSceneCompleted);
//        _levelManager.dispatchEvent(new Event(ELevelEventType.EVENT_LEVEL_LOAD_COMPLETED));
        _isLoadFinish = true;
        CTest.log("场景创建完成");

    }

    // 将剧情合并到关卡
    private function _joinScenarioInLevel(cfgInfo:CLevelConfigInfo, lvScenarioInfo:CLevelScenarioConfigInfo) : void {
        if (!lvScenarioInfo || !(lvScenarioInfo.hasScenario())) return ;
        for each (var scenarioNode:CLevelScenarioScenarioInfo in lvScenarioInfo.scenarios) {
            if (scenarioNode.scenarioID <= 0 && scenarioNode.trunk <= 0 && StringUtil.isNullOrEmpty(scenarioNode.event)) {
                CLevelLog.addDebugLog("joinScenarioInLevel : error param : " + "scenarioID : " + scenarioNode.scenarioID + ", trunk : " + scenarioNode.trunk + ", event : " + scenarioNode.event, true);
                continue ;
            }
            if (scenarioNode.surrender != 0) {
                continue ;
            }

            var trunkID:int = scenarioNode.trunk;
            var trunkInfo:CTrunkConfigInfo = cfgInfo.getTrunkById(trunkID);
            if (trunkInfo) {
                var findNode:Array = null;
                if (scenarioNode.isInTrunk) {
                    // 事件在trunk, 添加播放剧情事件到trunk的指定事件里
                    if (trunkInfo.hasOwnProperty(scenarioNode.event)) {
                        if (trunkInfo[scenarioNode.event] == null) trunkInfo[scenarioNode.event] = new Array();
                        findNode = trunkInfo[scenarioNode.event] as Array;
                    }
                } else {
                    // 事件在entity中
                    var entity:CTrunkEntityBaseData = trunkInfo.getEntityById(scenarioNode.entityType, scenarioNode.ID);
                    if (entity) {
                        if (entity[scenarioNode.event] == null) entity[scenarioNode.event] = new Array();
                        findNode = entity[scenarioNode.event] as Array;
                    }
                }
                if (findNode) {
                    // param : 参数1 : 剧情ID, 参数2 : 是否完全控制
                    var param:String = scenarioNode.scenarioID.toString()+","+scenarioNode.allControl;
                    var scenarioEventData:Object = {name:ETrunkEventType.SCENARIO, parameter:param, delay:scenarioNode.delay};
                    var event:CSceneEventInfo = new CSceneEventInfo(scenarioEventData);
                    findNode.unshift(event);
                } else {
                    CLevelLog.addDebugLog("joinScenarioInLevel : can't find event node or event not in node : " + "scenarioID : " + scenarioNode.scenarioID + ", trunk : " + scenarioNode.trunk + ", event : " + scenarioNode.event, true);
                }
            } else {
                CLevelLog.addDebugLog("joinScenarioInLevel : can't find trunk : " + "scenarioID : " + scenarioNode.scenarioID + ", trunk : " + scenarioNode.trunk + ", event : " + scenarioNode.event, true);
            }
        }
    }
    private function _findStartByScenario(lvCfgInfo:CLevelConfigInfo) : CSceneEventInfo {
        var firstTrunkActiveEvents:Array = lvCfgInfo.getTrunkById(100).activeEvents;
        if (firstTrunkActiveEvents && firstTrunkActiveEvents.length > 0) {
            for each (var sceneEvent:CSceneEventInfo in firstTrunkActiveEvents) {
                if (sceneEvent.name == ETrunkEventType.SCENARIO) {
                    return sceneEvent;
                }
            }
        }
        return null;
    }
    private function _createGameLevel(cfgInfo:CLevelConfigInfo) : void {
        if (_levelManager.gameLevel) {
            _levelManager.gameLevel.destroy();
        }
        _levelManager.gameLevel = new CGameLevel(cfgInfo);
    }
    private function _createScene(sceneName:String, roleX:Number, roleY:Number) : void {
        var sceneHandler:CSceneHandler = (_levelManager.system.stage.getSystem(CSceneSystem).handler as CSceneHandler);
        CLevelLog.addDebugLog("create scene : " + sceneName);
        sceneHandler.enterScene(sceneName, roleX, roleY, true);
    }

    public function isLoadFinish() : Boolean {
        return _isLoadFinish;
    }

    private var _levelManager:CLevelManager;

    private var _isLoadFinish:Boolean;
}
}
