//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/9/10.
 * 这里使用双系统共有manager，net，view
 * 本系统关闭，右上角图标隐藏
 */
package kof.game.bargainCard {

import QFLib.Foundation.CTime;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.util.CSharedObject;

import morn.core.handlers.Handler;

public class CBargainCardSystem extends CBundleSystem implements ISystemBundle{
//    private var _mainView : CBargainCardView;
//    private var _manager : CBargainCardManager;
//    private var _netHandler : CBargainCardNetHandler;
    public function CBargainCardSystem() {
    }
    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.BARGAINCARD);
    }
    override public function dispose():void
    {
        super.dispose();
    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
            return false;
        var ret : Boolean = super.initialize();
//        ret = ret && addBean( _mainView = new CBargainCardView() );
//        ret = ret && addBean( _manager = new CBargainCardManager() );
//        ret = ret && addBean( _netHandler = new CBargainCardNetHandler() );
//        _mainView.closeHandler = new Handler( _onViewClosed);
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD, _updateData );
        return ret;
    }

    override protected function onBundleStart(pCtx : ISystemBundleContext) : void
    {
        closeSystem();
        //用<角色id+系统id+日期>当key去缓存中去状态,如果取不到则为当天第一次登录
        var selfRoleId:Number = (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.ID;
        var dateStr : String = CTime.formatYMDStr(CTime.getCurrServerTimestamp());
        var key : String = selfRoleId  + bundleID + dateStr;
        var bool : Boolean = CSharedObject.readFromSharedObject(key);
        if(bool) return;
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if(pSystemBundleContext && _buyMonthCardSystem)
        {
            _buyMonthCardSystem.manager.firstOpen = true;
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, _buyMonthCardSystem.manager.firstOpen);
        }
    }
    override protected function onBundleStop(pCtx : ISystemBundleContext) : void
    {
        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD, _updateData );
    }
    //小红点
    public function updateRedTips() : void
    {
        var bool : Boolean = _buyMonthCardSystem.manager.silverRewardState || _buyMonthCardSystem.manager.goldRewardState || _buyMonthCardSystem.manager.firstOpen ;
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, bool);
        }
    }

    override protected function onActivated(value : Boolean) : void
    {
        super.onActivated(value);
        _buyMonthCardSystem.onActivatedCallBack(value);
        if(value)
        {
            _buyMonthCardSystem.mainView.addDisplay();
            //用<角色id+系统id+日期>当key去缓存中去状态,如果取不到则为当天第一次登录
            var selfRoleId:Number = (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.ID;
            var dateStr : String = CTime.formatYMDStr(CTime.getCurrServerTimestamp());
            var key : String = selfRoleId  + bundleID + dateStr;
            var bool : Boolean = CSharedObject.readFromSharedObject(key);
            if(!bool)
            {
                CSharedObject.writeToSharedObject(key,true);
                _buyMonthCardSystem.manager.firstOpen = false;
            }
            updateRedTips();
        }
        else
        {
            _buyMonthCardSystem.mainView.removeDisplay();
        }
    }
    public function onViewClosed() : void
    {
        this.setActivated(false);
    }
    protected function _updateData( e : CPlayerEvent ) : void {
        if ( e.type == CPlayerEvent.PLAYER_MONTH_AND_WEEK_CARD )
        {
            if(_buyMonthCardSystem.mainView.isOpen)
            {
                _buyMonthCardSystem.mainView.closeBargainSystemCB = closeSystem;
            }
            else
            {
                closeSystem();
            }
        }
    }
    private function closeSystem() : void
    {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var goldState : Boolean = _playerSystem.playerData.monthAndWeekCardData.goldCardState;
        if ( pSystemBundleCtx )
        {
            if(goldState)//激活月卡，关闭图标
            {
                pSystemBundleCtx.stopBundle( this );
            }
        }
    }
    private function get _playerSystem() : CPlayerSystem {
        return stage.getSystem( CPlayerSystem ) as CPlayerSystem
    }
    private function get _buyMonthCardSystem() : CBuyMonthCardSystem
    {
        return stage.getSystem(CBuyMonthCardSystem) as CBuyMonthCardSystem;
    }
}
}
