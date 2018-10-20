//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/20.
 */
package helper {

import QFLib.Foundation.CKeyboard;
import QFLib.Foundation.CMap;

import flash.ui.Keyboard;


public class CKeyPressHelper extends CHelperBase {
    public function CKeyPressHelper(battleTutor:CBattleTutor) {
        super (battleTutor);
        _keyPressHandlerList = new CMap();
    }

    public override function dispose() : void {
        super.dispose();
        stop();
        _keyPressHandlerList = null;
    }

    public function start() : void {
        _keyboard = new CKeyboard(_pBattleTutor.system.stage.flashStage);

        _keyboard.registerKeyCode(true, Keyboard.W, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.S, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.A, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.D, _onKeyDown);

        _keyboard.registerKeyCode(true, Keyboard.U, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.I, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.O, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.J, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.K, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.L, _onKeyDown);
        _keyboard.registerKeyCode(true, Keyboard.SPACE, _onKeyDown);
    }
    public function stop() : void {
        if (_keyboard) {
            _keyboard.unregisterKeyCode(true, Keyboard.W, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.S, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.A, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.D, _onKeyDown);

            _keyboard.unregisterKeyCode(true, Keyboard.U, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.I, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.O, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.J, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.K, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.L, _onKeyDown);
            _keyboard.unregisterKeyCode(true, Keyboard.SPACE, _onKeyDown);


            _keyboard.dispose();
            _keyboard = null;

        }

        if (_keyPressHandlerList) {
            for each (var handlerList:CMap in _keyPressHandlerList) {
                if (handlerList) {
                    handlerList.clear();
                }
            }
            _keyPressHandlerList.clear();
        }
    }


    private function _onKeyDown(keyCode:uint):void {
        if (_keyPressHandlerList.length == 0) return ;
        var handlerList:CMap = _keyPressHandlerList.find(keyCode);
        if (handlerList) {
            for each (var handler:Function in handlerList) {
                if (handler) {
                    handler(keyCode);
                }
            }
        }
    }

    // key : KeyBoard.X
    public function listenKey(key:uint, handler:Function) : Boolean {
        var handlerList:CMap = _keyPressHandlerList.find(key);
        if (handlerList == null) {
            handlerList = new CMap();
            _keyPressHandlerList.add(key, handlerList);
        }

        if (handlerList.find(handler) == null) {
            handlerList.add(handler, handler);
        }
        return true;
    }
    // key : KeyBoard.X
    public function unListenKey(key:uint, handler:Function) : Boolean {
        var handlerList:CMap = _keyPressHandlerList.find(key);
        if (handlerList) {
            handlerList.remove(handler);
        }
        return true;
    }

    private var _keyboard:CKeyboard;

    private var _keyPressHandlerList:CMap; // key:String, value:CMap(Handler)

}
}
