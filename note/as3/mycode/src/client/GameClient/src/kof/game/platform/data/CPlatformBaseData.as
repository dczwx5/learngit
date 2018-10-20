//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/20.
 */
package kof.game.platform.data {

public class CPlatformBaseData {
    public function CPlatformBaseData() {

    }

    public virtual function updateData(data:Object) : void {
        // ...
    }

    private var _platform : String;// 运营商 : tx.4399 : CPlatformSignatures
    public function set platform(value : String):void
    {
        _platform = value;
    }
    public function get platform() : String
    {
        return _platform;
    }
    private var _pf : String;// 平台, 空间, QGame : EPlatformType
    public function set pf(value : String):void
    {
        _pf = value;
    }
    public function get pf() : String
    {
        return _pf;
    }
    private var _platformServerID : int;// 平台服务器id
    public function set platformServerID(value : int):void
    {
        _platformServerID = value;
    }
    public function get platformServerID() : int
    {
        return _platformServerID;
    }
    private var _account : String;// 平台账号id
    public function set account(value : String):void
    {
        _account = value;
    }
    public function get account() : String
    {
        return _account;
    }

}
}
