//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CSystemData extends CObjectData {
    public function CSystemData() {
    }

    public function get channelInfo() : Object {
        return _rootData.data[ _channelInfo ];
    }
    public function get openSeverDays() : int{
        return _rootData.data[ _openSeverDays ];
    }
    public function get sevenDaysLoginActivityState() : Array{
        return _rootData.data[ _sevenDaysLoginActivityState ];
    }
    public function get firstRechargeState() : int{
        return _rootData.data[ _firstRechargeState ];
    }
    public function get isCollectionGame() : int{
        return _rootData.data[ _isCollectionGame ];
    }
    public function get isGetMicroClientReward() : int{
        return _rootData.data[ _isGetMicroClientReward ];
    }


    public static const _channelInfo : String = "channelInfo";
    public static const _openSeverDays : String = "openSeverDays";
    public static const _sevenDaysLoginActivityState : String = "sevenDaysLoginActivityState";
    public static const _firstRechargeState : String = "firstRechargeState";
    public static const _isCollectionGame : String = "isCollectionGame";
    public static const _isGetMicroClientReward : String = "isGetMicroClientReward";

}
}
