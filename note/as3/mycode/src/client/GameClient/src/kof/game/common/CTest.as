//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/16.
 */
package kof.game.common {

import QFLib.Foundation;

import flash.utils.getTimer;

public class CTest {
    public static const _IS_OPEN:Boolean = false;
    public function CTest() {
    }

    public static function traceObject(data:Object, isArray:Boolean = false) : void {
        if (!_IS_OPEN) return ;
        var str:String = _buildObjectStr(data, isArray);
        log(str);
    }
    private static function _buildObjectStr(data:Object, isArray:Boolean = false) : String {
        var str:String = "";
        var tempData:*;
        for (var key:* in data) {
            tempData = data[key];
            if (!isArray) {
                str += key + " : ";
            }
            if (tempData is int || tempData is String || tempData is Number || tempData is Boolean) {
                str += data[key] + ", ";
            } else {
                if (tempData is Array) {
                    str += "[ ";
                    str += _buildObjectStr(tempData, true);
                    str += " ]";
                } else {
                    str += "{ ";
                    str += _buildObjectStr(tempData, false);
                    str += " }";
                }
            }

        }return str;
    }

    public static function timeStart() : void {
        _timeStart = getTimer();
    }
    public static function timeEnd() : void {
        _timeEnd = getTimer();
    }
    public static function get duringTime() : int {
        return _timeEnd - _timeStart;
    }
    public static function flushDuringTime(str:String = null) : void {
        if (str == null) {
            trace("duringTime is " + duringTime);
        } else {
            trace(str + " duringTime is " + duringTime);
        }
    }

    public static function log(str:String) : void {
        if (!_IS_OPEN) return ;
//        trace(str);
        Foundation.Log.logMsg(str);
    }
    public static function get testReward() : Array {
        return [
            {ID:1,num:980},
            {ID:8,num:6},
            {ID:9,num:100},
            {ID:30100001,num:3},
            {ID:50900003,num:3}
            ,{ID:30101006,num:2}];
    }

    private static var _timeStart:int;
    private static var _timeEnd:int;
}
}
