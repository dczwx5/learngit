//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/13.
 */
package kof.game.item.view.part {

import kof.ui.imp_common.RewardListUI;
import kof.ui.imp_common.RewardMultyListUI;

import morn.core.components.Button;

import morn.core.components.Component;

import morn.core.components.List;

// 多行
// _initialArgs[0] : colCount
public class CRewardItemMulityListView extends CRewardItemListView {
    public function CRewardItemMulityListView() {
        // super ([], [["impCommon.swf"]]);
    }
    protected override function _onCreate() : void {
        _itemList.visible = false;
        _baseHeight = (rootUI["reward_list"] as RewardMultyListUI).height;
    }
    private var _baseHeight:Number;
    public override function updateWindow() : Boolean {
//        if (_stage.isValid()) {
//            _stage.removeRenderEvent();
//            return false;
//        }
//        _stage.validate();

        var itemList:Array = _rewardDataList;
        if (itemList.length > 0) _itemList.visible = true;
        else _itemList.visible = false;

        if (itemList.length > 0) {
            var colCount:int = _colCount;
            if (itemList.length > colCount) {
                _itemList.repeatX = colCount;
                _itemList.repeatY = ((itemList.length-1) / colCount) + 1;
                if (_itemList.repeatY > 1) {
                    var itemHeight:int = (_itemList.getCell(0) as Component).height;
                    (rootUI["reward_list"] as RewardMultyListUI).height = _baseHeight + (_itemList.repeatY - 1) * (5 + itemHeight);
                } else {
                    (rootUI["reward_list"] as RewardMultyListUI).height = _baseHeight;
                }
            } else {
                _itemList.repeatX = itemList.length;
                _itemList.repeatY = 1;
                (rootUI["reward_list"] as RewardMultyListUI).height = _baseHeight;
            }
        }
        _itemList.dataSource = itemList;
        // _itemList.refresh();
        _itemList.centerX = _itemList.centerX; // 强制布局
        return true;
    }

    // 每行显示多少个item
    private function get _colCount() : int {
        if (_initialArgs && _initialArgs.length > 0) {
            var col:int = _initialArgs[0] as int;
            return col;
        }
        return 3;
    }

    protected override function get _itemList() : List {
        return (rootUI["reward_list"] as RewardMultyListUI).item_list;
    }
    protected override function get _leftBtn() : Button {
        return null;
    }
    protected override function get _rightBtn() : Button {
        return null;
    }
    public override function get uiView() : RewardListUI {
        return null;
    }
}
}
