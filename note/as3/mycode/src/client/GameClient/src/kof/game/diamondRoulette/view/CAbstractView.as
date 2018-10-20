//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 11:40
 */
package kof.game.diamondRoulette.view {

import kof.game.diamondRoulette.CReturnDiamondSystem;
import kof.game.diamondRoulette.commands.COpenViewCommand;
import kof.game.diamondRoulette.control.CAbstractControl;
import kof.ui.IUICanvas;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class CAbstractView  {
    protected var _control:CAbstractControl=null;
    protected var _cmd:COpenViewCommand=null;
    protected var _uiCanvas:IUICanvas=null;
    protected var _closeHandler:Function = null;
    protected var _system:CReturnDiamondSystem=null;
    public function CAbstractView(control:CAbstractControl) {
        this._control = control;
    }

    public function update():void{
//        _system
    }

    public function close():void{

    }

    public function show():void{

    }

    public function setCmd(cmd:COpenViewCommand):void{
        this._cmd = cmd;
    }

    public function executeCmd():void{
        this._cmd.execute();
    }

    public function set uiCanvas(value:IUICanvas):void{
        _uiCanvas = value;
    }

    public function set closeHandler(value:Function):void{
        _closeHandler = value;
    }

    public function set system(sys:CReturnDiamondSystem):void{
        this._system = sys;
    }
}
}
