//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/11.
 */
package kof.game.common.view {

import morn.core.handlers.Handler;

public class CUIResourceLoadUtil {
    public function CUIResourceLoadUtil() {
    }

    // type : Resloader.xxx
    public static function loadResource(list:Array, callback:Function, args:Array = null) : void {
        if (list && list.length > 0) {
            var loadList:Array;
            for each (var loadData:CUIResourceLoadData in list) {
                if (false == _isLoaded(loadData)) {
                    if (loadList == null) {
                        loadList = new Array();
                    }
                    loadList[loadList.length] = _buildData(loadData.type, loadData.url);
                }
            }

            if (loadList && loadList.length > 0) {
                App.mloader.loadAssets(loadList, new Handler(callback, args), null, null, false);
                return ;
            }
        }

        if (callback) {
            callback.apply(null, args);
        }
    }

    private static function _isLoaded(loadData:CUIResourceLoadData) : Boolean {
//        switch (loadData.type) {
//            case ResLoader.SWF :
//                return App.mloader.getResLoaded(loadData.url);
//            case ResLoader.BMD :
//                return App.asset.getBitmapData(loadData.url);
//        }
        return App.mloader.getResLoaded(loadData.url);
    }
    private static function _buildData(type:int, url:String) : Object {
        return {url:url,type:type,size:1,priority:1};
    }
}
}
