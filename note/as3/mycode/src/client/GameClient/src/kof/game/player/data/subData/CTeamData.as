//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CTeamData extends CObjectData {
    public function CTeamData() {
    }

    public function get name() : String { return _rootData.data[_name] ; }
    public function get battleValue() : Number { return _rootData.data[ _battleValue ]; }
    public function get level() : int {
        return _rootData.data[_level];
    }
    public function get exp() : Number {
        return _rootData.data[ _exp ];
    }
    // 战队信息
    public function get useHeadID() : int {
        return _rootData.data[ _useHeadID ];
    }

    public function get headIDList() : Array {
        return _rootData.data[ _headIDList ];
    }
    // 已经修改次数
    public function get firstModifyName() : int {
        return _rootData.data[ _firstModifyName ];
    } // 0第一次改名
    public function get createTeam() : Boolean {
        return _rootData.data[ _createTeam ];
    } // 是否创建战队
    // 个性签名
    public function get sign() : String {
        return _rootData.data[ _sign ];
    }
    public function getNoneServerName() : String {
        var tempName : String = _rootData.data[ _name ];
        var index : int = tempName.indexOf( "." );
        if ( index == -1 ) {
            return tempName;
        }
        tempName = tempName.substring( index + 1 );
        return tempName;
    }
    public function get prototypeID() : int {
        return _rootData.data[ _prototypeID ];
    } // 格斗家ID
    public static const _name : String = "name";
    public static const _battleValue : String = "battleValue";
    public static const _level : String = "level";
    public static const _exp : String = "exp";
    public static const _sign : String = "sign";
    public static const _useHeadID : String = "useHeadID";
    public static const _headIDList : String = "headIDList";
    public static const _firstModifyName : String = "firstModifyName";
    public static const _createTeam : String = "createTeam";
    public static const _prototypeID : String = "prototypeID";

}
}
