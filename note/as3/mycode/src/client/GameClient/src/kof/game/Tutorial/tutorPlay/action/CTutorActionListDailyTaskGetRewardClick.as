//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.framework.events.CEventPriority;

import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.newServerActivity.CNewServerActivityManager;
import kof.game.newServerActivity.CNewServerActivitySystem;
import kof.game.newServerActivity.CNewServerActivitySystem;
import kof.game.newServerActivity.data.CActivityRewardConfig;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskStateType;
import kof.ui.master.NewServerActivity.NewServerActivityItemListUI;
import kof.ui.master.task.TaskItemUI;
import kof.util.CAssertUtils;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.List;


/**
 * 新手引导：每日任务领取奖励
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionListDailyTaskGetRewardClick extends CTutorActionBase {

    public function CTutorActionListDailyTaskGetRewardClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        super.dispose();

        if (_pButton) {
            _pButton.removeEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler );
            _pButton = null;
        }
        if (_pList) {
            _pList.removeEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler );
            _pList = null;
        }
    }

    override protected virtual function startByUIComponent( comp : Component ) : void {
        super.startByUIComponent( comp );

        var pList : List = comp as List;
        if ( !pList ) {
            Foundation.Log.logErrorMsg("每日任务领奖引导动作的目标UI类型不是List");
        }

        CAssertUtils.assertNotNull( pList );

        _pList = pList;
        var pCellItem : TaskItemUI = pList.getCell(0) as TaskItemUI;

        if (!pCellItem) {
            _actionValue = true;
        } else {
            _pList.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
            var pButton : Component = pCellItem.btn;
            if ( pButton ) {
                _pButton = pButton;
                pButton.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
            }
            this.holeTarget = pButton;
        }
    }

    private function _target_mouseClickEventHandler( event : MouseEvent ) : void {
        _pButton.removeEventListener( event.type, _target_mouseClickEventHandler );
        _pList.removeEventListener( event.type, _target_mouseClickEventHandler );

        this._actionValue = true;
    }

    private var _pButton:Component;
    private var _pList:List;

}
}
