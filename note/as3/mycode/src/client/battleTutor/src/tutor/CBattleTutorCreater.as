//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package tutor {

import Enum.EBattleTutorType;

import kof.framework.CAppSystem;
import kof.game.Tutorial.battleTutorPlay.CBattleTutorData;

public class CBattleTutorCreater {
    public static function createTutor(battleTutor:CBattleTutor, tutorData:CBattleTutorData, system:CAppSystem) : CTutorBase {
        var tutorBase:CTutorBase;
        var clazz:Class;
        switch (tutorData.tutorID) {
            case EBattleTutorType.ID_1001 :
                clazz = CTutor1001;
                break;
            case EBattleTutorType.ID_1002 :
                clazz = CTutor1002;
                break;
            case EBattleTutorType.ID_1003 :
                clazz = CTutor1003;
                break;
            case EBattleTutorType.ID_1004 :
                clazz = CTutor1004;
                break;
            case EBattleTutorType.ID_2000 :
                clazz = CTutor2000;
                break;
            case EBattleTutorType.ID_2001 :
                clazz = CTutor2001;
                break;

            case EBattleTutorType.ID_3001 :
                clazz = CTutor3001;
                break;
//            case EBattleTutorType.ID_4000 :
//                clazz = CTutor4000;
//                break;
            case EBattleTutorType.ID_4001 :
                clazz = CTutor4001;
                break;

            case EBattleTutorType.ID_5001 :
                clazz = CTutor5001;
                break;

        }

        if (clazz) {
            tutorBase = new clazz();
            tutorBase.battleTutor = battleTutor;
            tutorBase.tutorData = tutorData;
            tutorBase.system = system;
            tutorBase.initialize();
        }

        return tutorBase;
    }
}
}
