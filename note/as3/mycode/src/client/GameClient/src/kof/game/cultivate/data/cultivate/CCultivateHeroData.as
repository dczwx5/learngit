//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/17.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectData;

public class CCultivateHeroData extends CObjectData {
    public function CCultivateHeroData() {

    }

    public function get profession() : int { return _data[_profession]; }
    public function get HP() : int { return _data["HP"]; }
    public function get ragePower() : int { return _data["ragePower"]; }
    public function get MaxHP() : int { return _data["MaxHP"]};


    public static const _profession:String = "profession";
}
}
