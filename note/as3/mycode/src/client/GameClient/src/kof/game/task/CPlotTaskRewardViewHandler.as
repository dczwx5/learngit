//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/9.
 */
package kof.game.task {

import flash.events.KeyboardEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.common.CFlyItemUtil;
import kof.game.common.view.CViewExternalUtil;
import kof.game.instance.CInstanceSystem;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.game.task.data.CTaskData;
import kof.ui.IUICanvas;
import kof.ui.master.task.TaskRewardUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CPlotTaskRewardViewHandler extends CViewHandler {

    private var m_taskRewardUI:TaskRewardUI;
    private var m_viewExternal:CViewExternalUtil;
    private var _num:int;
    private var _pTaskData:CTaskData;

    private var _pTaskDataAry : Array;

    private var _pDoneShowTaskDataAry : Array;


    public function CPlotTaskRewardViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ TaskRewardUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "frameclip_taskdone.swf"
        ];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if (!m_taskRewardUI) {
            m_taskRewardUI = new TaskRewardUI();
            m_taskRewardUI.closeHandler = new Handler( _onClose );
            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, m_taskRewardUI);

            m_taskRewardUI.img_role.url = "icon/role/big/role_204.png";

            m_taskRewardUI.eff_taskDone.mouseEnabled =
                    m_taskRewardUI.eff_taskDone.mouseChildren = false;
        }

        return Boolean( m_taskRewardUI );
    }
    public function addDisplay( pTaskData:CTaskData ) : void {

        if( !_pTaskDataAry )
            _pTaskDataAry = [];
        _pTaskDataAry.push( pTaskData );

        _onAddDisplay();
    }
    private function _onAddDisplay():void{
        if( CPlayerCardUtil.IsInPumping ){
            var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
            if(pReciprocalSystem){
                pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_2 );
            }
        }

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
    public function _addToDisplay( ):void {
        _pTaskData = null;
        _pTaskData = _pTaskDataAry.shift();
        if( !_pTaskData || !_pTaskData.plotTask ){
            return;
        }

        if( _pTaskData.plotTask.reward <= 0 ){
            m_taskRewardUI.close( Dialog.CLOSE );
            return;
        }

        if( getTaskDataFromDoneShowAry( _pTaskData.taskID ) ){//为了修改重复弹同一奖励的BUG
            if( !m_taskRewardUI.parent )
                m_taskRewardUI.close( Dialog.CLOSE );
            return;
        }
        if( !_pDoneShowTaskDataAry )
            _pDoneShowTaskDataAry = [];
        _pDoneShowTaskDataAry.push( _pTaskData.taskID );


//        m_taskRewardUI.txt_name.text = _pTaskData.plotTask.trackName;
        m_taskRewardUI.txt_desc.text = _pTaskData.plotTask.targerDesc;
        m_viewExternal.show();
        ( m_viewExternal.view as CRewardItemListView ).forceAlign = 1;
        ( m_viewExternal.view as CRewardItemListView ).updateLayout();
        m_viewExternal.setData(_pTaskData.plotTask.reward);
        m_viewExternal.updateWindow();
        _num = 15;
        schedule(1,updateView);
        uiCanvas.addPopupDialog(m_taskRewardUI);

        m_taskRewardUI.eff_taskDone.visible = false;
        if(  _pTaskData.plotTask.taskEffect ){
            m_taskRewardUI.eff_taskDone.removeEventListener( UIEvent.FRAME_CHANGED  , onChanged );
            m_taskRewardUI.eff_taskDone.addEventListener( UIEvent.FRAME_CHANGED  , onChanged );
            m_taskRewardUI.eff_taskDone.gotoAndPlay(0);
            m_taskRewardUI.eff_taskDone.visible = true;
        }

        addEventListenerHandler();

    }

    private function onChanged(evt:UIEvent):void{
        if( m_taskRewardUI.eff_taskDone.frame >=  m_taskRewardUI.eff_taskDone.totalFrame - 1) {
            m_taskRewardUI.eff_taskDone.removeEventListener( UIEvent.FRAME_CHANGED  , onChanged );
            m_taskRewardUI.eff_taskDone.stop();
//            m_taskRewardUI.eff_taskDone.visible = false;
        }
    }

    public function removeDisplay() : void {
        if ( m_taskRewardUI ) {
            m_taskRewardUI.close( Dialog.CLOSE );
        }
    }
    private function updateView( delta : Number ):void {
        if( _num <= 0 ){
            _num = 0;
            unschedule(updateView);
            m_taskRewardUI.close( Dialog.OK );
//            m_taskRewardUI.txt_time.text = "";
        }
//        m_taskRewardUI.txt_time.text = _num + "秒后自动领取";
        m_taskRewardUI.btn_ok.label = '领取奖励(' + _num + 's)';
        _num --;
//        m_taskRewardUI.txt_time.centerX = 0;
    }
    private function rewardHandler():void{
        //不需要手动领取
//        pCTaskHandler.onDrawTaskRewardRequest( pTaskData.taskID , pTaskData.plotTask.type );

    }
    private function get pCTaskHandler():CTaskHandler{
        return system.getBean(CTaskHandler) as CTaskHandler;
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            case Dialog.CLOSE:
                break;
            case Dialog.OK:
                rewardHandler();
                break;
        }

        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_2 );
        }

        unschedule(updateView);
        if( m_taskRewardUI ){
            m_taskRewardUI.eff_taskDone.removeEventListener( UIEvent.FRAME_CHANGED  , onChanged );
            m_taskRewardUI.eff_taskDone.stop();
        }
        if( _pTaskData.plotTask.reward ){
            var len:int = m_taskRewardUI.reward_list.item_list.dataSource.length;
            for(var i:int = 0; i < len; i++)
            {
                var item:Component =  m_taskRewardUI.reward_list.item_list.getCell(i) as Component;
                CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
            }
        }

        ( system as CMainTaskSystem ).updateViewII( _pTaskData );

        if( _instanceSystem.isMainCity ){//如果在主城，继续弹下一个任务奖励
            callLater( _addToDisplay );
        }

        App.tip.closeAll();
        removeEventListenerHandler();
    }

    private function getTaskDataFromDoneShowAry( taskID : int  ) : Boolean {
        var doneShowTaskID : int;
        for each ( doneShowTaskID in _pDoneShowTaskDataAry ){
            if( doneShowTaskID == taskID ){
                return true;
                break;
            }
        }
        return false;
    }
    private function _onKeyUp( evt : KeyboardEvent ):void{
        if( evt.charCode == 32 ){
            m_taskRewardUI.close( Dialog.OK );
            evt.stopImmediatePropagation();
        }
    }
    private function addEventListenerHandler():void{
        removeEventListenerHandler();
        system.stage.flashStage.addEventListener( KeyboardEvent.KEY_UP, _onKeyUp );
    }
    private function removeEventListenerHandler():void{
        system.stage.flashStage.removeEventListener( KeyboardEvent.KEY_UP, _onKeyUp );
    }
    private function get _pCTaskSystem():CTaskSystem{
        return system.stage.getSystem( CTaskSystem ) as CTaskSystem
    }
    private function get _pCTaskManager():CTaskManager{
        return _pCTaskSystem.getBean( CTaskManager ) as CTaskManager;
    }
    private function get _instanceSystem():CInstanceSystem{
        return system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
    }
    private function get iUICanvas():IUICanvas{
        return system.stage.getSystem(IUICanvas) as IUICanvas;
    }
}
}
