//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/9/20.
 */
package kof.game.welfarehall {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.Tutorial.CTutorSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLogUtil;
import kof.game.instance.CInstanceSystem;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.welfarehall.data.CAdvertisementData;
import kof.game.welfarehall.data.CAnnouncementData;
import kof.game.welfarehall.data.CRechargeWelfareData;
import kof.game.welfarehall.data.WelfareHallConst;
import kof.game.welfarehall.view.CActivationCodeViewHandler;
import kof.game.welfarehall.view.CAdvertisingViewHandler;
import kof.game.welfarehall.view.CAnnouncementViewHandler;
import kof.game.welfarehall.view.CNoticeViewHandler;
import kof.game.welfarehall.view.CRechargeWelfareViewHandler;
import kof.game.welfarehall.view.CRecoveryViewHandler;
import kof.game.welfarehall.view.CWechatGifViewHandler;
import kof.game.welfarehall.view.CWelfareHallViewHandler;

import morn.core.handlers.Handler;

public class CWelfareHallSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var _pCWelfareHallHandler : CWelfareHallHandler;

    private var _pCWelfareHallManager : CWelfareHallManager;

    private var _pCWelfareHallViewHandler : CWelfareHallViewHandler;

    private var _pCActivationCodeViewHandler : CActivationCodeViewHandler;

    private var m_pAnnouncementViewHandler : CAnnouncementViewHandler;

    private var m_pNoticeViewHandler : CNoticeViewHandler;

    private var m_pAdvertisingViewHandler : CAdvertisingViewHandler;

    private var _wechatGifViewHandler : CWechatGifViewHandler;

    private var _rechargeWelfareHandler : CRechargeWelfareViewHandler;

    private var m_pHelpHandler:CWelfareHelpHandler;

    private var _recoveryViewHandler : CRecoveryViewHandler;

    private var _panelViewAry : Array ;

    private var rechargeData:CRechargeWelfareData;

    public function CWelfareHallSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pCWelfareHallHandler = new CWelfareHallHandler() );
            this.addBean( _pCWelfareHallManager = new CWelfareHallManager() );
            this.addBean( _pCWelfareHallViewHandler = new CWelfareHallViewHandler() );
            this.addBean( _pCActivationCodeViewHandler = new CActivationCodeViewHandler() );
            this.addBean( m_pAnnouncementViewHandler = new CAnnouncementViewHandler() );
            this.addBean( m_pNoticeViewHandler = new CNoticeViewHandler() );
            this.addBean( m_pAdvertisingViewHandler = new CAdvertisingViewHandler() );
            this.addBean( _wechatGifViewHandler = new CWechatGifViewHandler() );
            this.addBean( _recoveryViewHandler = new CRecoveryViewHandler() );
            this.addBean( m_pHelpHandler = new CWelfareHelpHandler());
            //暂不打开返利功能1
            //this.addBean( _rechargeWelfareHandler = new CRechargeWelfareViewHandler() );
            //this.addBean( m_pHelpHandler = new CWelfareHelpHandler() );

            rechargeData = _pCWelfareHallManager.data;
            //按tab顺序
            //panelViewAry = [_pCActivationCodeViewHandler,m_pAnnouncementViewHandler,m_pNoticeViewHandler,
            //_wechatGifViewHandler,_bargainCardViewHandler];
            //暂不打开返利功能2
            panelViewAry = [m_pAnnouncementViewHandler, _pCActivationCodeViewHandler,m_pNoticeViewHandler,_recoveryViewHandler];
        }

        _pCWelfareHallViewHandler.closeHandler = new Handler( _onViewClosed );
        return m_bInitialized;
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CWelfareHallViewHandler = this.getHandler( CWelfareHallViewHandler ) as CWelfareHallViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        var typeArr : * = ctx.getUserData( this, CBundleSystem.WELFARE_HALL_TYPE , false );
        var type:int = 0;
        if( typeArr ){
            type = typeArr[0];
        }

        if ( value ) {
            pView.addDisplay( type );
        } else {
            //设置默认打开第1项
            ctx.setUserData( this, CBundleSystem.WELFARE_HALL_TYPE, true );
            ctx.setUserData( this, CBundleSystem.WELFARE_HALL_TYPE, false );
            pView.removeDisplay();
            dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.WELFAREHALL_VIEW_CLOSE ));
        }
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        //获取福利信息
        _pCWelfareHallHandler.foreverRechargeInfoRequest(1);

        _addListeners();

        _pCWelfareHallHandler.advertisementListRequest();
        //获取资源找回信息
        _pCWelfareHallHandler.findRewardsDataRequest();
    }

    public function redTips(bool : Boolean):void
    {
        // 登陆时主界面图标提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, bool);
        }
    }
    private function updateRedPoint(e : CWelfareHallEvent):void
    {
        var bool : Boolean = _pCWelfareHallManager.hasRecoveryReward;
        redTips(bool);
    }

    private function _addListeners():void
    {
        this.addEventListener(CWelfareHallEvent.ANNOUNCEMENT_UPDATE, _onAnnouncementListHandler);
        this.addEventListener(CWelfareHallEvent.ADVERTISING_UPDATE, _onAdvertisingHandler);
        this.addEventListener(CWelfareHallEvent.UPDATE_RED_POINT , updateRedPoint );

    }

    private function _removeListeners():void
    {
        this.removeEventListener(CWelfareHallEvent.ANNOUNCEMENT_UPDATE, _onAnnouncementListHandler);
        this.removeEventListener(CWelfareHallEvent.ADVERTISING_UPDATE, _onAdvertisingHandler);
        this.removeEventListener(CWelfareHallEvent.UPDATE_RED_POINT , updateRedPoint );

    }

    private function _onAnnouncementListHandler(e:Event = null):void
    {
        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem.isMainCity)
        {
            var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleContext)
            {
                var currState:Boolean = pSystemBundleContext.getUserData(this,CBundleSystem.ACTIVATED,false);
                var announcementList:Vector.<CAnnouncementData> = _pCWelfareHallManager.announcementListData;
                if(!currState && announcementList && announcementList.length && !(stage.getSystem(CTutorSystem) as CTutorSystem).isPlaying)
                {
                    _showAnnouncementWin();
                }
            }
        }
        else
        {
            instanceSystem.callWhenInMainCity(_showAnnouncementWin, null, null, null, 1);
        }
    }

    private function _showAnnouncementWin():void
    {
        var bundleCtx:ISystemBundleContext = stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.WELFARE_HALL));
        bundleCtx.setUserData(systemBundle, CBundleSystem.WELFARE_HALL_TYPE, [WelfareHallConst.ANNOUNCEMENT]);
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    private function _onAdvertisingHandler(e:Event = null):void
    {
        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem.isMainCity)
        {
            var advertisementList:Vector.<CAdvertisementData> = _pCWelfareHallManager.advertisementListData;
            if(advertisementList && advertisementList.length && !(stage.getSystem(CTutorSystem) as CTutorSystem).isPlaying)
            {
                _showAdvertisingWin();
            }
        }
        else
        {
            instanceSystem.callWhenInMainCity(_showAdvertisingWin, null, null, null, 2);
        }
    }

    private function _showAdvertisingWin():void
    {
        m_pAdvertisingViewHandler.addDisplay();
        CLogUtil.recordLinkLog(this, 10001);
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }
    public function set panelViewAry(value : Array) : void
    {
        _panelViewAry = value;
    }
    public function get panelViewAry() : Array
    {
        return _panelViewAry;
    }
    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.WELFARE_HALL );
    }
    public override function dispose() : void {
        super.dispose();

        _pCWelfareHallHandler.dispose();
        _pCWelfareHallManager.dispose();
        _pCWelfareHallManager.dispose();
        _pCActivationCodeViewHandler.dispose();
        m_pAnnouncementViewHandler.dispose();
        _wechatGifViewHandler.dispose();
        _rechargeWelfareHandler.dispose();
        _recoveryViewHandler.dispose();
        _removeListeners();
    }
}
}
