//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/6/13.
 */
package kof.game.superVip {
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.table.OperatorConfig;
import kof.table.SuperVipConfig;

public class CSuperVipManager extends CAbstractHandler {
    public function CSuperVipManager() {
        super();
    }
    private var _plat : String = "";//平台标记
    private var _serveID : int;//平台服务器id
    private var _cofigTable : IDataTable;
    private var _operatorTable : IDataTable;

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _cofigTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.SUPERVIPCONFIG );
        _operatorTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.OPERATORCONFIG );
        return ret;
    }
    public function getConfigByPlatform() : SuperVipConfig
    {
        var temp : SuperVipConfig;
        for each (var item : SuperVipConfig in _cofigTable.tableMap)
        {
            if(item.platform == plat && item.serverId == serveID)
            {
                return item;
            }
            if(item.platform == plat && item.serverId == 0)
            {
                temp = item;//如果没有平台服务器id配置，使用默认值
            }
        }
        return temp;
    }

    public function getOperatorByID(ID:int):OperatorConfig
    {
        for each (var item : OperatorConfig in _operatorTable.tableMap)
        {
            if(item.ID == ID)
            {
                return item;
            }
        }
        return null;
    }
    public function set plat( value : String ) : void
    {
        _plat = value;
    }
    public function get plat() : String
    {
        return _plat;
    }
    public function set serveID( value : int ) : void
    {
        _serveID = value;
    }
    public function get serveID() : int
    {
        return _serveID;
    }

}
}
