//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/17.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.table.ClimbTowerBase;
import kof.table.ClimbTowerInfo;
import kof.table.RobotPlayer;

public class CCultivateLevelData extends CObjectData {
    public function CCultivateLevelData() {
        this.addChild(CCultivateLevelDefenderListData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty("defenders")) {
            defenderList.resetChild();
            defenderList.updateDataByData(defenders);
        }
    }

    public function get sectionID() : int { return 1 + (layer-1)/3; }
    public function get layer() : int { return _data[_layer]; } // 副本序号 1-15
    public function get name() : String { return _data["name"]; } // 敌人战队名
    public function get passed() : int { return _data["passed"]; } // 0没过关, 1过关
    public function get defenders():Array { return _data["defenders"]; }
    public function get robotPlayerID() : int { return _data["robotPlayerID"]; } // 机器人ID
    public function get level() : int { return _data["level"]; }

    public static const _layer:String = "layer";

    public function get sectionRecord() : ClimbTowerBase {
        if (!_sectionRecord) {
            var dataTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.CULTIVATE_BASE);
            var allData:Vector.<Object> = dataTable.toVector();
            for each (var record:ClimbTowerBase in allData) {
                if (record.layer  == layer && level >= record.minlevel && level <= record.maxLevel) {
                    _sectionRecord = record;
                    break;
                }
            }
        }
        return _sectionRecord;
    }

    public function get descRecord() : ClimbTowerInfo {
        if (!_descRecord) {
            var dataTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.CULTIVATE_DESC);
            _descRecord = dataTable.findByPrimaryKey(layer);
        }
        return _descRecord;
    }

    public function get isLastLevel() : Boolean {
        return layer == 15;
    }
    public function get reward() : int {
        if (sectionRecord) {
            return sectionRecord.DropID;
        } else {
            return 0;
        }
    }

    public function get enemyPower() : int {
        return defenderList.battleValue;
    }
    public function get robotRecord() : RobotPlayer {
        if (!_robotRecord) {
            _robotRecord = _databaseSystem.getTable(KOFTableConstants.RobotPlayer ).findByPrimaryKey(robotPlayerID) as RobotPlayer;
        }
        return _robotRecord;
    }

    public function getHeroListData() : Array {
        if (_heroListData) return _heroListData;
        _heroListData = new Array();

        var mList:Array = defenderList.list;

        var pRobot:RobotPlayer = robotRecord;
        var defenderData:CCultivateLevelDefenderData;
        for (var i:int = 0; i < mList.length; i++) {
            defenderData = mList[i] as CCultivateLevelDefenderData;
            var heroID:int = defenderData.profession;
            var level:int = pRobot.heroLevel;
            var star:int = pRobot.heroStar;
            var quality:int = pRobot.heroQuality;

            var heroData:CPlayerHeroData = ((_databaseSystem as CAppSystem).stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.createHero(heroID);
            heroData.setTrainData(level, star, quality);
            _heroListData.push(heroData);
        }

        return _heroListData;
    }
    private var _heroListData:Array;

    public function get defenderList() : CCultivateLevelDefenderListData {
         return this.getChild(0) as CCultivateLevelDefenderListData;
    }
    private var _sectionRecord:ClimbTowerBase;
    private var _robotRecord:RobotPlayer;

    private var _descRecord:ClimbTowerInfo;

}
}
