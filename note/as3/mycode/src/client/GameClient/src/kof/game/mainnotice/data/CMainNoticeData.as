//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/5.
 */
package kof.game.mainnotice.data {

import QFLib.Foundation.CMap;

public class CMainNoticeData {

    private var _data:CMap;

    private var _isDirty:Boolean;

    public function CMainNoticeData() {
        _data = new CMap();
    }
    public function initialData(data:Object) : void {
        _updateData(data);
    }
    private function _updateData(data:Object) : void {
        if (!data) return ;
        for (var key:String in data) {
            _setData(key, data[key]);
        }
    }
    private function _setData(key:String, value:*) : void {
        _data[key] = value;
        _isDirty = true;
    }

    public function get gamePromptID() : int { return _data[_gamePromptID]; }
    public function get contents() : Array { return _data[_contents]; }
    public function get time() : Number { return _data[_time]; }


    public static const _gamePromptID:String = "gamePromptID";
    public static const _contents:String = "contents";
    public static const _time:String = "time";
}
}
