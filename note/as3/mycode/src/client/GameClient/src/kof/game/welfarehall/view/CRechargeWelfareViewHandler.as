//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/2.
 */
package kof.game.welfarehall.view {

import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;
import kof.game.welfarehall.CWelfareHallEvent;
import kof.game.welfarehall.CWelfareHallHandler;
import kof.game.welfarehall.CWelfareHallManager;
import kof.game.welfarehall.CWelfareHallSystem;
import kof.game.welfarehall.CWelfareHelpHandler;
import kof.game.welfarehall.data.CRechargeWelfareData;
import kof.game.yyHall.data.CYYRewardData;
import kof.game.yyHall.view.CYYHallViewHandler;
import kof.table.ForeverRechargeReward;
import kof.table.Item;
import kof.ui.master.welfareHall.RechargeWelfareItemUI;
import kof.ui.master.welfareHall.RechargeWelfareUI;
import kof.ui.master.welfareHall.WelfareHallUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CRechargeWelfareViewHandler extends CWelfarePanelBase {

    public var _activationCodeUI : RechargeWelfareUI;

    private var m_viewExternal:CViewExternalUtil;

    private var welfareData:CRechargeWelfareData;

    public function CRechargeWelfareViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _activationCodeUI = null;
    }
    override public function get viewClass() : Array {
        return [ RechargeWelfareUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_activationCodeUI ) {

            welfareData = (system.getBean(CWelfareHallManager) as CWelfareHallManager).data;

            _activationCodeUI = new RechargeWelfareUI();
            _activationCodeUI.list_reward.renderHandler = new Handler( _onGetHandler );
//            _activationCodeUI.list_reward.renderHandler = new Handler( CItemUtil.getItemRenderFunc(system));
            _activationCodeUI.btn_open.clickHandler = new Handler(_onOpenCostHandler);
            turnRechargeList();
            updateTotalDiamond();
        }

        return _activationCodeUI;
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
        if ( _activationCodeUI ) {
            mainUI.ctn.addChild( _activationCodeUI );
        }
        _addEventListeners();
    }

    override public function removeDisplay() : void {
        if ( _activationCodeUI ) {
            _activationCodeUI.remove();
            _removeEventListeners();
//            clearInterval( _showEffID );
        }
    }

    private function _addEventListeners():void {
        _removeEventListeners();
    }
    private function _removeEventListeners():void{
    }
    private function _onGetHandler(item:Component, index:int):void {
        if ( !(item is RechargeWelfareItemUI) ) {
            return;
        }
        if ( item.dataSource == null ) {
            item.visible = false;
            return;
        }
        item.visible = true;

        var render : RechargeWelfareItemUI = item as RechargeWelfareItemUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        var pRecord:ForeverRechargeReward = item.dataSource as ForeverRechargeReward;//用item直接赋值

        //判断是否领取过
        if (welfareData.isGetReward(pRecord.rechargeValue)) {
            render.img_hasTake.visible = true;
            render.btn_take.visible = false;
        }else{
            render.img_hasTake.visible = false;
            render.btn_take.visible = true;
            //判断是否达到领取条件
            if(welfareData.totalRechargeDiamond < pRecord.rechargeValue)
            {
                ObjectUtils.gray(render.btn_take);
                render.btn_take.disabled = true;
                render.btn_take.mouseEnabled = false;
                render.btn_take.label = "未达成";
            }else{
                ObjectUtils.gray(render.btn_take,false);
                render.btn_take.disabled = false;
                render.btn_take.mouseEnabled = true;
                render.btn_take.label = "领取";
            }
        }
//        var externalUtil:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, _ui);
//        m_viewExternal.show();
//        (m_viewExternal.view as CRewardItemListView).isShowItemCount = false;
//        (m_viewExternal.view as CRewardItemListView).forceAlign = 1;
//        (m_viewExternal.view as CRewardItemListView).updateLayout();
//        m_viewExternal.setData([getItemForItemID(m_selectedData.ResourceType)]);
//        render.reward_list.setData([getItemForItemID(pRecord.rewardId)]);

        render.reward_list.item_list.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
        var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage,
                pRecord.rewardId as int);
        var dataList:Array =  rewardListData.list;
        render.reward_list.item_list.dataSource = dataList;
        render.reward_list.left_btn.visible = false;
        render.reward_list.right_btn.visible = false;
//        m_viewExternal = new CViewExternalUtil( CRewardItemListView, this, render );
//        m_viewExternal.show();
//        m_viewExternal.setData( pRecord.rewardId );
//        m_viewExternal.updateWindow();

        render.txt_cost.text = "" + pRecord.rechargeValue;

        render.btn_take.clickHandler = new Handler(_onTakeHandler, [pRecord.rechargeValue]);
    }

    private function _onTakeHandler(value:int):void
    {
        (system.getBean(CWelfareHallHandler) as CWelfareHallHandler).receiveRechargeRewardRequest(value);
    }

    /**
     * 礼包领取动画
     * */
    public function addBag(value:int):void
    {
        _updateTabTipState();
        for each (var cell:RechargeWelfareItemUI in _activationCodeUI.list_reward.cells) {
            if ((cell.dataSource as ForeverRechargeReward) == null)
            {
                return;
            }
            if ((cell.dataSource as ForeverRechargeReward).rechargeValue == value) {

                var len:int = cell.reward_list.item_list.cells.length;
                //按钮置灰
                cell.img_hasTake.visible = true;
                cell.btn_take.visible = false;
                for(var i:int = 0; i < len; i++)
                {
                    var daysCell:Component = cell.reward_list.item_list.getCell(i);
                    if(daysCell.visible)
                    {
                        //领取的物品飞到背包
                        CFlyItemUtil.flyItemToBag(daysCell, daysCell.localToGlobal(new Point()), system);
                    }
                }
            }
        }

        turnRechargeList();
    }
    /**
     * 重新排序，已领取的排在最后
     * */
    private function turnRechargeList():void
    {
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.FOREVER_RECHARGE_REWARD);
        var pList:Array = pTable.toArray();
        var getList:Array = new Array();//未领取数组
        var getOverList:Array = new Array();//已领取数组
        var lastList:Array = new Array();
        for(var i:int = 0;i < pList.length;i++)
        {
            //判断是否在已经领取的数组里
            var isHasGet:Boolean = welfareData.receiveRechargeRecord.indexOf(pList[ i ].rechargeValue) != -1;
            if (isHasGet) {
                getOverList.push(pList[ i ]);
            } else {
                getList.push(pList[ i ]);
            }
        }
        for(var m:int = 0;m < getList.length;m++)
        {
            lastList.push(getList[m]);
        }

        for(var l:int = 0;l < getOverList.length;l++)
        {
            lastList.push(getOverList[l]);
        }
        _activationCodeUI.list_reward.dataSource = lastList;
    }

    private function get _helper():CWelfareHelpHandler
    {
        return system.getHandler(CWelfareHelpHandler) as CWelfareHelpHandler;
    }

    // 小红点提示
    private function _updateTabTipState():void
    {
        _helper.updateAllReward(welfareData);
        _system.dispatchEvent( new CWelfareHallEvent( CWelfareHallEvent.UPDATE_RED_POINT ));
        //主界面图标小红点
        //(system as CWelfareHallSystem).redTips(_helper.hasRechargeReward());
    }
    /**
     * 更新累计充值钻石
     * */
    public function updateTotalDiamond():void
    {
        _activationCodeUI.txt_total.text = "" + welfareData.totalRechargeDiamond;
        _activationCodeUI.list_reward.refresh();
        _updateTabTipState();
    }
    /**
     * 根据物品ID获取物品表数据
     * @ItemID 物品id
     * @return 返回的物品表数据
     *
     * */
    public function getItemForItemID( itemID : int ) : Item {
        var itemTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
        return itemTable.findByPrimaryKey( itemID );
    }


    private function _onOpenCostHandler():void
    {
//        var pBundle:ISystemBundle = (system as CWelfareHallSystem).ctx.getSystemBundle(SYSTEM_ID(KOFSysTags.RECHARGEREBATE));
//        (system as CWelfareHallSystem).ctx.setUserData(pBundle, CBundleSystem.ACTIVATED, true);
        //打开充值界面
        var idBundle : * = SYSTEM_ID( "PAY" );
        if ( null == idBundle || undefined == idBundle )
            return;

        var pCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( !pCtx )
            return;

        var pSystemBundle : ISystemBundle = pCtx.getSystemBundle( idBundle );
        if ( !pSystemBundle )
            return;

        var vCurrent : Boolean = pCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
        pCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
    }

    private function get mainUI():WelfareHallUI{
        return (system.getBean( CWelfareHallViewHandler ) as CWelfareHallViewHandler).welfareHallUI;
    }

    private function get _system() : CWelfareHallSystem
    {
        return system as CWelfareHallSystem;
    }

}
}
