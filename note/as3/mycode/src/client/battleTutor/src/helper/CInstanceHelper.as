//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/20.
 */
package helper {

import config.CPathConfig;

import kof.game.Tutorial.battleTutorPlay.CBattleTutorEvent;
import kof.game.player.data.CPlayerData;

public class CInstanceHelper extends CHelperBase {
    public function CInstanceHelper(battleTutor:CBattleTutor) {
        super (battleTutor);
    }

    public function getSingPoins(id:int) : Object {
        return _pBattleTutor.systemHelper.levelSystem.getSingPoins(id);
    }

    public function playAudio(id:String) : Boolean {
        if (id == null || id.length == 0) return true;

        var path:String = CPathConfig.getAudioPath(id.toString());
        _pBattleTutor.systemHelper.audio.playAudioByPath(path, 1);

        return true;
    }

    public function uploadData(step:int) : Boolean {
        if (step <= 0) {
            return true;
        }
        if (_updateLoadedStepMap.hasOwnProperty(step.toString())) {
            return true;
        }

        _updateLoadedStepMap[step] = step;
        var playerData:CPlayerData = _pBattleTutor.systemHelper.playerSystem.playerData;
//        if (playerData.tutorData.battleGuideStep < step) {
            playerData.tutorData.battleGuideStep = step;
            _pBattleTutor.dispatchEvent(new CBattleTutorEvent(CBattleTutorEvent.EVENT_STEP_CHANGE, step));
//            log("|--------------------------------battle tutor step : " + step);
//        }

        return true;
    }
    private var _updateLoadedStepMap:Object = new Object();

}
}
