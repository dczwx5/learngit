//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/7.
 */
package kof.game.Tutorial.tutorPlay.action.carnival {

import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.tutorPlay.action.CTutorActionBase;
import kof.game.openServerActivity.COpenServerActivitySystem;
import kof.game.openServerActivity.COpenServerActivityViewHandler;
import kof.util.CAssertUtils;

import morn.core.components.Component;

public class CTutorActionCarnivalSelectDay extends CTutorActionBase {

    public function CTutorActionCarnivalSelectDay( actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    public override function dispose() : void {
        super.dispose();

    }

    override protected function startByUIComponent( comp : Component ) : void {
        CAssertUtils.assertNotNull( comp );
        this.holeTarget = comp;
    }

    override public function update(delta:Number) : void {
        super.update(delta);

        var selectDay:int = _targetDay;

        var isDayOk:Boolean = isSelectDay(_system, selectDay);
        if (isDayOk) {
            _actionValue = true;
        }
    }

    public static function isSelectDay(system:CAppSystem, selectDay:int) : Boolean {
        var pSystem:COpenServerActivitySystem = system.stage.getSystem(COpenServerActivitySystem) as COpenServerActivitySystem;
        if (pSystem) {
            var view:COpenServerActivityViewHandler = pSystem.getBean(COpenServerActivityViewHandler) as COpenServerActivityViewHandler;
            if (view) {
                if (view.selectDay == selectDay) {
                    return true;
                }
            }
        }
        return false;
    }
    public static function isSelectTab(system:CAppSystem, tabIndex:int) : Boolean {
        var pSystem:COpenServerActivitySystem = system.stage.getSystem(COpenServerActivitySystem) as COpenServerActivitySystem;
        if (pSystem) {
            var view:COpenServerActivityViewHandler = pSystem.getBean(COpenServerActivityViewHandler) as COpenServerActivityViewHandler;
            if (view) {
                if (view.selectTab == tabIndex) {
                    return true;
                }
            }
        }
        return false;
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
