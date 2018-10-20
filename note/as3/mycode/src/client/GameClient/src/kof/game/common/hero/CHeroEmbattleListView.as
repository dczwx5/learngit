//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/1.
 */
package kof.game.common.hero {

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CHeroExtendsData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.InstanceType;
import kof.ui.imp_common.EmbattleSmallItemUI;

import morn.core.components.Component;

import morn.core.components.List;
import morn.core.handlers.Handler;

// 出阵格斗家头像列表
public class CHeroEmbattleListView {

    // embattleTYpe : CEmbattleConst
    private var _embattleType:int;
    private var _heroListView:List;
    private var _onAddHandler:Handler;
    private var _maxCount:int; // 最大出场
    private var _isHideByEmpty:Boolean;
    private var _isSelf:Boolean;

    private var _forceUseHeroList:Array;

    // heroList : if null use embattleData, else use heroListData, maxCount等都无效, embattleType也无效
    // new CHeroEmbattleListView(system, _ui.list, -1, new Handler(..) ,heroListData);
    // or
    // new CHeroEmbattleListView(system, _ui.list, instanceType, new Handler(..));
    public function CHeroEmbattleListView(system:CAppSystem, heroListView:List, embattleType:int,
                                          onAddHandle:Handler, heroList:Array = null, isHideByEmpty:Boolean = false,
                                          isShowHp:Boolean = false, needReverse:Boolean = true, isShowTips:Boolean = true, totalCount:int = 3, isSelf:Boolean = true) {
        _TOTAL_COUNT = totalCount;
        _forceUseHeroList = heroList;
        _isHideByEmpty = isHideByEmpty;
        _isShowHp = isShowHp;
        _isSelf = isSelf;

        _system = system;
        _embattleType = embattleType;
        _heroListView = heroListView;
        _heroListView.renderHandler = new Handler(_onRenderHeroItem);
        _onAddHandler = onAddHandle;

        _needReverse = needReverse;
        _isShowTips = isShowTips;

        if (!_forceUseHeroList) {
            var database:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
            var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(embattleType);
            _maxCount = _TOTAL_COUNT;
            if (instanceTypeRecord) {
                _maxCount = instanceTypeRecord.embattleNumLimit;
            }
        } else {
            _maxCount = _forceUseHeroList.length;
        }
    }

    public function updateData(embattleType:int, heroList:Array = null) : void {
        _embattleType = embattleType;
        _forceUseHeroList = heroList;

        if (!_forceUseHeroList) {
            var database:IDatabase = _system.stage.getSystem(IDatabase) as IDatabase;
            var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
            var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(embattleType);
            _maxCount = _TOTAL_COUNT;
            if (instanceTypeRecord) {
                _maxCount = instanceTypeRecord.embattleNumLimit;
            }
        } else {
            _maxCount = _forceUseHeroList.length;
        }
    }

    private var _TOTAL_COUNT:int = 3;
    // ===========update and render
    public function updateWindow() : Boolean {

        var heroListData:Array = new Array(_TOTAL_COUNT);

        var i:int = 0;
        if (_forceUseHeroList) {
            // 使用heroListData
            for (i = 0; i < _TOTAL_COUNT; i++) {
                if (i < _forceUseHeroList.length) {
                    heroListData[i] = _forceUseHeroList[i];
                } else {
                    heroListData[i] = null;
                }
            }
        } else {
            // 使用阵容数据
            var pPlayerData:CPlayerData = _playerData;
            var emListData:CEmbattleListData = pPlayerData.embattleManager.getByType(_embattleType);
            if (emListData) {
                for (i = 0; i < _TOTAL_COUNT; i++) {
                    var emData:CEmbattleData = emListData.getByPos(i+1);
                    if (emData) {
                        heroListData[i] = pPlayerData.heroList.getHero(emData.prosession);
                    } else {
                        heroListData[i] = null;
                    }
                }
            }
        }

        if (_maxCount < _TOTAL_COUNT && _needReverse) {
            heroListData = heroListData.reverse(); // 向右显示, 一般是支持显示一个和3个。显示两个看着会有问题
        }

        _heroListView.dataSource = heroListData;

        var isListHasData:Boolean = false;
        for each (var heroData:CPlayerHeroData in heroListData) {
            isListHasData = heroData != null || isListHasData;
        }

        if (_isHideByEmpty && !isListHasData) {
            _heroListView.visible = false;
        } else {
            _heroListView.visible = true;
        }

        return true;
    }

    private function _onRenderHeroItem(box:Component, idx:int) : void {
        var item:EmbattleSmallItemUI = box as EmbattleSmallItemUI; // Item组件没做通用的
        if (!item) return ;

        if (_maxCount < _TOTAL_COUNT && item.dataSource == null) {
            item.visible = false;
            return ;
        }
        RenderHeroItem(_system, _isShowHp, _onAddHandler, _isShowTips, false, _isSelf, item, idx);
    }
    public static function RenderHeroItem(system:CAppSystem, isShowHp:Boolean, onAddHandler:Handler,
                                          isShowTips:Boolean, needHideByNullData:Boolean, isSelf:Boolean, box:Component, idx:int) : void {
        var item:EmbattleSmallItemUI = box as EmbattleSmallItemUI; // Item组件没做通用的
        if (!item) return ;

        if (needHideByNullData && item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        item.item.icon_image.visible = false;
        item.btn_add.visible = false;

        item.hp.visible = false;
        var heroData:CPlayerHeroData = item.dataSource as CPlayerHeroData;
        if (!heroData) {
            if (onAddHandler) {
                item.btn_add.visible = true;
                item.btn_add.clickHandler = onAddHandler;
            }
            item.item.toolTip = null;
            item.item.quality_clip.index = 0;
            item.base_quality_clip.visible = false;

        } else {
            item.base_quality_clip.visible = true;
            item.base_quality_clip.index = heroData.qualityBaseType;
            item.item.icon_image.visible = true;
            item.item.quality_clip.index = 0; // eiko 说 品质都不需要显示 heroData.qualityLevelValue+1;
            item.item.icon_image.url = CPlayerPath.getHeroSmallIconPath(heroData.prototypeID);
            var playerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);

            if (isShowTips) {
                item.item.toolTip = new Handler(playerSystem.showHeroTips, [heroData, null, isSelf]);
            }

            if (isShowHp) {
                item.hp.visible = true;
                var hpMax:int = heroData.propertyData.MaxHP;
                hpMax = Math.max(hpMax, 1);
                var curHp:int = 1;
                if (heroData.extendsData) {
                    curHp = (heroData.extendsData as CHeroExtendsData).hp;
                    item.hp.value = curHp/hpMax;
                } else {
                    curHp = heroData.propertyData.HP;
                    item.hp.value = curHp/hpMax;
                }
            }
        }
    }

    private function get _playerData() : CPlayerData {
        return (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }

    private var _isShowHp:Boolean = false;
    private var _system:CAppSystem;

    private var _needReverse:Boolean;
    private var _isShowTips:Boolean;
}
}


