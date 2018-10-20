//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/8/26.
 */
package kof.game.common {
import flash.events.TimerEvent;

import flash.utils.Timer;

public class CDelayCall {
    // delay : 1000 == 1秒
    public function CDelayCall(call:Function, delay:Number, args:Array=null) {
        if (call == null) return ;
        if (delay < 0) {
            _onTimerEnd(null);
            return ;
        }

        _callback = call;
        _args = args;
        _timer = new Timer(delay*1000, 1);
        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, _onTimerEnd);
        _timer.start();
    }
    public function dispose() : void {
        if (_timer) {
            _timer.stop();
            _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, _onTimerEnd);
            _timer = null;
        }
        _callback = null;
        _args = null;
    }

    private function _onTimerEnd(e:TimerEvent) : void {
        if (_callback) {
            _callback.apply(null, _args);
        }
        dispose();
    }



    private var _timer:Timer;
    private var _callback:Function;
    private var _args:Array;
}
}
