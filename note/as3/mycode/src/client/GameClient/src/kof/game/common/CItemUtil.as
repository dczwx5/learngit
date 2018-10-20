//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/24.
 */
package kof.game.common {

import kof.framework.CAppSystem;
import kof.game.common.item.EItemCategory;
import kof.game.common.item.EItemGroup;
import kof.game.currency.enum.ECurrencyType;
import kof.game.enum.EItemType;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.CItemViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.imp_common.ItemUIUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CItemUtil {
    public function CItemUtil() {
    }

    /**
     * 是否格斗家整卡物品
     * @return
     */
    public static function isHeroItem(itemData:CItemData):Boolean
    {
//        var group:int = int(itemId.toString().charAt(0));
//
//        return itemId > 10000000 && group == EItemGroup.AbilityProp;

        if(itemData && itemData.itemRecord)
        {
            return itemData.itemRecord.type == EItemType.ITEM_TYPE_HERO;
        }

        return false;
    }


    /**
     * 是否格斗家碎片
     * @param itemId
     * @return
     */
    public static function isHeroChips(itemId:int):Boolean
    {
        var group:int = int(itemId.toString().charAt(0));
        var category:int = int(itemId.toString().slice(1,3));

        return group == EItemGroup.Chip && category == EItemCategory.Chip_Hero;
    }

    public static function getItemRenderFunc(system:CAppSystem, itemSize:int = 0):Function
    {
        if(itemSize == 0)
        {
            return (system.stage.getSystem(CItemSystem ).getHandler(CItemViewHandler) as CItemViewHandler).renderItem;
        }
        else
        {
            return (system.stage.getSystem(CItemSystem ).getHandler(CItemViewHandler) as CItemViewHandler).renderBigItem;
        }
    }
    public static function getBigItemRenderByHeroDataFunc(system:CAppSystem) : Function {
        return (system.stage.getSystem(CItemSystem ).getHandler(CItemViewHandler) as CItemViewHandler).renderBigItemByHeroData;
    }

    /**
     * 得货币名字
     * @param id 货币类型
     * @return
     */
    public static function getCurrencyNameById(id:int):String
    {
        return CLang.Get(id+"");
    }
}
}
