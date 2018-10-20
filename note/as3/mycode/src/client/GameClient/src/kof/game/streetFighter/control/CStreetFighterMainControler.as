//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter.control {

import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.event.CViewEvent;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.table.StreetFighterReward;

public class CStreetFighterMainControler extends CStreetFighterControler {
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
        var win:CViewBase;
//        var pSystemBundleCtx : ISystemBundleContext;
//        var pSystemBundle : ISystemBundle;
        switch (subType) {
            case EStreetFighterViewEventType.MAIN_REFRESH_CLICK :
                if (streetFighterData.rankData.needSync) {
                    streetFighterData.rankData.sync();
                    netHandler.sendGetRank();
                }
                break;
            case EStreetFighterViewEventType.MAIN_EMBATTLE_CLICK :
                //
                if (streetFighterData.alreadyStartFight) {
                    _wnd.uiCanvas.showMsgAlert(CLang.Get("street_can_not_change_embattle"));
                } else {
                    uiHandler.openEmbattleView();
                }
                break;
            case EStreetFighterViewEventType.MAIN_AUTO_SET_BEST_EMBATTLE :
                this.bestEmbattleReqeust();
                break;
            case EStreetFighterViewEventType.MAIN_REPORT_CLICK :
                netHandler.sendGetReport();
                uiHandler.showReportView();
                break;
            case EStreetFighterViewEventType.MAIN_SHOP_CLICK :
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.MALL, "shop_type", [system.shopType]);
                break;
            case EStreetFighterViewEventType.MAIN_REWARD_CLICK :
                uiHandler.showRewardView();
                break;
            case EStreetFighterViewEventType.MAIN_RANK_CLICK :
                    uiHandler.showRankView();
                break;
            case EStreetFighterViewEventType.MAIN_MATCH :
                if (!streetFighterData.isActivityTime) {
                    _wnd.uiCanvas.showMsgAlert(CLang.Get("street_not_activity"));
                    return ;
                }

                var doMatchFunc:Function = function () : void {
                    if (streetFighterData.isIdle) {
                        streetFighterData.resetTempData();
                        CGameStatus.setStatus(CGameStatus.Status_StreetFighterMatch);
                        uiHandler.showMatch();
                        netHandler.sendMatchRequest();
                    }
                };
                if (CGameStatus.checkStatus(system)) {
                    if (streetFighterData.alreadyStartFight == false) {
                        if (_isFirstMatch) {
                            _isFirstMatch = false;
                            uiCanvas.showMsgBox(CLang.Get("street_first_match_tips"), function () : void {
                                // 更换阵容
                                if (streetFighterData.alreadyStartFight) {
                                    _wnd.uiCanvas.showMsgAlert(CLang.Get("street_can_not_change_embattle"));
                                } else {
                                    uiHandler.openEmbattleView();
                                }
                            }, function () : void {
                                // 开始匹配
                                doMatchFunc();
                            }, true, CLang.Get("street_goto_embattle"), CLang.Get("street_ok_to_match"), false);
                        } else {
                            doMatchFunc();
                        }

                    } else {
                        doMatchFunc();
                    }
                }

                break;
            case EStreetFighterViewEventType.MAIN_REFIGHT_CLICK :
                if (streetFighterData.alreadyStartFight) {
                    uiHandler.showRefightConfirm();
                }
                break;
            case EStreetFighterViewEventType.MAIN_TASK_REWARD_GET_CLICK :
                var record:StreetFighterReward = e.data as StreetFighterReward;
                if (canGetReward(record)) {
                    netHandler.sendGetRewardRequest(record.ID)
                }
                break;

        }
    }

    private function _onHide(e:CViewEvent) : void {

    }

    private static var _isFirstMatch:Boolean = true;
}
}
