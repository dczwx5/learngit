//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/19.
 */
package kof.game.task.data {

import QFLib.Utils.PathUtil;

public class CTaskPath {
    public function CTaskPath() {
    }

    //任务图标
    public static  function getTaskIocnUrlByID( img : String ):String{
        var url:String = "icon/task/" + img +  ".png";
        return PathUtil.getVUrl(url);
    }
}
}
