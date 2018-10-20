//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1.data {

import kof.data.CObjectData;


public class CPeak1v1RankingData extends CObjectData {

    public function CPeak1v1RankingData() {

    }

    public function get roleID() : Number { return _data[_roleID]; }
    public function get ranking() : int { return _data[_ranking]; }
    public function get name() : String { return _data[_name]; }
    public function get score() : int { return _data[_score]; }

    public static const _roleID:String = "roleID"; // 角色ID
    public static const _ranking:String = "ranking"; // 排名
    public static const _name:String = "name"; // 战队名
    public static const _score:String = "score"; // 积分


}
}
