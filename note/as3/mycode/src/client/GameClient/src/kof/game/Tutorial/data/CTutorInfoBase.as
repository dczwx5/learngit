//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/3.
 */
package kof.game.Tutorial.data {

public class CTutorInfoBase {
    public function CTutorInfoBase(tutorData:CTutorData) {
        _tutorData = tutorData;
    }

    public function dispose() : void {
        _tutorData = null;
    }


    protected var _tutorData:CTutorData;
}
}
