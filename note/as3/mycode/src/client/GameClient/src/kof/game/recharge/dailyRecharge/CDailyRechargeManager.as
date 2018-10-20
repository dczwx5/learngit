//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/17.
 */
package kof.game.recharge.dailyRecharge {

import QFLib.Foundation.CTime;
import QFLib.Foundation.CTimer;

import flash.events.TimerEvent;

import flash.utils.Timer;

import kof.SYSTEM_ID;
import kof.framework.CAbstractHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.switching.CSwitchingSystem;
import kof.game.switching.validation.CSwitchingValidatorSeq;
import kof.message.Activity.EverydayRechargeResponse;
import kof.message.Activity.EverydayRechargeRewardResponse;

public class CDailyRechargeManager  extends CAbstractHandler
{
    public function CDailyRechargeManager()
    {
        super ();
    }
    public var m_nRechargeValue : int = -1;
    public var m_nSeverDays : int = -1;
    public var m_aRechargeData : Array;
    private var m_isClosed : Boolean;

    private var m_pValidater : CDailyRechargeValidater;
    private var m_pTrigger : CDailyRechargeTrigger;

    private var m_fCountDownTime : Number = 0;

    private var m_theRunTimer : Timer = null;
    private var m_theTimer: CTimer = null;

    public const Def_seleted : int = 2;
    override public function dispose() : void {
        super.dispose();

        m_pTrigger.dispose();
        m_pValidater.dispose();

        m_theRunTimer.stop();
        m_theRunTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
        m_theRunTimer = null;
        m_theTimer = null;
    }
    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        var switchingSystem : CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        m_pValidater = new CDailyRechargeValidater(system);
        switchingSystem.addValidator(m_pValidater);
        m_pTrigger = new CDailyRechargeTrigger();
        switchingSystem.addTrigger(m_pTrigger);

        m_theRunTimer = new Timer( 100 );
        m_theRunTimer.addEventListener( TimerEvent.TIMER, _onTimer );
        m_theRunTimer.stop();
        m_theTimer = new CTimer();
        return ret;
    }
    public function updateRechargeStateData( response : EverydayRechargeResponse) : void
    {
        m_nRechargeValue = response.everydayRecharge;
        m_nSeverDays = response.openServerDays;
        m_aRechargeData = response.receiveMap;
        if (response.openState == 0)
        {
            closeDailyRechargeSystem();
            m_isClosed = true;
        }
        else
        {
            startDailyRechargeSystem();

            if (getRewardCount() == 3)
            {
                stopSystemBundle();
            }

            var view : CDailyRechargeViewHandler = this.system.getBean( CDailyRechargeViewHandler ) as CDailyRechargeViewHandler;
            if ( null != view && view.isViewShow ) {
                view.updateView( );
            }
            _system.updateRedPoint(isHaveReward);
        }
    }


    public function updateReward( response : EverydayRechargeRewardResponse) : void
    {
        m_aRechargeData = response.receiveMap;
        _system.updateRedPoint(isHaveReward);
    }

    public function closeDailyRechargeSystem() : void
    {
        var sys : ISystemBundleContext =  ( system.stage.getSystem(CDailyRechargeSystem) as CDailyRechargeSystem).ctx;
        if( sys && !m_isClosed)
        {
            sys.unregisterSystemBundle(system.stage.getSystem(CDailyRechargeSystem) as CDailyRechargeSystem);
        }
    }

    public function startDailyRechargeSystem() : void{
        var sys : ISystemBundleContext =  ( system.stage.getSystem(CDailyRechargeSystem) as CDailyRechargeSystem).ctx;
        if( sys && m_isClosed)
        {
            sys.registerSystemBundle(system.stage.getSystem(CDailyRechargeSystem) as CDailyRechargeSystem);
            m_isClosed = false;
        }
    }

    //奖励领取次数
    public function getRewardCount() : int
    {
        var length : int = m_aRechargeData.length;
        var count : int = 0;
        for (var i : int = 0; i < length; ++i)
        {
            if (m_aRechargeData[i]["count"] == 1)
            {
                ++count;
            }
        }

        return count;
    }

    public function startSystemBundle() : void
    {
        if((system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(KOFSysTags.DAILY_RECHARGE))
        {
            return;
        }
        m_pValidater.valid = true;
        var pValidators : CSwitchingValidatorSeq = system.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
        if ( pValidators )
        {
            if ( pValidators.evaluate() )// 验证所有开启条件是否已达成
            {
                var vResult : Vector.<String> = pValidators.listResultAsTags();
                if ( vResult && vResult.length )
                {
                    if(vResult.indexOf(KOFSysTags.DAILY_RECHARGE) != -1)
                    {
                        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
                        if ( pSystemBundleContext ) {
                            pSystemBundleContext.startBundle( system as ISystemBundle );
                        }
                    }
                }
            }
        }
    }
    public function stopSystemBundle() : void {
        m_pValidater.valid = false;
　      var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext ) {
            pSystemBundleContext.stopBundle( system as ISystemBundle );
        }

        if (m_pValidater.valid == false)
        {
            _startTimeCountDown();
        }
    }

    private function _update(deltaTime : Number) : void
    {
        m_fCountDownTime -= deltaTime;
        if (m_fCountDownTime < 0)
        {
            if (m_fCountDownTime > -2) //10s作为服务器同步误差
            {
                startSystemBundle();
            }
            else
            {
                _stopTimeCountDown();
            }
        }
    }

    private function _startTimeCountDown () : void
    {
        var date : Date = new Date();
        var serverTime : Number = CTime.getCurrServerTimestamp();
        date.setTime(serverTime);
        m_fCountDownTime = (24 - date.hours) * 3600 - date.minutes * 60 - date.seconds;

        m_theRunTimer.start();
        m_theTimer.reset();

    }
    private function _stopTimeCountDown() : void
    {
        m_theRunTimer.stop();
    }
    private function _onTimer( e:TimerEvent ) : void
    {
        _update( m_theTimer.seconds() );
        m_theTimer.reset();
    }
    //通过页签获取领取状态
    //如果数据中有该索引，则已充值，返回领取状态，否则为未充值
    public function getRewardStateByIndex(index : int) : int
    {
        for each(var obj : Object in m_aRechargeData)
        {
            if(obj.rechargeValue == index)
            {
                return obj.count;
            }
        }
        return 0;
    }

    public function getRechargeTypeByIndex(index : int) : int
    {
        switch(index)
        {
            case 0:
                return 10;
            case 1:
                return 30;
            case 2:
                return 100;
        }
        return 1;
    }

    /**
     * 获取可领奖状态
     */
    public function get isHaveReward() : Boolean
    {
        var result : Boolean = false;
        var type : int;
        for(var i : int = 0; i < 3; i++)
        {
            type = getRechargeTypeByIndex(i);
            if(m_nRechargeValue >= type)//满足充值条件且并未领取
            {
                result = result || getRewardStateByIndex(type) == 0;
            }
        }
        return result;
    }

    /**
     * 获取可领奖页签
     */
    public function get rewandIndex() : int
    {
        var type : int;
        for(var i : int = 0; i < 3; i++)
        {
            type = getRechargeTypeByIndex(i);
            if(m_nRechargeValue >= type && getRewardStateByIndex(type) == 0)//满足充值条件且并未领取
            {
                return i;
            }
        }
        return Def_seleted;//如果没有可领奖，打开默认标签
    }
    private function get _system() : CDailyRechargeSystem
    {
        return system as CDailyRechargeSystem;
    }
}
}
