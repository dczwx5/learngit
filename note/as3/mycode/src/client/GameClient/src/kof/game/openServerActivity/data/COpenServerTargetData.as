//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/10/25.
 */
package kof.game.openServerActivity.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class COpenServerTargetData extends CObjectData {
    public function COpenServerTargetData() {
        super();
        _data = new CMap();
    }

    override public function updateDataByData(data:Object) : void {
        if (!data) return ;
        for (var key:String in data) {
            _data[key] = data[key];
        }
//        if(_data[_isObtained]){
//            if(_data[_obtainedNum] > 0){
//                _data[_obtainedNum] --;
//            }
//        }
    }



    public function set targetId(value:Number) : void {
        _data[_targetId] = value;
    }
    public function set curVal(value:String) : void {
        _data[_curVal] = value;
    }
    public function set targetVal(value:int) : void {
        _data[_targetVal] = value;
    }
    public function set obtainedNum(value:int) : void {
        _data[_obtainedNum] = value;
    }
    public function set isObtained(value:Boolean) : void {
        _data[_isObtained] = value;
    }
    public function set isComplete(value:Boolean) : void {
        _data[_isComplete] = value;
    }

    public function get targetId() : Number { return _data[_targetId]; }
    public function get curVal() : String { return _data[_curVal]; }
    public function get targetVal() : int { return _data[_targetVal]; }
    public function get obtainedNum() : int { return _data[_obtainedNum]; }
    public function get isObtained() : Boolean { return _data[_isObtained]; }
    public function get isComplete() : Boolean { return _data[_isComplete];}

    public static const _targetId:String = "targetId";// 目标id、配表id
    public static const _curVal:String = "curVal";//当前值、以及达到了多少
    public static const _targetVal:String = "targetVal";//目标值、要达到多少
    public static const _obtainedNum:String = "obtainedNum";//已领取数
    public static const _isObtained:String = "isObtained";//自己是否已领取
    public static const _isComplete:String = "isComplete";//是否完成


}
}
