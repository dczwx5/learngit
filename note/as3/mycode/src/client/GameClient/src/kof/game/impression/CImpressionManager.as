//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/20.
 */
package kof.game.impression {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.property.CBasePropertyData;
import kof.game.impression.data.CPlayerInfoData;
import kof.game.impression.util.CImpressionUtil;
import kof.game.impression.util.EImpressionAttrType;
import kof.game.impression.view.CImpressionViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.common.data.CAttributeBaseData;
import kof.table.Impression;
import kof.table.PassiveSkillPro;

/**
 * 羁绊数据处理器
 */
public class CImpressionManager extends CAbstractHandler {

    public static var Attrs:Array = ["Attack","Defense","HP"];

    private var m_data:*;
    private var m_pListData:Array = [];

    public function CImpressionManager()
    {
        super();
    }

    override protected virtual function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        return ret;
    }

    public function get data():*
    {
        return m_data;
    }

    public function set data(value:*):void
    {
        m_data = value;

        var view : CImpressionViewHandler = this.system.getBean( CImpressionViewHandler ) as CImpressionViewHandler;
        if ( null != view && view.isViewShow)
        {
            view.update();
        }
    }

    /**
     * 得羁绊格斗家列表数据
     */
    public function getHeroListData():Array
    {
        var resultArr:Array = [];
        var tableArr:Array = _impressionTable.toArray();

        if(tableArr && tableArr.length)
        {
            var lastGroup:int = tableArr[tableArr.length-1 ].groupId;
            var listArr:Array = [];
            for(var i:int = 0; i < lastGroup; i++)// 取所有组数据，三个一组
            {
                var groupArr:Array = _impressionTable.findByProperty("groupId",i+1);
                if(groupArr.length < 3)
                {
                    fillNullData(groupArr);
                }

                tableDatatransformToHeroData(groupArr);

                if(i % 4 == 0)
                {
                    listArr = [];
                    resultArr.push(listArr);
                }

                for(var j:int = 0; j < groupArr.length; j++)
                {
                    listArr.push(groupArr[j]);
                    groupArr[j]["outerIndex"] = resultArr.indexOf(listArr);
                    groupArr[j]["innerIndex"] = listArr.indexOf(groupArr[j]);
                }
            }
        }

        m_pListData = resultArr;

        return m_pListData;
    }

    /**
     * 不足三个的组填空数据
     */
    private function fillNullData(groupArr:Array):void
    {
        if(groupArr.length < 3)
        {
            for(var i:int = groupArr.length; i < 3; i++)
            {
                groupArr.push({});
            }
        }
    }

    private function tableDatatransformToHeroData(originArr:Array):void
    {
        for(var i:int = 0; i < originArr.length; i++)
        {
            if(originArr[i] is Impression)
            {
                originArr[i] = getDataByTableData(originArr[i]);
            }
        }
    }

    /**
     * 得可培养的格斗家列表
     * @return
     */
    public function getCanTrainHeroData():Array
    {
        var heroListData:Array = getHeroListData();
        var arr:Array = [];
        for each(var players:Array in heroListData)
        {
            for each(var player:CPlayerInfoData in players)
            {
                if(player.isGet)
                {
                    arr.push(player);
                }
            }
        }

        return arr;
    }

    /**
     * 得同一个组的格斗家列表
     * @param groupId
     * @return
     */
    public function getGroupHeroList(groupId:int):Array
    {
        var heroArr:Array = [];
        var resultArr:Array = _impressionTable.findByProperty("groupId",groupId);
        if(resultArr && resultArr.length)
        {
            for each(var info:Impression in resultArr)
            {
                var playerInfoData:CPlayerInfoData = getDataByTableData(info);
                heroArr.push(playerInfoData);
            }
        }

        return heroArr;
    }

    private function getDataByTableData(info:Impression):CPlayerInfoData
    {
        var result:CPlayerInfoData = new CPlayerInfoData();
        if(info)
        {
            result.roleId = info.roleId;
            var activityHeroIds:Array = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.activityHeroIds;
            var isActivityOpen:Boolean = activityHeroIds.indexOf(info.roleId+"") != -1;// 活动投放的格斗家
            result.isOpen = info.isOpen || isActivityOpen || isHeroCollected(info.roleId);
            result.isGet = isHeroCollected(info.roleId);
        }

        return result;
    }

    /**
     * 格斗家是否已收集
     * @return
     */
    private function isHeroCollected(heroId:int):Boolean
    {
        var playerManager:CPlayerManager = this.system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager)
                as CPlayerManager;
//        if(playerManager)
//        {
//            var ownHeroArr:Array = playerManager.playerData.heroList.list as Array;
//
//            if(ownHeroArr && ownHeroArr.length)
//            {
//                for(var i:int = 0; i < ownHeroArr.length; i++)
//                {
//                    var playerData:CPlayerHeroData = ownHeroArr[i] as CPlayerHeroData;
//                    if(playerData && playerData.ID == heroId)
//                    {
//                        return true;
//                    }
//                }
//            }
//        }

        return playerManager.playerData.heroList.hasHero(heroId);
    }

    /**
     * 得某个格斗家
     * @param id
     * @return
     */
    public function getHeroDataById(id:int):CPlayerHeroData
    {
        var manager:CPlayerManager = system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
        if(manager)
        {
            var ownHeroArr : Array = manager.playerData.heroList.list as Array;
            if(ownHeroArr && ownHeroArr.length)
            {
                for each(var info:CPlayerHeroData in ownHeroArr)
                {
                    if(id == info.ID)
                    {
                        return info;
                    }
                }
            }
        }

        return null;
    }

    public function getImpressionInfo(roleId:int):Impression
    {
        var arr:Array = _impressionTable.findByProperty("roleId",roleId);
        if(arr && arr.length)
        {
            return arr[0] as Impression;
        }

        return null;
    }

    /**
     * 得属性加成信息(获得加成，满星加成)
     * @return
     */
    public function getAttrInfo(roleId:int):Object
    {
        var obj:Object;
        var arr:Array = _impressionTable.findByProperty("roleId",roleId);
        if(arr && arr.length)
        {
            obj = {};
            var tableData:Impression = arr[0] as Impression;
            obj[EImpressionAttrType.Type_Collect+""] = getAttrData(EImpressionAttrType.Type_Collect,tableData);

            var heroData:CPlayerHeroData = getHeroDataById(roleId);
            var currStar:int = heroData != null ? heroData.star : 1;
            currStar = currStar == 0 ? 1 : currStar;
            var nextStar:int = currStar >= 7 ? 7 : currStar+1;
            var fulStar:int  = 7;

            obj[EImpressionAttrType.Type_CurrStar+""] = getAttrData(EImpressionAttrType.Type_CurrStar,tableData,currStar);
            obj[EImpressionAttrType.Type_NextStar+""] = getAttrData(EImpressionAttrType.Type_CurrStar,tableData,nextStar);
            obj[EImpressionAttrType.Type_FullStar+""] = getAttrData(EImpressionAttrType.Type_CurrStar,tableData,fulStar);
        }

        return obj;
    }

    /**
     * 得总获得属性
     * @return
     */
    public function getTotalCollectAttr():CBasePropertyData
    {
        var totalAttrData:CBasePropertyData = new CBasePropertyData();
        totalAttrData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

        var heroListData:Array = getHeroListData();
        for each(var players:Array in heroListData)
        {
            for each(var player:CPlayerInfoData in players)
            {
                if(player.isGet)
                {
                    var resultArr:Array = _impressionTable.findByProperty("roleId",player.roleId);
                    if(resultArr && resultArr.length) {
                        var impression : Impression = resultArr[ 0 ] as Impression;
                        var heroData:CPlayerHeroData = getHeroDataById(player.roleId);
                        var currStar:int = heroData != null ? heroData.star : 1;
                        var attrData:CBasePropertyData = getAttrData(EImpressionAttrType.Type_CurrStar,impression,currStar);
                        attrData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                        totalAttrData.add(attrData);
                    }
                }
            }
        }

        return totalAttrData;
    }

    /**
     * 得收集加成or星级加成属性
     * @return
     */
    public function getAttrData(type:int, tableData:Impression, starLevel:int = 0):CBasePropertyData
    {
        var attrData:CBasePropertyData = new CBasePropertyData();
        attrData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        var attrInfo:String;

        starLevel = starLevel == 0 ? 1 : starLevel;
        switch (type)
        {
            case EImpressionAttrType.Type_Collect:
//                    attrInfo = tableData.basicProperty.slice(1,tableData.basicProperty.length-1);
                attrInfo = tableData["star"+tableData.star].slice(1,tableData["star"+tableData.star].length-1);
                break;
            case EImpressionAttrType.Type_CurrStar:
            case EImpressionAttrType.Type_NextStar:
            case EImpressionAttrType.Type_FullStar:
                attrInfo = tableData["star"+starLevel].slice(1,tableData["star"+starLevel].length-1);
                break;
        }

        var arr:Array = attrInfo.split(":");
        var attrType:int = int(arr[0]);// 属性类型
        var attrValue:int = int(arr[1]);// 属性值
        var attrPercent:int = int(arr[2]);// 属性万分比
        var attrName:String = getAttrNameEN(attrType);
        if(attrData.hasOwnProperty(attrName))
        {
            attrData[attrName] = attrPercent;
        }

        return attrData;
    }

    /**
     * 所有格斗家所加的属性总和
     * @return
     */
    public function getAllHeroAddAttr():CBasePropertyData
    {
        var totalAttrData:CBasePropertyData = new CBasePropertyData();
        totalAttrData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var heroList:Array = playerData.heroList.list;
        for each(var heroData:CPlayerHeroData in heroList)
        {
            if(heroData && heroData.hasData)
            {
                var currArr:Array = CImpressionUtil.getCurrTotalAttr(heroData.prototypeID, heroData.impressionLevel);
                for each(var attrData:CAttributeBaseData in currArr)
                {
                    totalAttrData[attrData.attrNameEN] += attrData.attrBaseValue;
                }
            }
        }

        return totalAttrData;
    }

    /**
     * 得属性英文名
     * @param type
     * @return
     */
    private function getAttrNameEN(type:int):String
    {
        var info:PassiveSkillPro = _passiveSkillTable.findByPrimaryKey(type);
        if(info)
        {
            return info.word;
        }

        return null;
    }

    private function get _impressionTable():IDataTable
    {
        return (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.IMPRESSION);
    }

    private function get _passiveSkillTable():IDataTable
    {
        return (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
    }
}
}
