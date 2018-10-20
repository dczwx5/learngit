//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/21.
 */
package kof.game.player.data {

import kof.data.CObjectListData;

public class CEmabattleDataManager extends CObjectListData {
    public function CEmabattleDataManager() {
        super (CEmbattleListData, CEmbattleListData.TYPE);
    }

    // 判断是否有阵型数据
    public function hasEmbattleData(type:int) : Boolean {
        var list:CEmbattleListData =  super.getByPrimary(type) as CEmbattleListData;
        return list != null;
    }

    public function getByType(type:int) : CEmbattleListData {
        var list:CEmbattleListData =  super.getByPrimary(type) as CEmbattleListData;
        if (!list) {
            // 正常情况下，服务器会把所有阵型发下来, 但如果加了新阵型, 老号的数据会有问题(不会有新阵型的数据)
            list = new CEmbattleListData();
            this.addByCreatedData(list, {type:type, embattleList:[]});
        }
        return list;
    }
    public function getEmbattleDataByTypeAndPosition( type : int, position : int ) : CEmbattleData {
        var list:CEmbattleListData =  getByType( type );
        var embattleData : CEmbattleData;
        for each ( embattleData in list.list ){
            if( embattleData.position == position )
                    return embattleData;
        }
        return null;
    }

    // return heroList
    public function getHeroCountByType(type:int) : int {
        var heroList:Array = getHeroListByType(type);
        if (!heroList || heroList.length == 0) {
            return 0;
        }
        var count:int = 0;
        for each (var heroData:CPlayerHeroData in heroList) {
            if (heroData) {
                count++;
            }
        }
        return count;
    }

    public function getHeroListByType(type:int) : Array {
        var heroList:Array = getHeroListByEmbattleList(getByType(type));
        return heroList;
    }
    public function getHeroListByEmbattleList(selfEmbattle:CEmbattleListData) : Array {
        var heroList:Array = new Array();
        var embattleData:CEmbattleData;
        for (var i:int = 0; i < selfEmbattle.list.length; i++) {
            embattleData = selfEmbattle.list[i];
            if (embattleData) {
                var heroID:int = embattleData.prosession;
                var heroData:CPlayerHeroData = (_rootData as CPlayerData).heroList.getHero(heroID);
                heroList[i] = heroData;
            }
        }
        return heroList;
    }
    public function getPowerByEmbattleType(type:int) : int {
        var heroList:Array = getHeroListByType(type);
        var power:int = calcPowerByHeroList(heroList);
        return power;
    }
    public function getPowerByEmbattleList(selfEmbattle:CEmbattleListData) : int {
        var heroList:Array = getHeroListByEmbattleList(selfEmbattle);
        var power:int = calcPowerByHeroList(heroList);
        return power;
    }
    public function calcPowerByHeroList(heroList:Array) : int {
        var power:int = 0;
        for each (var heroData:CPlayerHeroData in heroList) {
            power += heroData.battleValue;
        }
        return power;
    }

    public static const _embattleMessage:String = "embattleMessage";
}
}
