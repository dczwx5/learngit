//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/5/22.
//----------------------------------------------------------------------

package QFLib.Framework.CharacterExtData {

import QFLib.Foundation;
import QFLib.Math.CVector3;

public class CCharacterCollisionBoundInfo {
    public function dispose( ) : void {

        m_v3Position = null ;
        m_v3Size = null ;
    }

    public function loadFromData(data : Object) : void
    {
        if(null != data[ "nType" ]){
            m_nType = data[ "nType" ];
        }

        if(null != data[ "fDuaration" ]){
            m_fDuaration = data[ "fDuaration" ];
        }

        if( null != data["nPart"] )
        {
            m_nPart = data["nPart"];
        }

        if( null != data["hitEvent"])
        {
            m_sHitEvent = data["hitEvent"];
        }

        var v3Str : String ;
        var v3Axis : Array ;

        if(null != data[ "v3Position" ])
        {
            v3Str = data[ "v3Position" ];
            v3Axis = v3Str.split( ",");

            if(null != v3Axis && 3 == v3Axis.length) {
                m_v3Position = new CVector3(v3Axis[0], v3Axis[1], v3Axis[2]);
            }
            else
            {
                Foundation.Log.logWarningMsg( "no data for Collision Position " );
            }
        }

        if(null != data[ "v3Size" ])
        {
            v3Str = data[ "v3Size" ] ;
            v3Axis = v3Str.split( ",") ;

            if( null != v3Axis && 3 == v3Axis.length){
                m_v3Size = new CVector3( v3Axis[0], v3Axis[1], v3Axis[2] ) ;
            }
            else
            {
                Foundation.Log.logWarningMsg("no data for Collision Size");
            }
        }
    }


    public function get nType( ) : int
    {
        return m_nType ;
    }

    public function get fDuaration( ) : Number
    {
        return m_fDuaration ;
    }

    final public function get v3Size( ) : CVector3 {

        return m_v3Size ;
    }

    final public function get v3Position( ) : CVector3 {

        return m_v3Position ;
    }

    public function get sHitEvent() : String {
        return m_sHitEvent;
    }

    private var m_nType : int ;
    private var m_fDuaration : Number ;
    private var m_v3Position : CVector3 ;
    private var m_v3Size : CVector3;
    private var m_nPart : int ;
    private var m_sHitEvent : String;

}
}
