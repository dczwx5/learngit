//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.login {

/**
 * 登录数据
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLoginData {

    public function CLoginData() {
    }

    private var m_sAccount : String;

    final public function get account() : String {
        return m_sAccount;
    }

    final public function set account( value : String ) : void {
        m_sAccount = value;
    }

    private var m_sGatewayIP : String;

    final public function get gatewayIP() : String {
        return m_sGatewayIP;
    }

    final public function set gatewayIP( value : String ) : void {
        m_sGatewayIP = value;
    }

    private var m_nGatewayPort : uint;

    final public function get gatewayPort() : uint {
        return m_nGatewayPort;
    }

    final public function set gatewayPort( value : uint ) : void {
        m_nGatewayPort = value;
    }

    private var m_sLoginWay : String;

    final public function get loginWay() : String {
        return m_sLoginWay;
    }

    final public function set loginWay( value : String ) : void {
        m_sLoginWay = value;
    }

    private var m_sPlatform : String;

    final public function get platform() : String {
        return m_sPlatform;
    }

    final public function set platform( value : String ) : void {
        m_sPlatform = value;
    }

    private var m_sQueryString : String;

    final public function get queryString() : String {
        return m_sQueryString;
    }

    final public function set queryString( value : String ) : void {
        m_sQueryString = value;
    }

    private var m_sOS : String;

    final public function get os() : String {
        return m_sOS;
    }

    final public function set os( value : String ) : void {
        m_sOS = value;
    }

    private var m_sUserAgent : String;

    final public function get userAgent() : String {
        return m_sUserAgent;
    }

    final public function set userAgent( value : String ) : void {
        m_sUserAgent = value;
    }

    private var m_sFlashVersion : String;

    final public function get flashVersion() : String {
        return m_sFlashVersion;
    }

    final public function set flashVersion( value : String ) : void {
        m_sFlashVersion = value;
    }

    private var m_sDriverInfo : String;

    final public function get driverInfo() : String {
        return m_sDriverInfo;
    }

    final public function set driverInfo( value : String ) : void {
        m_sDriverInfo = value;
    }

    private var m_iPlatformServerID : int;

    final public function get platformServerID() : int {
        return m_iPlatformServerID;
    }

    final public function set platformServerID( value : int ) : void {
        m_iPlatformServerID = value;
    }

    private var m_iServerID : int;

    final public function get serverID() : int {
        return m_iServerID;
    }

    final public function set serverID( value : int ) : void {
        m_iServerID = value;
    }

    private var m_iWdUrl : String;

    final public function get wdUrl() : String {
        return m_iWdUrl;
    }

    final public function set wdUrl( value : String ) : void {
        m_iWdUrl = value;
    }

}
}

// vim:ft=as3 ts=4 sw=4 tw=120 expandtab
