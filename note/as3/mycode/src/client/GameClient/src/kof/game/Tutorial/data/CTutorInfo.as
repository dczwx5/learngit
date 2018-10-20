//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial.data {

public class CTutorInfo {
    public function CTutorInfo() {
    }

    public function get rewindStep() : int {
        if (pre >= 0) {
            return pre;
        }
        return step;
    }

    public function hasNext() : Boolean {
        if (step == next || next <= 0) {
            return false;
        }
        return true;
    }

    public function get rewindFunc() : Array {
        if (_rewindData && _rewindData.length > 0) {
            return _rewindData;
        }
        return null;

//        if (_rewindHandler != null) return _rewindHandler;
//        if (_rewindData && _rewindData.length > 0) {
//            var args:Array = null;
//            if (_rewindData.length > 1) {
//                args = new Array(_rewindData.length-1);
//                for (var i:int = 1; i < _rewindData.length-1; i++) {
//                    args[i-1] = _rewindData[i];
//                }
//            }
//
//
//            _rewindHandler = new Handler(_rewindData[0], args);
//        }
//        return null;
    }
    public function get finishFunc() : Array {
        if (_finishData && _finishData.length > 0) {
            return _finishData;
        }
        return null;
    }

    public function get advanceFunc() : Array {
        if (_advancdData && _advancdData.length > 0) {
            return _advancdData;
        }
        return null;
    }

    public var step:int;
    public var pre:int;
    public var next:int;

    private var _rewindData:Array;
    private var _finishData:Array;
    private var _advancdData:Array;
//    private var _rewindHandler:Handler;
//    private var _finishFunc:Handler;
//    private var _advanceFunc:Handler;
}
}
