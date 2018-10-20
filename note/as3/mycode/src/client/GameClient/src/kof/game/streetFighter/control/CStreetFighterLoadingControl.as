//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/29.
 */
package kof.game.streetFighter.control {

import flash.events.Event;

import kof.data.CPreloadData;
import kof.game.KOFSysTags;
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
import kof.game.loading.CSceneLoadingViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.streetFighter.enum.EStreetFighterWndType;
import kof.game.streetFighter.view.loading.CStreetFighterLoadingView;
import kof.game.streetFighter.view.main.CStreetFighterView;
import kof.ui.CUISystem;

public class CStreetFighterLoadingControl extends CStreetFighterControler {
    public function CStreetFighterLoadingControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.FIRST_UPDATE_VIEW, _onFirstUpdateView);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.FIRST_UPDATE_VIEW, _onFirstUpdateView);
    }

    // 第一次updateView, 预加载
    private static function ClearPreload() : void {
        if (_preload) {
            _preload.dispose();
            _preload = null;
        }
    }
    private static var _preload:CPreload;
    private function _onFirstUpdateView(e:CViewEvent) : void {
        var pPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var myHeroData:CPlayerHeroData = pPlayerData.heroList.getHero(system.data.loadingData.fightHeroID);
        var loadHeroList:Array = [myHeroData.prototypeID, system.data.loadingData.enemyHeroData.prototypeID];

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
        streetFighterData.myProgress = e.data as int;
        system.netHandler.sendProgressSyncRequest(streetFighterData.myProgress);
    }
    private function _onFinishProgress(e:CPreloadEvent) : void {
        _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
        _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);

        var isLoadFinished:Boolean = (_wnd as CStreetFighterLoadingView).isLoadFinish();
        if (isLoadFinished) {
            _onVirtualLoadFinish(null);
        } else {
            _wnd.addEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);
        }
    }
    private function _onVirtualLoadFinish(e:CLoadingEvent) : Boolean {
        _wnd.removeEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);
        var instanceID:int = streetFighterData.loadingData.instanceID;
        var pInstanceSystem:CInstanceSystem = _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        pInstanceSystem.unListenEvent(_onInstanceEvent);
        pInstanceSystem.listenEvent(_onInstanceEvent);
        pInstanceSystem.setUnCloseSystemData(KOFSysTags.STREET_FIGHTER, EInstanceType.TYPE_STREET_FIGHTER);
        pInstanceSystem.enterInstance(instanceID);

        return true;
    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            var pInstanceSystem:IInstanceFacade = system.stage.getSystem(IInstanceFacade) as IInstanceFacade;
            pInstanceSystem.unListenEvent(_onInstanceEvent);
            pInstanceSystem.addExitProcess(CStreetFighterView, CInstanceExitProcess.FLAG_STREET_FIGHTER, system.setActived, [true], 9999);
            var sceneLoadingView:CSceneLoadingViewHandler = ((uiCanvas as CUISystem).getBean(CSceneLoadingViewHandler) as CSceneLoadingViewHandler);
            if (sceneLoadingView) {
                sceneLoadingView.removeEventListener( CSceneLoadingViewHandler.EVENT_END, _onRemoveLoading );
                sceneLoadingView.addEventListener(CSceneLoadingViewHandler.EVENT_END, _onRemoveLoading);
                sceneLoadingView.removeEventListener( CSceneLoadingViewHandler.EVENT_ADD, _onAddLoading );
                sceneLoadingView.addEventListener(CSceneLoadingViewHandler.EVENT_ADD, _onAddLoading);
            } else {
                _wnd.viewManagerHandler.hideAllSystem();
            }
            _wnd.viewManagerHandler.hideAll(EStreetFighterWndType.WND_LOADING);

            pInstanceSystem.addExitProcess(null, null, function () : void {
                ClearPreload();
            }, null , 9999);
        }
    }
    private function _onRemoveLoading(e:Event) : void {
        var sceneLoadingView:CSceneLoadingViewHandler = ((uiCanvas as CUISystem).getBean(CSceneLoadingViewHandler) as CSceneLoadingViewHandler);
        if (sceneLoadingView) {
            sceneLoadingView.removeEventListener( CSceneLoadingViewHandler.EVENT_END, _onRemoveLoading );
            sceneLoadingView.forceHide = false;
        }
        if (_wnd) {
            _wnd.viewManagerHandler.hideAllSystem();
        }
    }
    private function _onAddLoading(e:Event) : void {
        var sceneLoadingView:CSceneLoadingViewHandler = ((uiCanvas as CUISystem).getBean(CSceneLoadingViewHandler) as CSceneLoadingViewHandler);
        if (sceneLoadingView) {
            sceneLoadingView.removeEventListener( CSceneLoadingViewHandler.EVENT_ADD, _onAddLoading );
            sceneLoadingView.forceHide = true;
        }
    }

}
}
