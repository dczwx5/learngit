//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import kof.framework.IConfiguration;
import kof.game.core.CGameComponent;
import kof.util.CAssertUtils;

/**
 * ECS中的配置代理组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CKOFConfiguration extends CGameComponent implements IConfiguration {

    private var m_pDelegate : IConfiguration;

    public function CKOFConfiguration( pDelegate : IConfiguration ) {
        super();
        m_pDelegate = pDelegate;
    }

    [Inline]
    final public function get configuration() : IConfiguration {
        return m_pDelegate;
    }

    public function getRaw( key : String, defaultVal : * = undefined ) : * {
        return m_pDelegate ? m_pDelegate.getRaw(key, defaultVal) : defaultVal;
    }

    public function getInt( key : String, defaultVal : int = 0 ) : int {
        return m_pDelegate ? m_pDelegate.getInt( key, defaultVal) : defaultVal;
    }

    public function getString( key : String, defaultVal : String = null ) : String {
        return m_pDelegate ? m_pDelegate.getString( key, defaultVal ) : defaultVal;
    }

    public function getBoolean( key : String, defaultVal : Boolean = false ) : Boolean {
        return m_pDelegate ? m_pDelegate.getBoolean( key, defaultVal ) : defaultVal;
    }

    public function getNumber( key : String, defaultVal : Number = NaN ) : Number {
        return m_pDelegate ? m_pDelegate.getNumber( key, defaultVal ) : defaultVal;
    }

    public function getXML( key : String, defaultVal : XML = null ) : XML {
        return m_pDelegate ? m_pDelegate.getXML( key, defaultVal ) : defaultVal;
    }

    public function getJSONObject( key : String, defaultVal : Object = null ) : Object {
        return m_pDelegate ? m_pDelegate.getJSONObject( key, defaultVal ) : defaultVal;
    }

    public function setConfig( key : String, value : * ) : * {
        CAssertUtils.assertNotNull( m_pDelegate, "Null configuration delegated!");
        return m_pDelegate.setConfig( key, value );
    }

    public function addUpdateListener( func : Function ) : void {
        CAssertUtils.assertNotNull( m_pDelegate, "Null configuration delegated!");
        m_pDelegate.addUpdateListener( func );
    }

    public function removeUpdateListener( func : Function ) : Boolean {
        if ( m_pDelegate )
            return m_pDelegate.removeUpdateListener( func );
        return false;
    }

    public function addItemUpdateListener( key : String, func : Function ) : void {
        CAssertUtils.assertNotNull( m_pDelegate, "Null configuration delegated!");
        m_pDelegate.addItemUpdateListener( key, func );
    }

    public function removeItemUpdateListener( key : String, func : Function = null ) : Boolean {
        if ( m_pDelegate )
            return m_pDelegate.removeItemUpdateListener( key, func );
        return false;
    }
}
}
