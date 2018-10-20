//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/26.
 */
package kof.game.peak1v1.control {

import kof.data.CPreloadData;
import kof.game.common.loading.CLoadingEvent;
import kof.game.common.preLoad.CPreload;
import kof.game.common.preLoad.CPreloadEvent;
import kof.game.common.preLoad.EPreloadType;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.peak1v1.view.CPeak1v1View;
import kof.game.peak1v1.view.loading.CPeak1v1LoadingView;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;


public class CPeak1v1LoadingControl extends CPeak1v1Controler {
    public function CPeak1v1LoadingControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.FIRST_UPDATE_VIEW, _onFirstUpdateView);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.FIRST_UPDATE_VIEW, _onFirstUpdateView);
    }

    // 第一次updateView, 预加载 control 在界面关闭时会dispose掉, 所以这里必须用静态的
    private static function ClearPreload() : void {
        if (_preload) {
            _preload.dispose();
            _preload = null;
        }
    }
    private static var _preload:CPreload;
    private function _onFirstUpdateView(e:CViewEvent) : void {
        var pPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var myHeroList:Array = pPlayerData.embattleManager.getHeroListByType(EInstanceType.TYPE_PEAK_1V1);
        var myHeroData:CPlayerHeroData = myHeroList[0];
        var loadHeroList:Array = [myHeroData.prototypeID, system.data.matchData.enemyHeroData.prototypeID];

        if (_preload) {
            _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
            _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
            _preload.dispose();
            _preload = null;
        }
        _preload = new CPreload(system.stage);
        var preloadList:Vector.<CPreloadData> = new Vector.<CPreloadData>();
        CPreload.AddPreloadListByIDList(preloadList, loadHeroList, EPreloadType.RES_TYPE_HERO);
        _preload.addEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
        _preload.addEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
        _preload.load(preloadList);
    }
    private function _onUpdateProgress(e:CPreloadEvent) : void {
        data.myProgress = e.data as int;
        system.netHandler.sendSyncProcess(data.myProgress);
    }
    private function _onFinishProgress(e:CPreloadEvent) : void {
        _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
        _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);

        var isLoadFinished:Boolean = (_wnd as CPeak1v1LoadingView).isLoadFinish();
        if (isLoadFinished) {
            _onVirtualLoadFinish(null);
        } else {
            _wnd.addEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);
        }
    }
    private function _onVirtualLoadFinish(e:CLoadingEvent) : Boolean {
        _wnd.removeEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);
        var instanceID:int = data.matchData.instanceID;
        var pInstanceSystem:CInstanceSystem = _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.unListenEvent(_onInstanceEvent);
        pInstanceSystem.listenEvent(_onInstanceEvent);
        pInstanceSystem.enterInstance(instanceID);
        _wnd.close();
        return true;
    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            var pInstanceSystem:IInstanceFacade = system.stage.getSystem(IInstanceFacade) as IInstanceFacade;
            pInstanceSystem.unListenEvent(_onInstanceEvent);
            pInstanceSystem.addExitProcess(CPeak1v1View, CInstanceExitProcess.FLAG_PEAK, system.setActived, [true], 9999);
            _wnd.viewManagerHandler.hideAllSystem();

            pInstanceSystem.addExitProcess(null, null, function () : void {
                ClearPreload();
            }, null , 9999);
        }
    }
}
}
