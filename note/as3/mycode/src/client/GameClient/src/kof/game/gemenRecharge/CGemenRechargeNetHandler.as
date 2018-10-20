//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/09/03.
 */
package kof.game.gemenRecharge {

import flash.display.BitmapData;
import flash.display.Loader;
import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import kof.game.common.system.CNetHandlerImp;

/**
 * 请求处理
 * */
public class CGemenRechargeNetHandler extends CNetHandlerImp {


    private var _callBackWX : Function;
    public function CGemenRechargeNetHandler() {
        super();
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        return ret;
    }
    //请求二维码
    /*
     * 下载微信二维码
     * */
    public function urlGetWXCode() : void
    {
        try
        {
            var urlRequest : URLRequest = new URLRequest(_manager.qrCodeWX);
            var urlLoaderWX : URLLoader = new URLLoader();
            urlLoaderWX.dataFormat = URLLoaderDataFormat.BINARY;
            urlLoaderWX.addEventListener(Event.COMPLETE,completeHandlerWX);
            urlLoaderWX.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            urlLoaderWX.addEventListener(IOErrorEvent.IO_ERROR, printError);
            urlLoaderWX.load(urlRequest);
            App.log.debug("wx_qrcode start load: " + _manager.qrCodeWX);
        }
        catch (e : IOError)
        {
            App.log.warn("wx_qrcode request failed，error："+ e.message);
        }
    }

    private function completeHandlerWX(e : Event) : void
    {
        var m_content : ByteArray = e.target.data as ByteArray;
        var _loader : Loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
        function completeHandler(e:Event):void
        {
            App.log.debug("wx_qrcode load complete: "+ _loader.width + "*" + _loader.height );

            var bmd : BitmapData = new BitmapData( _loader.width, _loader.height,true,0);
            bmd.draw( _loader );
            _manager.qrBmpWX = bmd;
            _loader.removeEventListener(Event.COMPLETE,completeHandler);
            _loader = null;
            if(_callBackWX)
                _callBackWX();
        }
        if(!m_content)
        {
            App.log.warn( "wx_qrcode request failed，error：返回ByteArray为空" );
            return;
        }
        _loader.loadBytes(m_content);

    }

    private function progressHandler(e : ProgressEvent) : void
    {
        var i : Number = Math.round( e.bytesLoaded / e.bytesTotal * 100);
        App.log.debug("已加载字节" + i);
    }

    private function printError(e:IOErrorEvent) : void
    {
        App.log.warn("wx_qrcode request failed，error："+ e.text);
    }

    private function get _system() : CGemenRechargeSystem
    {
        return system as CGemenRechargeSystem;
    }
    private function get _manager() : CGemenRechargeManager
    {
        return _system.getBean( CGemenRechargeManager) as CGemenRechargeManager;
    }
}
}
