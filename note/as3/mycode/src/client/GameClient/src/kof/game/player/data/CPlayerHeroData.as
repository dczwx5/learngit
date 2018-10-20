//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2016/9/24.
 */
package kof.game.player.data {

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.character.property.CBasePropertyData;
import kof.game.impression.util.CImpressionUtil;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.data.property.CGlobalProperty;
import kof.game.player.data.property.CPlayerHeroProperty;
import kof.game.player.data.property.CPlayerHeroPropertyCale;
import kof.game.player.enum.EHeroIntelligence;
import kof.table.PlayerBasic;
import kof.table.PlayerDisplay;
import kof.table.PlayerLevelConsume;
import kof.table.PlayerLines;
import kof.table.PlayerQuality;
import kof.table.PlayerQualityConsume;
import kof.table.PlayerSkill;
import kof.table.PlayerStarConsume;
import kof.table.Skill;
import kof.util.CQualityColor;

public class CPlayerHeroData extends CObjectData {
    public function CPlayerHeroData() {
        this.addChild(CHeroEquipListData);
        this.addChild(CSkillListData);
        _propertyData = new CHeroPropertyData();
        _propertyData.databaseSystem = this._databaseSystem;
        _calcProperty = new CPlayerHeroPropertyCale(this);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (data.hasOwnProperty("fightProperty")) {
            _propertyData.updateDataByData(data["fightProperty"]);
        }
        if (data.hasOwnProperty("equipList")) equipList.updateDataByData(data["equipList"]);

    }
    public function recalcProperty(globalProperty:CGlobalProperty, globalPercentProperty:CBasePropertyData) : void {
        propertyData.recalcProperty(globalProperty,globalPercentProperty);
    }
    public function updateEquip(data:Object) : CHeroEquipData {
        return equipList.updateItemData(data["equipMap"]) as CHeroEquipData;
    }
    public function updateSkillListData(data:Object) : void {
        skillList.resetChild(); // 技能只加不减, 可以不要resetChild
        skillList.updateDataByData(data["skillInfo"]);
    }
    public function addSkillListData(data:Object) : void {
        skillList.updateDataByData(data["skillInfo"]);
    }
    public function updateSkillData(data:Object) : void {
        skillList.updateDataByData(data);
    }

    public function compareWith(otherHero:CPlayerHeroData) : int {
//        // 剧情副本出战编制、资质、星级、等级、战力、id
//        var v1:int = _getEmbattleSortValue(this);
//        var v2:int = _getEmbattleSortValue(otherHero);
//        if(v1 != v2)
//        {
//            return v2 - v1;
//        }

        if (qualityBase != otherHero.qualityBase) {
            return otherHero.qualityBase - qualityBase;
        }

        if (star != otherHero.star) {
            return otherHero.star - star;
        }
        // 不按品质排
//        if (quality != otherHero.quality) {
//            return otherHero.quality - quality;
//        }

//        if (level != otherHero.level) {
//            return otherHero.level - level;
//        }
        if (battleValue != otherHero.battleValue) {
            return otherHero.battleValue - battleValue;
        }
        return playerDisplayRecord.SortID - otherHero.playerDisplayRecord.SortID;
    }

    // 根据阵型排序
    private function _getEmbattleSortValue(v1:CPlayerHeroData) : int {
        var embattleList:CEmbattleListData = (_rootData as CPlayerData).embattleManager.getByType(EInstanceType.TYPE_MAIN);
        if (embattleList && embattleList.list && embattleList.list.length > 0) {
            var posEm1:int = embattleList.getPosByHero(v1.prototypeID);
            if(posEm1 != -1) return 1;
        }
        return 0;
    }

    //计算玩家可以升至多少级
    public function getCanLevelUpValue(expValue:Number):int
    {
        var levelConsumeTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = (_databaseSystem as CAppSystem).stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        levelConsumeTable = pDatabaseSystem.getTable( KOFTableConstants.HERO_TRAIN_LEVEL ) as CDataTable;
        var levelConsume:PlayerLevelConsume;
        var lvExp:Number = 0;
        if(this.level<MAX_LEVEL)
        {
            for(var i:int=this.level;i<=MAX_LEVEL;i++)
            {
                levelConsume = levelConsumeTable.findByPrimaryKey(i);
                lvExp += levelConsume.consumEXP;
                if(i==MAX_LEVEL)
                {
                    if(expValue>=lvExp)
                    {
                        return MAX_LEVEL;
                    }
                    else
                    {
                        return MAX_LEVEL-1;
                    }
                }
                if(expValue<lvExp)
                {
                    return levelConsume.playerLevel;
                }
            }
        }
        return MAX_LEVEL;
    }
    public function get currentPieceCount() : int {
        var item:CBagData = ((_databaseSystem as CAppSystem).stage.getSystem(CBagSystem).getBean(CBagManager) as CBagManager).getBagItemByUid(this.pieceID);
        if (item) return item.num;
        return 0;
    }

    // =====================================升星

    public function get nextStarPieceCost() : int {
        var star:int = this.star;
        var nextStar:int = star; // +1;
        if (nextStar > MAX_STAR_LEVEL) {
            return 0;
        }
        var consumeData:PlayerStarConsume = getStarConsume(nextStar);
        return consumeData.pieceNum;
    }

    public function getStarConsume(star:int) : PlayerStarConsume {
        if (star > MAX_STAR_LEVEL) {
            return null;
        }
        var starList:Vector.<Object> = heroStarTable.toVector();
        for each (var starData:PlayerStarConsume in starList) {
            if (starData.playerstar == star && qualityBase >= starData.qualityLower && qualityBase <= starData.qualityLimit) {
                return starData;
            }
        }
        return null;
    }

    // =================================升品

    public function get nextQualityConsume() : PlayerQualityConsume {
        return getQualityConsume(this.quality); // +1);
    }
    public function getQualityConsume(quality:int) : PlayerQualityConsume {
        var qualityList:Vector.<Object> = heroQualityTable.toVector();
        for each (var data:PlayerQualityConsume in qualityList) {
            if (data.quality == quality && qualityBase >= data.qualityLower && qualityBase <= data.qualityLimit && data.profession == playerBasic.Profession) {
                return data;
            }
        }
        return null;
    }
    // 根据当前quality等级, 获得品质表数据
    public function getQualityLevel(quality:int) : PlayerQuality {
        var qualityLevel:PlayerQuality = heroQualityLevelTable.findByPrimaryKey(quality);
        return qualityLevel;
    }
    // 当前品质表数据
    public function get qualityLevel() : PlayerQuality {
        return getQualityLevel(this.quality);
    }
    // 当前品质级别, 0-6, 白绿蓝...
    public function get qualityLevelValue() : int {
        var temp:PlayerQuality = qualityLevel;
        if (!temp) return 0;
        return int(temp.qualityColour);
    }
    //  当前品质 + X
    public function get qualityLevelSubValue() : int {
        var qualityList:Vector.<Object> = heroQualityLevelTable.toVector();
        var firstSameLevelQuality:PlayerQuality;
        for (var i:int = 0; i < qualityList.length; i++) {
            var tempQuality:PlayerQuality = (qualityList[i] as PlayerQuality);
            if (int(tempQuality.qualityColour) == qualityLevelValue) {
                if (firstSameLevelQuality == null) {
                    firstSameLevelQuality = tempQuality;
                } else {
                    if (firstSameLevelQuality.ID > tempQuality.ID) {
                        firstSameLevelQuality = tempQuality;
                    }
                }
            }
        }
        var firstQuality:int = firstSameLevelQuality.ID;
        var subValue:int = this.quality - firstQuality;
        return subValue;
    }

    // =================================升级
    public function get nextLevelConsume() : PlayerLevelConsume {
        return getLevelConsume(level); // +1);
    }
    public function getLevelConsume(level:int) : PlayerLevelConsume {
        var levelList:Vector.<Object> = heroLevelTable.toVector();
        for each (var data:PlayerLevelConsume in levelList) {
            if (data.playerLevel == level && qualityBase >= data.qualityLower && qualityBase <= data.qualityLimit) {
                return data;
            }
        }
        return null;
    }

    // =================================羁绊(亲密度)

    /**
     * 是否道具足以进行亲密度提升
     */
    public function get isCanImpressionUpgrade():Boolean
    {
        if(hasData)
        {
            return CImpressionUtil.isHeroCanUpgrade(prototypeID);
        }

        return false;
    }

    /**
     * 羁绊中格斗家是否已开放
     */
    public function get isHeroOpened():Boolean
    {
        return CImpressionUtil.isHeroOpened(prototypeID);
    }

    // ==================================================calc property===================================
    // 以下属性只能算出格斗家基本属性, 升级，长品，升星后的属性，不包括任务其他系统的属性
    public function specialLevelProperty(lv:int) : CPlayerHeroProperty {
        return _calcProperty.calcSpecialLevelProperty(lv) as CPlayerHeroProperty;
    }
    public function get nextLevelProperty() : CPlayerHeroProperty {
        return _calcProperty.calcNextLevelProperty() as CPlayerHeroProperty;
    }
    public function get nextQualityProperty() : CPlayerHeroProperty {
        return _calcProperty.calcNextQualityProperty() as CPlayerHeroProperty;
    }
    public function get nextAwakenProperty() : CPlayerHeroProperty {
        return _calcProperty.calcNextStarProperty() as CPlayerHeroProperty;
    }
    public function get currentProperty():CPlayerHeroProperty{
        return _calcProperty.calcProperty() as CPlayerHeroProperty;
    }

    public function get equipList() : CHeroEquipListData { return this.getChild(0) as CHeroEquipListData; }
    public function get skillList() : CSkillListData { return this.getChild(1) as CSkillListData; }

    [Inline]
    public function get propertyData() : CHeroPropertyData { return _propertyData; } // 总属性 , 重新计算总属性的情况 1 : 格斗家自身属性改变时, 2 : 神器，天赋属性改变时, 在playerData更新所有格斗家的属性

    // 没有技能数据的情况下, 或得大招的技能数据,
    public function getSuperSkillRecordInTable() : Skill {
        return _databaseSystem.getTable(KOFTableConstants.SKILL).findByPrimaryKey(skillRecord.SkillID[5]);
    }

    // ====================get

    public function get ID() : int { return _data[_ID]; } // uniID
    public function get prototypeID() : int { return _data[_prototypeID]; } // heroID
    public function get level() : int { return _data[_level]; }
    public function set level(value:int) : void { _data[_level] = value; }
    public function get exp() : int { return _data[_exp]; }
    public function get battleValueBase() : Number { return _data["battleValue"] ? _data["battleValue"] : 0; } // 服务器下发的战斗力
    public function get star() : Number { if (_data.hasOwnProperty(_star)) {
        return _data[_star];
    } else {
        return 0;
    } }
    public function set star(v:Number) : void {
        _data[_star] = v;
    }
    public function get quality() : Number { return _data[_quality] ? _data[_quality] : 0; } // 品质
    public function set quality(v:Number) : void {
        _data[_quality] = v;
    }
    public function get impressionLevel() : Number { return _data[_impressionLevel] ? _data[_impressionLevel] : 0; } // 亲密度等级
    public function get impressionExp() : Number { return _data[_impressionExp] ? _data[_impressionExp] : 0; } // 亲密度进度
    public function get impressionTalk() : Boolean { return _data[_impressionTalk]; } // 亲密度培养剧情对话
    public function get impressionTask() : Object { return _data[_impressionTask]; } // 羁绊任务信息

    public function setTrainData(iLevel:int = -1, iStar:int = -1, iQuality:int = -1) : void {
        if (iLevel != -1) {
            _data[_level] = iLevel;
        }
        if (iStar != -1) {
            _data[_star] = iStar;
        }
        if (iQuality != -1) {
            _data[_quality] = iQuality;
        }
    }
    public function setHp(v:int) : void {
        propertyData.HP = v;
    }
    public function setMaxHp(v:int) : void {
        propertyData.MaxHP = v;
    }

    private var _propertyData:CHeroPropertyData;

    public function get battleValue() : int {
        // 按属性计算战力
        _propertyData.databaseSystem = this._databaseSystem;
        return _propertyData.getBattleValue();
    }

    public static const _ID:String = "ID";
    public static const _prototypeID:String = "prototypeID";
    public static const _level:String = "level";
    public static const _exp:String = "exp";
    public static const _star:String = "star";
    public static const _quality:String = "quality";
    public static const _impressionLevel:String = "impressionLevel";
    public static const _impressionExp:String = "impressionExp";
    public static const _impressionTalk:String = "impressionTalk";
    public static const _impressionTask:String = "impressionTask";


//    public static const HIRE_PIECE_COUNT:int = 50;
    public static const MAX_LEVEL:int = 150;
    public static const MAX_QUALITY_LEVEL:int = 31;
    public static const MAX_STAR_LEVEL:int = 7;

    public function get qualityBase() : int { return playerBasic.intelligence; } // 资质
    public function get qualityBaseType() : int {
        var value:int = qualityBase;

        switch (value) {
            case EHeroIntelligence.C:
                return 0;
            case EHeroIntelligence.B:
            case EHeroIntelligence.BPlus:
                return 1;
            case EHeroIntelligence.A:
            case EHeroIntelligence.APlus:
                return 2;
            case EHeroIntelligence.S:
                return 3;
            case EHeroIntelligence.SS:
                return 4;
            case EHeroIntelligence.SSS:
                return 5;
            default:
                return 0;
        }
//        switch (value)
//        {
//            case EHeroIntelligence.C:
//                return 0;
//            case EHeroIntelligence.B:
//                return 1;
//            case EHeroIntelligence.BPlus:
//                return 2;
//            case EHeroIntelligence.A:
//                return 3;
//            case EHeroIntelligence.APlus:
//                return 4;
//            case EHeroIntelligence.S:
//                return 5;
//            case EHeroIntelligence.SS:
//                return 6;
//            case EHeroIntelligence.SSS:
//                return 7;
//            default:
//                return 0;
//        }

        return 0;

    }
    public function get job() : int { return playerBasic.Profession; } // 攻防技 - 012

    // 是否需要显示
    public function get isShow() : Boolean { return this.playerDisplayRecord.IsShow > 0; }
    public function get initialStar() : int {  return playerDisplayRecord.InitialStar; }
    public function get hireNeedPieceCount():int { return playerDisplayRecord.HirePieceNum; }
    public function get enoughToHire() : Boolean { return currentPieceCount >= this.hireNeedPieceCount; }
    public function get pieceRate() : Number { return currentPieceCount/hireNeedPieceCount; }
    public function get pieceID() : int { return playerDisplayRecord.PieceID; }
    public function get heroName() : String { if (lineTable) return lineTable.PlayerName; else return ""; }
    public function get heroNameWithColor() : String { return "<font color='" + CQualityColor.QUALITY_COLOR_ARY[qualityLevelValue] + "'>" + heroName + "</font>"; }
    public function get strokeColor() : String { return CQualityColor.QUALITY_COLOR_STROKE_ARY[qualityLevelValue]; }
    public function get hasData() : Boolean { return ID > 0; }

    // public function get pieceID() : int { return playerBasic.heropieceid; } // 碎片ID
    public function get playerBasic() : PlayerBasic {
        if (_playerBasic == null) _playerBasic = _databaseSystem.getTable(KOFTableConstants.PLAYER_BASIC).findByPrimaryKey(this.prototypeID);
        return _playerBasic;
    }
    public function set playerBasic(v:PlayerBasic) : void { _playerBasic = v; }

    public function get playerDisplayRecord() : PlayerDisplay {
        if (_playerDisplayRecord == null) _playerDisplayRecord = _databaseSystem.getTable(KOFTableConstants.PLAYER_DISPLAY).findByPrimaryKey(this.prototypeID);
        return _playerDisplayRecord;
    }
    public function set playerDisplayRecord(v:PlayerDisplay) : void { _playerDisplayRecord = v; }
    public function get heroStarTable() : IDataTable {
        if (_heroStarTable == null) _heroStarTable = _databaseSystem.getTable(KOFTableConstants.HERO_TRAIN_STAR);
        return _heroStarTable;
    }
    public function get heroQualityTable() : IDataTable {
        if (_heroQualityTable == null) _heroQualityTable = _databaseSystem.getTable(KOFTableConstants.HERO_TRAIN_QUALITY);
        return _heroQualityTable;
    }
    public function get heroQualityLevelTable() : IDataTable {
        if (_heroQualityLevelTable == null) _heroQualityLevelTable = _databaseSystem.getTable(KOFTableConstants.HERO_TRAIN_QUALITY_LEVEL);
        return _heroQualityLevelTable;
    }
    public function get heroLevelTable() : IDataTable {
        if (_heroLevelTable == null) _heroLevelTable = _databaseSystem.getTable(KOFTableConstants.HERO_TRAIN_LEVEL);
        return _heroLevelTable;
    }
    public function get lineTable() : PlayerLines {
        if (_linesRecord == null) _linesRecord = _databaseSystem.getTable(KOFTableConstants.PLAYER_LINES).findByPrimaryKey(prototypeID);
        return _linesRecord;
    }
    public function get skillRecord() : PlayerSkill {
        if (_skillRecord == null) _skillRecord = _databaseSystem.getTable(KOFTableConstants.PLAYER_SKILL).findByPrimaryKey(prototypeID);
        return _skillRecord;
    }

    private var _playerBasic:PlayerBasic;
    private var _playerDisplayRecord:PlayerDisplay;
    private var _heroStarTable:IDataTable;
    private var _heroQualityTable:IDataTable;
    private var _heroQualityLevelTable:IDataTable; // quality->quality等级, 白绿蓝....
    private var _heroLevelTable:IDataTable;
    private var _linesRecord:PlayerLines;
    private var _skillRecord:PlayerSkill;

    // component
    private var _calcProperty:CPlayerHeroPropertyCale;

    public var embattlePosition:int;
    public static const REBORN_LEVEL:int = 3;
}
}
