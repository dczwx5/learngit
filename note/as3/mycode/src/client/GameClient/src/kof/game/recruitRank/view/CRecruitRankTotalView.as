//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/14.
 */
package kof.game.recruitRank.view {

import QFLib.Foundation.CTime;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.rechargerebate.CRechargeRebateHandler;
import kof.game.recruitRank.CRecruitRankHandler;
import kof.game.recruitRank.CRecruitRankManager;
import kof.game.recruitRank.data.CRecruitRankItemData;
import kof.ui.master.RecruitRank.RecruitRankItemUI;
import kof.ui.master.RecruitRank.RecruitRankTotalUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CRecruitRankTotalView extends CViewHandler{
    public function CRecruitRankTotalView() {
        super();
    }

    private var isViewInit : Boolean;
    private var m_rankView : RecruitRankTotalUI;
    private var _closeHandler : Handler;

    override public function get viewClass() : Array
    {
        return [ RecruitRankTotalUI ];
    }
//    override protected function get additionalAssets() : Array{
//        return [
//            "RecruitRank.swf",
//            "limitActivity.swf",
//        ];
//    }
    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if( !super.onInitializeView() )
            return false;

        if( !isViewInit)
            this.initialize();

        return isViewInit;
    }

    protected function initialize() : void
    {
        if( !m_rankView )
        {
            m_rankView = new RecruitRankTotalUI();
            m_rankView.btn_close.clickHandler = new Handler( _close );
            //显示初始化数据，取表
            m_rankView.list_rank.renderHandler = new Handler( _showAllRank );
            m_rankView.btn_refresh.clickHandler = new Handler( _refreshRankList );
            m_rankView.list_rank.mouseHandler = new Handler( mouseItemHandler );
            isViewInit = true;
        }
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _addToDisplay );
    }

    private function _addToDisplay() : void
    {
        if( onInitializeView() )
        {
            invalidate();

            if(m_rankView)
            {
                uiCanvas.addDialog( m_rankView );
                //填充排名list
                m_rankView.list_rank.dataSource = recruitManager.getAppointRankInfo(1,0);
                m_rankView.lb_myRank.text = recruitManager.myRank > 0?recruitManager.myRank + "":"未上榜";
                m_rankView.num_time.num = recruitManager.myTimes;
                m_rankView.lb_myName.text = playerData.teamData.name;
                _addEventListener();
                this.schedule(1,_onCountDown);
            }
        }
        else {
            LOG.logErrorMsg( "Initialized\"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    public function removeDisplay() : void
    {
        if( m_rankView )
        {
            m_rankView.close( Dialog.CLOSE );
        }
    }
    public function set closeHandler(value : Handler) :void
    {
        _closeHandler = value;
    }
    private function _addEventListener() : void
    {

    }
    private function _close() : void
    {
        if( m_rankView )
        {
            m_rankView.close( Dialog.CLOSE );
        }
    }
    private function _showAllRank(item:RecruitRankItemUI,index:int):void
    {
        if(item == null || item.dataSource == null)return;
        var itemData:CRecruitRankItemData = item.dataSource as CRecruitRankItemData;
        if (!itemData) return ;
        //前3名特殊处理，次数不显示
        if(itemData.roleRank <= 3)
        {
            item.clip_rank.visible = true;
            item.clip_rank.index = itemData.roleRank - 1;
            item.lb_rank.text = "";
            item.num_time.visible = false;

            if(itemData.roleTimes == 0)
            {
                item.lb_name.text = "精致招募达到"+itemData.limitTimes + "次即可上榜";
                item.num_time.visible = false;
                item.lb_times.visible = false;
            }
            else
            {
                item.lb_name.text = itemData.roleName;
                item.num_time.visible = false;
                item.lb_times.visible = true;
            }
        }
        else
        {
            item.clip_rank.visible = false;
            item.lb_rank.text = itemData.roleRank + "";
            item.lb_times.visible = false;
            if(itemData.roleTimes == 0)
            {
                item.lb_name.text = "精致招募达到"+itemData.limitTimes + "次即可上榜";
                item.num_time.visible = false;
            }
            else
            {
                item.lb_name.text = itemData.roleName;
                item.num_time.visible = true;
                item.num_time.num = itemData.roleTimes;
            }
        }

    }
    private function _refreshRankList():void
    {
        recruitHandler.onRankListRequest();
    }
    /**
     * 倒计时
     */
    private function _onCountDown( delta : Number ):void{
        if( m_rankView && recruitManager.endTime > 0){
            var currTime:Number = CTime.getCurrServerTimestamp();
            var leftTime:Number = recruitManager.endTime-currTime;
            if(leftTime>0)
            {
                var days:int = leftTime/(24*3600*1000);
                leftTime = leftTime-days*24*60*60*1000;
                m_rankView.lb_time.text = days + "天 " + CTime.toDurTimeString(leftTime);
            }else{
                m_rankView.lb_time.text = CLang.LANG_00301;
                this.unschedule(_onCountDown);
            }
        }
    }
    private function mouseItemHandler( evt:Event,idx : int ) : void {
        var rankItemViewUI : RecruitRankItemUI = m_rankView.list_rank.getCell( idx ) as RecruitRankItemUI;
        if ( evt.type == MouseEvent.CLICK ) {
            if(rankItemViewUI.dataSource){
                var itemData:CRecruitRankItemData = rankItemViewUI.dataSource as CRecruitRankItemData;
                if(itemData && itemData.roleID > 0)
                    _pRankMenuHandler.show( rankItemViewUI,itemData.roleID );
            }
        }
    }
    public function get recruitManager() : CRecruitRankManager
    {
        return system.getBean(CRecruitRankManager) as CRecruitRankManager;
    }
    public function get recruitHandler() : CRecruitRankHandler
    {
        return system.getBean(CRecruitRankHandler) as CRecruitRankHandler;
    }
    override protected virtual function updateData() : void
    {
        super.updateData();
    }
    private function get playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    private function get _pRankMenuHandler():CRankQueryView{
        return system.getBean( CRankQueryView ) as CRankQueryView;
    }
}
}