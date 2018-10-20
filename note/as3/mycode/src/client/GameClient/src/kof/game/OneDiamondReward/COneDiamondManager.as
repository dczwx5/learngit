//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/14.
 */
package kof.game.OneDiamondReward {

import kof.framework.CAbstractHandler;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.switching.CSwitchingSystem;
import kof.message.Activity.ActivityMessageResponse;
import kof.message.Activity.OneDiamondActivityRewardResponse;

public class COneDiamondManager  extends CAbstractHandler{
    public function COneDiamondManager()
    {
    }

    public var m_nState : int = -1;
    public var m_fEndTime : Number = -1;
    private var m_pValidater : COneDiamondValidater;
    private var m_pTrigger : COneDiamondTrigger;

    override public function dispose() : void {
        super.dispose();

        m_pTrigger.dispose();
        m_pValidater.dispose();
    }
    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        var switchingSystem : CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        m_pValidater = new COneDiamondValidater(system)
        switchingSystem.addValidator(m_pValidater);
        m_pTrigger = new COneDiamondTrigger();
        switchingSystem.addTrigger(m_pTrigger);
        return ret;
    }

    public function updateInitialState(response : ActivityMessageResponse) : void
    {
        m_nState = response.OneDiamondActivityState;
        m_fEndTime = response.endTime;
        var view : COneDiamondViewHandler;
        view = this.system.getBean( COneDiamondViewHandler ) as COneDiamondViewHandler;
        if (m_nState == 1 )
        {
            m_pValidater.valid = true;
            m_pTrigger.notifyUpdated();
            if ( null != view && view.isUiInitialized ) {
                view.updateState( m_nState, m_fEndTime);
            }
        }
        else if (m_nState == 2)
        {
            closeOneDiamondSystem();
        }
    }
    public function updateRewardState( response : OneDiamondActivityRewardResponse) : void
    {
        m_nState = response.OneDiamondActivityState;

        if (m_nState > 0)
        {
            var view : COneDiamondViewHandler;
            view = this.system.getBean( COneDiamondViewHandler ) as COneDiamondViewHandler;
            if ( null != view && view.isUiInitialized ) {
                view.updateState( m_nState, m_fEndTime );
            }
        }
    }

    public function openOneDiamondSystem(endTime : Number) : void
    {
        m_fEndTime = endTime;
        m_nState = 1;

        m_pValidater.valid = true;
        m_pTrigger.notifyUpdated();

        var view : COneDiamondViewHandler;
        view = this.system.getBean( COneDiamondViewHandler ) as COneDiamondViewHandler;
        if ( null != view && view.isUiInitialized ) {
            view.updateState( m_nState, m_fEndTime );
        }
    }
    public function closeOneDiamondSystem() : void
    {
        var sys : ISystemBundleContext =  ( system.stage.getSystem(COneDiamondSystem) as COneDiamondSystem).ctx;
        if( sys )
        {
            sys.unregisterSystemBundle(system.stage.getSystem(COneDiamondSystem) as COneDiamondSystem);
            //获取活动预览数据
            //==========add by Lune 0702===================================
            var args : Object = new Object();
            args.sysID = _system.bundleID;
            args.state = 2;
            args.endTime = 0;
            if(_activityManager)
            {
                _activityManager.updatePreviewDic(args);
                _activityManager.checkHavePreviewData();
            }
            //==========add by Lune 0702===================================
        }
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
    private function get _system() : COneDiamondSystem
    {
        return system as COneDiamondSystem;
    }
}
}
