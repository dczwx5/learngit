//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/3.
 */
package kof.ui.components {

import flash.events.MouseEvent;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.IItem;
import morn.core.handlers.Handler;

public class ButtonGroup extends Box implements IItem {

    protected var _items:Vector.<Button>;
    protected var _setIndexHandler:Handler = new Handler(setIndex);
    protected var _selectedIndex:int;
    protected var _selectHandler:Handler;

    public function ButtonGroup() {
        super();
    }

    /**批量设置视图*/
    public function setItems(views:Array):void {
        removeAllChild();
        var index:int = 0;
        for (var i:int = 0, n:int = views.length; i < n; i++) {
            var item:Button = views[i];
            if (item) {
                item.name = "btn" + index;
                addChild(item);
                index++;
            }
        }
        initItems();
    }

    /**增加视图*/
    public function addItem(view:Button):void {
        view.name = "btn" + _items.length;
        addChild(view);
        initItems();
    }

    /**初始化视图*/
    public function initItems():void {
        _items = new Vector.<Button>();
        for (var i:int = 0; i < int.MAX_VALUE; i++) {
            var item:Button = getChildByName("btn" + i) as Button;
            if (item == null) {
                break;
            }
            _items.push(item);
            item.removeEventListener(MouseEvent.CLICK, onClick);
            item.addEventListener(MouseEvent.CLICK, onClick);
            item.selected = (i == _selectedIndex);
        }
    }
    protected function onClick(e:MouseEvent):void {
        var item:Button = e.currentTarget as Button;
        selectedIndex = _items.indexOf(e.currentTarget as Button);
    }

    /**当前视图索引*/
    public function get selectedIndex():int {
        return _selectedIndex;
    }

    public function set selectedIndex(value:int):void {
        if (_selectedIndex != value) {
            setSelect(_selectedIndex, false);
            _selectedIndex = value;
            setSelect(_selectedIndex, true);
            if (_selectHandler != null) {
                _selectHandler.executeWith([_selectedIndex]);
            }
        }
    }

    protected function setSelect(index:int, selected:Boolean):void {
        if (_items && index > -1 && index < _items.length) {
            _items[index].selected = selected;
        }
    }

    /**选择项*/
    public function get selection():Button {
        return _selectedIndex > -1 && _selectedIndex < _items.length ? _items[_selectedIndex] : null;
    }

    public function set selection(value:Button):void {
        selectedIndex = _items.indexOf(value);
    }

    /**索引设置处理器(默认接收参数index:int)*/
    public function get setIndexHandler():Handler {
        return _setIndexHandler;
    }

    public function set setIndexHandler(value:Handler):void {
        _setIndexHandler = value;
    }

    protected function setIndex(index:int):void {
        selectedIndex = index;
    }

    /**选择被改变时执行的处理器(默认返回参数index:int)*/
    public function get selectHandler():Handler {
        return _selectHandler;
    }

    public function set selectHandler(value:Handler):void {
        _selectHandler = value;
    }
    /**集合*/
    public function get items():Vector.<Button> {
        return _items;
    }

    override public function set dataSource(value:Object):void {
        _dataSource = value;
        if (value is int || value is String) {
            selectedIndex = int(value);
        } else {
            super.dataSource = value;
        }
    }
}
}
