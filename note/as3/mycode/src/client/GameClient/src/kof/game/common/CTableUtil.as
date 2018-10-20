//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/17.
 */
package kof.game.common {

import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;

public class CTableUtil {
    public function CTableUtil() {
    }

    /**
     * 按主键查找
     * @param system
     * @param tableName
     * @param primaryKey
     * @return
     */
    public function findByPrimaryKey(system:CAppSystem, tableName:String, primaryKey:*):*
    {
        if(system)
        {
            var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            if(dataBase)
            {
                var dataTable:IDataTable = dataBase.getTable(tableName);
                if(dataTable)
                {
                    return dataTable.findByPrimaryKey(primaryKey);
                }
            }
        }

        return null;
    }

    /**
     * 按字段名查找
     * @param system
     * @param tableName
     * @param propertyName
     * @param value
     * @return
     */
    public function findByProperty(system:CAppSystem, tableName:String, propertyName:String, value:*):Array
    {
        if(system)
        {
            var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            if(dataBase)
            {
                var dataTable:IDataTable = dataBase.getTable(tableName);
                if(dataTable)
                {
                    return dataTable.findByProperty(propertyName, value);
                }
            }
        }

        return null;
    }
}
}
