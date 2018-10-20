//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/8/30.
 */
package kof.game.level.imp {
import QFLib.Interface.IDisposable;
import kof.data.CPreloadData;
import kof.game.common.CTest;
import kof.game.common.preLoad.CPreload;
import kof.game.common.preLoad.CPreloadEvent;
import kof.game.common.preLoad.EPreloadType;
import kof.game.embattle.CEmbattleSystem;
import kof.game.embattle.CEmbattleUtil;
import kof.game.embattle.CEmbattleUtil;
import kof.game.level.CLevelManager;

public class CLevelPreload implements IDisposable {
    public function CLevelPreload(levelManager:CLevelManager) {
        _levelManager = levelManager;
        _isFinish = false;
    }
    public function dispose() : void {
        clear();
        _levelManager = null;
        _isFinish = false;
    }

    public function clear() : void {
        _isFinish = false;
        if (_preload) {
            _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
            _preload.dispose();
            _preload = null;
        }

    }

    public function load(externPreloadListData:Vector.<CPreloadData>) : void {
        this.clear();

        CTest.log("关卡开始预加载2");

        var preloadList:Vector.<CPreloadData> = new Vector.<CPreloadData>();

        // 出战格斗家
        var pEmbattleSystem:CEmbattleSystem = _levelManager.system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        if (pEmbattleSystem) {
            var pEmbattleUtil:CEmbattleUtil = pEmbattleSystem.getBean(CEmbattleUtil) as CEmbattleUtil;
            if (pEmbattleUtil) {
                var pHeroIDList:Array = pEmbattleUtil.getHeroIDListInEmbattleByCurrentInstance();
                if (pHeroIDList && pHeroIDList.length) {
                    CPreload.AddPreloadListByIDList(preloadList, pHeroIDList, EPreloadType.RES_TYPE_HERO);
                }
            }
        }

        // 关卡怪物
        if (_levelManager && _levelManager.levelConfigInfo && _levelManager.levelConfigInfo.preLoad && _levelManager.levelConfigInfo.preLoad.length > 0) {
            var monsterIDList:Array = _levelManager.levelConfigInfo.preLoad;
            CPreload.AddPreloadListByIDList(preloadList, monsterIDList, EPreloadType.RES_TYPE_MONSTER);
        }

        // 外部添加的
        if (externPreloadListData && externPreloadListData.length > 0) {
            CPreload.AddPreloadList(preloadList, externPreloadListData);
        }
        if (preloadList.length > 0) {
            _preload = new CPreload(_levelManager.system.stage);
            _preload.addEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
            _preload.load(preloadList);

        } else {
            _preloadEnd();
        }
    }
    private function _onFinishProgress(e:CPreloadEvent) : void {
        _preloadEnd();
    }
    private function _preloadEnd() : void {
        _isFinish = true;
        CTest.log("关卡预加载结束");

    }

    public function isFinish() : Boolean {
        return _isFinish;
    }

    private var _preload:CPreload;

    private var _levelManager:CLevelManager;
    private var _isFinish:Boolean;
}
}