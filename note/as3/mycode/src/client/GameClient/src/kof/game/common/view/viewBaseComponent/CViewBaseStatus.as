//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/9.
 */
package kof.game.common.view.viewBaseComponent {

public class CViewBaseStatus {
    public function CViewBaseStatus() {
        _state = STATE_UNREADY;
        _waitToShow = false;
    }

    public function dispose() : void {
        _state = STATE_DISPOSE;
    }
    public function loadingResource() : void {
        _state = STATE_LOADING_RESOURCE;
    }
    public function created() : void {
        _state = STATE_CREATE;

    }
    public function showed() : void {
        _state = STATE_SHOW;
    }
    public function hided() : void {
        _state = STATE_HIDE;
    }
    public function get waitToShow() : Boolean {
        return _waitToShow;
    }
    public function set waitToShow(v:Boolean) : void {
        _waitToShow = v;
    }

    final public function get isUnReadyState() : Boolean { return _state == STATE_UNREADY; }
    final public function get isLoadingResouceState() : Boolean { return _state == STATE_LOADING_RESOURCE; }
    final public function get isCreateState() : Boolean { return _state == STATE_CREATE; }
    final public function get isShowState() : Boolean { return _state == STATE_SHOW; }
    final public function get isHideState() : Boolean { return _state == STATE_HIDE; }
    final public function get isDisposeState() : Boolean { return _state == STATE_DISPOSE; }

    private static const STATE_UNREADY:int = -1;
    private static const STATE_LOADING_RESOURCE:int = 0;
    private static const STATE_CREATE:int = 1;
    private static const STATE_SHOW:int = 2;
    private static const STATE_HIDE:int = 3;
    private static const STATE_DISPOSE:int = 4;

    private var _state:int;
    private var _waitToShow:Boolean;
}
}
