//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/28.
 */
package kof.game.player.data {

import kof.data.CObjectData;

public class CSkillSlotData extends CObjectData {
    public function CSkillSlotData() {
    }

    public function get position() : int { return _data[_position]} // 槽位置，从1开始
    public function get isActive() : Boolean { return _data["isActive"]} // 技能槽是否激活 true代表已激活
    public function get isBreak() : Boolean { return _data["isBreak"]} // 技能槽是否已突破

    public static const _position:String = "position";
}
}
