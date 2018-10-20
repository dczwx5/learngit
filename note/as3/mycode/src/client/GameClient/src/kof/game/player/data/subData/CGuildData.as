//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/30.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CGuildData extends CObjectData {
    public function CGuildData() {
    }

    public function get clubID() : String {
        return _rootData.data[ _clubID ];
    }
    public function get clubName() : String {
        return _rootData.data[ _clubName ];
    }
    public function get societyCoin() : Number {
        return _rootData.data[ _societyCoin ];
    }


    public static const _clubID : String = "clubID";
    public static const _clubName : String = "clubName";
    public static const _societyCoin : String = "societyCoin";

}
}
