//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/6/28.
 */
package kof.game.LotteryActivity {

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.table.BundleEnable;

import morn.core.handlers.Handler;

public class CLotteryActivitySystem  extends CBundleSystem implements ISystemBundle{{
    private var _mainView :CLotteryActivityMainView;
    private var _manager : CLotteryActivityManager;
    private var _netHandler : CLotteryActivityNetHander;
    public function CLotteryActivitySystem() {
        super();
    }
    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.ACTIVITY_LOTTERY);
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
        ret = ret && addBean( _mainView = new CLotteryActivityMainView() );
        ret = ret && addBean( _manager = new CLotteryActivityManager() );
        ret = ret && addBean( _netHandler = new CLotteryActivityNetHander() );

        if(ret)
        {
            _mainView.closeHandler = new Handler( onViewClosed);
        }
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
        }
        //(stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        return ret;
    }
    private var _isCarnivalActivityStart : Boolean;
    private function _onSystemBundleStateChangedHandler( event : CSystemBundleEvent ) : void {
        if( _isCarnivalActivityStart )
            return;
        var bundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.CARNIVAL_ACTIVITY ) ) );
        if( iStateValue == CSystemBundleContext.STATE_STARTED ){
            _isCarnivalActivityStart = true;
            _netHandler.LotteryActivityRequest();
        }
    }

    override protected function onActivated(value : Boolean) : void
    {
        super.onActivated(value);
        if(value)
        {
            _mainView.addDisplay();
        }
        else
        {
            _mainView.removeDisplay();
            //抽奖次数用完活动入口关闭
            if(_manager.count >= 10)
                _manager.closeActivity();
        }
    }
    public function onViewClosed() : void
    {
        this.setActivated(false);
    }
    public function changeActivityState( bool:Boolean ) : void
    {
        if(bool)
        {
            this.ctx.startBundle(this);
        }
        else
        {
            this.ctx.stopBundle(this);
            var pView : CLotteryActivityMainView = this.getBean( CLotteryActivityMainView);
            if(pView) pView.removeDisplay();//如果界面开着，就强制关掉
        }
    }
    public function get ConfigLevel():int
    {
        var pDB : IDatabase = stage.getSystem( IDatabase ) as IDatabase;
        if( !pDB ) return 0;
        var pTable : IDataTable = pDB.getTable( KOFTableConstants.BUNDLE_ENABLE );
        if( !pTable ) return 0;
        var arr : Array = pTable.toArray();
        for each ( var v : BundleEnable in arr )
        {
            if ( v.ID == bundleID )
                return v.MinLevel;
        }
        return 0;
    }
    /**
     * 背包物品更新
     * @param e
     */
    protected function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if( e.type == CBagEvent.BAG_UPDATE)
        {
            if(_mainView)
                _mainView.updateTicketState();
            updateRedPoint();
        }
    }
    // 主界面图标提示
    public function updateRedPoint() : void
    {
        var bool : Boolean = _manager.hasKeyNum >= _manager.needKeyNum && _manager.count < 10;
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( bundleID );
        if ( pSystemBundleContext && pSystemBundle ) {
            pSystemBundleContext.setUserData( this, CBundleSystem.NOTIFICATION, bool);
        }
    }

    }
}
}
