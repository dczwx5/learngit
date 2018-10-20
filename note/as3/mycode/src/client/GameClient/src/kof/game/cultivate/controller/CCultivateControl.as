//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.cultivate.controller {

import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.character.property.CBasePropertyData;
import kof.game.character.property.CBasePropertyData;
import kof.game.cultivate.data.cultivate.CCultivateHeroData;
import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.cultivate.data.cultivate.CCultivateLevelDefenderData;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.common.CLang;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.event.CViewEvent;
import kof.game.cultivate.view.cultivateNew.CCultivateViewNew;
import kof.game.embattle.CEmbattleSystem;
import kof.game.impression.CImpressionManager;
import kof.game.impression.CImpressionSystem;
import kof.game.impression.util.CImpressionUtil;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.shop.enum.EShopType;

public class CCultivateControl extends CCultivateControlerBase {
    public function CCultivateControl() {
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

        _wnd.removeEventListener(CViewEvent.UPDATE_VIEW, _onUpdateView);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.UPDATE_VIEW, _onUpdateView);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var levelData:CCultivateLevelData;
        switch (subType) {
            case ECultivateViewEventType.MAIN_CLICK_REWARD_BOX :
                var levelIndex:int = e.data as int;
                levelData = climpData.cultivateData.levelList.getLevel(levelIndex);
                if (levelData.passed > 0) {
                    // pass
                    if (!climpData.cultivateData.otherData.isGetRewardBox(levelIndex)) {
                        netHandler.sendGetRewardBox(levelIndex);
                    }
                }
                break;
            case ECultivateViewEventType.MAIN_CLICK_CHANGE_BUFF_BTN :
                _processEmbattle((_wnd as CCultivateViewNew).getSelectLevelData(), true);
                break;
            case ECultivateViewEventType.MAIN_CLICK_SHOP :
                // uiCanvas.showMsgAlert(CLang.Get("common_not_open"));
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.MALL, "shop_type", [EShopType.SHOP_TYPE_5]);

                break;
            case ECultivateViewEventType.MAIN_CLICK_STRATEGY :
//                uiHandler.showCultivateStrategyView();
                uiCanvas.showMsgAlert(CLang.Get("common_sorry_not_open"));
                break;
            case ECultivateViewEventType.MAIN_CLICK_EMBATTLE :
                _processEmbattle((_wnd as CCultivateViewNew).getSelectLevelData(), false);
                break;
            case ECultivateViewEventType.MAIN_CLICK_RESET :
                // 是否有宝箱未领
                var hasRewardBoxCanGet:Boolean = false;
                for (var i:int = 0; i < 5; i++) {
                    var boxLevel:int = (i+1)*3; // 宝箱对应的关卡index
                    levelData = climpData.cultivateData.levelList.getLevel(boxLevel);
                    var isGetReward:Boolean = climpData.cultivateData.otherData.isGetRewardBox(boxLevel);
                    if (levelData.passed && isGetReward == false) {
                        hasRewardBoxCanGet = true;
                        break;
                    }
                }

                if (climpData.cultivateData.otherData.resetTimes > 0) {
                    if (hasRewardBoxCanGet) {
                        uiSystem.showMsgAlert(CLang.Get("cultivate_has_reward_box_can_get"));
                        return ;
                    }
                    netHandler.sendReset();
                } else {
                    uiCanvas.showMsgAlert(CLang.Get("common_none_reset_count"));
                }
                break;
            case ECultivateViewEventType.MAIN_SEND_EMBATTLE_FIRST :
                var embattleSystem:CEmbattleSystem = _system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
                embattleSystem.requestBestEmbattle(EInstanceType.TYPE_CLIMP_CULTIVATE);
                break;
            case ECultivateViewEventType.FIGHT_CLICK :
                var culLevelData:CCultivateLevelData = e.data as CCultivateLevelData;
                if (_isLevelPass(culLevelData)) {
                    uiCanvas.showMsgAlert(CLang.Get("common_has_pass_level"));
                    return ;
                }
                if (!_isCurrentFightLevel(culLevelData)) {
                    if (climpData.cultivateData.levelList.curOpenLevelIndex > culLevelData.layer) {
                        uiCanvas.showMsgAlert(CLang.Get("cultivate_hass_pass"));
                    } else if (climpData.cultivateData.levelList.curOpenLevelIndex < culLevelData.layer) {
                        uiCanvas.showMsgAlert(CLang.Get("cultivate_not_open"));
                    } else {
                        uiCanvas.showMsgAlert(CLang.Get("cultivate_data_error"));
                    }
                    return ;
                }

                // 关卡可以打
                var isHasBuff:Boolean = climpData.cultivateData.otherData.curBuffData.isDataValid();
                var isBuffActived:Boolean = climpData.cultivateData.otherData.currBuffEffect > 0;
                var embattleList:Array = playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE).list;
                var isFull:Boolean = embattleList.length >= system.fightCountMax;
                var tipsContent:String;
                if (!isHasBuff || !isBuffActived) {
                    tipsContent = "cultivate_ask_to_set_buff";
                    uiCanvas.showMsgBox(CLang.Get(tipsContent), function () : void {
                        // onOk
                        _processEmbattle((_wnd as CCultivateViewNew).getSelectLevelData(), true);
                    }, function () : void {
                       // onCancle
                        processFight();
                    }, true, CLang.Get("cultivate_goto_set_buff"), CLang.Get("cultivate_not_goto_set_buff"), false);
                } else if (!isFull) {
                    tipsContent = "cultivate_ask_to_set_hero_full";
                    uiCanvas.showMsgBox(CLang.Get(tipsContent), function () : void {
                        // onOk
                        _processEmbattle((_wnd as CCultivateViewNew).getSelectLevelData(), false);
                    }, function () : void {
                        // onCancle
                        processFight();
                    }, true, CLang.Get("cultivate_goto_set_buff"), CLang.Get("cultivate_not_goto_set_buff"));

                } else {
                    processFight();
                }

                break;
        }
    }

    // 爬塔数据更新时, 更新布阵界面
    private function _onUpdateView(e:CViewEvent) : void {
        // 更新heroListData
        // 这里更新了格斗家列表的数据，添加了extendsData
        var embattleList:CEmbattleListData = playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
        if (!embattleList) return ;

        var hasChangeEmbattle:Boolean = false;
        var isInEmbattle:Boolean;

        var heroList:Array = climpData.cultivateData.heroList.list;
        for each (var cultivateHeroData:CCultivateHeroData in heroList) {
            var pos:int = embattleList.getPosByHero(cultivateHeroData.profession);
            isInEmbattle = pos != -1;
            if (isInEmbattle && cultivateHeroData.HP == 0) {
                // 失败下阵
                isInEmbattle = false;
                embattleList.removeByPos(pos);
                hasChangeEmbattle = true;
            }
        }

        if (hasChangeEmbattle) {
            var pEmbattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
            if (pEmbattleSystem) {
                pEmbattleSystem.requestEmbattle(EInstanceType.TYPE_CLIMP_CULTIVATE);
            }
        }
    }

    private function _onHide(e:CViewEvent) : void {
        var heroList:Array = playerData.heroList.list;
        for each (var heroData:CPlayerHeroData in heroList) {
            heroData.extendsData = null;
        }
        _wnd.viewManagerHandler.hideAll();
    }

//  格斗家基础属性+斗魂属性*（1+格斗家资质加成）*（1+好感度加成）
    public function calcCultivateProperty(heroData:CPlayerHeroData) : CBasePropertyData {
        // 格斗家资质加成
        var baseQualityAdd:Number = 1.0;
        var str:String = heroData.playerBasic.InitPerProperty;
        var strArr:Array = str ? str.split(",") : null;
        if(strArr && strArr.length) {
            var subStr:String = strArr[0] as String;
            var subStrArr:Array = subStr ? subStr.split(":") : null;
            if(subStrArr && subStrArr.length) {
                baseQualityAdd = int(subStrArr[1]) / 10000;
            }
        }

        // 好感 度百分比属性总加成
        var imAttack:Number = 0;
        var imDefense:Number = 0;
        var imHp:Number = 0;
        var manager:CImpressionManager = system.stage.getSystem(CImpressionSystem).getBean(CImpressionManager);
        var attrData:CBasePropertyData = manager.getTotalCollectAttr();
        if(attrData) {
            var attrName : String;
            attrName = CImpressionUtil.Attrs[ 0 ];
            if ( attrData.hasOwnProperty( attrName ) ) {
                imHp = attrData[ attrName ] * 0.0001;
            }
            attrName = CImpressionUtil.Attrs[ 1 ];
            if ( attrData.hasOwnProperty( attrName ) ) {
                imAttack = attrData[ attrName ] * 0.0001;
            }
            attrName = CImpressionUtil.Attrs[ 2 ];
            if ( attrData.hasOwnProperty( attrName ) ) {
                imDefense = attrData[ attrName ] * 0.0001;
            }
        }

        var talentPropertyData:CBasePropertyData = playerData.talentPropertyData;
        var baseProperty:CBasePropertyData = CBasePropertyData.copyFromPlayerBasic(heroData.playerBasic);
        var kImValue:Number = 0;
        var value:Number;
        for each (var key:String in CBasePropertyData._calcBattleValueKeyList) {
            if (key == CBasePropertyData._Attack) {
                kImValue = imAttack;
            } else if (key == CBasePropertyData._Defense ) {
                kImValue = imDefense;
            } else if (key == CBasePropertyData._HP) {
                kImValue = imHp;
            } else {
                kImValue = 0;
            }
            value = baseProperty[key] + talentPropertyData[key] * (1 + baseQualityAdd) * (1 + kImValue);
            baseProperty[key] = value;
        }

        baseProperty.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        return baseProperty;
    }
}
}
