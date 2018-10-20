//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard.util {

import QFLib.Foundation.CTime;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.ESystemBundlePropertyType;
import kof.game.bundle.ISystemBundleContext;
import kof.game.enum.EItemType;
import kof.game.equipCard.CEquipCardSystem;
import kof.game.equipCard.Enum.EEquipCardOpenType;
import kof.game.equipCard.util.CEquipCardUtil;
import kof.game.item.CItemData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.playerCard.util.ECardPoolType;
import kof.game.shop.data.CShopItemData;
import kof.table.EquipCardPool;
import kof.table.EquipShowItem;
import kof.table.Item;
import kof.table.ShopItem;

public class CEquipCardUtil {

    private static var _system : CAppSystem;
    public static var IsInPumping:Boolean;// 是否正在抽卡中
    public static var IsSkipAnimation:Boolean;// 是否跳过动画

    public function CEquipCardUtil()
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

        var dataArr:Array = _showItemTable.findByProperty("poolID",getCurrPoolId());
        for each(var info:EquipShowItem in dataArr)
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
     * 卡池中价值含量高的物品
     * @return
     */
    public static function getDisplayItemsInPool(lastItem:CItemData = null):Array
    {
        var resultArr:Array = [];

        var dataArr:Array = _showItemTable.findByProperty("poolID",getCurrPoolId());
        var arr:Array = [];
        if(lastItem == null)
        {
            arr = dataArr.slice(0,6);
        }
        else
        {
            var startIndex:int;
            for(var i:int = 0; i < dataArr.length; i++)
            {
                if(dataArr[i].itemID == lastItem.ID)
                {
                    startIndex = i + 1;
                    break;
                }
            }

            if(startIndex + 6 <= dataArr.length)
            {
                arr = dataArr.slice(startIndex, startIndex + 6);
            }
            else
            {
                arr = dataArr.slice(startIndex, dataArr.length-1);
                var diffNum:int = 6 - arr.length;
                arr = arr.concat(dataArr.slice(0, diffNum));
            }
        }

//        for each(var info:EquipShowItem in dataArr)
//        {
//            if(info.showPosID > 0)
//            {
//                arr.push(info);
//            }
//        }
//
//        arr.sortOn("showPosID",Array.NUMERIC);


        for each(var info:EquipShowItem in arr)
        {
            var itemData:CItemData = new CItemData();
            itemData.databaseSystem = _system.stage.getSystem(IDatabase) as IDatabase;
            itemData.updateDataByData(CItemData.createObjectData(info.itemID));
            resultArr.push(itemData);
        }

        return resultArr;
    }

//    public static function getNextItemsOnRoll(page:int):Array
//    {
//        var dataArr:Array = _showItemTable.findByProperty("poolID",getCurrPoolId());
//
//        var totalPage:int = int(Math.ceil(dataArr.length / 4));
//        var currPage:int = int(page % totalPage);
//
//        if(currPage == 0)
//        {
//            return getGoodItemsInPool();
//        }
//
//        var starIndex:int = currPage * 4;
//        var endIndex:int = (currPage + 1) * 4;
//
//        var resultArr:Array = [];
//        var arr:Array = dataArr.slice(starIndex, endIndex);
//        for each(var info:EquipShowItem in arr)
//        {
//            var itemData:CItemData = new CItemData();
//            itemData.databaseSystem = _system.stage.getSystem(IDatabase) as IDatabase;
//            itemData.updateDataByData(CItemData.createObjectData(info.itemID));
//            resultArr.push(itemData);
//        }
//
//        return resultArr;
//    }

    /**
     * 是否酒券足以抽卡
     * @param ticketId 酒券id(普通/高级)
     * @param needNum 所需数量(单抽/10连抽)
     * @return
     */
    public static function isTicketEnough(ticketId:int,needNum:int):Boolean
    {
        var ownNum:int = CEquipCardUtil.getOwnTicketNum(ticketId);
        return ownNum >= needNum;
    }

    public static function getShopData(itemId:int):CShopItemData
    {
        var shopData:CShopItemData;
        var arr:Array = _shopItem.findByProperty("itemID",itemId);
        if(arr && arr.length)
        {
            var shopItemId:int = (arr[0] as ShopItem).ID;
            shopData = new CShopItemData();
            var obj:Object = {};
            obj[CShopItemData._shopItemID] = shopItemId;
            obj[CShopItemData._discount] = 10;
            obj[CShopItemData._currentSellNum] = -1;
            shopData.updateDataByData(obj);
        }

        return shopData;
    }

    /**
     * 是否为整卡
     * @return
     */
    public static function isHeroCardItem(itemId:int):Boolean
    {
        var type:String = itemId.toString().charAt(0);
        return type == "1";
    }

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

    public static function getHeroDataById(roleId:int):CPlayerHeroData
    {
        if(roleId)
        {
            var manager:CPlayerManager = _system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
            var playerData:CPlayerData = manager.playerData;
            var heroData:CPlayerHeroData = playerData.heroList.getHero(roleId) as CPlayerHeroData;
            return heroData;
        }

        return null;
    }

    /**
     * 是否斗魂
     * @return
     */
    public static function isDouSoul(itemId:int):Boolean
    {
        var itemInfo:Item = _item.findByPrimaryKey(itemId) as Item;
        if(itemInfo)
        {
            return itemInfo.type == EItemType.ITEM_TYPE_701;
        }

        return false;
    }

    /**
     * 是否道具足以抽卡
     * @return
     */
    public static function hasCardToPump():Boolean
    {
        return isTicketEnough(CEquipCardConst.Common_Card_Id,CEquipCardConst.Consume_Num_One)
                || isTicketEnough(CEquipCardConst.Common_Card_Id,CEquipCardConst.Consume_Num_Ten);
    }

    public static function getCurrPoolId():int
    {
        var bundleCtx:ISystemBundleContext = _system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var openWay:int = bundleCtx.getUserData(_system as CEquipCardSystem, ESystemBundlePropertyType.Type_SystemOpenWay);

        var poolId:int;
        switch(openWay)
        {
            case EEquipCardOpenType.OPEN_TYPE_ICON:
                poolId = 1;
                break;
            case EEquipCardOpenType.OPEN_TYPE_ACTIVE:
                poolId = 2;
                break;
            default:
                poolId = 1;
                break;
        }

        return poolId;
    }

    /**
     * 得起始抽卡次数
     * @return
     */
    public static function getFirstBeginCount(poolId:int):int
    {
        var tableData:EquipCardPool = _equipCardPoolTable.findByPrimaryKey(poolId) as EquipCardPool;
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

    private static function get _equipCardPoolTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.EQUIPCARD_POOL);
    }

    private static function get _showItemTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.EQUIPSHOWITEM);
    }

    private static function get _europeanMoneyTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.EUROPEAN_MONEY);
    }

    private static function get _playerBasicTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_BASIC);
    }

    private static function get _shopItem():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.SHOP_ITEM);
    }

    private static function get _item():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.ITEM);
    }
}
}
