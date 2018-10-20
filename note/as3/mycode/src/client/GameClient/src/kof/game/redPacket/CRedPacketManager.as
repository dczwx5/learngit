//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-06-01.
 */
package kof.game.redPacket {

import kof.framework.CAbstractHandler;
import kof.game.redPacket.data.CRedPacketInfo;
import kof.game.switching.CSwitchingSystem;
import kof.message.FighterTreasure.OpenRedEnvelopeResponse;
import kof.message.FighterTreasure.SendRedEnvelopeResponse;
import kof.message.FighterTreasure.WholeServerRedEnvelopeResponse;

/**
 *@author Demi.Liu
 *@data 2018-06-01
 */
public class CRedPacketManager extends CAbstractHandler {
    //红包数据
    private var _redPacketInfo:CRedPacketInfo;

    //打开红包结果
    private var _openRedPacketInfo:OpenRedEnvelopeResponse;

    //红包数据
    public var redPacketInfoList:Array = new Array();

    public function CRedPacketManager() {
        super();
    }

    public function set redPacketInfo( data:CRedPacketInfo):void{
        _redPacketInfo = null;
    }

    public function set openRedPacketInfo(data:OpenRedEnvelopeResponse):void{
        _openRedPacketInfo = data;
    }

    public function get openRedPacketInfo():OpenRedEnvelopeResponse{
        return _openRedPacketInfo;
    }

    public function get redPacketInfo():CRedPacketInfo{
        _redPacketInfo = redPacketInfoList.shift();
        return _redPacketInfo;
    }

    public function get redPacketInfoListLength():int{
        return redPacketInfoList.length
    }

    public function get isShow():Boolean{
        if(_redPacketInfo){
            return true;
        }
        return false;
    }


}
}
