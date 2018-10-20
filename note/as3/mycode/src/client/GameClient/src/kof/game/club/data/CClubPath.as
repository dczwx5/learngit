//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/27.
 */
package kof.game.club.data {

import QFLib.Utils.PathUtil;

public class CClubPath {
    public function CClubPath() {
    }
    //俱乐部小图标
    public static  function getClubIconUrByID( iconID : int ):String{
        var url:String = "icon/club/icon/" + iconID +  ".png";
        return PathUtil.getVUrl(url);
    }
    //俱乐部大图标
    public static  function getBigClubIconUrByID( iconID : int ):String{
        var url:String = "icon/club/icon_big/" + iconID +  ".png";
        return PathUtil.getVUrl(url);
    }
}
}
