//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/7.
 */
package kof.game.task.track {

import QFLib.Utils.HtmlUtil;

import flash.events.TextEvent;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.handler.CPlayHandler;
import kof.game.common.view.CViewExternalUtil;
import kof.game.core.CECSLoop;
import kof.game.instance.CInstanceSystem;
import kof.game.item.view.part.CRewardItemMulityListView;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.task.CTaskJumpViewHandler;
import kof.game.task.CTaskManager;
import kof.game.task.CTaskRewardTipsView;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskConditionType;
import kof.game.task.data.CTaskConst;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskJumpConst;
import kof.game.task.data.CTaskJumpTabConst;
import kof.ui.IUICanvas;
import kof.ui.master.task.TaskTrackoneUI;

import morn.core.components.Box;
import morn.core.handlers.Handler;

public class CTaskTrackIViewHandler extends CViewHandler {

    private var m_taskTrackUI:TaskTrackoneUI;

    private var m_viewExternal:CViewExternalUtil;

    private var taskData : CTaskData;

    private var _pDoneShowTaskDataAry : Array;

    public function CTaskTrackIViewHandler(  ) {
        super( false );
    }

    private function initUI() : void {
        m_taskTrackUI.btn_hide.clickHandler = new Handler( hideHandler );
        m_taskTrackUI.btn_show.clickHandler = new Handler( showHandler );

        m_taskTrackUI.btn.clickHandler = new Handler( taskJumpHandler );
//        m_viewExternal = new CViewExternalUtil(CRewardItemMulityListView, this, m_taskTrackUI);
        m_taskTrackUI.txt_target.addEventListener( TextEvent.LINK , _onTextLinkHandler );
        m_taskTrackUI.img_reward.toolTip = new Handler( showTips );
    }

    public function show( m_taskTrackUI:TaskTrackoneUI ,pTaskData : CTaskData ):void{
        this.m_taskTrackUI = m_taskTrackUI;
        initUI();
        if(!pTaskData || !pTaskData.plotTask){
            return;
        }
        if( getTaskDataFromDoneShowAry( pTaskData.plotTask.nextTaskID ) ){//为了修改一个BUG，下一个任务提前显示了
            return;
        }
        if( !_pDoneShowTaskDataAry )
            _pDoneShowTaskDataAry = [];
        _pDoneShowTaskDataAry.push( pTaskData );
        taskData = pTaskData;
        m_taskTrackUI.txt_name.text = taskData.plotTask.trackName;
//        var chapterAry : Array = pCTaskManager.getChapterTaskArray( taskData.plotTask.chapterID );
//        m_taskTrackUI.txt_pro.text = (taskData.plotTask.taskSchedule - 1) + "/" + chapterAry.length;
//        var proValue:Number = int(( (taskData.plotTask.taskSchedule - 1)/chapterAry.length)*100)/100;
//        m_taskTrackUI.pro.value = proValue;
        m_taskTrackUI.txt_desc.text = taskData.plotTask.desc;

        if( taskData.plotTask.taskTarget.length > 0 ){
            if( taskData.plotTask.targerDesc.indexOf( taskData.plotTask.taskTarget ) != - 1 ) {
                var taskTargetStr : String = HtmlUtil.hrefAndU( taskData.plotTask.taskTarget, CTaskConst.TASK_TARGET, "#8bef3a" );
                var targerDesc : String = taskData.plotTask.targerDesc;
                m_taskTrackUI.txt_target.text = targerDesc.replace( taskData.plotTask.taskTarget, taskTargetStr );
            }else{
                m_taskTrackUI.txt_target.text = taskData.plotTask.targerDesc;
            }
        }else {
            m_taskTrackUI.txt_target.text = taskData.plotTask.targerDesc;
        }

        m_taskTrackUI.box_reward.visible = taskData.plotTask.reward > 0;


//        m_taskTrackUI.box_target.y =  m_taskTrackUI.box_desc.y + m_taskTrackUI.box_desc.height ;
//        if( m_taskTrackUI.txt_target.height > 18 )
//            m_taskTrackUI.btn.y = m_taskTrackUI.box_targetT.y + m_taskTrackUI.box_targetT.height ;
//        m_taskTrackUI.img_lineTarget.y = m_taskTrackUI.btn.y + m_taskTrackUI.btn.height + 5 ;
//        m_taskTrackUI.box_reward.y =  m_taskTrackUI.box_target.y + m_taskTrackUI.box_target.height ;

//        if( taskData.plotTask.reward ){
//            m_viewExternal.show();
//            m_viewExternal.setData(taskData.plotTask.reward);
//            m_viewExternal.updateWindow();
//        }

//        m_taskTrackUI.panel.refresh();
        addDisplay();
    }

    protected function addDisplay() : void {
        if ( !_parentCtn ) {
            callLater( addDisplay );
        } else {
            _addDisplay();
        }
    }

    private function _addDisplay():void{
        resetCtn();
        if(_parentCtn) {
            _parentCtn.addChild( m_taskTrackUI );
        }
    }
    private function taskJumpHandler():void{
        if( taskData.plotTask.condition == CTaskConditionType.Type_101 ){
            _pTaskJumpViewHandler.onNpcJump( taskData.plotTask.npcID );
        }else if( taskData.plotTask.condition == CTaskConditionType.Type_106 ){//策划要求，先看每日任务系统是否开启，开启就进入每日任务，没有开启就进入剧情副本
            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.TASK ) ) );
            var bundle : ISystemBundle;
            if( iStateValue == CSystemBundleContext.STATE_STARTED ){
                bundle =  bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.TASK ));
            }else {
                bundle =  bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.INSTANCE ));
            }
            bundleCtx.setUserData( bundle, "activated", true );
        }else if( taskData.plotTask.condition == CTaskConditionType.Type_146 ){
            _playerSystem.dispatchEvent( new CPlayerEvent( CPlayerEvent.OPEN_AND_SELHERO , taskData.plotTask.parm[0] ) );
        }else{
            var sysTag : String =  CTaskJumpConst.getJumpPare( taskData.plotTask.condition );
            var tab : int;
            if( taskData.plotTask.condition == CTaskConditionType.Type_107 ){//精英副本
                tab = _instanceSystem.instanceData.getChapterIndexByInstanceID( taskData.plotTask.parm[0] );
            }else if( taskData.plotTask.condition == CTaskConditionType.Type_110 ){//剧情副本
                tab = _instanceSystem.instanceData.getChapterIndexByInstanceID( taskData.plotTask.parm[0] );
            } else{
                tab = CTaskJumpTabConst.getJumpTab( taskData.plotTask.condition );
            }

            _pTaskJumpViewHandler.onPanelJump( sysTag , tab );
        }
    }
    private function _onTextLinkHandler( evt : TextEvent ):void {
        var text : String = evt.text;
        if( text == CTaskConst.TASK_TARGET ){
            taskJumpHandler();
        }
    }
    private function showTips():void {
        _pTaskRewardTipsView.addTips( taskData );
    }

    private function hideHandler():void{
        m_taskTrackUI.box_content.visible = false;
        m_taskTrackUI.btn_show.visible = true;
        m_taskTrackUI.btn_hide.visible = false;
    }
    private function showHandler():void{
        m_taskTrackUI.box_content.visible = true;
        m_taskTrackUI.btn_show.visible = false;
        m_taskTrackUI.btn_hide.visible = true;
    }
    private function resetCtn():void{
        if( !_parentCtn )
                return;
        while( _parentCtn.numChildren > 0 ){
            _parentCtn.removeChildAt(0);
        }
    }

    private function getTaskDataFromDoneShowAry( taskID : int  ) : CTaskData {
        var pTaskData : CTaskData;
        for each ( pTaskData in _pDoneShowTaskDataAry ){
            if( pTaskData.taskID == taskID ){
                return pTaskData;
                break;
            }
        }
        return null;
    }

    private function get _parentCtn():Box{
        var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        if ( !pLobbyViewHandler.pMainUI )
            return null;
        var right:Box = pLobbyViewHandler.pMainUI.getChildByName("right") as Box;
        var notice:Box = right.getChildByName("task") as Box;
        return notice;
    }
    private function get iUICanvas():IUICanvas{
        return system.stage.getSystem(IUICanvas) as IUICanvas;
    }

    private function get pCTaskManager() : CTaskManager {
        return _pCTaskSystem.getBean( CTaskManager ) as CTaskManager;
    }
    private function get _pTaskJumpViewHandler() : CTaskJumpViewHandler {
        return _pCTaskSystem.getBean( CTaskJumpViewHandler ) as CTaskJumpViewHandler;
    }

    private function get _pTaskRewardTipsView(): CTaskRewardTipsView{
        return system.getBean( CTaskRewardTipsView ) as CTaskRewardTipsView ;
    }
    private function get _pCTaskSystem(): CTaskSystem{
        return system.stage.getSystem( CTaskSystem ) as CTaskSystem ;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _instanceSystem() : CInstanceSystem {
        return system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
    }
    private function get _playHandler() : CPlayHandler {
        return (system.stage.getSystem(CECSLoop).getBean(CPlayHandler)) as CPlayHandler;
    }
}
}
