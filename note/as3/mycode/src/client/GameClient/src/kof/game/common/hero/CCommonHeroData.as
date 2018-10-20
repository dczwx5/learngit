//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.common.hero {

import kof.data.CObjectData;


public class CCommonHeroData extends CObjectData {

    public function CCommonHeroData() {
    }

    public function get prototypeID() : int { return _data[_prototypeID]; }
    public function get level() : int { return _data[_level]; }
    public function get quality() : int { return _data[_quality]; }
    public function get star() : int { return _data[_star]; }
    public function get battleValue() : int { return _data[_battleValue]; }

    public static const _prototypeID:String = "prototypeID";
    public static const _level:String = "level";
    public static const _quality:String = "quality";
    public static const _star:String = "star";
    public static const _battleValue:String = "battleValue";
}
}
