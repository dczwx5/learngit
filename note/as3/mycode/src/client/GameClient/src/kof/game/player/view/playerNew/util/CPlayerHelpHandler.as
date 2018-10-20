//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/16.
 */
package kof.game.player.view.playerNew.util {

import QFLib.Utils.HtmlUtil;

import flash.utils.Dictionary;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.enum.EItemType;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.view.playerNew.data.CHeroAttrData;
import kof.game.player.view.playerNew.data.CLevelResultData;
import kof.game.player.view.playerNew.data.CQualityResultData;
import kof.game.player.view.playerNew.data.CStarResultData;
import kof.game.player.view.playerNew.data.CTabInfoData;
import kof.game.player.view.playerNew.panel.CEquipDevelopPanel;
import kof.game.player.view.playerNew.panel.CHeroDevelopPanel;
import kof.game.player.view.playerNew.panel.CSkillDevelopPanel;
import kof.game.player.view.playerNew.panel.CSkillVideoPanel;
import kof.game.switching.CSwitchingSystem;
import kof.table.BundleEnable;
import kof.table.Item;
import kof.table.PlayerLevelConsume;
import kof.table.PlayerLines;
import kof.table.PlayerQuality;
import kof.table.PlayerQualityConsume;
import kof.table.PlayerSkill;
import kof.table.PlayerStarConsume;
import kof.util.CQualityColor;

public class CPlayerHelpHandler extends CAbstractHandler {

    private var _currSelPanelIndex:int;
    private var m_listHeros:Array;
    private var m_pQualResultData:CQualityResultData;
    private var m_pStarResultData:CStarResultData;
    private var m_pLevelResultData:CLevelResultData;
    private var m_listEmbattleId:Array;

    public function CPlayerHelpHandler()
    {
        super();
    }

    public function getTabNameByIndex(tab:int) : String {
        if (0 == tab) {
            return "HeroDevelop";
        } else if (1 == tab) {
            return "EquipDevelop";
        } else {
            return "SkillDevelop";
        }
    }

    public function getTabInfoData() : Vector.<CTabInfoData>
    {
        var tabDataVec : Vector.<CTabInfoData> = new Vector.<CTabInfoData>();
        var pageTabData : Array = [
            {"label" : "格斗家养成", "name" : "HeroDevelop", "sysTag":KOFSysTags.ROLE},
            {"label" : "装备培养", "name" : "EquipDevelop", "sysTag":KOFSysTags.EQP_STRONG},
            {"label" : "体能提升", "name" : "SkillDevelop", "sysTag":KOFSysTags.SKIL_LEVELUP} ];

        for ( var i : int = 0; i < pageTabData.length; i++ )
        {
            var tabInfoData : CTabInfoData = new CTabInfoData();
            tabInfoData.tabIndex = i;
            tabInfoData.tabNameCN = pageTabData[ i ].label;
            tabInfoData.tabNameEN = pageTabData[ i ].name;
            tabInfoData.panelClass = getPanelClassByTabIndex( i );
            tabInfoData.sysTag = pageTabData[i ].sysTag;
            tabInfoData.openLevel  = getSystemOpenLevel(tabInfoData.sysTag);

//            var playerLevel:int = getPlayerLevel();
//            if (playerLevel >= tabInfoData.openLevel)
//            {
//                tabDataVec.push( tabInfoData );
//            }

            if(isChildSystemOpen(tabInfoData.sysTag))
            {
                tabDataVec.push( tabInfoData );
            }
        }

        return tabDataVec;
    }

    public function getPlayerLevel() : int
    {
        return (system as CPlayerSystem).playerData.teamData.level;
    }

    private function getPanelClassByTabIndex(tabIndex:int):Class
    {
        var cls:Class;
        switch(tabIndex)
        {
            case CPlayerConst.Panel_Index_HeroDevelop:
                cls = CHeroDevelopPanel;
                break;
            case CPlayerConst.Panel_Index_EquipDevelop:
                cls = CEquipDevelopPanel;
                break;
            case CPlayerConst.Panel_Index_SkillDevelop:
                cls = CSkillDevelopPanel;
                break;
        }

        return cls;
    }
    private function getSkillVideoPanelClass():Class{
        return CSkillVideoPanel;
    }

    public function getSystemOpenLevel(sysTag:String):int
    {
        if(sysTag)
        {
            var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
            var sysIdTable : IDataTable = pDatabase.getTable( KOFTableConstants.BUNDLE_ENABLE );
            var theFindResult : Array = sysIdTable.findByProperty( "TagID", sysTag );

            if ( theFindResult && theFindResult.length )
            {
                var bundleEnable : BundleEnable = theFindResult[ 0 ] as BundleEnable;
                return bundleEnable.MinLevel;
            }
        }

        return 0;
    }

// 小红点提示条件======================================================================================================
    public function isHeroCanDevelop(heroData:CPlayerHeroData):Boolean
    {
        if(heroData && heroData.hasData)
        {
//            return isHeroCanQualityAdvance(heroData) || isHeroCanLevelUp(heroData) || isHeroCanStarAdvance(heroData);
            return isHeroCanQualityAdvance(heroData) || isHeroCanStarAdvance(heroData);
        }

        return false;
    }

    /**
     * 是否能品质进阶
     * @return
     */
    public function isHeroCanQualityAdvance(heroData:CPlayerHeroData):Boolean
    {
        if(!heroData.hasData)
        {
            return false;
        }

        if (heroData.quality >= CPlayerHeroData.MAX_QUALITY_LEVEL)// 满阶
        {
            return false;
        }
        else
        {
            // 升下一品质消耗
            var nextQualityCostTable:PlayerQualityConsume = heroData.nextQualityConsume;
            var teamLevel:int = getPlayerLevel();
            if(nextQualityCostTable)
            {
                if(teamLevel < nextQualityCostTable.teamLevel)
                {
                    return false;
                }

                var playerData:CPlayerData = (system as CPlayerSystem).playerData;
                var ownGold:Number = playerData.currency.gold;
                if(ownGold < nextQualityCostTable.consumGold)
                {
                    return false;
                }

                for(var i:int = 1; i <= 4; i++)
                {
                    var itemId : int = nextQualityCostTable["consumItemID" + i];
                    var bagData : CBagData = _bagManager.getBagItemByUid( itemId ); // item1, 当前拥有
                    var bagNum:int = bagData == null ? 0 : bagData.num;
                    if ( bagNum < nextQualityCostTable[ "numItemID" + (i) ] )
                    {
                        return false;
                    }
                }
            }
        }

        return true;
    }

    /**
     * 能否升星
     * @param heroData
     * @return
     */
    public function isHeroCanStarAdvance(heroData:CPlayerHeroData):Boolean
    {
        if(!heroData.hasData)
        {
            return false;
        }

        if(heroData.star >= CPlayerHeroData.MAX_STAR_LEVEL)//满星
        {
            return false;
        }
        else
        {
            var playerStarConsume:PlayerStarConsume = heroData.getStarConsume(heroData.star);
            var teamLevel:int = getPlayerLevel();
            if(playerStarConsume)
            {
                if ( teamLevel < playerStarConsume.teamLevel )
                {
                    return false;
                }
            }
        }

        var bagData : CBagData = _bagManager.getBagItemByUid(heroData.pieceID);
        var bagNum:int = bagData == null ? 0 : bagData.num;
        var needNum:int = heroData.nextStarPieceCost;
        var commonBagData:CBagData = getCommomPieceBagData(heroData);
        var commonNum:int = commonBagData == null ?  0 : commonBagData.num;


        return bagNum + commonNum >= needNum;
    }

    /**
     * @param heroData
     * @return 返回升星时，可用于补足的万能碎片背包物品数据
     */
    public function getCommomPieceBagData( heroData:CPlayerHeroData):CBagData {

        for each (var bagData:CBagData in _bagManager.bagDataDic) {
            if (bagData != null && bagData.item.type == EItemType.ITEM_TYPE_402 && heroData.qualityBase >= int(bagData.item.param6) && heroData.qualityBase <= int(bagData.item.param7)) {
                return bagData;
            }
        }
        return null;
    }

    /**
     * 得格斗家技能数据(不包括攻击、跳跃)
     * @param heroId
     * @return
     */
    public function getHeroSkills(heroId:int):Array
    {
        var playerSkill : PlayerSkill = _playerSkill.findByPrimaryKey(heroId);

        var skillArr : Array = playerSkill.SkillID.concat();
        skillArr.splice(0,2);

//        spcicalSkill(playerSkill.SkillID[5]);

        return skillArr;
    }

    /**
     * 默认格斗家数据
     * @return
     */
    public function getDefaultHeroData():CPlayerHeroData
    {

        var heroList:Array = (system as CPlayerSystem).playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_MAIN);
        if(heroList && heroList.length)
        {
            return heroList[0];
        }

        return null;
    }

    public function isFirstHero(heroId:int):Boolean
    {
//        var heroList:Array = (system as CPlayerSystem).playerData.heroList.list;
        var heroList:Array = _getHiredHeroList();
        if(heroList && heroList.length)
        {
            return heroList[0 ].prototypeID == heroId;
        }

        return false;
    }

    public function isLastHero(heroId:int):Boolean
    {
//        var heroList:Array = (system as CPlayerSystem).playerData.heroList.list;
        var heroList:Array = _getHiredHeroList();
        if(heroList && heroList.length)
        {
            return heroList[heroList.length-1].prototypeID == heroId;
        }

        return false;
    }

    /**
     * 得上一个or下一个格斗家数据
     * @param currHeroId
     * @param type
     * @return
     */
    public function getPrevOrNextHeroData(currHeroId:int,type:int):CPlayerHeroData
    {
//        var heroList:Array = (system as CPlayerSystem).playerData.heroList.list;
        var heroList:Array = _getHiredHeroList();
        if(heroList && heroList.length)
        {
            for(var i:int = 0; i < heroList.length; i++)
            {
                if(heroList[i ].prototypeID == currHeroId)
                {
                    if(type == 1)// 前一个
                    {
                        return heroList[i-1] as CPlayerHeroData;
                    }
                    else
                    {
                        return heroList[i+1] as CPlayerHeroData;
                    }
                }
            }
        }

        return null;
    }

    private function _getHiredHeroList():Array
    {
        if(m_listHeros == null || m_listHeros.length == 0)
        {
            updateHiredHeroList();
        }

        return m_listHeros;
    }

    public function updateHiredHeroList():void
    {
        var playerData:CPlayerData = (system as CPlayerSystem).playerData;
        var list:Array = playerData.displayList;

        var existFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean
        {
            return item.hasData || (item.hasData == false && item.enoughToHire);
        };

        var unHireFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean
        {
            return item.hasData == false && item.enoughToHire == false;
        };

        var hireList:Array = list.filter(existFilter);
        hireList.sort(playerData.heroList.compare);

        var unHireList:Array = list.filter(unHireFilter);
        unHireList.sort(playerData.heroList.compare);

        m_listHeros = hireList.concat(unHireList);
    }

    public function clear():void
    {
        if(m_listHeros)
        {
            m_listHeros.length = 0;
            m_listHeros = null;
        }

        if(m_pQualResultData)
        {
            m_pQualResultData.clearData();
        }

        if(m_pStarResultData)
        {
            m_pStarResultData.clearData();
        }

        if(m_pLevelResultData)
        {
            m_pLevelResultData.clearData();
        }
    }

    /**
     * 格斗家定位占位
     * @return
     */
    public function getRoleSet(heroId:int):String
    {
        var playerLines:PlayerLines = _playerLines.findByPrimaryKey(heroId) as PlayerLines;
        if(playerLines)
        {
            return playerLines.RoleSet;
        }

        return "";
    }

    /**
     * 格斗家经历
     * @return
     */
    public function getRoleExpreience(heroId:int):String
    {
        var playerLines:PlayerLines = _playerLines.findByPrimaryKey(heroId) as PlayerLines;
        if(playerLines)
        {
            return playerLines.RoleExpreience;
        }

        return "";
    }

    public function getHeroDetailInfo(heroId:int):Array
    {
        var arr:Array = [];
        var labelArr:Array = CPlayerConst.HeroTags[0];
        var nameArr:Array = CPlayerConst.HeroTags[1];
        var playerLines:PlayerLines = _playerLines.findByPrimaryKey(heroId) as PlayerLines;
        if(playerLines)
        {
            for(var i:int = 0; i < labelArr.length; i++)
            {
                var obj:Object = {};
                obj["label"] = labelArr[i];
                obj["content"] = playerLines[nameArr[i]];
                arr.push(obj);
            }
        }

        return arr;
    }

    public function getItemData(itemId:int):CItemData
    {
        return (system.stage.getSystem(CItemSystem) as CItemSystem).getItem(itemId);
    }

    public function getItemTableData(itemID : int) : Item
    {
        return _item.findByPrimaryKey(itemID);
    }

    /**
     * 得格斗家升品、升级、升星培养属性
     * @param heroData
     * @return
     */
    public function getHeroDevelopAttrData(heroData:CPlayerHeroData):Array
    {
        var dataArr:Array = [];

        var attrs:Array = CPlayerConst.HeroBaseAttrs;
        for each(var attrName:String in attrs)
        {
            var value:int = heroData.propertyData[attrName];
            var nameCN:String = heroData.propertyData.getAttrNameCN(attrName);
            var levelUpValue:int;
            var qualityUpValue:int;
            var starUpValue:int;
            if(heroData.level < CPlayerHeroData.MAX_LEVEL)
            {
                levelUpValue = heroData.nextLevelProperty[attrName] - heroData.currentProperty[attrName];
            }

            if(heroData.qualityLevel.ID < CPlayerHeroData.MAX_QUALITY_LEVEL)
            {
                qualityUpValue = heroData.nextQualityProperty[attrName] - heroData.currentProperty[attrName];
            }

            if(heroData.star < CPlayerHeroData.MAX_STAR_LEVEL)
            {
                starUpValue = heroData.nextAwakenProperty[attrName] - heroData.currentProperty[attrName];
            }

            var attrData:CHeroAttrData = new CHeroAttrData();
            attrData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            attrData.attrBaseValue = value;
            attrData.attrNameCN = nameCN;
            attrData.attrNameEN = attrName;
            attrData.levelUpValue = levelUpValue;
            attrData.qualityUpValue = qualityUpValue;
            attrData.starUpValue = starUpValue;
            dataArr.push(attrData);
        }

        return dataArr;
    }

    /**
     * 是否道具足够格斗家升级
     * @return
     */
    public function isHeroCanLevelUp(heroData:CPlayerHeroData):Boolean
    {
        if(!heroData.hasData)
        {
            return false;
        }

        if(heroData.level >= CPlayerHeroData.MAX_LEVEL)
        {
            return false;
        }

        var stuffArr:Array = getHeroSuccLevelUpStuff(heroData);
        return stuffArr.length > 0;
    }

    /**
     * 得格斗家成功升级所需的道具
     * @param heroId
     * @return
     */
    public function getHeroSuccLevelUpStuff(heroData:CPlayerHeroData):Array
    {
        var stuffArr:Array = [];

        var pNextLevelConsume:PlayerLevelConsume = heroData.nextLevelConsume;
        var currExp:int = heroData.exp;
        var totalExp:int = pNextLevelConsume == null ? 0 : pNextLevelConsume.consumEXP;
        var needExp:int = totalExp - currExp;

        // 升下一级消耗
        var itemIdArr:Array = [];
        var nextLevelCostTable:PlayerLevelConsume;
        if ( heroData.level >= CPlayerHeroData.MAX_LEVEL )//已经到顶级
        {
            nextLevelCostTable = heroData.getLevelConsume( CPlayerHeroData.MAX_LEVEL );
        }
        else
        {
            nextLevelCostTable = pNextLevelConsume;
        }

        if(nextLevelCostTable && getPlayerLevel() >= (nextLevelCostTable.teamLevel+1))// 升至下一级所需最小战队等级
        {
            var isCanLevelUp:Boolean;
            var dic:Dictionary = new Dictionary();
            var exp:int;
            for(var i:int = 1; i <= 6; i++)
            {
                if(exp != 0 && exp >= needExp)
                {
                    isCanLevelUp = true;
                    break;
                }

                var itemId : int = nextLevelCostTable["consumItemID" + i];
                itemIdArr.push(itemId);

                dic[itemId] = 0;

                var itemData : CItemData = getItemData( itemId ); // 消耗物品
                var bagData : CBagData = _bagManager.getBagItemByUid( itemId ); // item1, 当前拥有
                var itemNum : int = bagData == null ? 0 : bagData.num;

                if (itemData.teamLevel <= getPlayerLevel() && itemNum > 0)
                {
                    for(var j:int = 0; j < itemNum; j++)
                    {
                        if(exp == 0 || exp < needExp)
                        {
                            dic[itemId] += 1;
                            exp += int(itemData.itemRecord.param4);
                        }
                        else
                        {
                            isCanLevelUp = true;
                            break;
                        }
                    }
                }
            }

            if(isCanLevelUp)
            {
                for(var key:String in dic)
                {
                    if(dic[key] > 0)
                    {
                        var obj:Object = {};
                        obj.itemID = int(key);
                        obj.num = dic[key];
                        stuffArr.push(obj);
                    }
                }
            }
        }

        return stuffArr;
    }

    /**
     * 得格斗家完整名字(包括品质信息)
     * @return
     */
    public function getHeroWholeName(heroData:CPlayerHeroData):String
    {
        var playerName:String = heroData.heroNameWithColor;
        var qualLeveltxt:String = HtmlUtil.color("+" + heroData.qualityLevelSubValue,CQualityColor.QUALITY_COLOR_ARY[heroData.qualityLevelValue]);

        if(heroData.qualityLevelSubValue <= 0)
        {
            return playerName;
        }
        else
        {
            return playerName + qualLeveltxt;
        }

        return "";
    }

    public function getHeroNextQualName(heroData:CPlayerHeroData):String
    {
        var nextQual:int = heroData.quality + 1;

        var qualityLevel:PlayerQuality = _heroQualityLevelTable.findByPrimaryKey(nextQual);
        var qualityLevelValue:int = qualityLevel == null ? 0 : int(qualityLevel.qualityColour);

        var qualityList:Vector.<Object> = _heroQualityLevelTable.toVector();
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
        var subValue:int = nextQual - firstQuality;

        var playerName:String = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[qualityLevelValue] + "'>" + heroData.heroName + "</font>";
        var qualLeveltxt:String = HtmlUtil.color("+" + subValue, CQualityColor.QUALITY_COLOR_ARY[qualityLevelValue]);

        if(subValue <= 0)
        {
            return playerName;
        }
        else
        {
            return playerName + qualLeveltxt;
        }

        return "";
    }

    /**
     * 得格斗家名
     * @param roleId
     * @return
     */
    public function getHeroName(heroId:int):String
    {
        var tableData:PlayerLines = _playerLinesTable.findByPrimaryKey(heroId) as PlayerLines;
        return tableData == null ? "" : tableData.PlayerName;
    }

    /**
     * 下一星级增加百分比属性预览
     * @return
     */
    public function getNextStarAddPercent(heroData:CPlayerHeroData):Number
    {
        if(heroData)
        {
            var currValue:Number = 0;
            var nextValue:Number = 0;
            var arr:Array = _playerStarConsumeTable.toArray();
            for each(var info:PlayerStarConsume in arr)
            {
                if(info.playerstar == heroData.star && heroData.qualityBase >= info.qualityLower
                        && heroData.qualityBase <= info.qualityLimit)
                {
                    currValue = info.starConsumeRatio;
                }

                if(info.playerstar == (heroData.star + 1) && heroData.qualityBase >= info.qualityLower
                        && heroData.qualityBase <= info.qualityLimit)
                {
                    nextValue = info.starConsumeRatio;
                }
            }

            return nextValue - currValue;
        }

        return 0;
    }

    /**
     * 格斗家是否在剧情副本中出战
     * @param heroId
     * @return
     */
    public function isHeroInEmbattle(heroId:int):Boolean
    {
        if(m_listEmbattleId == null)
        {
            m_listEmbattleId = _getEmbattleHeroList();
        }

        return m_listEmbattleId.indexOf(heroId) != -1;
    }

    /**
     * 获取出战格斗家列表，按战力降序排列
     * @return
     */
    private function _getEmbattleHeroList() : Array
    {
        var resultArr : Array = [];

        var playerManager : CPlayerManager = system.getHandler(CPlayerManager) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;

        var instanceType : int = EInstanceType.TYPE_MAIN;
        var embattleListData : CEmbattleListData = playerData.embattleManager.getByType( instanceType );
        if ( embattleListData && embattleListData.list && embattleListData.list.length > 0 ) {
            var len:int = embattleListData.list.length;
            for ( var i : int = 0; i < len; i++ ) {
                var embattleData : CEmbattleData = embattleListData.list[i] as CEmbattleData;
                if ( embattleData ) {
                    var heroID : int = embattleData.prosession;
                    resultArr.push(heroID)
                }
            }
        }

        return resultArr;
    }

    public function updateEmbattleInfo():void
    {
        m_listEmbattleId = _getEmbattleHeroList();
    }

    /**
     * 子系统是否已开启
     * @param sysTag
     * @return
     */
    public function isChildSystemOpen(sysTag:String):Boolean
    {
        return (system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(sysTag);
    }

    //property===============================================================================
    public function get currSelPanel():int
    {
        return _currSelPanelIndex;
    }

    public function set currSelPanelIndex(value:int):void
    {
        _currSelPanelIndex = value;
    }

    public function get qualityResultData():CQualityResultData
    {
        if(m_pQualResultData == null)
        {
            m_pQualResultData = new CQualityResultData();
            m_pQualResultData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        return m_pQualResultData;
    }

    public function get starResultData():CStarResultData
    {
        if(m_pStarResultData == null)
        {
            m_pStarResultData = new CStarResultData();
            m_pStarResultData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        return m_pStarResultData;
    }

    public function get levelResultData():CLevelResultData
    {
        if(m_pLevelResultData == null)
        {
            m_pLevelResultData = new CLevelResultData();
            m_pLevelResultData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        return m_pLevelResultData;
    }

    //table===============================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _playerLines():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_LINES);
    }

    private function get _playerSkill():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_SKILL);
    }

    private function get _item():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ITEM);
    }

    private function get _heroQualityLevelTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.HERO_TRAIN_QUALITY_LEVEL);
    }

    private function get _bagManager():CBagManager
    {
        return system.stage.getSystem(CBagSystem ).getHandler(CBagManager) as CBagManager;
    }

    private function get _playerLinesTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_LINES);
    }

    private function get _playerStarConsumeTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.HERO_TRAIN_STAR);
    }
}
}
