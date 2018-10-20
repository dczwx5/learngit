//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/03/06.
 */
package kof.game.cultivate.controller {

import flash.events.Event;

import kof.data.CPreloadData;
import kof.game.common.CLang;
import kof.game.common.preLoad.CPreload;
import kof.game.common.preLoad.EPreloadType;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.cultivate.CCultivateNetHandler;
import kof.game.cultivate.CCultivateSystem;
import kof.game.cultivate.CCultivateUIHandler;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.game.common.view.control.CControlBase;
import kof.game.cultivate.data.cultivate.CCultivateHeroData;
import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.cultivate.data.cultivate.CCultivateLevelDefenderData;
import kof.game.cultivate.enum.ECultivateWndType;
import kof.game.cultivate.view.cultivateNew.CCultivateViewNew;
import kof.game.cultivate.view.cultivateNew.CCultivateViewNew;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CHeroExtendsData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;

public class CCultivateControlerBase extends CControlBase {
    [Inline]
    public function get uiHandler() : CCultivateUIHandler {
        return _wnd.viewManagerHandler as CCultivateUIHandler;
    }
    [Inline]
    public function get system() : CCultivateSystem {
        return _system as CCultivateSystem;
    }
    [Inline]
    public function get netHandler() : CCultivateNetHandler {
        return system.netHandler;
    }
    [Inline]
    public function get climpData() : CClimpData {
        return system.climpData;
    }
    [Inline]
    public function get cultivateData() : CCultivateData {
        return climpData.cultivateData;
    }

    public function get playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }

    // =========================]
    public function _isLevelPass(culLevelData:CCultivateLevelData) : Boolean {
        return culLevelData && culLevelData.passed == 1;
    }
    // 是否当前可打的关卡
    public function _isCurrentFightLevel(culLevelData:CCultivateLevelData) : Boolean {
        return climpData.cultivateData.levelList.curOpenLevelIndex == culLevelData.layer;
    }

    // 判断格斗家是否足够出阵
    public function _isHeroFull() : Boolean {
        var embattleList:Array = playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE).list;
        var isFull:Boolean = embattleList.length >= system.fighterCountLess;
        var hasHeroDead:Boolean = false;
        for each (var embattleData:CEmbattleData in embattleList) {
            var heroData:CPlayerHeroData = playerData.heroList.getHero(embattleData.prosession);
            if (heroData && heroData.extendsData) {
                if ((heroData.extendsData as CHeroExtendsData).hp == 0) {
                    hasHeroDead = true;
                    break;
                }
            }
        }
        if (hasHeroDead) {
            isFull = false;
        }

        return isFull;
    }

    public function processFight() : Boolean {
        if (false == CGameStatus.checkStatus(system)) {
            return false;
        }

        var embattleList:Array = playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE).list;
        if (!embattleList || embattleList.length <= 0) {
            uiCanvas.showMsgAlert(CLang.Get("common_embattle_no_hero"));
            return false;
        }

        // 上阵人物限制
        var isFull:Boolean = _isHeroFull();
        if (!isFull) {
            uiCanvas.showMsgAlert(CLang.Get("common_need_x_hero", {v1:system.fighterCountLess}));
            return false;
        }

        var instanceSystem:IInstanceFacade = system.stage.getSystem(IInstanceFacade) as IInstanceFacade;
        instanceSystem.listenEvent(_onInstanceEvent);

        // 添加预加载内容
        var heroArr:Array = climpData.cultivateData.levelList.curLevelData.defenderList.list;
        var enemyIdList:Array = [];
        if(heroArr && heroArr.length) {
            for each(var defenderData:CCultivateLevelDefenderData in heroArr) {
                enemyIdList.push(defenderData.profession);
            }
        }

        var preloadDataList:Vector.<CPreloadData> = new Vector.<CPreloadData>();
        CPreload.AddPreloadListByIDList(preloadDataList, enemyIdList, EPreloadType.RES_TYPE_HERO);
        instanceSystem.addPreloadData(preloadDataList);

        netHandler.sendCultivateFight(climpData.cultivateData.levelList.curOpenLevelIndex, climpData.cultivateData.buffSelectIndex);

        return true;
    }
    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            var lastFightLevel:int = system.climpData.cultivateData.levelList.curOpenLevelIndex;
            _wnd.DelayCall(0.5, uiHandler.hideAllSystem);
            var instanceSystem:IInstanceFacade = system.stage.getSystem(IInstanceFacade) as IInstanceFacade;
            instanceSystem.unListenEvent(_onInstanceEvent);
            var func:Function = function () : void {
                var pView:CCultivateViewNew = uiHandler.getCreatedWindow(ECultivateWndType.Cultivate) as CCultivateViewNew;
                if (pView) {
                    var curFightLevel:int = system.climpData.cultivateData.levelList.curOpenLevelIndex;
                    if (curFightLevel > lastFightLevel) {
                        pView.showFadeInOut();
                    } else {
                        if (curFightLevel == lastFightLevel) {
                            if (system.climpData.cultivateData.levelList.curLevelData.passed > 0) {
                                pView.setAllPass(true);
                            }
                        }

                    }
                }
                system.setActived(true);
            };
            instanceSystem.addExitProcess(CCultivateViewNew, CInstanceExitProcess.FLAG_CULTIVATE, func, null, 9999);
        }
    }

    // =======布阵
    public function _setHeroListExtendsData() : void {
        // 更新heroListData
        // 这里更新了格斗家列表的数据，添加了extendsData
        var heroList:Array = playerData.heroList.list;
        var cultivateHeroData:CCultivateHeroData;
        var extendsData:CHeroExtendsData;
        for each (var heroData:CPlayerHeroData in heroList) {
            if (heroData.extendsData && heroData.extendsData is CHeroExtendsData) {
                extendsData = heroData.extendsData as CHeroExtendsData;
            } else {
                extendsData = new CHeroExtendsData();
            }
            // hp
            cultivateHeroData = climpData.cultivateData.heroList.getHero(heroData.prototypeID);
            if (cultivateHeroData) {
                extendsData.hp = cultivateHeroData.HP;
                extendsData.maxHP = cultivateHeroData.MaxHP;
            } else {
                extendsData.hp = heroData.propertyData.HP;
                extendsData.maxHP = heroData.propertyData.MaxHP;
            }
            heroData.extendsData = extendsData;
        }
    }

    // =======布阵
    // 打开布阵界面
    public function _processEmbattle(curCultivateData:CCultivateLevelData, isShowBuff:Boolean) : void {
        _setHeroListExtendsData();

        var enemyListData:Array = curCultivateData.getHeroListData();
        for (var i:int = 0; i < enemyListData.length; i++) {
            var defenderData:CCultivateLevelDefenderData =  curCultivateData.defenderList.list[i];
            var enemyData:CPlayerHeroData = enemyListData[i];
            if (enemyData) {
                if (defenderData && defenderData.maxHP != 0) {
                    enemyData.setHp(defenderData.HP);
                    enemyData.setMaxHp(defenderData.maxHP);
                } else {
                    // 满血的没数据
                    enemyData.setHp(1);
                    enemyData.setMaxHp(1);
                }
            }
        }

        uiHandler.showEmbattleView(function () : void {
            uiHandler.DelayCall(0.1, _processBuff, isShowBuff);
        });
    }
    // ======================buff
    // 打开buff界面 or 不打开
    public function _processBuff(isShowBuff:Boolean) : void {
        if (isShowBuff) {
            uiHandler.showCultivateStrategyView(null);
        }
    }
}
}
