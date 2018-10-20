//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.config {

import kof.framework.CAppSystem;
import kof.framework.IConfiguration;

/**
 * KOF配置项
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKOFConfigSystem extends CAppSystem {

    private var m_pConfig : IConfiguration;

    public static var GMSwitch : Boolean;

    public function CKOFConfigSystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        m_pConfig = null;
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        m_pConfig = this.stage.getBean( IConfiguration ) as IConfiguration;
        if ( m_pConfig ) {
            parseConfig( m_pConfig );
        }

        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        return ret;
    }

    public function get configuration() : IConfiguration {
        return m_pConfig;
    }

    protected function parseConfig( config : IConfiguration ) : void {
        if ( !config )
            return;

        var pConfigXML : XML = config.getXML( 'ConfigRaw' );
        if ( pConfigXML ) {
            config.setConfig( 'networkLog', Boolean( int( pConfigXML..networkLog ) ) );
            config.setConfig( 'networkSyncInterval', int( pConfigXML..networkSyncInterval ) );
            config.setConfig( 'enableGM', Boolean( int( pConfigXML..enableGM ) ) );
            config.setConfig( 'GMAppURL', String( pConfigXML..GMAppURL ));
            config.setConfig( 'isEncryption', Boolean( int( pConfigXML..isEncryption ) ) );
            config.setConfig( 'isConfigEncryption', Boolean( int( pConfigXML..isConfigEncryption ) ) );
            config.setConfig( 'enableProtocolEncryption', Boolean( int( pConfigXML..enableProtocolEncryption ) ) );
            config.setConfig( 'language', Boolean( int( pConfigXML..language ) ) );
            config.setConfig( 'logLevel', String( pConfigXML..logLevel ) );
            config.setConfig( 'popUpLogLevel', String( pConfigXML..popUpLogLevel ) );
            config.setConfig( 'gameNotice', String( pConfigXML..gameNotice ) );
            config.setConfig( 'gameHomepage', String( pConfigXML..gameHomepage ) );
            config.setConfig( 'gameForum', String( pConfigXML..gameForum ) );
            config.setConfig( 'loadBytes', int( pConfigXML..loadBytes ) );
            config.setConfig( 'enableQsonLoading', Boolean( int( pConfigXML..enableQsonLoading ) ) );
            config.setConfig( 'enablePackedQsonLoading', Boolean(int( pConfigXML..enablePackedQsonLoading ) ) );
            config.setConfig( 'enableFileExistencePreChecking', Boolean(int( pConfigXML..enableFileExistencePreChecking ) ) );
            config.setConfig( 'fileCheckLevel', int( pConfigXML..fileCheckLevel ) );
            config.setConfig( 'videoURL',String(pConfigXML..videoURL));
        }
    }
}
}
