//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/10.
 */
package kof.game.task {

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubSystem;
import kof.game.club.data.CClubConst;
import kof.game.common.CFlyItemUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.CViewExternalUtil;
import kof.game.instance.CInstanceSystem;
import kof.game.item.CItemSystem;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.task.data.CTaskConditionType;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskJumpConst;
import kof.game.task.data.CTaskPath;
import kof.game.task.data.CTaskStateType;
import kof.game.task.data.CTaskType;
import kof.table.TaskActive;
import kof.ui.CUISystem;
import kof.ui.master.task.TaskActiveItemUI;
import kof.ui.master.task.TaskItemUI;
import kof.ui.master.task.TaskUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.List;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CTaskViewHandler extends CTweenViewHandler {

    private var m_taskUI:TaskUI;
    private var m_pCloseHandler : Handler;
    private var m_viewExternal:CViewExternalUtil;
    private var _activeItemAry : Array;
    private var _playActiveAwardGetEff :Boolean;

    private var m_bViewInitialized : Boolean;

    public function CTaskViewHandler() {
        super( false );
    }
    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        m_taskUI = null;
    }

    override public function get viewClass() : Array {
        return [ TaskUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "frameclip_task.swf"
        ];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_taskUI ) {
                m_taskUI = new TaskUI();
                m_taskUI.box_num1.visible =
                        m_taskUI.box_num2.visible =
                                false;
                m_taskUI.viewI.list.renderHandler = new Handler( renderItem );
                m_taskUI.viewI.list.dataSource = [];
                m_taskUI.viewII.list.renderHandler = new Handler( renderItem );
                m_taskUI.viewII.list.dataSource = [];

                m_taskUI.tab.selectHandler = new Handler( _onTabSelectedHandler );

//                m_taskUI.btn_getAllReward.clickHandler = new Handler(_getAllRewardHandler);
                _activeItemAry = [];
                initActiveViewHandler();
				 m_taskUI.img_taskAllDone.url = "icon/task/taskdone.png";
                m_taskUI.img_taskAllDone.visible = false;

                m_taskUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }


    private function initActiveViewHandler():void{
        var taskActiveTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.TASK_ACTIVE );
        var taskActiveAry : Array = taskActiveTable.toArray();
        var xLen : Number = ( m_taskUI.viewI.active.pro.width / 100 ) * ( 100 / (taskActiveAry[taskActiveAry.length - 1 ] as TaskActive).active );
        var taskActive : TaskActive;
        var taskActiveItem : TaskActiveItemUI;
        for each( taskActive in taskActiveAry ){
            taskActiveItem = new TaskActiveItemUI();
            taskActiveItem.box_eff.visible =
                    taskActiveItem.box_get.visible =
                                    false;
            taskActiveItem.frameclip_get.stop();
            taskActiveItem.frameclip_eff.stop();
            taskActiveItem.y = 19;
            taskActiveItem.x = m_taskUI.viewI.active.pro.x + xLen * taskActive.active - taskActiveItem.width + 12;
            taskActiveItem.txt.text = String( taskActive.active );
            taskActiveItem.clip.dataSource = taskActive;
            m_taskUI.viewI.active.addChild( taskActiveItem );
            _activeItemAry.push( taskActiveItem );
//            taskActiveItem.toolTip = new Handler( showActiveItemTips, [taskActiveItem] );
        }
    }

    private function _onTabSelectedHandler( index : int ):void{
        m_taskUI.viewI.visible = m_taskUI.tab.selectedIndex == 0;
        m_taskUI.viewII.visible = m_taskUI.tab.selectedIndex == 1;
        var type : int = index + 2;
        var taskAry : Array  = pCTaskManager.getTaskDatasByTypeAndSort( type );
        if( m_taskUI.tab.selectedIndex == 0 ){
            m_taskUI.viewI.list.dataSource = taskAry;
            m_taskUI.viewI.list.scrollTo( 0 );
            m_taskUI.img_taskAllDone.visible = m_taskUI.viewI.list.dataSource.length <= 0;
        }else{
            m_taskUI.viewII.list.dataSource = taskAry;
            m_taskUI.viewII.list.scrollTo( 0 );
            m_taskUI.img_taskAllDone.visible = m_taskUI.viewII.list.dataSource.length <= 0;
        }
    }
    private var _updateList : Array;
    private var _lastType : int;
    private function _onTaskListUpdate( evt:CTaskEvent = null ):void{
        var type : int = m_taskUI.tab.selectedIndex + 2;
        var list : List;
        type == CTaskType.DAILY_TASK ? list = m_taskUI.viewI.list : list = m_taskUI.viewII.list ;
        var taskAry : Array = pCTaskManager.getTaskDatasByTypeAndSort( type );

        if( !_updateList )
            _updateList = [];

        if( _lastType != type ){
            _updateList = [];
        }
        _updateList.push( [taskAry , list, type ] );

        if( _updateList.length > 1 ){
            m_taskUI.viewI.list.removeEventListener( UIEvent.ITEM_RENDER ,_updateListView );
            m_taskUI.viewII.list.removeEventListener( UIEvent.ITEM_RENDER ,_updateListView );
            if( list == m_taskUI.viewI.list )
                m_taskUI.viewI.list.addEventListener( UIEvent.ITEM_RENDER ,_updateListView );
            else if( list == m_taskUI.viewII.list )
                m_taskUI.viewII.list.addEventListener( UIEvent.ITEM_RENDER ,_updateListView );
        }else{
            _updateListView();
        }
    }
    private function _updateListView( ):void{
        var ary : Array = _updateList.shift();
        if( null == ary || int( ary[2] ) != m_taskUI.tab.selectedIndex + 2 )
                return;
        m_taskUI.img_taskAllDone.visible = ( ary[0] as Array ).length <= 0;
        ( ary[1] as List ).dataSource = ary[0] as Array;

        _onTagHandler();
    }

    private function renderItem(item:Component, idx:int):void {
        if (!(item is TaskItemUI)) {
            return;
        }
        var pTaskItemUI:TaskItemUI = item as TaskItemUI;
        var pCTaskData : CTaskData = pTaskItemUI.dataSource as CTaskData;
        if( pCTaskData ){
//            if( pCTaskData.task == null ){
//                _pCUISystem.showMsgBox(  pCTaskData.taskID + ' 。。null')
//                return;
//            }
            pTaskItemUI.txt_name.text = pCTaskData.task.name;
            pTaskItemUI.txt_desc.text = pCTaskData.task.desc;
            pTaskItemUI.img_taskIcon.url = CTaskPath.getTaskIocnUrlByID( pCTaskData.task.image );
//            if( pCTaskData.task.type == CTaskType.LONG_LINE_TASK ){
//                pTaskItemUI.txt_active.text = "";
//            }else{
//                pTaskItemUI.txt_active.text = "活跃值  " + pCTaskData.task.active;
//            }
            //进度
            if( pCTaskData.task.condition == CTaskConditionType.Type_119 ){
                pTaskItemUI.txt_pro.text = '[0/1]';
            }else if( pCTaskData.task.condition == CTaskConditionType.Type_107
                    || pCTaskData.task.condition == CTaskConditionType.Type_110
                    || pCTaskData.task.condition == CTaskConditionType.Type_127
                    || pCTaskData.task.condition == CTaskConditionType.Type_128
                    || pCTaskData.task.condition == CTaskConditionType.Type_129
                    || pCTaskData.task.condition == CTaskConditionType.Type_130
                    || pCTaskData.task.condition == CTaskConditionType.Type_131
                    || pCTaskData.task.condition == CTaskConditionType.Type_132
                    || pCTaskData.task.condition == CTaskConditionType.Type_133
                    || pCTaskData.task.condition == CTaskConditionType.Type_139
            ){
                if( pCTaskData.conditionParam[2] > 0 ){
                    pTaskItemUI.txt_pro.text = "[<font color='#88ff31'>" + pCTaskData.conditionParam[2] + "</font>/" + pCTaskData.conditionParam[1] + "]";
                }else{
                    pTaskItemUI.txt_pro.text = "[" + pCTaskData.conditionParam[2] + "/" + pCTaskData.conditionParam[1] + "]";
                }

            }else if( pCTaskData.task.condition == CTaskConditionType.Type_109){
                if( pCTaskData.conditionParam[0] >= 10000 ){
                    pTaskItemUI.txt_pro.text = "[" + pCTaskData.conditionParam[1] + "/" + int( pCTaskData.conditionParam[0] / 10000 ) + '万]';
                    if( pCTaskData.conditionParam[1] > 10000 ){
                        pTaskItemUI.txt_pro.text = "[<font color='#88ff31'>" + int( pCTaskData.conditionParam[1] / 10000 ) + '万' + "</font>/" + int( pCTaskData.conditionParam[0] / 10000 ) + '万]';
                    }else if( pCTaskData.conditionParam[1] > 0 ){
                        pTaskItemUI.txt_pro.text = "[<font color='#88ff31'>" + pCTaskData.conditionParam[1] + "</font>/" + int( pCTaskData.conditionParam[0] / 10000 ) + '万]';
                    }
                }else{
                    if( pCTaskData.conditionParam[1] > 10000){
                        pTaskItemUI.txt_pro.text = "[<font color='#88ff31'>" + int( pCTaskData.conditionParam[1]/10000) + '万' + "</font>/" + pCTaskData.conditionParam[0] + "]";
                    }else if( pCTaskData.conditionParam[1] > 0 ){
                        pTaskItemUI.txt_pro.text = "[<font color='#88ff31'>" + pCTaskData.conditionParam[1] + "</font>/" + pCTaskData.conditionParam[0] + "]";
                    }else{
                        pTaskItemUI.txt_pro.text = "[" + pCTaskData.conditionParam[1] + "/" + pCTaskData.conditionParam[0] + "]";
                    }

                }
            }else{
                if( pCTaskData.conditionParam[1] > 0 ){
                    pTaskItemUI.txt_pro.text = "[<font color='#88ff31'>" + pCTaskData.conditionParam[1] + "</font>/" + pCTaskData.conditionParam[0] + "]";
                }else{
                    pTaskItemUI.txt_pro.text = "[" + pCTaskData.conditionParam[1] + "/" + pCTaskData.conditionParam[0] + "]";
                }

            }

            if( pCTaskData.state == CTaskStateType.FINISH ){
                pTaskItemUI.btn.label = "领  奖";
                pTaskItemUI.btn.skin = 'png.common.button.btn_05';
                pTaskItemUI.btn.visible =
                        pTaskItemUI.box_btn.visible =
                                                true;
                pTaskItemUI.frameclip_cangetawrad.play();
                pTaskItemUI.txt_pro.visible = false;
            }else{
                pTaskItemUI.btn.label = "前  往";
                pTaskItemUI.btn.skin = 'png.common.button.btn_01';
                pTaskItemUI.btn.visible = Boolean( pCTaskData.task.link );
                                pTaskItemUI.box_btn.visible =
                                        false;
                pTaskItemUI.frameclip_cangetawrad.stop();
                pTaskItemUI.txt_pro.visible = true;
            }
            pTaskItemUI.btn.clickHandler = new Handler(_taskHandler,[ pCTaskData ,pTaskItemUI]);
            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, pTaskItemUI);
            m_viewExternal.show();
            m_viewExternal.setData(pCTaskData.task.reward);
            m_viewExternal.updateWindow();
        }
    }
    private function _onActiveItemCkHandler( evt :MouseEvent ):void{
        if( _playActiveAwardGetEff )
                return;
        var taskActiveItem : TaskActiveItemUI = evt.currentTarget.parent as TaskActiveItemUI;
        var taskActive : TaskActive = taskActiveItem.clip.dataSource as TaskActive;
        if( !taskActive )
                return;
        if( pCPlayerData.taskData.dailyQuestActiveRewards.indexOf( taskActive.ID ) != -1 ){
            _pCUISystem.showMsgAlert( '已经领取该奖励');
            return;
        }
        if( pCPlayerData.taskData.dailyQuestActiveValue < taskActive.active ){
            _pCUISystem.showMsgAlert( '尚未达到领取条件');
            return;
        }

        pCTaskHandler.onDrawDailyTaskActiveRewardRequest( (taskActiveItem.clip.dataSource as TaskActive).ID,(taskActiveItem.clip.dataSource as TaskActive).reward );

    }
    private function _onPlayerDataHandler(e:CPlayerEvent):void{
        _onActiveHandler();
    }
    private function _onActiveHandler():void{
        var taskActiveTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.TASK_ACTIVE );
        var taskActiveAry : Array = taskActiveTable.toArray();
        var activeMax : int = (taskActiveAry[taskActiveAry.length - 1 ] as TaskActive).active;
        m_taskUI.viewI.active.txt_active.text = String( pCPlayerData.taskData.dailyQuestActiveValue );
        m_taskUI.viewI.active.pro.value = int(( pCPlayerData.taskData.dailyQuestActiveValue/activeMax)*100)/100;
        m_taskUI.viewI.active.box_pro.visible = m_taskUI.viewI.active.pro.value > 0;
        m_taskUI.viewI.active.box_pro.visible ?  m_taskUI.viewI.active.frameclip_pro.play() : m_taskUI.viewI.active.frameclip_pro.stop();
        if( m_taskUI.viewI.active.box_pro.visible )
            m_taskUI.viewI.active.box_pro.x = 170 + m_taskUI.viewI.active.pro.value * m_taskUI.viewI.active.pro.width - m_taskUI.viewI.active.box_pro.width;

        _onTaskActiveItemHandler(null);
    }
    private function _onTaskResetResponeHandler( evt : CTaskEvent ):void{
        _onTaskActiveItemHandler(null);
        m_taskUI.viewI.active.pro.value = 0;
        m_taskUI.viewI.active.box_pro.visible = false;
        m_taskUI.viewI.active.frameclip_pro.stop();
        m_taskUI.viewI.active.txt_active.text = '0';
    }
    private function _onTaskActiveItemHandler( evt : CTaskEvent ):void{
        var taskActive : TaskActive ;
        var taskActiveItem  : TaskActiveItemUI;
        for each(  taskActiveItem  in _activeItemAry ){
            taskActive = taskActiveItem.clip.dataSource as TaskActive;
            if( pCPlayerData.taskData.dailyQuestActiveRewards.indexOf( taskActive.ID ) != -1 ){
                if( evt == null && !_playActiveAwardGetEff ){
                    taskActiveItem.clip.index = 2;//已领取.
                    taskActiveItem.box_eff.visible =
                            taskActiveItem.box_get.visible =
                                            false;
                    taskActiveItem.frameclip_get.stop();
                    taskActiveItem.frameclip_eff.stop();
                }else if( evt && int( evt.data) == taskActive.ID  ) {
                    _playActiveAwardGetEff = true;
                    onPlayActiveAwardGetEff( taskActiveItem );
                }

            }else if( pCPlayerData.taskData.dailyQuestActiveValue >= taskActive.active ){
                taskActiveItem.clip.index = 1;//达到
                taskActiveItem.box_eff.visible = true;
                taskActiveItem.box_get.visible = false;
                taskActiveItem.frameclip_get.stop();
                taskActiveItem.frameclip_eff.play();
            }else{
                taskActiveItem.clip.index = 0;//未达到
                taskActiveItem.box_eff.visible =
                        taskActiveItem.box_get.visible =
                                        false;
                taskActiveItem.frameclip_get.stop();
                taskActiveItem.frameclip_eff.stop();
            }

            var status : int;
            if( pCPlayerData.taskData.dailyQuestActiveRewards.indexOf( taskActive.ID ) != -1 ){
                status = 2;
            }else if( pCPlayerData.taskData.dailyQuestActiveValue >= taskActive.active ){
                status = 1;
            }else{
                status = 3;
            }

            taskActiveItem.dataSource = taskActive.reward;
            taskActiveItem.toolTip = new Handler( _itemSystem.showRewardTips, [taskActiveItem, ["活跃度达" + taskActive.active + "可领", status, 1]]);
            _onTagHandler();
        }

    }
    private function onPlayActiveAwardGetEff( taskActiveItem : TaskActiveItemUI ):void{
        taskActiveItem.clip.index = 1;
        stopeff();
        taskActiveItem.frameclip_get.addEventListener(UIEvent.FRAME_CHANGED,onChanged );
        taskActiveItem.box_get.visible = true;
        taskActiveItem.box_eff.visible = false;
        taskActiveItem.frameclip_eff.stop();
        taskActiveItem.frameclip_get.gotoAndPlay(0);

        function onChanged(evt:UIEvent):void{
            if ( taskActiveItem.frameclip_get.frame >= taskActiveItem.frameclip_get.totalFrame - 1 ) {
                stopeff();
                _playActiveAwardGetEff = false;
                taskActiveItem.clip.index = 2;
            }
        }
        function stopeff():void{
            taskActiveItem.frameclip_get.removeEventListener( UIEvent.FRAME_CHANGED, onChanged );
            taskActiveItem.frameclip_get.stop();
            taskActiveItem.box_get.visible = false;
        }

    }
    private function _taskHandler( ...args):void{
        var pCTaskData : CTaskData = args[0] as CTaskData ;
        var pTaskItemUI: TaskItemUI = args[1] as TaskItemUI ;
        if( pCTaskData ){
            if( pCTaskData.state == CTaskStateType.CAN_DO ){
                var sysTag : String = CTaskJumpConst.getJumpPare(pCTaskData.task.condition);
                if( sysTag.length > 0 ){
                    if( sysTag == CTaskJumpConst.SUB_CLUB_BAG ){
                        _clubSystem.addEventListener( CClubEvent.CLUB_WORLD_VIEW_SHOW ,_onClubViewOnshowHandler );
                        _clubHandler.onOpenClubRequest( false );
                    }else{
                        var tab : int;
                        if( pCTaskData.task.condition == CTaskConditionType.Type_107 || pCTaskData.task.condition == CTaskConditionType.Type_110 ){
                            tab = _instanceSystem.instanceData.getChapterIndexByInstanceID( pCTaskData.task.conditionParm[0] );
                        }
                        _pTaskJumpViewHandler.onPanelJump( sysTag ,tab );
                        m_taskUI.close( Dialog.CLOSE );
                    }

                }
            }else if( pCTaskData.state == CTaskStateType.FINISH ){
                getRewardHandler( pCTaskData ,pTaskItemUI );
            }
        }
    }

    private function _onTagHandler():void{

        m_taskUI.txt_num1.text = String( pCTaskManager.dailyTaskCanAwardNum + pCTaskManager.activeCanAwardNum );
        m_taskUI.box_num1.visible = pCTaskManager.dailyTaskCanAwardNum > 0 || pCTaskManager.activeCanAwardNum > 0 ;

        m_taskUI.txt_num2.text = String( pCTaskManager.longLineTaskCanAwardNum );
        m_taskUI.box_num2.visible = pCTaskManager.longLineTaskCanAwardNum > 0;


        //todo 策划暂时隐藏
//        m_taskUI.box_getAllReward.visible = m_taskUI.btn_getAllReward.visible = false;

//        if( m_taskUI.tab.selectedIndex == 0 )
//            m_taskUI.btn_getAllReward.visible = m_taskUI.box_num1.visible;
//        else if( m_taskUI.tab.selectedIndex == 1 )
//            m_taskUI.btn_getAllReward.visible = m_taskUI.box_num2.visible;
//        m_taskUI.box_getAllReward.visible = m_taskUI.btn_getAllReward.visible;

    }


    private function _getAllRewardHandler():void{
        pCTaskHandler.onDrawAllTaskRewardRequest( m_taskUI.tab.selectedIndex + 2 );
    }
    private function getRewardHandler( pCTaskData : CTaskData , pTaskItemUI: TaskItemUI ):void{
        if( !pCTaskData || !pTaskItemUI || !pCTaskData.task )
                return;
        pCTaskHandler.onDrawTaskRewardRequest( pCTaskData.taskID , pCTaskData.task.type );

        //tofix
        if( pTaskItemUI.reward_list.item_list.dataSource ){
            var len:int = pTaskItemUI.reward_list.item_list.dataSource.length;
            for(var i:int = 0; i < len; i++)
            {
                var item:Component =  pTaskItemUI.reward_list.item_list.getCell(i) as Component;
                CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
            }
        }

    }

    //////////////特殊跳转处理/////////////////
    private function _onClubViewOnshowHandler( evt : CClubEvent = null ):void{
        _clubSystem.removeEventListener( CClubEvent.CLUB_WORLD_VIEW_SHOW ,_onClubViewOnshowHandler );
        _clubSystem.showClubSubView( CClubConst.WELFARE_BAG , CClubConst.CLUB_BAG_SEND );
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
        if( m_taskUI && m_taskUI.parent )
            return;

        if ( m_taskUI ){
            _addEventListeners();
            if( pCTaskManager.getTypeIsDirty( CTaskType.DAILY_TASK ))
                initSubView( CTaskType.DAILY_TASK , m_taskUI.viewI.list );
            if( pCTaskManager.getTypeIsDirty( CTaskType.LONG_LINE_TASK ))
                initSubView( CTaskType.LONG_LINE_TASK , m_taskUI.viewII.list );
            _onActiveHandler();
            _onTagHandler();
            _playActiveAwardGetEff = false;
            m_taskUI.tab.selectedIndex = 0;
            callLater( _onTabSelectedHandler , [0] );
        }
        callLater( _addToDisplayB );
    }
    private function _addToDisplayB() : void {
        setTweenData(KOFSysTags.TASK);
        showDialog(m_taskUI);
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_taskUI ) {
            _removeEventListeners();
        }
    }
    private function _addEventListeners():void {
        _removeEventListeners();
        system.addEventListener( CTaskEvent.TASK_UPDATE, _onTaskListUpdate );
        system.addEventListener( CTaskEvent.DRAW_DAILY_TASK_ACTIVE_REWARD, _onTaskActiveItemHandler );
        system.addEventListener( CTaskEvent.TASK_RESET_RESPONSE, _onTaskResetResponeHandler );

        _playerSystem.addEventListener( CPlayerEvent.PLAYER_TASK ,_onPlayerDataHandler );

        for each( var taskActiveItem : TaskActiveItemUI in _activeItemAry ){
            taskActiveItem.clip.addEventListener( MouseEvent.CLICK, _onActiveItemCkHandler , false, 0, true);
        }
    }
    private function _removeEventListeners():void {
        if(m_taskUI){
            for each( var taskActiveItem : TaskActiveItemUI in _activeItemAry ){
                taskActiveItem.clip.removeEventListener( MouseEvent.CLICK, _onActiveItemCkHandler );
            }
        }
        system.removeEventListener( CTaskEvent.TASK_UPDATE , _onTaskListUpdate );
        system.removeEventListener( CTaskEvent.DRAW_DAILY_TASK_ACTIVE_REWARD, _onTaskActiveItemHandler );
        system.removeEventListener( CTaskEvent.TASK_RESET_RESPONSE, _onTaskResetResponeHandler );

        _playerSystem.removeEventListener( CPlayerEvent.PLAYER_TASK ,_onPlayerDataHandler );
    }
    private function showActiveItemTips( item : TaskActiveItemUI ):void {
        (system.getBean(CTaskActiveItemTipsHandler) as CTaskActiveItemTipsHandler).addTips(item);
    }

    private function initSubView( type : int , list : List ):void{
        var taskAry : Array = pCTaskManager.getTaskDatasByTypeAndSort( type );
        list.dataSource = taskAry;
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function get pCTaskManager():CTaskManager{
        return system.getBean(CTaskManager) as CTaskManager;
    }
    private function get pCTaskHandler():CTaskHandler{
        return system.getBean(CTaskHandler) as CTaskHandler;
    }
    private function get _pTaskJumpViewHandler():CTaskJumpViewHandler{
        return system.getBean(CTaskJumpViewHandler) as CTaskJumpViewHandler;
    }
    private function get pCPlayerData():CPlayerData{
        var playerManager:CPlayerManager = _playerSystem.getBean(CPlayerManager) as CPlayerManager;
        return  playerManager.playerData;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _instanceSystem() : CInstanceSystem {
        return system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
    }
    private function get _itemSystem() : CItemSystem {
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _clubHandler() : CClubHandler {
        return _clubSystem.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _clubSystem() : CClubSystem {
        return system.stage.getSystem( CClubSystem ) as CClubSystem;
    }


}
}
