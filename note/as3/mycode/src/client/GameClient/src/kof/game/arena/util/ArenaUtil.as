//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/25.
 */
package kof.game.arena.util {

import kof.game.arena.data.CArenaResultData;
import kof.game.arena.data.CArenaRoleData;
import kof.game.common.view.resultWin.CPVPResultData;

public class ArenaUtil {

    /** 是否第一次打开界面 */
    public static var isFirstOpen:Boolean = true;

    public function ArenaUtil()
    {
    }

    public static function getArenaRoleData():CArenaRoleData
    {
        var roleData:CArenaRoleData = new CArenaRoleData();
        var obj:Object = CArenaRoleData.createObjectData(1001,"不知火舞知火舞",1,999999,999,108);
        roleData.updateDataByData(obj);

        return roleData;
    }

    public static function getArenaResultData():CArenaResultData
    {
        var serverData:Object = {};

        var blueInfo:Object = {};
        blueInfo.curRank = 7127;

        var arr1:Array = [];
        var heroInfo:Object = {};
        heroInfo.battleValue = 1086;
        heroInfo.heroId = 311;
        arr1.push(heroInfo);

        heroInfo = {};
        heroInfo.battleValue = 1086;
        heroInfo.heroId = 205;
        arr1.push(heroInfo);

        heroInfo = {};
        heroInfo.battleValue = 1086;
        heroInfo.heroId = 304;
        arr1.push(heroInfo);

        blueInfo.heroesInfo = arr1;
        blueInfo.name = "s223.体贴的鸡丝";
        blueInfo.rankChange = 258;

        serverData.blueInfo = blueInfo;


        var redInfo:Object = {};
        redInfo.curRank = 6503;

        var arr2:Array = [];
        heroInfo = {};
        heroInfo.battleValue = 1138;
        heroInfo.heroId = 112;
        arr2.push(heroInfo);

        heroInfo = {};
        heroInfo.battleValue = 1136;
        heroInfo.heroId = 108;
        arr2.push(heroInfo);

        heroInfo = {};
        heroInfo.battleValue = 799;
        heroInfo.heroId = 312;
        arr2.push(heroInfo);

        redInfo.heroesInfo = arr2;
        redInfo.name = "s223.草薙京";
        redInfo.rankChange = -258;

        serverData.redInfo = redInfo;
        serverData.result = 1;

        var rewardArr:Array = [];
        var itemData:Object = {};
        itemData.ID = 15;
        itemData.num = 50;
        rewardArr.push(itemData);

        itemData = {};
        itemData.ID = 1;
        itemData.num = 20000;
        rewardArr.push(itemData);

        itemData = {};
        itemData.ID = 50900002;
        itemData.num = 2;
        rewardArr.push(itemData);

        serverData.rewards = rewardArr;

        var arenaResultData:CArenaResultData = new CArenaResultData();
        arenaResultData.convertData(serverData);

        return arenaResultData;
    }

}
}
