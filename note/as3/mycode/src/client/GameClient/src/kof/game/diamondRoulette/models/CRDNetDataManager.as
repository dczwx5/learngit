//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/2/5.
 * Time: 12:15
 */
package kof.game.diamondRoulette.models {

import kof.framework.INetworking;
import kof.game.diamondRoulette.models.vo.DiamondRoulette;
import kof.message.Activity.ActivityChangeResponse;
import kof.message.Activity.DiamondRouletteDrawRequest;
import kof.message.Activity.DiamondRouletteDrawResponse;
import kof.message.Activity.DiamondRouletteRequest;
import kof.message.Activity.DiamondRouletteResponse;
import kof.message.CAbstractPackMessage;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/2/5
 */
public class CRDNetDataManager extends CAbstractModel {
    private var _data:DiamondRoulette = null;
    public function CRDNetDataManager() {
        super();
        _data = new DiamondRoulette();
    }

    override public function initRequest():void{
        this.diamondRouletteRequest();
    }

    override public function set net(value:INetworking):void{
        this._net = value;
        _initBindMessage();
    }

    private function _initBindMessage():void{
        this._net.bind(DiamondRouletteResponse).toHandler(_diamondRouletteResponse);
        this._net.bind(DiamondRouletteDrawResponse).toHandler(_diamondRouletteDrawResponse);
    }

    private function _diamondRouletteResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:DiamondRouletteResponse = message as DiamondRouletteResponse;
        _data.decode(response);
        this.notify();
    }

    private function _diamondRouletteDrawResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:DiamondRouletteDrawResponse = message as DiamondRouletteDrawResponse;
        _data.decodeDraw(response);
        this.notify();
    }
    //打开界面请求信息
    public function diamondRouletteRequest():void{
        var request:DiamondRouletteRequest = new DiamondRouletteRequest();
        request.info = 1;
        _net.post(request);
    }
    //点击按钮请求信息
    public function diamondRouletteDrawRequest():void{
        var request:DiamondRouletteDrawRequest = new DiamondRouletteDrawRequest();
        request.drawCounts = 1;
        _net.post(request);
    }

    public function get data():DiamondRoulette{
        return this._data;
    }
}
}
