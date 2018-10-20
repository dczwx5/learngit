//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2018/2/7.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CSubClubData extends CObjectData {
    public function CSubClubData() {
        super();
    }

    public function get isOpenClub() : Boolean {
        return _rootData.data[ _isOpenClub ];
    }


    public static const _isOpenClub : String = "isOpenClub";
}
}
