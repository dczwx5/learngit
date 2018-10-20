//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import kof.framework.CAppSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.loading.CSceneLoadingViewHandler;
import kof.game.scenario.CScenarioSystem;
import kof.ui.CUISystem;
import kof.ui.CUISystem;

public class CTutorActionPlayScenario extends CTutorActionBase {

    public function CTutorActionPlayScenario(actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    override public function dispose() : void {
        super.dispose();

    }

    override public function start() : void {
        super.start();

        var sScenarioID : String = _info.actionParams[0] as String;

        if (sScenarioID && sScenarioID.length > 0) {
            var uiSystem:CUISystem = _system.stage.getSystem(CUISystem) as CUISystem;
            var pLoadingView : CSceneLoadingViewHandler = uiSystem.getBean( CSceneLoadingViewHandler );
            if (pLoadingView.isViewShow) {
                _waitPlay = true;
            } else {
                var pScenarioSystem:CScenarioSystem = (_system.stage.getSystem(CScenarioSystem) as CScenarioSystem);
                pScenarioSystem.playScenario(int(sScenarioID), 1, _onScenarioFinish ,false);
            }
        } else {
            _actionValue = true;
        }
    }

    override public function update(delta:Number) : void {
        super.update(delta);

        if (_waitPlay) {
            var sScenarioID : String = _info.actionParams[0] as String;
            if (sScenarioID && sScenarioID.length > 0) {
                var uiSystem:CUISystem = _system.stage.getSystem(CUISystem) as CUISystem;
                var pLoadingView : CSceneLoadingViewHandler = uiSystem.getBean( CSceneLoadingViewHandler );
                if (false == pLoadingView.isViewShow) {
                    var pScenarioSystem:CScenarioSystem = (_system.stage.getSystem(CScenarioSystem) as CScenarioSystem);
                    pScenarioSystem.playScenario(int(sScenarioID), 1, _onScenarioFinish ,false);
                    _waitPlay = false;
                }
            }
        }
    }

    private function _onScenarioFinish(scenarioID:int) : void {
        _actionValue = true;
    }

    private var _waitPlay:Boolean;
}
}

