//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title.view {

import QFLib.Foundation.CTime;

import kof.game.KOFSysTags;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerVisitData;
import kof.game.player.data.property.CPropertyHelp;
import kof.game.title.control.CTitleMainControler;
import kof.game.title.data.CTitleData;
import kof.game.title.data.CTitleItemData;
import kof.game.title.enum.ETitleViewEventType;
import kof.game.title.enum.ETitleWndResType;
import kof.game.title.titlePath.CTitlePath;
import kof.table.TitleTypeConfig;
import kof.ui.master.Title.TitleItemUI;
import kof.ui.master.Title.TitleMainUI;

import morn.core.components.Box;
import morn.core.components.List;
import morn.core.components.Tab;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CTitleView extends CRootView {

    public function CTitleView() {
        var childrenList:Array = null;
        var uiClazz:Class = TitleMainUI;
        super(uiClazz, childrenList, ETitleWndResType.MAIN, false);
    }

    protected override function _onCreate() : void {
        CSystemRuleUtil.setRuleTips(_ui.tips, CLang.Get("title_rule"));
        setTweenData(KOFSysTags.TITLE);

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
         _isFrist = true;
        listEnterFrameEvent = true;
    }
    protected override function _onShowing():void {
        // has data
        if (!_isTabInitial) {
            _tabTypeList = new Array();
            var tabNameString:String = new String();
            var typeList:Array = _titleData.typeTable.toArray();
            typeList.sortOn("type");
            for (var i:int = 0; i < typeList.length; i++) {
                var typeRecord:TitleTypeConfig = typeList[i];
                tabNameString += typeRecord.name;
                if (i != typeList.length - 1) {
                    tabNameString += ",";
                }
                _tabTypeList[_tabTypeList.length] = typeRecord.type;
            }
            tab.labels = tabNameString;
        }

        tab.selectHandler = new Handler(_onChangeTab);
        itemList.renderHandler = new Handler(_renderItem);

    }
    protected override function _onHide() : void {
        tab.selectHandler = null;
        itemList.renderHandler = null;
        listEnterFrameEvent = false;
        _curItemListByType = null;
    }
    protected override function _onEnterFrame(delta:Number) : void {
        if (!_curItemListByType) return ;
        var tabIndex:int = tab.selectedIndex;
        if (tabIndex == -1) {
            return ;
        }

        var iClientTime:Number = CTime.getCurrServerTimestamp();
        for each (var itemData:CTitleItemData in _curItemListByType) {
            if (itemData.isComplete) {
                var validDuringTime:Number = itemData.itemRecord.effectiveTime; // 有效持续时间
                var invalidTime:Number = itemData.invalidTick; // 过期时间, 一个时间点
                if (invalidTime > 0) {
                    validDuringTime = invalidTime - iClientTime;
                }
                if (validDuringTime != -1) {
                    var timeString:String = CTitleMainControler.ToTimeString(validDuringTime);
                    var item:TitleItemUI = getItemByData(itemData.configId);
                    if (item) {
                        item.during_time_txt.text = CLang.Get("common_vaild_time", {v1:timeString});
                    }
                }
            }
        }
    }
    private function getItemByData(configID:int) : TitleItemUI {
        var cells:Vector.<Box> = itemList.cells;
        for (var i:int = 0; i < cells.length; i++) {
            var item:TitleItemUI = cells[i] as TitleItemUI;
            if (item && item.dataSource) {
                var itemData:CTitleItemData = item.dataSource as CTitleItemData;
                if (itemData.configId == configID) {
                    return item;
                }
            }
        }
        return null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
            if (tab.selectedIndex == 0) {
                _onChangeTab(0);
            } else {
                tab.selectedIndex = 0;
            }
        } else {
            _onChangeTab(tab.selectedIndex);
        }

        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        if (isSelf) {
            // 头像等级
            _ui.face_img.url = CPlayerPath.getHeroBigconPath( _playerData.teamData.useHeadID );
            _ui.level_txt.text = _playerData.teamData.level.toString();
            // 战队名
            pPlayerSystem.platform.signatureRender.renderSignature(pPlayerSystem.playerData.vipData.vipLv, pPlayerSystem.platform.data, _ui.signature, pPlayerSystem.playerData.teamData.name);
            // 总战力
            _ui.battle_value_total_txt.text = _playerData.titlePropertyData.getBattleValue().toString();
        } else {
            _ui.face_img.url = CPlayerPath.getHeroBigconPath( _visitorData.useHeadID );
            _ui.level_txt.text = _visitorData.level.toString();
            // 战队名
            pPlayerSystem.platform.signatureRender.renderSignature(_visitorData.vipLv, _visitorData.platformData, _ui.signature, _visitorData.name);
            // 总战力
            var allItemList:Array = _titleData.itemListData.list;
            var battleValue:int = 0;
            for each (var pItemData:CTitleItemData in allItemList) {
                if (pItemData.isComplete) {
                    var propertyData:CBasePropertyData = CPropertyHelp.createPropertyData(system, pItemData.itemRecord.properties);
                    battleValue += propertyData.getBattleValue();
                }
            }
            _ui.battle_value_total_txt.text = battleValue.toString();
        }


        // 当前称号
        var pCurTitleData:CTitleItemData = _titleData.curTitleItem;
        if (pCurTitleData) {
            _ui.cur_title_img.url = CTitlePath.getTitleUrl(pCurTitleData.itemRecord.image);
            _ui.cur_title_none_txt.visible = false;

        } else {
            _ui.cur_title_img.url = null;
            _ui.cur_title_none_txt.visible = true;
        }

        this.addToDialog(KOFSysTags.TITLE);

        return true;
    }

    private function _onChangeTab(selectIndex:int) : void {
        var type:int = getTypeByIndex(selectIndex);
        var itemDataList:Array = _titleData.itemListData.getListByType(type);
        _curItemListByType = itemDataList;
        itemList.dataSource = itemDataList;
    }
    private function _renderItem(comp:Box, idx:int) : void {
        if (!comp) {
            return ;
        }
        if (!comp.dataSource) {
            comp.visible = false;
            return ;
        }
        var item:TitleItemUI = comp as TitleItemUI;
        comp.visible = true;

        var itemData:CTitleItemData = comp.dataSource as CTitleItemData;
        var isWore:Boolean = itemData.configId == _titleData.curTitleID;
        item.wearing_img.visible = isWore;
        item.get_btn.clickHandler = new Handler(_onGetClick, [item]);
        item.wear_btn.clickHandler = new Handler(_onWearClick, [item]);
        item.un_wear_btn.clickHandler = new Handler(_onUnWearClick, [item]);
        item.get_btn.visible = item.wear_btn.visible = item.un_wear_btn.visible = false;

        // 是否获得
        var isGot:Boolean = itemData.isComplete;
        item.mask_1.visible = item.mask2.visible = !isGot;
        var validDuringTime:Number = itemData.itemRecord.effectiveTime; // 有效持续时间 单位小时
        var invalidTime:Number = itemData.invalidTick; // 过期时间, 一个时间点
        var iClientTime:Number = CTime.getCurrServerTimestamp();
        if (invalidTime > 0) {
            validDuringTime = invalidTime - iClientTime; // 单位秒
        }
        var timeString:String;
        if (isGot) {
            if (isWore) {
                item.un_wear_btn.visible = true && isSelf;
            } else {
                item.wear_btn.visible = true && isSelf;
            }
            if (-1 != validDuringTime) {
                if (itemData.itemRecord.effectiveTimeDescGot && itemData.itemRecord.effectiveTimeDescGot.length > 0) {
                    // 使用默认的已获得的时间到期描述
                    item.during_time_txt.text = itemData.itemRecord.effectiveTimeDescGot;
                } else {
                    timeString = CTitleMainControler.ToTimeString(validDuringTime);
                    item.during_time_txt.text = CLang.Get("common_vaild_time", {v1:timeString});
                }
            }
        } else {
            item.get_btn.visible = true && isSelf;
            if (-1 != validDuringTime) {
                if (itemData.itemRecord.effectiveTimeDescUnGet && itemData.itemRecord.effectiveTimeDescUnGet.length > 0) {
                    // 使用默认的未获得的时间到期描述
                    item.during_time_txt.text = itemData.itemRecord.effectiveTimeDescUnGet;
                } else {
                    timeString = CTitleMainControler.ToTimeString( validDuringTime * 3600 * 1000 );
                    item.during_time_txt.text = CLang.Get( "common_vaild_time", {v1 : timeString} );
                }
            }
        }
        if (validDuringTime == -1) {
            item.during_time_txt.text = CLang.Get("common_all_time");
        }

        // 战力 和 属性
        var propertyData:CBasePropertyData = CPropertyHelp.createPropertyData(system, itemData.itemRecord.properties);
        var uiPairList:Array = [[item.property_1_title_txt, item.property_1_value_txt],
                                [item.property_2_title_txt, item.property_2_value_txt],
                                [item.property_3_title_txt, item.property_3_value_txt]];
        CPropertyHelp.showPropertyInUI(uiPairList, propertyData);
        // 总战力
        item.battle_value_num.num = propertyData.getBattleValue();

        // 穿戴效果
        item.wear_effect_txt.text = itemData.itemRecord.wearEffectDesc;
        // 获得方式
        item.get_way_txt.text = itemData.itemRecord.jumpToSysTagDesc;

        item.title_img.url = CTitlePath.getTitleUrl(itemData.itemRecord.image);
        ObjectUtils.gray(item.title_img, !isGot);

    }

    private function getTypeByIndex(tabIndex:int) : int {
        return _tabTypeList[tabIndex];
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ===================================ui================================
    public function get tab() : Tab {
        return _ui.tab;
    }
    public function get itemList() : List {
        return _ui.item_list;
    }
    // ====================================event=============================
    private function _onGetClick(item:TitleItemUI) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ETitleViewEventType.MAIN_GET_CLICK, item.dataSource as CTitleItemData));
    }
    private function _onWearClick(item:TitleItemUI) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ETitleViewEventType.MAIN_WEAR_CLICK, item.dataSource as CTitleItemData));
    }
    private function _onUnWearClick(item:TitleItemUI) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ETitleViewEventType.MAIN_UN_WEAR_CLICK, item.dataSource as CTitleItemData));
    }

    //===================================get/set======================================


    [Inline]
    private function get _ui() : TitleMainUI {
        return rootUI as TitleMainUI;
    }
    [Inline]
    private function get _titleData() : CTitleData {
        if (_data && _data.length > 0) {
            return super._data[0] as CTitleData;
        }
        return null;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        if (_data && _data.length > 1) {
            return super._data[1] as CPlayerData;
        }
        return null;
    }
    [Inline]
    private function get _visitorData() : CPlayerVisitData {
        if (_data && _data.length > 2) {
            return super._data[2] as CPlayerVisitData;
        }
        return null;
    }

    public function get isSelf() : Boolean {
        if (_visitorData) {
            return false;
        }
        return true;
    }

    private var _isFrist:Boolean = true;
    private var _isTabInitial:Boolean = false;
    private var _tabTypeList:Array;
    private var _curItemListByType:Array;

}
}
