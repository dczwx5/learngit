//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.view {

import kof.table.StrengthItem;
import kof.table.StrengthType;
import kof.ui.master.strengthen.StrengthenTabUI;

import morn.core.components.Box;
import morn.core.components.Button;

import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.Label;

import morn.core.handlers.Handler;

public class CStrengthenTab extends Component {
    public function dispose() : void {
        _ui.parent.removeChild(_ui);
        _ui.btn.clickHandler = null;
        _ui.dataSource = null;
        _ui = null;
        _typeRecord = null;
        _openChildList = false;
    }

    public function resetState() : void {
        selected = false;

        if (_typeRecord.hasChild > 0) {
            _lastSelectChildItem = null;
            _ui.child_list.selectedIndex = 0;
        }

        if (_openChildList) {
            reserveChildList();
        }
    }

    public function setActive() : void {
        _onClickBth();
    }

    public function CStrengthenTab(rootView:CStrengthenView, ui:StrengthenTabUI, dataSource:StrengthType) {
        super ();
        mouseChildren = true;
        _ui = ui;
        _rootView = rootView;
        _selected = false;
        _typeRecord = dataSource ;
        _ui.dataSource = _typeRecord;

        _ui.btn.toggle = true;
        _ui.btn.clickHandler = new Handler(_onClickBth);
        _ui.child_list.renderHandler = new Handler(_onRenderChildTab);
        this.addChild(_ui);

        _ui.child_list.visible = false;
        _openChildList = false;

        // 设置子列表
        _ui.btn.btnLabel.text = _typeRecord.typeName;
        if (_typeRecord.hasChild > 0) {
            var allList:Array = _rootView._strengthenData.itemListData.getChildTabListByType(_typeRecord.ID);
            _ui.child_list.repeatY = allList.length;
            _ui.child_list.dataSource = allList;
        }
        _ui.clip.visible = _typeRecord.hasChild > 0;

    }

    // 子tab列表
    private function _onRenderChildTab(comp:Component, idx:int) : void {
        var box:Box = comp as Box;
        var itemRecord:StrengthItem = comp.dataSource as StrengthItem;
        var btn:Button = box.getChildByName("child_btn") as Button;
        btn.clickHandler = new Handler(_onChildTabClick, [itemRecord]);
        btn.btnLabel.text = itemRecord.tabName;
        btn.btnLabel.align = "left";

        var lbl:Label = box.getChildByName("btnLabel") as Label;
        if (lbl) {
            lbl.visible = false;
        }
        var img:Image = box.getChildByName("child_icon") as Image;
        img.url = itemRecord.tabIcon;

    }

    // 点击一级tab
    private function _onClickBth() : void {
        if (_selectHandler) {
            if (_typeRecord.hasChild > 0) {
                if (_lastSelectChildItem) {
                    _onChildTabClick(_lastSelectChildItem, false);
                } else {
                    var childListData:Array = _ui.child_list.dataSource as Array;
                    if (!childListData || childListData.length == 0) {
                        childListData = _rootView._strengthenData.itemListData.getChildTabListByType(_typeRecord.ID);
                    }
                    var tempSelectItem:StrengthItem = childListData[0];
                    _onChildTabClick(tempSelectItem, false);
                }
            } else {
                var itemList:Array = _rootView._strengthenData.itemListData.getListByType(_typeRecord.ID);
                _selectHandler.executeWith([this, itemList, false]);
            }
        }
    }
    // 点子列表
    // isClickChild true : 点tab然后调用
    private function _onChildTabClick(itemRecord:StrengthItem, isClickChild:Boolean = true) : void {
        if (_selectHandler) {
            var itemList:Array = _rootView._strengthenData.itemListData.getChildrenListByType(_typeRecord.ID, itemRecord.childGroup);
            _selectHandler.executeWith([this, itemList, isClickChild]);
            _lastSelectChildItem = itemRecord;
        }

        var cells:Vector.<Box> = _ui.child_list.cells;
        for each (var box:Box in cells ) {
            if (box && box.dataSource) {
                var childItemRecord:StrengthItem = box.dataSource as StrengthItem;
                var btn:Button = box.getChildByName("child_btn") as Button;
                if (childItemRecord == itemRecord) {
                    btn.selected = true;
                } else {
                    btn.selected = false;
                }
            }

        }

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

    public function get ui() : StrengthenTabUI {
        return _ui;
    }

    public function get openChildList() :  Boolean {
        return _openChildList;
    }
    public function reserveChildList() : void {
        if (_typeRecord.hasChild > 0) {
            _openChildList = !_openChildList;
            _ui.child_list.visible = _openChildList;
            if (_openChildList) {
                _ui.clip.index = 1;
            } else {
                _ui.clip.index = 0;
            }
        }
    }
    public function set selected(v:Boolean) : void {
        _selected = v;
        _ui.btn.selected = _selected;
    }
    public function get selected() : Boolean {
        return _selected;
    }

    public function get typeRecord() : StrengthType {
        return _typeRecord;
    }

    private var _ui:StrengthenTabUI;
    private var _selected:Boolean;
    private var _typeRecord:StrengthType;
    private var _selectHandler:Handler;
//    private var _renderHandler:Handler;
    private var _rootView:CStrengthenView;
    private var _openChildList:Boolean;
    private var _lastSelectChildItem:StrengthItem;
}
}
