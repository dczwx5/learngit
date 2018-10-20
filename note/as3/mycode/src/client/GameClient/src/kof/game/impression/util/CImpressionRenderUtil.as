//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/25.
 */
package kof.game.impression.util {

import kof.framework.CAppSystem;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;
import kof.ui.imp_common.RewardItemUI;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.handlers.Handler;

public class CImpressionRenderUtil {

    private static var _system:CAppSystem;

    public function CImpressionRenderUtil() {
    }

    public static function initialize( gSystem : CAppSystem ) : void {
        _system = gSystem;
    }

    public static function renderItem( item:Component, index:int):void
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
            if(itemData.num > 1)
            {
                rewardItem.num_lable.text = itemData.num.toString();
            }

            rewardItem.icon_image.url = itemData.iconSmall;
            rewardItem.bg_clip.index = itemData.quality;
        }
        else
        {
            rewardItem.num_lable.text = "";
            rewardItem.icon_image.url = "";
        }

        rewardItem.toolTip = new Handler( _showTips, [rewardItem] );
    }

    /**
     * 物品tips
     * @param item
     */
    private static function _showTips(item:RewardItemUI):void
    {
        (_system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    public static function renderStar( item:Component, index:int):void
    {
        if(!(item is Box))
        {
            return;
        }

        var box:Box = item as Box;
        var star:Image = box.getChildAt(0) as Image;
        var showState:int = box.dataSource as int;
        if(showState == 1)
        {
            star.skin = "png.juese.star_big";
        }
        else if(showState == 2)
        {
            star.skin = "png.juese.star_big_di";
        }
    }
}
}
