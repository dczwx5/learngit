//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1.control {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.embattle.CEmbattleViewHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.peak1v1.data.CPeak1v1HeroStateData;
import kof.game.peak1v1.enum.EPeak1v1ViewEventType;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CHeroExtendsData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.InstanceType;


public class CPeak1v1MainControl extends CPeak1v1Controler {
    public function CPeak1v1MainControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
        _wnd.removeEventListener(CViewEvent.UPDATE_VIEW, _onUpdateView);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);
        _wnd.addEventListener(CViewEvent.UPDATE_VIEW, _onUpdateView);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        var embattleSystem:CEmbattleSystem;
        switch (subType) {
            case EPeak1v1ViewEventType.MAIN_RANK_CLICK :
                uiHandler.showRankView();
                break;
            case EPeak1v1ViewEventType.MAIN_REPORT_CLICK :
                uiHandler.showReportView();
                break;
//            case EPeak1v1ViewEventType.MAIN_AUTO_SET_BEST_EMBATTLE :
//                embattleSystem = _system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
//                embattleSystem.requestBestEmbattle(EInstanceType.TYPE_PEAK_1V1, true);
//                break;
            case EPeak1v1ViewEventType.MAIN_EMBATTLE_CLICK :
                _processEmbattle();
                break;
            case EPeak1v1ViewEventType.MAIN_REWARD_CLICK :
                uiHandler.showRewardView();
                break;
            case EPeak1v1ViewEventType.MAIN_REWARD_DESC_CLICK :
                uiHandler.showRewardDescView();
                break;
            case EPeak1v1ViewEventType.MAIN_REG_CLICK :
                if (data.fightCount >= data.fightCountMax) {
                    uiHandler.uiCanvas.showGamePromptMsgAlert(2703);
                } else {
                    if (data.regState == 0) {
                        if (CGameStatus.checkStatus(system)) {
                            netHandler.sendRegister();
                        }
                    }
                }

                break;
            case EPeak1v1ViewEventType.MAIN_UN_REG_CLICK :
                if (data.regState == 1) {
                    netHandler.sendCancelRegister();
                }
                break;
        }
    }

    // 打开布阵界面
    private function _processEmbattle() : void {
        _setHeroListExtendsData();

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var database:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
            var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(EInstanceType.TYPE_PEAK_1V1);
            var fighterCount:int = 3;
            if (instanceTypeRecord) {
                fighterCount = instanceTypeRecord.embattleNumLimit;
            }

            var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
            var pEmbattleView:CEmbattleViewHandler = embattleSystem.getBean(CEmbattleViewHandler) as CEmbattleViewHandler;
            pEmbattleView.removeEventListener(Event.CLOSE, _onEmbattleCloseB);
            pEmbattleView.addEventListener(Event.CLOSE, _onEmbattleCloseB);
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
            pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args',[EInstanceType.TYPE_PEAK_1V1, fighterCount, true, true, true]);
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
        }
    }
    // 布阵界面关闭, 移除事件监听, 清除血条状态
    private function _onEmbattleCloseB(e:Event) : void {
        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        var pEmbattleView:CEmbattleViewHandler = embattleSystem.getBean(CEmbattleViewHandler) as CEmbattleViewHandler;
        pEmbattleView.removeEventListener(Event.CLOSE, _onEmbattleCloseB);

        var heroList:Array = playerData.heroList.list;
        for each (var heroData:CPlayerHeroData in heroList) {
            heroData.extendsData = null;
        }

    }
    // 数据更新时, 更新布阵界面
    private function _onUpdateView(e:CViewEvent) : void {
        // 更新heroListData
        // 这里更新了格斗家列表的数据，添加了extendsData
        var embattleList:CEmbattleListData = playerData.embattleManager.getByType(EInstanceType.TYPE_PEAK_1V1);
        if (!embattleList) return ;

        var hasChangeEmbattle:Boolean = false;
        var isInEmbattle:Boolean;

        var heroList:Array = system.data.heroStateListData.list;
        for each (var peak1v1HeroData:CPeak1v1HeroStateData in heroList) {
            var pos:int = embattleList.getPosByHero(peak1v1HeroData.profession);
            isInEmbattle = pos != -1;
            if (isInEmbattle && peak1v1HeroData.HP == 0) {
                // 失败下阵
                isInEmbattle = false;
                embattleList.removeByPos(pos);
                hasChangeEmbattle = true;
            }
        }

        if (hasChangeEmbattle) {
            var pEmbattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
            if (pEmbattleSystem) {
                pEmbattleSystem.requestEmbattle(EInstanceType.TYPE_PEAK_1V1);
            }
        }
    }
    private function _setHeroListExtendsData() : void {
        // 更新heroListData
        // 这里更新了格斗家列表的数据，添加了extendsData
        var heroList:Array = playerData.heroList.list;
        var peak1v1HeroData:CPeak1v1HeroStateData;
        var extendsData:CHeroExtendsData;
        for each (var heroData:CPlayerHeroData in heroList) {
            if (heroData.extendsData && heroData.extendsData is CHeroExtendsData) {
                extendsData = heroData.extendsData as CHeroExtendsData;
            } else {
                extendsData = new CHeroExtendsData();
            }
            // hp
            peak1v1HeroData = system.data.heroStateListData.getHero(heroData.prototypeID);// climpData.cultivateData.heroList.getHero(heroData.prototypeID);
            if (peak1v1HeroData) {
                extendsData.hp = peak1v1HeroData.HP;
            } else {
                extendsData.hp = heroData.propertyData.HP;
            }
            heroData.extendsData = extendsData;
        }
    }
    private function _onHide(e:CViewEvent) : void {
        var heroList:Array = playerData.heroList.list;
        for each (var heroData:CPlayerHeroData in heroList) {
            heroData.extendsData = null;
        }
        _wnd.viewManagerHandler.hideAll();
    }
}
}
