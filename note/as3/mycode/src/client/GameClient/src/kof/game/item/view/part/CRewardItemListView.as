//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/21.
 */
package kof.game.item.view.part {


import kof.framework.CAppSystem;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.common.view.CChildView;
import kof.game.item.view.tips.CItemTipsView;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardListUI;

import morn.core.components.Button;

import morn.core.components.Component;
import morn.core.components.List;

import morn.core.handlers.Handler;

// 奖励横向列表组件, 左对齐
// name : x_y :
//      x-> 0:居中, 1:左对齐, 2右对齐,
//      y->repeatx : 0:默认5, other 指定repeatx
// name == null || name.length == 0 -> 0_0 -> 居中, repeatx == 5
public class CRewardItemListView extends CChildView {
    public function CRewardItemListView() {
        // super ([], [["impCommon.swf"]]);
        _isShowCurrency = true;
        _isShowItemCount = true;
        _forceRepeatX = -1;
        _forceAlign = -1;
    }

    protected override function _onCreate() : void {
        setNoneData();
    }
    protected override function _onShow() : void {
        _itemList.renderHandler = new Handler(_onRenderItem);
        _itemList.visible = false;
        if (_leftBtn) {
            _leftBtn.visible = false;
            _leftBtn.clickHandler = new Handler(_onLeft);
        }
        if (_rightBtn) {
            _rightBtn.clickHandler = new Handler(_onRight);
            _rightBtn.visible = false;
        }

        _updateLayout();
    }

    // 使用当前item数量设置repeatx的值, 即把所有item都列出来
    public function setRepeatXByData() : void {
        var dataList:Array = _rewardDataList;
        if (dataList && dataList.length > 0) {
            repeatValue = dataList.length;
        }
        _updateLayout();
    }

    public function updateLayout() : void {
        _updateLayout();
    }

    protected function _updateLayout() : void {
        if (uiView) {
            _ALIGN = 0;
            _REPEATX = 5;

            if (-1 != _forceAlign) {
                _ALIGN = _forceAlign;
            }
            if (-1 != _forceRepeatX) {
                _REPEATX = _forceRepeatX;
                if (_rightBtn) {
                    uiView.width = _REPEATX * 60;
                    _rightBtn.x = uiView.width + 1;
                }
            }
        }
    }

    protected override function _onHide() : void {
        _itemList.renderHandler = null;
        if (_leftBtn) {
            _leftBtn.clickHandler = null;
        }
        if (_leftBtn) {
            _rightBtn.clickHandler = null;
        }
        _dataList = null;
    }

    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) {
            return false;
        }

        var itemList:Array = _rewardDataList;
        if (!itemList) {
            _itemList.visible = false;
            return true;
        }

        if (!_isShowCurrency) {
            itemList = _dataList.itemList;
        }

        if (itemList.length > 0) _itemList.visible = true;
        else _itemList.visible = false;

        var len:int = itemList.length;
        if (len > _REPEATX) {
            if (_itemList.repeatX != _REPEATX) {
                _itemList.repeatX = _REPEATX;
            }
        } else {
            if (_itemList.repeatX != itemList.length) {
                _itemList.repeatX = itemList.length;
            }
        }

        _itemList.dataSource = itemList;

        if (_ALIGN == 0) {
            _itemList.centerX = 0;
        } else if (_ALIGN == 1) {
            _itemList.left = 0;
        } else {
            _itemList.right = 0;
        }

        _curPage = 0;
        _updatePage();
        return true;
    }

    private function _onRenderItem(box:Component, idx:int) : void {
        var item:RewardItemUI = box as RewardItemUI;
        if (item == null) return ;

        if (_rewardDataList == null || _itemList.array == null || idx >= _itemList.array.length) {
            item.visible = false;
            return ;
        }
        _onRenderItemC(uiCanvas as CAppSystem, box, idx, isShowItemCount, _showHasReward);

    }
    public static function onRenderItem(system:CAppSystem, box:Component, idx:int, isShowItemCount:Boolean, showHasReward:Boolean) : void {
        var item:RewardItemUI = box as RewardItemUI;
        if (item == null) return ;

        _onRenderItemC(system, box, idx, isShowItemCount, showHasReward);
    }

    private static function _onRenderItemC(system:CAppSystem, box:Component, idx:int, isShowItemCount:Boolean, showHasReward:Boolean) : void {
        var item:RewardItemUI = box as RewardItemUI;
        if (item == null) return ;
        if (!item.dataSource) {
            item.visible = false;
            return ;
        }

        item.visible = true;
        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
        item.num_lable.visible = isShowItemCount;
        item.num_lable.text = itemData.num == 0 ? "" : itemData.num.toString();
        item.icon_image.url = itemData.iconSmall;
        item.bg_clip.index = itemData.quality;

        item.toolTip = new Handler(AddTips, [system, item]);
        item.hasTakeImg.visible = showHasReward;
        item.box_eff.visible = itemData.effect;
        if (itemData.effect) {
            item.clip_eff.play();
        } else {
            item.clip_eff.stop();
        }
    }

//    protected function get _ui() : RewardListUI {
//        return rootUI["reward_list"] as RewardListUI;
//    }
    public function get repeatX() : int {
        return _itemList.repeatX;
    }
    protected function get _itemList() : List {
        if (_ui) return _ui.item_list;
        return (rootUI["reward_list"] as RewardListUI).item_list;
    }
    protected function get _leftBtn() : Button {
        if (_ui) return _ui.left_btn;
        return (rootUI["reward_list"] as RewardListUI).left_btn;
    }
    protected function get _rightBtn() : Button {
        if (_ui) return _ui.right_btn;
        return (rootUI["reward_list"] as RewardListUI).right_btn;
    }
    public function get uiView() : RewardListUI {
        if (_ui) return _ui;
        return (rootUI["reward_list"] as RewardListUI);
    }

    private static function AddTips(system:CAppSystem, item:Component) : void {
        var itemSystem:CItemSystem = (system).stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }
    private function _addTips(item:Component) : void {
        AddTips(uiCanvas as CAppSystem, item);
    }

    public function get _rewardDataList() : Array {
        //if (_dataList == null) {
            _refreshRewardData();
        //}

        if (!_dataList) return null;
        return _dataList.list;
    }

    private var _showHasReward:Boolean;
    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);
        _showHasReward = false;

    }
    public function showHasReward() : void {
        _showHasReward = true;
    }
    private function _refreshRewardData() : void {
        var dataList:CRewardListData;
        if (_data is int) {
            dataList = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, _data as int);
        } else if (_data is CRewardListData) {
            dataList = _data as CRewardListData;
        } else if (_data is Array) {
            dataList = CRewardUtil.createByList((uiCanvas as CAppSystem).stage, _data as Array);
        }
        _dataList = dataList;
    }

    public function set ui(v:RewardListUI) : void {
        _ui = v;
    }
    public function get ui() : RewardListUI {
        return _ui;
    }

    // =====page======
    private function _onLeft() : void {
        _curPage--;
        _updatePage();
    }
    private function _onRight() : void {
        _curPage++;
        _updatePage();
    }
    private function _updatePage() : void {
        var itemList:List = _itemList;
        if (_curPage < 0)
            _curPage = 0;
        if (_curPage >= itemList.totalPage)
            _curPage = itemList.totalPage - 1;
        itemList.page = _curPage;

        if (itemList.totalPage == 1) {
            _leftBtn.visible = false;
            _rightBtn.visible = false;
        } else {
            if (_curPage == 0) {
                _leftBtn.visible = false;
                _rightBtn.visible = true;
            } else {
                _leftBtn.visible = true;
                if (_curPage == itemList.totalPage-1) {
                    _rightBtn.visible = false;
                } else {
                    _rightBtn.visible = true;
                }
            }
        }
    }

    public function get isShowCurrency() : Boolean {
        return _isShowCurrency;
    }
    public function set isShowCurrency(value : Boolean) : void {
        _isShowCurrency = value;
    }
    public function get repeatValue() : int {
        return _forceRepeatX;
    }
    public function set repeatValue(value : int) : void {
        _forceRepeatX = value;
    }

    public function get forceAlign() : int {
        return _forceAlign;
    }
    public function set forceAlign(value : int) : void {
        _forceAlign = value;
    }

    public function get isShowItemCount():Boolean {
        return _isShowItemCount;
    }
    public function set isShowItemCount(value:Boolean):void {
        _isShowItemCount = value;
    }

    private var _dataList:CRewardListData;
    private var _ui:RewardListUI;

    private var _curPage:int;
    private var _isShowCurrency:Boolean = true; // 是否显示货币
    private var _forceRepeatX:int = -1; // 指定横向数量, 默认不指定, 这个优化级最高, 如果指定了, 就使用这个
    private var _forceAlign:int = -1; // 0 居中, 1左对齐, 2右对齐, 默认不指定, 这个优化级最高, 如果指定了, 就使用这个

    private var _isShowItemCount:Boolean = true; // 是否显示道具数量

    // 在ui中指定
    private var _REPEATX:int = 5;
    private var _ALIGN:int = 0; // 0 居中, 1左对齐, 2右对齐


}
}
