//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter.data {


import kof.data.CObjectData;

public class CStreetFighterEnterHeroData extends CObjectData {
    public function CStreetFighterEnterHeroData() {
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);

    }
    [Inline]
    public function get time() : int { return _data["time"]; } // 进场时间
    [Inline]
    public function get level() : int { return _data["level"]; } // 角色等级

    [Inline]
    public function get name() : String { return _data["name"]; } // 战队名
    [Inline]
    public function get headIcon() : int { return _data["headIcon"]; } // 角色头像
    [Inline]
    public function get roleID() : Number { return _data[_roleID]; } // 角色ID

    public static const _roleID:String = "roleID";

}
}
