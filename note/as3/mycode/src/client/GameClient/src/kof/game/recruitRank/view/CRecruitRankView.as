//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/10.
 */
/*UI视图进程*/
package kof.game.recruitRank.view {

import QFLib.Foundation.CTime;

import flash.events.Event;

import flash.events.MouseEvent;
import kof.game.KOFSysTags;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.recruitRank.CRecruitRankHandler;
import kof.game.recruitRank.CRecruitRankManager;
import kof.game.recruitRank.CRecruitRankSystem;
import kof.game.recruitRank.data.CRecruitRankItemData;
import kof.table.Activity;
import kof.table.RecruitRankActivityTimesConfig;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardPackageItemUI;
import kof.ui.master.RecruitRank.RecruitRankMainUI;
import kof.ui.master.RecruitRank.RecruitRankTopItemUI;
import kof.ui.master.RecruitRank.RecruitRewardBoxUI;

import morn.core.components.Component;


import morn.core.handlers.Handler;

public class CRecruitRankView extends CTweenViewHandler{
    private var m_pRecruitUI : RecruitRankMainUI;
    private var _closeHandler : Handler;
    private var m_endTime:Number = 0.0;
    private var m_isInit:Boolean;

    public function CRecruitRankView() {
        super(false);
    }
    override public function get viewClass() : Array {
        return [RecruitRankMainUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override public function dispose() : void {
        super.dispose();

        if( m_pRecruitUI )
            m_pRecruitUI.remove();
        m_pRecruitUI = null;
    }

    override protected function get additionalAssets() : Array{
        return [
                "frameclip_rebat.swf", "frameclip_item2.swf"
        ];
    }
    //重载初始化界面方法
    override protected function onInitializeView() : Boolean{
        if( !super.onInitializeView() )
                return false;
        if(!m_isInit)
           initialize();
        return m_isInit;
    }

    protected function initialize() : void{
        if( !m_pRecruitUI ){
            m_pRecruitUI = new RecruitRankMainUI();
            m_pRecruitUI.btn_close.clickHandler = new Handler( _onClose );
            m_pRecruitUI.btn_recruit.clickHandler = new Handler( _btnClick );
            m_pRecruitUI.link_reward.clickHandler = new Handler( _openRewardView );
            m_pRecruitUI.link_rank.clickHandler = new Handler( _openRankTotalView );
            m_pRecruitUI.btn_refresh.clickHandler = new Handler( _onRefresh );

            m_pRecruitUI.list_reward1.renderHandler = new Handler( CItemUtil.getItemRenderFunc(recruitRankSystem,1) );//第一名奖励列表
            m_pRecruitUI.list_reward2.renderHandler = new Handler( CItemUtil.getItemRenderFunc(recruitRankSystem) );//第二名奖励列表
            m_pRecruitUI.list_reward3.renderHandler = new Handler( CItemUtil.getItemRenderFunc(recruitRankSystem) );//第三名奖励列表
            m_pRecruitUI.list_rank.renderHandler = new Handler( _showTopTenList );//第4-10名列表
            m_pRecruitUI.list_rank.mouseHandler = new Handler( mouseItemHandler );
            m_pRecruitUI.list_totalReward.renderHandler = new Handler( _showTotalReward);//全服累计招募奖励

            m_pRecruitUI.lb_name1.addEventListener(MouseEvent.CLICK, rankQuery);
            m_pRecruitUI.lb_name2.addEventListener(MouseEvent.CLICK, rankQuery);
            m_pRecruitUI.lb_name3.addEventListener(MouseEvent.CLICK, rankQuery);
            m_isInit = true;
        }
    }

    override protected function updateDisplay() : void{
        super.updateDisplay();
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addDisplay );
    }

    private function _addDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if(!m_pRecruitUI)  return;
        var activityConfig:Activity = recruitManager.getActivity();
        if(activityConfig){
            m_pRecruitUI.img_role.skin = "icon/recuitRank/" + activityConfig.image + ".png";
        }
        refreshView();
        _onRefresh();
        var currTime:Number = CTime.getCurrServerTimestamp();
        var leftTime:Number = m_endTime-currTime;
        if(leftTime>0)
        {
            m_pRecruitUI.box_data.visible = true;
            this.schedule(1,_onCountDown);
        }
        else
        {
            m_pRecruitUI.box_data.visible = false;
            m_pRecruitUI.lb_time.text = CLang.LANG_00301;
        }
        setTweenData(KOFSysTags.RECRUIT_RANK);
        showDialog(m_pRecruitUI,false);

    }
    public function removeDisplay() : void {
        if ( this.m_pRecruitUI ) {
            closeDialog(_onFinished);
        }
    }
    private function _onFinished() : void {
        m_pRecruitUI.remove();
        this.unschedule(_onCountDown);
        //_removeEventListener();
    }
    private function _btnClick():void
    {
        CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.CARDPLAYER,null,null);
        _onClose();
    }

    override protected function updateData () : void{
        super.updateData();
    }
    /**
     * 刷新界面数据
     */
    public function refreshView():void
    {
        if(m_pRecruitUI)
        {
            m_pRecruitUI.lb_playerTimes.text = recruitManager.myTimes + "";
            m_pRecruitUI.lb_total.text = recruitManager.totalTimes + "";
            m_pRecruitUI.lb_playerRank.text = recruitManager.myRank > 0?recruitManager.myRank + "":"未上榜";
            m_pRecruitUI.pro_bar.value = recruitManager.timesPercent;
            m_endTime = recruitManager.endTime;

            m_pRecruitUI.list_reward1.dataSource = recruitManager.getSingleReward(1);
            m_pRecruitUI.list_reward2.dataSource = recruitManager.getSingleReward(2);
            m_pRecruitUI.list_reward3.dataSource = recruitManager.getSingleReward(3);
            m_pRecruitUI.list_rank.dataSource = recruitManager.getAppointRankInfo(4,10);
            m_pRecruitUI.list_totalReward.dataSource = recruitManager.getTotalReward();
            m_pRecruitUI.img_tips.toolTip = recruitManager.getHelpTips();
            //CSystemRuleUtil.setRuleTips(m_pRecruitUI.img_tips, recruitManager.getHelpTips());
            _renderTopThree();
        }
    }
    /**
     * 显示奖励信息列表界面
     */
    private function _openRewardView() : void
    {
        ( recruitRankSystem.getBean( CRecruitRewardView) as CRecruitRewardView ).addDisplay();
    }
    /**
     * 显示排名，其中1-3名特殊处理，4-10名采用list
     */
    private function _renderTopThree() : void
    {
        var topThree:Array = recruitManager.getAppointRankInfo(1,3);
        if(topThree[0])
        {
            m_pRecruitUI.lb_name1.text = topThree[0 ].roleName;
            m_pRecruitUI.lb_name1.name = topThree[0 ].roleID;
            m_pRecruitUI.lb_limit1.text = topThree[0 ].roleName == ""?"精致招募达到"+topThree[0 ].limitTimes+"次即可上榜":"";
        }
        if(topThree[1])
        {
            m_pRecruitUI.lb_name2.text = topThree[1 ].roleName;
            m_pRecruitUI.lb_name2.name = topThree[1 ].roleID;
            m_pRecruitUI.lb_limit2.text = topThree[1 ].roleName == ""?"精致招募达到"+topThree[1 ].limitTimes+"次即可上榜":"";
        }
        if(topThree[2])
        {
            m_pRecruitUI.lb_name3.text = topThree[2 ].roleName;
            m_pRecruitUI.lb_name3.name = topThree[2 ].roleID;
            m_pRecruitUI.lb_limit3.text = topThree[2 ].roleName == ""?"精致招募达到"+topThree[2 ].limitTimes+"次即可上榜":"";
        }
    }

    /**
     * 打开排名总览
     */
    private function _openRankTotalView() : void
    {
        (recruitRankSystem.getBean( CRecruitRankTotalView ) as CRecruitRankTotalView ).addDisplay();
    }

    /**
     * 请求排名榜排名榜数据
     */
    private function _onRefresh() : void
    {
        recruitHandler.onActivityDataRequest();
        recruitHandler.onRankListRequest();
    }

//    /**
//     * 显示第一名奖励
//     */
//    private function _showTopThreeReward1( item:RewardPackageItemUI,index:int ) : void
//    {
//        if(item == null || item.dataSource == null)return;
//        var rewardData:CRewardData = item.dataSource as CRewardData;
//        item.mc_item.box_effect.visible = rewardData.effect;
//        item.mc_item.clip_effect.autoPlay = rewardData.effect;
//        item.txt_name.visible = false;
//        item.mc_item.img.url = rewardData.iconBig;
//        item.mc_item.clip_bg.index = rewardData.quality;
//        item.mc_item.txt_num.text = rewardData.num.toString();
//        item.txt_name.text = CLang.Get("item_name_and_num", {v1:rewardData.nameWithColor, v2:rewardData.num});
//        item.toolTip = new Handler(_addRewardTips, [item]);
//    }
//    /**
//     * 显示第二三名奖励
//     */
//    private function _showTopThreeReward2( item:RewardItemUI,index:int ) : void
//    {
//        if(item == null || item.dataSource == null)return;
//        var itemData:CRewardData = item.dataSource as CRewardData;
//        if (!itemData) return ;
//        item.box_eff.visible = itemData.effect;
//        item.clip_eff.autoPlay = itemData.effect;
//        item.num_lable.text = itemData.num.toString();
//        item.icon_image.url = itemData.iconSmall;
//        item.bg_clip.index = itemData.quality;
//        item.toolTip = new Handler(_addSmallRewardTips, [item]);
//        item.hasTakeImg.visible = false;
//    }
//
//    /**
//     * 奖励tips
//     * @param item
//     */
//    private function _addRewardTips(item:RewardPackageItemUI) : void {
//        var itemSystem:CItemSystem = recruitRankSystem.stage.getSystem(CItemSystem) as CItemSystem;
//        itemSystem.addTips(CItemTipsView, item);
//    }
//    private function _addSmallRewardTips(item:RewardItemUI) : void {
//        var itemSystem:CItemSystem = recruitRankSystem.stage.getSystem(CItemSystem) as CItemSystem;
//        itemSystem.addTips(CItemTipsView, item);
//    }

    /**
     * 显示4-10名列表
     */
    private function _showTopTenList(item:RecruitRankTopItemUI,index:int) : void
    {
        if(item == null || item.dataSource == null)return;
        var itemData:CRecruitRankItemData = item.dataSource as CRecruitRankItemData;
        if (!itemData) return ;
        var limitTimes:int = itemData.limitTimes;
        item.lb_rank.text = itemData.roleRank + "";
        item.lb_name.text = itemData.roleTimes == 0?"精致招募达到"+limitTimes+"次即可上榜":itemData.roleName;
        item.lb_times.text = itemData.roleTimes == 0?"":itemData.roleTimes + "";

    }

    /**
     * 显示全服累计招募奖励
     */
    private function _showTotalReward(item:RecruitRewardBoxUI,index:int) : void
    {
        if(item == null || item.dataSource == null)return;
        var itemData:RecruitRankActivityTimesConfig = item.dataSource as RecruitRankActivityTimesConfig;
        if (!itemData) return ;
        item.lb_configTimes.text = itemData.times + "";
        m_pRecruitUI["fc_"+index].visible = false;
        item.clip_box.index = 0;
        item.clip_box.dataSource = itemData.reward;

        var isGet:Boolean = recruitManager.isGetReward(itemData.ID);
        var status:int = CRewardTips.REWARD_STATUS_NOT_COMPLETED;
        if(isGet)//已领取
        {
            status = CRewardTips.REWARD_STATUS_HAS_REWARD;
            m_pRecruitUI["fc_"+index].visible = false;
            m_pRecruitUI["fc_"+index].stop();
            item.clip_box.index = 1;
        }
        else
        {
            if(recruitManager.totalTimes >= itemData.times)//可领取未领取
            {
                status = CRewardTips.REWARD_STATUS_CAN_REWARD;
                m_pRecruitUI["fc_"+index].visible = true;
                m_pRecruitUI["fc_"+index].autoPlay = true;
                m_pRecruitUI["fc_"+index].play();
                item.clip_box.index = 0;
            }
            else//不可领取
            {
                status = CRewardTips.REWARD_STATUS_OTHER_1;
                m_pRecruitUI["fc_"+index].visible = false;
                m_pRecruitUI["fc_"+index].stop();
                item.clip_box.index = 0;
            }
        }

        item.toolTip = new Handler(itemSystem.showRewardTips,[item.clip_box,[["全服累计达到"+itemData.times+" 可领取"],status,1]]);
        item.addEventListener(MouseEvent.CLICK, _onRewardBoxClick);
    }

    /**
     * 点击领奖
     */
    private function _onRewardBoxClick(e:MouseEvent):void{
        var itemData:RecruitRankActivityTimesConfig = e.currentTarget.dataSource as RecruitRankActivityTimesConfig;
        //var isGet:Boolean = recruitManager.isGetReward(itemData.ID);
        if(itemData)
        //    return;
            recruitHandler.onRewardRequest(itemData.ID);
    }

    /**
     * 倒计时
     */
    private function _onCountDown( delta : Number ):void{
        if( m_pRecruitUI && m_endTime > 0){
            var currTime:Number = CTime.getCurrServerTimestamp();
            var leftTime:Number = m_endTime-currTime;
            if(leftTime>0)
            {
                var days:int = leftTime/(24*3600*1000);
                m_pRecruitUI.clip_date1.index = days/10;
                m_pRecruitUI.clip_date2.index = days%10;
                leftTime = leftTime-days*24*60*60*1000;
                m_pRecruitUI.lb_time.text = CTime.toDurTimeString(leftTime);
            }else{
                m_pRecruitUI.clip_date1.index = 0;
                m_pRecruitUI.clip_date2.index = 0;
                m_pRecruitUI.lb_time.text = CLang.LANG_00301;
                this.unschedule(_onCountDown);
            }
        }
    }

    private function rankQuery( e:MouseEvent ) : void
    {
        var item : Component = e.currentTarget as Component;
        var roleID : Number = Number(item.name);
        if(!item || roleID == 0) return;
        _pRankMenuHandler.show( item, roleID);
    }
    private function mouseItemHandler( evt:Event,idx : int ) : void {
        var rankItemViewUI : RecruitRankTopItemUI = m_pRecruitUI.list_rank.getCell( idx ) as RecruitRankTopItemUI;
        if ( evt.type == MouseEvent.CLICK ) {
            if(rankItemViewUI.dataSource){
                var itemData:CRecruitRankItemData = rankItemViewUI.dataSource as CRecruitRankItemData;
                if(itemData && itemData.roleID > 0)
                    _pRankMenuHandler.show( rankItemViewUI,itemData.roleID );
            }
        }
    }
    private function _addEventListener() : void {
        //system.addEventListener(CRecruitRankEvent.TIMES_UPDATE,_updateMyScoreInfo);
        //system.addEventListener(CRecruitRankEvent.RANK_UPDATE,_updateMyRankInfo);
        //system.addEventListener(CRecruitRankEvent.REWARD_UPDATE,_updateViewInfo);
    }

    private function _removeEventListener() : void {
        //system.removeEventListener(CRecruitRankEvent.TIMES_UPDATE,_updateMyScoreInfo);
        //system.removeEventListener(CRecruitRankEvent.RANK_UPDATE,_updateMyRankInfo);
        //system.removeEventListener(CRecruitRankEvent.REWARD_UPDATE,_updateViewInfo);
    }
    public function get closeHandler() : Handler {
        return _closeHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        _closeHandler = value;
    }

    private function _onClose() : void {
        if ( this._closeHandler ) {
            this._closeHandler.execute();
        }
    }
    private function get recruitHandler() : CRecruitRankHandler {
        return system.getBean( CRecruitRankHandler ) as CRecruitRankHandler;
    }

    private function get recruitManager() : CRecruitRankManager {
        return system.getBean( CRecruitRankManager ) as CRecruitRankManager;
    }
    private function get recruitRankSystem() : CRecruitRankSystem
    {
        return system as CRecruitRankSystem;
    }
    private function get itemSystem() : CItemSystem {
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }
    private function get _pRankMenuHandler():CRankQueryView{
        return system.getBean( CRankQueryView ) as CRankQueryView;
    }
}
}
