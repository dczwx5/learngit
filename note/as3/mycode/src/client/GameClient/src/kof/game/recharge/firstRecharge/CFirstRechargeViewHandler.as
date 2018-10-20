//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/3.
 */
package kof.game.recharge.firstRecharge {

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
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.platform.CPlatformHandler;
import kof.game.platform.EPlatformType;
import kof.game.platform.xiyou.CXiyouDataManager;
import kof.game.player.CPlayerSystem;
import kof.table.FirstRechargeActivityConst;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.firstRecharge.firstRechargeUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CFirstRechargeViewHandler extends CTweenViewHandler
{
    public function CFirstRechargeViewHandler()
    {
        super(false);
    }

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : firstRechargeUI;
    private var m_pCloseHandler : Handler;

    override public function get viewClass() : Array
    {
        return [ firstRechargeUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_itemEffect_small.swf"];
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

        if ( !m_bViewInitialized && !m_pViewUI)
        {
            m_pViewUI = new firstRechargeUI();
            m_pViewUI.list_reward.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            m_pViewUI.closeHandler = new Handler( _onClose );
            m_bViewInitialized = true;
        }
        updateButton();
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
                    xiyouManager.onQrcodeXiyouRequest(2);
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
    public function get isViewInitial():Boolean
    {
        if(m_pViewUI)
        {
            return true;
        }
        return false;
    }
    private function _initView():void {
        if ( m_pViewUI )
        {
            var configInfo:FirstRechargeActivityConst = _getRechargeConfigInfo();
            if(configInfo)
            {
                var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, configInfo.firstRechargeReward);
                if(rewardListData)
                {
                    if(m_pViewUI.list_reward)
                    {
                        m_pViewUI.list_reward.dataSource = rewardListData.list;
                    }
                }
            }
            m_pViewUI.text_experience.visible = false;
            //updateButton();
        }
    }

    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if (m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }
        }
    }

    private function _onClose(type : String) : void
    {
         if ( this.closeHandler )
            {
                this.closeHandler.execute();
                var manager : CFirstRechargeManager = system.getBean( CFirstRechargeManager ) as CFirstRechargeManager;
                if (manager.m_nRewardStateId == 2)
                {
                    manager.closeFirstRechargeSystem();
                }
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
        if( e.target == m_pViewUI.btn_recharge)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

            (system.stage.getSystem(CFirstRechargeSystem) as CFirstRechargeSystem).setActivity(false);

            CLogUtil.recordLinkLog(system, 10006);
        }
        else if ( e.target == m_pViewUI.btn_close)
        {
            this.closeHandler.execute();
        }
        else if ( e.target == m_pViewUI.btn_getReward )
        {
            getGiftRequest();
        }

    }
    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }
    private function get rechargeNetHandler() : CFirstRechargeNetHandler
    {
        return system.getBean( CFirstRechargeNetHandler ) as CFirstRechargeNetHandler;
    }
    public function getGiftRequest() : void
    {
        if( rechargeNetHandler )
        {
            rechargeNetHandler.firstRechargeRequest( );
        }
    }
    public function updateButton(id : int = -1) : void
    {
        if (id == -1) {
            var manager : CFirstRechargeManager = system.getBean( CFirstRechargeManager ) as CFirstRechargeManager;
            id = manager.m_nRewardStateId;
        }
        if (id == 0)
        {
            m_pViewUI.btn_recharge.visible = true;
            m_pViewUI.btn_getReward.visible = false;
            m_pViewUI.text_rewardSuccess.visible = false;
            //first button
        }
        else if (id == 1)
        {
            m_pViewUI.btn_recharge.visible = false;
            m_pViewUI.btn_getReward.visible = true;
            m_pViewUI.text_rewardSuccess.visible = false;
            //second button
        }
        else if (id ==2)
        {
            _flyItem();
            m_pViewUI.btn_getReward.visible = false;
            m_pViewUI.btn_recharge.visible = false;
            m_pViewUI.text_rewardSuccess.visible = true;
        }
    }

    private function _getRechargeConfigInfo() : FirstRechargeActivityConst

    {
        var table:IDataTable = (system.stage.getSystem(CDatabaseSystem) as IDatabase).getTable(KOFTableConstants.FirstRecharge);
        if(table)
        {
            return table.findByPrimaryKey(1) as FirstRechargeActivityConst;
        }

        return null;
    }
    private function _flyItem():void
    {
        var len:int = m_pViewUI.list_reward.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component =  m_pViewUI.list_reward.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }
    override public function dispose() : void
    {
        super.dispose();
    }
}
}
