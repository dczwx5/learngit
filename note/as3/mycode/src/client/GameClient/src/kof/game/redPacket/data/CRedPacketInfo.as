//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-06-07.
 */
package kof.game.redPacket.data {

/**
 *@author Demi.Liu
 *@data 2018-06-07
 */
public class CRedPacketInfo {
    public function CRedPacketInfo(data:Object) {
        playerId = data.playerId;
        roleName = data.roleName;
        headId = data.headId;
        envelopeId = data.envelopeId;
        amount = data.amount;
        levelLimit = data.levelLimit;
        isOpen = false;
    }

    //玩家id
    public var playerId:Number;

    //玩家名
    public var roleName:String;

    //玩家头像id
    public var headId:int;

    //红包id
    public var envelopeId:Number;

    //红包金额
    public var amount:int;

    //等级限制
    public var levelLimit:int;

    //打开红包
    public var isOpen:Boolean;

}
}
