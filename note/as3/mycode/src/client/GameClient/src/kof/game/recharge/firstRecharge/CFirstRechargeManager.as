//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/3.
 */
package kof.game.recharge.firstRecharge {

import kof.framework.CAbstractHandler;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLogUtil;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.Activity.FirstRechargeRewardResponse;

public class CFirstRechargeManager extends CAbstractHandler
{
    public var m_nRewardStateId : int = -1;
    public function CFirstRechargeManager()
    {

    }
    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        m_nRewardStateId = playerData.systemData.firstRechargeState;

        if (m_nRewardStateId == 2)
        {
            closeFirstRechargeSystem();
        }
        else//0未充值和1已充值未领取，都是开启状态
        {
            var args : Object = new Object();
            args.sysID = _system.bundleID;
            args.state = 1;
            args.endTime = 0;
            if(_activityManager)
                _activityManager.updatePreviewDic(args);
            //=============add by Lune 0627======================================
            //用于收集活动开启预览数据
        }
        return ret;
    }

    public function updateFirstRechargeManager(response : FirstRechargeRewardResponse) : void
    {
        m_nRewardStateId = response.firstRechargeState;

        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            instanceSystem.callWhenInMainCity(_activeView,null,null,null,1);
        }

        var view : CFirstRechargeViewHandler = this.system.getBean( CFirstRechargeViewHandler ) as CFirstRechargeViewHandler;
        if ( null != view && view.isViewInitial ) {
            view.updateButton( m_nRewardStateId );
        }
    }

    private function _activeView() : void
    {
        if (m_nRewardStateId == 1)
        {
            (system.stage.getSystem(CFirstRechargeSystem) as CFirstRechargeSystem).setActivity(true);
            CLogUtil.recordLinkLog(system, 10004);
        }
    }


    public function closeFirstRechargeSystem() : void
    {
        var sys : ISystemBundleContext =  ( system.stage.getSystem(CFirstRechargeSystem) as CFirstRechargeSystem).ctx;
        if( sys )
        {
            sys.unregisterSystemBundle(system.stage.getSystem(CFirstRechargeSystem) as CFirstRechargeSystem);
            _activityManager.checkHavePreviewData();
        }
    }

    private function get playerData() : CPlayerData
    {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        return playerManager.playerData;
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
    private function get _system() : CFirstRechargeSystem
    {
        return system as CFirstRechargeSystem;
    }
}
}
