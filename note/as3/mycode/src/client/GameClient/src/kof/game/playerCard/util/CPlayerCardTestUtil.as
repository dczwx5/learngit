//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/19.
 */
package kof.game.playerCard.util {

import kof.framework.CAppSystem;
import kof.message.CardPlayer.CardPlayerResponse;

public class CPlayerCardTestUtil {

    private static var _system : CAppSystem;

    public function CPlayerCardTestUtil()
    {
    }

    public static function initialize( gSystem : CAppSystem ) : void
    {
        _system = gSystem;
    }

    public static function getResponseData():CardPlayerResponse
    {
        var response:CardPlayerResponse = new CardPlayerResponse();
        response.dataMap = [];
        for(var i:int = 0; i < 5; i++)
        {
            var obj:Object = {};
            obj["itemID"] = 30802001;
            obj["count"] = 99;
            if(obj.hasOwnProperty("count"))
            {
                delete obj["count"];
            }
            obj["itemNum"] = 99;
            response.dataMap[i] = obj;
        }

        var obj2:Object = {};
        obj2["itemID"] = 40100101;
        obj2["itemNum"] = 20;
        obj2["display"] = 108;
        response.dataMap.push(obj2);

        response.number = Math.ceil(Math.random()*10);

        return response;
    }
}
}
