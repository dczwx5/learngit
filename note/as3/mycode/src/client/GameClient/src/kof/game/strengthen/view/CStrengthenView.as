//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.view {


import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerData;
import kof.game.strengthen.control.CStrengthenControler;
import kof.game.strengthen.data.CStrengthenData;
import kof.game.strengthen.enum.EStrengthenViewEventType;
import kof.game.strengthen.enum.EStrengthenWndResType;
import kof.table.StrengthItem;
import kof.table.StrengthLevelBattleValue;
import kof.table.StrengthTargetBattleValue;
import kof.ui.master.strengthen.StrengthenMainViewItemUI;
import kof.ui.master.strengthen.StrengthenMainViewUI;
import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CStrengthenView extends CRootView {

    public function CStrengthenView() {
        var childrenList:Array = null;
        var uiClazz:Class = StrengthenMainViewUI;
        super(uiClazz, childrenList, EStrengthenWndResType.MAIN, false);
    }

    protected override function _onCreate() : void {
        CSystemRuleUtil.setRuleTips(_ui.tips, CLang.Get("strengthen_rule"));
        setTweenData(KOFSysTags.STRENGTHEN);
    }
    protected override function _onDispose() : void {

    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }
    protected override function _onShow():void {
         _isFrist = true;

        _ui.item_list.renderHandler = new Handler(_onRenderItem);

    }
    protected override function _onShowing():void {
        // has data

    }
    protected override function _onHide() : void {
        _ui.item_list.scrollTo(0);
        _ui.item_list.renderHandler = null;

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (!_tabList) {
            _tabList = new CStrengthenTabList(this);
            _tabList.renderHandler = new Handler(_renderPage);
            _tabList.activeFirstTab();
        } else {
            if (_isFrist) {
                _isFrist = false;
                _tabList.resetState();
                _tabList.activeFirstTab();
            } else {
                _renderPage(_ui.item_list.dataSource as Array);
            }
        }


        // 战力
        _ui.my_battle_value_txt.num = _playerData.teamData.battleValue; // 我的战力
        var levelBattleValueRecord:StrengthLevelBattleValue = _strengthenData.getLevelBattleValueRecord(_playerData.teamData.level);
//        _ui.target_battle_value_title_txt.text = CLang.Get("strengthen_target_battle_value_title", {v1:levelBattleValueRecord.ID}); // X级战力推荐
//        _ui.target_battle_value_txt.text = levelBattleValueRecord.battleValue.toString(); // 目标战力

        var curValue:int = _playerData.teamData.battleValue;
        var targetValue:int = levelBattleValueRecord.battleValue;
        targetValue = targetValue > 0 ? targetValue : 1;
        var battleValueRata:Number = curValue / targetValue * 10000;
        var clipIndex:int = _strengthenData.getIndexByBattleValuePercent(battleValueRata);;
        _ui.battle_value_level_clip.index = clipIndex; // CBAS

        this.addToDialog(KOFSysTags.STRENGTHEN);
        return true;
    }
    private function _renderPage(itemList:Array) : void {
        _ui.item_list.dataSource = itemList;
    }
    private function _onRenderItem(comp:Component, idx:int) : void {
        if (!comp) {
            return ;
        }
        if (!comp.dataSource) {
            comp.visible = false;
            return ;
        }
        var item:StrengthenMainViewItemUI = comp as StrengthenMainViewItemUI;
        comp.visible = true;

        var itemRecord:StrengthItem = comp.dataSource as StrengthItem;

        item.grew_up_btn.clickHandler = new Handler(_onClickGrewUp, [item]);
        item.goto_btn.clickHandler = new Handler(_onClickGoto, [item]);
        item.name_txt.text = itemRecord.itemName;
        item.icon_img.url = itemRecord.icon;

        if (itemRecord.battleValueGrewType > 0) {
            // 提升战力
//            item.progress_txt.visible = true;
//            item.bar.visible = true;
            item.score_clip.visible = true;
//            item.desc_txt.visible = false;
            item.recommend.visible = false;
//            item.progress_txt.visible = false;
//            item.bar.visible = false;
            item.desc_txt.visible = true;

            var pController:CStrengthenControler = this.controlList[0] as CStrengthenControler;
            var curValue:int = pController.getBattleValueByType(itemRecord.battleValueGrewType);
            var targetRecord:StrengthTargetBattleValue = _strengthenData.getItemTargetBattleValueRecord(itemRecord.battleValueGrewType, _playerData.teamData.level);
            var targetValue:int = targetRecord.target;
            if (targetValue <= 0) {
                targetValue = 1;
            }
//            item.progress_txt.text = curValue + "/" + targetValue;
//            item.bar.value = curValue/targetValue;
            item.grew_up_btn.visible = curValue < targetValue;
            item.goto_btn.visible = !item.grew_up_btn.visible;
            item.score_clip.index = _strengthenData.getItemLevel(curValue/targetValue*10000);
            item.desc_txt.text = itemRecord.desc;

        } else {
//            item.progress_txt.visible = false;
//            item.bar.visible = false;
            item.score_clip.visible = false;
            item.desc_txt.visible = true;

            item.desc_txt.text = itemRecord.desc;
            item.recommend.visible = itemRecord.recommend > 0;
            item.grew_up_btn.visible = false;
            item.goto_btn.visible = true;
        }
    }

    // ===================================ui================================

    // ====================================event=============================
    private function _onClickGrewUp(item:StrengthenMainViewItemUI) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStrengthenViewEventType.MAIN_GREW_UP_CLICK, item.dataSource as StrengthItem));
    }
    private function _onClickGoto(item:StrengthenMainViewItemUI) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStrengthenViewEventType.MAIN_GOTO_CLICK, item.dataSource as StrengthItem));
    }

    //===================================get/set======================================

    [Inline]
    public function get _ui() : StrengthenMainViewUI {
        return rootUI as StrengthenMainViewUI;
    }
    [Inline]
    public function get _strengthenData() : CStrengthenData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStrengthenData;
        }
        return null;
    }
    [Inline]
    public function get _playerData() : CPlayerData {
        if (_data && _data.length > 1) {
            return super._data[1] as CPlayerData;
        }
        return null;
    }

    private var _isFrist:Boolean = true;
    private var _tabList:CStrengthenTabList;
}
}
