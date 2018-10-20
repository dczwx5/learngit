//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/25.
 */
package kof.game.talent.talentFacade.talentSystem.data {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.table.TalentSoulFurnace;

public class CTalentMeltingData extends CObjectData {

    private var m_pConfigData:TalentSoulFurnace;

    public static const Type:String = "type";// 熔炉类型
    public static const Level:String = "level";// 熔炉等级
    public static const Exp:String = "exp";// 熔炉经验值

    public function CTalentMeltingData()
    {
        super();
    }

    public function get type() : int { return _data[Type]; }
    public function get level() : int { return _data[Level]; }
    public function get exp() : int { return _data[Exp]; }

    public function set type(value:int):void
    {
        _data[Type] = value;
    }

    public function set level(value:int):void
    {
        _data[Level] = value;
    }

    public function set exp(value:int):void
    {
        _data[Exp] = value;
    }

    public function get configData():TalentSoulFurnace
    {
//        if(m_pConfigData == null)
//        {
            var dataTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.TalentSoulFurnace);
            var arr:Array = dataTable.findByProperty("type", type);
            if(arr && arr.length)
            {
                for each(var item:TalentSoulFurnace in arr)
                {
                    if(item.returnLevel == level)
                    {
                        m_pConfigData = item;
                        break;
                    }
                }
            }
//        }

        return m_pConfigData;
    }

    public function get nextConfigData():TalentSoulFurnace
    {
        var dataTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.TalentSoulFurnace);
        var arr:Array = dataTable.findByProperty("type", type);
        if(arr && arr.length)
        {
            for each(var item:TalentSoulFurnace in arr)
            {
                if(item.returnLevel == level + 1)
                {
                    return item;
                }
            }
        }

        return null;
    }
}
}
