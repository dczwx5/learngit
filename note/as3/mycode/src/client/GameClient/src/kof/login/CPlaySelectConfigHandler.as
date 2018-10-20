//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/1.
 */
package kof.login {

import QFLib.Foundation.CURLJson;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.util.CAssertUtils;

/**
 * 选角页面的配置控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPlaySelectConfigHandler extends CAbstractHandler {

    private var m_pConfigData : Array;

    /**
     * Creates a new CPlaySelectConfigHandler.
     */
    public function CPlaySelectConfigHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pConfigData )
            m_pConfigData.splice( 0, m_pConfigData.length );
        m_pConfigData = null;
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.initConfigData();
        return ret;
    }

    protected function initConfigData() : Boolean {
        var pDB : IDatabase = system.stage.getBean( IDatabase );
        if ( pDB ) {
            var pTable : IDataTable = pDB.getTable( KOFTableConstants.ROLE_SELECT );
            CAssertUtils.assertNotNull( pTable, "Can not query data from \"" + KOFTableConstants.ROLE_SELECT + "\"" );

            m_pConfigData = pTable.toArray();
        }

        if ( !m_pConfigData ) {
            // load from single json data.
            var preventCache : String = "?_=" + Math.random();
            var file : CURLJson = new CURLJson( "assets/table/" + KOFTableConstants.ROLE_SELECT + ".json" + preventCache );
            file.startLoad( _onFinished );

            function _onFinished( cFile : CURLJson, idErr : int ) : void {
                if ( idErr == 0 ) { // success.
                    m_pConfigData = cFile.jsonObject as Array;

                    /* for each ( var obj : Object in m_pConfigData ) { */
                        /* if ( obj ) { */
                            /* LOG.logMsg( "RoleSelectItem: " + obj.ID + " => " + obj.RoleID + " - " + obj.RoleName ); */
                        /* } */
                    /* } */
                } else {
                    LOG.logErrorMsg( "Can not load \"" + KOFTableConstants.ROLE_SELECT + "\".json!!! [ERROR CODE: " + idErr + "]" );
                }

                makeStarted();
            }

            return false;
        }

        return true;
    }

    override protected virtual function onShutdown() : Boolean {
        return super.onShutdown();
    }

    override protected virtual function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );
    }

    public function get configData() : Array {
        return m_pConfigData;
    }

}
}
