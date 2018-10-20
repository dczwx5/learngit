//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/10.
 */
package kof.game.Tutorial.tutorPlay.action.teachingInstance {


import QFLib.Foundation;
import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.tutorPlay.action.CTutorActionBase;
import kof.game.teaching.CTeachingInstanceSystem;
import kof.game.teaching.CTeachingInstanceViewHandler;
import kof.util.CAssertUtils;

import morn.core.components.Component;
import morn.core.components.Tab;

public class CTutorActionTeachingSelectTab extends CTutorActionBase {

    public function CTutorActionTeachingSelectTab( actionInfo : CTutorActionInfo, system : CAppSystem ) {
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

        var targetTab:int = _targetTab;
        var isTabOk:Boolean = isSelectTab(_system, targetTab);
        if (isTabOk) {
            _actionValue = true;
        }
    }

    private function get _targetTab() : int {
        if (_info.actionParams && _info.actionParams.length > 0) {
            return _info.actionParams[0];
        }
        return 0;
    }

    public static function isSelectTab(system:CAppSystem, tabIndex:int) : Boolean {
        var pSystem:CTeachingInstanceSystem = system.stage.getSystem(CTeachingInstanceSystem) as CTeachingInstanceSystem;
        if (pSystem) {
            var view:CTeachingInstanceViewHandler = pSystem.getBean(CTeachingInstanceViewHandler) as CTeachingInstanceViewHandler;
            if (view) {
                if (view.selectTab == tabIndex) {
                    return true;
                }
            }
        }
        return false;
    }

}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
