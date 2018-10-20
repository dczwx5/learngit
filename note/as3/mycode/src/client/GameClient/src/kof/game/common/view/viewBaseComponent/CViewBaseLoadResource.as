//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/9.
 */
package kof.game.common.view.viewBaseComponent {

import morn.core.handlers.Handler;

public class CViewBaseLoadResource {
    public function CViewBaseLoadResource(swfRes:Array) {
        _swfResList = swfRes;
        if (_swfResList && _swfResList.length > 0) {
            _swfResBlockList = _swfResList[0];
            if (_swfResList.length > 1) {
                _swfResUnBlockList = _swfResList[1];
            }
        }
    }

    public function dispose() : void {
        _swfResList = null;
        _swfResBlockList = null;
        _swfResUnBlockList = null;
        _onBlockResourceFinishCallback = null;
        _onUnBlockResourceFinishCallback = null;
    }

    public function load(onBlockResourceFinish:Function, onUnBlockResourceFinish:Function) : void {
        _onBlockResourceFinishCallback = onBlockResourceFinish;
        _onUnBlockResourceFinishCallback = onUnBlockResourceFinish;

        if (_swfResBlockList && _swfResBlockList.length > 0) {
            for each (var swfUrl:String in _swfResBlockList) {
                if (!App.mloader.getResLoaded(swfUrl)) {
                    App.mloader.loadAssets(_swfResBlockList, new Handler(_onLoadResourceFinish), null, null, false);
                    return ;
                }
            }
        }
        _onLoadResourceFinish();
    }
    private function _onLoadResourceFinish(... args) : void {
        if (_swfResBlockList && _swfResBlockList.length > 0) trace( _swfResBlockList.join() + " load completed...");

        _onBlockResourceFinishCallback();

        // load unBlock Resource
        if (_swfResUnBlockList && _swfResUnBlockList.length > 0) {
            for each (var swfUrl:String in _swfResUnBlockList) {
                if (!App.mloader.getResLoaded(swfUrl)) {
                    App.mloader.loadAssets(_swfResUnBlockList, new Handler(_onLoadUnLockResourceFinish), null, null, false);
                    return ;
                }
            }
        }

        _onLoadUnLockResourceFinish();
    }

    private function _onLoadUnLockResourceFinish(... args) : void {
        if (_swfResUnBlockList && _swfResUnBlockList.length > 0) trace ( _swfResUnBlockList.join() + " load completed...");

        if (_onUnBlockResourceFinishCallback) _onUnBlockResourceFinishCallback();
    }

    private var _swfResList:Array; // 资源列表 二维数组, _swfResList[0] : 阻塞加载, _swfResList[1] : 非阻塞加载
    private var _swfResBlockList:Array; //
    private var _swfResUnBlockList:Array; //

    private var _onBlockResourceFinishCallback:Function;
    private var _onUnBlockResourceFinishCallback:Function;
}
}
