//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/29.
 */
package kof.game.instance {

import kof.framework.CAbstractHandler;
import kof.game.instance.event.CInstanceEvent;

// 处理回到主城时的事务
public class CInstanceExitProcess extends CAbstractHandler {
    public static const FLAG_INSTANCE:String = "flag_instance";
    public static const FLAG_CREATE_TEAM:String = "flag_create_team";
    public static const FLAG_CULTIVATE:String = "flag_cultivate";
    public static const FLAG_PEAK:String = "flag_peak";
    public static const FLAG_PEAK_1V1:String = "flag_peak1v1";
    public static const FLAG_ARENA:String = "flag_arena";
    public static const FLAG_WORLDBOSS:String = "flag_worldBoss";
    public static const FLAG_CLUBBOSS:String = "flag_clubBoss";
    public static const FLAG_ENDLESS_TOWER:String = "flag_endlessTower";
    public static const FLAG_ENDLESS_TOWER_AUTO:String = "flag_endlessTower_auto";
    public static const FLAG_GM_REPORT:String = "flag_gm_report";
    public static const FLAG_STREET_FIGHTER:String = "flag_street_fighter";
    public static const FLAG_GUILD_WAR_DISPOSE:String = "flag_guild_war_disposeLoader";
    public static const FLAG_STORY:String = "flag_story";


    public function CInstanceExitProcess() {
    }

    public override function dispose():void {
        super.dispose();
        (system as CInstanceSystem).removeEventListener(CInstanceEvent.LEVEL_ENTERED, _onEnterLevel);

    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();
        _list = new Array();
        (system as CInstanceSystem).addEventListener(CInstanceEvent.LEVEL_ENTERED, _onEnterLevel);
        return ret;
    }

    /**
     * @param flagClz : 类标记, 可为null, 用于添加的事务的管理, 可用于删除, 等
     * @param flagName : 名字标记, 可为null, 常量定义在CInstanceExitProcess, 用于添加的事务的管理, 可用于删除, 等
     * @param func
     * @param param
     * @param priority 值越大, 优先级越小
     * @param block : false -> process list direct,  true -> while wait
     */
    public function addProcess(flagClz:Class, flagName:String, func:Function, param:Array, priority:int) : void {
        _list.push(new ProcessHandler(flagClz, flagName, func, param, priority));
        _list.sortOn("priority", Array.NUMERIC );
    }
    public function removeProcess(flagClz:Class, flagName:String) : void {
        if (null == flagClz && flagName == null) return ;
        for (var i:int = 0; i < _list.length; i++) {
            var handler:ProcessHandler = _list[i] as ProcessHandler;
            if (flagClz) {
                if (handler.flagClz == flagClz || handler.flagClz is flagClz) {
                    _list.splice(i, 1);
                    i--;
                }
            }
            if (flagName && flagName.length > 0) {
                if (handler.flagName == flagName) {
                    _list.splice(i, 1);
                    i--;
                }
            }

        }
    }

    private function _onEnterLevel(e:CInstanceEvent) : void {
        if (_instanceSystem.isMainCity) {
            // 暂时一次全处理
            while(_list.length) {
                var handler:ProcessHandler = _list.shift();
                handler.func.apply(null, handler.param);
            }
        }
    }

    private function get _instanceSystem() : CInstanceSystem {
        return system as CInstanceSystem;
    }

    private var _list:Array;
}
}

class ProcessHandler {
    public function ProcessHandler(flagClz:Class, flagName:String, func:Function, param:Array, priority:int) {
        this.func = func;
        this.param = param;
        this.priority = priority;
        this.flagClz = flagClz;
        this.flagName = flagName;
    }
    public var func:Function;
    public var param:Array;
    public var priority:int;
    public var flagClz:Class;
    public var flagName:String

}
