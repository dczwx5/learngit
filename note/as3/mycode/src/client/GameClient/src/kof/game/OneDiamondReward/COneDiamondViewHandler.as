//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/14.
 */
package kof.game.OneDiamondReward {

import QFLib.Foundation.CTime;


import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.setTimeout;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CLogUtil;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.platform.CPlatformHandler;
import kof.game.platform.EPlatformType;
import kof.game.platform.xiyou.CXiyouDataManager;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.table.OneDiamondActivityConfig;
import kof.ui.master.OneDiamondReward.OneDiamondRewardUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class COneDiamondViewHandler extends CViewHandler
{
    public function COneDiamondViewHandler()
    {
        super(false);
    }

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI : OneDiamondRewardUI;
    private var m_pCloseHandler : Handler;
    private var m_fCountDownTime : Number = 1000000;
    override public function get viewClass() : Array
    {
        return [ OneDiamondRewardUI ];
    }
    protected override function get additionalAssets() : Array {
        return ["frameclip_item2.swf"];
    }
    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new OneDiamondRewardUI();

                m_pViewUI.list_reward.renderHandler = new Handler( CItemUtil.getItemRenderFunc(_system) );
                m_pViewUI.closeHandler = new Handler( _onClose );

                m_bViewInitialized = true;
            }
        }

        m_pViewUI.text_rewardSuccess.visible = false;
        m_pViewUI.btn_reward.visible = true;
        _updateOneDiamondManagerInitialState();

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }
    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addPopupDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    /**
     * 飘字提示
     * @param str
     * @param type
     */
    public function get isViewShow():Boolean
    {
        if(m_pViewUI && m_pViewUI.parent)
        {
            return true;
        }

        return false;
    }
    public function get isUiInitialized() : Boolean
    {
        if (m_pViewUI)
            return true;
        return false;
    }


    private function _initView():void {
        if ( m_pViewUI )
        {
            var configInfo:OneDiamondActivityConfig = _getOneDiamondConfig();
            if(configInfo)
            {
                var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, configInfo.rewardID);
                if(rewardListData)
                {
                    if(m_pViewUI.list_reward)
                    {
                        m_pViewUI.list_reward.dataSource = rewardListData.list;
                    }
                }
            }
            schedule(1,update);
        }
        _showQrcode();
    }
    /**
     * 显示平台二维码
     * add by Lune 0807
     */
    private function _showQrcode() : void
    {
        var platform : CPlatformHandler = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).platform;
        if(!platform || !platform.data)
        {
            m_pViewUI.box_qrcode.visible = false;
            return;
        }
        switch(platform.data.platform)
        {
            case EPlatformType.PLATFORM_XIYOU:
            {
                m_pViewUI.box_qrcode.visible = true;
                var xiyouManager : CXiyouDataManager = platform.getBean( CXiyouDataManager ) as CXiyouDataManager;
                var bmpZFB : BitmapData = xiyouManager.qrBmpZFB;
                if(bmpZFB)
                {
                    m_pViewUI.img_zfb.bitmapData = bmpZFB;
                }
                else//如果未缓存到，重新请求
                {
                    xiyouManager.onQrcodeXiyouRequest(1);
                    xiyouManager.onQrcodeXiyouRequest(2);
                    xiyouManager.loadCompleteCallBackWX(function requestWX():void
                    {
                        m_pViewUI.img_wx.bitmapData = xiyouManager.qrBmpWX;

                    });
                    xiyouManager.loadCompleteCallBackZFB(function requestZFB():void
                    {
                        m_pViewUI.img_zfb.bitmapData = xiyouManager.qrBmpZFB;
                    });
                }
                break;
            }
            default:
            {
                m_pViewUI.box_qrcode.visible = false;
            }
        }
    }

    private function _getOneDiamondConfig() : OneDiamondActivityConfig
    {
        var table:IDataTable = (system.stage.getSystem(CDatabaseSystem) as IDatabase).getTable(KOFTableConstants.OneDiamondReward);
        if(table)
        {
            return table.findByPrimaryKey(1) as OneDiamondActivityConfig;
        }

        return null;
    }
    public function updateState(state : int, endTime : Number) : void
    {
        if (state == 1)
        {
            m_pViewUI.btn_reward.visible = true;
            m_pViewUI.text_rewardSuccess.visible = false;
            m_fCountDownTime = endTime - CTime.getCurrServerTimestamp();

            var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( KOFSysTags.ONE_DIAMOND_REWARD ));
            if ( pSystemBundleContext && pSystemBundle)
            {
                pSystemBundleContext.setUserData(system as COneDiamondSystem, CBundleSystem.TIME_COUNTDOWN, m_fCountDownTime);
            }
        }
        else if (state == 2)
        {
            _flyItem();
            m_pViewUI.btn_reward.visible = false;
            m_pViewUI.text_rewardSuccess.visible = true;
            m_fCountDownTime = 0;
            _onClose();
        }
    }

    public function update(delta : Number) : void
    {
        m_fCountDownTime -= 1000 * delta;
        if (m_fCountDownTime > 0)
        {
            m_pViewUI.text_countDown.text = _toDurTimeSpaceString(m_fCountDownTime);
        }
        else
        {
            m_pViewUI.text_countDown.text = "活动结束";
            m_pViewUI.text_countDown.align = "center";
            var manager : COneDiamondManager = system.getBean( COneDiamondManager ) as COneDiamondManager;
            manager.m_nState = 2;
            unschedule(update);
        }
    }
    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();
            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    private function _onClose(type : String = "") : void
    {
        if ( this.closeHandler )
        {
            this.closeHandler.execute();
        }
    }
    private function _addListeners():void
    {
        m_pViewUI.addEventListener(MouseEvent.CLICK, _onClickHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.removeEventListener(MouseEvent.CLICK, _onClickHandler);
    }

    private function _onClickHandler(e:MouseEvent):void
    {
        if( e.target == m_pViewUI.btn_reward)
        {
            var blueDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.blueDiamond;
            if  ( blueDiamond >= 1)
            {
                if ( _manager.m_nState == 1 )
                    getGiftRequest();
            }
            else
            {
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                _onClose("close");
            }

            CLogUtil.recordLinkLog(system, 10009);
        }
        else if ( e.target == m_pViewUI.btn_close)
        {
            if (_manager.m_nState == 2)
            {
                _onClose("close");
                _manager.closeOneDiamondSystem();
            }
            else if (_manager.m_nState == 1)
            {
                uiCanvas.showMsgBox( "1钻礼包限时钜惠，擦肩即是永恒?", close, cancle, true, "确定", "取消");
                function cancle() : void
                {
                    return;
                }
                function  close() : void
                {
                    _onClose("close");
                    if (_manager.m_nState == 2)
                    {
                        _manager.closeOneDiamondSystem();
                    }
                }
            }
        }

    }
    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }
    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function _updateOneDiamondManagerInitialState() : void
    {
        if (_manager.m_nState == 1)
        {
            if ( _manager.m_fEndTime > -0.9999 )
                m_fCountDownTime = _manager.m_fEndTime - CTime.getCurrServerTimestamp();
        }

    }
    public function getGiftRequest() : void
    {
        if( _oneDiamondNetHandler )
        {
            _oneDiamondNetHandler.oneDiamondRewardRequest( );
        }
    }

    private function _flyItem():void
    {

        var configInfo:OneDiamondActivityConfig = _getOneDiamondConfig();
        if(configInfo) {
            var rewardData : CRewardListData = CRewardUtil.createByDropPackageID( system.stage, configInfo.rewardID );

            if(rewardData) {
                var index:int = 0;
                for each(var itemData:CRewardData in rewardData.list){
                    var itemBox:Component =  m_pViewUI.list_reward.getCell(index) as Component;
                    CFlyItemUtil.flyItemToBag(itemBox, itemBox.localToGlobal(new Point()), system);
                    index ++;
                 }
            }
        }
    }

    private function _toDurTimeSpaceString(time:Number) : String {
        time /= 1000;
        var s:int = time % 60;
        time /= 60;
        var m:int = time % 60;
        time /= 60;
        var h:int = time;
        return _fillZeros(h.toString(),2) + " : " + _fillZeros(m.toString(),2) + " : " + _fillZeros(s.toString(),2);
    }
    private function _fillZeros(str:String, len:int, flag:String = "0"):String {
        while (str.length < len) {
            str = flag + str;
        }
        return str;
    }

    override public function dispose() : void
    {
        unschedule(update);
        super.dispose();
    }
    private function get _system() : COneDiamondSystem
    {
        return system as COneDiamondSystem;
    }
    private function get _manager() : COneDiamondManager
    {
        return system.getBean(COneDiamondManager) as COneDiamondManager;
    }
    private function get _oneDiamondNetHandler() : COneDiamondNetHandler
    {
        return system.getBean( COneDiamondNetHandler ) as COneDiamondNetHandler;
    }
}
}
