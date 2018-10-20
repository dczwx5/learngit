//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/26.
 */
package kof.game.guildWar {

import kof.data.CPreloadData;
import kof.framework.CAbstractHandler;
import kof.game.common.loading.CLoadingEvent;
import kof.game.common.preLoad.CPreload;
import kof.game.common.preLoad.CPreloadEvent;
import kof.game.common.preLoad.EPreloadType;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.guildWar.view.CGuildWarLoadingViewHandler;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.peak1v1.view.CPeak1v1View;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;

public class CGuildWarLoadingHandler extends CAbstractHandler {
    public function CGuildWarLoadingHandler()
    {
        super();
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();

        _addListeners();

        return ret;
    }

    private function _addListeners():void
    {
        _loadingView.addEventListener(CGuildWarEvent.FIRST_UPDATE_VIEW, _onFirstUpdateView);
    }

    private function _removeListeners():void
    {
        _loadingView.removeEventListener(CGuildWarEvent.FIRST_UPDATE_VIEW, _onFirstUpdateView);
    }

    // 第一次updateView, 预加载
    private var _preload:CPreload;
    private function _onFirstUpdateView(e:CGuildWarEvent) : void {
        var pPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var myHeroList:Array = pPlayerData.embattleManager.getHeroListByType(EInstanceType.TYPE_GUILD_WAR);
        var myHeroData:CPlayerHeroData = myHeroList[0];
        var loadHeroList:Array = [myHeroData.prototypeID, _guildWarData.matchData.enemyHeroData.prototypeID];

        _preload = new CPreload(system.stage);
        var preloadList:Vector.<CPreloadData> = new Vector.<CPreloadData>();
        CPreload.AddPreloadListByIDList(preloadList, loadHeroList, EPreloadType.RES_TYPE_HERO);
        _preload.addEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
        _preload.addEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
        _preload.load(preloadList);
    }

    private function _onUpdateProgress(e:CPreloadEvent) : void {
        _guildWarData.myProgress = e.data as int;
        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarProgressSyncRequest(_guildWarData.myProgress);
    }

    private function _onFinishProgress(e:CPreloadEvent) : void {
        _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
        _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);

        var isLoadFinished:Boolean = _loadingView.isLoadFinish();
        if (isLoadFinished) {
            _onVirtualLoadFinish(null);
        } else {
            _loadingView.addEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);
        }
    }

    private function _onVirtualLoadFinish(e:CLoadingEvent) : Boolean {
        _loadingView.removeEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);
        var instanceID:int = _guildWarData.matchData.instanceID;
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.unListenEvent(_onInstanceEvent);
        pInstanceSystem.listenEvent(_onInstanceEvent);
        pInstanceSystem.enterInstance(instanceID);
//        _loadingView.removeDisplay();

        pInstanceSystem.addExitProcess(null, CInstanceExitProcess.FLAG_GUILD_WAR_DISPOSE, _disposePreload, null, 9999);
        return true;
    }

    private function _disposePreload():void
    {
        if(_preload)
        {
            _preload.dispose();
            _preload = null;
        }
    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            var pInstanceSystem:IInstanceFacade = system.stage.getSystem(IInstanceFacade) as IInstanceFacade;
            pInstanceSystem.unListenEvent(_onInstanceEvent);
            pInstanceSystem.addExitProcess(CPeak1v1View, CInstanceExitProcess.FLAG_PEAK, (system as CGuildWarSystem).setActived, [true], 9999);
//            _wnd.viewManagerHandler.hideAllSystem();
            _loadingView.removeDisplay();
        }
    }

    private function get _guildWarData():CGuildWarData
    {
        return (system as CGuildWarSystem).data;
    }

    private function get _loadingView():CGuildWarLoadingViewHandler
    {
        return system.getHandler(CGuildWarLoadingViewHandler) as CGuildWarLoadingViewHandler;
    }

    override public function dispose():void
    {
        super.dispose();

        _removeListeners();
    }
}
}
