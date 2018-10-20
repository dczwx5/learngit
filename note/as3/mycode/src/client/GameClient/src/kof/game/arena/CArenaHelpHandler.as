//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena {

import QFLib.Foundation.CTime;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.arena.data.CArenaBaseData;
import kof.game.arena.data.CArenaBaseData;
import kof.game.arena.data.CArenaBestRankRewardData;
import kof.game.arena.data.CArenaBestRankRewardData;
import kof.game.arena.enum.EArenaRewardTakeState;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.table.ArenaChangeBatch;
import kof.table.ArenaConstant;
import kof.table.ArenaConstant;
import kof.table.ArenaHighestRanking;
import kof.table.ArenaRankingReward;
import kof.table.ArenaTimeDeplete;
import kof.table.PlayerBasic;
import kof.table.PlayerBasic;
import kof.table.PlayerQuality;
import kof.ui.demo.BubblesDialogueUI;
import kof.ui.imp_common.RewardItemUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CArenaHelpHandler extends CAbstractHandler {
    public function CArenaHelpHandler()
    {
        super();
    }

    /**
     * 是否有奖励可领
     * @return
     */
    public function hasRewardToTake():Boolean
    {
        var rewardData:CArenaBestRankRewardData = _arenaManager.rewardData;
        if(rewardData && rewardData.canGetRewards.length > 0)
        {
            return true;
        }

        return false;
    }

    /**
     * 得普通排名奖励信息
     * @return
     */
    public function getCommonRankRewardInfo():Array
    {
        var resultArr:Array = _arenaRankingReward.toArray();

        return resultArr;
    }

    public function getNextRewardInfo(id:int):ArenaRankingReward
    {
        return _arenaRankingReward.findByPrimaryKey(id) as ArenaRankingReward;
    }

    /**
     * 得最高排名奖励信息
     * @return
     */
    public function getBestRankRewardInfo():Array
    {
        var dataArr:Array = _arenaHighestRanking.toArray();

        var canTakeArr:Array = [];
        var notTakeArr:Array = [];
        var hasTakeArr:Array = [];

        for each(var info:ArenaHighestRanking in dataArr)
        {
            var state:int = getRewardState(info.ID);
            switch (state)
            {
                case EArenaRewardTakeState.CanTake:
                    canTakeArr.push(info);
                    break;
                case EArenaRewardTakeState.HasTaken:
                    hasTakeArr.push(info);
                    break;
                case EArenaRewardTakeState.NotReach:
                    notTakeArr.push(info);
                    break;
            }
        }

        canTakeArr.sortOn("ranking",Array.NUMERIC);
        notTakeArr.sortOn("ranking",Array.NUMERIC);
        hasTakeArr.sortOn("ranking",Array.NUMERIC);

        var resultArr:Array = canTakeArr.concat(notTakeArr);
        resultArr = resultArr.concat(hasTakeArr);

        return resultArr;
    }

    /**
     * 是否可挑战(未进入前十名则无法对前十名的玩家进行挑战)
     * @return
     */
    public function isCanChallenge():Boolean
    {
        return false;
    }

    /**
     * 是否可膜拜
     * @return
     */
    public function isCanWorship():Boolean
    {
        return false;
    }

    /**
     * 得最大挑战次数
     * @return
     */
    public function getMaxChallengeNum():int
    {
        var arenaConstant:ArenaConstant = _arenaConstant.findByPrimaryKey(1) as ArenaConstant;
        if(arenaConstant)
        {
            return arenaConstant.expInterval;
        }

        return 0;
    }

    /**
     * 得最高排名奖励领取状态
     * @param rewardId
     * @return
     */
    public function getRewardState(rewardId:int):int
    {
        var state:int;
        var rewardData:CArenaBestRankRewardData = _arenaManager.rewardData;
        if(rewardData)
        {
            if(rewardData.canGetRewards.indexOf(rewardId) != -1)
            {
                state = EArenaRewardTakeState.CanTake;
            }
            else if(rewardData.haveGotRewards.indexOf(rewardId) != -1)
            {
                state = EArenaRewardTakeState.HasTaken;
            }
            else
            {
                state = EArenaRewardTakeState.NotReach;
            }
        }

        return state;
    }

    /**
     * 得换一批消耗钻石数
     * @return
     */
    public function getRefreshCostNum():int
    {
        var currChangeNum:int = _arenaManager.arenaBaseData == null ? 0 : _arenaManager.arenaBaseData.changeNum;
        var nextChangeNum:int = currChangeNum + 1;
        var arr:Array = _arenaChangeBatch.toArray();

        if(arr && arr.length)
        {
            for each(var info:ArenaChangeBatch in arr)
            {
                if(info && nextChangeNum >= info.timeFloor && nextChangeNum <= info.timeUpper)
                {
                    return info.depleteNum;
                }
            }
        }

        return 0;
    }

    /**
     * 得购买体力消耗钻石数
     * @return
     */
    public function getBuyPowerCostNum():int
    {
        var arenaBaseData:CArenaBaseData = _arenaManager.arenaBaseData;
        if(arenaBaseData)
        {
            var times:int = arenaBaseData.buyNum + 1;
            var arr:Array = _arenaTimeDeplete.toArray();
            for each(var info:ArenaTimeDeplete in arr)
            {
                if(times >= info.timeFloor && times <= info.timeUpper)
                {
                    return info.depleteNum;
                }
            }
        }

        return 0;
    }

    /**
     * 已购买挑战次数
     * @return
     */
    public function getHasBuyNum():int
    {
        var arenaBaseData:CArenaBaseData = _arenaManager.arenaBaseData;
        if(arenaBaseData)
        {
            return arenaBaseData.buyNum;
        }

        return 0;
    }

    /**
     * 最大可购买挑战次数
     * @return
     */
    public function getMaxCanBuyNum():int
    {
        var tableData:ArenaConstant = _arenaConstant.findByPrimaryKey(1);
        if(tableData)
        {
            return tableData.buyUpper;
        }

        return 0;
    }

    /**
     * 当前奖励信息
     * @return
     */
    public function getCurrRankRewardInfo():ArenaHighestRanking
    {
//        var arenaRewardData:CArenaBestRankRewardData = _arenaManager.rewardData;
        var hisBestRank:int = _arenaManager.getHisBestRank();
        if(hisBestRank)
        {
            var arr:Array = _arenaHighestRanking.toArray();
            for(var i:int = 0; i < arr.length; i++)
            {
                var curr:int = arr[i ].ranking;
                var next:int = i < arr.length-1 ? arr[i+1 ].ranking : 0;

                if(hisBestRank <= curr && hisBestRank > next)
                {
                    return arr[i ];
                }
            }
        }

        return null;
    }

    /**
     * 下一排名段奖励信息
     * @return
     */
    public function getNextRankRewardInfo():ArenaHighestRanking
    {
        var arr:Array = _arenaHighestRanking.toArray();

        var currRankInfo:ArenaHighestRanking = getCurrRankRewardInfo();
        if(currRankInfo)
        {
            return _arenaHighestRanking.findByPrimaryKey(currRankInfo.ID + 1) as ArenaHighestRanking;
        }
        else
        {
            return arr[0] as ArenaHighestRanking;
        }

        return null;
    }

    public function getRandomTalk():String
    {
        var arr:Array = _arenaBubble.toArray();
        if(arr && arr.length)
        {
            var index:int = Math.random() * arr.length;
            if(arr[index])
            {
                return arr[index ].content;
            }
        }

        return "";
    }

    /**
     * 显示气泡说话
     * @param bubbleUI
     * @param content
     * @param x
     * @param y
     * @param position
     */
    public function showBubbleDialog(bubbleUI:BubblesDialogueUI,content:String,x:int,y:int,position:int):void
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

    public function getHeroIdArr():Array
    {
        var resultArr:Array = [];
        var arr:Array = _playerBasic.toArray();
        for each(var info:PlayerBasic in arr)
        {
            if(info)
            {
                resultArr.push(info.ID);
            }
        }

        return resultArr;
    }

    /**
     * 是否为自己
     * @param roleId
     * @return
     */
    public function isSelf(roleId:Number):Boolean
    {
        var selfRoleId:Number = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.ID;
        return roleId == selfRoleId;
    }

    /**
     * 是否敌方
     * @param roleId
     * @return
     */
    public function isEnemy(rank:int):Boolean
    {
        return (system as CArenaSystem).currChallengeRank == rank;
    }

    /**
     * 战报时间
     * @return
     */
    public function getFightReportTimeInfo(timestamp:Number):String
    {
        if(isNaN(timestamp))
        {
            return "";
        }

        var currTime:Number = CTime.getCurrServerTimestamp();
        var diff:Number = currTime - timestamp;
        if(diff < 1*60*1000)
        {
            return "刚刚";
        }

        if(diff < 1*60*60*1000)
        {
            var min:int = diff/(60*1000);
            return min + "分钟前";
        }

        if(diff < 1*24*60*60*1000)
        {
            var hour:Number = diff/(60*60*1000);
            return Math.round(hour) + "小时前";
        }

        var day:Number = diff/(24*60*60*1000);
        return Math.round(day) + "天前";
    }

    /**
     * 得格斗家职业
     * @param heroId
     * @return
     */
    public function getHeroCareer(heroId:int):int
    {
        var info:PlayerBasic = _playerBasic.findByPrimaryKey(heroId) as PlayerBasic;
        if(info)
        {
            return info.Profession;
        }

        return 0;
    }

    /**
     * 得格斗家资质
     * @param heroId
     * @return
     */
    public function getHeroIntelligence(heroId:int):int
    {
        var info:PlayerBasic = _playerBasic.findByPrimaryKey(heroId) as PlayerBasic;
        if(info)
        {
            return info.intelligence;
        }

        return 0;
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
     * 得格斗家品质颜色
     * @return
     */
    public function getHeroQualityColor(quality:int):int
    {
        var qualityInfo:PlayerQuality = _playerQuality.findByPrimaryKey(quality) as PlayerQuality;
        if(qualityInfo)
        {
            return int(qualityInfo.qualityColour);
        }

        return 0;
    }

//==========================================table==================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _arenaTimeDeplete():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ArenaTimeDeplete);
    }

    private function get _arenaChangeBatch():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ArenaChangeBatch);
    }

    private function get _arenaRankingReward():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ArenaRankingReward);
    }

    private function get _arenaHighestRanking():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ArenaHighestRanking);
    }

    private function get _arenaBubble():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ArenaBubble);
    }

    private function get _bagManager():CBagManager
    {
        return system.stage.getSystem(CBagSystem).getBean(CBagManager) as CBagManager;
    }

    private function get _arenaConstant():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ArenaConstant);
    }

    private function get _arenaManager():CArenaManager
    {
        return system.getHandler(CArenaManager) as CArenaManager;
    }

    private function get _playerBasic():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_BASIC);
    }

    private function get _playerQuality():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.HERO_TRAIN_QUALITY_LEVEL);
    }
}
}
