//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/23.
 */
package kof.game.task {

import QFLib.Utils.HtmlUtil;

import flash.events.TextEvent;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.handler.CPlayHandler;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubSystem;
import kof.game.club.data.CClubConst;
import kof.game.common.CRewardUtil;
import kof.game.core.CECSLoop;
import kof.game.instance.CInstanceSystem;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.task.data.CTaskConditionType;
import kof.game.task.data.CTaskConst;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskJumpConst;
import kof.game.task.data.CTaskJumpTabConst;
import kof.game.task.data.CTaskStateType;
import kof.game.task.data.CTaskType;
import kof.ui.master.task.TaskTrackItwoUI;
import kof.ui.master.task.TaskTrackoneUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.Label;

import morn.core.handlers.Handler;

public class CDailyTaskTrackViewHandler extends CViewHandler {

    private var m_taskTrackUI:TaskTrackItwoUI;

    public function CDailyTaskTrackViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ TaskTrackItwoUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_taskTrackUI ) {
            m_taskTrackUI = new TaskTrackItwoUI();
            m_taskTrackUI.btn_hide.clickHandler = new Handler( hideHandler );
            m_taskTrackUI.btn_show.clickHandler = new Handler( showHandler );
            m_taskTrackUI.btn_task.clickHandler = new Handler( showTaskViewHandler );
            m_taskTrackUI.btn_show.visible = false;
        }
        initialize();
        return Boolean( m_taskTrackUI );
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }
    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addDisplay():void{

        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.TASK ) ) );
        if( iStateValue == CSystemBundleContext.STATE_STOPPED ){
            m_taskTrackUI.remove();
            return;
        }
//        if( m_taskTrackUI.parent )
//                return;
        if ( !_parentCtn ) {
            callLater( _addDisplay );
        } else {
            _addToDisplay();
        }
    }
    private function _addToDisplay():void{
        if(_parentCtn) {
            m_taskTrackUI.list.dataSource = _taskManager.getTaskDatasByTypeAndSortII( CTaskType.DAILY_TASK );
            m_taskTrackUI.list.refresh();
            _parentCtn.addChild( m_taskTrackUI );

        }
    }
    protected function initialize() : void {
        m_taskTrackUI.list.renderHandler = new Handler( renderItem );
        m_taskTrackUI.list.selectHandler = new Handler( selectHandler );
    }
    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is Box ) ) {
            return;
        }
        var box : Box = item as Box;
        if( box.dataSource ){
            var pTaskData : CTaskData = box.dataSource as CTaskData;
            var label : Label = box.getChildByName('txt') as Label;
            label.addEventListener( TextEvent.LINK , _onTextLinkHandler , false, 0, true );

            var strPro : String = '';
            if( pTaskData.state == CTaskStateType.FINISH ){
                strPro = '可领取';
                strPro = HtmlUtil.hrefAndU( strPro , CTaskConst.TASK_GET_AWARD ,"#8bef3a" );
            }else{
                if(  pTaskData.task.link ){
                    //进度
                    if( pTaskData.task.condition == CTaskConditionType.Type_119 ){
                        strPro = '0/1';
                    }else if( pTaskData.task.condition == CTaskConditionType.Type_107
                            || pTaskData.task.condition == CTaskConditionType.Type_110
                            || pTaskData.task.condition == CTaskConditionType.Type_127
                            || pTaskData.task.condition == CTaskConditionType.Type_128
                            || pTaskData.task.condition == CTaskConditionType.Type_129
                            || pTaskData.task.condition == CTaskConditionType.Type_130
                            || pTaskData.task.condition == CTaskConditionType.Type_131
                            || pTaskData.task.condition == CTaskConditionType.Type_132
                            || pTaskData.task.condition == CTaskConditionType.Type_133
                            || pTaskData.task.condition == CTaskConditionType.Type_139
                    ){
                        if( pTaskData.conditionParam[2] > 0 ){
                            strPro =  pTaskData.conditionParam[2] + "/" + pTaskData.conditionParam[1] ;
                        }else{
                            strPro =  pTaskData.conditionParam[2] + "/" + pTaskData.conditionParam[1] ;
                        }

                    }else if( pTaskData.task.condition == CTaskConditionType.Type_109){
                        if( pTaskData.conditionParam[0] >= 10000 ){
                            strPro = pTaskData.conditionParam[1] + "/" + int( pTaskData.conditionParam[0] / 10000 ) + '万';
                        }else{
                            if( pTaskData.conditionParam[1] > 0 ){
                                strPro =  pTaskData.conditionParam[1] + "/" + pTaskData.conditionParam[0] ;
                            }else{
                                strPro =  pTaskData.conditionParam[1] + "/" + pTaskData.conditionParam[0] ;
                            }

                        }
                    }else{
                        if( pTaskData.conditionParam[1] > 0 ){
                            strPro =  pTaskData.conditionParam[1] + "/" + pTaskData.conditionParam[0] ;
                        }else{
                            strPro =  pTaskData.conditionParam[1] + "/" + pTaskData.conditionParam[0] ;
                        }
                    }
                    strPro = HtmlUtil.hrefAndU( strPro , CTaskConst.TASK_TARGET ,"#ff732e" );
                }

            }
            if( strPro.length <= 0  ){
                strPro = "<font color='#ff732e'>未达成</font>";
            }
            label.text = pTaskData.task.name + ":" +  strPro;
        }
    }
    private function _onTextLinkHandler( evt : TextEvent ):void {
        evt.stopImmediatePropagation();
        var box : Box = evt.currentTarget.parent as Box;
        var text : String = evt.text;
        if( text == CTaskConst.TASK_TARGET ){
            taskJumpHandler( box.dataSource as CTaskData );
        }else if( text == CTaskConst.TASK_GET_AWARD ){
            getRewardHandler( box.dataSource as CTaskData );
        }

    }
    private function selectHandler( index : int ):void {
        var box : Box = m_taskTrackUI.list.getCell( index ) as Box;
        if ( !box )
            return;
        var pTaskData : CTaskData = box.dataSource as CTaskData;
        if ( pTaskData ) {

        }
    }

    private function taskJumpHandler( taskData : CTaskData):void{
        if( taskData.state == CTaskStateType.CAN_DO ) {
            var sysTag : String = CTaskJumpConst.getJumpPare( taskData.task.condition );
            if ( sysTag.length > 0 ) {
                if ( sysTag == CTaskJumpConst.SUB_CLUB_BAG ) {
                    _clubSystem.addEventListener( CClubEvent.CLUB_WORLD_VIEW_SHOW, _onClubViewOnshowHandler );
                    _clubHandler.onOpenClubRequest( false );
                } else {
                    var tab : int;
                    if ( taskData.task.condition == CTaskConditionType.Type_107 || taskData.task.condition == CTaskConditionType.Type_110 ) {
                        tab = _instanceSystem.instanceData.getChapterIndexByInstanceID( taskData.task.conditionParm[ 0 ] );
                    }
                    _pTaskJumpViewHandler.onPanelJump( sysTag, tab );
                }

            }
        }
    }
    //////////////特殊跳转处理/////////////////
    private function _onClubViewOnshowHandler( evt : CClubEvent = null ):void{
        _clubSystem.removeEventListener( CClubEvent.CLUB_WORLD_VIEW_SHOW ,_onClubViewOnshowHandler );
        _clubSystem.showClubSubView( CClubConst.WELFARE_BAG , CClubConst.CLUB_BAG_SEND );
    }

    private function getRewardHandler( pCTaskData : CTaskData ):void{
        if( !pCTaskData ||  !pCTaskData.task )
            return;
        pCTaskHandler.onDrawTaskRewardRequest( pCTaskData.taskID , pCTaskData.task.type );
        //tofix

        var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, pCTaskData.task.reward);
        if(rewardListData)
        {
            (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
        }

    }
    private function showTaskViewHandler():void{
        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.TASK ));
        bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
    }
    private function hideHandler():void{
        m_taskTrackUI.list.visible = false;
        m_taskTrackUI.btn_show.visible = true;
        m_taskTrackUI.btn_hide.visible = false;
        m_taskTrackUI.img_bg.visible = false;
        m_taskTrackUI.img_corner.visible = false;
    }
    private function showHandler():void{
        m_taskTrackUI.list.visible = true;
        m_taskTrackUI.btn_show.visible = false;
        m_taskTrackUI.btn_hide.visible = true;
        m_taskTrackUI.img_bg.visible = true;
        m_taskTrackUI.img_corner.visible = true;
    }
    private function get _parentCtn():Box{
        var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        if ( !pLobbyViewHandler.pMainUI )
            return null;
        var right:Box = pLobbyViewHandler.pMainUI.getChildByName("right") as Box;
        var notice:Box = right.getChildByName("dailytask") as Box;
        return notice;
    }

    private function get _taskManager():CTaskManager{
        return _pTaskSystem.getBean( CTaskManager ) as CTaskManager;
    }
    private function get _pTaskSystem():CTaskSystem{
        return system.stage.getSystem( CTaskSystem ) as CTaskSystem;
    }
    private function get _pTaskJumpViewHandler() : CTaskJumpViewHandler {
        return _pCTaskSystem.getBean( CTaskJumpViewHandler ) as CTaskJumpViewHandler;
    }
    private function get pCTaskHandler(): CTaskHandler{
        return _pCTaskSystem.getBean( CTaskHandler ) as CTaskHandler ;
    }
    private function get _pCTaskSystem(): CTaskSystem{
        return system.stage.getSystem( CTaskSystem ) as CTaskSystem ;
    }
    private function get _instanceSystem() : CInstanceSystem {
        return system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
    }
    private function get _clubHandler() : CClubHandler {
        return _clubSystem.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _clubSystem() : CClubSystem {
        return system.stage.getSystem( CClubSystem ) as CClubSystem;
    }
    private function get _playHandler() : CPlayHandler {
        return (system.stage.getSystem(CECSLoop).getBean(CPlayHandler)) as CPlayHandler;
    }
}
}
