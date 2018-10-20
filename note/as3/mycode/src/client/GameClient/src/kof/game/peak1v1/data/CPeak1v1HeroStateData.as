//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1.data {

import kof.data.CObjectData;


public class CPeak1v1HeroStateData extends CObjectData {

    public function CPeak1v1HeroStateData() {
    }

    public function get profession() : int { return _data[_profession]; }
    public function get HP() : int { return _data[_HP]; }

    public static const _profession:String = "profession";
    public static const _HP:String = "HP";
}
}
