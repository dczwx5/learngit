//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/10.
 */
package kof.game.endlessTower {

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.endlessTower.data.CEndlessTowerBoxData;
import kof.game.endlessTower.data.CEndlessTowerHeroData;
import kof.game.endlessTower.data.CEndlessTowerLayerData;
import kof.game.endlessTower.data.CLayerBoxRewardTakeInfoData;
import kof.game.endlessTower.enmu.EEndlessTowerLayerDataType;
import kof.game.endlessTower.enmu.ERewardTakeState;
import kof.game.endlessTower.util.CEndlessConst;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.table.EndlessTowerConst;
import kof.table.EndlessTowerLayerConfig;
import kof.table.EndlessTowerRobotConfig;
import kof.table.EndlessTowerSegmentConfig;
import kof.table.PassiveSkillPro;
import kof.table.PlayerQuality;
import kof.table.RobotHero;
import kof.table.RobotPlayer;
import kof.ui.imp_common.RewardItemUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CEndlessTowerHelpHandler extends CAbstractHandler {

    /** 最大层数 */
    private var m_iMaxLayer:int;

    public function CEndlessTowerHelpHandler()
    {
        super();
    }

    /**
     * 普通奖励掉落包ID
     * @return
     */
    public function getCommonRewardDropId(layerId:int):int
    {
        var info:EndlessTowerLayerConfig = getLayerConfigInfo(layerId);
        if(info)
        {
            return info.firstPassReward;
        }

        return 0;
    }

    /**
     * 通关奖励掉落包ID
     * @return
     */
    public function getPassRewardDropId(layerId:int):int
    {
        var info:EndlessTowerLayerConfig = getLayerConfigInfo(layerId);
        if(info)
        {
            if(isFirstPass(layerId))
            {
                return info.firstPassReward;
            }
            else
            {
                return info.passReward;
            }
        }

        return 0;
    }

    /**
     * 宝箱奖励掉落包ID
     * @return
     */
    public function getBoxRewardDropId(layerId:int):int
    {
        var info:EndlessTowerLayerConfig = getLayerConfigInfo(layerId);
        if(info)
        {
            return info.boxReward[0] as int;
        }

        return 0;
    }

    /**
     * 每日宝箱奖励
     * @return
     */
    public function getEveryDayBoxRewardId():int
    {
        var info:EndlessTowerConst = getTowerConstInfo();
        if(info)
        {
            return info.everydayReward;
        }

        return 0;
    }

    public function getSegmentName(layerId:int):String
    {
        var info:EndlessTowerSegmentConfig = getSegmentConfig(layerId);
        if(info)
        {
            return info.segmentName;
        }

        return "";
    }

    /**
     * 得某一层的格斗家数据
     * @param layerId
     * @return
     */
    public function getHeroDatasById(layerId:int):Array
    {
        var heroArr:Array = [];

        var info:EndlessTowerRobotConfig = _endlessTowerRobot.findByPrimaryKey(layerId) as EndlessTowerRobotConfig;
        if(info)
        {
            var level:int;
            var quality:int;
            var star:int;
            var robotPlayer:RobotPlayer = _robotPlayer.findByPrimaryKey(info.playerId) as RobotPlayer;
            if(robotPlayer)
            {
                level = robotPlayer.heroLevel;
                quality = robotPlayer.heroQuality;
                star = robotPlayer.heroStar;
            }

            for(var i:int = 0; i < info.heroIds.length; i++)
            {
                var robotInfo:RobotHero = _robotHero.findByPrimaryKey(int(info.heroIds[i])) as RobotHero;
                if(robotInfo)
                {
                    var heroData:CEndlessTowerHeroData = new CEndlessTowerHeroData();
                    heroData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                    heroData.heroId = robotInfo.heroID;
                    heroData.level = level;
                    heroData.quality = quality;
                    heroData.star = star;
                    heroData.layerId = layerId;

                    heroArr.push(heroData);
                }
            }
        }

        return heroArr;
    }

    /**
     * 得某一层的宝箱数据
     * @param layerId
     * @return
     */
    public function getBoxDatasById(layerId:int):Array
    {
        var resultArr:Array = [];
        var boxArr:Array = getLayerBoxReward(layerId);
        for each(var rewardId:int in boxArr)
        {
            if(rewardId)
            {
                var boxData:CEndlessTowerBoxData = new CEndlessTowerBoxData();
                boxData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
                boxData.boxRewardId = rewardId;
                boxData.layerId = layerId;

                resultArr.push(boxData);
            }
        }

        return resultArr;
    }

    /**
     * 得当前所在层的前后5层数据(包括当前层)
     * @param currLayer
     * @return
     */
    public function getTenLayerData(currLayer:int):Array
    {
        var resultArr:Array = [];

        var min:int = currLayer - CEndlessConst.Step;
        var max:int = currLayer + CEndlessConst.Step;
        for(var i:int = max; i >= min; i--)
        {
            if(i > 0 && i <= maxLayer)
            {
                _setLayerData(resultArr, i);

                if(resultArr.length >= 11)
                {
                    break;
                }
            }
        }

        return resultArr;
    }

    private function _setLayerData(resultArr:Array, layer:int, isAddToBack:Boolean = true):void
    {
        var boxLayerData:CEndlessTowerLayerData;
        var boxData:Array = getBoxDatasById(layer);
        if(boxData.length)
        {
            boxLayerData = new CEndlessTowerLayerData();
            boxLayerData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            boxLayerData.layerId = layer;
            boxLayerData.type = EEndlessTowerLayerDataType.Type_Box;
            boxLayerData.dataArr = boxData;
        }

        var heroData:Array = getHeroDatasById(layer);

        var layerData:CEndlessTowerLayerData = new CEndlessTowerLayerData();
        layerData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        layerData.layerId = layer;
        layerData.type = EEndlessTowerLayerDataType.Type_Hero;
        layerData.dataArr = heroData;

        if(isAddToBack)
        {
            if(boxLayerData)
            {
                resultArr.push(boxLayerData);
            }
            resultArr.push(layerData);
        }
        else
        {
            resultArr.unshift(layerData);
            if(boxLayerData)
            {
                resultArr.unshift(boxLayerData);
            }
        }
    }

    /**
     * 某层的前十层数据
     * @return
     */
    public function getPrevLayerData(targetLayer:int, currLayerDatas:Array):Array
    {
        var resultArr:Array = [];

        var len:int = currLayerDatas.length;
        resultArr.push(currLayerDatas[len-3]);
        resultArr.push(currLayerDatas[len-2]);
        resultArr.push(currLayerDatas[len-1]);

        for(var i:int = targetLayer-1; i > 0; i--)
        {
            _setLayerData(resultArr, i);

            if(resultArr.length >= 10)
            {
                break;
            }
        }

        return resultArr;
    }

    /**
     * 某层的后十层数据
     * @return
     */
    public function getNextLayerData(targetLayer:int, currLayerDatas:Array):Array
    {
        var resultArr:Array = [];

        resultArr.push(currLayerDatas[0]);
        resultArr.push(currLayerDatas[1]);
        resultArr.push(currLayerDatas[2]);

        for(var i:int = targetLayer+1; i <= maxLayer; i++)
        {
            _setLayerData(resultArr, i, false);

            if(resultArr.length >= 10)
            {
                break;
            }
        }

        return resultArr;
    }

    /**
     * 得某页的十层数据
     * @return
     */
    public function getLayerDataByPage(page:int):Array
    {
        var resultArr:Array = [];

        var startIndex:int = page * 40 - 30;
        var endIndex:int = page * 40 - 40;
        for(var i:int = startIndex; i > endIndex; i--)
        {
            _setLayerData(resultArr, i);
        }

        return resultArr;
    }

    public function get maxLayer():int
    {
        if(m_iMaxLayer == 0)
        {
            var layerArr:Array = _endlessTowerLayer.toArray();
            m_iMaxLayer = layerArr.length;
        }

        return m_iMaxLayer;
    }

    public function getQualityColor(quality:int):int
    {
        var qualityLevel:PlayerQuality = _heroQualityLevel.findByPrimaryKey(quality);
        if (qualityLevel)
        {
            return int(qualityLevel.qualityColour);
        }

        return 0;
    }

    /**
     * 每层的宝箱奖励
     * @param layerId
     * @return
     */
    public function getLayerBoxReward(layerId:int):Array
    {
        var info:EndlessTowerLayerConfig = _endlessTowerLayer.findByPrimaryKey(layerId);
        if(info)
        {
            return info.boxReward;
        }

        return null;
    }

    /**
     * 宝箱领取状态
     * @return
     */
    public function getLayerBoxTakeState(layerId:int, boxIndex:int):int
    {
        var manager:CEndlessTowerManager = system.getHandler(CEndlessTowerManager) as CEndlessTowerManager;
        var maxLayer:int = manager.baseData.maxPassedLayer;
        if(layerId > maxLayer)
        {
            return ERewardTakeState.CannotTake;
        }
        else
        {
            var boxTakeInfo:CLayerBoxRewardTakeInfoData = manager.baseData.boxTakeInfoListData.getData(layerId);
            if(boxTakeInfo == null)
            {
                return ERewardTakeState.CanTake;
            }

            var hasTakeArr:Array = boxTakeInfo.obtainedArr;
            if(hasTakeArr.indexOf(boxIndex) == -1)
            {
                return ERewardTakeState.CanTake;
            }
            else
            {
                return ERewardTakeState.HasTake;
            }
        }
    }

    /**
     * 某层的宝箱是否已领取
     * @param layerId
     * @return
     */
    public function isBoxTaked(layerId:int):Boolean
    {
        var manager:CEndlessTowerManager = system.getHandler(CEndlessTowerManager) as CEndlessTowerManager;
        var maxLayer:int = manager.baseData.maxPassedLayer;

        if(layerId > maxLayer)
        {
            return false;
        }

        var boxTakeInfo:CLayerBoxRewardTakeInfoData = manager.baseData.boxTakeInfoListData.getData(layerId);
        if(boxTakeInfo == null)
        {
            return false;
        }

        var hasTakeArr:Array = boxTakeInfo.obtainedArr;
        var boxDataArr:Array = getBoxDatasById(layerId);
        if(boxDataArr.length == 0)// 该层没有配宝箱
        {
            return true;
        }

        if(hasTakeArr && boxDataArr && boxDataArr.length == hasTakeArr.length)
        {
            return true;
        }

        return true;
    }

    /**
     * 是否首通
     * @param layer
     * @return
     */
    public function isFirstPass(layer:int):Boolean
    {
        var manager:CEndlessTowerManager = system.getHandler(CEndlessTowerManager) as CEndlessTowerManager;
        if(manager)
        {
            return manager.baseData.maxPassedLayer < layer;
        }

        return false;
    }

    public function renderItem(item:Component, index:int):void
    {
        if(!(item is RewardItemUI))
        {
            return;
        }

        var rewardItem:RewardItemUI = item as RewardItemUI;
        rewardItem.mouseChildren = false;
        rewardItem.mouseEnabled = true;
        var itemData:CRewardData = rewardItem.dataSource as CRewardData;
        if(null != itemData)
        {
            rewardItem.num_lable.text = itemData.num > 1 ? itemData.num.toString() : "";
            rewardItem.icon_image.url = itemData.iconSmall;
            rewardItem.bg_clip.index = itemData.quality;
        }
        else
        {
            rewardItem.num_lable.text = "";
            rewardItem.icon_image.url = "";
        }

        rewardItem.toolTip = new Handler( showTips, [rewardItem] );
    }

    /**
     * 物品tips
     * @param item
     */
    public function showTips(item:RewardItemUI):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    /**
     * 某一层的配置信息
     * @param layerId
     * @return
     */
    public function getLayerConfigInfo(layerId:int):EndlessTowerLayerConfig
    {
        return _endlessTowerLayer.findByPrimaryKey(layerId) as EndlessTowerLayerConfig;
    }

    /**
     * 得属性英文名
     * @param attrType 属性类型
     * @return
     */
    public function getAttrNameEN( attrType : int ) : String {
        var arr : Array = _passiveSkillProTable.findByProperty( "ID", attrType );
        if ( arr && arr.length ) {
            return (arr[ 0 ] as PassiveSkillPro).word;
        }

        return "";
    }

    public function getConsumeItemId():int
    {
        var info:EndlessTowerConst = getTowerConstInfo();
        if(info)
        {
            return info.challengeCostItemId;
        }

        return 0;
    }

    /**
     * 是否有奖励可领
     * @return
     */
    public function hasRewardCanTake():Boolean
    {
        return hasDailyReward() || hasBoxReward();
    }

    /**
     * 是否有每日奖励可领
     * @return
     */
    public function hasDailyReward():Boolean
    {
        var manager:CEndlessTowerManager = system.getHandler(CEndlessTowerManager) as CEndlessTowerManager;

        if(manager && manager.baseData)
        {
            return manager.baseData.dayRewardTakeLayer != manager.baseData.maxPassedLayer;
        }

        return false;
    }

    /**
     * 是否有宝箱奖励可领
     * @return
     */
    public function hasBoxReward():Boolean
    {
        var manager:CEndlessTowerManager = system.getHandler(CEndlessTowerManager) as CEndlessTowerManager;
        if(manager && manager.baseData)
        {
            var arr:Array = getLayerBoxReward(manager.baseData.maxPassedLayer);
            if(arr && arr.length)
            {
                for(var i:int = 0; i < arr.length; i++)
                {
                    if(arr[i])
                    {
                        var state:int = getLayerBoxTakeState(manager.baseData.maxPassedLayer, i);
                        if(state == ERewardTakeState.CanTake)
                        {
                            return true;
                        }
                    }
                }
            }
        }

        return false;
    }

    /**
     * 出战敌方格斗家列表
     * @param heroArr
     * @return
     */
    public function getEmbattleEnemyList(heroArr:Array):Array
    {
        var resultArr:Array = [];
        if(heroArr && heroArr.length)
        {
            for each(var data:CEndlessTowerHeroData in heroArr)
            {
                if(data)
                {
                    var heroData:CPlayerHeroData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.createHero(data.heroId);
                    heroData.setTrainData(data.level, data.star, data.quality);
                    resultArr.push(heroData);
                }
            }
        }

        return resultArr;
    }

    public function getTowerConstInfo():EndlessTowerConst
    {
        return _endlessTowerConst.findByPrimaryKey(1) as EndlessTowerConst;
    }

    public function getSegmentConfig(layerId:int):EndlessTowerSegmentConfig
    {
        var id:int = Math.ceil(layerId % 50);

        return _endlessTowerSegment.findByPrimaryKey(id) as EndlessTowerSegmentConfig;
    }

    //table===============================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _endlessTowerConst():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.EndlessTowerConst);
    }

    private function get _endlessTowerLayer():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.EndlessTowerLayerConfig);
    }

    private function get _endlessTowerSegment():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.EndlessTowerSegmentConfig);
    }

    private function get _endlessTowerRobot():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.EndlessTowerRobotConfig);
    }

    private function get _robotPlayer():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.RobotPlayer);
    }

    private function get _heroQualityLevel():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.HERO_TRAIN_QUALITY_LEVEL);
    }

    private function get _robotHero():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.RobotHero);
    }

    private function get _passiveSkillProTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
    }
}
}
