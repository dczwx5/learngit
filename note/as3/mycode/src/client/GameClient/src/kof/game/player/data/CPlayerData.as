//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/23.
 */
package kof.game.player.data {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.property.CBasePropertyData;
import kof.game.impression.util.CImpressionUtil;
import kof.game.player.data.property.CGlobalProperty;
import kof.game.player.data.subData.CCurrencyData;
import kof.game.player.data.subData.CGuildData;
import kof.game.player.data.subData.CMonthAndWeekCardData;
import kof.game.player.data.subData.CSubClubData;
import kof.game.player.data.subData.CSubPlatformData;
import kof.game.player.data.subData.CSubEquipData;
import kof.game.player.data.subData.CSubSkillData;
import kof.game.player.data.subData.CSubTaskData;
import kof.game.player.data.subData.CSubTutorData;
import kof.game.player.data.subData.CSystemData;
import kof.game.player.data.subData.CTeamData;
import kof.game.player.data.subData.CVipData;
import kof.game.player.data.subData.CVitData;
import kof.table.ModifyNameCost;
import kof.table.PlayerBasic;
import kof.table.PlayerConstant;
import kof.table.PlayerDisplay;
import kof.table.TeamLevel;

public class CPlayerData extends CPlayerBaseData {
    public function CPlayerData(system:IDatabase) {
        super();
        this.setToRootData(system);


        this.addChild(CPlayerHeroListData);
        this.addChild(CEmabattleDataManager);
        this.addChild(CCurrencyData);

        this.addChild(CGlobalPropertyData);
        this.addChild(CGlobalPropertyData);

        this.addChild(CVipHelper);
        this.addChild(CTeamData);
        this.addChild(CVipData);
        this.addChild(CSubSkillData);
        this.addChild(CSubEquipData);
        this.addChild(CMonthAndWeekCardData);
        this.addChild(CSystemData);
        this.addChild(CSubTutorData);
        this.addChild(CVitData);
        this.addChild(CSubTaskData);
        this.addChild(CGuildData);
        this.addChild(CGlobalPropertyData);
        this.addChild(CSubPlatformData);

        this.addChild(CPlayerVisitData);
        this.addChild(CSubClubData);

        this.addChild(CGlobalPropertyData);
        this.addChild(CGlobalPropertyData);
        this.addChild(CGlobalPropertyData);
        this.addChild(CGlobalPropertyData);

        _globalProperty = new CGlobalProperty();
        _globalProperty.databaseSystem = system;

    }

    public function initialHeroList(data:Object) : void {
        heroList.updateDataByData(data["heroList"]);
        heroList.reclacProperty(globalProperty, globalPercentProperty);
    }
    public override function updateDataByData(data:Object) : void {
        if (!data) return ;

        if (data.hasOwnProperty("playerMessage")) {
            var playerMessage:Object = data["playerMessage"];
            super.updateDataByData(playerMessage);

            // 天赋，神器，周卡月卡等全局属性
            var isGlobalPropertyChange:Boolean = false;
            var tempData:Object;
            var key:String;
            if (playerMessage.hasOwnProperty(CGlobalPropertyData._artifactProperty)) {
                tempData = playerMessage[CGlobalPropertyData._artifactProperty];
                artifactProprtyData.updateDataByData(tempData);
                for (key in tempData) {
                    isGlobalPropertyChange = true;
                    break;
                }
            }
            if (playerMessage.hasOwnProperty(CGlobalPropertyData._talentProperty)) {
                tempData = playerMessage[CGlobalPropertyData._talentProperty];
                talentPropertyData.updateDataByData(tempData);
                for (key in tempData) {
                    isGlobalPropertyChange = true;
                    break;
                }
            }

            if (playerMessage.hasOwnProperty(CGlobalPropertyData._cardProperty)) {
                tempData = playerMessage[CGlobalPropertyData._cardProperty];
                cardPropertyData.updateDataByData(tempData);
                for (key in tempData) {
                    isGlobalPropertyChange = true;
                    break;
                }
            }
            if (playerMessage.hasOwnProperty(CGlobalPropertyData._clubProperty)) {
                tempData = playerMessage[CGlobalPropertyData._clubProperty];
                clubPropertyData.updateDataByData(tempData);
                for (key in tempData) {
                    isGlobalPropertyChange = true;
                    break;
                }
            }
            if (playerMessage.hasOwnProperty(CGlobalPropertyData._effortProperty)) {
                tempData = playerMessage[CGlobalPropertyData._effortProperty];
                effortPropertyData.updateDataByData(tempData);
                for (key in tempData) {
                    isGlobalPropertyChange = true;
                    break;
                }
            }

            if (playerMessage.hasOwnProperty(CGlobalPropertyData._titleProperty)) {
                tempData = playerMessage[CGlobalPropertyData._titleProperty];
                titlePropertyData.updateDataByData(tempData);
                for (key in tempData) {
                    isGlobalPropertyChange = true;
                    break;
                }
            }

            if (playerMessage.hasOwnProperty(CGlobalPropertyData._gemProperty)) {
                tempData = playerMessage[CGlobalPropertyData._gemProperty];
                gemPropertyData.updateDataByData(tempData);
                for (key in tempData) {
                    isGlobalPropertyChange = true;
                    break;
                }
            }
            //单笔充值记录
            if (playerMessage.hasOwnProperty(CVipData._singleRecharge)) {
                tempData = playerMessage[CVipData._singleRecharge];
                vipData.updateDataByData(tempData);
            }
            //累计充值记录
            if (playerMessage.hasOwnProperty(CVipData._totalRecharge)) {
                tempData = playerMessage[CVipData._totalRecharge];
                vipData.updateDataByData(tempData);
            }
            if (isGlobalPropertyChange) {
                globalProperty.Set(artifactProprtyData);
                globalProperty.add(talentPropertyData);
                globalProperty.add(cardPropertyData);
                globalProperty.add(clubPropertyData);
                globalProperty.add(effortPropertyData); // 成就
                globalProperty.add(titlePropertyData); // 称号
                globalProperty.add(gemPropertyData); // 宝石

                heroList.reclacProperty(globalProperty, globalPercentProperty);
            }
        }

        if (data.hasOwnProperty(CEmabattleDataManager._embattleMessage)) {
            embattleManager.updateDataByData(data[CEmabattleDataManager._embattleMessage]);
        }

        this.setInitialized();
    }
    public function addHero(data:Object) : CPlayerHeroData {
        var heroData:CPlayerHeroData = heroList.addHeroData(data["heroList"]);
        if (heroData) {
            heroData.recalcProperty(globalProperty, globalPercentProperty);
            heroList.reclacProperty(globalProperty, globalPercentProperty);
        }

        var isInList:Boolean;
        for each(var info:CPlayerHeroData in _displayList)
        {
            if(info.prototypeID == heroData.prototypeID)
            {
                isInList = true;
                break;
            }
        }

        if(!isInList)
        {
            _displayList.push(heroData);
        }

        return heroData;
    }
    public function updateHero(data:Object) : CPlayerHeroData {
        var heroData:CPlayerHeroData =  heroList.updateHeroData(data["heroList"]);
        if (heroData) {
            if(data["heroList"].hasOwnProperty("star"))// 格斗家升星会导致全局属性变更
            {
                heroList.reclacProperty(globalProperty, globalPercentProperty);
            }
            else
            {
                heroData.recalcProperty(globalProperty, globalPercentProperty);
            }
        }

        return heroData;
    }

    public function addDailyQuestActiveRewards() : void {
        this.taskData.dailyQuestActiveRewards.push();
    }

    // 更新所有技能数据, 所有格斗家, 所有技能
    public function updateSkillListData(data:Object) : void {
        var dataObjectList:Array = data["dataObject"];
        for each (var dataObject:Object in dataObjectList) {
            var heroID:int = dataObject["ID"];
            var heroData:CPlayerHeroData = heroList.getHero(heroID);
            if (heroData) {
                heroData.updateSkillListData(dataObject);
            }
        }
    }

    // 更新单个格斗家, 单个技能数据
    public function updateSkillData(data:Object) : void {
        var dataObject:Object = data["dataObject"];
        var heroID:int = dataObject["ID"];
        var heroData:CPlayerHeroData = heroList.getHero(heroID);
        if (heroData) {
            heroData.updateSkillData(dataObject);
        }
    }
    // 添加技能数据
    public function addSkillData(data:Object) : void {
        var dataObjectList:Array = data["dataObject"];
        for each (var dataObject:Object in dataObjectList) {
            var heroID:int = dataObject["ID"];
            var heroData:CPlayerHeroData = heroList.getHero(heroID);
            if (heroData) {
                heroData.addSkillListData(dataObject);
            }
        }
    }

    public function updateRandomName(name:String) : void {
        _randomName = name;
    }

    public function updateVisitData(data:Object) : void {
        visitPlayerData.updateDataByData(data);
    }

    // ==============================extends==================================
    public function calcExpChange(curLevel:int, curExp:int) : int {
        var expChange:int;
        var isLevelUp:Boolean = curLevel > teamData.level;
        if (isLevelUp || curExp != teamData.exp) {
            if (isLevelUp) {
                expChange = curExp + (nextLevelExpCost - teamData.exp);
            } else {
                expChange = curExp - teamData.exp;
            }
        } else {
            expChange = 0;
        }

        return expChange;
    }
    public function getChangeNameCost() : int {
        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.MODIFY_NAME_COST);

        var count:int = teamData.firstModifyName+1;

        var list:Array = table.toArray();
        for (var i:int = 0; i < list.length; i++) {
            var record:ModifyNameCost = list[i];
            if (count >= record.countMin && (count <= record.countMax || record.countMax == -1)) {
                return record.cost;
            }
        }
        return 100;
    }
    public function get vitMax() : int {
        const pTable:TeamLevel = this.teamLevelTable;
        if (pTable)
            return pTable.VitMax;
        return 0;
    }
    // 根据等级获得战队等级表
    public function getTeamLevelTable(lv:int) : TeamLevel {
        var teamLevelTable:TeamLevel = teamLevelDatabase.findByPrimaryKey(lv);
        return teamLevelTable;
    }
    public function get nextLevelExpCost() : int {
        if(!teamLevelTable)
                return 0;
        return teamLevelTable.NextLevelUpExp;
    }
    public function get teamLevelTable() : TeamLevel {
        if (_lastTeamLevelTable && _lastTeamLevelTable.ID == teamData.level) {
            return _lastTeamLevelTable;
        }
        _lastTeamLevelTable = teamLevelDatabase.findByPrimaryKey(teamData.level);
        return _lastTeamLevelTable;
    }
    public function get maxTeamLevel():int
    {
        var arr:Array = teamLevelDatabase.toArray();
        if(arr && arr.length)
        {
            var len:int = arr.length;
            return (arr[len - 1] as TeamLevel).Level;
        }

        return 0;
    }
    // ==========================================================
    public function get skillTable() : IDataTable {
        if (null == _pSkillTable) _pSkillTable = this._databaseSystem.getTable(KOFTableConstants.SKILL);
        return _pSkillTable;
    }
    public function get playerBasicTable() : IDataTable {
        if (null == _playerBasicTable) _playerBasicTable = this._databaseSystem.getTable(KOFTableConstants.PLAYER_BASIC);
        return _playerBasicTable;
    }
    public function get playerDisplayTable() : IDataTable {
        if (null == _playerDisplayTable) _playerDisplayTable = this._databaseSystem.getTable(KOFTableConstants.PLAYER_DISPLAY);
        return _playerDisplayTable;
    }

    public function get teamLevelDatabase() : IDataTable {
        if (null == _teamLevelDatabase) _teamLevelDatabase = this._databaseSystem.getTable(KOFTableConstants.TEAM_LEVEL);
        return _teamLevelDatabase;
    }
    public function get playerConstant() : PlayerConstant {
        if (_playerConstant == null) _playerConstant = _databaseSystem.getTable(KOFTableConstants.PLAYER_CONSTANT).toVector()[0] as PlayerConstant;
        return _playerConstant;
    }
    public function get displayList() : Array {
        if (_displayList == null) {
            _displayList = new Array();
            var allList:Vector.<Object> = playerBasicTable.toVector();
            var display:PlayerDisplay;
            var heroData:CPlayerHeroData;
            for each (var player:PlayerBasic in allList) {
                display = playerDisplayTable.findByPrimaryKey(player.ID);
                if (display && _isHeroDisplay(display) && player.ID < 1000) {
                    heroData = heroList.getHero(player.ID);
                    heroData.playerBasic = player;
                    heroData.playerDisplayRecord = display;
                    _displayList.push(heroData);
                }
            }
        }
        return _displayList;
    }

    /**
     * 新增活动推送的格斗家
     */
    public function updateActivityAddHero():void
    {
        if(activityHeroIds && _displayList)
        {
            for each(var heroId:String in activityHeroIds)
            {
                var id:int = int(heroId);
                if(!_isHeroExist(id))
                {
                    var heroData:CPlayerHeroData;
                    heroData = heroList.getHero(id);
                    heroData.playerBasic = playerBasicTable.findByPrimaryKey(id) as PlayerBasic;
                    heroData.playerDisplayRecord = playerDisplayTable.findByPrimaryKey(id) as PlayerDisplay;
                    _displayList.push(heroData);
                }
            }
        }
    }

    private function _isHeroExist(heroId:int):Boolean
    {
        if(_displayList)
        {
            for each(var heroData:CPlayerHeroData in _displayList)
            {
                if(heroData && heroData.prototypeID == heroId)
                {
                    return true;
                }
            }
        }

        return false;
    }

    public function _isHeroDisplay(display:PlayerDisplay):Boolean
    {
        var heroId:String = display.ID + "";
        if(display.IsShow > 0 || _activityHeroIds.indexOf(heroId) != -1 || heroList.hasHero(display.ID))
        {
            return true;
        }

        return false;
    }

    public function get heroList() : CPlayerHeroListData {
        return this.getChild(0) as CPlayerHeroListData;
    }
    public function get embattleManager() : CEmabattleDataManager {
        return this.getChild(1) as CEmabattleDataManager;
    }
    final public function get currency() : CCurrencyData {
        return this.getChild(2) as CCurrencyData;
    }
    public function get artifactProprtyData() : CGlobalPropertyData { return this.getChild(3) as CGlobalPropertyData; } // 神器
    public function get talentPropertyData() : CGlobalPropertyData { return this.getChild(4) as CGlobalPropertyData; } // 天赋
    public function get vipHelper() : CVipHelper { return this.getChild(5) as CVipHelper; } // vipHelper
    public function get teamData() : CTeamData { return this.getChild(6) as CTeamData; }
    public function get vipData() : CVipData { return this.getChild(7) as CVipData; }
    public function get skillData() : CSubSkillData { return this.getChild(8) as CSubSkillData; }
    public function get equipData() : CSubEquipData { return this.getChild(9) as CSubEquipData; }
    public function get monthAndWeekCardData() : CMonthAndWeekCardData { return this.getChild(10) as CMonthAndWeekCardData; }
    public function get systemData() : CSystemData { return this.getChild(11) as CSystemData; }
    public function get tutorData() : CSubTutorData { return this.getChild(12) as CSubTutorData; }
    public function get vitData() : CVitData { return this.getChild(13) as CVitData; }
    public function get taskData() : CSubTaskData { return this.getChild(14) as CSubTaskData; }
    public function get guideData() : CGuildData { return this.getChild(15) as CGuildData; }
    public function get cardPropertyData() : CGlobalPropertyData { return this.getChild(16) as CGlobalPropertyData; } // 周卡月卡
    public function get platformData() : CSubPlatformData { return this.getChild(17) as CSubPlatformData; } // 平台数据
    public function get visitPlayerData() : CPlayerVisitData { return this.getChild(18) as CPlayerVisitData; } // 查看玩家数据, 自己的也是一样
    public function get clubData() : CSubClubData { return this.getChild(19) as CSubClubData; } // 俱乐部数据

    public function get clubPropertyData() : CGlobalPropertyData { return this.getChild(20) as CGlobalPropertyData; } // 公会全局属性
    public function get effortPropertyData() : CGlobalPropertyData { return this.getChild(21) as CGlobalPropertyData; } // 成就系统全局属性
    public function get titlePropertyData() : CGlobalPropertyData { return this.getChild(22) as CGlobalPropertyData; } // 成就系统全局属性
    public function get gemPropertyData() : CGlobalPropertyData { return this.getChild(23) as CGlobalPropertyData; } // 宝石系统全局属性

    // 神器等属性总和
    [Inline]
    public function get globalProperty() : CGlobalProperty {
        return _globalProperty;
    }
    private var _globalProperty:CGlobalProperty;

    private var _globalPercentProperty:CBasePropertyData;
    // 羁绊等加的全局百分比属性
    public function get globalPercentProperty():CBasePropertyData
    {
        _globalPercentProperty = CImpressionUtil.getImpressionStarAttr();
        return _globalPercentProperty;
    }

    public function get randomName() : String {
        return _randomName;
    }
    private var _randomName:String;
    private var _teamLevelDatabase:IDataTable; // 战队等级对应属性
    private var _lastTeamLevelTable:TeamLevel; // buffer,  call lastTeamLevelTable instead of _lastTeamLevelTable
    private var _playerConstant:PlayerConstant;
    private var _playerBasicTable:IDataTable;
    private var _playerDisplayTable:IDataTable;
    private var _pSkillTable:IDataTable;

    private var _displayList:Array; // 已经过滤掉固定不显示列表的格斗家列表. CPlayerHeroData


    // extends
    private var _lastTotalExp:int; // 最后的下级升级需要经验
    public function get lastTotalExp() : int {
        return _lastTotalExp;
    }
    public function set lastTotalExp(value : int) : void {
        _lastTotalExp = value;
    }
    private var _lastExp:int; // 记录最后的经验
    public function get lastExp() : int {
        return _lastExp;
    }
    public function set lastExp(value : int) : void {
        _lastExp = value;
    }
    private var _lastLevel:int; // 记录上一次的level
    public function get lastLevel() : int {
        return _lastLevel;
    }
    public function set lastLevel(value : int) : void {
        _lastLevel = value;
    }
    private var _lastExpChange:int; // 记录最后一次exp改变值
    public function get lastExpChange() : int {
        return _lastExpChange;
    }
    public function set lastExpChange(value : int) : void {
        _lastExpChange = value;
    }

    public var isLevelUp:Boolean; // 是否升级了, 关闭升级界面后设为false

    private var _activityHeroIds:Array = [];// 活动投放的格斗家ID
    public function set activityHeroIds(value:Array):void
    {
        _activityHeroIds = value;
    }

    // 活动投放的格斗家
    public function get activityHeroIds():Array
    {
        return _activityHeroIds;
    }

// private var _databaseSystem:CDatabaseSystem;
}
}
