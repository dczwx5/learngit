//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.control {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bootstrap.CNetDelayHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.player.data.CEmbattleListData;
import kof.game.practice.CPracticeSystem;

public class CPeakGameMainControl extends CPeakGameControler {
    public function CPeakGameMainControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        var embattleSystem:CEmbattleSystem;
        var pSystemBundleCtx : ISystemBundleContext;
        var pSystemBundle : ISystemBundle;
        switch (subType) {
            case EPeakGameViewEventType.MAIN_CLICK_FIGHT :
                if (false == CGameStatus.checkStatus(system)) {
                    break;
                }

                var fightFunc:Function = function () : void {
                    var emList:CEmbattleListData = system.embattleListData;
                    if (emList && emList.list.length == 3) {
                        if (peakGameData.isIdle) {
                            CGameStatus.setStatus(CGameStatus.Status_PeakGameMatch);
                            netHandler.sendMatch(system.playType);
                        } else {
                            if (peakGameData.isMatching) {
                                _wnd.uiCanvas.showMsgAlert(CLang.Get("peak_is_matching"));
                            } else {
                                _wnd.uiCanvas.showMsgAlert(CLang.Get("peak_is_match_sucess"));
                            }
                        }
                    } else {
                        _wnd.uiCanvas.showMsgAlert(CLang.Get("peak_need_3_hero"));
                    }
                };
                var delay:int = peakGameData.lastNetDelay;
                var isDelay:Boolean = delay > CNetDelayHandler.NET_DELAY_BAD;
                if (isDelay) {
//                    uiCanvas.showMsgBox(CLang.Get("common_net_delay_bad_matching_tips"), function () : void {
//                        fightFunc();
//                    }, function () : void {
//                        // todo : 下载微端
//                    }, true, CLang.Get("common_matching_continue"), CLang.Get("common_download_micro_pc"));
                    uiCanvas.showMsgBox(CLang.Get("common_net_delay_bad_matching_tips"), function () : void {
                        fightFunc();
                    }, null, false, CLang.Get("common_matching_continue"));
                } else {
                    fightFunc();
                }

                break;
            case EPeakGameViewEventType.MAIN_CLICK_LEVEL :
                uiHandler.showLevelView();
                break;
            case EPeakGameViewEventType.MAIN_CLICK_REWARD :
                uiHandler.showRewardView(0);
                break;
            case EPeakGameViewEventType.MAIN_CLICK_RANK :
                uiHandler.showRankView();
                break;
            case EPeakGameViewEventType.MAIN_CLICK_PRACTICE :
                (system.stage.getSystem(CPracticeSystem) as CPracticeSystem).enterPractice();
                break;
            case EPeakGameViewEventType.MAIN_CLICK_REPORT :
                uiHandler.showReportView();
                break;
            case EPeakGameViewEventType.MAIN_CLICK_SHOP :

                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.MALL, "shop_type", [system.shopType]);
                break;
            case EPeakGameViewEventType.MAIN_CLICK_EMBATTLE :
                pSystemBundleCtx = system.stage.getSystem( ISystemBundleContext ) as
                        ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    pSystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
                    pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args',[system.embattleType, 3, false, system.isShowQuality, system.isShowLevel]);
                    pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
                }
                break;
            case EPeakGameViewEventType.MAIN_CLICK_LEVEL_INFO :
                uiHandler.showLevelView();
                break;
            case EPeakGameViewEventType.MAIN_CLICK_PK :
                pSystemBundleCtx = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    pSystemBundle  = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.PEAK_PK ) );
                    pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
                }
                break;
            case EPeakGameViewEventType.MAIN_AUTO_SET_BEST_EMBATTLE :
                embattleSystem = _system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
                embattleSystem.requestBestEmbattle(system.embattleType);
                if (peakGameData.firstAutoEmbattle == false) {
                    netHandler.sendFirstAutoEMbattleRequest(system.playType);
                    peakGameData.firstAutoEmbattle = true;
                }
                break;
        }
    }

    private function _onHide(e:CViewEvent) : void {

    }
}
}
