//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.data {

import QFLib.Foundation.CMap;

import flash.utils.Dictionary;

import kof.framework.IDataTable;

/**
 * 数据表接口
 * 带查询缓存功能，通过字段查询
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CDataTable implements IDataTable {

    /** @private internal use only. */
    private var m_strName : String;

    /** @private */
    private var m_pTableMap : CMap;

    /** @private */
    private var m_pTableVector : Vector.<Object>;

    /** @private */
    private var m_pCache : Dictionary;

    /** @private */
    private var m_sIDkey : String;

    /** Creates a new CDataTable */
    public function CDataTable( strName : String, sIDkey : String = 'ID' ) {
        this.name = strName;
        this.m_sIDkey = sIDkey;
    }

    public function dispose() : void {
        if ( m_pTableMap ) {
            m_pTableMap.clear();
        }

        m_pTableMap = null;

        if ( m_pTableVector ) {
            m_pTableVector.splice( 0, m_pTableVector.length );
        }
        m_pTableVector = null;

        m_pCache = null;
    }

    final public function get isReady() : Boolean {
        return true;
    }

    /** Returns the name of the table. */
    final public function get name() : String {
        return m_strName;
    }

    final public function set name( value : String ) : void {
        m_strName = value;
    }

    /** @private internal use only */
    internal function initWithMap( pDataMap : CMap ) : Boolean {
        if ( !pDataMap )
            return false;

        this.m_pTableMap = pDataMap;
        return true;
    }

    public function get primaryKey() : String {
        return m_sIDkey;
    }

    public function get tableMap() : CMap {
        return m_pTableMap;
    }

    /**
     * 通过PrimaryKey查找对应行数据对象
     *
     * @param keyVal PrimaryKey value.
     * @return a object row data cast to an AS3 class.
     */
    public function findByPrimaryKey( keyVal : * ) : * {
        if ( null == keyVal || undefined == keyVal )
            return null;

        return m_pTableMap.find( keyVal );
    }

    public function findByProperty( sPropertyName : String, filterVal : *, cacheAsResult : Boolean = false ) : Array {
        if ( null == sPropertyName || !sPropertyName.length )
            return null;
        if ( null == filterVal || undefined == filterVal )
            return null;

        if ( m_pCache && (sPropertyName in m_pCache ) ) {
            if ( filterVal in m_pCache[ sPropertyName ] ) {
//                return m_pCache[ sPropertyName ][ filterVal ];
                var resultCache:CacheEntry = m_pCache[ sPropertyName ][ filterVal ] as CacheEntry;
                if(resultCache != null)
                {
                    return resultCache.theCacheResult;
                }
            }
        }

        var listResult : Array = [];

        for each ( var rowObj : Object in m_pTableMap ) {
            if ( rowObj.hasOwnProperty( sPropertyName ) && rowObj[ sPropertyName ] == filterVal )
                listResult.push( rowObj );
        }

        if ( listResult.length > 0 ) {
            if ( cacheAsResult ) {
                var pCacheEntry : CacheEntry = new CacheEntry( sPropertyName, filterVal, listResult );

                if ( !m_pCache )
                    m_pCache = new Dictionary();

                if ( !(sPropertyName in m_pCache) ) {
                    m_pCache[ sPropertyName ] = new Dictionary();
                }

                if ( !(filterVal in m_pCache[ sPropertyName ]) ) {
                    m_pCache[ sPropertyName ][ filterVal ] = pCacheEntry;
                }
            }

            return listResult;
        }
        return null;
    }

    protected function get tableVector() : Vector.<Object> {
        if ( !m_pTableVector && m_pTableMap ) {
            m_pTableVector = m_pTableMap.toVector();
        }

        return m_pTableVector;
    }

    public function first() : * {
        const rows : Vector.<Object> = this.tableVector;
        if ( rows && rows.length )
            return rows[ 0 ];
        return null;
    }

    public function last() : * {
        const rows : Vector.<Object> = this.tableVector;
        if ( rows && rows.length )
            return rows[ rows.length - 1 ];
        return null;
    }

    public function queryList( maxLimits : int = -1 ) : Array {
        return toArray( maxLimits );
    }

    public function toArray( maxLimits : int = -1 ) : Array {
        var rows : Array = [];
        this.m_pTableMap.toArray( rows );
        const nMaxRows : uint = rows ? rows.length : 0;
        if ( maxLimits <= 0 || nMaxRows <= maxLimits )
            return rows;

        if ( rows ) {
            return rows.slice( 0, maxLimits );
        }
        return null;
    }

    public function toVector( maxLimits : int = -1 ) : Vector.<Object> {
        const rows : Vector.<Object> = this.tableVector;
        const nMaxRows : uint = rows ? rows.length : 0;
        if ( maxLimits <= 0 || nMaxRows <= maxLimits )
            return rows;

        if ( rows ) {
            return rows.slice( 0, maxLimits );
        }
        return null;
    }
}
}

import QFLib.Interface.IDisposable;

class CacheEntry implements IDisposable {

    public var sPropertyName : String;
    public var theFilterVal : *;
    public var theCacheResult : Array;

    function CacheEntry( sPropertyName : String, theFilterVal : *, theCacheResult : Array ) {
        this.sPropertyName = sPropertyName;
        this.theFilterVal = theFilterVal;
        this.theCacheResult = theCacheResult;
    }

    public function dispose() : void {
        sPropertyName = theFilterVal = null;
        if ( theCacheResult && theCacheResult.length )
            theCacheResult.splice( 0, theCacheResult.length );
        theCacheResult = null;
    }
}
