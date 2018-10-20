//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/24.
 */
package kof.game.common.view.reward {


import kof.framework.CViewHandler;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.view.part.CRewardItemListView;

import morn.core.components.View;

public class CShowRewardViewUtil {
    // rewardData :
    // int : packageID
    // CRewardListData :
    // array : rewardList
    public static function show(rootView:CViewHandler, parentUI:View, rewardData:*, isShowCurrency:Boolean = true) : void {
        var externalUtil:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, rootView, parentUI);
        (externalUtil.view as CRewardItemListView).isShowCurrency = isShowCurrency;
        externalUtil.show();
        externalUtil.setData(rewardData);
        externalUtil.updateWindow();
    }
}
}
