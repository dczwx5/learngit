//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/13.
 */
package kof.game.platformDownloadReward {

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.game.platform.EPlatformType;
import kof.game.player.CPlayerSystem;
import kof.table.PlatFormBoxLoginReward;

public class CPlatformBoxHelpHandler extends CAbstractHandler {
    public function CPlatformBoxHelpHandler()
    {
        super();
    }

    public function getRewards():Array
    {
        var tableDataArr:Array = _platFormBoxLoginReward.findByProperty("platformName", EPlatformType.PLATFORM_2144);

        if(tableDataArr && tableDataArr.length)
        {
            var rewardId:int = (tableDataArr[0] as PlatFormBoxLoginReward).boxLoginReward;
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, rewardId);
            if(rewardListData)
            {
                return rewardListData.list;
            }
        }

        return [];
    }

    /**
     * 是否从盒子登录
     * @return
     */
    public function isLoginFromBox():Boolean
    {
        var platformData:Object = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.platformData.platformInfo;
        if(platformData && platformData.data && platformData.data.hasOwnProperty("isBox") && platformData.data.isBox == true)
        {
            return true;
        }

        return false;
    }

//table===============================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _platFormBoxLoginReward():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PlatFormBoxLoginReward);
    }
}
}
