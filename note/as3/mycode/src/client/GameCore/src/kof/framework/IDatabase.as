//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import QFLib.Interface.IDisposable;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface  IDatabase extends IDisposable {

    /**
     * Retrieves a table instance by the specific name of the table.
     */
    function getTable( sTableName : String ) : IDataTable;

    /**
     * Returns <code>true</code> if the IDatabase was ready to work.
     */
    function get isReady() : Boolean;

    /**
     * Added a Validator function callback when the database was ready.
     *
     * @param pfnValidator Validator function callback.
     */
    function addValidator( pfnValidator : Function ) : void;

    /**
     * Removes a Validator function callback.
     *
     * @param pfnValidator Validator function callback.
     */
    function removeValidator( pfnValidator : Function ) : void;

} // interface IDatabase

} // package kof.framework

// vim:ft=as3 tw=120
