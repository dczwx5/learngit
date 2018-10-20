//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/14.
 *福袋信息
 */
package kof.game.club.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CClubWelfareBagData extends CObjectData {
    public function CClubWelfareBagData() {
        super();
        _data = new CMap();
    }
    public function get ID() : String { return _data[_ID]; }
    public function get name() : String { return _data[_name]; }
    public function get createTime() : Number { return _data[_createTime]; }
    public function get expireTime() : Number { return _data[_expireTime]; }
    public function get itemType() : int { return _data[_itemType]; }
    public function get luckyBagState() : int { return _data[_luckyBagState]; }
    public function get recordList() : Array { return _data[_recordList]; }
    public function get rewardID() : int { return _data[_rewardID]; }
    public function get rewardNum() : int { return _data[_rewardNum]; }
    public function get totalNum() : int { return _data[_totalNum]; }
    public function get rewardValue() : int { return _data[_rewardValue]; }
    public function get roleID() : int { return _data[_roleID]; }
    public function get type() : int { return _data[_type]; }
    public function get headId() : int { return _data[_headId]; }
    public function get isSendMarquee() : Boolean { return _data[_isSendMarquee]; }
    public function get sendMarqueeRate() : Array { return _data[_sendMarqueeRate]; }
    public function get thanksPlayerID() : int { return _data[_thanksPlayerID]; }
    public function get thanksValue() : int { return _data[_thanksValue]; }
    public function get configID() : int { return _data[_configID]; }


    public static function createObjectData( ID:int,name:String,createTime:Number,expireTime:Number,itemType:int,luckyBagState:int,recordList:Array,rewardID:int,
    rewardNum:int,totalNum:int,rewardValue:int,roleID:int,type:int,headId:int,isSendMarquee:Boolean,sendMarqueeRate:Array,thanksPlayerID:int,
                                             thanksValue:int,configID:int) : Object {
        return {ID:ID,name:name,createTime:createTime,expireTime:expireTime,itemType:itemType,luckyBagState:luckyBagState,recordList:recordList,rewardID:rewardID,
            rewardNum:rewardNum,totalNum:totalNum,rewardValue:rewardValue,roleID:roleID,type:type,headId:headId,isSendMarquee:isSendMarquee,
            sendMarqueeRate:sendMarqueeRate,thanksPlayerID:thanksPlayerID,thanksValue:thanksValue,configID:configID
        }
    }

    public static const _ID:String = "ID";
    public static const _name:String = "name";
    public static const _createTime:String = "createTime";
    public static const _expireTime:String = "expireTime";
    public static const _itemType:String = "itemType";
    public static const _luckyBagState:String = "luckyBagState";
    public static const _recordList:String = "recordList";
    public static const _rewardID:String = "rewardID";
    public static const _rewardNum:String = "rewardNum";
    public static const _totalNum:String = "totalNum";
    public static const _rewardValue:String = "rewardValue";
    public static const _roleID:String = "roleID";
    public static const _type:String = "type";
    public static const _headId:String = "headId";
    public static const _isSendMarquee:String = "isSendMarquee";
    public static const _sendMarqueeRate:String = "sendMarqueeRate";
    public static const _thanksPlayerID:String = "thanksPlayerID";
    public static const _thanksValue:String = "thanksValue";
    public static const _configID:String = "configID";


}
}
