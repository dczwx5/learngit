//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/10.
 */
package kof.game.common.view.viewBaseComponent {

import kof.game.common.view.CUIResourceLoadData;
import kof.game.common.view.CUIResourceLoadUtil;

// show之后加载资源
public class CViewBaseLoadAfterShow {
    public function CViewBaseLoadAfterShow() {
    }

    public function addUiResource(url:String, type:int) : void {
        if (!_uiLoadList) {
            _uiLoadList = new Array();
        }
        var data:CUIResourceLoadData = new CUIResourceLoadData(url, type);
        _uiLoadList[_uiLoadList.length] = data;
    }
    // 非UI
    public function addOtherResource(url:String) : void {
        if (!_otherLoadList) {
            _otherLoadList = new Array();
        }
        var data:CUIResourceLoadData = new CUIResourceLoadData(url, 0);
        _otherLoadList[_otherLoadList.length] = data;
    }

    public function load(callback:Function) : void {
        _callback = callback;

        CUIResourceLoadUtil.loadResource(_uiLoadList, _loadOtherResource);
    }

    private function _loadOtherResource(... args) : void {
        if (_otherLoadList && _otherLoadList.length > 0) {

        }

        _callback();
    }

    private var _uiLoadList:Array;
    private var _otherLoadList:Array;
    private var _callback:Function;

}
}