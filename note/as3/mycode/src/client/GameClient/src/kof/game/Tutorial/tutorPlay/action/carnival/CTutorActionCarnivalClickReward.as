//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/7.
 */
package kof.game.Tutorial.tutorPlay.action.carnival {

import kof.game.Tutorial.tutorPlay.action.*;

import QFLib.Foundation;
import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.openServerActivity.COpenServerActivitySystem;
import kof.ui.master.OpenServerActivity.OpenServerActivityEntryItemUI;
import kof.util.CAssertUtils;

import morn.core.components.Component;
import morn.core.components.List;

public class CTutorActionCarnivalClickReward extends CTutorActionBase {

    public function CTutorActionCarnivalClickReward( actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    public override function dispose() : void {
        super.dispose();

    }

    override protected function startByUIComponent( comp : Component ) : void {
        CAssertUtils.assertNotNull( comp );

        startByList( comp as List );
    }

    protected function startByList( pList : List ) : void {
        if ( !pList )
            return;

        var idx : int = 0; // 参数不够用, 只能选择第一个

        var child : Component = pList.getCell( pList.startIndex + idx ) as Component;
        if ( child ) {

            this.holeTarget = (child as OpenServerActivityEntryItemUI).btn_get;
        } else {
            Foundation.Log.logWarningMsg("默认引导点击配置项" + this._info.ID + "作为List并不能找到下标为" +
                    idx + "的UI对象" );
        }
    }

    override public function update(delta:Number) : void {
        super.update(delta);

        var selectDay:int = _targetDay;
        var isDayOk:Boolean = CTutorActionCarnivalSelectDay.isSelectDay(_system, selectDay);
        if (!isDayOk) {
            // 强制回滚
            holeTarget = null;
            return ;
        }

        var targetTab:int = _targetTab;
        var isTabOk:Boolean = CTutorActionCarnivalSelectDay.isSelectTab(_system, targetTab);
        if (!isTabOk) {
            // 强制回滚
            holeTarget = null;
            return ;
        }

        var targetID:int = _targetID;
        var pSystem:COpenServerActivitySystem = _system.stage.getSystem(COpenServerActivitySystem) as COpenServerActivitySystem;
        var hasRewarded:Boolean = pSystem.isTargetHasGetReward(targetID, 0);
        if (hasRewarded) {
            _actionValue = true;
            return ;
        }

        // 不可领。也直接通过
        var canReward:Boolean = pSystem.isTargetCanGetReward(targetID, 0);
        if (!canReward) {
            _actionValue = true;
            return ;
        }
    }

    private function get _targetDay() : int {
        if (_info.actionParams && _info.actionParams.length > 0) {
            return _info.actionParams[0];
        }
        return 0;
    }
    private function get _targetTab() : int {
        if (_info.actionParams && _info.actionParams.length > 1) {
            return _info.actionParams[1];
        }
        return 0;
    }

    //
    private function get _targetID() : int {
        if (_info.actionParams && _info.actionParams.length > 2) {
            return _info.actionParams[2];
        }
        return 0;
    }
}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
