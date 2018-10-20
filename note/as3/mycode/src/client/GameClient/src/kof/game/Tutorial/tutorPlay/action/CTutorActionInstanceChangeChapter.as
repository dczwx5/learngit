//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;

public class CTutorActionInstanceChangeChapter extends CTutorActionBase {

    public function CTutorActionInstanceChangeChapter(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        super.dispose();

    }

    override public function start() : void {
        super.start();
        var type:String = _info.actionParams[0] as String;
        if (type == "1") {
            _isElite = true;
        }
    }

    override public function update(delta:Number) : void {
        super.update(delta);
        var indexChapter : int = _info.actionParams[1] as int;
        if (indexChapter >= 0) {
            var pInstanceSystem:CInstanceSystem = _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            var view:CInstanceScenarioView = pInstanceSystem.uiHandler.getWindow(_wndType) as CInstanceScenarioView;
            if (view && view.isShowState) {
                _actionValue = view._pageView.changeChapter(indexChapter);
            }
        }
    }

    private function get _wndType() : int {
        return _isElite ? EInstanceWndType.WND_INSTANCE_ELITE : EInstanceWndType.WND_INSTANCE_SCENARIO;
    }

    private var _isElite:Boolean;
}
}

