//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/25.
 */
package kof.game.newServerActivity.view {

import QFLib.Foundation.CTime;

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.CViewManagerHandler;
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.newServerActivity.CNewServerActivityHandler;
import kof.game.newServerActivity.CNewServerActivityManager;
import kof.game.newServerActivity.CNewServerActivitySystem;
import kof.game.newServerActivity.data.CActivityRewardConfig;
import kof.game.newServerActivity.event.CNewServerActivityEvent;
import kof.table.ServerActivity;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.NewServerActivity.NewServerActivityItemListUI;
import kof.ui.master.NewServerActivity.NewServerActivityUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.Image;
import morn.core.handlers.Handler;

public class CNewServerActivityViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pNewServerActivityUI : NewServerActivityUI;
    private var m_pCloseHandler : Handler;
    //private var m_sGoalStr : String;//活动信息
    private var m_curActivityStartTime : Date ;//活动开始时间;
    private var m_curActivityEndTime : Date;//当前活动的结束时间
    private var m_iCountDownTime : Number;
    private var m_sCurActivityName : String;//活动名字

    private var m_pActivityRank : CNewServerActivityRankViewHandler;

    public function CNewServerActivityViewHandler() {
        super( false );
    }

    override public function get viewClass() :Array
    {
        return [ NewServerActivityUI , NewServerActivityItemListUI ];
    }

    override protected function onAssetsLoadCompleted() :void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if( !super.onInitializeView() )
            return false;

        if( !m_bViewInitialized )
        {
            this.initialize();
        }
        return m_bViewInitialized;
    }

    protected function initialize() : void
    {
        if( !m_pNewServerActivityUI )
        {
            m_pNewServerActivityUI = new NewServerActivityUI();

            m_pNewServerActivityUI.close_btn.clickHandler = new Handler( _close );
            m_pNewServerActivityUI.btngroup.selectHandler = new Handler( _selectCallBack );
            //m_pNewServerActivityUI.btn_rank.clickHandler = new Handler( _getActivityRankData );
            //m_pNewServerActivityUI.firstReward_list.renderHandler = new Handler( _onRenderFirstRewardList );
            m_pNewServerActivityUI.firstReward_list.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            m_pNewServerActivityUI.reward_list.renderHandler = new Handler( _onRenderRewardList);
            //m_pNewServerActivityUI.rank_list.renderHandler = new Handler( _onRenderRankView );
            //m_pNewServerActivityUI.btn_closeRank.clickHandler = new Handler( _hideRankView );

            //m_pNewServerActivityUI.tips_btn.toolTip = CLang.Get( "newServerActivityRule" );
            CSystemRuleUtil.setRuleTips(m_pNewServerActivityUI.tips_btn, CLang.Get( "newServerActivityRule" ));


            m_bViewInitialized = true;
        }
    }

    /**
     * 选择目标天数
     * **/
    private function _selectCallBack( index : int ) : void
    {
        _curRenderAcitivityID = -1; // 设置item数据时, 才更新值
        var dayId : int = index + 1;

        newServerActivityManager.m_curDay = dayId;
        var serverActivity : ServerActivity = getServerActivity( dayId );
        //设置活动id
        newServerActivityManager.curActivityID = serverActivity.type;
        var activityId : int = serverActivity.type;
        //当前活动的名称
        m_sCurActivityName = newServerActivityManager.actiivityTypeArray[ index ];
        //获取活动的开始、结束时间
        m_curActivityStartTime =  newServerActivityManager.curActivityStartTime( dayId );
        m_curActivityEndTime = newServerActivityManager.curActivityEndTime( dayId );
        m_iCountDownTime = m_curActivityEndTime.getTime() - CTime.getCurrServerTimestamp();

        if( m_curActivityStartTime.getTime() > CTime.getCurrServerTimestamp() ) // 活动没有开启,展示广告
        {
            m_pNewServerActivityUI.num_remainDay.num = 0;
            m_pNewServerActivityUI.txt_activityCountDown.text = "活动未开启";
            this.unschedule( _onCountDown );
            //显示广告,关闭内容
            m_pNewServerActivityUI.img_ad.url = "icon/newServerActivity/ad/ad" + activityId.toString() + ".jpg" ;
            m_pNewServerActivityUI.box_activity.visible = false;
            m_pNewServerActivityUI.img_ad.visible = true;

        }
        else
        {
            //关闭广告、开启内容
            m_pNewServerActivityUI.box_activity.visible = true;
            m_pNewServerActivityUI.img_ad.visible = false;
            _onRenderCountDown();
            this.schedule( 1 , _onCountDown );
            //设置广告
            _onRenderBanner( activityId );
            //发送活动请求
            _getActiivityData( dayId );
        }

    }

    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    private function _close() : void
    {
        if( m_pCloseHandler )
        {
            m_pCloseHandler.execute();
        }
    }

    /**
     * 显示排行榜
     * **/
    private function _getActivityRankData( e : MouseEvent ) : void
    {
        //发送排行榜请求
        if( newServerActivityHandler )
        {
            newServerActivityHandler.getActivityRankRequest( newServerActivityManager.m_curDay );
        }
    }

    protected function _showDiaplay() : void
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
        if ( onInitializeView() ) {
            invalidate();


            if ( m_pNewServerActivityUI )
            {
                setTweenData(KOFSysTags.NEW_SERVER_ACTIVITY);
                showDialog(m_pNewServerActivityUI);
//                uiCanvas.addDialog( m_pNewServerActivityUI );
                _initView();
                _addEventListener();

                ( system as CNewServerActivitySystem ).setRedPoint();
            }

        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass , _showDiaplay );
    }
    public function removeDisplay() : void
    {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void
    {
        _removeEventListener();

        //移除倒计时
        this.unschedule( _onCountDown );
    }

    private function _onCountDown( delta : Number ) : void
    {
        m_iCountDownTime -= 1000 ;
        _onRenderCountDown();
        /*if( m_pNewServerActivityUI.box_rank.visible )
        {
            m_pNewServerActivityUI.txt_rankCountDown.text = m_pNewServerActivityUI.txt_activityCountDown.text;
        }*/
    }

    /**
     * 初始化界面
     * **/
    private function _initView() : void
    {
        _onRenderActivityStete();
        //_updateActivityRedPoint();

        var selectIndex : int = m_pNewServerActivityUI.btngroup.selectedIndex;
        //选择默认的目标
        m_pNewServerActivityUI.btngroup.selectedIndex = newServerActivityManager.openSeverDays > 7 ? 6 : newServerActivityManager.openSeverDays - 1;
        if( selectIndex == m_pNewServerActivityUI.btngroup.selectedIndex )//如果选择的index没有变化，要自己更新
        {
            _selectCallBack( selectIndex );
        }
    }

    /**
     * 开服天数改变
     * **/
    private function _refreshActivityState( e : CNewServerActivityEvent ) :void
    {
        //0点刷新界面
        _initView();
    }
    /**
     * 奖励状态改变
     * **/
    private function _refreshRewardData( e : CNewServerActivityEvent ) : void
    {
        if( m_pNewServerActivityUI.reward_list )
        {
            m_pNewServerActivityUI.reward_list.dataSource = newServerActivityManager.activityRewards;
        }
    }
    /**
     * 活动改变
     * **/
    private function _updateActivity( e : CNewServerActivityEvent ) : void
    {
//        var activityId : int = newServerActivityManager.curActivityID;
        var activityId : int = newServerActivityManager.m_curDay;
        //m_sGoalStr = newServerActivityManager.getActivityInfoById( activityId ).info;
        //获取选择的活动数据
        newServerActivityManager.updateActivityData( activityId );
        //Banner界面内容
        _onRenderBannerView();
        //第一名
        _onRenderFirstView();
        //奖励
        _onRenderRewardView();

        _curRenderAcitivityID = activityId;
    }
    private var _curRenderAcitivityID:int = -1;
    public function get curRenderAcitivityID() : int {
        return _curRenderAcitivityID;
    }

    private function _onFirstNameCK( evt : MouseEvent ):void{
        if( m_pNewServerActivityUI.txt_firstName.dataSource )
            _pNewServerActivityRankMenuHandler.show( m_pNewServerActivityUI.txt_firstName );
    }

    private function _addEventListener() : void
    {
        if( m_pNewServerActivityUI )
        {
            m_pNewServerActivityUI.btn_rank.addEventListener( MouseEvent.CLICK ,_getActivityRankData);
            m_pNewServerActivityUI.btn_goto.addEventListener( MouseEvent.CLICK, _gotoImprove);
            m_pNewServerActivityUI.txt_firstName.addEventListener( MouseEvent.CLICK, _onFirstNameCK );
        }
        system.addEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_DAY_UPDATE ,_refreshActivityState);
        system.addEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_DATE_UPDATE,_refreshRewardData);
        system.addEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_UPDATE, _updateActivity);
        system.addEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_RANK_UPDATA , _updateRankDate );
        system.addEventListener( CNewServerActivityEvent.NEWSERVERRANKACTIVITYSTATERESPONSE , _onRenderActivityStete );
        //system.addEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_TIPS_UPDATE , _updateActivityRedPoint );
    }

    private function _removeEventListener() : void
    {
        if( m_pNewServerActivityUI )
        {
            m_pNewServerActivityUI.btn_rank.removeEventListener( MouseEvent.CLICK ,_getActivityRankData);
            m_pNewServerActivityUI.btn_goto.removeEventListener( MouseEvent.CLICK, _gotoImprove);
            m_pNewServerActivityUI.txt_firstName.removeEventListener( MouseEvent.CLICK, _onFirstNameCK );
        }
        system.removeEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_DAY_UPDATE ,_refreshActivityState);
        system.removeEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_DATE_UPDATE,_refreshRewardData);
        system.removeEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_UPDATE,_updateActivity);
        system.removeEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_RANK_UPDATA , _updateRankDate );
        system.removeEventListener( CNewServerActivityEvent.NEWSERVERRANKACTIVITYSTATERESPONSE , _onRenderActivityStete );
        //system.removeEventListener( CNewServerActivityEvent.NEW_SERVER_ACTIVITY_TIPS_UPDATE , _updateActivityRedPoint );
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    /**
     * 领取奖励
     * **/
    private function _getStageReward( activityID : int , stage : int ) : void
    {
        if(newServerActivityHandler)
        {
            newServerActivityHandler.getStageRewardRequest( activityID, stage );
        }
    }
    /**
     * 发送获取活动数据请求
     * **/
    private function _getActiivityData( activityId : int ) : void
    {
        if( newServerActivityHandler )
        {
            newServerActivityHandler.getActivityDataRequest( activityId );
        }
    }

    private function get newServerActivityManager() : CNewServerActivityManager
    {
        return system.getBean( CNewServerActivityManager ) as CNewServerActivityManager;
    }

    private function get newServerActivityHandler() : CNewServerActivityHandler
    {
        return system.getBean( CNewServerActivityHandler ) as CNewServerActivityHandler;
    }
    /*******************************排行榜相关部分*********************************************/
    private function _setRankCountDown() : void
    {
        //处理排行榜界面上的倒计时
        if ( m_pActivityRank && m_pActivityRank.activityRankUI.parent )
        {
            var countStr : String = m_iCountDownTime > 0 ? "倒计时:" + CTime.toDurTimeString( m_iCountDownTime ) : "活动已结束" ;
            m_pActivityRank.countDown(countStr);
        }
    }
    /**
     * 排行榜数据更新
     * **/
    private function _updateRankDate( e : CNewServerActivityEvent ) : void
    {
        if( !m_pActivityRank )
        {
            m_pActivityRank = new CNewServerActivityRankViewHandler( this.uiCanvas , system  );
        }
        m_pActivityRank.show();
        m_pActivityRank.rankName = m_sCurActivityName;
        m_pActivityRank.rankTitle = newServerActivityManager.activityInfo.title;
        m_pActivityRank.dayIndex = m_pNewServerActivityUI.btngroup.selectedIndex + 1;
        m_pActivityRank.updateListDataSource();

        _setRankCountDown();
    }
    /***************************界面处理部分*******************************************/

    /**
     * 左边的活动状态显示
     * **/
    private function _onRenderActivityStete( evt : CNewServerActivityEvent = null ) : void
    {
        m_pNewServerActivityUI.img_going.visible = false;
        m_pNewServerActivityUI.img_end.visible = false;
        var redPointName : String;
        //设置活动的显示
        for( var i : int = 0 ; i < 7 ; i ++ )
        {
            redPointName ="redpoint" +  i.toString();
            //var isShowActivity : Boolean = newServerActivityManager.openSeverDays - i >= 0; // 活动显示列表比开服天数多一天
            var isShowActivity : Boolean = true;//修改成显示所有页签
            m_pNewServerActivityUI.btngroup.items[i].visible = isShowActivity;
            if( isShowActivity )
            {
                var activityID : int = i + 1;
                if( newServerActivityManager.curActivityStartTime( activityID ).getTime() > CTime.getCurrServerTimestamp() )
                {
                    //活动还没开启,不显示小红点
                    m_pNewServerActivityUI.getChildByName( redPointName ).visible = false;
                }
                else
                {
                    m_pNewServerActivityUI.btngroup.items[i ].removeChildByName("activityState");
                    var stateImg : Image = new Image();
                    if( newServerActivityManager.curActivityEndTime( activityID ).getTime() <  CTime.getCurrServerTimestamp() ) // 活动未结束
                    {
                        stateImg.skin = m_pNewServerActivityUI.img_end.skin;
                        m_pNewServerActivityUI.getChildByName( redPointName ).visible = false;
                    }
                    else{
                        stateImg.skin = m_pNewServerActivityUI.img_going.skin;
                        var gameSettingData:CGameSettingData = _gameSettingSystem.gameSettingData;
                        var redPointAry : Array = gameSettingData[CGameSettingData.NewServerActivity ];
                        if(  redPointAry[ newServerActivityManager.openSeverDays - 1]  && redPointAry[ newServerActivityManager.openSeverDays - 1] == true ){
                            m_pNewServerActivityUI.getChildByName( redPointName ).visible = false;
                        }else{
                            m_pNewServerActivityUI.getChildByName( redPointName ).visible = true;
                        }
                    }
                    stateImg.name = "activityState";
                    m_pNewServerActivityUI.btngroup.items[i].addChild(stateImg);
                    stateImg.y = m_pNewServerActivityUI.btngroup.items[i ].height - stateImg.height ;
                }
            }
        }
    }
    /**
     * 倒计时界面处理
     * **/
    private function _onRenderCountDown() : void {
        var remainDay : int = (int)( ( m_iCountDownTime - m_iCountDownTime % 86400000 ) / 86400000 );
        var remainTime : Number = m_iCountDownTime % 86400000;
        if ( m_iCountDownTime <= 0 ) {
            unschedule( _onCountDown );
            m_pNewServerActivityUI.num_remainDay.num = 0;
            m_pNewServerActivityUI.txt_activityCountDown.text = "活动已结束";
        }
        else {
            m_pNewServerActivityUI.num_remainDay.num = remainDay;
            m_pNewServerActivityUI.txt_activityCountDown.text = CTime.toDurTimeString( remainTime );
        }
        _setRankCountDown();
    }

    /**
     * banner设置
     * **/
    private function _onRenderBanner( id : int ) : void
    {
        var imgUrl : String = "icon/newServerActivity/banners/banner" + id.toString() + ".jpg" ;
        m_pNewServerActivityUI.img_banner.url = imgUrl;
    }
    /**
     * 设置item_list数据
     * */
    private function _onRenderFirstRewardList( item : Component, index : int ) : void {

        if( !(item is RewardItemUI) )
        {
            return;
        }

        if ( item == null || item.dataSource == null ) {
            return;
        }

        var rewardItem:RewardItemUI = item as RewardItemUI;
        rewardItem.mouseChildren = false;
        rewardItem.mouseEnabled = true;
        var itemData : CRewardData = rewardItem.dataSource as CRewardData;
        if ( itemData != null )
        {
            if( itemData.num >= 1 )
            {
                rewardItem.num_lable.text = itemData.num.toString();
            }
            rewardItem.icon_image.url = itemData.iconSmall;
            rewardItem.bg_clip.index = itemData.quality;
            rewardItem.box_eff.visible = itemData.effect;
        }
        else
        {
            rewardItem.num_lable.text = "";
            rewardItem.icon_image.url = "";
        }
        rewardItem.toolTip = new Handler( _showTips, [rewardItem] );
    }

    private function _onRenderRewardList( item : Component, index : int ) : void
    {
        var itemUI : NewServerActivityItemListUI = item as NewServerActivityItemListUI;
        var activityData : CActivityRewardConfig = item.dataSource as CActivityRewardConfig;
        if( !activityData ) return;
        var activityRewardId : int = activityData.rewardID;
        var activityRewardListData : CRewardListData = CRewardUtil.createByDropPackageID(system.stage, activityRewardId);
        if( !activityRewardListData ) return;
        itemUI.activityReward_list.dataSource = activityRewardListData.list;
        //itemUI.activityReward_list.renderHandler = new Handler( _onRenderFirstRewardList );
        itemUI.activityReward_list.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));

        if( activityData.rewardType == 1 )//排名奖励
        {
            //设置背景图
            itemUI.img_rankBg.visible = true;
            itemUI.img_goalBg.visible = false;
            //设置显示内容
            itemUI.box_rankReward.visible = true;
            itemUI.box_goalReward.visible = false;
            itemUI.btn_getGift.visible = false;
            //处理排名奖励
            if( activityData.pre_goal == activityData.goal )
            {
                itemUI.img_ranktorank.visible = false;
                itemUI.num_lastRank.visible = false;
                itemUI.num_preRank.num = activityData.goal;
                callLater( function () : void {
                    itemUI.txt_ranktxt3.x = itemUI.num_preRank.x + itemUI.num_preRank.width + 2;
                });
            }
            else{
                itemUI.img_ranktorank.visible = true;
                itemUI.num_lastRank.visible = true;
                itemUI.num_preRank.num = activityData.pre_goal;

                itemUI.num_lastRank.num = activityData.goal;

                callLater( function () : void {
                    itemUI.img_ranktorank.x = itemUI.num_preRank.x + itemUI.num_preRank.width + 2;
                    itemUI.num_lastRank.x = itemUI.img_ranktorank.x + itemUI.img_ranktorank.width + 2;
                    itemUI.txt_ranktxt3.x = itemUI.num_lastRank.x + itemUI.num_lastRank.width + 2;
                });
            }
            itemUI.tips_btn.visible = index == newServerActivityManager.activityRewards.length -1 ? true : false;
            CSystemRuleUtil.setRuleTips(itemUI.tips_btn, newServerActivityManager.getRankTips());

            //itemUI.txt_mail.visible = activityData.canGet ? true : false;
        }
        //目标奖励删除
        /*else if( activityData.rewardType == 0 )//目标奖励
        {
            //设置入榜单条件
            itemUI.tips_btn.visible = activityData.goal == newServerActivityManager.activityInfo.rankFloor ? true : false;
            itemUI.tips_btn.toolTip = newServerActivityManager.getRankTips();
            //设置背景图
            itemUI.img_rankBg.visible = false;
            itemUI.img_goalBg.visible = true;
            //itemUI.img_goalBg.toolTip = _getRankTips();
            //设置显示内容
            itemUI.box_rankReward.visible = false ;
            itemUI.box_goalReward.visible = true ;
            itemUI.btn_getGift.visible = true;

            itemUI.txt_forceAchieve.text = m_sCurActivityName + "达到";
            itemUI.num_goal.num = activityData.goal;

            itemUI.btn_getGift.disabled = ( activityData.hasGet || !activityData.canGet );//已经领取或者没有激活
            itemUI.btn_getGift.label = activityData.hasGet ? "已领取" : "领取";
            if( !activityData.canGet ) itemUI.btn_getGift.label = "未达成";

            if( !activityData.hasGet )
            {
                itemUI.btn_getGift.clickHandler = new Handler( _getStageReward,[newServerActivityManager.activityInfo.ID,activityData.goal]);
            }
        }*/
    }

    /**
     * banner内容显示
     * **/
    private function _onRenderBannerView() : void
    {
        m_pNewServerActivityUI.txt_myForceTitle.text = "我的" + m_sCurActivityName + "：" ;
        m_pNewServerActivityUI.txt_myForce.num = newServerActivityManager.activityData.myForce;
        if( newServerActivityManager.activityData.myRank > 0 ){
            m_pNewServerActivityUI.txt_myRank.text =  newServerActivityManager.activityData.myRank.toString();
        }else{
            m_pNewServerActivityUI.txt_myRank.text =
                            newServerActivityManager.getActivityInfoById( m_pNewServerActivityUI.btngroup.selectedIndex + 1 ).describe;
        }
        m_pNewServerActivityUI.txt_tips.text = newServerActivityManager.getActivityInfoById( m_pNewServerActivityUI.btngroup.selectedIndex + 1 ).describe;

        m_pNewServerActivityUI.txt_activityEndTime.text = "活动限时：" + CTime.formatYMDStr( m_curActivityStartTime.getTime() ) + "-" +  CTime.formatYMDStr( m_curActivityEndTime.getTime() );
    }

    /**
     * 前往提升
     * **/
    private function _gotoImprove( e : MouseEvent ) : void
    {
        switch( newServerActivityManager.curActivityID )
        {
            case 1:
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.INSTANCE,null,null);
                break;
            case 2:
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.TALENT,null,null);
                break;
            case 3:
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.ROLE,null,null);
                break;
            case 4:
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.ARENA,null,null);
                break;
            case 5:
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.ROLE,null,null);
                break;
            case 6:
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.ARTIFACT,null,null);
                break;
            case 7:
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.ROLE,null,null);
                break;
        }
    }

    /**
     * 第一名的内容显示
     * **/
    private function _onRenderFirstView() : void
    {
        //第一名奖励
        if( newServerActivityManager.firstReward )
        {
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, newServerActivityManager.firstReward);
            if(rewardListData)
            {
                if(m_pNewServerActivityUI.firstReward_list)
                {
                    m_pNewServerActivityUI.firstReward_list.dataSource = rewardListData.list;
                }
            }
        }
        m_pNewServerActivityUI.img_firstForce.url = "icon/newServerActivity/force/force" + newServerActivityManager.curActivityID.toString() + ".png" ;
        m_pNewServerActivityUI.txt_firstForce.num = newServerActivityManager.activityData.firstForce;

        m_pNewServerActivityUI.txt_firstName.text = newServerActivityManager.activityData.firstName != null ? newServerActivityManager.activityData.firstName : "虚位以待";

        if( newServerActivityManager.activityData.firstName != null ){
            var obj : Object = new Object();
            obj._id = newServerActivityManager.activityData.firstID ;
            m_pNewServerActivityUI.txt_firstName.dataSource = obj;
        }else{
            m_pNewServerActivityUI.txt_firstName.dataSource = null;
        }



        var iconUrl : String = "icon/role/ui/head_icon/big_" + newServerActivityManager.activityData.firstHeadID + ".png";
        m_pNewServerActivityUI.firstHeadView.img_firstHead.skin = iconUrl;
        var pIconMask : DisplayObject = m_pNewServerActivityUI.firstHeadView.icon_mask;
        if( pIconMask )
        {
            m_pNewServerActivityUI.firstHeadView.img_firstHead.cacheAsBitmap = true;
            pIconMask.cacheAsBitmap = true;
            m_pNewServerActivityUI.firstHeadView.img_firstHead.mask = pIconMask;
        }
    }

    /**
     * 右边的奖励显示
     * **/
    private function _onRenderRewardView() : void
    {
        if( m_pNewServerActivityUI.reward_list && newServerActivityManager.activityRewards )
        {
            m_pNewServerActivityUI.reward_list.dataSource = newServerActivityManager.activityRewards;
        }
    }

    private function _showTips( item :RewardItemUI ) : void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    /**
     * 小红点更新
     * **/
    /*private function _updateActivityRedPoint() : void
    {
        var redPointName : String = "";
        for( var i : int = 0 ; i < newServerActivityManager.activityList.length ; i++ )
        {
            redPointName = "redpoint" + i.toString();
            m_pNewServerActivityUI.getChildByName( redPointName ).visible = newServerActivityManager.activityList[i]["prize"];
        }
    }*/

    /**
     * 活动选择第几天
     * */
    public function get selectActivity() : int
    {
        if (m_pNewServerActivityUI && m_pNewServerActivityUI.btngroup) {
            return m_pNewServerActivityUI.btngroup.selectedIndex + 1;
        }
        return -1;

    }

    private function get _pNewServerActivityRankMenuHandler():CNewServerActivityRankMenuHandler{

        return system.getBean( CNewServerActivityRankMenuHandler ) as CNewServerActivityRankMenuHandler;

    }

    private function getServerActivity( day : int ) : ServerActivity{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.NEW_SERVER_ACTIVITY );
        var serverActivity : ServerActivity =  pTable.findByPrimaryKey( day );
        return serverActivity;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _gameSettingSystem():CGameSettingSystem{
        return system.stage.getSystem( CGameSettingSystem ) as CGameSettingSystem;
    }

    public function get newServerActivityUI() : NewServerActivityUI {
        return m_pNewServerActivityUI;
    }
}
}
