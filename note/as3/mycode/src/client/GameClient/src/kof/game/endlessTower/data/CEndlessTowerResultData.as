//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/13.
 */
package kof.game.endlessTower.data {

import kof.data.CObjectData;
import kof.game.item.data.CRewardListData;

public class CEndlessTowerResultData extends CObjectData {
    public function CEndlessTowerResultData() {
        super ();

        this.addChild(CRewardListData);

    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        _reward.resetChild();
        if (data.hasOwnProperty(_rewardList)) {
            _reward.updateDataByData(data[_rewardList]);
        }
    }

    public function get isWin() : Boolean {
        return _data[_isWin];
    }
    public function get isFirstPass() : Boolean {
        return _data[_isFirstPass];
    }

    public function get rewardList() : CRewardListData {
        return _reward;
    }

    public function get heroIdList():Array
    {
        return _data[_heroIdList];
    }

    public function get robotName():String
    {
        return _data[_robotName];
    }

    public static function createDataObject(rIsWin:Boolean, rIsFirstPass:Boolean, rRewardList:Array, heroIdList:Array, robotName:String) : Object {
        return {isWin:rIsWin, isFirstPass:rIsFirstPass, rewardList:rRewardList, robotHeroIds:heroIdList, robotName:robotName};
    }


    private function get _reward() : CRewardListData { return this.getChild(0) as CRewardListData; }
    public static const _isWin:String = "isWin";
    public static const _isFirstPass:String = "isFirstPass";
    public static const _rewardList:String = "rewardList";
    public static const _heroIdList:String = "robotHeroIds";
    public static const _robotName:String = "robotName";
}
}
