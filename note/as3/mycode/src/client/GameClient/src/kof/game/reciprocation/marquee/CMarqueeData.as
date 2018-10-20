//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.reciprocation.marquee {

import flash.utils.Dictionary;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CMarqueeData {

    private var m_pData : Array;
    private var m_dicUniqueTxt : Dictionary;

    public function CMarqueeData() {
        super();
        m_pData = [];
        m_dicUniqueTxt = new Dictionary();
    }

    public function dispose() : void {
        if ( m_pData )
            m_pData.splice( 0, m_pData.length );
        m_pData = null;
        m_dicUniqueTxt = null;
    }

    public function get size() : uint {
        return m_pData.length;
    }

    public function push( data : String, showTime:int = 5 ) : void {
        if ( data in m_dicUniqueTxt )
            return;
        m_dicUniqueTxt[ data ] = true;
        m_pData.push( {content:data,time:showTime} );
    }

    public function next() : Object {
        return m_pData.length ? m_pData[ 0 ] : null;
    }

    public function shift() : Object {
        if ( next() ) {
            var ret : Object = m_pData[ 0 ];
            m_pData = m_pData.slice( 1 );
            delete m_dicUniqueTxt[ ret.content ];
            return ret;
        }
        return null;
    }

}
}
