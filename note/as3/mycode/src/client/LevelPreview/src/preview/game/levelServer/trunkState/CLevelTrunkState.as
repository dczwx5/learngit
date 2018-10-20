/**
 * Created by auto on 2016/5/30.
 */
package preview.game.levelServer.trunkState {
import QFLib.Interface.IDisposable;

import avmplus.getQualifiedClassName;

import flash.utils.getTimer;

import kof.game.levelCommon.CLevelLog;
import preview.game.levelServer.CLevelServer;

public class CLevelTrunkState implements IDisposable {
    public static const _UNREADY:String = "unready";
    public static const _ACTIVE:String = "active";
    public static const _ENTER:String = "enter";
    public static const _PASS:String = "pass";
    public static const _COMPLETE:String = "complete";
    public static const _PORTAL:String = "portal";
    public static const _OVER:String = "gameOver"; // 到这里就结束了

    public function CLevelTrunkState(rState:String, server:CLevelServer) {
        _state = rState;
        _server = server;
        inState();
    }

    public function dispose() : void {
        _server = null;
        _state = _UNREADY;
        _startTime = -1;
    }

    protected virtual function inState() : void {
        _startTime = getTimer();
        CLevelLog.Log(getQualifiedClassName(this) + " : inState");
        // throw new Error("CLevelTrunkState's inState function need override");
    }
    public function get startTime() : int {
        return this._startTime;
    }
    public function get subStartTime() : Number {
        return getTimer() - startTime;
    }

    public virtual function checkNextState() : CLevelTrunkState {
        throw new Error("CLevelTrunkState's checkNextState function need override");
        return null;
    }
    final public function get state() : String {
        return _state;
    }

    final public function isCompleted() : Boolean {
        return state == _OVER;
    }
    final public function isActived() : Boolean {
        return state == _ACTIVE;
    }
    final public function isPortal() : Boolean {
        return state == _PORTAL;
    }
    protected var _server:CLevelServer;
    protected var _state:String;
    protected var _startTime:int;

}
}
