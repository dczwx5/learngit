//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package kof.game.Tutorial.battleTutorPlay {

public class CBattleTutorData {
    public function CBattleTutorData(tutorID:int, controlType:int) {
        this.tutorID = tutorID;
        this.controlType = controlType;
    }

    // 自由控制
    public function isFreeType() : Boolean {
        return controlType == 0;
    }

    public var tutorID:int;
    public var controlType:int;
}
}
