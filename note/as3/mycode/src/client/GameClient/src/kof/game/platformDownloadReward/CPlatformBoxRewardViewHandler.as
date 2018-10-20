//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/13.
 */
package kof.game.platformDownloadReward {

import QFLib.Foundation;

import flash.external.ExternalInterface;
import flash.geom.Point;

import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.platformDownloadReward.event.CPlatformBoxRewardEvent;
import kof.ui.platform.platformHallReward.Platform2144HallRewardUI;
import kof.ui.platform.sevenK.SevenKPrivilegeUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

/**
 * 平台盒子下载礼包奖励
 * @author sprite (sprite@qifun.com)
 */
public class CPlatformBoxRewardViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : Platform2144HallRewardUI;
    private var m_pCloseHandler : Handler;
    private var m_bIsTakeReward:Boolean;

    public function CPlatformBoxRewardViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        _reqInfo();

        return ret;
    }

    private function _reqInfo():void
    {
        (system.getHandler(CPlatformBoxRewardNetHandler) as CPlatformBoxRewardNetHandler).platformRewardInfo();
    }

    override public function get viewClass() : Array
    {
        return [Platform2144HallRewardUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["platform2144hallreward.swf", "frameclip_item.swf"];
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
                m_pViewUI = new Platform2144HallRewardUI();

                m_pViewUI.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.btn_download.clickHandler = new Handler(_onBtnClickHandler);
                m_pViewUI.btn_close.clickHandler = new Handler(_onCloseHandler);

                m_bViewInitialized = true;
            }
        }

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
//            invalidate();
            callLater( _tweenShow );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _tweenShow():void
    {
        setTweenData(KOFSysTags.PLATFORM_BOX);
        showDialog(m_pViewUI, false, _addToDisplay);
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
        system.addEventListener(CPlatformBoxRewardEvent.GetRewardSucc, _onTakeRewardSuccHandler);
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CPlatformBoxRewardEvent.GetRewardSucc, _onTakeRewardSuccHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _updateRewardInfo();
            _updateBtnState();
        }
    }

    private function _updateBtnState():void
    {
        if(_helper.isLoginFromBox())
        {
            var manager:CPlatformBoxRewardManager = system.getHandler(CPlatformBoxRewardManager) as CPlatformBoxRewardManager;
            if(manager.rewardTakeState == 0)
            {
                m_pViewUI.btn_download.label = "领取奖励";
                m_pViewUI.btn_download.disabled = false;
            }
            else
            {
                m_pViewUI.btn_download.label = "已领取";
                m_pViewUI.btn_download.disabled = true;
            }
        }
        else
        {
            m_pViewUI.btn_download.label = "立即下载";
            m_pViewUI.btn_download.disabled = false;
        }
    }

    private function _updateRewardInfo():void
    {
        m_pViewUI.list_item.dataSource = _helper.getRewards();
    }

    private function _onTakeRewardSuccHandler(e:CPlatformBoxRewardEvent):void
    {
        m_bIsTakeReward = true;

        _updateBtnState();

        var len:int = m_pViewUI.list_item.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component = m_pViewUI.list_item.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }

//        removeDisplay();
//        _onCloseHandler();
    }

    private function _onBtnClickHandler():void
    {
        if(m_pViewUI.btn_download.label == "立即下载")
        {
            if ( ExternalInterface.available ) {
                try {
                    ExternalInterface.call( "downloadBox" );
                } catch ( e : Error ) {
                    Foundation.Log.logErrorMsg( "downloadBox error caught: " + e.message );
                }
            }
        }
        else if(m_pViewUI.btn_download.label == "领取奖励")
        {
            (system.getHandler(CPlatformBoxRewardNetHandler) as CPlatformBoxRewardNetHandler).getPlatformReward();
        }
    }

    private function _onCloseHandler():void
    {
        if ( this.closeHandler )
        {
            this.closeHandler.execute();
        }
    }

    public function removeDisplay() : void
    {
        closeDialog(_remove);
    }

    private function _remove():void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

//property=============================================================================================================
    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    private function get _helper():CPlatformBoxHelpHandler
    {
        return system.getHandler(CPlatformBoxHelpHandler) as CPlatformBoxHelpHandler;
    }

    public function get isTakeReward():Boolean
    {
        return m_bIsTakeReward;
    }

}
}
