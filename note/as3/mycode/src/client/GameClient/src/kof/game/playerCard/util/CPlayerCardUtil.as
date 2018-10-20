//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/6/9.
 */
package kof.game.playerCard.util {

import QFLib.Foundation.CTime;
import QFLib.Utils.CDateUtil;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.CItemUtil;
import kof.game.item.CItemData;
import kof.game.player.CPlayerHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerUIHandler;
import kof.game.player.CPlayerUIHandler;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.playerCard.CPlayerCardManager;
import kof.game.playerCard.data.CPlayerCardData;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.enum.EShopType;
import kof.message.Hero.ItemConvertToHeroPieceResponse;
import kof.table.AllShowItem;
import kof.table.CardPlayerActivity;
import kof.table.CardPlayerConstant;
import kof.table.CardPlayerPool;
import kof.table.FreeSet;
import kof.table.NewServerShowItem;
import kof.table.ShopItem;
import kof.table.ShowItem;

public class CPlayerCardUtil {

    public static var HeroChipsNum:int;//整卡召唤界面格斗家碎片信息
    public static var HasOpenRequested:Boolean;// 只有第一次打开界面则请求初始化信息
    public static var IsSkipAnimation:Boolean;// 是否跳过动画
    public static var IsInPumping:Boolean;// 是否正在抽卡中

    private static var _system : CAppSystem;

    public function CPlayerCardUtil()
    {
    }

    public static function initialize( gSystem : CAppSystem ) : void
    {
        _system = gSystem;
    }

    /**
     * 得拥有的酒券数
     * @param itemId 物品id
     * @return
     */
    public static function getOwnTicketNum(itemId:int):int
    {
        var bagData : CBagData = _bagManager.getBagItemByUid(itemId);
        if (bagData)
        {
            return bagData.num;
        }

        return 0;
    }

    /**
     * 得卡池预览物品信息
     * @param poolType 卡池类型
     * @param tabIndex 第几个标签
     * @return
     */
    public static function getCardPoolItems(poolType:int,tabIndex:int):Array
    {
        var resultArr:Array = [];

        var dataArr:Array = _showItemTable.findByProperty("poolID",poolType);
        for each(var info:ShowItem in dataArr)
        {
            if(info.tabID == tabIndex+1)
            {
                var itemData:CItemData = new CItemData();
                itemData.databaseSystem = _system.stage.getSystem(IDatabase) as IDatabase;
                itemData.updateDataByData(CItemData.createObjectData(info.itemID));
                resultArr.push(itemData);
            }
        }

        return resultArr;
    }

    /**
     * 得卡池所有预览物品(格斗家整卡和普通物品)
     * @return
     */
    public static function getCardPoolItems2(poolType:int, subPoolType:int = 0):Array
    {
        var resultArr:Array = [];
        var ss:Array = [];
        var s:Array = [];
        var a:Array = [];
        var b:Array = [];
        var c:Array = [];
        var other:Array = [];

//        var dataArr:Array;
//        if(isInNewServerTime())
//        {
//            dataArr = _newServerShowItem.findByProperty("poolID",poolType);
//        }
//        else
//        {
//            dataArr = _showItemTable.findByProperty("poolID",poolType);
//        }

        var tableArr:Array = _allShowItem.findByProperty("poolID",poolType);
        var dataArr:Array = [];
        for each(var info:AllShowItem in tableArr)
        {
            if(info.subPoolID == subPoolType)
            {
                dataArr.push(info);
            }
        }

        for each(info in dataArr)
        {
            var itemData:CItemData = new CItemData();
            itemData.databaseSystem = _system.stage.getSystem(IDatabase) as IDatabase;
            itemData.updateDataByData(CItemData.createObjectData(info.itemID));

//            if(CPlayerCardUtil.isHeroCardItem(itemData.ID))
//            {
            if(CItemUtil.isHeroItem(itemData))
            {
                var cardInfo:Object = CPlayerCardUtil.getHeroCardInfo(itemData.ID);
                var heroData:CPlayerHeroData = CPlayerCardUtil.getHeroDataById(cardInfo.roleId);
                var intelligence:int = heroData == null ? 0 : heroData.qualityBaseType;

                switch (intelligence)
                {
                    case 0:
                        c.push(itemData);
                        break;
                    case 1:
                        b.push(itemData);
                        break;
                    case 2:
                        a.push(itemData);
                        break;
                    case 3:
                        s.push(itemData);
                        break;
                    case 4:
                        ss.push(itemData);
                        break;
                }
            }
            else
            {
                other.push(itemData);
            }
        }

        resultArr.push(ss);
        resultArr.push(s);
        resultArr.push(a);
        resultArr.push(b);
        resultArr.push(c);
        resultArr.push(other);

        return resultArr;
    }

    /**
     * 是否能免费试酒
     * @return
     */
    public static function isCanFreeTry():Boolean
    {
        var currNum:int = (_system.getHandler(CPlayerCardManager) as CPlayerCardManager).currFreeNum;
        return currNum > 0;
    }

    /**
     * 是否酒券足以抽卡
     * @param ticketId 酒券id(普通/高级)
     * @param needNum 所需数量(单抽/10连抽)
     * @return
     */
    public static function isTicketEnough(ticketId:int,needNum:int):Boolean
    {
        var ownNum:int = CPlayerCardUtil.getOwnTicketNum(ticketId);
        return ownNum >= needNum;
    }

    public static function getShopData(itemId:int):CShopItemData
    {
        var shopData:CShopItemData;
//        var arr:Array = _shopItem.findByProperty("itemID",itemId);
        var tableArr:Array = _shopItem.toArray();
        for each(var item:ShopItem in tableArr)
        {
            if(item.shopID == EShopType.SHOP_TYPE_19 && item.itemID == itemId)
            {
                var shopItemId:int = item.ID;
                shopData = new CShopItemData();
                var obj:Object = {};
                obj[CShopItemData._shopItemID] = shopItemId;
                obj[CShopItemData._discount] = 10;
                obj[CShopItemData._currentSellNum] = -1;
                shopData.updateDataByData(obj);
            }
        }

//        if(arr && arr.length)
//        {
//            var shopItemId:int = (arr[0] as ShopItem).ID;
//            shopData = new CShopItemData();
//            var obj:Object = {};
//            obj[CShopItemData._shopItemID] = shopItemId;
//            obj[CShopItemData._discount] = 10;
//            obj[CShopItemData._currentSellNum] = -1;
//            shopData.updateDataByData(obj);
//        }

        return shopData;
    }

    /**
     * 是否为整卡
     * @return
     */
//    public static function isHeroCardItem(itemId:int):Boolean
//    {
//        var type:String = itemId.toString().charAt(0);
//        return type == "1";
//    }

    /**
     * 是否为酒券
     * @param itemId
     * @return
     */
    public static function isCardTicketItem(itemId:int):Boolean
    {
        var type:String = itemId.toString().charAt(0);
        return type == "2";
    }

    /**
     * 是否为格斗家碎片
     * @param itemId
     * @return
     */
    public static function isHeroChipsItem(itemId:int):Boolean
    {
        var type:String = itemId.toString().charAt(0);
        return type == "4";
    }

    /**
     * 整卡信息
     * @return
     */
    public static function getHeroCardInfo(itemId:int):Object
    {
        var idStr:String = itemId.toString();
        var star:int = int(idStr.slice(1,3));
        var roleId:int = int(idStr.slice(5,8));

        var qual:String;
        var quality:int = _playerBasicTable.findByPrimaryKey(roleId ).intelligence;
        if(quality == 5 || quality == 6)
        {
            qual = "R";
        }
        else if(quality == 7 || quality == 8)
        {
            qual = "SR";
        }
        else if(quality == 9 || quality == 10)
        {
            qual = "SSR";
        }

        var obj:Object = {};
        obj["star"] = star;
        obj["roleId"] = roleId;
        obj["quality"] = qual;

        return obj;
    }

    /**
     * 得卡池免费抽卡次数
     * @return
     */
    public static function getTotalFreeTimes(poolId:int):int
    {
        var tableData:FreeSet = _freeSetTable.findByPrimaryKey(poolId) as FreeSet;
        if(tableData)
        {
            return tableData.freetimes;
        }

        return 0;
    }

    /**
     * 免费抽卡是否在CD中
     * @return
     */
    public static function isInCD():Boolean
    {
//        var currTime:Number = CTime.getCurrentTimestamp();
        var currTime:Number = CTime.getCurrServerTimestamp();
        var expiredTime:Number = (_system.getHandler(CPlayerCardManager) as CPlayerCardManager).freeExpiredTime;

        if(expiredTime && expiredTime > currTime)
        {
            return true;
        }

        return false;
    }

    /**
     * 是否在活动时间内
     * @return
     */
    public static function isInActiveTime():Boolean
    {
        var tableData:CardPlayerActivity = _cardPlayerActivityTable.findByPrimaryKey(1);
        if(tableData)
        {
            var startDate:Date = CDateUtil.getDateByFullTimeString(tableData.startTime);
            var endDate:Date = CDateUtil.getDateByFullTimeString(tableData.endTime);
            return CDateUtil.isInDate(startDate,endDate);
        }

        return false;
    }

    /**
     * 显示格斗家招募界面
     */
    public static function showHeroGetView(cardData:CPlayerCardData):void
    {
        if(cardData)
        {
            var heroData:CPlayerHeroData;
            if(isHeroChipsItem(cardData.itemId))// 格斗家碎片
            {
                CPlayerCardUtil.HeroChipsNum = cardData.count;
            }
//            else if(isHeroCardItem(cardData.itemId))// 格斗家整卡
//            {
            if(CItemUtil.isHeroItem(cardData.itemData))
            {
                CPlayerCardUtil.HeroChipsNum = 0;
            }

            heroData = getHeroDataById(cardData.roleId);
            heroData.star = cardData.star;
            var playerUIHandler:CPlayerUIHandler = _system.stage.getSystem(CPlayerSystem ).getHandler(CPlayerUIHandler ) as CPlayerUIHandler;
            playerUIHandler.showHeroGetView(heroData);
        }
    }

    /**
     * 道具转换成格斗家碎片打开招募界面
     * @param response
     */
    public static function showHeroGetView2(response:ItemConvertToHeroPieceResponse):void
    {
        CPlayerCardUtil.HeroChipsNum = response.pieceCount;

        var heroData:CPlayerHeroData = getHeroDataById(response.heroId);
        heroData.star = response.star;
        var playerUIHandler:CPlayerUIHandler = _system.stage.getSystem(CPlayerSystem ).getHandler(CPlayerUIHandler ) as CPlayerUIHandler;
        playerUIHandler.showHeroGetView(heroData);
    }

    public static function getHeroDataById(roleId:int):CPlayerHeroData
    {
        if(roleId)
        {
            var manager:CPlayerManager = _system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
            var playerData:CPlayerData = manager.playerData;
            var heroData:CPlayerHeroData = playerData.heroList.createHero(roleId) as CPlayerHeroData;
            return heroData;
        }

        return null;
    }

    /**
     * 是否酒券足以抽卡
     * @return
     */
    public static function hasCardToPump():Boolean
    {
        return isTicketEnough(CPlayerCardConst.Common_Card_Id,CPlayerCardConst.Consume_Num_One)
               || isTicketEnough(CPlayerCardConst.Common_Card_Id,CPlayerCardConst.Consume_Num_Ten)
               || isTicketEnough(CPlayerCardConst.Better_Card_Id,CPlayerCardConst.Consume_Num_One)
               || isTicketEnough(CPlayerCardConst.Better_Card_Id,CPlayerCardConst.Consume_Num_Ten);
    }

    /**
     * 是否处于新服活动时间
     * @return
     */
    public static function isInNewServerTime():Boolean
    {
        var serverOpenDays:int = (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.systemData.openSeverDays;
        var serverOpenDate:Date = new Date(CTime.getCurrServerTimestamp());
        serverOpenDate.date -= (serverOpenDays - 1);
        CDateUtil.setZeroDate(serverOpenDate);

        var tableData:CardPlayerConstant = _cardPlayerConstant.findByPrimaryKey(1);
        if(tableData)
        {
            var serverEndDate:Date = new Date(serverOpenDate.time);// 新服活动结束日期
            serverEndDate.date += (tableData.newServerTime + 1);
        }

        return CDateUtil.isInDate(serverOpenDate, serverEndDate);
    }

    /**
     * 得起始抽卡次数
     * @return
     */
    public static function getFirstBeginCount(poolId:int):int
    {
        var tableData:CardPlayerPool = _cardPlayerPoolTable.findByPrimaryKey(poolId) as CardPlayerPool;
        if(tableData)
        {
            return tableData.fristBeginTime;
        }

        return 0;
    }

//==============================================table==================================================
    private static function get _bagManager():CBagManager
    {
        return _system.stage.getSystem(CBagSystem ).getBean(CBagManager) as CBagManager;
    }

    private static function get _dataBase():IDatabase
    {
        return _system.stage.getSystem(IDatabase) as IDatabase;
    }

    private static function get _cardPlayerPoolTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.CARDPLAYER_POOL);
    }

    private static function get _cardPlayerTimesTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.CARDPLAYER_TIMES);
    }

    private static function get _showItemTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.SHOWITEM);
    }

    private static function get _cardPlayerActivityTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.CARDPLAYER_ACTIVITY);
    }

    private static function get _europeanMoneyTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.EUROPEAN_MONEY);
    }

    private static function get _playerBasicTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_BASIC);
    }

    private static function get _freeSetTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.FREE_SET);
    }

    private static function get _shopItem():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.SHOP_ITEM);
    }

    private static function get _cardPlayerConstant():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.CARDPlAYERCONSTANT);
    }

    private static function get _newServerShowItem():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.NEWSERVERSHOWITEM);
    }

    private static function get _allShowItem():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.AllSHOWITEM);
    }
}
}
