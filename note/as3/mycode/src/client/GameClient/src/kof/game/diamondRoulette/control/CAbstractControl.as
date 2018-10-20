//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 10:52
 */
package kof.game.diamondRoulette.control {

import kof.game.diamondRoulette.commands.CAbstractCommand;
import kof.game.diamondRoulette.models.CAbstractModel;
import kof.game.diamondRoulette.models.CRDNetDataManager;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class CAbstractControl {
    private var _model:CRDNetDataManager=null;
    private var _cmd:CAbstractCommand=null;
    public function CAbstractControl() {
    }

    public function set model(value:CRDNetDataManager):void{
        this._model = value;
    }

    public function get model():CRDNetDataManager{
        return this._model;
    }

    public function set cmd(value:CAbstractCommand):void{
        this._cmd = value;
    }

    public function execute():void{
        //执行操作
        this._model.execute();
    }

    public function invoker():void{
        this._cmd.execute();
    }
}
}
