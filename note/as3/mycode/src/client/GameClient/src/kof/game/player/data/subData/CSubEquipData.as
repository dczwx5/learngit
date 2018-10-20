//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CSubEquipData extends CObjectData {
    public function CSubEquipData() {
    }

    public function get huizhang():Number{
        return _rootData.data[_huizhang] ? _rootData.data[_huizhang] : 0;
    } // 徽章
    public function get miji():Number{
        return _rootData.data[_miji] ? _rootData.data[_miji] : 0;
    } // 秘籍

    public static const _huizhang:String = "badgeExp";
    public static const _miji:String = "secretExp";
}
}
