//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/31.
 */
package kof.game.bossChallenge.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;
import kof.game.item.data.CRewardListData;

public class CBossChallengeRewardData extends CObjectData {

    private var _thisData : CMap;

    public function CBossChallengeRewardData()
    {
        this.addChild(CRewardListData);
        _thisData = new CMap();
    }
    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        for (var key:String in data)
        {
            _thisData[key] = data[key];
        }
    }
    public function get isWin() : Boolean {return _thisData["win"];}
    public function get selfRewards() : Array {return _thisData["selfRewards"];}
    public function get cooperateRewards() : Array {return _thisData["cooperateRewards"];}
    public function get selfHeroID() : int { return _thisData["selfHeroID"]; }
    public function get cooperateName() : String { return _thisData["cooperateName"]; }
    public function get cooperateHeroID() : int { return _thisData["cooperateHeroID"]; }
    public function get cooperateDP() : int { return _thisData["cooperateDP"]; }


}
}
