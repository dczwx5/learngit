//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/19.
 */
package kof.game.taskcallup.view {

import QFLib.Foundation.CTime;

import flash.geom.Point;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubManager;
import kof.game.club.CClubSystem;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.taskcallup.CTaskCallUpEvent;
import kof.game.taskcallup.CTaskCallUpHandler;
import kof.game.taskcallup.CTaskCallUpManager;
import kof.game.taskcallup.CTaskCallUpSystem;
import kof.game.taskcallup.data.CCallUpAcceptedData;
import kof.game.taskcallup.data.CCallUpListData;
import kof.game.taskcallup.data.CTaskCallUpConst;
import kof.game.taskcallup.data.CTaskCallUpPath;
import kof.table.CallUpConstant;
import kof.table.VipPrivilege;
import kof.ui.CUISystem;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.SevenDays.RewardItem1UI;
import kof.ui.master.taskcallup.TaskCallUpIIUI;
import kof.ui.master.taskcallup.TaskCallUpIngItemIIUI;
import kof.ui.master.taskcallup.TaskCallUpItemIIUI;
import kof.ui.master.taskcallup.TaskCallUpUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.List;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CTaskCallUpViewHandler extends CTweenViewHandler {

    private var _taskCallUpUI : TaskCallUpIIUI;

    private var m_pCloseHandler : Handler;

    private var m_viewExternal:CViewExternalUtil;

//    private var _canRwardNum : int;

    public function CTaskCallUpViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _taskCallUpUI = null;
    }
    override public function get viewClass() : Array {
        return [ TaskCallUpUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "frameclip_xuanfu.swf"
        ];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_taskCallUpUI ) {
            _taskCallUpUI = new TaskCallUpIIUI();

            _taskCallUpUI.closeHandler = new Handler( _onClose );

            _taskCallUpUI.list_task.renderHandler = new Handler( renderItem_task );
            _taskCallUpUI.list_task.selectHandler = new Handler( selectTaskItemHandler );
            _taskCallUpUI.list_task.dataSource = [];

            _taskCallUpUI.list_accepted.renderHandler = new Handler( renderItem_accepted );
            _taskCallUpUI.list_accepted.selectHandler = new Handler( selectacceptedItemHandler );

            _taskCallUpUI.btn_change.clickHandler = new Handler( _onChangeListHandler );

//            _taskCallUpUI.img_hero.url = CPlayerPath.getUIHeroFacePath(306);

            CSystemRuleUtil.setRuleTips(_taskCallUpUI.img_tips, CLang.Get("taskCallup_rule"));
        }

        return _taskCallUpUI;
    }

    //待接受任务列表
    private function renderItem_task(item:Component, idx:int):void {
        if (!(item is TaskCallUpItemIIUI)) {
            return;
        }
        var taskCallUpItemUI:TaskCallUpItemIIUI = item as TaskCallUpItemIIUI;
        if( taskCallUpItemUI.dataSource ){
            var pCallUpListData : CCallUpListData = taskCallUpItemUI.dataSource as CCallUpListData;
            taskCallUpItemUI.txt_name.text = pCallUpListData.taskCallUp.name;
            taskCallUpItemUI.txt_desc.text = pCallUpListData.taskCallUp.desc;
            var h : int = Math.floor( pCallUpListData.taskCallUp.time / 60 );
            var m : int = pCallUpListData.taskCallUp.time % 60;
            var timeStr :String = '';
            if( h > 0 ) timeStr = h + '小时';
            if( m > 0 ) timeStr = m + '分';
            taskCallUpItemUI.txt_time.text = timeStr;
            taskCallUpItemUI.img.url = CTaskCallUpPath.getTaskCallUpIocnUrlByID( pCallUpListData.taskCallUp.icon );

            taskCallUpItemUI.img_accepted.visible = pCallUpListData.accepted;
            taskCallUpItemUI.btn_ok.visible = !pCallUpListData.accepted;

            taskCallUpItemUI.img_add1.visible = taskCallUpItemUI.img_add2.visible = false;
            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, taskCallUpItemUI);
            var item_list : List = (m_viewExternal.view as CRewardItemListView).uiView.item_list;
            item_list.spaceX = 6 ;
            item_list.addEventListener( UIEvent.ITEM_RENDER, _onListChange );
            m_viewExternal.show();
            m_viewExternal.setData( pCallUpListData.taskCallUp.reward );
            m_viewExternal.updateWindow();

            taskCallUpItemUI.btn_ok.clickHandler = new Handler( _onSetHandler ,[pCallUpListData] );
        }
    }
    private function _onListChange( evt : UIEvent ):void{
        var item_list : List = evt.currentTarget as List;
//        item_list.removeEventListener( UIEvent.ITEM_RENDER, _onListChange );
        var taskCallUpItemUI : TaskCallUpItemIIUI = item_list.parent.parent as TaskCallUpItemIIUI;
        var pCallUpListData : CCallUpListData = taskCallUpItemUI.dataSource as CCallUpListData;
        if( pCallUpListData.taskCallUp.type == CTaskCallUpConst.TEAM_TYPE ){
            var rewardItem : RewardItemUI;
            var rewardData : CRewardData;
            var p : Point;
            var p2 : Point;
            for each ( rewardItem in item_list.cells ){
                rewardData = rewardItem.dataSource as  CRewardData;
                if( rewardData && ( rewardData.data.ID == 13 || rewardData.data.ID == 1  ) ){//神器能量和金币，显示‘加成’，策划说写死
                     p  = rewardItem.parent.localToGlobal( new Point( rewardItem.x, rewardItem.y ) );
                     p2  = taskCallUpItemUI.globalToLocal( p );
//                    if( !taskCallUpItemUI.img_add1.visible ){
//                        taskCallUpItemUI.img_add1.visible = true;
//                        taskCallUpItemUI.img_add1.x = p2.x + 5;
//                    }else if( !taskCallUpItemUI.img_add2.visible ){
//                        taskCallUpItemUI.img_add2.visible = true;
//                        taskCallUpItemUI.img_add2.x = p2.x + 5;
//                    }
                    if( rewardData.data.ID == 13 && !taskCallUpItemUI.img_add1.visible ){
                        taskCallUpItemUI.img_add1.visible = true;
//                        taskCallUpItemUI.img_add1.x = p2.x + 5;
                        taskCallUpItemUI.img_add1.x = 43;
                    }else if( rewardData.data.ID == 1 && !taskCallUpItemUI.img_add2.visible ){
                        taskCallUpItemUI.img_add2.visible = true;
//                        taskCallUpItemUI.img_add2.x = p2.x + 5;
                        taskCallUpItemUI.img_add2.x = 101;
                    }

                }
            }
        }

    }
    private function selectTaskItemHandler( index : int ) : void {
        var taskCallUpItemUI : TaskCallUpItemIIUI = _taskCallUpUI.list_task.getCell( index ) as TaskCallUpItemIIUI;
        if ( !taskCallUpItemUI )
            return;

    }
    //已接受任务列表
    private function renderItem_accepted(item:Component, idx:int):void {
        if (!(item is TaskCallUpIngItemIIUI)) {
            return;
        }
    }
    private function selectacceptedItemHandler( index : int ) : void {
        var taskCallUpIngItemUI : TaskCallUpIngItemIIUI = _taskCallUpUI.list_accepted.getCell( index ) as TaskCallUpIngItemIIUI;
        if ( !taskCallUpIngItemUI )
            return;
        var pCallUpAcceptedData : CCallUpAcceptedData = taskCallUpIngItemUI.dataSource as CCallUpAcceptedData;
        if( !pCallUpAcceptedData )
                return
        if( pCallUpAcceptedData.endTime - CTime.getCurrServerTimestamp() <= 0 ){
            _pTaskCallUpHandler.onTaskCallUpRewardRequest( pCallUpAcceptedData.taskId );
        }else{
            _pTaskCallUpInfoViewHandler.addDisplay( pCallUpAcceptedData );
        }

        _taskCallUpUI.list_accepted.selectedIndex = -1;
    }
    private function _onSetHandler(...args):void{

        var pCallUpListData : CCallUpListData = args[0] as CCallUpListData;

        if( _pTaskCallUpManager.callUpLimit <= 0 ){
            _pCUISystem.showMsgAlert('很抱歉，您今天的接取次数已用完，无法接取。');
            return;
        }
        var num : int;
        for( var index : int = 0 ; index < _pTaskCallUpManager.acceptedCallUpList.length ; index ++ ){
             if( _pTaskCallUpManager.acceptedCallUpList[index] is CCallUpAcceptedData )
                 num++;
        }
        if( num >= 3 ){
            _pCUISystem.showMsgAlert('很抱歉，您当前进行中召集任务已满，无法接取。');
            return;
        }
        if( pCallUpListData.taskCallUp.type == CTaskCallUpConst.CLUB_TYPE && !_pClubManager.isInClub ){
            _pCUISystem.showMsgAlert('很抱歉，您不在俱乐部中，无法接取俱乐部任务。');
            return;
        }
        _pTaskCallUpSetViewHandler.addDisplay( pCallUpListData );
    }
    private function _onChangeListHandler(...args):void{
//        if( _playerData.currency.purpleDiamond < int( _taskCallUpUI.txt_need.text ) &&
//                _playerData.currency.blueDiamond < int( _taskCallUpUI.txt_need.text ) &&
//                ( _playerData.currency.purpleDiamond + _playerData.currency.blueDiamond ) < int( _taskCallUpUI.txt_need.text )
//        ){
//            _pCUISystem.showMsgAlert('很抱歉，您的绑钻不足，无法进行次操作。');
//            return;
//        }

        _pCUISystem.showMsgBox( '需要消耗' + int( _taskCallUpUI.txt_need.text ) + '绑钻，确定继续吗？',okFun,null,true,null,null,true,"COST_BIND_D" );
        function okFun():void{
            var cost:int = int( _taskCallUpUI.txt_need.text );
            var own:int = _playerData.currency.purpleDiamond + _playerData.currency.blueDiamond;
            if(own < cost)
            {
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
            }

            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( int( _taskCallUpUI.txt_need.text ), onRefreshCallUpRequest );
        }
        function onRefreshCallUpRequest():void{
            _pTaskCallUpHandler.onRefreshCallUpRequest();
        }

    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay() : void {
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
        _addEventListeners();
        _taskCallUpUI.list_accepted.dataSource = [];
        _pTaskCallUpHandler.onTaskCallUpListRequest();
    }

    public function removeDisplay() : void {
        closeDialog();
    }
    private function _onTaskCallUpInfoResponseHandler( evt : CTaskCallUpEvent ):void{
//        _pTaskCallUpManager.callUpList.sort( randomSort );
        _taskCallUpUI.list_task.dataSource = _pTaskCallUpManager.callUpList;
        _pTaskCallUpManager.acceptedCallUpList.length = 3;
        _taskCallUpUI.list_accepted.dataSource = _pTaskCallUpManager.acceptedCallUpList;
        _taskCallUpUI.list_accepted.selectedIndex = -1;
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.VIPPRIVILEGE );
        var vipPrivilege : VipPrivilege = pTable.findByPrimaryKey( _playerData.vipData.vipLv );
        _taskCallUpUI.txt_num.text = _pTaskCallUpManager.callUpLimit  + '/' + vipPrivilege.callupLimit;
        _onRefreshNeed();
        if( !_taskCallUpUI.parent ){
            unschedule( _onRefreshTime );
            schedule( 1 , _onRefreshTime );
        }
        _onRefreshTime( 0 );
        if ( _taskCallUpUI && !_taskCallUpUI.parent ) {
//            uiCanvas.addDialog( _taskCallUpUI );
            setTweenData(KOFSysTags.TASKCALLUP, new Point(950, 600));
            showDialog(_taskCallUpUI);

        }
    }
    private function _onTaskCallUpRefreshResponseHandler( evt : CTaskCallUpEvent ):void{
//        _pTaskCallUpManager.callUpList.sort( randomSort );
        _taskCallUpUI.list_task.dataSource = _pTaskCallUpManager.callUpList;
        _onRefreshNeed();
    }
    private function _onRefreshNeed():void{
        var pTable : IDataTable  = _pCDatabaseSystem.getTable( KOFTableConstants.CALLUPCONSTANT );
        var callUpConstant : CallUpConstant = pTable.findByPrimaryKey( 1 );
        if( _pTaskCallUpManager.refresh >= callUpConstant.refresh.length )
            _taskCallUpUI.txt_need.text = String( callUpConstant.refresh[ callUpConstant.refresh.length - 1 ] );
        else
            _taskCallUpUI.txt_need.text = String( callUpConstant.refresh[ _pTaskCallUpManager.refresh ] );
    }


    private function _onRefreshTime( delta : Number ):void{
        //刷新时间
        if( _pTaskCallUpManager.refreshTime - CTime.getCurrServerTimestamp() <= 0 ){
            _taskCallUpUI.txt_time.text = '00:00:00';
            _pTaskCallUpHandler.onTaskCallUpListRequest();
        }else{
            _taskCallUpUI.txt_time.text = CTime.toDurTimeString( _pTaskCallUpManager.refreshTime - CTime.getCurrServerTimestamp() );
        }
       //已经接取任务
        var taskCallUpIngItemUI:TaskCallUpIngItemIIUI;
        var canRwardNum : int;
        for each( taskCallUpIngItemUI in _taskCallUpUI.list_accepted.cells ){
            if( taskCallUpIngItemUI.dataSource == null){
//                taskCallUpIngItemUI.img.url = CTaskCallUpPath.getTaskCallUpIocnUrlByID( 'icon_gdzj_zanweijiequ' );
                taskCallUpIngItemUI.img.url = '';
                taskCallUpIngItemUI.txt_notAccept.visible = true;//未接取
                taskCallUpIngItemUI.toolTip =
                        taskCallUpIngItemUI.txt_canAward.visible =
                                taskCallUpIngItemUI.txt_time.visible = false;
                taskCallUpIngItemUI.clip_bg.index = 0;
                taskCallUpIngItemUI.frameclip_xuanfu.visible = false;
            }else if( taskCallUpIngItemUI.dataSource is CCallUpAcceptedData ) {
                var pCallUpAcceptedData : CCallUpAcceptedData = taskCallUpIngItemUI.dataSource as CCallUpAcceptedData;
                taskCallUpIngItemUI.img.url = CTaskCallUpPath.getTaskCallUpIocnUrlByID( pCallUpAcceptedData.taskCallUp.icon );
                if( pCallUpAcceptedData.endTime - CTime.getCurrServerTimestamp() <= 0 ){//已完成
                    taskCallUpIngItemUI.txt_canAward.visible = true;
                    taskCallUpIngItemUI.toolTip =
                            taskCallUpIngItemUI.txt_notAccept.visible =
                                    taskCallUpIngItemUI.txt_time.visible = false;
                    taskCallUpIngItemUI.clip_bg.index = 2;
                    taskCallUpIngItemUI.frameclip_xuanfu.visible = true;
                    canRwardNum ++;
                }else{//进行中
                    taskCallUpIngItemUI.txt_time.visible = true;
                    taskCallUpIngItemUI.txt_notAccept.visible =
                            taskCallUpIngItemUI.txt_canAward.visible = false;
                    taskCallUpIngItemUI.txt_time.text = CTime.toDurTimeString( pCallUpAcceptedData.endTime - CTime.getCurrServerTimestamp() );
                    taskCallUpIngItemUI.toolTip = '点击查看详情';
                    taskCallUpIngItemUI.clip_bg.index = 1;
                    taskCallUpIngItemUI.frameclip_xuanfu.visible = false;
                }
            }
        }
//        if( canRwardNum > _canRwardNum ){
//            ( system as CTaskCallUpSystem ).onSystemNotice( true );
//        }
//        _canRwardNum = canRwardNum;


    }
    //随机排序
    private function randomSort( a : * , b : * ):int{
        if( Math.random() < 0.5 ){
            return -1;
        }
        return 1;
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        _removeEventListeners();
        unschedule( _onRefreshTime );
    }

    private function _addEventListeners():void {
        _removeEventListeners();
        system.addEventListener( CTaskCallUpEvent.TASK_CALL_UP_UPDATE, _onTaskCallUpInfoResponseHandler );
        system.addEventListener( CTaskCallUpEvent.TASK_CALL_UP_REFRESH, _onTaskCallUpRefreshResponseHandler );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CTaskCallUpEvent.TASK_CALL_UP_UPDATE ,_onTaskCallUpInfoResponseHandler );
        system.removeEventListener( CTaskCallUpEvent.TASK_CALL_UP_REFRESH ,_onTaskCallUpRefreshResponseHandler );
    }
    private function get _pTaskCallUpHandler():CTaskCallUpHandler{
        return system.getBean( CTaskCallUpHandler ) as CTaskCallUpHandler;
    }
    private function get _pTaskCallUpManager():CTaskCallUpManager{
        return system.getBean( CTaskCallUpManager ) as CTaskCallUpManager;
    }
    private function get _pTaskCallUpSetViewHandler():CTaskCallUpSetViewHandler{
        return system.getBean( CTaskCallUpSetViewHandler ) as CTaskCallUpSetViewHandler;
    }
    private function get _pTaskCallUpInfoViewHandler():CTaskCallUpInfoViewHandler{
        return system.getBean( CTaskCallUpInfoViewHandler ) as CTaskCallUpInfoViewHandler;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pClubManager():CClubManager{
        return (system.stage.getSystem( CClubSystem ) as CClubSystem ).getBean( CClubManager ) as CClubManager ;
    }


}
}
