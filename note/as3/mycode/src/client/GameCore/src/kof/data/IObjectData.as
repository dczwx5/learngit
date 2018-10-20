//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/21.
 */
package kof.data {

import QFLib.Foundation.CMap;

import kof.framework.IDatabase;

public interface IObjectData {
    function updateDataByData(data:Object) : void;
    function set databaseSystem(database:IDatabase) : void;
    function set rootData(data:IObjectData) : void;
    function get data() : CMap;

}
}
