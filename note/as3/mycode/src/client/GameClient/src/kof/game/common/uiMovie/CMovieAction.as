//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/19.
 */
package kof.game.common.uiMovie {

public class CMovieAction {
    public function CMovieAction(action : Function, duringTime : Number) {
        this._action = action;
        this.duringTime = duringTime;
    }

    public function call() : void {
        if (_action) {
            _action(this);
        }
    }

    private var _action : Function;
    public var isFinish : Boolean;
    public var duringTime : Number;
    public var next : CMovieAction;
}
}