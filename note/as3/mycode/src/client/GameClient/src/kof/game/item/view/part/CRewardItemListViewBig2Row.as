//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
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
import kof.ui.imp_common.RewardFullItemUIUI;

import morn.core.components.Button;

import morn.core.components.Component;
import morn.core.components.List;

import morn.core.handlers.Handler;

// 横向大图标, 固定2行
public class CRewardItemListViewBig2Row {

    public function CRewardItemListViewBig2Row( system:CAppSystem, list:List, leftBtn:Button = null, rightBtn:Button = null) {
        _list = list;
        _system = system;

        _isShowCurrency = true;
        _isShowItemCount = true;

        _list.renderHandler = new Handler(_onRenderItem);
        _list.visible = false;

        _leftBtn = leftBtn;
        _rightBtn = rightBtn;

        if (_leftBtn) {
            _leftBtn.visible = false;
            _leftBtn.clickHandler = new Handler(_onLeft);
        }
        if (_rightBtn) {
            _rightBtn.clickHandler = new Handler(_onRight);
            _rightBtn.visible = false;
        }
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

        itemList.sortOn("quality", Array.DESCENDING);
        if (itemList.length > 0) {
            _list.visible = true;
        } else {
            _list.visible = false;
        }

//        var len:int = itemList.length;
//        _list.repeatX = len;
        _list.dataSource = itemList;
//        _list.centerX = _list.centerX;
        _curPage = 0;
        _updatePage();

        return true;
    }

    private function _onRenderItem(box:Component, idx:int) : void {
        var item:RewardFullItemUIUI = box as RewardFullItemUIUI;
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
        item.item_name.text = itemData.nameWithColor;
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
    private function _onLeft() : void {
        _curPage--;
        _updatePage();
    }
    private function _onRight() : void {
        _curPage++;
        _updatePage();
    }
    private function _updatePage() : void {
        if (!_rightBtn || !_rightBtn) return ;

        var itemList:List = _list;
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
    private var _leftBtn:Button;
    private var _rightBtn:Button;

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
    private var _curPage:int;

}
}
