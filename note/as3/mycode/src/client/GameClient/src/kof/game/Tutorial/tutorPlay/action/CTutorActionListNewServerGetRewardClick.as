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
import kof.game.newServerActivity.view.CNewServerActivityViewHandler;
import kof.ui.master.NewServerActivity.NewServerActivityItemListUI;
import kof.util.CAssertUtils;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.List;


/**
 * 新手引导：七天新服活动, 领奖
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorActionListNewServerGetRewardClick extends CTutorActionBase {

    public function CTutorActionListNewServerGetRewardClick(pInfo : CTutorActionInfo, pSystem : CTutorSystem ) {
        super( pInfo, pSystem );
    }

    override public function dispose() : void {
        super.dispose();

        if (_pButton) {
            _pButton.removeEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler );
        }
        if (_pList) {
            _pList = null;
        }
    }

    override protected virtual function startByUIComponent( comp : Component ) : void {
        super.startByUIComponent( comp );

        var pList : List = comp as List;
        if ( !pList ) {
            Foundation.Log.logErrorMsg("七天新服活动领奖引导动作的目标UI类型不是List");
        }

        CAssertUtils.assertNotNull( pList );

        var pNerServerActivitySystem:CNewServerActivitySystem = (_system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem);
        if (!pNerServerActivitySystem) {
            _actionValue = true;
            return ;
        }

        _pList = pList;
        _isHasDatas = false;
//        var activityId : int = (pNerServerActivitySystem.getBean( CNewServerActivityManager ) as CNewServerActivityManager).curActivityID;
//        if (activityId != 1) {
//            _actionValue = true;
//            return ;
//        }


    }

    private function _target_mouseClickEventHandler( event : MouseEvent ) : void {
        (event.currentTarget as Component).removeEventListener( event.type, _target_mouseClickEventHandler );
        this._actionValue = true;
    }

    override public function update(delta:Number) : void {
        super.update(delta);
        if (_isHasDatas) return ;
        _isHasDatas = _pList.dataSource && _pList.dataSource.length > 0;
        if (!_isHasDatas) return ;
        var pNerServerActivitySystem:CNewServerActivitySystem = (_system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem);
        if (!pNerServerActivitySystem) {
            _isHasDatas = false;
            return ;
        }

        var viewHandler:CNewServerActivityViewHandler = (pNerServerActivitySystem.getBean(CNewServerActivityViewHandler) as CNewServerActivityViewHandler);
        var isTab1:Boolean = viewHandler.curRenderAcitivityID == 1 && pNerServerActivitySystem.isSelectFirstActivity();
        if (!isTab1) {
            _isHasDatas = false;
            return ;
        }

        // 检测数据, 数据正确则, 等待item
        var isDataValid:Boolean = false;
        var pDataSource:Array = _pList.dataSource as Array;
        {
            var sucessIndex:int = 0;
            for each (var pConfigData:CActivityRewardConfig in pDataSource) {
                if (pConfigData.rewardType != CActivityRewardConfig.TYPE_RANK && (pConfigData.goal == 5 || pConfigData.goal == 10)) {
                    sucessIndex++; // 等级item index
                    if (pConfigData.canGet && pConfigData.hasGet == false && sucessIndex <= 2) { // 第二个之后的要翻页, 所以当作是不能领的
                        isDataValid = true;
                    }
                }
            }
        }

        // 数据不正确, 没有符合的数据, 直接完成步骤
        if (!isDataValid) {
            _actionValue = true;
            return ;
        }

        var cellList:Vector.<Box> = _pList.cells;
        var pCellItem : NewServerActivityItemListUI = null;
        var itemIndex:int = 0;
        var isDataOk:Boolean = true;
        if (cellList) {
            for (var i:int = 0; i < cellList.length; i++) {
                var cell:Box = cellList[i];
                isDataOk = isDataOk && cell.dataSource != null;
                if (cell && cell.dataSource) {
                    var rewardData:CActivityRewardConfig = cell.dataSource as CActivityRewardConfig;
                    if (rewardData.rewardType != CActivityRewardConfig.TYPE_RANK && (rewardData.goal == 5 || rewardData.goal == 10)) {
                        itemIndex++; // 等级item index
                        if (rewardData.canGet && rewardData.hasGet == false && itemIndex <= 2) { // 第二个之后的要翻页, 所以当作是不能领的
                            pCellItem = cell as NewServerActivityItemListUI;
                        }
                    }
                }
            }
        }

        // list.dataSource有数据了。但是cellItem可能还没数据
        if (!isDataOk && !pCellItem) {
            _isHasDatas = false;
            return ;
        }

        if (!pCellItem) {
            // 因为前面已经做了数据检测, 如果item找不到说明数据和item不一致, 等待一致
            _isHasDatas = false;
        } else {
            var pButton : Component = pCellItem.btn_getGift;
            if ( pButton ) {
                _pButton = pButton;
                pButton.addEventListener( MouseEvent.CLICK, _target_mouseClickEventHandler, false, CEventPriority.BINDING, true );
            }
            this.holeTarget = pButton;
        }
    }

    private var _pButton:Component;

    private var _pList:List;
    private var _isHasDatas:Boolean;

}
}
