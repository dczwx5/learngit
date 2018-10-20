//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/8.
 */
package helper {

public class CHelperBase {
    public function CHelperBase(battleTutor:CBattleTutor) {
        _pBattleTutor = battleTutor;
    }

    public function dispose() : void {
        _pBattleTutor = null;
    }

    protected var _pBattleTutor:CBattleTutor;
}
}
