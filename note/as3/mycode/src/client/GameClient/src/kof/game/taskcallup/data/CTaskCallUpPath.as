//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/20.
 */
package kof.game.taskcallup.data {

import QFLib.Utils.PathUtil;

public class CTaskCallUpPath {
    public function CTaskCallUpPath() {
    }

    //任务图标
    public static  function getTaskCallUpIocnUrlByID( iconID : String ):String{
        var url:String = "icon/taskcallup/" + iconID +  ".png";
        return PathUtil.getVUrl(url);
    }
}
}
