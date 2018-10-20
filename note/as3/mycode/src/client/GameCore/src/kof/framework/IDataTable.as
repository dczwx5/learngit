//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IDataTable extends IDisposable {

    /**
     * Returns <code>true</code> if the IDatabase was ready to work.
     */
    function get isReady() : Boolean;

    function get name() : String;

    function get primaryKey() : String;

    function get tableMap() : CMap;

    function findByPrimaryKey( keyVal : * ) : *;

    function findByProperty( sPropertyName : String, filterVal : *, cacheAsResult : Boolean = false ) : Array;

    function first() : *;

    function last() : *;

    /** Sames as toArray. */
    function queryList( maxLimits : int = -1 ) : Array;

    function toArray( maxLimits : int = -1 ) : Array;

    function toVector( maxLimits : int = -1 ) : Vector.<Object>;



} // interface IDataTable

} // package kof.framework

// vim:ft=as3 tw=120

