//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/26.
 */
package kof.game.pvp {

import QFLib.Interface.IUpdatable;

import kof.framework.CAbstractHandler;
import kof.message.Pvp.QueryRoomRespond;

public class CPvpManager extends CAbstractHandler implements IUpdatable {

    private var _pvpListDataArr : Array;

    public function CPvpManager() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
        _pvpListDataArr = null;
    }

    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        return ret;
    }

    public function update( delta : Number ) : void {
    }

    public function initialPvpListData(data:QueryRoomRespond):void {
        var arr:Array = data.roomInfos;
        _pvpListDataArr = new Array();

        for each (var obj:Object in arr){
            var _pvpListData:CPvpListData = new CPvpListData(obj);
            _pvpListDataArr.push(_pvpListData);
        }
        (system.getBean(CPvpListViewHandler) as CPvpListViewHandler).updateFun(_pvpListDataArr);
    }

    public function joinRoomData(data:Object):void{
        if(_pvpListDataArr == null)
        {
            _pvpListDataArr = new Array()
        }
        for each( var obj:Object in _pvpListDataArr)
        {
            if(obj.roomId == data.roomId)
            {
                var _obj:CPvpListData = new CPvpListData(data);
                obj.leftArr =_obj.leftArr;
                obj.rightArr =_obj.rightArr;
                (system.getBean(CPvpListViewHandler) as CPvpListViewHandler).updateFun(_pvpListDataArr);
                return;
            }
        }
    }

    public function createlPvpRoomData(data:Object):void{
        if(_pvpListDataArr == null)
        {
            _pvpListDataArr = new Array()
        }

        var _pvpListData:CPvpListData = new CPvpListData(data);
        _pvpListDataArr.unshift(_pvpListData);

        (system.getBean(CPvpListViewHandler) as CPvpListViewHandler).updateFun(_pvpListDataArr);

    }
}
}