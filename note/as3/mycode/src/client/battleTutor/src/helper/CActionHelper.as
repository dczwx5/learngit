//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package helper {

import action.CActionBase;

public class CActionHelper extends CHelperBase {
    public function CActionHelper(battleTutor:CBattleTutor) {
        super (battleTutor);
    }

    public function resetStartTime(act:CActionBase) : Boolean {
        act.resetStartTime();
        return true;
    }
}
}
