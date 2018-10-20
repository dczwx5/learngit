//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/11/29.
 */
package kof.game.club.view.clubgame {

import QFLib.Utils.PathUtil;

public class ClubGameImgUrlConst {

//    public static const TYPE_LIST:Array = ["0","1","A","10","J","Q","K"];
    public static const CARD_ARY:Array = [100,101,102,103,104,105];

    public static function getCardUrl( id:int ):String
    {
        var url:String = "icon/clubgame/" + CARD_ARY[id] +  ".png";
        return PathUtil.getVUrl(url);
    }

}
}
