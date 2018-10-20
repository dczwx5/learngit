//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/14.
 */
package kof.game.talent.talentFacade {

import flash.utils.Dictionary;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.character.property.CBasePropertyData;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EHeroCareer;
import kof.game.common.data.CAttributeBaseData;
import kof.game.switching.CSwitchingSystem;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentOpenConditionType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPointStateType;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentAllPointData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentConditionData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentEmbedInfo;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentPointData;
import kof.table.TalentOpenCondition;
import kof.table.TalentOpenCondition;
import kof.table.TalentOpenCondition.EOpenConditionType;
import kof.table.TalentSoulFurnace;
import kof.table.TalentSoulPoint;
import kof.table.TalentSoulSuit;

public class CTalentHelpHandler extends CAbstractHandler {

    private var m_pPropertyData:CBasePropertyData;

    public function CTalentHelpHandler()
    {
        super();
    }

    /**
     * 当前标签页的套装等级
     * @param pageType
     * @return
     */
    public function getCurrSuitLevel(pageType:int):int
    {
        var arr:Array = CTalentDataManager.getInstance().getEmbatleInfoByPage(pageType);
        if(arr && arr.length)
        {
            for(var i:int = arr.length - 1; i >= 0; i--)
            {
                var embedInfo:CTalentEmbedInfo = arr[i] as CTalentEmbedInfo;
                if(embedInfo)
                {
                    var talentSoulSuit:TalentSoulSuit = isReach(pageType, embedInfo);
                    if(talentSoulSuit)
                    {
                        return talentSoulSuit.suitLevel;
                    }
                }
            }
        }

        return 0;
    }

    /**
     * 当前等级套装配置数据
     * @param pageType
     * @return
     */
    public function getCurrSuitInfo(pageType:int):TalentSoulSuit
    {
        var suitLevel:int = getCurrSuitLevel(pageType);
        var dataArr:Array = _talentSoulSuit.findByProperty("suitLevel", suitLevel);
        if(dataArr && dataArr.length)
        {
            return dataArr[0] as TalentSoulSuit;
        }

        return null;
    }

    public function getTipsSuitInfo(pageType:int):Array
    {
        var resultArr:Array = [];
        var arr:Array = CTalentDataManager.getInstance().getEmbatleInfoByPage(pageType);
        if(arr && arr.length)
        {
            for(var i:int = arr.length - 1; i >= 0; i--)
            {
                var embedInfo:CTalentEmbedInfo = arr[i] as CTalentEmbedInfo;
                if(embedInfo)
                {
                    var talentSoulSuit:TalentSoulSuit = isReach(pageType, embedInfo);
                    if(talentSoulSuit)
                    {
                        resultArr.push(talentSoulSuit);
                        break;
                    }
                }
            }
        }

        if(resultArr.length == 0)// 取第一个
        {
            talentSoulSuit = getSuitInfo(pageType, 1);
            if(talentSoulSuit)
            {
                resultArr.push(talentSoulSuit);
            }
        }
        else// 下一个套装
        {
            talentSoulSuit = resultArr[0] as TalentSoulSuit;
            var talentSoulSuit2:TalentSoulSuit = getSuitInfo(pageType, talentSoulSuit.suitLevel + 1);
            if(talentSoulSuit2)
            {
                resultArr.push(talentSoulSuit2);
            }
        }

        return resultArr;
    }

    public function isReach(pageType:int, embedInfo:CTalentEmbedInfo):TalentSoulSuit
    {
        var tableArr:Array = _talentSoulSuit.findByProperty("pageID", pageType).reverse();
        if(tableArr && tableArr.length)
        {
            for each(var info:TalentSoulSuit in tableArr)
            {
                if(info && info.soulLevel == embedInfo.qualLevel && embedInfo.totalNum >= info.soulNum)
                {
                    return info;
                }
            }
        }

        return null;
    }

    /**
     * 得套装信息
     * @param pageId
     * @param suitLevel 套装等级
     * @return
     */
    public function getSuitInfo(pageId:int, suitLevel:int):TalentSoulSuit
    {
        var tableArr:Array = _talentSoulSuit.findByProperty("pageID", pageId);
        if(tableArr && tableArr.length)
        {
            for each(var info:TalentSoulSuit in tableArr)
            {
                if(info && info.suitLevel == suitLevel)
                {
                    return info;
                }
            }
        }

        return null;
    }

    /**
     * 得斗魂信息
     * @param pageId
     * @param qualLevel 斗魂等级
     * @return
     */
    public function getEmbedInfo(pageId:int, qualLevel:int):CTalentEmbedInfo
    {
        return CTalentDataManager.getInstance().getEmbedInfoByPageAndLevel(pageId, qualLevel);
    }

    /**
     * 斗魂套装属性
     * @param suitInfo
     * @return
     */
    public function getSuitAttrInfo(suitInfo:TalentSoulSuit):Array
    {
        var resultArr:Array = [];

        if(m_pPropertyData == null)
        {
            m_pPropertyData = new CBasePropertyData();
            m_pPropertyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        if(suitInfo && suitInfo.propertysAdd)
        {
            var str:String = suitInfo.propertysAdd.replace( "[", "" );
            str = str.replace( "]", "" );
            var arr1:Array = str.split(";");

            for each(var str2:String in arr1)
            {
                var arr2:Array = str2.split(":");
                var attrData:CAttributeBaseData = new CAttributeBaseData();
                attrData.attrType = int(arr2[0]);
                attrData.attrBaseValue = int(arr2[1]);
                attrData.attrNameEN = m_pPropertyData.getAttrNameEN(int(arr2[0]));
                attrData.attrNameCN = m_pPropertyData.getAttrNameCN(attrData.attrNameEN);
                resultArr.push(attrData);
            }
        }

        return resultArr;
    }

    public function getSuitAttrDataById(pageType:int, attrType:int):CAttributeBaseData
    {
        var suitInfo:TalentSoulSuit = getCurrSuitInfo(pageType);
        if(suitInfo)
        {
            var arr:Array = getSuitAttrInfo(suitInfo);
            if(arr && arr.length)
            {
                for each(var attrData:CAttributeBaseData in arr)
                {
                    if(attrData.attrType == attrType)
                    {
                        return attrData;
                    }
                }
            }
        }

        return null;
    }

    /**
     * 斗魂是否可开启
     * @return
     */
    public function isTalentCanOpen(talentSoulPoint:TalentSoulPoint):Boolean
    {
        if(talentSoulPoint)
        {
            var condition:TalentOpenCondition = _talentOpenCondition.findByPrimaryKey(talentSoulPoint.openConditionID)
                as TalentOpenCondition;
            if(condition)
            {
                for(var i:int = 0; i < condition.conditions.length; i++)
                {
                    if(condition.conditions[i])
                    {
                        if(!isConditionReach(condition.conditions[i], condition.params[i], talentSoulPoint.pageID))
                        {
                            return false;
                        }
                    }
                }
            }
        }

        return true;
    }

    /**
     * 某个条件是否达成
     * @return
     */
    public function isConditionReach(conditionType:int, targetValue:int, pageId:int):Boolean
    {
        if(conditionType == EOpenConditionType.ROLE_LEVEL)// 战队升级条件
        {
            return _playerData.teamData.level >= targetValue;
        }

        if(conditionType == EOpenConditionType.PEAK_LEVEL)
        {
            var peakData:CPeakGameData = (system.stage.getSystem(CPeakGameSystem) as CPeakGameSystem).peakGameData;
            return peakData.scoreLevelID >= targetValue;
        }

        if(conditionType == EOpenConditionType.SOUL_LEVEL_SUM)
        {
            var dic:Dictionary = CTalentDataManager.getInstance().talentInfoData.historyHighTotalLevelDic;
            var currValue:int = dic[pageId] as int;
            return currValue >= targetValue;
        }

        if(conditionType == EOpenConditionType.ATTACK_HERO_NUM)
        {
            return _getHeroNumByCareer(EHeroCareer.Type_Attack) >= targetValue;
        }

        if(conditionType == EOpenConditionType.DEFENCE_HERO_NUM)
        {
            return _getHeroNumByCareer(EHeroCareer.Type_Defense) >= targetValue;
        }

        if(conditionType == EOpenConditionType.SKILL_HERO_NUM)
        {
            return _getHeroNumByCareer(EHeroCareer.Type_Skill) >= targetValue;
        }

        if(conditionType == EOpenConditionType.HERO_NUM)
        {
            return _playerData.heroList.list.length >= targetValue;
        }

        if(conditionType == EOpenConditionType.HERO_MAX_QUALITY)
        {
            return _getHeroMaxIntelligence() >= targetValue;
        }

        if(conditionType == EOpenConditionType.VIP_LEVEL)
        {
            return _playerData.vipData.vipLv >= targetValue;
        }

        return false;
    }

    private function _updateConditionInfo(conditionData:CTalentConditionData, pageId:int):void
    {
        if(conditionData)
        {
            switch(conditionData.conditionType)
            {
                case EOpenConditionType.ROLE_LEVEL:
                    conditionData.conditionDesc = "达到指定战队等级";
                    conditionData.currValue = _playerData.teamData.level;
                    break;
                case EOpenConditionType.PEAK_LEVEL:
                    conditionData.conditionDesc = "拳皇大赛达到指定段位";
                    var peakData:CPeakGameData = (system.stage.getSystem(CPeakGameSystem) as CPeakGameSystem).peakGameData;
                    conditionData.currValue = peakData.scoreLevelID;
                    break;
                case EOpenConditionType.SOUL_LEVEL_SUM:
                    conditionData.conditionDesc = "镶嵌总等级达到指定值";
                    var dic:Dictionary = CTalentDataManager.getInstance().talentInfoData.historyHighTotalLevelDic;
                    var currValue:int = dic[pageId] as int;
                    conditionData.currValue = currValue;
                    break;
                case EOpenConditionType.ATTACK_HERO_NUM:
                    conditionData.conditionDesc = "攻击型格斗家达到指定值";
                    conditionData.currValue = _getHeroNumByCareer(EHeroCareer.Type_Attack);
                    break;
                case EOpenConditionType.DEFENCE_HERO_NUM:
                    conditionData.conditionDesc = "防御型格斗家达到指定值";
                    conditionData.currValue = _getHeroNumByCareer(EHeroCareer.Type_Defense);
                    break;
                case EOpenConditionType.SKILL_HERO_NUM:
                    conditionData.conditionDesc = "技巧型格斗家达到指定值";
                    conditionData.currValue = _getHeroNumByCareer(EHeroCareer.Type_Skill);
                    break;
                case EOpenConditionType.HERO_NUM:
                    conditionData.conditionDesc = "拥有格斗家达到指定值";
                    conditionData.currValue = _playerData.heroList.list.length;
                    break;
                case EOpenConditionType.HERO_MAX_QUALITY:
                    conditionData.conditionDesc = "格斗家最高资质达到指定值";
                    conditionData.currValue = _getHeroMaxIntelligence();
                    break;
                case EOpenConditionType.VIP_LEVEL:
                    conditionData.conditionDesc = "VIP等级达到指定值";
                    conditionData.currValue = _playerData.vipData.vipLv;
                    break;
            }
        }
    }

    public function getOpenConditionInfo(conditionId:int, pageId:int):Array
    {
        var resultArr:Array = [];
        var condition:TalentOpenCondition = _talentOpenCondition.findByPrimaryKey(conditionId) as TalentOpenCondition;
        if(condition)
        {
            for(var i:int = 0; i < condition.conditions.length; i++)
            {
                var type:int = int(condition.conditions[i]);
                if(type)
                {
                    var conditionData:CTalentConditionData = new CTalentConditionData();
                    conditionData.conditionType = type;
                    conditionData.targetValue = int(condition.params[i]);
                    _updateConditionInfo(conditionData, pageId);

                    resultArr.push(conditionData);
                }
            }
        }

        return resultArr;
    }

    private function _getHeroMaxIntelligence():int
    {
        var maxIntelligence:int = 0;
        var heroList:Array = _playerData.heroList.list;
        for each(var heroData:CPlayerHeroData in heroList)
        {
            if(heroData.qualityBase > maxIntelligence)
            {
                maxIntelligence = heroData.qualityBase;
            }
        }

        return maxIntelligence;
    }

    private function _getHeroNumByCareer(career:int):int
    {
        var num:int = 0;
        var heroList:Array = _playerData.heroList.list;
        for each(var heroData:CPlayerHeroData in heroList)
        {
            if(heroData.job == career)
            {
                num++;
            }
        }

        return num;
    }

    /**
     * 某个标签页是否有可操作项
     * @param pageType
     * @return
     */
    public function isCanOperateByPage(pageType:int):Boolean
    {
        var alreadyOpenPointID:Array = [];
        var talentPageData : CTalentAllPointData = CTalentDataManager.getInstance().getTalentPagePointData( pageType );
        if ( talentPageData )
        {
            var talentPointDataVec : Vector.<CTalentPointData> = talentPageData.pointInfos;
            var len : int = talentPointDataVec.length;
            var talentPointData : CTalentPointData;
            var talentSoulPoint:TalentSoulPoint;
            var max:int = pageType == ETalentPageType.BEN_YUAN ? 33 : 19;
            for ( var j : int = 0; j < len; j++ )
            {
                talentPointData = talentPointDataVec[ j ];
                talentSoulPoint = CTalentFacade.getInstance().getTalentPointSoulForID(talentPointData.soulPointConfigID);
                alreadyOpenPointID.push( talentSoulPoint.pointID );
                for ( var i:int = 1; i <= max; i++ )
                {
                    if(talentSoulPoint && i == talentSoulPoint.pointID && talentPointData.state == ETalentPointStateType.OPEN_CAN_EMBED)
                    {
                        if ( CTalentDataManager.getInstance().getTalentPointForWarehouse( i , pageType).length )
                        {
                            return true;
                        }
                    }
                }
            }
        }

        //下一个开启的位置
        var nextPointArr:Array = CTalentFacade.getInstance().nextOpenSePointID(pageType);
        var nextPoint : int = nextPointArr.length > 0 ? nextPointArr[0] : 0;
        if(nextPoint > 0)
        {
            talentSoulPoint = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( nextPoint, pageType );
            var isCanOpen : Boolean = isTalentCanOpen( talentSoulPoint );
            if ( isCanOpen )
            {
                return true;
            }
        }

        // 特殊斗魂
        var m:int = pageType == ETalentPageType.BEN_YUAN ? 31 : 17;
        var n:int = pageType == ETalentPageType.BEN_YUAN ? 33 : 19;
        for(i = m; i <= n; i++)
        {
            if(alreadyOpenPointID.indexOf(i) == -1)
            {
                talentSoulPoint = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( i , pageType);
                if(isTalentCanOpen(talentSoulPoint))
                {
                    return true;
                }
            }
        }

        return false;
    }

    public function isCanMelt():Boolean
    {
        return false;
    }

    /**
     * 整个斗魂系统是否有可操作项
     * @return
     */
    public function isCanOperate():Boolean
    {
        return isCanOperateByPage(ETalentPageType.BEN_YUAN)
                || (_isPageOpen(ETalentPageType.PEAK) && isCanOperateByPage(ETalentPageType.PEAK));
    }

    private function _isPageOpen(pageType:int):Boolean
    {
        var system:CAppSystem = CTalentFacade.getInstance().talentAppSystem;
        var tag:String = pageType == ETalentPageType.BEN_YUAN ? KOFSysTags.TALENT : KOFSysTags.TALENT_PEAK;
        var isSystemOpen:Boolean = (system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(tag);
        if(isSystemOpen)
        {
            return true;
        }

        return false;
    }

    /**
     * 某种斗魂熔炉是否已开启
     * @param type
     * @return
     */
    public function isTalentMeltOpen(type:int):Boolean
    {
        var arr:Array = _talentSoulFurnace.findByProperty("type", type) as Array;
        if(arr && arr.length)
        {
            var playerSystem:CPlayerSystem = CTalentFacade.getInstance().talentAppSystem.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var teamLevel:int = playerSystem.playerData.teamData.level;
            return teamLevel >= (arr[0] as TalentSoulFurnace).openLevel;
        }

        return false;
    }

    /**
     * 得斗魂熔炉开启等级
     * @param type
     * @return
     */
    public function getTalentMeltOpenLevel(type:int):int
    {
        var arr:Array = _talentSoulFurnace.findByProperty("type", type) as Array;
        if(arr && arr.length)
        {
            return (arr[0] as TalentSoulFurnace).openLevel;
        }

        return 0;
    }

//table===============================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _talentSoulSuit():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.TalentSoulSuit);
    }

    private function get _talentOpenCondition():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.TalentOpenCondition);
    }

    private function get _talentSoulFurnace():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.TalentSoulFurnace);
    }

    private function get _playerData():CPlayerData
    {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
}
}
