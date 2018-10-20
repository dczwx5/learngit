//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/18.
 */
package kof.game.common {

import flash.display.Stage;
import flash.events.Event;

import morn.core.handlers.Handler;

public class CNextFrameCall {
    public function CNextFrameCall(stage:Stage, callback:Handler, nextFrameCount:int = 1) {
        if (callback) {
            _nextFrameCount = nextFrameCount;
            _stage = stage;
            _hander = callback;

            if (_nextFrameCount < 1) {
                if (_hander) {
                    _hander.execute();
                }
            } else {
                stage.addEventListener(Event.ENTER_FRAME, _onNextFrame);
            }
        }

    }
    private function _onNextFrame(e:Event) : void {
        iFrame++;
        if (iFrame >= _nextFrameCount) {
            _stage.removeEventListener(Event.ENTER_FRAME, _onNextFrame);
            if (_hander) {
                _hander.execute();
            }
        }
    }


    private var iFrame:int = 0;
    private var _nextFrameCount:int;
    private var _stage:Stage;
    private var _hander:Handler;

}
}
