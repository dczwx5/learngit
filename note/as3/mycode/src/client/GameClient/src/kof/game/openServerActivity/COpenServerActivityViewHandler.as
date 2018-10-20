//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/10/19.
 */
package kof.game.openServerActivity {

import QFLib.Foundation.CTime;

import com.greensock.TweenMax;

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.openServerActivity.data.COpenServerTargetData;
import kof.game.openServerActivity.event.COpenServerActivityEvent;
import kof.game.openServerActivity.view.COpenServerRewardTipsViewHandler;
import kof.game.player.CPlayerSystem;
import kof.table.CarnivalActivityConfig;
import kof.table.CarnivalEntryConfig;
import kof.table.CarnivalRewardConfig;
import kof.table.CarnivalTargetConfig;
import kof.ui.CUISystem;
import kof.ui.components.KOFProgressBar;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.OpenServerActivity.OpenServerActivityEntryItemUI;
import kof.ui.master.OpenServerActivity.OpenServerActivityRewardUI;
import kof.ui.master.OpenServerActivity.OpenServerActivityUI;

import morn.core.components.Box;

import morn.core.components.Button;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.Image;
import morn.core.handlers.Handler;

public class COpenServerActivityViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized:Boolean;
    private var m_openServerUI:OpenServerActivityUI;

    private var m_progressArr:Array = [];
    private var _closeHandler:Handler;

    private var _curSelectBtn:Button;
    private var _curSelectTargetLabel:String = "";
    private var _curSelectDayIndex:int = 0;

    private var m_endTime:Number = 0.0;

    private var _curTargetID : int;
    private var _lastNum : int;

    public function COpenServerActivityViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ OpenServerActivityUI ];
    }

    override protected function get additionalAssets() : Array {
        return ["frameclip_task.swf","fiest.swf"];
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
        if ( !m_openServerUI ) {
            m_openServerUI = new OpenServerActivityUI();
            m_openServerUI.btn_close.clickHandler = new Handler( _close );

            for(var i:int = 1; i < 8 ; i++){
                (m_openServerUI["btn_"+i] as Button).clickHandler = new Handler( _onDaysTabClickHandler, [m_openServerUI["btn_"+i]] );
            }

            m_openServerUI.tab_label.selectHandler = new Handler( _onOptionsTabClickHandler );

            m_openServerUI.list_reward.renderHandler = new Handler( _onRenderTargetRewardItem );//积分奖励宝箱列表

            m_progressArr.push(m_openServerUI.pro_bar1,m_openServerUI.pro_bar2,m_openServerUI.pro_bar3,m_openServerUI.pro_bar4,m_openServerUI.pro_bar5);

            m_bViewInitialized = true;
        }
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addToDisplay );
    }

    private function _addToDisplay() : void {

        if ( onInitializeView() ) {
            invalidate();

            if ( m_openServerUI )
            {
//                uiCanvas.addDialog( m_openServerUI );
                setTweenData(KOFSysTags.CARNIVAL_ACTIVITY);
                showDialog(m_openServerUI,false,_showDialogTweenEnd);

                m_endTime = openServerManager.endTime;

                this.schedule(1,_onCountDown);
                _addEventListener();

                _updateTargetCompleteNumReward();
                updateActivityState();
                updateDayRedImg();
            }

        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }

    }

    private function _showDialogTweenEnd():void {
        _onDaysTabClickHandler(m_openServerUI.btn_1);
    }

    /**
     * 倒计时
     */
    private function _onCountDown( delta : Number ):void{
        if( m_openServerUI && m_endTime > 0){
            var currTime:Number = CTime.getCurrServerTimestamp();
            var leftTime:Number = m_endTime-currTime;
            if(leftTime>0)
            {
                var days:int = leftTime/(24*3600*1000);
                m_openServerUI.clip_day.num = days;
                leftTime = leftTime-days*24*60*60*1000;
                m_openServerUI.lb_time.text = CTime.toDurTimeString(leftTime);
            }else{
                m_openServerUI.clip_day.num = 0;
                m_openServerUI.lb_time.text = CLang.LANG_00301;
                this.unschedule(_onCountDown);
            }
        }
    }

    public function updateActivityState( e:COpenServerActivityEvent = null ):void{
        if(m_openServerUI){
//            m_openServerUI.img_suo1.visible = openServerManager.isStartActivityByDay(1);
            m_openServerUI.img_suo2.visible = !openServerManager.isStartActivityByDay(2);
            m_openServerUI.img_suo3.visible = !openServerManager.isStartActivityByDay(3);
            m_openServerUI.img_suo4.visible = !openServerManager.isStartActivityByDay(4);
            m_openServerUI.img_suo5.visible = !openServerManager.isStartActivityByDay(5);
            m_openServerUI.img_suo6.visible = !openServerManager.isStartActivityByDay(6);
            m_openServerUI.img_suo7.visible = !openServerManager.isStartActivityByDay(7);

//            m_openServerUI.btn_1.disabled = !openServerManager.isStartActivityByDay(1);
            m_openServerUI.btn_2.disabled = !openServerManager.isStartActivityByDay(2);
            m_openServerUI.btn_3.disabled = !openServerManager.isStartActivityByDay(3);
            m_openServerUI.btn_4.disabled = !openServerManager.isStartActivityByDay(4);
            m_openServerUI.btn_5.disabled = !openServerManager.isStartActivityByDay(5);
            m_openServerUI.btn_6.disabled = !openServerManager.isStartActivityByDay(6);
            m_openServerUI.btn_7.disabled = !openServerManager.isStartActivityByDay(7);
        }
    }

    public function _onDaysTabClickHandler( btn:Button ):void {

        _curTargetID = 0;
        _curSelectDayIndex = int(btn.name);

        if(_curSelectBtn){
            _curSelectBtn.selected = false;
            _curSelectBtn = null;
        }

        _curSelectBtn = btn;
        _curSelectBtn.selected = true;

        m_openServerUI.tab_label.dataSource = openServerManager.getActivityLabels(int(btn.name));

        if(m_openServerUI.tab_label.selectedIndex == 0){
            _onOptionsTabClickHandler(0);
        }else{
            m_openServerUI.tab_label.selectedIndex = 0;
        }

        updateLabelRedImg();
    }

    private function _onOptionsTabClickHandler(index:int):void {
        var btn:Button = m_openServerUI.tab_label.selection as Button;
        _curSelectTargetLabel = btn.label;
        var config:CarnivalEntryConfig =  openServerManager.getActivityLabelByName(btn.label);
        if(config){
            m_openServerUI.list_item.renderHandler = new Handler( _activityItemRender );
            var dataArr:Array = openServerManager.getActivityTargetsConfig(config.targetIds);
            openServerManager.sortActivityTargetsConfig(dataArr);
            m_openServerUI.list_item.dataSource = dataArr;
        }

        _updateProValue();
    }

    /**
     * 活动目标信息
     * @param item
     * @param index
     */
    private function _activityItemRender( item:OpenServerActivityEntryItemUI, index:int):void{
        if(item == null || item.dataSource == null)return;
        var entryConfig:CarnivalTargetConfig = item.dataSource as CarnivalTargetConfig;
        var targetInfo:COpenServerTargetData = openServerManager.getTargetInfoById(entryConfig.ID);

        if(entryConfig.type == 2 || entryConfig.type == 3 || entryConfig.type == 6 || entryConfig.type == 22){
            // 这里特殊处理ID为2（剧情副本）、3（精英副本）、6（竞技排名）、22（拳皇段位）
            item.lb_dic.text = entryConfig.description;
        }else{
            if(targetInfo){
                item.lb_dic.text = entryConfig.description + " " + targetInfo.curVal + "/" + targetInfo.targetVal;
            }else{
                item.lb_dic.text = entryConfig.description + " 0/" + entryConfig.args;
            }
        }

//        item.lb_sy.text = "剩余" + targetInfo.leftNum + "个";
        var curNum : int;
        if( _curTargetID == entryConfig.ID ){
            curNum = _lastNum - 1;
            if( curNum <= 0 )
                curNum = 0;
        }else{
            if(targetInfo)
                curNum = getNum( targetInfo.obtainedNum , entryConfig );
        }
        item.lb_sy.text = "剩余" + curNum + "个";


        var isGet:Boolean = openServerManager.isGetTargetReward(entryConfig.ID);
        if(isGet){
            item.btn_get.label = "已领取";
            item.btn_get.disabled = true;
        }else{
            var isCan:Boolean = openServerManager.isCanTargetReward(entryConfig.ID);
            if(isCan){
                item.btn_get.label = "领取";
                item.btn_get.disabled = false;
            }else{
                item.btn_get.label = "未达成";
                item.btn_get.disabled = true;
            }

            if(curNum == 0)
            {
                item.btn_get.disabled = true;
            }
        }

        var rewardData:CRewardListData = CRewardUtil.createByDropPackageID(openServerSystem.stage, entryConfig.reward);
        if(rewardData){
            item.list_reward.renderHandler = new Handler( _rewardItemRender );
            item.list_reward.dataSource = rewardData.list;
        }

        item.btn_get.clickHandler = new Handler( _onGetRewardClick, [entryConfig.ID,curNum] );
    }

    private function getNum( x : int  , carnivalTargetConfig : CarnivalTargetConfig):int{
        if( x <= ( 1 - carnivalTargetConfig.percentNum / 10000 ) * carnivalTargetConfig.maxNum ){
//            int((rM^2/(x+rM))
            return int( ( ( carnivalTargetConfig.percentNum / 10000 ) * Math.pow( carnivalTargetConfig.maxNum ,2) ) / ( x + ( carnivalTargetConfig.percentNum / 10000 ) * carnivalTargetConfig.maxNum ) );
        }else{
            return carnivalTargetConfig.maxNum - x ;
        }
    }

    private function _rewardItemRender( item:RewardItemUI,index:int ):void{
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

    /**
     * 目标完成数量奖励礼包
     */
    private function _onRenderTargetRewardItem(item:OpenServerActivityRewardUI,index:int):void{
        if(item == null || item.dataSource == null)return;

        if(index == 0){
            item.img_baozi.visible = true;
            item.star1_btn.visible = false;
        }else{
            item.img_baozi.visible = false;
            item.star1_btn.visible = true;
        }

        var rewardTable:CarnivalRewardConfig = item.dataSource as CarnivalRewardConfig;

        var isGet:Boolean = openServerManager.isGetReward(rewardTable.ID);
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
            if(openServerManager.getTargetComlpeteNum() >= rewardTable.completeNum){
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
        item.lb_scoreCount.text = openServerManager.getTargetComlpeteNum() + "/" + rewardTable.completeNum;
//        item.toolTip = new Handler(_addTips2,[item]);
        item.star1_btn.dataSource = rewardTable.reward;
        item.toolTip = new Handler(itemSystem.showRewardTips,[item.star1_btn,[["完成数量达到"+rewardTable.completeNum+" 可领取"],status,1]]);

    }

    private function _onRewardBoxClick(e:MouseEvent):void{
        var item:OpenServerActivityRewardUI = e.currentTarget as OpenServerActivityRewardUI;
        var rewardTable:CarnivalRewardConfig = item.dataSource as CarnivalRewardConfig;//send consume_blue_diamond
        var isGet:Boolean = openServerManager.isGetReward(rewardTable.ID);
        if(isGet)return;
        openServerHandler.onGetCompleteRewardRequest(rewardTable.ID);
    }

    private function _addTips2(item:OpenServerActivityRewardUI) : void{
        (system.getBean( COpenServerRewardTipsViewHandler ) as COpenServerRewardTipsViewHandler).showTips(item.dataSource);
    }

    private function _onGetRewardClick(targetId:int,lastNum : int):void{
//        var targetInfo:COpenServerTargetData = openServerManager.getTargetInfoById(targetId);
//        if(targetInfo.leftNum <= 0){
//            uiSysTem.showMsgAlert("奖励剩余数量不足");
//            return;
//        }
        _curTargetID = targetId;
        _lastNum = lastNum;

        openServerHandler.onGetTargetRewardRequest(targetId);
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_openServerUI ) {
            _removeEventListener();
            this.unschedule(_onCountDown);
            _curTargetID = 0;
        }
    }

    public function set closeHandler( value:Handler ):void {
        _closeHandler = value;
    }


    override protected virtual function updateData():void {
        super.updateData();

        if ( m_openServerUI ) {

        }
    }

    private function _updateProValue():void{
        //更新进度条
        var myNum:int = openServerManager.getTargetComlpeteNum();
        var curConfig:CarnivalRewardConfig = openServerManager.getCompleteRewardConfigByMyScore(myNum);
        var curIndex:int = curConfig.ID;
        var upIndex:int = curIndex - 1;
        if(upIndex <=0)upIndex = 1;
        var upScoreConfig:CarnivalRewardConfig = openServerManager.getRewardConfigById(upIndex);
        var index:int = curIndex - 1;
        for(var i:int = 0; i < 5 ; i++){
            if(i < index){
                (m_progressArr[i] as KOFProgressBar).value = 1.0;
            }else if(i == index){
                if(curIndex == 1){
                    (m_progressArr[i] as KOFProgressBar).value = myNum/curConfig.completeNum;
                }else{
                    (m_progressArr[i] as KOFProgressBar).value = (myNum - upScoreConfig.completeNum)/(curConfig.completeNum - upScoreConfig.completeNum);
                }
            }else if(i > index){
                (m_progressArr[i] as KOFProgressBar).value = 0.0;
            }
        }
    }

    private function _addTips(item:RewardItemUI) : void {
        var itemSystem:CItemSystem = openServerSystem.stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }

    private function _addEventListener() : void {

        system.addEventListener(COpenServerActivityEvent.ACTIVITY_TARGET_UPDATE,_updateTargetInfo);
        system.addEventListener(COpenServerActivityEvent.ACTIVITY_TARGET_REWARD,_updateTargetInfo);
        system.addEventListener(COpenServerActivityEvent.ACTIVITY_COMPLETE_REWARD,_updateTargetCompleteNumReward);
        system.addEventListener(COpenServerActivityEvent.ACTIVITY_START,updateActivityState);

    }

    private function _removeEventListener() : void {

        system.removeEventListener(COpenServerActivityEvent.ACTIVITY_TARGET_UPDATE,_updateTargetInfo);
        system.removeEventListener(COpenServerActivityEvent.ACTIVITY_TARGET_REWARD,_updateTargetInfo);
        system.removeEventListener(COpenServerActivityEvent.ACTIVITY_COMPLETE_REWARD,_updateTargetCompleteNumReward);
        system.removeEventListener(COpenServerActivityEvent.ACTIVITY_START,updateActivityState);
    }

    private function _updateTargetInfo(e:COpenServerActivityEvent):void{
        if(_curSelectTargetLabel && _curSelectTargetLabel != ""){
            var config:CarnivalEntryConfig =  openServerManager.getActivityLabelByName(_curSelectTargetLabel);
            if(config){
                var dataArr:Array = openServerManager.getActivityTargetsConfig(config.targetIds);
                openServerManager.sortActivityTargetsConfig(dataArr);
                m_openServerUI.list_item.dataSource = dataArr;

                m_openServerUI.list_reward.dataSource = openServerManager.getRewardList();
                _updateProValue();
            }
        }

        updateDayRedImg();
    }

    private function _updateTargetCompleteNumReward(e:COpenServerActivityEvent = null):void{
        if(m_openServerUI){
            m_openServerUI.list_reward.dataSource = openServerManager.getRewardList();
            _updateProValue();
        }

        if(e){
            _flyRewardItem( int(e.data));
        }
    }

    private function _flyRewardItem(rewardId:int):void{
        var scoreTable:CarnivalRewardConfig = openServerManager.getRewardConfigById(rewardId);
        //获取的宝箱奖励ID
        var rewardData:CRewardListData = CRewardUtil.createByDropPackageID(openServerSystem.stage, scoreTable.reward);
        if(rewardData) {
            var delay:Number = 0.0;
            for each(var itemData:CRewardData in rewardData.list){
                var itemUI:RewardItemUI = new RewardItemUI();
                itemUI.num_lable.text = itemData.num.toString();
                itemUI.icon_image.url = itemData.iconSmall;
                itemUI.bg_clip.index = itemData.quality;
                itemUI.hasTakeImg.visible = false;
                var itemBox:Component =  m_openServerUI.list_reward.getCell((rewardId-1)) as Component;
                TweenMax.delayedCall(delay,function(ui:RewardItemUI):void{
                    CFlyItemUtil.flyItemToBag(ui, itemBox.localToGlobal(new Point()), system);
                },[itemUI]);
                delay += 0.2;
            }
        }
    }

    public function flyTargetItem(targetId:int):void{
        var items:Vector.<Box> = m_openServerUI.list_item.cells;
        var entryConfig:CarnivalTargetConfig = null;
        var len:int = items.length;
        var ui:RewardItemUI = null;
        for each(var itemUI:OpenServerActivityEntryItemUI in items){
            if(itemUI.dataSource){
                entryConfig = itemUI.dataSource as CarnivalTargetConfig;
                if(entryConfig.ID == targetId){
                    len = itemUI.list_reward.cells.length;
                    for(var i:int=0; i<len; i++) {
                        ui = itemUI.list_reward.cells[i] as RewardItemUI;
                        if(ui.dataSource){
                            CFlyItemUtil.flyItemToBag(ui, ui.localToGlobal(new Point()), system);
                        }
                    }
                }
            }
        }
    }

    public function updateDayRedImg():void{
        if(m_openServerUI){
            m_openServerUI.img_redDay_1.visible = openServerManager.isShowRedByDay(1);
            m_openServerUI.img_redDay_2.visible = openServerManager.isShowRedByDay(2);
            m_openServerUI.img_redDay_3.visible = openServerManager.isShowRedByDay(3);
            m_openServerUI.img_redDay_4.visible = openServerManager.isShowRedByDay(4);
            m_openServerUI.img_redDay_5.visible = openServerManager.isShowRedByDay(5);
            m_openServerUI.img_redDay_6.visible = openServerManager.isShowRedByDay(6);
            m_openServerUI.img_redDay_7.visible = openServerManager.isShowRedByDay(7);
        }

        updateLabelRedImg();
    }

    public function updateLabelRedImg():void{
        if(m_openServerUI){
            if(_curSelectDayIndex != 0){
                var activityConf:CarnivalActivityConfig = openServerManager.getActivityConfigById(_curSelectDayIndex);
                var labelArr:Array = openServerManager.getActivityLabels(_curSelectDayIndex);
                for(var i:int = 0 ; i < labelArr.length ; i++){
                    var isShow:Boolean = openServerManager.isShowRedByLabel(labelArr[i]);
                    (m_openServerUI["img_redLabel_"+i] as Image).visible = isShow;
                }
            }
        }
    }

    private function _close():void{
        if(_closeHandler){
            _closeHandler.execute();
        }
    }

    private function get openServerHandler() : COpenServerActivityHandler {
        return system.getBean( COpenServerActivityHandler ) as COpenServerActivityHandler;
    }

    private function get openServerManager() : COpenServerActivityManager {
        return system.getBean( COpenServerActivityManager ) as COpenServerActivityManager;
    }

    private function get openServerSystem() : COpenServerActivitySystem {
        return system as COpenServerActivitySystem;
    }

    private function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get uiSysTem() : CUISystem {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get itemSystem() : CItemSystem {
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }


    public function get selectDay() : int {
        return _curSelectDayIndex; // 1开始
    }
    public function get selectTab() : int {
        if (m_openServerUI) {
            return m_openServerUI.tab_label.selectedIndex;
        }
        return 0;
    }

}
}
