//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/6/22.
 */
package kof.game.welfarehall.view {

import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.game.welfarehall.CWelfareHallEvent;
import kof.game.welfarehall.CWelfareHallHandler;
import kof.game.welfarehall.CWelfareHallManager;
import kof.game.welfarehall.CWelfareHallSystem;
import kof.table.Currency;
import kof.table.RetrieveReward;
import kof.table.RetrieveSystemConfig;
import kof.ui.master.welfareHall.RecoveryViewItemUI;
import kof.ui.master.welfareHall.RecoveryViewUI;

import morn.core.handlers.Handler;

public class CRecoveryViewHandler extends CWelfarePanelBase{
    private var m_bViewInitialize : Boolean;
    private var m_view : RecoveryViewUI;
    public function CRecoveryViewHandler() {
        super();
    }
    override public function get viewClass() : Array
    {
        return [RecoveryViewUI];
    }
    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override protected function onInitializeView() : Boolean
    {
        if(!super.onInitializeView())
        {
            return false;
        }
        if(!m_bViewInitialize)
        {
            this.initialize();
        }
        return m_bViewInitialize;
    }
    protected function initialize() : void
    {
        m_view = new RecoveryViewUI();
        m_view.btn_gold.clickHandler = new Handler(_findAllRewards,["gold"]);
        m_view.btn_diamond.clickHandler = new Handler(_findAllRewards,["diamond"]);
        m_view.list_activity.renderHandler = new Handler(_showActivityItem);
        m_bViewInitialize = true;
    }
    override public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if ( m_view ) {
            if(!_mainView.welfareHallUI.ctn.contains(m_view))
                _mainView.welfareHallUI.ctn.addChild( m_view );
            _system.addEventListener(CWelfareHallEvent.UPDATE_RECOVERY_VIEW , _updateState );
            _updateState();
        }
    }
    private function _updateState(e : CWelfareHallEvent = null) : void
    {
        var list : Array = _manager.recoverableList;
        if(!list || list.length == 0)
        {
            m_view.img_noreward.visible = true;
            m_view.list_activity.visible = false;
            m_view.lb_gold.text = "0";
            m_view.lb_diamond.text = "0";
        }
        else
        {
            m_view.img_noreward.visible = false;
            m_view.list_activity.visible = true;
            m_view.list_activity.dataSource = _manager.recoverableList;
            var totalConsume : Object = _manager.getRecoveryTotalConsume();
            if(totalConsume)
            {
                m_view.lb_gold.text = totalConsume.cur1 + "";
                m_view.lb_diamond.text = totalConsume.cur2 + "";
                m_view.icon_currency1.url =  "icon/currency/"+_manager.getCurrencyType(totalConsume.type1)+".png";
                m_view.icon_currency2.url =  "icon/currency/"+_manager.getCurrencyType(totalConsume.type2)+".png";
            }
        }

        m_view.btn_gold.disabled = m_view.btn_diamond.disabled = !_manager.hasRecoveryReward;
    }
    override public function removeDisplay() : void {
        if ( m_view ) {
            m_view.remove();
            _system.removeEventListener(CWelfareHallEvent.UPDATE_RECOVERY_VIEW , _updateState );
        }
    }

    private function _showActivityItem(item : RecoveryViewItemUI, index : int) : void
    {
        if (!(item is RecoveryViewItemUI) || !item.dataSource) return;
        var data : Object = item.dataSource;
        var times : int = data.count ? data.count : 1;
        var dataConfig : RetrieveSystemConfig = _manager.getRecoveryConfigByID( data.systemId );
        var rewardConfig : RetrieveReward = _manager.getRecoveryRewardByID( data.systemId );
        if(dataConfig == null || rewardConfig == null) return;
        item.img_activity.url = "icon/task/" + dataConfig.img + ".png";
        item.lb_activity.text = dataConfig.systemName;
        item.lb_gold.text = dataConfig.commonConsumes * times + "";
        item.lb_diamond.text = dataConfig.payConsumes * times + "";
        item.icon_currency1.url =  "icon/currency/"+_manager.getCurrencyType(dataConfig.commonCurrencyType) + ".png";
        item.icon_currency2.url =  "icon/currency/"+_manager.getCurrencyType(dataConfig.payCurrencyType) +".png";
        item.list_item.renderHandler = new Handler( CItemUtil.getItemRenderFunc( _system ) );
        var rewardData : CRewardListData = CRewardUtil.createByDropPackageID( _system.stage, rewardConfig.payReward,times);
        if ( rewardData ) item.list_item.dataSource = rewardData.list;
        item.btn_gold.disabled = data.state == 1 ? true : false;
        item.btn_diamond.disabled = data.state == 1 ? true : false;
        item.btn_gold.clickHandler = new Handler( _findOneRewards, [ data.systemId, "gold", item.lb_gold.text, dataConfig.systemName ] );
        item.btn_diamond.clickHandler = new Handler( _findOneRewards, [ data.systemId, "diamond",item.lb_diamond.text ,dataConfig.systemName ] );
    }

    private function _findOneRewards(...params ) : void
    {
        var type : int = params[1] == "gold" ? 1:2;
        var typeStr : String = params[1] == "gold" ? "金币":"绑钻";
        var tisStr:String = "是否消耗"+ params[2] + typeStr + "找回" + params[3] + "奖励？";
        uiCanvas.showMsgBox( tisStr, function():void{ _netHandler.findRewardsRequest(params[0],type,params[2]);},null,true,null,null,true,typeStr );

    }
    private function _findAllRewards(... params ):void
    {
        var totalConsume : Object = _manager.getRecoveryTotalConsume();
        var type : int = params[0] == "gold" ? 1:2;
        var typeStr : String = type == 1 ?  totalConsume.cur1+"金币" : totalConsume.cur2+"绑钻";
        var cost : int = type == 1 ?  totalConsume.cur1: totalConsume.cur2;
        var tisStr:String = "是否消耗"+ typeStr + "找回全部活动奖励？";
        uiCanvas.showMsgBox( tisStr, function():void{ _netHandler.findRewardsRequest(params[0],type, cost);},null,true,null,null,true,typeStr );
    }
    private function get _netHandler() : CWelfareHallHandler
    {
        return system.getBean( CWelfareHallHandler ) as CWelfareHallHandler;
    }
    private function get _system() : CWelfareHallSystem
    {
        return system as CWelfareHallSystem;
    }
    private function get _mainView():CWelfareHallViewHandler
    {
        return system.getBean( CWelfareHallViewHandler ) as CWelfareHallViewHandler
    }
    private function get _manager():CWelfareHallManager{
        return system.getBean( CWelfareHallManager ) as CWelfareHallManager;
    }
}
}
