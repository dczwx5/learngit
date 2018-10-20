//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/9/04.
 */
package kof.game.gemenRecharge {

import flash.display.BitmapData;
import kof.framework.CAbstractHandler;

public class CGemenRechargeManager extends CAbstractHandler{

    private var _plat : String = "";//平台标记
    private var _serveID : int = 0;//平台服务器id
    private var _account : String = "";//平台账号id
    private var _qrBmpWX : BitmapData;
    private var _qrCodeWX : String = "";//请求地址
    public function CGemenRechargeManager() {
        super();
    }

    override public function dispose() : void
    {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        qrCodeWX = "http://pay.game2.cn/toMobileQrcode/op/getQrcode/t/ALIPAY_WXPAY/s/kof"
                + serveID + "/u/"
                + account + "/f/gindex/";
        return ret;

    }

    public function set plat( value : String ) : void {_plat = value;}
    public function get plat() : String {return _plat;}
    public function set serveID( value : int ) : void {_serveID = value;}
    public function get serveID() : int {return _serveID;}
    public function set account( value : String ) : void {_account = value;}
    public function get account() : String {return _account;}
    public function set qrBmpWX( value : BitmapData ) : void {_qrBmpWX = value;}
    public function get qrBmpWX() : BitmapData {return _qrBmpWX;}
    public function set qrCodeWX( value : String ) : void {_qrCodeWX = value;}
    public function get qrCodeWX() : String {return _qrCodeWX;}
}
}
