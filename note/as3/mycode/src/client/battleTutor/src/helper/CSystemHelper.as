//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package helper {

import kof.framework.IApplication;
import kof.framework.IDatabase;
import kof.game.Tutorial.CTutorSystem;
import kof.game.audio.IAudio;
import kof.game.core.CECSLoop;
import kof.game.instance.CInstanceAutoFightHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.level.CLevelSystem;
import kof.game.player.CPlayerSystem;
import kof.game.scenario.CScenarioSystem;
import kof.game.scene.ISceneFacade;
import kof.ui.CUISystem;

public class CSystemHelper extends CHelperBase {
    public function CSystemHelper(battleTutor:CBattleTutor) {
        super (battleTutor);
    }

    [Inline]
    public function get sceneSystem() : ISceneFacade {
        return _pBattleTutor.system.stage.getSystem(ISceneFacade) as ISceneFacade;
    }
    [Inline]
    public function get escLoop() : CECSLoop {
        return _pBattleTutor.system.stage.getSystem(CECSLoop) as CECSLoop;
    }
    [Inline]
    public function get application() : IApplication {
        return _pBattleTutor.system.stage.getBean(IApplication) as IApplication;
    }
    [Inline]
    public function get instanceSystem() : CInstanceSystem {
        return _pBattleTutor.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }
    [Inline]
    public function get autoFightHandler() : CInstanceAutoFightHandler {
        return instanceSystem.getBean(CInstanceAutoFightHandler) as CInstanceAutoFightHandler;
    }
    [Inline]
    public function get levelSystem() : CLevelSystem {
        return _pBattleTutor.system.stage.getSystem(CLevelSystem) as CLevelSystem;
    }
    [Inline]
    public function get scenarioSystem() : CScenarioSystem {
        return _pBattleTutor.system.stage.getSystem(CScenarioSystem) as CScenarioSystem;
    }
    [Inline]
    public function get playerSystem() : CPlayerSystem {
        return _pBattleTutor.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    [Inline]
    public function get tutorSystem() : CTutorSystem {
        return _pBattleTutor.system.stage.getSystem(CTutorSystem) as CTutorSystem;
    }
    [Inline]
    public function get database() : IDatabase {
        return _pBattleTutor.system.stage.getSystem(IDatabase) as IDatabase;
    }
    [Inline]
    public function get audio() : IAudio {
        return _pBattleTutor.system.stage.getSystem(IAudio) as IAudio;
    }
    [Inline]
    public function get uiSystem() : CUISystem {
        return _pBattleTutor.system.stage.getSystem(CUISystem) as CUISystem;
    }
}
}
