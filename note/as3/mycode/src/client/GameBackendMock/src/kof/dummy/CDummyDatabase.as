//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.dummy {

import QFLib.Foundation.CURLJson;

import kof.data.CDatabaseSystem;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CDummyDatabase extends CAbstractHandler implements IDatabase {

    private var m_data : Object = {
        server_runtime : { // DummyServer specified
            pvp : false
        },
        account : {
            id : 1,
            name : "auto",
            token : null
        },
        role : {
            roleID : 10086,
            name : "Hero [Dummy]",
            prototypeID : 10,
            level : 1,
            curExp : 0,
            money : 0,
            diamond : 0,
            x : 1400,
            y : 600,
            dirX : 1,
            dirY : 0,
            line : 1,
            mapID : 83,
            mapType : 1,
            battleValue : 0,
            atk : 10000,
            moveSpeed : 500,
            hp : 10000,
            maxHp : 10000,
            mp : 1000,
            operateSide: 1,
            operateIndex: 1
        }
    };

    public function CDummyDatabase() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    public final function get data() : Object {
        return m_data;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            onInitialize();
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        super.onShutdown();
        return true;
    }

    private final function onInitialize() : void {
        // TODO: initialized dummy database.

        // Load configuration data from external-link.
        var preventCache : String = "?_=" + Math.random();
        var jsonFile : CURLJson = new CURLJson( "dummyData.json" + preventCache );
        jsonFile.startLoad( _onLoadFinished );

        function _onLoadFinished( f : CURLJson, idError : int ) : void {
            if ( idError == 0 ) {
                m_data = f.jsonObject;
            } else {
                // ignore.
            }

            f.dispose();
        }
    }

    internal function get database() : IDatabase {
        return system.getBean( IDatabase ) as IDatabase;
    }

    internal function get tableDataBase() : CDatabaseSystem{
        return system.getBean( CDatabaseSystem ) as CDatabaseSystem;
    }

    public function getDataBaseTable( sTableName : String ) : IDataTable
    {
        if( tableDataBase )
            return tableDataBase.getTable( sTableName );
        return null;
    }
    public function getTable( sTableName : String ) : IDataTable {
        if ( database )
            return database.getTable( sTableName );
        return null;
    }

    public function get isReady() : Boolean {
        return this.isStarted && (database ? database.isReady : true);
    }

    public function addValidator( pfnValidator : Function ) : void {
        database.addValidator( pfnValidator );
    }

    public function removeValidator( pfnValidator : Function ) : void {
        database.removeValidator( pfnValidator );
    }
}
}
