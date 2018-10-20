//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakpk.data {

import kof.data.CObjectData;

public class CPeakpkInviterData extends CObjectData {
    public function CPeakpkInviterData() {
    }

    [Inline]
    public function get name() : String { return _data["name"]; }
    [Inline]
    public function get fairPeakScore() : int { return _data["fairPeakScore"]; }
    [Inline]
    public function get id() : Number { return _data["id"]; } // p1 uid

}
}
