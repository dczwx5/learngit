//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/8/3.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.table.TowerBuff;

public class CCultivateBuffData extends CObjectData {
    public function CCultivateBuffData() {

    }

    public function get ID() : int { return _data[_ID]; } // buff id

    public function isDataValid() : Boolean {
        return ID > 0;
    }

    public function get name() : String {
        var buffRecord:TowerBuff = this.buffRecord;
        if (!buffRecord) return "";

        return buffRecord.Name;
    }

    public function get percent() : String {
        var buffRecord:TowerBuff = this.buffRecord;
        if (!buffRecord) return "";

        return buffRecord.Rate;
    }

    public function get desc() : String {
        var buffRecord:TowerBuff = this.buffRecord;
        if (!buffRecord) return "";

        return buffRecord.Desc;
    }
    public function get icon() : String {
        var buffRecord:TowerBuff = this.buffRecord;
        if (!buffRecord) return "";

        return buffRecord.Icon + ".png";
    }

    public function get buffRecord() : TowerBuff {
        var table:IDataTable = buffTable;
        if (!table) return null;
        if (ID <= 0) return null;

        var record:TowerBuff = table.findByPrimaryKey(ID) as TowerBuff;
        return record;
    }

    public function get buffTable() : IDataTable {
        return _databaseSystem.getTable(KOFTableConstants.CULITIVATE_BUFF);
    }

    public static const _ID:String = "ID";
}
}
