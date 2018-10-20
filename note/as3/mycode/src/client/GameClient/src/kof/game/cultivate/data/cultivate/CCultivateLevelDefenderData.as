//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/17.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectData;

public class CCultivateLevelDefenderData extends CObjectData {
    public function CCultivateLevelDefenderData() {

    }

    public function get profession() : int { return _data[_profession]; } // playerBasic 表ID
    public function get maxHP() : int { return _data["maxHP"]; }
    public function get HP() : int { return _data["HP"]; }
    public function get battleValue() : int { return _data["battleValue"]; }

    public static const _profession:String = "profession";
}
}
