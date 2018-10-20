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
import kof.util.CAssertUtils;

import morn.core.components.Component;
import morn.core.components.Tab;

public class CTutorActionCarnivalSelectTab extends CTutorActionBase {

    public function CTutorActionCarnivalSelectTab( actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    public override function dispose() : void {
        super.dispose();
    }

    override protected function startByUIComponent( comp : Component ) : void {
        CAssertUtils.assertNotNull( comp );

        if ( comp is Tab ) {
            startByTab( comp as Tab );
            return;
        }
    }


    protected function startByTab( pTab : Tab ) : void {
        if ( !pTab )
            return;

        var idx : int = _targetTab;

        var child : Component = pTab.getChildByName("item" + idx) as Component;
        if ( child ) {
            this.holeTarget = child;
        } else {
            Foundation.Log.logWarningMsg("默认引导点击配置项" + this._info.ID + "作为Tab并不能找到下标为" +
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
        if (isTabOk) {
            _actionValue = true;
        }
    }

    private function get _targetTab() : int {
        if (_info.actionParams && _info.actionParams.length > 1) {
            return _info.actionParams[1];
        }
        return 0;
    }
    private function get _targetDay() : int {
        if (_info.actionParams && _info.actionParams.length > 0) {
            return _info.actionParams[0];
        }
        return 0;
    }
}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
