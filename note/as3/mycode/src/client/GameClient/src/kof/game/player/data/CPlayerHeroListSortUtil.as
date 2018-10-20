//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/14.
 */
package kof.game.player.data {

import QFLib.Math.CMath;

import kof.game.instance.enum.EInstanceType;

public class CPlayerHeroListSortUtil {
    private var _pHeroListData:CPlayerHeroListData;
    public function CPlayerHeroListSortUtil( heroListData:CPlayerHeroListData) {
        _pHeroListData = heroListData;
    }
    // 一键 布阵返回列表  不考虑上阵
    public function getCommentList(emType:int) : Array {
        var list:Array = _pHeroListData.cloneChildList;
        var isIgnoreSortEmbattle:Boolean = true;
        var compareHandler:Function = getcCompareByEmType(emType, isIgnoreSortEmbattle);
        list.sort(compareHandler);
        return list;
    }
    //考虑上阵
    public function getSortList(emType:int) : Array {
        var list:Array = _pHeroListData.cloneChildList;
        var compareHandler:Function = getcCompareByEmType(emType);
        list.sort(compareHandler);
        return list;
    }
    public function getcCompareByEmType(emType:int, isIgnoreSortEmbattle:Boolean = false) : Function {
        switch (emType) {
            case EInstanceType.TYPE_MAIN: return isIgnoreSortEmbattle ? compareByScenarioIgnoreSortEmbattle : compareByScenario;
            case EInstanceType.TYPE_GOLD_INSTANCE: return isIgnoreSortEmbattle ? compareByScenarioIgnoreSortEmbattle : compareByScenario;
            case EInstanceType.TYPE_TRAIN_INSTANCE: return isIgnoreSortEmbattle ? compareByScenarioIgnoreSortEmbattle : compareByScenario;
            case EInstanceType.TYPE_CLIMP_CULTIVATE: return isIgnoreSortEmbattle ? compareByCultivateIgnoreSortEmbattle : compareByCultivate;
            case EInstanceType.TYPE_ELITE: return isIgnoreSortEmbattle ? compareByEliteIgnoreSortEmbattle : compareByElite;
            case EInstanceType.TYPE_PVP: return isIgnoreSortEmbattle ? compareBy1V1IgnoreSortEmbattle : compareBy1V1;
            case EInstanceType.TYPE_3V3: return isIgnoreSortEmbattle ? compareBy3V3IgnoreSortEmbattle : compareBy3V3;
            case EInstanceType.TYPE_3PV3P: return isIgnoreSortEmbattle ? compareBy3PV3PIgnoreSortEmbattle : compareBy3PV3P;
            case EInstanceType.TYPE_PEAK_GAME: return isIgnoreSortEmbattle ? compareByMatchIgnoreSortEmbattle : compareByMatch;
            case EInstanceType.TYPE_PEAK_GAME_FAIR: return isIgnoreSortEmbattle ? compareByPeakFairIgnoreSortEmbattle : compareByPeakFair;
            case EInstanceType.TYPE_HOOK:return isIgnoreSortEmbattle ? compareByHookIgnoreSortEmbattle : compareByHook;
            case EInstanceType.TYPE_ARENA:return isIgnoreSortEmbattle ? compareByArenaIgnoreSortEmbattle : compareByArena;
            case EInstanceType.TYPE_WORLD_BOSS:return isIgnoreSortEmbattle ? compareByWorldBossIgnoreSortEmbattle : compareByWorldBoss;
            case EInstanceType.TYPE_ENDLESS_TOWER:return isIgnoreSortEmbattle ? compareByEndlessTowerIgnoreSortEmbattle : compareByEndlessTower;
            case EInstanceType.TYPE_PEAK_1V1:return isIgnoreSortEmbattle ? compareByPeak1v1IgnoreSortEmbattle : compareByPeak1v1;
            case EInstanceType.TYPE_GUILD_WAR:return isIgnoreSortEmbattle ? compareByGuildWarIgnoreSortEmbattle : compareByGuildWar;
            case EInstanceType.TYPE_STREET_FIGHTER:return isIgnoreSortEmbattle ? compareByStreetFigterIgnoreSortEmbattle : compareByStreetFighter;
        }
        return null;
    }

    // 已出阵优化规则不生效, 主要用来一键出战
    public function compareIgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_MAIN, v1, v2, true); }
    public function compareByScenarioIgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_MAIN, v1, v2, true); }
    public function compareByCultivateIgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compare_hp_battleValueB(EInstanceType.TYPE_CLIMP_CULTIVATE, v1, v2, true); }
    public function compareByEliteIgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return compare_battleValue_onlyB(EInstanceType.TYPE_ELITE, v1, v2, true); }
    public function compareBy1V1IgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_PVP, v1, v2, true); }
    public function compareBy3V3IgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_3V3, v1, v2, true); }
    public function compareBy3PV3PIgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_3PV3P, v1, v2, true); }
    public function compareByMatchIgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_PEAK_GAME, v1, v2, true); }
    public function compareByPeakFairIgnoreSortEmbattle(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_PEAK_GAME_FAIR, v1, v2, true); }
    public function compareByHookIgnoreSortEmbattle(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return compare_battleValue_onlyB(EInstanceType.TYPE_HOOK,v1,v2, true); }
    public function compareByArenaIgnoreSortEmbattle(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_ARENA,v1,v2, true); }
    public function compareByWorldBossIgnoreSortEmbattle(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_WORLD_BOSS,v1,v2, true); }
    public function compareByEndlessTowerIgnoreSortEmbattle(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_ENDLESS_TOWER,v1,v2, true); }
    public function compareByPeak1v1IgnoreSortEmbattle(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_PEAK_1V1,v1,v2, true); }
    public function compareByGuildWarIgnoreSortEmbattle(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_GUILD_WAR,v1,v2, true); }
    public function compareByStreetFigterIgnoreSortEmbattle(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return compare_battleValue_onlyB(EInstanceType.TYPE_STREET_FIGHTER,v1,v2, true); }

    // 默认使用剧情阵型排序, 主要用于在列表中排序显示
    public function compare(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_MAIN, v1, v2); }
    public function compareByScenario(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_MAIN, v1, v2); }
    public function compareByCultivate(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compare_hp_battleValueB(EInstanceType.TYPE_CLIMP_CULTIVATE, v1, v2); }
    public function compareByElite(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return compare_battleValue_onlyB(EInstanceType.TYPE_ELITE, v1, v2); }
    public function compareBy1V1(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_PVP, v1, v2); }
    public function compareBy3V3(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_3V3, v1, v2); }
    public function compareBy3PV3P(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_3PV3P, v1, v2); }
    public function compareByMatch(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_PEAK_GAME, v1, v2); }
    public function compareByPeakFair(v1:CPlayerHeroData, v2:CPlayerHeroData) : Number { return _compareB(EInstanceType.TYPE_PEAK_GAME_FAIR, v1, v2); }
    public function compareByHook(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return compare_battleValue_onlyB(EInstanceType.TYPE_HOOK,v1,v2); }
    public function compareByArena(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_ARENA,v1,v2); }
    public function compareByWorldBoss(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_WORLD_BOSS,v1,v2); }
    public function compareByEndlessTower(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_ENDLESS_TOWER,v1,v2); }
    public function compareByPeak1v1(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_PEAK_1V1,v1,v2); }
    public function compareByGuildWar(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return _compareB(EInstanceType.TYPE_GUILD_WAR,v1,v2); }
    public function compareByStreetFighter(v1:CPlayerHeroData,v2:CPlayerHeroData):Number{ return compare_battleValue_onlyB(EInstanceType.TYPE_STREET_FIGHTER,v1,v2); }

    // 通用排序
    private function _compareB(emType:int, v1:CPlayerHeroData, v2:CPlayerHeroData, isIgnoreSortEmbattle:Boolean = false) : Number {
        var sortValue:Object = _getSortValueByCanHireC(v1, v2);
        if (sortValue != null) return sortValue as Number;

        sortValue = _getSortValueByPieceC(v1, v2);
        if (sortValue != null) return sortValue as Number;

        if (!isIgnoreSortEmbattle) {
            var emSortValue:int = _getEmbattleSortValueC(emType, v1, v2);
            if (emSortValue != 0) return emSortValue;
        }

        // 都存在, 且同样在/(不在)剧情阵型中
        // 剧情副本出战编制、资质、星级、等级、战力、id
        return v1.compareWith(v2);
    }

    // isIgnoreSortEmbattle : true : 已出阵优化规则不生效
    private function compare_battleValue_onlyB(emType:int, v1:CPlayerHeroData, v2:CPlayerHeroData, isIgnoreSortEmbattle:Boolean = false):Number {
        if ( !isIgnoreSortEmbattle ) {
            var emSortValue : int = _getEmbattleSortValueC( emType, v1, v2 );
            if ( emSortValue != 0 ) return emSortValue;
        }

        return v2.battleValue - v1.battleValue;
    }

    private function _compare_hp_battleValueB(emType:int, v1:CPlayerHeroData, v2:CPlayerHeroData, isIgnoreSortEmbattle:Boolean = false) : Number {
        if (!isIgnoreSortEmbattle) {
            var emSortValue:int = _getEmbattleSortValueC(emType, v1, v2);
            if (emSortValue != 0) return emSortValue;
        }

        var extendsData1:CHeroExtendsData = v1.extendsData as CHeroExtendsData;
        var extendsData2:CHeroExtendsData = v2.extendsData as CHeroExtendsData;
        if (extendsData1 && extendsData2) {
            if (extendsData1.hp <= 0 && extendsData2.hp > 0) {
                return 1;
            } else if (extendsData2.hp <= 0 && extendsData1.hp > 0) {
                return -1;
            }
        }
        return v2.battleValue - v1.battleValue;
    }

    /**
     * 新规则, 如果是没召, 同时又可以招的, 放在最前面
     */
    private function _getSortValueByCanHireC(v1:CPlayerHeroData, v2:CPlayerHeroData) : Object {
        var isHero1Exist:Boolean = v1.hasData;
        var isHero2Exist:Boolean = v2.hasData;
        if (isHero1Exist == true && isHero1Exist == isHero2Exist) {
            // 两个都存在, 不处理
            return null;
        }
        if (isHero1Exist == false && isHero2Exist == false) {
            if (v1.enoughToHire && v2.enoughToHire) return null; // 两个都可召, 不处理
            else if (v1.enoughToHire) return -1; // 可召的优化
            else if (v2.enoughToHire) return 1;
            else return null;
        } else if (!isHero1Exist) {
            if (v1.enoughToHire) return -1;
            else return null;
        } else if (!isHero2Exist) {
            if (v2.enoughToHire) return 1;
            else return null;
        }
        return null;
    }

    //
    private function _getSortValueByPieceC(v1:CPlayerHeroData, v2:CPlayerHeroData) : Object {
        // var v1Index:int = ArrayUtil.findItemByProp(list, CPlayerHeroData._prototypeID, ID1);
        // var v2Index:int = ArrayUtil.findItemByProp(list, CPlayerHeroData._prototypeID, ID2);
        // 根据hasData判断是否存在, 避免频繁查询
        var isHero1Exist:Boolean = v1.hasData;
        var isHero2Exist:Boolean = v2.hasData;
        if (isHero1Exist && isHero2Exist == false) {
            // 1存在, 2不存在
            return -1;
        } else if (isHero2Exist && isHero1Exist == false) {
            // 1不存在, 2存在
            return 1;
        } else if (isHero1Exist == false && isHero2Exist == false) {
            // 都不存在
            var rate1:Number = v1.pieceRate;
            var rate2:Number = v2.pieceRate;
            // 相等, 则按默认排序ID
            if (Math.abs(rate1 - rate2) < CMath.EPSILON) return v1.playerDisplayRecord.SortID - v2.playerDisplayRecord.SortID;
            // 碎片比高的在前
            return rate2 - rate1;
        }
        return null;
    }
    // 根据阵型排序
    public function _getEmbattleSortValueC(emType:int, v1:CPlayerHeroData, v2:CPlayerHeroData) : int {
        var embattleList:CEmbattleListData = (_pHeroListData.rootData as CPlayerData).embattleManager.getByType(emType);
        if (embattleList && embattleList.list && embattleList.list.length > 0) {
            var posEm1:int = embattleList.getPosByHero(v1.prototypeID);
            var posEm2:int = embattleList.getPosByHero(v2.prototypeID);
            if (posEm1 != -1 && posEm2 == -1) return -1;
            else if (posEm1 == -1 && posEm2 != -1) return 1;
            else if (posEm1 != -1 && posEm2 != -1) return posEm1 - posEm2;
        }
        return 0;
    }
}
}
