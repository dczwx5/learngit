//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by Ender 2018-6-30.
 */
package kof.game.activityTreasure.view {

import QFLib.Utils.HtmlUtil;

import kof.framework.CViewHandler;
import kof.game.activityTreasure.CActivityTreasureManager;
import kof.game.activityTreasure.data.CActivityTreasureTaskData;
import kof.game.switching.CSwitchingJump;
import kof.table.ActivityTreasureTask;
import kof.ui.master.ActivityTreasure.ActivityTreasureRewardPreviewUI;
import kof.ui.master.ActivityTreasure.ActivityTreasureTaskListItemUI;
import kof.ui.master.ActivityTreasure.ActivityTreasureTaskUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * @author Ender
 * @date 2018-6-30
 */
public class CActivityTreasureTaskViewHandler extends CViewHandler {

    private var m_pViewUI : ActivityTreasureTaskUI;
    private var m_bViewInitialized : Boolean;

    public function CActivityTreasureTaskViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ ActivityTreasureRewardPreviewUI ];
    }


    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() ) {
            return false;
        }

        if ( !m_bViewInitialized ) {
            if ( !m_pViewUI ) {
                m_pViewUI = new ActivityTreasureTaskUI();
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.taskList.renderHandler = new Handler( taskListRander );

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            callLater( _addToDisplay );
        }
        else {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        uiCanvas.addPopupDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( m_pViewUI && m_pViewUI.parent ) {
                    m_pViewUI.close( Dialog.CLOSE );
                }
                break;
        }
        _removeListeners();
    }

    private function taskListRander( item : ActivityTreasureTaskListItemUI, index : int ) : void {
        if ( item == null || item.dataSource == null )return;

        var data : CActivityTreasureTaskData = item.dataSource as CActivityTreasureTaskData;
        var cfgInfo : ActivityTreasureTask = activityTreasureManager.getActivityTreasureTaskCfgInfoById( data.m_id );
        //图标
        item.taskIcon.url = "icon/task/" + cfgInfo.image + ".png";
        //标题&进度
        item.titleAndDescLabel.text = cfgInfo.name + " " + HtmlUtil.getHtmlText( "[" + data.m_currVal + "/" + cfgInfo.targetVal + "]", "#cdfeff", 16, "微软雅黑" );
        //描述
        item.describeLabel.text = cfgInfo.desc;
        //奖励数量
        item.rewardNum.text = "X" + cfgInfo.award;
        //是否已完成
        item.finishTag.visible = data.m_state == 2;
        item.darkImg.visible = data.m_state == 2;

        item.goto_btn.visible = !(2 == data.m_state);
        if (cfgInfo.linkTarget && cfgInfo.linkTarget.length > 0) {
            item.goto_btn.clickHandler = new Handler(function () : void {
                CSwitchingJump.jump(system, cfgInfo.linkTarget);
                _onClose("");
            });
        } else {
            item.goto_btn.visible = false;
        }

    }

    private function _initView() : void {

        var tempArr : Array = activityTreasureManager.taskDataArr;
        //排序算法
        tempArr.sort( sortActiveTaskDataFunc );
        m_pViewUI.taskList.dataSource = tempArr;

    }

    private function sortActiveTaskDataFunc( data1 : CActivityTreasureTaskData, data2 : CActivityTreasureTaskData ) : int {
        var t1 : int;
        var t2 : int;
        //第一轮，依据领取状态判定，可领取最前，未完成其次，已领取最末
        if ( data1.m_state == 0 ) {
            t1 = 1;
        }
        else if ( data1.m_state == 1 ) {
            t1 = 0;
        }
        else if ( data1.m_state == 2 ) {
            t1 = 2;
        }
        if ( data2.m_state == 0 ) {
            t2 = 1;
        }
        else if ( data2.m_state == 1 ) {
            t2 = 0;
        }
        else if ( data2.m_state == 2 ) {
            t2 = 2;
        }

        //第一轮排序平序状态下，做第二轮，依据id大小判定
        if ( t1 == t2 ) {
            t1 = data1.m_id;
            t2 = data2.m_id;
        }

        return t1 - t2;
    }

    private function _addListeners() : void {
    }

    private function _removeListeners() : void {
    }

    override protected function updateDisplay() : void {
    }

    override public function dispose() : void {
    }

    private function get activityTreasureManager() : CActivityTreasureManager {
        return (system.getBean( CActivityTreasureManager ) as CActivityTreasureManager);
    }
}
}
