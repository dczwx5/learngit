//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/15.
 */
package kof.game.player.data {

import kof.data.CObjectData;

public class CEmbattleData extends CObjectData {
    final public function get heroID() : int { return _data[HERO_ID]; } // uniID
    final public function get prosession() : int { return _data[PROSESSION]; } // heroID
    final public function get position() : int { return _data[POSITION]; } // 位置

    public static function getCreateData(uid:int, prosession:int, pos:int) : Object {
        return ({heroID:uid, prosession:prosession, position:pos});
    }

    public function export() : Object {
        return {heroID:heroID, prosession:prosession, position:position};
    }

    public static const HERO_ID:String = "heroID";
    public static const PROSESSION:String = "prosession";
    public static const POSITION:String = "position";
}
}
