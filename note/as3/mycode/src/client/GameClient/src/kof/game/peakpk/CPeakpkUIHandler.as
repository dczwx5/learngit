//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk {

import flash.events.Event;

import kof.game.KOFSysTags;
import kof.game.common.loading.CLoadingEvent;
import kof.game.common.loading.CMatchLoadingView;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.im.CIMEvent;
import kof.game.im.CIMHandler;
import kof.game.im.CIMManager;
import kof.game.im.CIMSystem;
import kof.game.im.data.CIMFriendsData;
import kof.game.instance.CInstanceSystem;
import kof.game.peakpk.controll.CPeakpkMainControl;
import kof.game.peakpk.controll.CPeakpkMatchLoadingControl;
import kof.game.peakpk.controll.CPeakpkReceiveInviteControl;
import kof.game.peakpk.controll.CPeakpkSendInviteControl;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.peakpk.enum.EPeakpkWndType;
import kof.game.peakpk.enum.EPeakpkDataEventType;
import kof.game.peakpk.event.CPeakpkEvent;
import kof.game.peakpk.imp.CPeakpkResultDataProvider;
import kof.game.peakpk.view.CPeakpkPlayerTips;
import kof.game.peakpk.view.CPeakpkReceiveInviteView;
import kof.game.peakpk.view.CPeakpkSendInviteView;
import kof.game.peakpk.view.CPeakpkView;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;


public class CPeakpkUIHandler extends CViewManagerHandler {

    public function CPeakpkUIHandler() {
    }

    public override function dispose() : void {
        super.dispose();

        _system.removeEventListener(CPeakpkEvent.DATA_EVENT, _onPeakpkDataEvent);
    }

    override public virtual function onEvtEnable() : void {
        super.onEvtEnable();

        var imSystem:CIMSystem = system.stage.getSystem(CIMSystem) as CIMSystem;
        if (imSystem) {
            if (evtEnable) {
                imSystem.addEventListener( CIMEvent.FRIENDINFO_LIST_RESPONSE ,_onIMData );

            } else {
                imSystem.removeEventListener( CIMEvent.FRIENDINFO_LIST_RESPONSE ,_onIMData );

            }
        }
    }
    private function _onIMData(e:CIMEvent) : void {
        var friendList:Array = _getFriendData();
        var view:CViewBase = getWindow(EPeakpkWndType.WND_PEAK_PK_MAIN);
        if (view) {
            var pData:CPeakpkData = _data;
            pData.pFriendList = friendList;
            view.invalidate();
        }

    }
    private function _getFriendData() : Array {
        var imSystem:CIMSystem = system.stage.getSystem(CIMSystem) as CIMSystem;
        var newList:Array = new Array();
        if (imSystem) {
            var imManager:CIMManager = imSystem.getBean(CIMManager) as CIMManager;
            var pFriendList:Array = imManager.getFriendList();
            var pCIMFriendsData:CIMFriendsData;
            for each (pCIMFriendsData in pFriendList) {
                if (pCIMFriendsData.isOnline) {
                    newList[newList.length] = pCIMFriendsData;
                }
            }
            newList.sortOn(CIMFriendsData._fairPeakScore, Array.NUMERIC | Array.DESCENDING);
        }
        return newList;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.registTips(CPeakpkPlayerTips);

        this.addViewClassHandler(EPeakpkWndType.WND_PEAK_PK_MAIN, CPeakpkView, CPeakpkMainControl);
        this.addViewClassHandler(EPeakpkWndType.WND_SEND_INVITE, CPeakpkSendInviteView, CPeakpkSendInviteControl);
        this.addViewClassHandler(EPeakpkWndType.WND_RECEIVE_INVITE, CPeakpkReceiveInviteView, CPeakpkReceiveInviteControl);

        this.addViewClassHandler(EPeakpkWndType.WND_PEAK_LOADING, CMatchLoadingView, CPeakpkMatchLoadingControl);

        this.addBundleData(EPeakpkWndType.WND_PEAK_PK_MAIN, KOFSysTags.PEAK_PK);

        _system.addEventListener(CPeakpkEvent.DATA_EVENT, _onPeakpkDataEvent);
        return ret;
    }

    // ================================== event ==================================
    private function _onPeakpkDataEvent(e:CPeakpkEvent) : void {
        if (CPeakpkEvent.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;

        switch (subEvent) {
            case EPeakpkDataEventType.DATA :
                break;
            case EPeakpkDataEventType.PK_SUCCESS_DATA_P1 :
                showSendInvite();
                break;
            case EPeakpkDataEventType.PK_FAIL_DATA_P1 :
                CGameStatus.unSetStatus(CGameStatus.Status_PeakPKMatch);
                break;
            case EPeakpkDataEventType.PK_CONFIRM_DATA_P1 :
                hideSendInvite();
                // 有后续进副本动作
                break;
            case EPeakpkDataEventType.PK_REFUSE_DATA_P1 :
                CGameStatus.unSetStatus(CGameStatus.Status_PeakPKMatch);
                hideSendInvite();
                break;
            case EPeakpkDataEventType.PK_RECEIVE_INVITE_DATA_P2 :
                if (CGameStatus.checkStatus(system)) {
                    CGameStatus.setStatus( CGameStatus.Status_PeakPKMatch );
                    showReceiveInvite();
                } else {
                    _system.netHandler.sendRefuseInvite(_data.inviterData.id);
                }
                break;
            case EPeakpkDataEventType.PK_RECEIVE_INVITE_CANCEL_DATA_P2 :
                CGameStatus.unSetStatus(CGameStatus.Status_PeakPKMatch);
                hideReceiveInvite();
                break;
            case EPeakpkDataEventType.PK_MATCH_DATA :
                // 进入匹配
                showLoadingView();
                break;
            case EPeakpkDataEventType.PK_LOADING_DATA :
                // 对手进度
                break;
            case EPeakpkDataEventType.RESULT_DATA :
                win = getCreatedWindow(EPeakpkWndType.WND_PEAK_LOADING);
                if (win) {
                    (win as CMatchLoadingView).clearPreloadData();
                }
                break;
        }
    }


    ////////////////////////////////////////////////

    public function showPeakpkView() : void {
        if (_data.needSync) {
            var imsystem:CIMSystem = system.stage.getSystem(CIMSystem) as CIMSystem;
            if (imsystem) {
                _data.sync();
                imsystem.addEventListener(CIMEvent.FRIENDINFO_LIST_RESPONSE, _onFriendListDataHandlerB);
                (imsystem.getHandler(CIMHandler) as CIMHandler).onFriendInfoListRequest();
            }
        } else {
            _onFriendListDataHandlerB(null);
        }
    }
    private function _onFriendListDataHandlerB(e:Event) : void {
        var imsystem:CIMSystem = system.stage.getSystem(CIMSystem) as CIMSystem;
        if (imsystem) {
            imsystem.removeEventListener(CIMEvent.FRIENDINFO_LIST_RESPONSE, _onFriendListDataHandlerB);

            var playerData:CPlayerData = _playerData;
            var pData:CPeakpkData = _data;
            var friendList:Array = _getFriendData();
            pData.pFriendList = friendList;
            show(EPeakpkWndType.WND_PEAK_PK_MAIN, null, null, [pData, playerData]);
        }
    }

    public function hidePeakpkView() : void {
        hide(EPeakpkWndType.WND_PEAK_PK_MAIN);
    }
    public function showResult() : void {
        var pvpResultData:CPVPResultData = (system.getHandler(CPeakpkResultDataProvider) as CPeakpkResultDataProvider).getResultData();
        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem) {
            (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).data = pvpResultData;
            (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).addDisplay();
        }
    }

    public function showSendInvite() : void {
        var playerData:CPlayerData = _playerData;
        var pData:CPeakpkData = _data;

        show(EPeakpkWndType.WND_SEND_INVITE, null, null, [pData, playerData]);
    }
    public function hideSendInvite() : void {
        hide(EPeakpkWndType.WND_SEND_INVITE);
    }
    public function showReceiveInvite() : void {
        var playerData:CPlayerData = _playerData;
        var pData:CPeakpkData = _data;

        show(EPeakpkWndType.WND_RECEIVE_INVITE, null, null, [pData, playerData]);
    }
    public function hideReceiveInvite() : void {
        hide(EPeakpkWndType.WND_RECEIVE_INVITE);
    }

    // loading
    public function showLoadingView() : void {
        var playerData:CPlayerData = _playerData;
        var pData:CPeakpkData = _data;
        show(EPeakpkWndType.WND_PEAK_LOADING, null, function (view:CViewBase) : void {
            view.addEventListener(CLoadingEvent.LOADING_REQUIRE_TO_END, _onLoadingFinish); // loading结束
            view.addEventListener(CViewEvent.HIDE, _onLoadingHide); // 防止loading异常结束
        }, [pData.matchData, playerData, pData.loadingData]);
    }
    private function _onLoadingFinish(e:Event) : void {
        var view:CViewBase = e.currentTarget as CViewBase;
        view.removeEventListener(CLoadingEvent.LOADING_REQUIRE_TO_END, _onLoadingFinish);
        view.removeEventListener(CViewEvent.HIDE, _onLoadingHide);
    }
    private function _onLoadingHide(e:CViewEvent) : void {
        var view:CViewBase = e.currentTarget as CViewBase;
        view.removeEventListener(CLoadingEvent.LOADING_REQUIRE_TO_END, _onLoadingFinish);
        view.removeEventListener(CViewEvent.HIDE, _onLoadingHide);
    }
    public function hideLoadingView() : void {
        hide(EPeakpkWndType.WND_PEAK_LOADING);

    }
    // ================================== common data ==================================
    [Inline]
    private function get _system() : CPeakpkSystem {
        return system as CPeakpkSystem;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _data() : CPeakpkData {
        return _system.data;
    }
}
}
