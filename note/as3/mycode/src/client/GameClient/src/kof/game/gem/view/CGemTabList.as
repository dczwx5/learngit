//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/5.
 */
package kof.game.gem.view {

import kof.game.gem.data.CGemCategoryHeadData;
import kof.game.gem.data.CGemCategoryListCellData;
import kof.ui.master.Gem.GemMergeTabUI;

import morn.core.handlers.Handler;

public class CGemTabList {

    private var _rootView:CGemMergeViewHandler;
    private var _renderHandler:Handler;// 外部的更新方法

    public function CGemTabList(rootView:CGemMergeViewHandler)
    {
        _rootView = rootView;
        _createTab();
    }

    public function resetState() : void {
        var tabCount:int = _rootView.viewUI.tabBox.numChildren;
        for (var i:int = 0; i < tabCount; i++) {
            var tab:CGemTab =  (_rootView.viewUI.tabBox.getChildAt(i) as CGemTab);
            tab.resetState();
        }
    }

    public function activeFirstTab() : void {
        (_rootView.viewUI.tabBox.getChildAt(0) as CGemTab).setActive();
    }

    private function _createTab() : void
    {
        var headList:Array = _rootView.categoryListData.getHeadListData();
        for (var i:int = 0; i < headList.length; i++)
        {
            var headData:CGemCategoryHeadData = headList[i] as CGemCategoryHeadData;

            var tabItem:CGemTab = new CGemTab(_rootView, new GemMergeTabUI(), headData);
            tabItem.selectHandler = new Handler(_onSelectTab);
            _rootView.viewUI.tabBox.addChild(tabItem);
        }

        _updatePositionTab();
    }

    private function _onSelectTab(item:CGemTab, cellData:CGemCategoryListCellData, isSelectChild:Boolean) : void {
        if (!isSelectChild) {
            // 点一级tab
            item.reserveChildList();
        }
        var num:int = _rootView.viewUI.tabBox.numChildren;
        for (var i:int = 0; i < num; i++) {
            var tempItem : CGemTab = _rootView.viewUI.tabBox.getChildAt( i ) as CGemTab;
            if ( tempItem != item ) {
                tempItem.selected = false;
            } else {
                tempItem.selected = true;
            }
        }

        _updatePositionTab();

        if (_renderHandler)
        {
            _renderHandler.executeWith([cellData]);
        }
    }

    private function _updatePositionTab() : void {
        var num:int = _rootView.viewUI.tabBox.numChildren;
        var preChild:CGemTab;
        for (var i:int = 0; i < num; i++) {
            if (i > 0) {
                preChild = _rootView.viewUI.tabBox.getChildAt(i-1) as CGemTab;
            }
            var child:CGemTab = _rootView.viewUI.tabBox.getChildAt(i) as CGemTab;
            if (preChild) {
                child.y = 4 + preChild.y + preChild.height;
            } else {
                child.y = 0;
            }
        }

        _rootView.viewUI.tab_panel.refresh();
    }

    /**
     * 更新提示信息(是否可合成、数量等信息)
     */
    public function updateTipInfo():void
    {
        var num:int = _rootView.viewUI.tabBox.numChildren;
        for (var i:int = 0; i < num; i++)
        {
            var gemTab : CGemTab = _rootView.viewUI.tabBox.getChildAt( i ) as CGemTab;
            if(gemTab)
            {
                gemTab.updateTipInfo();
            }
        }
    }

    public function set renderHandler(v:Handler) : void
    {
        _renderHandler = v;
    }
}
}
