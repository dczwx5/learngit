//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/20.
 */
package kof.game.impression.util {

import QFLib.Foundation.CMap;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.character.property.CBasePropertyData;
import kof.game.impression.CImpressionManager;
import kof.game.impression.CImpressionNetHandler;
import kof.game.impression.data.CFoodData;
import kof.game.impression.data.CImpressionAttrData;
import kof.game.impression.data.CImpressionTotalLevelData;
import kof.game.impression.data.CPlayerInfoData;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.common.data.CAttributeBaseData;
import kof.game.scenario.CScenarioSystem;
import kof.game.task.CTaskManager;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskType;
import kof.table.Impression;
import kof.table.ImpressionLevel;
import kof.table.ImpressionProperty;
import kof.table.ImpressionTitle;
import kof.table.ImpressionTotalLevelAddProperty;
import kof.table.ImpressionTotalLevelAddProperty;
import kof.table.PassiveSkillPro;
import kof.table.PlayerBasic;
import kof.table.PlayerLines;
import kof.table.Task;
import kof.ui.demo.BubblesDialogueUI;

public class CImpressionUtil {

    private static const _OPEN_LEVEL : int = 20;// 玩家战队20级

    public static const Attrs : Array = [ "HP", "Attack", "Defense" ];

    private static var _system : CAppSystem;

    public static const PosArr:Array = [
        {x:0,y:0},{x:66,y:-3},{x:132,y:-6},{x:-2,y:71},{x:64,y:69},{x:130,y:67},{x:-4,y:140}, {x:62,y:142},
        {x:128,y:144},{x:-2,y:211},{x:64,y:214},{x:130,y:217},

        {x:0,y:-8},{x:66,y:-10},{x:132,y:-8},{x:-1,y:67},{x:66,y:66},{x:133,y:67},{x:-2,y:141},{x:66,y:144},
        {x:134,y:141},{x:0,y:219},{x:66,y:221},{x:132,y:219},

        {x:0,y:-6},{x:66,y:-3},{x:132,y:0},{x:1,y:67},{x:67,y:69},{x:133,y:71},{x:2,y:141},{x:68,y:144},
        {x:134,y:141},{x:1,y:217},{x:67,y:214},{x:133,y:211}
    ];

    public function CImpressionUtil() {
    }

    public static function initialize( gSystem : CAppSystem ) : void {
        _system = gSystem;
    }

    /**
     * 羁绊系统是否已开启
     * @return
     */
    public static function isSystemOpened( system : CAppSystem ) : Boolean {
        if ( system == null ) {
            return false;
        }

        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager );
        if ( playerManager ) {
            return playerManager.playerData.teamData.level >= _OPEN_LEVEL;
        }

        return false;
    }

    /**
     * 得亲密度称号数据表信息
     * @param impressionLevel 亲密度等级
     * @param sex 性别
     * @return
     */
    public static function getTitleInfoByLevelAndSex( impressionLevel : int, sex : int ) : ImpressionTitle {
        var resultArr : Array = _impressionTitleTable.toArray();
        for each( var info : ImpressionTitle in resultArr ) {
            if ( info && info.gender == sex ) {
//                if ( impressionLevel > (info.level - 30) && impressionLevel <= info.level ) {
//                    return info;
//                }

                if ( impressionLevel >= info.level && impressionLevel < info.level+30 ) {
                    return info;
                }
            }
        }

        return null;
    }

    public static var maxImpressionLevel:int = 0;
    /**
     * 好感度等级上限
     * @return
     */
    public static function getTitleMaxLevel():int
    {
        if(maxImpressionLevel == 0)
        {
            var resultArr : Array = _impressionLevelTable.toArray();
            if(resultArr && resultArr.length)
            {
                maxImpressionLevel = (resultArr[resultArr.length - 1] as ImpressionLevel).level;
            }
        }

        return maxImpressionLevel;
    }

    /**
     * 是否已达最高等级
     * @return
     */
    public static function isReachMaxLevel(heroId:int):Boolean
    {
        var manager:CPlayerManager = _system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
        var playerData:CPlayerData = manager.playerData;
        var heroData:CPlayerHeroData = playerData.heroList.getHero(heroId) as CPlayerHeroData;

        return heroData && heroData.impressionLevel >= getTitleMaxLevel();
    }

    /**
     * 得升至下级所需好感度
     * @param quality 格斗家资质
     * @param level 亲密度等级
     * @return
     */
    public static function getMaxExp( quality : int, level : int ) : int {
        var resultArr : Array = _impressionLevelTable.toArray();
        if ( resultArr && resultArr.length ) {
            for each( var info : ImpressionLevel in resultArr ) {
                if ( quality >= info.intelligenceFloor && quality <= info.intelligenceUpper && level == info.level ) {
                    return info.exp;
                }
            }
        }

        return 0;
    }

    /**
     * 得某个亲密度等级所加的属性(累加属性)
     * @param roleId
     * @param impressionLevel 亲密度等级
     * @param isNext 是否下级预览属性
     * @return
     */
    public static function getAttrDatas( roleId : int, impressionLevel : int, isNext : Boolean = false ) : Array {
        var propArr : Array = _impressionPropertyTble.toArray();
        if ( propArr && propArr.length ) {
            // 当前亲密度等级所在的目标等级区间(如12级所在区间为11~20)
            var targetLevel : int;
            if ( impressionLevel == 0 ) {
                targetLevel = 10;
            }
            else {
                targetLevel = (impressionLevel % 10 == 0) ? impressionLevel : (int( impressionLevel / 10 ) + 1) * 10;
            }

            targetLevel = isNext ? targetLevel + 10 : targetLevel;


            var map : CMap = new CMap();
            for each( var info : ImpressionProperty in propArr )// 累加属性
            {
                if ( info.roleId == roleId && info.level <= targetLevel ) {
                    var arr : Array = _parseAttrStr( info.property.slice( 1, info.property.length - 1 ) );
                    for each( var attrData : CAttributeBaseData in arr )// 每个等级可能配多条属性
                    {
                        var data : CAttributeBaseData = map.find( attrData.attrType );
                        if ( data )
                        {
                            data.attrBaseValue += data.attrBaseValue;
                        }
                        else
                        {
                            map.add( attrData.attrType, attrData );
                        }
                    }
                }
            }
        }

        return map.toArray();
    }

    /**
     * 得当前亲密度等级所加的属性(累加属性)
     * @param roleId
     * @param impressionLevel 亲密度等级
     * @return
     */
    public static function getCurrTotalAttr(roleId : int, impressionLevel : int):Array
    {
        if(impressionLevel == 0)
        {
            return [];
        }

        var totalMap:CMap = new CMap();
        for(var i:int = 1; i <= impressionLevel; i++)
        {
            var map:CMap = getAttrInfoByLevel(i,roleId);
            for(var attrType:int in map)
            {
                var data : CAttributeBaseData = totalMap.find(attrType);
                if ( data )
                {
                    data.attrBaseValue += (map.find(attrType) as CAttributeBaseData).attrBaseValue;
                }
                else
                {
                    totalMap.add(attrType, (map.find(attrType) as CAttributeBaseData));
                }
            }
        }

        return totalMap.toArray();
    }

    public static function getNextAttr(impressionLevel:int,roleId:int):Array
    {
        var map:CMap = getAttrInfoByLevel(impressionLevel,roleId);
        if(map)
        {
            return map.toArray();
        }

        return [];
    }

    /**
     * 当前和下级属性(附战力)
     * @return
     */
    public static function getAttrInfoWithCombat(heroId:int, impressionLevel:int):Array
    {
        var resultArr:Array = [];
        var currArr:Array = getCurrTotalAttr(heroId, impressionLevel);
        var nextArr:Array = getCurrTotalAttr(heroId, impressionLevel+1);

        var combatData:CImpressionAttrData = new CImpressionAttrData();
        resultArr.push(combatData);

        var propData1:CBasePropertyData = new CBasePropertyData();
        propData1.databaseSystem = _system.stage.getSystem(IDatabase) as IDatabase;
        var propData2:CBasePropertyData = new CBasePropertyData();
        propData2.databaseSystem = _system.stage.getSystem(IDatabase) as IDatabase;

        for(var i:int = 0; i < Attrs.length; i++)
        {
            var data:CImpressionAttrData = new CImpressionAttrData();
            var attrName:String = Attrs[i];
            data.attrNameEN = attrName;
            data.attrNameCN = getAttrNameCN2(attrName);
            data.currTotalValue = _getValueByName(attrName, currArr);
            data.nextTotalValue = _getValueByName(attrName, nextArr);

            if(data.currTotalValue || data.nextTotalValue)
            {
                resultArr.push(data);
            }

            var currData:CAttributeBaseData = currArr[i] as CAttributeBaseData;
            if(currData)
            {
                propData1[currData.attrNameEN] += currData.attrBaseValue;
            }

            var nextData:CAttributeBaseData = nextArr[i] as CAttributeBaseData;
            if(nextData)
            {
                propData2[nextData.attrNameEN] += nextData.attrBaseValue;
            }
        }

        combatData.currCombat = propData1.getBattleValue();
        combatData.nextCombat = propData2.getBattleValue();

        return resultArr;
    }

    private static function _getValueByName(attrName:String, attrArr:Array):int
    {
        for each(var data:CAttributeBaseData in attrArr)
        {
            if(data && data.attrNameEN == attrName)
            {
                return data.attrBaseValue;
            }
        }

        return 0;
    }

    /**
     * 得某一级所加的属性
     * @return
     */
    public static function getAttrInfoByLevel(impressionLevel:int,roleId:int):CMap
    {
        var map:CMap;
        var propArr : Array = _impressionPropertyTble.findByProperty("roleId",roleId);
        if ( propArr && propArr.length )
        {
            map = new CMap();
            for(var i:int = 0; i < propArr.length; i++)
            {
                var prevLevel:int = i == 0 ? 0 : propArr[i-1 ].level;
                var currLevel:int = propArr[i ].level;
                var info:ImpressionProperty = propArr[i];

                if(info.roleId == roleId && impressionLevel > prevLevel && impressionLevel <= currLevel)
                {
                    var arr : Array = _parseAttrStr( info.property.slice( 1, info.property.length - 1 ) );
                    for each( var attrData : CAttributeBaseData in arr )// 每个等级可能配多条属性
                    {
                        var data : CAttributeBaseData = map.find( attrData.attrType );
                        if ( data )
                        {
                            data.attrBaseValue += data.attrBaseValue;
                        }
                        else
                        {
                            map.add( attrData.attrType, attrData );
                        }
                    }
                }
            }
        }

        return map;
    }

    /**
     * 解析属性
     * @return
     */
    private static function _parseAttrStr( str : String ) : Array {
        var arr : Array = [];
        if ( str ) {
            var arr1 : Array = str.split( ";" );
            for each( var attrStr : String in arr1 ) {
                var arr2 : Array = attrStr.split( ":" );
                var attrData:CAttributeBaseData = new CAttributeBaseData();
                attrData.attrType = int( arr2[ 0 ] );// 属性类型
                attrData.attrBaseValue = int( arr2[ 1 ] );// 属性值
                attrData.attrPercent = int( arr2[ 2 ] );// 万分比
                attrData.attrNameCN = getAttrNameCN( int( arr2[ 0 ] ) );// 中文名
                attrData.attrNameEN = getAttrNameEN( int( arr2[ 0 ] ) );// 英文名
                arr.push( attrData );
            }
        }

        return arr;
    }

    /**
     * 得属性中文名
     * @param attrType 属性类型
     * @return
     */
    public static function getAttrNameCN( attrType : int ) : String {
        var arr : Array = _passiveSkillProTable.findByProperty( "ID", attrType );
        if ( arr && arr.length ) {
            return (arr[ 0 ] as PassiveSkillPro).name;
        }

        return "";
    }

    public static function getAttrNameCN2(attrNameEN:String):String
    {
        var arr : Array = _passiveSkillProTable.findByProperty( "word", attrNameEN );
        if ( arr && arr.length ) {
            return (arr[ 0 ] as PassiveSkillPro).name;
        }

        return "";
    }

    /**
     * 得属性英文名
     * @param attrType 属性类型
     * @return
     */
    public static function getAttrNameEN( attrType : int ) : String {
        var arr : Array = _passiveSkillProTable.findByProperty( "ID", attrType );
        if ( arr && arr.length ) {
            return (arr[ 0 ] as PassiveSkillPro).word;
        }

        return "";
    }

    /**
     * 得升级所需美食
     * @return
     */
    public static function getFoodItems( roleId : int ) : Array {
        var itemDataArr : Array = [];
        var arr : Array = _impressionTable.findByProperty( "roleId", roleId );
        if ( arr && arr.length ) {
            var foodIds : String = (arr[ 0 ] as Impression).foodId;
            var arr2 : Array = foodIds.split( "," );
            for each( var id : String in arr2 ) {
                var itemData : CFoodData = new CFoodData();
                var bagData : CBagData = _bagManager.getBagItemByUid( int( id ) );
                var num : int = bagData == null ? 0 : bagData.num;
                var obj : Object = CFoodData.createObjectData( int( id ), num );
                itemData.databaseSystem = _dataBase;
                itemData.updateDataByData( obj );

                itemDataArr.push( itemData );
            }
        }

        itemDataArr.sort(sortByQual);
        return itemDataArr;
    }

    private static function sortByQual(a:CFoodData,b:CFoodData):int
    {
        if(a && b)
        {
            if(a.quality < b.quality)
            {
                return -1;
            }
            else if(a.quality > b.quality)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }

        return 0;
    }

    /**
     * 道具是否足够
     * @param itemDataArr 道具数组
     * @return
     */
    public static function isPropEnough( itemDataArr : Array ) : Boolean {
        for each( var itemData : CFoodData in itemDataArr ) {
            var bagData : CBagData = _bagManager.getBagItemByUid( itemData.itemID );
            if (bagData && bagData.num > 0 ) {
                return true;
            }
        }

        return false;
    }

    /**
     * 亲密度是否已满级
     * @return
     */
    public static function isFullLevel(heroData:CPlayerHeroData) : Boolean
    {
        if(heroData == null)
        {
            return false;
        }

        var arr:Array = _impressionLevelTable.toArray();
        var arr2:Array = [];
        if(arr && arr.length)
        {
            for each (var info:ImpressionLevel in arr)
            {
                if(heroData.qualityBase >= info.intelligenceFloor && heroData.qualityBase <= info.intelligenceUpper)
                {
                    arr2.push(info);
                }
            }
        }

        if(arr2.length)
        {
           return heroData.impressionLevel >= arr2[arr2.length-1].level;
        }

        return false;
    }

    /**
     * 得一个随机气泡对话
     * @return
     */
    public static function getRandomBubbleTalk(sex:int):String
    {
        var arr:Array = _bubbleMsgTable.findByProperty("gender",sex);
        if(arr && arr.length)
        {
            var index:int = Math.random()*arr.length;
            return arr[index ].msg;
        }

        return "";
    }

    /**
     * 得格斗家循环对话
     * @param roleId
     * @param oldTalk 上次说话
     * @return
     */
    public static function getHeroLoopTalk(roleId:int,oldTalk:String):String
    {
        var newTalkStr:String = "";
        var resultArr:Array = _impressionTable.findByProperty("roleId",roleId);
        if(resultArr && resultArr.length)
        {
            var tImpression:Impression = resultArr[0] as Impression;
            if(!oldTalk || oldTalk == "0")
            {
                newTalkStr = tImpression.monologue1;
            }
            else
            {
                for(var i:int = 1; i <= 3; i++)
                {
                    if(oldTalk == tImpression["monologue"+i])
                    {
                        var j:int = (i + 1 > 3) ? 1 : i + 1;// 取下一个
                        newTalkStr = tImpression["monologue"+j];
                        break;
                    }
                }
            }
        }

        return newTalkStr;
    }

    /**
     * 得格斗家名
     * @param roleId
     * @return
     */
    public static function getHeroName(roleId:int):String
    {
        var tableData:PlayerLines = _playerLinesTable.findByPrimaryKey(roleId) as PlayerLines;
        return tableData == null ? "" : tableData.PlayerName;
    }

    /**
     * 得格斗家性别
     * @param roleId
     * @return
     */
    public static function getHeroSex(roleId:int):int
    {
        var tableData:PlayerBasic = _playerBasicTable.findByPrimaryKey(roleId) as PlayerBasic;
        return tableData == null ? 0 : tableData.gender;
    }

    /**
     * 得首次培养剧情对话ID
     * @return
     */
    public static function getFirstTalkId(roleId:int):String
    {
        var arr:Array = _impressionTable.findByProperty("roleId",roleId);
        if(arr && arr.length)
        {
            return arr[0 ].firstTalk as String;
        }

        return null;
    }

    /**
     * 得格斗家可接取的羁绊任务信息
     * @return
     */
    public static function getTaskInfo(roleId:int):Array
    {
        var resultArr:Array = [];
        var arr:Array = _impressionTable.findByProperty("roleId",roleId);
        if(arr && arr.length)
        {
            var info:Impression = arr[0] as Impression;
            var taskStr:String = info.mission.slice(1,info.mission.length-1);
            var strArr:Array = taskStr.split(";");
            for each(var str:String in strArr)
            {
                var arr2:Array = str.split(":");
                var obj:Object = {};
                var taskInfo:Task = _taskTable.findByPrimaryKey(int(arr2[0]));
                obj["taskInfo"] = taskInfo;
                obj["needLevel"] = int(arr2[1]);
                resultArr.push(obj);
            }
        }

        return resultArr;
    }

    public static function getTaskById(id:int):Task
    {
        return _taskTable.findByPrimaryKey(id) as Task;
    }

    /**
     * 根据当前任务id得下一个可接取的任务信息
     * @param roleId
     * @param taskId
     * @return
     */
    public static function getNextTaskInfoByCurrId(roleId:int,taskId:int):Object
    {
        var taskArr:Array = getTaskInfo(roleId);
        for(var i:int = 0; i < taskArr.length; i++)
        {
            if(taskId == taskArr[i ].taskInfo.ID)
            {
                if(i < taskArr.length-1)
                {
                    return taskArr[i+1];
                }
            }
        }

        return null;
    }

    /**
     * 得战队名
     * @return
     */
    public static function getTeamName(roleId:int):String
    {
        var tableData:PlayerBasic = _playerBasicTable.findByPrimaryKey(roleId) as PlayerBasic;
        return tableData == null ? "" : tableData.teamName;
    }

    /**
     * 显示剧情对话
     */
    public static function showPlotTalk(heroData:CPlayerHeroData):void
    {
        var id:String = CImpressionUtil.getFirstTalkId(heroData.ID);
        (_system.stage.getSystem(CScenarioSystem) as CScenarioSystem).playScenario(int(id),1,function(id:int):void {
            (_system.getBean(CImpressionNetHandler) as CImpressionNetHandler).impressionTalkRequest(heroData.ID);
//            var data:Object = {};
//            data["impressionTalk"] = false;
//            heroData.updateDataByData(data);
        },false);
    }

    /**
     * 随机取一个要说话的格斗家
     * @return
     */
    public static function getRandomTalkHero(page:int):CPlayerInfoData
    {
        var start:int = page*3;
        var end:int = (page+1)*3;
        var heroListDataArr:Array = (_system.getBean(CImpressionManager) as CImpressionManager).getHeroListData();
        var listArr:Array = heroListDataArr.slice(start,end);

//        if(listArr && listArr.length)
//        {
//            var index:int = Math.random() * listArr.length;
//            return index;
//        }

        var hasGetHeroArr:Array = getHasGetHeroArr(listArr);
        if(hasGetHeroArr.length)
        {
            var index:int = Math.random() * hasGetHeroArr.length;
            return hasGetHeroArr[index];
        }

        return null;
    }

    private static function getHasGetHeroArr(arr:Array):Array
    {
        var resultArr:Array = [];
        for each(var heroArr:Array in arr)
        {
            for(var i:int = 0; i < heroArr.length; i++)
            {
                if(heroArr[i] is CPlayerInfoData && heroArr[i ].isGet)
                {
                    resultArr.push(heroArr[i]);
                }
            }
        }

        return resultArr;
    }

    /**
     * 某个格斗家是否可进行亲密度培养
     * @return
     */
    public static function isHeroCanUpgrade(roleId:int):Boolean
    {
        var heroData:CPlayerHeroData = getHeroDataById(roleId);
        if(isFullLevel(heroData))
        {
            return false;
        }

        var dataArr:Array = getFoodItems(roleId);
        for each(var itemData:CFoodData in dataArr)
        {
            if(itemData.num > 0)
            {
                return true;
            }
        }

        return false;
    }

    /**
     * 是否有可培养的格斗家
     * @return
     */
    public static function hasCanUpgradeHero():Boolean
    {
        var manager:CImpressionManager = _system.getBean(CImpressionManager) as CImpressionManager;
        var heroListDataArr:Array = manager.getHeroListData();
        for each(var listArr:Array in heroListDataArr)
        {
            for each(var player:CPlayerInfoData in listArr)
            {
                if(player.isOpen && player.isGet)
                {
                    if(isHeroCanUpgrade(player.roleId) || isCanTakeTaskReward(player.roleId))
                    {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    /**
     * 是否有任务奖励可领
     * @param heroId
     * @return
     */
    public static function isCanTakeTaskReward(heroId:int):Boolean
    {
        var heroData:CPlayerHeroData = getHeroDataById(heroId);
        if(heroData && heroData.hasData)
        {
            return heroData.impressionTask.state == EImpressionTaskStateType.Type_Complete;
        }

        return false;
    }

    public static function getHeroDataById(roleId:int):CPlayerHeroData
    {
        if(roleId)
        {
            var manager:CPlayerManager = _system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
            var playerData:CPlayerData = manager.playerData;
//            var heroData:CPlayerHeroData = playerData.heroList.getByKey("ID",roleId) as CPlayerHeroData;

            var heroData:CPlayerHeroData = playerData.heroList.getHero(roleId) as CPlayerHeroData;
            return heroData;
        }

        return null;
    }

    /**
     * 得羁绊配置信息
     * @param roleId
     * @return
     */
    public static function getImpressionConfig(roleId:int):Impression
    {
        var resultArr:Array = _impressionTable.findByProperty("roleId",roleId);
        if(resultArr && resultArr.length)
        {
            return resultArr[0] as Impression;
        }

        return null;
    }

    /**
     * 得货币名
     * @return
     */
    public static function getCurrencyName(itemId:int):String
    {
        var itemData:CItemData = (_system.stage.getSystem(CItemSystem) as CItemSystem).getItem(itemId) as CItemData;
        if(itemData && itemData.itemRecord)
        {
            return itemData.itemRecord.literatureDescription;
        }

        return "什么鬼";
    }

    /**
     * 货币图标
     * @param itemId
     * @return
     */
    public static function getCurrencyIcon(itemId:int):String
    {
//        var itemData:CItemData = (_system.stage.getSystem(CItemSystem) as CItemSystem).getItem(itemId) as CItemData;
//        if(itemData && itemData.itemRecord)
//        {
//            return itemData.itemRecord.smalliconURL+".png";
//        }

        var nameStr:String = "";
        switch (itemId)
        {
            case 1:// 金币
                nameStr = "goldcoin";
                break;
            case 2:// 绑定钻石
                nameStr = "violetdiamond";
                break;
            case 3:// 钻石
                nameStr = "bluediamond";
                break;
            case 4:// 体力
                nameStr = "power";
                break;
            case 5:// 荣耀币
                nameStr = "honor";
                break;
            case 6:// 试炼币
                nameStr = "trialcoin";
                break;
        }

        return "icon/currency/"+nameStr+".png";
    }

    /**
     * 显示气泡说话
     * @param bubbleUI
     * @param content
     * @param x
     * @param y
     * @param position
     */
    public static function showBubbleDialog(bubbleUI:BubblesDialogueUI,content:String,x:int,y:int,position:int):void
    {
        bubbleUI.txt_content.textField.width = 154;
        bubbleUI.txt_content.text = content;
        bubbleUI.txt_content.height = bubbleUI.txt_content.textField.textHeight + 35;
        bubbleUI.txt_content.width =  bubbleUI.txt_content.textField.textWidth + 35;

        if(position)
        {
            bubbleUI.img_target.scaleX = 1;
            bubbleUI.img_target.x = 7;
        }
        else
        {
            bubbleUI.img_target.scaleX = -1;
            bubbleUI.img_target.x = bubbleUI.txt_content.x + bubbleUI.txt_content.width - 7;
        }

        bubbleUI.x = x;
        bubbleUI.y = y;
    }

    /**
     * 格斗家是否已开放
     * @return
     */
    public static function isHeroOpened(roleId:int):Boolean
    {
        var resultArr:Array = _impressionTable.findByProperty("roleId",roleId);
        if(resultArr && resultArr.length)
        {
            var impression:Impression = resultArr[0] as Impression;

            var activityHeroIds:Array = (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.activityHeroIds;
            var isActivityOpen:Boolean = activityHeroIds.indexOf(roleId+"") != -1;// 活动投放的格斗家
            var playerManager:CPlayerManager = _system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager)
                    as CPlayerManager;
            var isGet:Boolean = playerManager.playerData.heroList.hasHero(roleId);

            return impression.isOpen || isActivityOpen || isGet;
        }

        return false;
    }

    /**
     * 羁绊格斗家星级加成属性(百分比全局属性)
     * @return
     */
    public static function getImpressionStarAttr():CBasePropertyData
    {
        var propertyData:CBasePropertyData = new CBasePropertyData();
        if(_system)
        {
            propertyData.databaseSystem = _system.stage.getSystem(IDatabase) as IDatabase;

            var heroListData:Array = (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.list;
            for each(var player:CPlayerHeroData in heroListData)
            {
                if(player.hasData)
                {
                    var resultArr:Array = _impressionTable.findByProperty("roleId",player.prototypeID);
                    if(resultArr && resultArr.length)
                    {
                        var impression : Impression = resultArr[ 0 ] as Impression;
                        var attrData:CBasePropertyData = _impressionManager.getAttrData(EImpressionAttrType.Type_CurrStar,impression,player.star);
                        attrData.databaseSystem = _system.stage.getSystem(IDatabase) as IDatabase;
                        propertyData.add(attrData);
                    }
                }
            }
        }

        return propertyData;
    }

    public static function getTaskDataById(taskId:int):CTaskData
    {
        var manager:CTaskManager = (_system.stage.getSystem(CTaskSystem) as CTaskSystem).getHandler(CTaskManager) as CTaskManager;
        return manager.getTaskDataByTaskID(taskId);
    }

    /**
     * 得好感度总等级加成信息
     * @return
     */
    public static function getImpressionTotalLevelData():CImpressionTotalLevelData
    {
        var currTotalLevel:int = 0;
        var heroList:Array = (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.list;
        for each(var heroData:CPlayerHeroData in heroList)
        {
            if(heroData)
            {
                currTotalLevel += heroData.impressionLevel;
            }
        }

        var compareValue:int = currTotalLevel == 0 ? (currTotalLevel + 1) : currTotalLevel;
        var dataArr:Array = _totalLevelAdditionTable.toArray();
        for each(var tableData:ImpressionTotalLevelAddProperty in dataArr)
        {
            var levelUpper:int = tableData.totalLevelUpper == -1 ? 999 : tableData.totalLevelUpper;
            if(tableData && compareValue >= tableData.totalLevelFloor && compareValue <= levelUpper)
            {
                var totalLevelData:CImpressionTotalLevelData = new CImpressionTotalLevelData();
                totalLevelData.ID = tableData.ID;
                totalLevelData.currTotalLevel = currTotalLevel;

                var nextTableData:ImpressionTotalLevelAddProperty = _totalLevelAdditionTable.findByPrimaryKey(tableData.ID + 1)
                        as ImpressionTotalLevelAddProperty;

                if(nextTableData)
                {
                    totalLevelData.nextTargetLevel = nextTableData.totalLevelFloor;
                }

                totalLevelData.totalAddition = tableData.addPropertyPercent;

                return totalLevelData;
            }
        }

        return null;
    }

//==========================================table==================================================
    private static function get _dataBase():IDatabase
    {
        return _system.stage.getSystem(IDatabase) as IDatabase;
    }

    private static function get _impressionTitleTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.IMPRESSION_TITLE);
    }

    private static function get _impressionLevelTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.IMPRESSION_LEVEL);
    }

    private static function get _passiveSkillProTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
    }

    private static function get _impressionPropertyTble():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.IMPRESSION_PROPERTY);
    }

    private static function get _impressionTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.IMPRESSION);
    }

    private static function get _bagManager():CBagManager
    {
        return _system.stage.getSystem(CBagSystem ).getBean(CBagManager) as CBagManager;
    }

    private static function get _bubbleMsgTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.BUBBLE_MSG);
    }

    private static function get _playerLinesTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_LINES);
    }

    private static function get _taskTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.TASK);
    }

    private static function get _playerBasicTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_BASIC);
    }

    private static function get _totalLevelAdditionTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ImpressionTotalLevelAddProperty);
    }

    private static function get _impressionManager():CImpressionManager
    {
        return _system.getHandler(CImpressionManager) as CImpressionManager;
    }
}
}
