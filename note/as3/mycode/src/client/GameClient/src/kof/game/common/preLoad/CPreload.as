//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/18.
 */
package kof.game.common.preLoad {

import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;
import flash.events.EventDispatcher;
import kof.data.CDatabaseSystem;
import kof.data.CPreloadData;
import kof.framework.CAppStage;
import kof.framework.IDatabase;
import kof.game.common.CTest;
import kof.game.scene.CSceneSystem;

public class CPreload extends EventDispatcher implements IDisposable {
    public function CPreload(stage:CAppStage) {
        _stage = stage;
        _reloadResourceList = new Array();
        _isFinish = false;
        _finishCount = 0;
    }

    private var _isDispose:Boolean = false;
    public function dispose() : void {
        if (!_isDispose) {
            _isDispose = true;
        }

        clear();
        _reloadResourceList = null;
        _reloadDataList = null;
        _isFinish = false;
    }

    public function clear() : void {
        for each (var obj:IDisposable in _reloadResourceList) {
            if (obj) {
                obj.dispose();
            }
        }
        _reloadResourceList = new Array();
        _isFinish = false;

//        trace("预加载-------------------------------- 释放资源");
    }

    public function stop() : void {

    }

    public function load(reloadDataList:Vector.<CPreloadData>) : void {
        this.clear();
        _reloadDataList = reloadDataList;

//        var temp:Vector.<CPreloadData> = new Vector.<CPreloadData>(); // 110201103 用于测试某个预加载
//        for each (var preloadData:CPreloadData in _reloadDataList) {
//            if ("110201103" == preloadData.id) {
//                temp.push(preloadData);
//            }
//        }
//        _reloadDataList = temp;

        if (_reloadDataList && _reloadDataList.length > 0) {
            var frameWork:CFramework = (_stage.getSystem(CSceneSystem) as CSceneSystem).graphicsFramework;
            var database:IDatabase = (_stage.getSystem(CDatabaseSystem) as CDatabaseSystem);
            for each (var preloadData:CPreloadData in _reloadDataList) {
                CTest.log("预加载-------------------------------- : ID " + preloadData.id + " : resType  " + preloadData.resType);
                CPreloadResLoad.load(preloadData, frameWork, database, _loadResourceFinishB);
            }
        } else {
            _preloadEnd();
        }
    }
    private function _loadResourceFinishB(preloadData:CPreloadData, model:Object, missileList:Array) : void {
        if (_isDispose) {
            // 异常, 非正常流程, 在中途中止了
            (model as IDisposable).dispose();
            CTest.log("异常, 非正常流程, 在中途中止了");
            return ;
        }

        _finishCount++;
//        var key:String = preloadData.resType + preloadData.id;
        _reloadResourceList[_reloadResourceList.length] = model;

        if (missileList && missileList.length > 0) {
            for each (var missileModel:CCharacter in missileList) {
                _reloadResourceList[_reloadResourceList.length] = missileModel;
            }
        }

        preloadData.isFinish = true;
        var totalCount:int = _reloadDataList.length;
        if (totalCount == 0) totalCount = 1;
        var progress:int = 10000*(_finishCount/totalCount);
        this.dispatchEvent(new CPreloadEvent(CPreloadEvent.LOADING_PROCESS_UPDATE, progress));
        _checkFinishC();
    }
    private function _checkFinishC() : void {
       if (_finishCount >= _reloadDataList.length) {
            _preloadEnd();
        }
    }

    private function _preloadEnd() : void {
        if (_isFinish) return ;

        _isFinish = true;
        this.dispatchEvent(new CPreloadEvent(CPreloadEvent.LOADING_PROCESS_FINISH));

        // _reloadResourceList里的东西不能clear, 不然预加载就没用了

    }

    // resType : EPreloadType
    public static function AddPreloadList(saveList:Vector.<CPreloadData>, preloadListData:Vector.<CPreloadData>) : void {
        var preloadData:CPreloadData;
        for each (preloadData in preloadListData) {
            if (false == IsExist(saveList, preloadData)) {
                saveList[saveList.length] = preloadData;
            }
        }
    }

    // resType : EPreloadType
    public static function AddPreloadListByIDList(saveList:Vector.<CPreloadData>, objectIDList:Array, resType:String) : void {
        var preloadData:CPreloadData;
        for each (var objID:* in objectIDList) {
            if (objID > 0) {
                preloadData = new CPreloadData();
                preloadData.resType = resType;
                preloadData.id = objID.toString();
                if (false == IsExist(saveList, preloadData)) {
                    saveList[saveList.length] = preloadData;
                }
            }
        }
    }
    private static function IsExist(list:Vector.<CPreloadData>, preloadData:CPreloadData) : Boolean {
        for each (var listItem:CPreloadData in list) {
            if (listItem.resType == preloadData.resType && preloadData.id == listItem.id) {
                return true;
            }
        }
        return false;
    }

    private var _stage:CAppStage;
    private var _reloadResourceList:Array;
    private var _reloadDataList:Vector.<CPreloadData>; // [CReloadData, CReloadData, CReloadData....]

    private var _finishCount:int;
    private var _isFinish:Boolean;
}
}
