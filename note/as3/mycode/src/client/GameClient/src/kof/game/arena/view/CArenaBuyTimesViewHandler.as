//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/18.
 */
package kof.game.arena.view {

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.arena.CArenaHelpHandler;
import kof.game.arena.CArenaManager;
import kof.game.arena.CArenaNetHandler;
import kof.game.arena.data.CArenaBaseData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.master.arena.ArenaBuyPowerWinUI;

import morn.core.handlers.Handler;

/**
 * 购买次数界面
 */
public class CArenaBuyTimesViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:ArenaBuyPowerWinUI;

    public function CArenaBuyTimesViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ ArenaBuyPowerWinUI ];
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
                m_pViewUI = new ArenaBuyPowerWinUI();
                m_pViewUI.btn_buy.clickHandler = new Handler(_onClickBuyHandler);

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
    }

    private function _initView():void
    {
    }

    override protected function updateDisplay():void
    {
        _updateNumInfo();
        _updateCostInfo();
    }

    /**
     * 今日已购买XX次
     */
    private function _updateNumInfo():void
    {
        var currNum:int = _arenaHelp.getHasBuyNum();
        var maxNum:int = _arenaHelp.getMaxCanBuyNum();
        m_pViewUI.txt_todayNum.text = "今日已购买" + currNum + "/" + maxNum;
    }

    /**
     * 消耗钻石数
     */
    private function _updateCostInfo():void
    {
        m_pViewUI.txt_cost.text = _arenaHelp.getBuyPowerCostNum().toString();
    }

    /**
     * 点击购买处理
     */
    private function _onClickBuyHandler():void
    {
        var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
        var needNum:int = _arenaHelp.getBuyPowerCostNum();
        reciprocalSystem.showCostBdDiamondMsgBox(needNum, buyTimes);

        function buyTimes():void
        {
            (system.getHandler(CArenaNetHandler) as CArenaNetHandler).arenaBuyChallengeRequest();
            App.dialog.close(m_pViewUI);

            var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var haveDiamond : int = playerSystem.playerData.currency.purpleDiamond + playerSystem.playerData.currency.blueDiamond;
            //钻石跟绑钻都不足的时候，弹出充值界面
            if(needNum > haveDiamond)
            {
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("很抱歉，您的钻石不足，请前往获得");
            }
        }

//        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData;
//        var ownNum:Number = playerData.currency.blueDiamond + playerData.currency.purpleDiamond;
//        var needNum:int = _arenaHelp.getBuyPowerCostNum();
//        if(ownNum < needNum)
//        {
//            uiCanvas.showMsgAlert(CLang.Get("arena_money_not_enough"),CMsgAlertHandler.WARNING);
//            return;
//        }
//
//        var arenaBaseData:CArenaBaseData = (system.getHandler(CArenaManager) as CArenaManager).arenaBaseData;
//        if(arenaBaseData == null)
//        {
//            uiCanvas.showMsgAlert(CLang.Get("arena_not_initialize"),CMsgAlertHandler.WARNING);
//            return;
//        }
//
//        (system.getHandler(CArenaNetHandler) as CArenaNetHandler).arenaBuyChallengeRequest();
//        App.dialog.close(m_pViewUI);
    }

    private function get _arenaHelp():CArenaHelpHandler
    {
        return system.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
    }

    override public function dispose():void
    {

    }

}
}
