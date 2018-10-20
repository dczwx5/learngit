//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/17.
 * Modified by Lune on 2018/09/11.
 */
package kof.game.recharge.dailyRecharge {

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
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
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
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.EverydayRechargeConfig;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.DailyRecharge.DailyRechargeUI;

import morn.core.components.Button;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CDailyRechargeViewHandler extends CTweenViewHandler
{
    public function CDailyRechargeViewHandler()
    {
        super (false);
    }
    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : DailyRechargeUI;
    private var m_pCloseHandler : Handler;
    private var m_buttonList : Vector.<Button>;
    private var m_selected : int = m_pManager.Def_seleted;//默认打开第三个页签
    private var m_fCountDownTime : Number = 1000000;

    override public function dispose() : void
    {
        super.dispose();
        m_pViewUI = null;
        m_pCloseHandler = null;
    }
    override public function get viewClass() : Array
    {
        return [ DailyRechargeUI ];
    }
    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    protected override function get additionalAssets() : Array {
        return ["frameclip_item2.swf"];
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
                m_pViewUI = new DailyRechargeUI();

                m_buttonList = new Vector.<Button>();
                var button : Button;
                for ( var i : int = 0; i < 3; i++ )
                {
                    button = m_pViewUI.buttonBox.getChildAt( i ) as Button;
                    if ( button ) {
                        button.clickHandler = new Handler( onButtonClick, [ parseInt( button.name ) ] );
                        m_buttonList.push( button );
                    }
                }
                m_pViewUI.list_reward.renderHandler = new Handler( _renderItem );
                m_pViewUI.closeHandler = new Handler( _onClose );

                m_pViewUI.btn_getReward.visible = false;
                m_pViewUI.text_rewardSuccess.visible = false;

                m_pViewUI.addEventListener(MouseEvent.CLICK, _onClickHandler);
                m_bViewInitialized = true;
            }
        }
        return m_bViewInitialized;
    }

    //切换页签
    private function onButtonClick( index : int ) : void
    {
        for ( var i : int = 0; i < 3; i++ ) {
            if ( m_buttonList[ i ].name == index.toString() ) {
                m_buttonList[ i ].selected = true;
            }
            else {
                m_buttonList[ i ].selected = false;
            }
        }
        m_selected = index;
        updateView();
    }

    private function _renderItem( item:Component, index:int):void
    {
        if(!(item is ItemUIUI))
        {
            return;
        }
        if ( item == null || item.dataSource == null ) {
            return;
        }

        var rewardItem:ItemUIUI = item as ItemUIUI;
        rewardItem.mouseChildren = false;
        rewardItem.mouseEnabled = true;
        var itemData:CRewardData = rewardItem.dataSource as CRewardData;
        if(null != itemData)
        {
            if(itemData.num >= 1)
            {
                rewardItem.txt_num.text = itemData.num.toString();
            }

            rewardItem.img.url = itemData.iconBig;
            rewardItem.clip_bg.index = itemData.quality;
            rewardItem.box_effect.visible = itemData.effect;
            rewardItem.clip_effect.autoPlay = itemData.effect;
        }
        else
        {
            rewardItem.txt_num.text = "";
            rewardItem.img.url = "";
        }

        rewardItem.toolTip = new Handler( _showTips, [rewardItem] );
    }
    private function _showTips(item:ItemUIUI):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
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
        setTweenData(KOFSysTags.DAILY_RECHARGE);
        showDialog(m_pViewUI);
        _startTimeCountDown();
        onButtonClick(m_pManager.rewandIndex);//优先打开可领奖页签
        _showQrcode();
    }
    public function get isViewShow():Boolean
    {
        if(m_pViewUI && m_pViewUI.parent)
        {
            return true;
        }
        return false;
    }

    public function removeDisplay() : void
    {
        closeDialog();
    }

    private function _onClose(type : String) : void
    {
        if ( this.closeHandler )
        {
            this.closeHandler.execute();
            unschedule(update);
            if (m_pManager.getRewardCount() >= 3)
            {
                m_pManager.stopSystemBundle();
            }
        }
    }
    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }
    private function _startTimeCountDown() : void
    {
        var date : Date = new Date();
        var serverTime : Number = CTime.getCurrServerTimestamp();
        date.setTime(serverTime);
        m_fCountDownTime = ((24 - date.hours) * 3600 - date.minutes * 60 - date.seconds) * 1000;
        if (m_fCountDownTime > 0)
        {
            m_pViewUI.text_countDownTime.text = CTime.toDurTimeString(m_fCountDownTime);
        }
        schedule(1, update);
    }

    public function updateView():void
    {
        if ( !m_pViewUI ) return;

        var type : int = m_pManager.getRechargeTypeByIndex(m_selected);
        var state : int = m_pManager.getRewardStateByIndex(type);//当前页签领取状态
        m_pViewUI.btn_recharge.visible = m_pManager.m_nRechargeValue < type;
        m_pViewUI.btn_getReward.visible = !state && !m_pViewUI.btn_recharge.visible;
        m_pViewUI.text_rewardSuccess.visible = state && !m_pViewUI.btn_recharge.visible;

        var id:int= _getRechargePackageId(m_pManager.m_nSeverDays,playerData.teamData.level);
        if(id <= 0) return;
        var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, id);
        if(rewardListData)
        {
            m_pViewUI.list_reward.dataSource = rewardListData.list;
        }
    }

    public function update(delta : Number) : void
    {
        m_fCountDownTime -= 1000 * delta;
        if (m_fCountDownTime > 0)
        {
            m_pViewUI.text_countDownTime.text = CTime.toDurTimeString(m_fCountDownTime);
        }
        else if (m_fCountDownTime > - 2 * 1000 ) //10s作为服务器同步误差
        {
            m_pManager.startSystemBundle();
        }
        else
        {
            rechargeNetHandler.initialRechargeRequest();
        }
    }
    private function _onClickHandler(e:MouseEvent):void
    {
        if( e.target == m_pViewUI.btn_recharge)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

            CLogUtil.recordLinkLog(system, 10011);
        }
        else if ( e.target == m_pViewUI.btn_getReward)
        {
            var type : int = m_pManager.getRechargeTypeByIndex(m_selected);
            rechargeNetHandler.rewardRequest(type);
        }
    }

    private function _getRechargePackageId(days : int, level : int) : int
    {
        var m_tableDailyRecharge : IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.DailyRecharge);
        var daysOffset : int = days % 7 == 0 ? 7 : days % 7;
        var configArray:Array = m_tableDailyRecharge.findByProperty("day",daysOffset);
        var config1 : EverydayRechargeConfig;
        var config2 : EverydayRechargeConfig;
        if(configArray && configArray.length>0)
        {
            config1 = configArray[0] as EverydayRechargeConfig;
            if (config1.level > level)
            {
                if (m_selected == 0)
                    return config1.oneReward;
                else if (m_selected == 1)
                    return config1.thirtyReward;
                else if (m_selected == 2)
                    return config1.hundredReward;
                else
                    return 0;
            }
            else
            {
                for (var i : int = 1; i < configArray.length; ++i)
                 {
                     config1 = configArray[i] as EverydayRechargeConfig;
                     config2 = configArray[i - 1] as EverydayRechargeConfig;
                    if (level >= config2.level && level < config1.level)
                    {
                        if (m_selected == 0)
                            return config1.oneReward;
                        else if (m_selected == 1)
                            return config1.thirtyReward;
                        else if (m_selected == 2)
                            return config1.hundredReward;
                        else
                            return 0;
                    }
                }
            }
        }
        return 0;
    }

    //飞行动画
    public function flyItem():void
    {
        var id:int= _getRechargePackageId(m_pManager.m_nSeverDays,playerData.teamData.level);
        if(id > 0)
        {
            var rewardData : CRewardListData =  CRewardUtil.createByDropPackageID(system.stage, id);
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
    private function get m_pManager() : CDailyRechargeManager
    {
        return system.getBean( CDailyRechargeManager ) as CDailyRechargeManager;
    }
    private function get playerData() : CPlayerData
    {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        return  playerManager.playerData;
    }
    private function get rechargeNetHandler() : CDailyRechargeNetHandler
    {
        return system.getBean( CDailyRechargeNetHandler ) as CDailyRechargeNetHandler;
    }
}
}
