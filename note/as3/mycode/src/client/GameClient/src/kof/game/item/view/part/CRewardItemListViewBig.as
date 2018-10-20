//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/02.
 */
package kof.game.item.view.part {

import kof.framework.CAppSystem;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.ui.imp_common.ItemUIUI;

import morn.core.components.Component;
import morn.core.components.List;

import morn.core.handlers.Handler;

// 横向大图标
public class CRewardItemListViewBig {

    public function CRewardItemListViewBig(system:CAppSystem, list:List) {
        _list = list;
        _system = system;

        _isShowCurrency = true;
        _isShowItemCount = true;

        _list.renderHandler = new Handler(_onRenderItem);
        _list.visible = false;
    }


    protected function _onHide() : void {
        _list.renderHandler = null;
        _dataList = null;
        _dataObject = null;
        _system = null;
    }

    public function updateWindow() : Boolean {
        var itemList:Array = _rewardDataList;
        if (!itemList) {
            _list.visible = false;
            return true;
        }

        if (!_isShowCurrency) {
            itemList = _dataList.itemList;
        }

        if (itemList.length > 0) {
            _list.visible = true;
        } else {
            _list.visible = false;
        }

        var len:int = itemList.length;
        _list.repeatX = len;
        _list.dataSource = itemList;
        _list.centerX = _list.centerX;

        return true;
    }

    private function _onRenderItem(box:Component, idx:int) : void {
        var item:ItemUIUI = box as ItemUIUI;
        if (item == null) return ;

        if (_rewardDataList == null || _list.array == null || idx >= _list.array.length) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
        item.txt_num.visible = _isShowItemCount;
        item.txt_num.text = itemData.num.toString();
        item.img.url = itemData.iconBig;
        item.clip_bg.index = itemData.quality;
        item.toolTip = new Handler(_addTips, [item]);

        item.clip_effect.visible = itemData.effect;
        if (item.clip_effect.visible) {
            item.clip_effect.autoPlay = true;
            item.circle_effect.play();
        } else {
            item.clip_effect.autoPlay = false;
            item.circle_effect.stop();
        }

        item.circle_effect.visible = false;
        item.circle_effect.autoPlay = false;
        item.circle_effect.stop();
    }

    private function _addTips(item:Component) : void {
        var itemSystem:CItemSystem = (_system).stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }

    public function get _rewardDataList() : Array {
        _refreshRewardData();

        if (!_dataList) return null;
        return _dataList.list;
    }

    private var _showHasReward:Boolean;
    public function setData(data:Object, forceInvalid:Boolean = true) : void {
        _dataObject = data;
        _showHasReward = false;

    }
    public function showHasReward() : void {
        _showHasReward = true;
    }
    private function _refreshRewardData() : void {
        var dataList:CRewardListData;
        if (_dataObject is int) {
            dataList = CRewardUtil.createByDropPackageID((_system).stage, _dataObject as int);
        } else if (_dataObject is CRewardListData) {
            dataList = _dataObject as CRewardListData;
        } else if (_dataObject is Array) {
            dataList = CRewardUtil.createByList((_system).stage, _dataObject as Array);
        }
        _dataList = dataList;
    }

    public function get uiHeight() : int {
        if (_list && _list.dataSource) {
            var len:int = (_list.dataSource as Array).length;
            return len * 80 + (len-1) * _list.spaceX;
        }
        return 1;
    }

    public function get isShowCurrency() : Boolean {
        return _isShowCurrency;
    }
    public function set isShowCurrency(value : Boolean) : void {
        _isShowCurrency = value;
    }
    public function get isShowItemCount():Boolean {
        return _isShowItemCount;
    }
    public function set isShowItemCount(value:Boolean):void {
        _isShowItemCount = value;
    }
    private var _list:List;
    private var _dataObject:Object;

    private var _dataList:CRewardListData;
    private var _isShowCurrency:Boolean = true; // 是否显示货币
    private var _isShowItemCount:Boolean = true; // 是否显示道具数量

    private var _system:CAppSystem;
}
}
