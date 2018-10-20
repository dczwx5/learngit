//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/22.
 */
package kof.game.instance {

import QFLib.Audio.CAudioManager;
import QFLib.Audio.audio.CAudioMP3Source;
import QFLib.Framework.CFX;
import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;
import QFLib.ResourceLoader.ELoadingPriority;

import flash.events.Event;

import kof.data.CDatabaseSystem;

import kof.data.CPreloadData;

import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.audio.CAudioSystem;
import kof.game.common.CTest;
import kof.game.common.preLoad.CPreload;
import kof.game.common.preLoad.CPreloadResLoad;
import kof.game.common.preLoad.EPreloadType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.scene.CSceneSystem;
import kof.table.InstanceLoad;

public class CInstanceLoadResInPreludeHandler extends CAbstractHandler {
    public function CInstanceLoadResInPreludeHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();

        if (App.stage) {
            App.stage.addEventListener("event_prologue_onload", _onPrologueLoaded);
        }
        return true;
   }

    // =========================================initial=============================================================

    private function _onPrologueLoaded(e:Event) : void {
        App.stage.removeEventListener("event_prologue_onload", _onPrologueLoaded);

        // 添加加载序列
        var pSceneSystem:CSceneSystem = system.stage.getSystem(CSceneSystem) as CSceneSystem;
        if (!pSceneSystem) return ;
        _pGraphicsFramework = pSceneSystem.graphicsFramework;
        if (!_pGraphicsFramework) return ;

        _pResList = _buildResListB();
        if (!_pResList || _pResList.length == 0) return ;

        _loadingList = new Array();
        _saveList = new Array();

        _instanceSystem.addEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterSystem);

        if (_hasNext()) {
            _next();
        }
        if (_hasNext()) {
            _next();
        }
        if (_hasNext()) {
            _next();
        }
        if (_hasNext()) {
            _next();
        }
    }

    private function _buildResListB() : Array {
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        if (!pDatabase) return null;

        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.INSTANCE_LOAD);
        if (!pTable) return null;

        var pList:Array = pTable.toArray();
        if (!pList || pList.length == 0) return null;
        pList.sortOn("ID", Array.NUMERIC);

        var preloadList:Vector.<CPreloadData> = _build_1_1_characterListC();
        var newList:Array = _buildLoadListC(pList, preloadList);

        return newList;
    }
    private function _build_1_1_characterListC() : Vector.<CPreloadData> {
        // 加载1-1内容
        var preloadList:Vector.<CPreloadData> = new Vector.<CPreloadData>();
        CPreload.AddPreloadListByIDList(preloadList, [ 110101203, 110101105, 110101202, 110101104], EPreloadType.RES_TYPE_MONSTER);
        return preloadList;
    }
    private function _buildLoadListC(pList:Array, preloadList:Vector.<CPreloadData>) : Array {
        // 组合列表
        var list1:Array = new Array(); // 序章资源
        var list3:Array = new Array(); // 1-1技能资源
        var newList:Array = new Array();
        var loadData:LoadResData;
        var i:int;

        for (i = 0; i < pList.length; i++) {
            var pRecord : InstanceLoad = pList[ i ] as InstanceLoad;
            loadData = new LoadResData();
            loadData.loadRecord = pRecord;
            if ( pRecord.BelongLevel == 0 ) {
                list1[ list1.length ] = loadData;
            } else if ( pRecord.BelongLevel == 1 ) {
                list3[ list3.length ] = loadData;
            }
        }
        newList = newList.concat(list1);
        for (i = 0; i < preloadList.length; i++) {
            loadData = new LoadResData();
            var preloadData:CPreloadData = preloadList[i];
            var preloadRecord:InstanceLoad = new InstanceLoad({ResType:8, BelongLevel:1}); // 模拟数据
            loadData.loadRecord = preloadRecord;
            loadData.preloadData = preloadData;
            newList[newList.length] = loadData;
        }
        newList = newList.concat(list3);

        return newList;
    }

    // ======================================================================================================

    private function _onEnterSystem(e:CInstanceEvent) : void {
        var instanceContentID:int = e.data as int;
        if (10001 == instanceContentID) {
            CTest.log("______________________________进入1-1, 清除序章加载列表 ");
            // 1-1 : 移除未加载的序章资源
            for (var i:int = 0; i < _pResList.length; i++) {
                var loadData:LoadResData = _pResList[i] as LoadResData;
                var pRecord:InstanceLoad = loadData.loadRecord;
                if (pRecord.BelongLevel == 0) {
                    // 序章资源
                    _pResList.splice(i, 1);
                    i--;
                    CTest.log("______________________________清除 : " + pRecord.ID);
                }
            }

            CTest.log("______________________________清除 savelist by prelude : ");
            _removeSaveList(true);
            CTest.log("______________________________打印 reslist");
            CTest.traceObject(_pResList, true);
            CTest.log("______________________________打印 savelist");
            CTest.traceObject(_saveList, true);

        } else if (1000 == instanceContentID) {
            // 主城 移除所有并结束
            _isEnd = true;
            // 如果还有正在加载的资源, 就等资源加载回来再清除
            if (_loadingList.length == 0) {
                _doFinal();
            } else {
                // 等待load回来
                _doFinalByIntoMainCity();
            }
        } else {
            // 错误
            _isEnd = true;
            if (_loadingList.length == 0) {
                _doFinal();
            } else {
                _doFinalByIntoMainCity();
            }
        }
    }

    private function _hasNext() : Boolean {
        return _pResList.length > 0;
    }
    private function _next() : void {
        if (_pResList.length > 0) {
            var loadData:LoadResData = _pResList.shift() as LoadResData;
            _addToQueue(loadData)
        }
    }
    private function _doFinal() : void {
        _pResList = null;
        _instanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterSystem);

        _removeSaveList(false);
        _saveList = null;
        _pGraphicsFramework = null;
        _loadingList = null;

        CTest.log("______________________________加载 结束");
    }

    // 预防加载卡住 .然后没有清理资源
    private function _doFinalByIntoMainCity() : void {
        _pResList.length = 0;
        _instanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterSystem);
        _removeSaveList(false);

        CTest.log("______________________________进入副本, 清理已经保存的savelist");
    }
    // ======================================================================================================

    private function _addToQueue(loadData:LoadResData) : void {
//        0  技能特效
//        1  打击特效
//        2  打击组合特效（组合元素特效）
//        3  大招特效
//        4  非技能动作特效
//        6  技能动作音效
//        7  打击音效
        var record:InstanceLoad = loadData.loadRecord;
        switch (record.ResType) {
            case 0 :
            case 1 :
            case 2 :
            case 3 :
            case 4 :
                _loadFx(loadData);
                break;
            case 6 :
            case 7 :
                _loadAudio(loadData);
                break;
            case 8 :
                _loadCharacter(loadData);
                break;
        }
    }

    // ==============================================FX========================================================
    private function _loadFx(loadData:LoadResData) : void {
        var url:String = "assets/" + loadData.loadRecord.Path + "/" + loadData.loadRecord.URL + ".json";

        var _onLoadedFX:Function  = function (pFx:CFX, iResult:int) : void {
            CTest.log("______________________________加载 特效 完成" + url);

            loadData.pFx = pFx;
            _saveList.push(loadData);
            if (pFx) {
                pFx.pause();
                pFx.visible = false;
            }

            _loadedB(loadData);
        };

        var fx:CFX = new CFX(_pGraphicsFramework);
        _loadingList.push(loadData);
        CTest.log("______________________________加载 特效 " + url);
        fx.loadFile(url, ELoadingPriority.NORMAL, _onLoadedFX);

    }

    // ==============================================Audio========================================================

    private function _loadAudio(loadData:LoadResData) : void {
        var url:String = "assets/" + loadData.loadRecord.Path + "/" + loadData.loadRecord.URL + ".mp3";
        _loadingList.push(loadData);
        CTest.log("______________________________加载 音效 " + url);

        var _onLoadedAudio:Function = function (idErrorCode:int, pMp3:CAudioMP3Source) : void {
            // 原本audioManager就不释放资源。先不管
            CTest.log("______________________________加载 音效 完成" + url);

            _loadedB(loadData);
        };

        var hasCache:Boolean = (_audioSystem.audioManager as CAudioManager).hasAudioCache(url);
        if (hasCache) {
            _onLoadedAudio(1, null);
        } else {
            (_audioSystem.audioManager as CAudioManager).loadAudio(url, _onLoadedAudio);
        }
    }

    // ==============================================Character========================================================

    private function _loadCharacter(loadData:LoadResData) : void {
        var _onLoadCharacterFinished:Function = function (preloadData:CPreloadData, model:Object, missileList:Array) : void {
            _saveList.push(loadData);
            loadData.modle = model;
            loadData.missileList = missileList;
            CTest.log("______________________________加载 人物 完成" +  loadData.preloadData.id);

            _loadedB(loadData);
        };

        // 1-1人物预加载
        var frameWork:CFramework = _pGraphicsFramework;
        var database:IDatabase = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem);
        _loadingList.push(loadData);
        CTest.log("______________________________加载 人物 " + loadData.preloadData.id);
        CPreloadResLoad.load(loadData.preloadData, frameWork, database, _onLoadCharacterFinished);
    }

    private function _loadedB(loadData:LoadResData) : void {
        var index:int = _loadingList.indexOf(loadData);
        if (index != -1) {
            _loadingList.splice(loadData);
        }

        if (_isEnd) {
            if (_loadingList.length == 0) {
                // 已经回主城了, 但是最后的资源还没加载完, 等资源加载完再清除
                _doFinal();
            } else {
                _doFinalByIntoMainCity();
            }
        } else {
            if (_hasNext()) {
                _next();
            }
        }
    }
    // ==============================================saveList========================================================
    private function _removeSaveList(removePreludeResOnly:Boolean) : void {
        if (!_saveList) return ;

        for (var i:int = 0; i < _saveList.length; i++) {
            var loadData:LoadResData = _saveList[i] as LoadResData;
            var pRecord:InstanceLoad = loadData.loadRecord;

            var isNeedRemove:Boolean = !removePreludeResOnly || (removePreludeResOnly && pRecord.BelongLevel == 0);
            if (isNeedRemove) {
                if (loadData.loadRecord.ResType == 8) {
                    // character
                    if (loadData.modle) {
                        (loadData.modle as IDisposable).dispose();
                    }
                    if (loadData.missileList) {
                        for each (var obj:IDisposable in loadData.missileList) {
                            if (obj) {
                                obj.dispose();
                            }
                        }
                    }
                } else {
                    var pObject:Object = loadData.pFx;
                    if (pObject && pObject is CFX) {
                        var pFx:CFX = pObject as CFX;
                        pFx.stop();
                        CFX.manuallyRecycle(pFx);
                    } else {
                        // 音效
                    }
                }

                _saveList.splice(i, 1);
                i--;
            }
        }
    }

    // ======================================================================================================

    private function get _instanceSystem() : CInstanceSystem {
        return system as CInstanceSystem;
    }
    private function get _audioSystem() : CAudioSystem {
        return system.stage.getSystem(CAudioSystem) as CAudioSystem;
    }

    private var _pResList:Array;
    private var _pGraphicsFramework:CFramework;
    private var _loadingList:Array;
    private var _isEnd:Boolean;
    private var _saveList:Array;
}
}

import QFLib.Framework.CFX;

import kof.data.CPreloadData;
import kof.table.InstanceLoad;

class LoadResData {
    public var loadRecord:InstanceLoad;
    public var preloadData:CPreloadData;
    public var pFx:CFX;
    public var modle:Object;
    public var missileList:Array;
}
