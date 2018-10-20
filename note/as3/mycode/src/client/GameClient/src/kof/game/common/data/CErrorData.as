//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/20.
 */
package kof.game.common.data {

import kof.game.common.CLang;

public class CErrorData {
    public function CErrorData(data:Object) {
        if (data == null) return ;

        if (data.hasOwnProperty("gamePromptID")) gamePromptID = data["gamePromptID"];
        if (data.hasOwnProperty("contents")) contents = data["contents"];
        if (data.hasOwnProperty("promptParams")) contents = data["promptParams"];
    }

    public function get isError() : Boolean {
        return gamePromptID  > 0;
    }
    public function get errorString() : String {
        var ret:String = "";
        for each (var error:String in contents) {
            ret += CLang.Get(error);
        }
        return ret;
    }

    public var gamePromptID :int; // 错识码
    public var contents:Array; // 错误内容string array
}
}
