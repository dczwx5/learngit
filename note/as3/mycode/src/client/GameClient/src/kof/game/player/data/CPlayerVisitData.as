//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/2/1.
 */
package kof.game.player.data {

import kof.data.CObjectData;
import kof.framework.CAppSystem;
import kof.framework.IDatabase;
import kof.game.character.property.CBasePropertyData;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;

// 访问玩家数据
public class CPlayerVisitData extends CObjectData {
    public function CPlayerVisitData(database:IDatabase = null) {
        _databaseSystem = database;
        this.addChild(CPlayerHeroListData);
        this.addChild(CPlayerHeroListData);
        this.addChild(CPlayerHeroListData);
        this.addChild(CBasePropertyData);
    }

    public override function updateDataByData(data:Object) : void {
        this.clearData();

        super.updateDataByData(data);

        heroList.resetChild();
        var pTop10List:Array = top10HeroList;
        if (pTop10List) {
            for each (var heroObjectData:Object in pTop10List) {
                if (heroObjectData && heroObjectData.hasOwnProperty(CPlayerHeroData._prototypeID)) {
                    heroObjectData[CPlayerHeroData._ID] = heroObjectData[CPlayerHeroData._prototypeID];
                }
            }
        }
        heroList.updateDataByData(top10HeroList);

        arenaHeroList.resetChild();
        arenaHeroList.updateDataByData(arenaEmbattle);

        peakHeroList.resetChild();
        peakHeroList.updateDataByData(peakEmbattle);

        impressionProperty.clearData();
        impressionProperty.updateDataByData(impressionTotalProperty);
    }

    public function get platformData() : CPlatformBaseData {
        if (!_platformData) {
            _platformData = ((_databaseSystem as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem).createPlatfromData(platformInfo);
        }
        return _platformData;
    }
    private var _platformData:CPlatformBaseData;

    public function get platformInfo() : Object { return _data["platformInfo"]; }

    public function get name() : String { return _data[_name] ; }
    public function get battleValue() : Number { return _data[ _battleValue ]; }
    public function get level() : int {
        return _data[_level];
    }
    // 战队头像
    public function get useHeadID() : int {
        return _data[ _headId ];
    }

    public function get curTitleID() : int {
        return _data[_title] ;
    }

    // 个性签名
    public function get sign() : String {
        return _data[ _sign ];
    }
    public function getNoneServerName() : String {
        var tempName : String = _data[ _name ];
        var index : int = tempName.indexOf( "." );
        if ( index == -1 ) {
            return tempName;
        }
        tempName = tempName.substring( index + 1 );
        return tempName;
    }
    public function get clubName() : String {
        return _data[ _clubName ];
    }
    public function get vipLv() : Number {
        return _data[ _VIPLevel ];
    }
    public function get heroCount() : int {
        return _data[ _heroNum ];
    }
    // 战队模型
    public function get prototypeID() : int {
        return _data[ _prototypeID ];
    } // 格斗家形象ID
    public function get id() : int {
        return _data[ _id ];
    }
    public function get top10HeroList() : Array {
        return _data[ _heroInfo ]["topTenHeroes"];
    }
    public function get top10BattleValue() : int {
        return _data[_heroInfo]["battleValue"];
    }

    public function get talentInfo() : Object {
        return _data[_talentInfo];
    }
    public function get talentPeakLevel() : int {
        return talentInfo["fairPeakTotalLevel"];
    }
    public function get talentPeakPower() : int {
        return talentInfo["fairPeakBattleValue"];
    }
    public function get talentLevel() : int {
        return talentInfo["normalTotalLevel"];
    }
    public function get talentPower() : int {
        return talentInfo["normalBattleValue"];
    }
    public function get arenaPower() : int {
        return arenaInfo["battleValue"];
    }
    public function get arenaRank() : int {
        return arenaInfo["curRank"];
    }
    public function get arenaEmbattle() : Array {
        return arenaInfo["embattle"];
    }
    public function get arenaHightestRank() : int {
        return arenaInfo["historyHighestRank"];
    }
    public function get arenaInfo() : Object {
        return _data["arenaInfo"]
    }

    public function get peakEmbattle() : Array {
        return peakInfo["embattle"];
    }
    public function get peakCurScor() : int {
        return peakInfo["curScore"];
    }
    public function get peakHightestScoreLevelID() : int {
        return peakInfo["historyHighScoreLevelID"];
    }
    public function get peakInfo() : Object {
        return _data[_peakInfo];
    }

    public function get impressionInfo() : Object {
        return _data[_impressionInfo];
    }
    public function get impressionTotalProperty() : Object {
        return impressionInfo["totalProperty"];
    }
    public function get impressionStarAddPercent() : Object {
        if (impressionInfo.hasOwnProperty("starAdd")) {
            return impressionInfo["starAdd"];
        }
        return {};
    }
    public function get impressionTotalLevel() : int {
        return impressionInfo["totalLevel"];
    }
    public function get impressionPower() : int {
        return impressionInfo["battleValue"];
    }

    public function get artifactInfo() : Object {
        return _data[_artifactInfo];
    }
    public function get artifactList() : Array {
        return artifactInfo["artifacts"];
    }
    public function get artifactPower() : int {
        return artifactInfo["battleValue"];
    }

    public static const _id : String = "id"; // playerUID
    public static const _name : String = "name";
    public static const _title : String = "title";
    public static const _headId : String = "headId";
    public static const _level : String = "level";
    public static const _VIPLevel : String = "VIPLevel";
    public static const _clubID:String = "clubID";
    public static const _clubName : String = "clubName";
    public static const _heroNum : String = "heroNum";
    public static const _battleValue : String = "battleValue";
    public static const _sign : String = "sign";
    public static const _heroInfo:String = "heroInfo";

     public static const _prototypeID : String = "prototypeID";

    // 神器
    public static const _artifactInfo:String = "artifactInfo"; // 神器
    // 斗魂
    public static const _talentInfo:String = "talentInfo"; // 斗魂
    public static const _peakInfo:String = "fairPeakInfo";

    // 好感度
    public static const _impressionInfo:String = "impressionInfo"; // 好感度


    public function get isSelf() : Boolean {
        return id == (rootData as CPlayerData).ID;
    }
    [Inline]
    public function get heroList() : CPlayerHeroListData { return getChild(0) as CPlayerHeroListData; }
    [Inline]
    public function get arenaHeroList() : CPlayerHeroListData { return getChild(1) as CPlayerHeroListData; }
    [Inline]
    public function get peakHeroList() : CPlayerHeroListData { return getChild(2) as CPlayerHeroListData; }
    [Inline]
    public function get impressionProperty() : CBasePropertyData { return getChild(3) as CBasePropertyData; }

}
}
