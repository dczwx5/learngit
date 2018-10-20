/**
 * Created by auto on 2016/5/31.
 */
package {
import QFLib.Foundation.CMap;
import QFLib.Framework.CObject;
import QFLib.Graphics.Scene.CCamera;
import QFLib.Math.CAABBox2;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import kof.framework.CAppStage;
import kof.game.CGameStage;
import kof.game.character.CFacadeMediator;

import kof.game.character.handler.CPlayHandler;
import kof.game.core.CGameObject;

import kof.game.core.CECSLoop;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.level.CLevelUIHandler;
import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;

import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;
import preview.game.levelServer.CLevelServerTriggerHandler;
import preview.game.levelServer.trigger.CTriggerGlobalMonster;

import kof.game.scene.CSceneObjectLists;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;

import preview.game.levelServer.trigger.CTriggerPortal;
import preview.game.levelServer.trigger.CTriggerTimer;
import preview.game.levelServer.trigger.CTriggerZone;
import preview.game.levelServer.trunkState.CLevelTrunkPortalState;
import preview.ui.CDebugLayer;
import preview.ui.CGoLayer;

import preview.ui.CInfoLayer;
import preview.ui.CResultLayer;
import preview.ui.CTrunkLayer;
import preview.ui.compoent.CBaseLayer;

public class CUILayer extends CBaseLayer {
    public function CUILayer(appStage:CGameStage = null) {
        if (_instance) throw new Error("CUILayer had created");
        _instance = this;

        _levelStage = appStage;
    }
    public function setAppStage(appStage:CAppStage) : void {
//        _levelStage = appStage;
    }
    public static function getInstance() : CUILayer {
        return _instance;
    }

    protected override function _onAdd() : void {
        super._onAdd();

        _infoVisible = true;

        this.setSize(stage.stageWidth, stage.stageHeight);
        this.bgGoDie();
        _result = new CResultLayer();
        this.addChild(_result);

        _trunkLayer = new CTrunkLayer();
        this.addChild(_trunkLayer);

        _debugLayer = new CDebugLayer(uiWidth, 200);
        _debugLayer.toLeft();
        _debugLayer.toBottom();
        this.addChild(_debugLayer);

        _infoLayerRight = new CInfoLayer(300, 250);
        this.addChild(_infoLayerRight);
        _infoLayerRight.toRightBottom();

        _infoLayerLeft = new CInfoLayer(300, 250);
        this.addChild(_infoLayerLeft);
        _infoLayerLeft.toRightBottom();
        _infoLayerLeft.x -= _infoLayerRight.uiWidth;

        _infoLayerMid = new CInfoLayer(300, 250);
        this.addChild(_infoLayerMid);
        _infoLayerMid.toRightBottom();
        _infoLayerMid.x -= (_infoLayerLeft.uiWidth+_infoLayerRight.uiWidth);


        _goLayer = new CGoLayer(100, 30);
        this.addChild(_goLayer);
        _goLayer.toCenter();
        _goLayer.toRight();



        _lastStageSize = new Point();
        this.addEventListener(Event.ENTER_FRAME, _onFrame);

        reverseShow();

    }
    protected override function _onRemove() : void {
        super._onRemove();
        this.removeEventListener(Event.ENTER_FRAME, _onFrame);

        this.removeChild(_goLayer);
        _goLayer = null;

        this.removeChild(_infoLayerRight);
        _infoLayerRight = null;

        this.removeChild(_infoLayerLeft);
        _infoLayerLeft = null;

        this.removeChild(_infoLayerMid);
        _infoLayerMid = null;

        this.removeChild(_trunkLayer);
        _trunkLayer = null;

        this.removeChild(_result);
        _result = null;

        this.removeChild(_debugLayer);
        _debugLayer = null;
    }

    ///.=======================================
    private var _loopCount:int = 0;
    private var _lastTime:Number;
    private function _onFrame(e:Event) : void {
        if (!visible) return ;

        var delta:Number = (getTimer() - _lastTime)/1000;
        _lastTime = getTimer();

//        ++_loopCount;
//        var v:int = (_loopCount % 3);
//        var v2:Boolean = (_loopCount % 3) != 0;
//        if ((_loopCount % 3) != 0) return ; // 虽然不注重效率。但3帧执行一次够了

        var data:Object = _parseMapObjectInfo();
        _infoLayerRight.updateByData(data);
        _infoLayerRight.toRightBottom();

        data = _parseSceneInfo();
        _infoLayerLeft.updateByData(data);
        _infoLayerLeft.toRightBottom();
        _infoLayerLeft.x -= _infoLayerRight.uiWidth;

        data = _parseSystemInfo();
        _infoLayerMid.updateByData(data);
        _infoLayerMid.toRightBottom();
        _infoLayerMid.x -= (_infoLayerLeft.uiWidth+_infoLayerRight.uiWidth);


        if (_trunkLayer.visible) {
            data = _parseTrunkAreaData();
            _trunkLayer.updateFromData(data);
        }

        data = _parseResultData();
        _result.updateFromData(data);

//        if (_isShowGo()) {
//            _goLayer.visible = true;
//            _goLayer.update(delta);
//        } else {
//            _goLayer.visible = false;
//        }
        _goLayer.visible = false;

        data = _parseDebugLog();
        if (data && data.length > 0) {
             _debugLayer.updateFromData(data);
            //_debugLayer.visible = true;
        } else {
            //_debugLayer.visible = false;
        }

        // onSize有时会失效, 不知道为啥
        if (_lastStageSize.x != stage.stageWidth || _lastStageSize.y != stage.stageHeight) {
            _onResize(null);
        }
    }

    private function _parseMapObjectInfo() : Object {
        if (!_levelStage) return null;
        var data:Object = new Array();
        var sceneSystem:CSceneSystem = _levelStage.getSystem(CSceneSystem) as CSceneSystem;
        var sceneObjectList:CSceneObjectLists = sceneSystem ? sceneSystem.getBean(CSceneObjectLists) as CSceneObjectLists : null;

        var m:CGameObject;
        // monster
        if (sceneObjectList) {
            var monsters:Vector.<Object> = sceneObjectList.getMonsters();
            if (monsters) {
                var reallyMonsters:Vector.<CGameObject> = new Vector.<CGameObject>();
                for each (m in monsters) {
                    if (m && (!(m.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).isDead)) {
                        reallyMonsters.push(m);
                    }
                }
                data.push("monster count : " + reallyMonsters.length);
                for each (m in reallyMonsters) {
                    if (m.transform && m.transform.position) {
                        data.push("    ==>monster : x : " + m.transform.x + ", y : " + m.transform.y);
                    } else {
                        data.push("    ==>monster : transfrom is null");
                    }
                }
            }
        }
        // mapObject
        if (sceneObjectList) {
            var mapObjectList:Vector.<Object> = sceneObjectList.getMapObjects();
            if (mapObjectList) {
                var liveMapObject:Vector.<CGameObject> = new Vector.<CGameObject>();
                for each (m in mapObjectList) {
                    if (m && (!(m.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).isDead)) {
                        liveMapObject.push(m);
                    }
                }
                data.push("mapObject count : " + liveMapObject.length);
                for each (m in liveMapObject) {
                    data.push("    ==>mapObject : x : " + m.transform.x + ", y : " + m.transform.y);
                }
            }
        }
        return  data;
    }

    private function _parseSystemInfo() : Object {
        var data:Object = new Array();
        data.push("version : 0.02");
        data.push("(Z) : 杀死一个同阵营怪物 (X) : 杀死所有同阵营怪物");
        data.push("(C) : 杀死一个敌对怪物, (V) : 杀死所有敌对怪物");
        data.push("(F12):场景碰撞,(F1):显隐面板,(F2):显隐trunk区域");
        data.push("(F3)debug info");
        data.push("(F10)播放场景特效(F11)播放场景动画");

        var sceneSystem:CSceneSystem = _levelStage.getSystem(CSceneSystem) as CSceneSystem;
        var scene:CSceneRendering = sceneSystem ? sceneSystem.getBean(CSceneRendering) as CSceneRendering : null;
        var camera:CCamera = scene ? scene.mainCamera : null;

        if (stage) {
            data.push("win : (" + stage.stageWidth + ", " + stage.stageHeight + ")");
        }

        // mouse
        if (camera) {
            var pos:Point = new Point(stage.mouseX, stage.mouseY);
            pos = pos.add(new Point(camera.min.x, camera.min.y));
            data.push("mouse stage : " + "(" + (int)(stage.mouseX) + "," + (int)(stage.mouseY) +")")
            data.push("mouse scene : " + "(" + (int)(pos.x) + "," + (int)(pos.y) +")")
        }

        return  data;
    }
    private function _parseSceneInfo() : Object {
        if (_levelStage == null) return null;

        var data:Object = new Array();
        var sceneSystem:CSceneSystem = _levelStage.getSystem(CSceneSystem) as CSceneSystem;
        var gameSystem:CECSLoop = _levelStage.getSystem(CECSLoop) as CECSLoop;
        var serverSystem:CLevelServerSystem = _levelStage.getSystem(CLevelServerSystem) as CLevelServerSystem;
        var levelServer:CLevelServer = serverSystem ? (serverSystem.getBean(CLevelServer) as CLevelServer) : null;
        var scene:CSceneRendering = sceneSystem ? sceneSystem.getBean(CSceneRendering) as CSceneRendering : null;
        var camera:CCamera = scene ? scene.mainCamera : null;
        var player:CPlayHandler = gameSystem ? gameSystem.getBean(CPlayHandler) as CPlayHandler : null;
        var triggerHandler:CLevelServerTriggerHandler = levelServer ? levelServer.triggerHandler : null;

        var levelSystem:CLevelSystem = _levelStage.getSystem(CLevelSystem) as CLevelSystem;
        var levelCleveManager:CLevelManager = levelSystem ? levelSystem.getBean(CLevelManager) as CLevelManager : null;

//        var levelUIHandler:CLevelUIHandler = levelSystem.getBean(CLevelUIHandler) as CLevelUIHandler;
        // trunk目标 预览不需要显示目标
//        if (levelServer && levelServer.curTrunkData && levelServer.curTrunkData.trunkInfo&& levelUIHandler) {
//            var trunkTargetTxt:String = levelUIHandler.getTargetTextByTrunkInfo(10001, levelServer.curTrunkData.trunkInfo);
//            data.push(trunkTargetTxt);
//        }


        // camera
        if (camera) {
            var center:CVector2 = camera.center;
            var ext:CVector2 = camera.ext;
            var viewPortSize:CVector2 = ext; // camera.getViewPortSize();
            data.push("camera : x : " + (int)(center.x) + ", y : " + (int)(center.y) +
                    ", size : ("+ (int)(viewPortSize.x*2) + ", " + (int)(viewPortSize.y*2) + ")");
            data.push("camera min : " + (int)(camera.min.x) + " : "+ (int)(camera.min.y));
        }

        // trunk
        if (camera) {
            var rect:CAABBox2 = camera.movableBox; // .camera.curLockTrunkArea;
            if (rect) {
                data.push("trunk : LT:("+(int)(rect.min.x) + "," + (int)(rect.min.y )+ "), RB:(" + (int)(rect.max.x) + "," + (int)(rect.max.y) + ")");
            } else {
                data.push("trunk : 无锁屏");
            }

        }

        // 刷怪区域
        if (levelCleveManager) {
            /* var trunkInfo:String = "trunk : ";
            if (levelCleveManager && levelCleveManager.curTrunkData) {
                trunkInfo += "ID : " + levelCleveManager.curTrunkData.ID;
                trunkInfo += ", State : active";
                data.push(trunkInfo);
                var rectZone:Rectangle = levelCleveManager.curTrunkData.getTrunkRect();
                data.push("刷怪区域 : LT:("+(int)(rectZone.x) + "," + (int)(rectZone.y) + "), RB:(" + (int)(rectZone.x+rectZone.width) + "," + (int)(rectZone.y + rectZone.height) + ")");
            }
           if (levelServer.curTrunksState) {
                trunkInfo += ", State : active"// + levelServer.curTrunksState.state;
            }
            if (trunkInfo != "trunk : ") {
                data.push(trunkInfo);
            }*/


            if (triggerHandler) {
                var zoneTrigger:CTriggerZone = triggerHandler.getZoneTrigger();
                if (zoneTrigger) {
                    var rectZone:Rectangle = levelCleveManager.curTrunkData.getTrunkRect();
                    data.push("刷怪区域 : LT:("+(int)(rectZone.x) + "," + (int)(rectZone.y) + "), RB:(" + (int)(rectZone.x+rectZone.width) + "," + (int)(rectZone.y + rectZone.height) + ")");
                } else {
                    data.push("刷怪区域 : 无");
                }

                // // 定时触发器
                var timerTrigger:CTriggerTimer = triggerHandler.getTriggerTimer();
                if (timerTrigger) {
                    data.push("定时触发器 : running..."+ "  limit : " + timerTrigger.limit);
                }
                // 怪物触发器
                var clearMonsterTrigger:CTriggerGlobalMonster = triggerHandler.getTriggerGlobalMonster();
                if (clearMonsterTrigger) {
                    data.push("怪物全局触发器 : running..." + "  limit : " + clearMonsterTrigger.limit);
                }

                // 随机触发器
                var randomTriggerCount:int = triggerHandler.getRandomTriggerCount();
                if (randomTriggerCount > 0) {
                    data.push("随机触发器 : running..." + "  count : " + randomTriggerCount);
                }

            }
        }
        // 传送门
        if (levelServer) {
            if (levelServer.curTrunksState && levelServer.curTrunksState.isPortal()) {
                var portalState:CLevelTrunkPortalState = levelServer.curTrunksState as CLevelTrunkPortalState;
                if (portalState.triggers) {
                    var portalTriggerCount:int = portalState.triggers.length;
                    if (portalTriggerCount > 0) {
                        data.push("传送门 : running..." + "  count : " + portalTriggerCount);
                    }
                }
            }
        }

        // player
        if (player && player.hero && player.hero.transform) {
            data.push("player 3D : x : " + int(player.hero.transform.x) + ", y : " + int(player.hero.transform.y) + ", z : " + int(player.hero.transform.z));
            var pos2D:CVector3 = CObject.get2DPositionFrom3D(player.hero.transform.x, player.hero.transform.y, player.hero.transform.z);
            data.push("player 2D : x : " + int(pos2D.x) + ", y : " + int(pos2D.y) + ", z : " + int(pos2D.z));
        }

        return  data;
    }
    private function _parseTrunkAreaData() : Object {
        var data:Object = new Object();
        var sceneSystem:CSceneSystem = _levelStage.getBean(CSceneSystem) as CSceneSystem;
        var serverSystem:CLevelServerSystem = _levelStage.getBean(CLevelServerSystem) as CLevelServerSystem;

        var levelServer:CLevelServer = serverSystem ? (serverSystem.getBean(CLevelServer) as CLevelServer) : null;
        var scene:CSceneRendering = sceneSystem ? sceneSystem.getBean(CSceneRendering) as CSceneRendering : null;
        var camera:CCamera = scene ? scene.mainCamera : null;
        var triggerHandler:CLevelServerTriggerHandler = levelServer ? levelServer.triggerHandler : null;

        var levelSystem:CLevelSystem = _levelStage.getSystem(CLevelSystem) as CLevelSystem;
        var levelCleveManager:CLevelManager = levelSystem ? levelSystem.getBean(CLevelManager) as CLevelManager : null;
        if (camera) {
            var camBox:CAABBox2 = camera.movableBox; // camera.curLockTrunkArea;
            if (camBox) {
                // var cameraPos:Point = new Point(camera);// (rect.min.x, rect.min.y); // camera.getCameraLTPos();
                var pos:Point = new Point(camBox.min.x-camera.min.x, camBox.min.y-camera.min.y);
                var lockData:Object = {x:pos.x, y:pos.y, width:camBox.getExtX2().x, height:camBox.getExtX2().y};
                // var lockData:Object = {x:camBox.min.x, y:camBox.min.y, width:camBox.getExtX2().x, height:camBox.getExtX2().y};
                data["lock"] = lockData;
            }
        }
        var rect:Rectangle;
        data["zone"] = new Array();
        var info:CTrunkConfigInfo = levelCleveManager.curTrunkData;
        if(info){
            var arr:Array = info.entities;
            for each(var entity:CTrunkEntityBaseData in arr){
                var zoneData:Object;
                if(entity.type == ETrunkEntityType.TRIGGER){
                    var rect:Rectangle = new Rectangle();
                    rect.width = entity.size.x;
                    rect.height = entity.size.y;
                    rect.x = entity.location.x-camera.min.x - rect.width/2;
                    rect.y = entity.location.y-camera.min.y-rect.height/2; // + yFixed;
                    zoneData = {x:rect.x, y:rect.y, width:rect.width, height:rect.height};
                    data["zone"].push(zoneData);
                }
            }
        }


//        if (triggerHandler) {
//            var zoneData:Object;
//            var zoneTrigger:CTriggerZone = levelServer.triggerHandler.getZoneTrigger();
//            if (zoneTrigger) {
//                rect = zoneTrigger.getLTZoneRect();
//                if (rect) {
//                    pos = new Point(rect.x-camera.min.x, rect.y-camera.min.y);
//                    zoneData = {x:pos.x, y:pos.y, width:rect.width, height:rect.height};
//                    data["zone"].push(zoneData);
//                }
//            }
//
//        }
        // 传送门
        if (levelServer && levelServer.curTrunksState && levelServer.curTrunksState.isPortal()) {
            var portalState:CLevelTrunkPortalState = levelServer.curTrunksState as CLevelTrunkPortalState;
            if (portalState.triggers && portalState.triggers.length > 0) {
                var portalTriggerList:Vector.<CTriggerPortal> = portalState.triggers;
                for each (var portalTrigger:CTriggerPortal in portalTriggerList) {
                    if (!portalTrigger) continue ;
                    rect = portalTrigger.getLTZoneRect();
                    if (rect) {
                        pos = new Point(rect.x-camera.min.x, rect.y-camera.min.y);
                        zoneData = {x:pos.x, y:pos.y, width:rect.width, height:rect.height};
                        data["zone"].push(zoneData);
                    }
                }
            }
        }
        return data;
    }

    private function _parseResultData() : Object {
        var data:Object = new Array();

        var serverSystem:CLevelServerSystem = _levelStage.getSystem(CLevelServerSystem) as CLevelServerSystem;
        var levelServer:CLevelServer = serverSystem ? (serverSystem.getBean(CLevelServer) as CLevelServer) : null;

        if (levelServer) {
            if (levelServer.curTrunksState && levelServer.curTrunksState.isCompleted()) {
//                data["result"] = "你过关了";
            }
        }
        return data;
    }
    private function _parseDebugLog() : String {
        if (CLevelLog.debugLog.length > 0) {
             return CLevelLog.flushDebugLog();
        }
        return null;
    }

    private function _isShowGo() : Boolean {
        var ret:Boolean = false;
        var serverSystem:CLevelServerSystem = _levelStage.getSystem(CLevelServerSystem) as CLevelServerSystem;
        var levelServer:CLevelServer = serverSystem ? (serverSystem.getBean(CLevelServer) as CLevelServer) : null;

        if (levelServer && levelServer.curTrunksState && levelServer.curTrunksState.isActived() && levelServer.curTrunksState.subStartTime > 1000) {
            ret = true;
        }
        return ret;
    }

    private function _onResize(e:Event) : void {
        this.setSize(stage.stageWidth, stage.stageHeight);
        _infoLayerRight.toRightBottom();

        _infoLayerLeft.toRightBottom();
        _infoLayerLeft.x -= _infoLayerRight.uiWidth;

        _infoLayerMid.toRightBottom();
        _infoLayerMid.x -= (_infoLayerLeft.uiWidth+_infoLayerRight.uiWidth);

        _result.toCenter();
        _goLayer.toCenter();
        _goLayer.toRight();

        _debugLayer.toLeft();
        _debugLayer.toBottom();
        _debugLayer.setSize(uiWidth, 200);

        _lastStageSize.x = uiWidth;
        _lastStageSize.y = uiHeight;
    }

    public function reverseShow() : void {
        this._infoVisible = !this._infoVisible;
        _infoLayerMid.visible = _infoLayerLeft.visible = _infoLayerRight.visible = _infoVisible;
        if (!_infoVisible) {
            _trunkLayer._bufVisible = _trunkLayer.visible;
            _debugLayer._bufVisible = _debugLayer.visible;
            _trunkLayer.visible = _infoVisible;
            _debugLayer.visible = _infoVisible;
        } else {
            _trunkLayer.visible = _trunkLayer._bufVisible;
            _debugLayer.visible = _debugLayer._bufVisible;
        }

    }
    public function reverseTrunkAreaShow() : void {
        _trunkLayer.visible = !_trunkLayer.visible;
    }
    public function reverseDebugShow() : void {
        _debugLayer.visible = !_debugLayer.visible;
    }
    private var _infoLayerRight:CInfoLayer;
    private var _infoLayerLeft:CInfoLayer;
    private var _infoLayerMid:CInfoLayer;

    private var _trunkLayer:CTrunkLayer;
    private var _goLayer:CGoLayer;
    private var _result:CResultLayer;

    private var _debugLayer:CDebugLayer;
    private static var _instance:CUILayer;
    private var _lastStageSize:Point;

    private var _levelStage:CGameStage;

    private var _infoVisible:Boolean;
}
}
