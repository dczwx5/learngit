//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 11:27
 */
package kof.game.diamondRoulette.models {

import kof.framework.INetworking;
import kof.game.diamondRoulette.view.CAbstractView;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class CAbstractModel {
    public var _viewVec:Vector.<CAbstractView> = null;
    protected var _net:INetworking=null;
    public function CAbstractModel() {
        _viewVec = new <CAbstractView>[];
    }

    public function execute():void{
        throw new Error("subClass has not override!")
    }

    public function initRequest():void{
        throw new Error("subClass has not override!")
    }

    public function addView(value:CAbstractView):void{
        var index:int=_viewVec.indexOf(value);
        if(index==-1){
            _viewVec.push(value);
        }
    }

    public function removeView(value:CAbstractView):void{
        var index:int = _viewVec.indexOf(value);
        if(index!=-1){
            _viewVec.splice(index,1);
        }
    }

    public function notify():void{
        for each(var view:CAbstractView in _viewVec){
            view.update();
        }
    }

    public function set net(value:INetworking):void{
        this._net = value;
    }
}
}
