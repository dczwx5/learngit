//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/8/16.
 */
package kof.game.limitActivity {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;

import com.greensock.TweenMax;

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ESystemBundlePropertyType;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.equipCard.Enum.EEquipCardOpenType;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.limitActivity.data.CLimitScoreRankItemData;
import kof.game.limitActivity.event.CLimitActivityEvent;
import kof.game.limitActivity.view.CLimitActivityRewardViewHandler;
import kof.game.limitActivity.view.CLimitScoreRewardTipsViewHandler;
import kof.game.player.CPlayerSystem;
import kof.table.Activity;
import kof.table.Item;
import kof.table.LimitTimeConsumeActivityConfig;
import kof.table.LimitTimeConsumeActivityConst;
import kof.table.LimitTimeConsumeActivityRankConfig;
import kof.table.LimitTimeConsumeActivityScoreConfig;
import kof.table.RankConfig;
import kof.ui.CUISystem;
import kof.ui.components.KOFProgressBar;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardPackageItemUI;
import kof.ui.master.limitActivity.LimitActivityUI;
import kof.ui.master.limitActivity.LimitScoreRewardUI;
import kof.ui.master.limitActivity.LimitScoreboardItemUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CLimitActivityViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized:Boolean;
    private var m_limitUI:LimitActivityUI;

    private var _closeHandler:Handler;

    private var m_progressArr:Array = [];

    private var m_startTime:Number = 0.0;
    private var m_endTime:Number = 0.0;

    public function CLimitActivityViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ LimitActivityUI ];
    }

    override protected function get additionalAssets():Array {
        return ["frameclip_item2.swf","frameclip_task.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            this.initialize();
        }

        return m_bViewInitialized;
    }

    protected function initialize() : void {
        if ( !m_limitUI ) {
            m_limitUI = new LimitActivityUI();
            m_limitUI.btn_close.clickHandler = new Handler( _close );

            m_limitUI.list_reward1.renderHandler = new Handler( CItemUtil.getItemRenderFunc(limitSystem,1) );
            m_limitUI.list_reward2.renderHandler = new Handler( _onRenderRewardList2 );
            m_limitUI.list_reward3.renderHandler = new Handler( _onRenderRewardList2 );

            m_limitUI.btn_rewardInfo.clickHandler = new Handler( _onShowRewardInfoView );//显示奖励信息列表界面
            m_limitUI.btn_upB.clickHandler = new Handler( _onShowRewardInfoView );//显示奖励信息列表界面
            m_limitUI.btn_nd.clickHandler = new Handler( _onShowNdView );//显示扭蛋界面

            m_limitUI.list_reward.renderHandler = new Handler( _onRenderScoreRewardItem );//积分奖励宝箱列表
            m_limitUI.list_scoreRank.renderHandler = new Handler( _onRenderScoreRankItem );//积分排行列表

//            m_limitUI.btn_prompt.toolTip = _showPromptTips();
            CSystemRuleUtil.setRuleTips(m_limitUI.btn_prompt, _showPromptTips());

            m_bViewInitialized = true;

            m_progressArr.push(m_limitUI.pro_bar1,m_limitUI.pro_bar2,m_limitUI.pro_bar3,m_limitUI.pro_bar4,m_limitUI.pro_bar5);
        }
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addToDisplay );
    }

    private function _addToDisplay() : void {

        if ( onInitializeView() ) {
            invalidate();

            if ( m_limitUI )
            {
//                uiCanvas.addDialog( m_limitUI );
                setTweenData(KOFSysTags.LIMIT_ACTIVITY);
                showDialog(m_limitUI);

                m_startTime = limitManager.startTime;
                m_endTime = limitManager.endTime;

                limitHandler.onActivityRankDataRequest();
                limitHandler.onActivityScoreDataRequest();

                m_limitUI.list_reward.dataSource = limitManager.getScoreRewardList();
                m_limitUI.list_scoreRank.dataSource = limitManager.rankInfos.rankInfos;

                var activityConfig:Activity = limitManager.getActivity();
                if(activityConfig){
                    m_limitUI.img_role.skin = "icon/limitActivity/" + activityConfig.image + ".png";
                }

                this.schedule(1,_onCountDown);
                _addEventListener();
            }

        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }

    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_limitUI ) {
            _removeEventListener();
            this.unschedule(_onCountDown);
        }
    }

    public function set closeHandler( value:Handler ):void {
        _closeHandler = value;
    }


    override protected virtual function updateData():void {
        super.updateData();

        if ( m_limitUI ) {

            var constTable:LimitTimeConsumeActivityConfig = limitManager.getConsumeTable();
            if(constTable){
                m_limitUI.lb_4.text = constTable.describe1;
                m_limitUI.lb_6.text = constTable.describe2;
            }

            updateRankReward();
            updateMyScoreAndRankInfo();
        }
    }

    /**
     * 倒计时
     */
    private function _onCountDown( delta : Number ):void{
        if( m_limitUI && m_endTime > 0){
            var currTime:Number = CTime.getCurrServerTimestamp();
            var leftTime:Number = m_endTime-currTime;
            if(leftTime>0)
            {
                var days:int = leftTime/(24*3600*1000);
                m_limitUI.clip_time.num = days;
                leftTime = leftTime-days*24*60*60*1000;
                m_limitUI.lb_time.text = CTime.toDurTimeString(leftTime);
            }else{
                m_limitUI.clip_time.num = 0;
                m_limitUI.lb_time.text = CLang.LANG_00301;
                this.unschedule(_onCountDown);
            }
        }
    }

    /**
     * 显示奖励信息列表界面
     */
    private function _onShowRewardInfoView():void{
        (limitSystem.getBean( CLimitActivityRewardViewHandler ) as CLimitActivityRewardViewHandler).addDisplay();
    }

    /**
     * @modify 2017年11月30日 17:58:57 改成打开招募界面
     * 显示扭蛋界面
     */
    private function _onShowNdView():void{
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.CARDPLAYER));
//        bundleCtx.setUserData(systemBundle, ESystemBundlePropertyType.Type_SystemOpenWay, EEquipCardOpenType.OPEN_TYPE_ACTIVE);
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    /**
     * 更新积分奖励宝箱数据列表
     */
    private function _onRenderScoreRewardItem(item:LimitScoreRewardUI,index:int):void{
        if(item == null || item.dataSource == null)return;

        var scoreTable:LimitTimeConsumeActivityScoreConfig = item.dataSource as LimitTimeConsumeActivityScoreConfig;

        var isGet:Boolean = limitManager.isGetReward(scoreTable.ID);
        var status:int = CRewardTips.REWARD_STATUS_NOT_COMPLETED;
        if(isGet){
            //已经领取
            status = CRewardTips.REWARD_STATUS_HAS_REWARD;
            item.star1_btn.index = 1;
            item.reward_effect1.visible = false;
            item.reward_effect1.stop();
            item.star1_effect_clip.visible = false;
            item.star1_effect_clip.stop();
        }else{
            item.star1_btn.index = 0;
            if(limitManager.mySroce >= scoreTable.score){
                //可领取奖励，但是还未领取
                status = CRewardTips.REWARD_STATUS_CAN_REWARD;
                item.reward_effect1.visible = true;
                item.reward_effect1.autoPlay = true;
                item.reward_effect1.play();
                item.star1_effect_clip.visible = true;
                item.star1_effect_clip.autoPlay = true;
                item.star1_effect_clip.play();
            }else{
                //不能领取奖励
                status = CRewardTips.REWARD_STATUS_OTHER_1;
                item.reward_effect1.visible = false;
                item.reward_effect1.stop();
                item.star1_effect_clip.visible = true;
                item.star1_effect_clip.stop();
            }
        }

        item.addEventListener(MouseEvent.CLICK, _onRewardBoxClick);
        item.lb_scoreCount.text = limitManager.mySroce + "/" + scoreTable.score;
//        item.toolTip = new Handler(_addTips3,[item]);
        item.star1_btn.dataSource = scoreTable.reward;
        item.toolTip = new Handler(itemSystem.showRewardTips,[item.star1_btn,[["消费积分达到"+scoreTable.score+" 可领取"],status,1]]);


    }

    private function _onRewardBoxClick(e:MouseEvent):void{
        var item:LimitScoreRewardUI = e.currentTarget as LimitScoreRewardUI;
        var scoreTable:LimitTimeConsumeActivityScoreConfig = item.dataSource as LimitTimeConsumeActivityScoreConfig;//send consume_blue_diamond
        var isGet:Boolean = limitManager.isGetReward(scoreTable.ID);
        if(isGet)return;

        limitHandler.onGetScoreRewardRequest(scoreTable.ID);
    }

    private function _flyItem(rewardId:int):void{
        var scoreTable:LimitTimeConsumeActivityScoreConfig = limitManager.getScoreRewardByID(rewardId);
        //获取的宝箱奖励ID
        var rewardData:CRewardListData = CRewardUtil.createByDropPackageID(limitSystem.stage, scoreTable.reward);
        if(rewardData) {
            var delay:Number = 0.0;
            for each(var itemData:CRewardData in rewardData.list){
                var itemUI:RewardItemUI = new RewardItemUI();
                itemUI.num_lable.text = itemData.num.toString();
                itemUI.icon_image.url = itemData.iconSmall;
                itemUI.bg_clip.index = itemData.quality;
                itemUI.hasTakeImg.visible = false;
                var itemBox:Component =  m_limitUI.list_reward.getCell((rewardId-1)) as Component;
                TweenMax.delayedCall(delay,function(ui:RewardItemUI):void{
                    CFlyItemUtil.flyItemToBag(ui, itemBox.localToGlobal(new Point()), system);
                },[itemUI]);
                delay += 0.2;
            }
        }
    }

    /**
     * 更新积分排行数据列表
     */
    private function _onRenderScoreRankItem(item:LimitScoreboardItemUI,index:int):void{
        if(item == null || item.dataSource == null)return;
        var rankInfo:CLimitScoreRankItemData = item.dataSource as CLimitScoreRankItemData;
        if(rankInfo.roleID == 0){
            if(rankInfo.roleRank > 3){
                item.lb_rank.visible = true;
                item.lb_rank.text = ""+rankInfo.roleRank;

                item.clip_rank1.visible = false;
            }else{

                item.clip_rank1.visible = true;
                item.clip_rank1.frame = (rankInfo.roleRank-1);

                item.lb_rank.visible = false;
            }
//            item.lb_name.visible = false;
            item.lb_score.visible = false;
        }else{

            if(rankInfo.roleRank <= 3){
                item.clip_rank1.visible = true;
                item.lb_rank.visible = false;
                item.clip_rank1.frame = (rankInfo.roleRank-1);
            }else{
                item.clip_rank1.visible = false;
                item.lb_rank.visible = true;
                item.lb_rank.text = ""+rankInfo.roleRank;
            }

            var color:String = "#ffffff";
            if(rankInfo.roleRank == 1){
                color = "#f0cf4c";
            }else if(rankInfo.roleRank == 2){
                color = "#d979f9";
            }else if(rankInfo.roleRank == 3){
                color = "#58cbfb";
            }

//            item.lb_name.visible = true;
            item.lb_score.visible = true;

            item.lb_score.text = ""+ rankInfo.roleScore;
        }

        if( rankInfo.roleName.length <= 0 ){
            var rankConfig : RankConfig = getRankConfigTableByID( rankInfo.roleRank );
            if( rankConfig.needVIP > 0 ){
                item.lb_name.text = HtmlUtil.getHtmlText('v'+ rankConfig.needVIP + '且积分达到' + rankConfig.needScore + '上榜',color,14);
            }else{
                item.lb_name.text = HtmlUtil.getHtmlText('积分达到' + rankConfig.needScore + '上榜',color,14);
            }
        }else{
            item.lb_name.text = HtmlUtil.getHtmlText(rankInfo.roleName,color,14);
        }
    }

    public function updateMyScoreAndRankInfo():void{
        var myScore:int = limitManager.mySroce;
        var myRank:int = limitManager.myRank;

        if(myRank <= 0){
            m_limitUI.lb_myRank.text = CLang.LANG_00300;
        }else{
            m_limitUI.lb_myRank.text = ""+myRank;
        }
        m_limitUI.lb_myScore.text = ""+myScore;
    }

    public function updateRankReward():void{

        var rankTable1:LimitTimeConsumeActivityRankConfig = limitManager.getRankRewardTableByRank(1);
        if(rankTable1){
            var rewardData1:CRewardListData = CRewardUtil.createByDropPackageID(limitSystem.stage, rankTable1.reward);
            if(rewardData1){
                m_limitUI.list_reward1.dataSource = rewardData1.list;
            }
        }

        var rankTable2:LimitTimeConsumeActivityRankConfig = limitManager.getRankRewardTableByRank(2);
        if(rankTable2){
            var rewardData2:CRewardListData = CRewardUtil.createByDropPackageID(limitSystem.stage, rankTable2.reward);
            if(rewardData2){
                m_limitUI.list_reward2.dataSource = rewardData2.list;
            }
        }

        var rankTable3:LimitTimeConsumeActivityRankConfig = limitManager.getRankRewardTableByRank(3);
        if(rankTable3){
            var rewardData3:CRewardListData = CRewardUtil.createByDropPackageID(limitSystem.stage, rankTable3.reward);
            if(rewardData3){
                m_limitUI.list_reward3.dataSource = rewardData3.list;
            }
        }
        _updateProValue();
    }

    private function _updateProValue():void{
        //更新进度条
        var myScore:int = limitManager.mySroce;
        var curScoreConfig:LimitTimeConsumeActivityScoreConfig = limitManager.getScoreConfigByMyScore(myScore);
        var curIndex:int = curScoreConfig.index;
        var upIndex:int = curIndex - 1;
        if(upIndex <=0)upIndex = 1;
        var upScoreConfig:LimitTimeConsumeActivityScoreConfig = limitManager.getScoreRewardByIndex(upIndex);
        var index:int = curIndex - 1;
        for(var i:int = 0; i < 5 ; i++){
            if(i < index){
                (m_progressArr[i] as KOFProgressBar).value = 1.0;
            }else if(i == index){
                if(curIndex == 1){
                    (m_progressArr[i] as KOFProgressBar).value = myScore/curScoreConfig.score;
                }else{
                    (m_progressArr[i] as KOFProgressBar).value = (myScore - upScoreConfig.score)/(curScoreConfig.score - upScoreConfig.score);
                }
            }else if(i > index){
                (m_progressArr[i] as KOFProgressBar).value = 0.0;
            }
        }
    }

    private function _updateViewInfo(e:CLimitActivityEvent):void{
//        updateRankReward();
        var rewardId:int = int(e.data);
        _flyItem(rewardId);
        m_limitUI.list_reward.dataSource = limitManager.getScoreRewardList();
    }

    private function _updateMyScoreInfo(e:CLimitActivityEvent):void{
        updateRankReward();
        updateMyScoreAndRankInfo();
        m_limitUI.list_reward.dataSource = limitManager.getScoreRewardList();
    }

    private function _updateMyRankInfo(e:CLimitActivityEvent):void{
        updateMyScoreAndRankInfo();
        if(m_limitUI){
            m_limitUI.list_scoreRank.dataSource = limitManager.rankInfos.rankInfos;
        }
    }

//    private function _onRenderRewardList1(item:RewardPackageItemUI,index:int):void{
//        if(item == null || item.dataSource == null)return;
//
//        var rewardData:CRewardData = item.dataSource as CRewardData;
//        item.mc_item.box_effect.visible = rewardData.effect;
//        item.mc_item.clip_effect.autoPlay = rewardData.effect;
//        item.txt_name.visible = false;
//        item.mc_item.img.url = rewardData.iconBig;
//        item.mc_item.clip_bg.index = rewardData.quality;
//        item.mc_item.txt_num.text = rewardData.num.toString();
//        item.txt_name.text = CLang.Get("item_name_and_num", {v1:rewardData.nameWithColor, v2:rewardData.num});
//        item.toolTip = new Handler(_addTips2, [item]);
//    }

    private function _onRenderRewardList2(item:RewardItemUI,index:int):void{
        if(item == null || item.dataSource == null)return;

        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
        item.box_eff.visible = itemData.effect;
        item.clip_eff.autoPlay = itemData.effect;
        item.num_lable.text = itemData.num.toString();
        item.icon_image.url = itemData.iconSmall;
        item.bg_clip.index = itemData.quality;
        item.toolTip = new Handler(_addTips, [item]);
        item.hasTakeImg.visible = false;
    }

    private function _addTips(item:RewardItemUI) : void {
        var itemSystem:CItemSystem = limitSystem.stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }

//    private function _addTips2(item:RewardPackageItemUI) : void {
//        var itemSystem:CItemSystem = limitSystem.stage.getSystem(CItemSystem) as CItemSystem;
//        itemSystem.addTips(CItemTipsView, item);
//    }
//
//    private function _addTips3(item:LimitScoreRewardUI) : void{
//        (system.getBean( CLimitScoreRewardTipsViewHandler ) as CLimitScoreRewardTipsViewHandler).showTips(item.dataSource);
//    }

    private function _showPromptTips():String{
        var constTable:LimitTimeConsumeActivityConst = limitManager.getConstTableByID();
        if(constTable){
            return constTable.describe3;
        }
        return "";
    }

    private function _addEventListener() : void {
        system.addEventListener(CLimitActivityEvent.ACTIVITY_MYSCORE_UPDATE,_updateMyScoreInfo);
        system.addEventListener(CLimitActivityEvent.ACTIVITY_RANK_UPDATE,_updateMyRankInfo);
        system.addEventListener(CLimitActivityEvent.ACTIVITY_REWARD_UPDATE,_updateViewInfo);
    }

    private function _removeEventListener() : void {
        system.removeEventListener(CLimitActivityEvent.ACTIVITY_MYSCORE_UPDATE,_updateMyScoreInfo);
        system.removeEventListener(CLimitActivityEvent.ACTIVITY_RANK_UPDATE,_updateMyRankInfo);
        system.removeEventListener(CLimitActivityEvent.ACTIVITY_REWARD_UPDATE,_updateViewInfo);
    }

    private function _close():void{
        if(_closeHandler){
            _closeHandler.execute();
        }
    }

    private function get limitHandler() : CLimitActivityHandler {
        return system.getBean( CLimitActivityHandler ) as CLimitActivityHandler;
    }

    private function get limitManager() : CLimitActivityManager {
        return system.getBean( CLimitActivityManager ) as CLimitActivityManager;
    }

    private function get limitSystem() : CLimitActivitySystem {
        return system as CLimitActivitySystem;
    }

    private function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get uiSysTem() : CUISystem {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    public function getItemTableByID(id:int) : Item{
        var itemTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        return itemTable.findByPrimaryKey(id);
    }
    public function getRankConfigTableByID(id:int) : RankConfig{
        var itemTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RANKCONFIG);
        return itemTable.findByPrimaryKey(id);
    }

    private function get itemSystem() : CItemSystem {
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }



}
}
