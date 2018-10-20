//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen.view {

import kof.table.StrengthType;
import kof.ui.master.strengthen.StrengthenTabUI;

import morn.core.handlers.Handler;

public class CStrengthenTabList {
    public function CStrengthenTabList(rootView:CStrengthenView) {
        _rootView = rootView;
        _createTab();
    }

    public function resetState() : void {
        var tabCount:int = _rootView._ui.tabBox.numChildren;
        for (var i:int = 0; i < tabCount; i++) {
            var tab:CStrengthenTab =  (_rootView._ui.tabBox.getChildAt(i) as CStrengthenTab);
            tab.resetState();
        }
    }

    public function activeFirstTab() : void {
        (_rootView._ui.tabBox.getChildAt(0) as CStrengthenTab).setActive();
    }

    private function _createTab() : void {
        var typeList:Array = _rootView._strengthenData.typeTable.toArray();
        for (var i:int = 0; i < typeList.length; i++) {
            var typeRecord:StrengthType = typeList[i] as StrengthType;

            var tabItem:CStrengthenTab = new CStrengthenTab(_rootView, new StrengthenTabUI(), typeRecord);
            tabItem.selectHandler = new Handler(_onSelectTab);
            _rootView._ui.tabBox.addChild(tabItem);
        }

        _updatePositionTab();
    }
    private function _onSelectTab(item:CStrengthenTab, itemList:Array, isSelectChild:Boolean) : void {
        if (!isSelectChild) {
            // 点一级tab
            item.reserveChildList();
        }
        var num:int = _rootView._ui.tabBox.numChildren;
        for (var i:int = 0; i < num; i++) {
            var tempItem : CStrengthenTab = _rootView._ui.tabBox.getChildAt( i ) as CStrengthenTab;
            if ( tempItem != item ) {
                if (tempItem.openChildList) {
                    tempItem.reserveChildList();
                }
                tempItem.selected = false;
            } else {
                tempItem.selected = true;
            }
        }

        _updatePositionTab();

        if (_renderHandler) {
            _renderHandler.executeWith([itemList]);
        }
    }

    private function _updatePositionTab() : void {
        var num:int = _rootView._ui.tabBox.numChildren;
        var preChild:CStrengthenTab;
        for (var i:int = 0; i < num; i++) {
            if (i > 0) {
                preChild = _rootView._ui.tabBox.getChildAt(i-1) as CStrengthenTab;
            }
            var child:CStrengthenTab = _rootView._ui.tabBox.getChildAt(i) as CStrengthenTab;
            if (preChild) {
                child.y = 4 + preChild.y + preChild.height;
            } else {
                child.y = 0;
            }
        }

        _rootView._ui.tab_panel.refresh();
    }

    public function set renderHandler(v:Handler) : void {
        _renderHandler = v;
    }

    private var _rootView:CStrengthenView;
    private var _renderHandler:Handler;
}
}
