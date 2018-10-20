//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/7.
 */
package kof.game.common.hero {
import QFLib.Utils.ArrayUtil;

import kof.game.common.view.CChildView;
import kof.game.common.view.component.CListItemSelectCompoent;
import kof.game.common.view.component.CListPageCompoent;
import kof.game.common.view.component.CUICompoentMap;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.ui.imp_common.HeroListHUI;

import morn.core.components.Button;
import morn.core.components.List;
import morn.core.handlers.Handler;

// 格斗家列表组件
public class CHeroListView extends CChildView {
    public function CHeroListView() {
        _heroItemRender = new CHeroListItemRender();
    }

    public override function setData(data:Object, isForceValid:Boolean = true) : void {
        super.setData(data, isForceValid);
        if (_heroList.dataSource) {
            _heroList.selectedIndex = 0;
        }
    }
    protected override function _onShow() : void {
        _isFirst = true;
        _uiCompoentMap = new CUICompoentMap(this);

        var func:Function;
        if (_itemRenderHandler) {
            func = _itemRenderHandler;
        } else {
            func = _heroItemRender.renderItem;
        }
        _heroList.renderHandler = new Handler(func);
        _uiCompoentMap.addCompoent(CListItemSelectCompoent, new CListItemSelectCompoent(this, _heroList, null, _onSelectItemB));
        (_uiCompoentMap.getCompoent(CListItemSelectCompoent) as CListItemSelectCompoent).addEffectHandler(new CHeroListItemEffectHandler(_heroList, ui.select_effect_clip));
        _uiCompoentMap.addCompoent(CListPageCompoent, new CListPageCompoent(this, _heroList, _leftBtn, _rightBtn, null, null));
    }
    protected override function _onHide() : void {
        _isFirst = false;

        _heroList.renderHandler = null;
        _heroList.mouseHandler = null;
        _heroList.selectHandler = null;

        this._uiCompoentMap.dispose();
        _uiCompoentMap = null;
    }

    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) {
            return false;
        }

        _heroList.dataSource = _heroListData;
        this._uiCompoentMap.refresh();

        _firstUpdateWindow();

        return true;
    }
    public function set selectHero(heroID:int) : void {
        // 打开指定页, 并选中
        var index:int = ArrayUtil.findItemByProp(_heroListData, "prototypeID", heroID);
        var pageCompoent:CListPageCompoent = _uiCompoentMap.getCompoent(CListPageCompoent) as CListPageCompoent;
        if (pageCompoent) {
            pageCompoent.setSelectedIndex(index, true);
        }
    }
    public function set selectIndex(index:int) : void {
        // 打开指定页, 并选中
        var pageCompoent:CListPageCompoent = _uiCompoentMap.getCompoent(CListPageCompoent) as CListPageCompoent;
        if (pageCompoent) {
            pageCompoent.setSelectedIndex(index, true);
        }
    }

    private function _firstUpdateWindow() : void {
        if (_isFirst) {
            _isFirst = false;
            if (_initialArgs && _initialArgs.length > 0 && _initialArgs[0] != -1) {
                var selectHeroID:int = _initialArgs[0];
                if (selectHeroID > -1) {
                    this.setArgs(null);

                    // 打开指定页, 并选中
                    var index:int = ArrayUtil.findItemByProp(_heroListData, "prototypeID", selectHeroID);
                    var pageCompoent:CListPageCompoent = _uiCompoentMap.getCompoent(CListPageCompoent) as CListPageCompoent;
                    if (pageCompoent) {
                        pageCompoent.setSelectedIndex(index, true);
                    }
                }
            } else {
                _heroList.selectedIndex = 0;
            }
        }
    }



    private function _onSelectItemB(idx:int) : void {
        if (rootView) this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_LIST_SELECT_HERO, _selectHeroData));
        this.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_LIST_SELECT_HERO, _selectHeroData));
    }

    public function set visible(v:Boolean) : void {
        if (ui) {
            ui.visible = v;
        }
    }

    public function get selectHeroData() : CPlayerHeroData { return _selectHeroData; }
    public function get ui() : HeroListHUI {
        if (_ui) {
            return _ui;
        }
        return rootUI["hero_list_view"] as HeroListHUI;
    }
    public function set ui(v:HeroListHUI) : void {
        _ui = v;
    }
    private var _ui:HeroListHUI;

    private function get _leftBtn() : Button { return ui.hero_left_btn; }
    private function get _rightBtn() : Button { return ui.hero_right_btn; }
    public function get _heroList() : List { return ui.hero_list; }

    private function get _selectHeroData() : CPlayerHeroData { return _heroList.selectedItem as CPlayerHeroData; }
    private function get _heroListData() : Array { return _data as Array; }

    private var _isFirst:Boolean = false;
    private var _uiCompoentMap:CUICompoentMap;

    private var _itemRenderHandler:Function;

    public function set itemRenderHandler(value : Function) : void {
        _itemRenderHandler = value;
    }

    private var _heroItemRender:CHeroListItemRender;

    public function set isShowQuality(value:Boolean):void
    {
        _heroItemRender.isShowQuality = value;
    }
}
}
