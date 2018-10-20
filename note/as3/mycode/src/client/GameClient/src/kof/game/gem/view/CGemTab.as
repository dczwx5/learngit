//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/5.
 */
package kof.game.gem.view {

import kof.framework.CAppSystem;
import kof.game.gem.data.CGemCategoryHeadData;
import kof.game.gem.data.CGemCategoryHeadData;
import kof.game.gem.data.CGemCategoryListCellData;
import kof.game.gem.data.CGemCategoryListData;
import kof.game.gem.event.CGemEvent;
import kof.ui.master.Gem.GemMergeTabUI;

import morn.core.components.Box;
import morn.core.components.Button;

import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CGemTab extends Component {

    private var _ui:GemMergeTabUI;
    private var _selected:Boolean;
    private var _headData:CGemCategoryHeadData;
    private var _selectHandler:Handler;
    private var _rootView:CGemMergeViewHandler;
    private var _openChildList:Boolean;
    private var _lastSelectChildItem:CGemCategoryListCellData;
    private var m_pSystem:CAppSystem;

    public function CGemTab(rootView:CGemMergeViewHandler, ui:GemMergeTabUI, dataSource:CGemCategoryHeadData)
    {
        super ();

        mouseChildren = true;
        _ui = ui;
        _rootView = rootView;
        m_pSystem = rootView.system;
        _selected = false;
        _headData = dataSource;
        _ui.dataSource = _headData;

        _ui.btn.toggle = true;
        _ui.btn.clickHandler = new Handler(_onClickBth);
        _ui.child_list.renderHandler = new Handler(_onRenderChildTab);
        this.addChild(_ui);

        _ui.child_list.visible = false;
        _openChildList = false;

        // 设置子列表
        _ui.btn.label = _headData.name;
        _ui.btn.labelColors = "0xa9bdd8,0xbfdeed,0xf0ecec";
        _ui.txt_canMerge.visible = _headData.isCanMerge;

        var listData:Array = categoryListData.getListData(_headData);
        if (listData && listData.length)
        {
            _ui.child_list.repeatY = listData.length;
            _ui.child_list.dataSource = listData;
            _ui.clip.visible = true;
        }
        else
        {
            _ui.clip.visible = false;
        }
    }

    public function addEventListeners():void
    {
    }

    public function removeEventListeners():void
    {

    }

    // 子tab列表
    private function _onRenderChildTab(comp:Component, idx:int) : void
    {
        var box:Box = comp as Box;
        var data:CGemCategoryListCellData = comp.dataSource as CGemCategoryListCellData;
        var btn:Button = box.getChildByName("child_btn") as Button;
        btn.clickHandler = new Handler(_onChildTabClick, [data]);
        btn.label = data.resultGem.name;
        btn.labelColors = "0xa9bdd8,0xbfdeed,0xf0ecec";
        var label:Label = box.getChildByName("txt_numInfo") as Label;
        label.text = "(" + data.canMergeNum + ")";
        label.visible = data.isCanMerge;
    }

    // 点击一级tab
    private function _onClickBth() : void
    {
        if (_selectHandler)
        {
            var listData:Array = categoryListData.getListData(_headData);
            if (listData && listData.length)
            {
                if (_lastSelectChildItem)
                {
                    _onChildTabClick(_lastSelectChildItem, false);
                }
                else
                {
                    var childListData:Array = _ui.child_list.dataSource as Array;
                    if (!childListData || childListData.length == 0)
                    {
                        childListData = listData;
                    }
                    var tempSelectItem:CGemCategoryListCellData = childListData[0];
                    _onChildTabClick(tempSelectItem, false);
                }
            }
            else
            {
                _selectHandler.executeWith([this, listData, false]);
            }
        }
    }

    // 点子列表
    // isClickChild true : 点tab然后调用
    private function _onChildTabClick(itemRecord:CGemCategoryListCellData, isClickChild:Boolean = true) : void
    {
        if (_selectHandler)
        {
//            var itemList:Array = categoryListData.getListData(_headData);
            _selectHandler.executeWith([this, itemRecord, isClickChild]);
            _lastSelectChildItem = itemRecord;
        }

        var cells:Vector.<Box> = _ui.child_list.cells;
        for each (var box:Box in cells )
        {
            if (box && box.dataSource)
            {
                var childItemRecord:CGemCategoryListCellData = box.dataSource as CGemCategoryListCellData;
                var btn:Button = box.getChildByName("child_btn") as Button;
                if (childItemRecord == itemRecord)
                {
                    btn.selected = true;
                }
                else
                {
                    btn.selected = false;
                }
            }
        }
    }

    public function resetState() : void
    {
        selected = false;

        if (_headData.hasChild > 0)
        {
            _lastSelectChildItem = null;
            _ui.child_list.selectedIndex = 0;
        }

        if (_openChildList)
        {
            reserveChildList();
        }
    }

    public function setActive() : void
    {
        _onClickBth();
    }

    // =============================================
    public function set selectHandler(v:Handler) : void {
        _selectHandler = v;
    }

    public override function get height() : Number {
        if (_openChildList) {
            return _ui.btn.height + _ui.child_list.height;
        } else {
            return _ui.btn.height;
        }
    }

    public function get ui() : GemMergeTabUI
    {
        return _ui;
    }

    public function reserveChildList() : void {
        if (_headData.hasChild > 0)
        {
            _openChildList = !_openChildList;
            _ui.child_list.visible = _openChildList;
            if (_openChildList) {
                _ui.clip.index = 1;
            } else {
                _ui.clip.index = 0;
            }
        }
    }

    /**
     * 更新提示信息(是否可合成、数量等信息)
     */
    public function updateTipInfo():void
    {
        if(_headData)
        {
            var newHeadData:CGemCategoryHeadData = categoryListData.getHeadByType(_headData.type);
            if(newHeadData)
            {
                _ui.txt_canMerge.visible = newHeadData.isCanMerge;
            }
        }

        _ui.child_list.refresh();
    }

    public function dispose() : void
    {
        _ui.parent.removeChild(_ui);
        _ui.btn.clickHandler = null;
        _ui.dataSource = null;
        _ui = null;
        _headData = null;
        _openChildList = false;
    }

    public function set selected(v:Boolean) : void {
        _selected = v;
        _ui.btn.selected = _selected;
    }

    public function get selected() : Boolean {
        return _selected;
    }

    public function get headData() : CGemCategoryHeadData {
        return _headData;
    }

    public function get categoryListData():CGemCategoryListData
    {
        return _rootView.categoryListData;
    }
}
}
