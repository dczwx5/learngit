//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/8/6.
 */
package kof.game.platform.xiyou {

import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.PlatformReward.QrcodeXiyouRequest;
import kof.message.PlatformReward.QrcodeXiyouResponse;

public class CXiyouDataManager extends CNetHandlerImp
{
    private var _qrCodeZFB : String = "";//支付宝
    private var _qrCodeWX : String = "";//微信
    private var _qrBmpZFB : BitmapData;
    private var _qrBmpWX : BitmapData;
    private var _callBackWX : Function;
    private var _callBackZFB : Function;
    public function CXiyouDataManager()
    {
        super();
    }
    public override function dispose() : void
    {
        super.dispose();
    }

    override protected function onSetup() : Boolean
    {
        super.onSetup();

        bind( QrcodeXiyouResponse, _onQrcodeXiyouResponse);

        return true;
    }
    /**
     * 请求西游平台二维码
     * Type 1微信2支付宝
     */
    public function onQrcodeXiyouRequest(type : int):void
    {
        var request:QrcodeXiyouRequest = new QrcodeXiyouRequest();
        request.type = type;
        networking.post(request);
    }
    private function _onQrcodeXiyouResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;
        var response : QrcodeXiyouResponse = message as QrcodeXiyouResponse;
        if(response)
        {
            if(response.type == 1)
            {
                _qrCodeWX = response.imgUrl;
            }
            else
            {
                _qrCodeZFB = response.imgUrl;
            }
            getQrCodeDataByTyep(response.type);//请求回来就自动下载缓存起来
        }
    }

    /*
    * 根据类型下载指定链接的二维码图片
    * */
    public function getQrCodeDataByTyep(type : int) : void
    {
        if(type == 1)
        {
            urlGetWXCode();
        }
        else
        {
            urlGetZFBCode();
        }
    }
    /*
     * 下载微信二维码
     * */
    public function urlGetWXCode() : void
    {
        try
        {
            var urlRequest : URLRequest = new URLRequest(_qrCodeWX);
            var urlLoaderWX : URLLoader = new URLLoader();
            urlLoaderWX.dataFormat = URLLoaderDataFormat.BINARY;
            urlLoaderWX.addEventListener(Event.COMPLETE,completeHandlerWX);
            urlLoaderWX.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            urlLoaderWX.load(urlRequest);
            App.log.debug("wx_qrcode start load: " + _qrCodeWX);
        }
        catch (e : Error)
        {
            App.log.warn("wx_qrcode request failed，error："+ e.message);
            trace("URL-GET请求失败，error："+ e.message);
        }
    }

    private function completeHandlerWX(e : Event) : void
    {
        var m_content : ByteArray = e.target.data as ByteArray;
        var _loader : Loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
        _loader.loadBytes(m_content);
        function completeHandler(e:Event):void
        {
            App.log.debug("wx_qrcode load complete: "+ _loader.width + "*" + _loader.height );
            _qrBmpWX = new BitmapData( _loader.width, _loader.height,true,0);
            _qrBmpWX.draw( _loader );
            _loader.removeEventListener(Event.COMPLETE,completeHandler);
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,completeHandlerWX);
            _loader = null;
            if(_callBackWX)
                _callBackWX();
        }
    }

    /*
     * 下载支付宝二维码
     * */
    public function urlGetZFBCode() : void
    {
        try
        {
            var urlRequest : URLRequest = new URLRequest(_qrCodeZFB);
            var urlLoaderZFB : URLLoader = new URLLoader();
            urlLoaderZFB.dataFormat = URLLoaderDataFormat.BINARY;
            urlLoaderZFB.addEventListener(Event.COMPLETE,completeHandlerZFB);
            urlLoaderZFB.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            urlLoaderZFB.load(urlRequest);
            App.log.debug("zfb_qrcode start load: " + _qrCodeZFB);
        }
        catch (e : Error)
        {
            App.log.warn("zfb_qrcode load failed，error："+ e.message);
            trace("URL-GET请求失败，error："+ e.message);
        }
    }
    private function completeHandlerZFB(e:Event):void
    {
        var m_content : ByteArray = e.target.data as ByteArray;
        var _loader : Loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
        _loader.loadBytes(m_content);
        function completeHandler(e:Event):void
        {
            App.log.debug("zfb_qrcode load complete："+ _loader.width + "*" + _loader.height );
            _qrBmpZFB = new BitmapData( _loader.width, _loader.height, true, 0 );
            _qrBmpZFB.draw( _loader );
            _loader.removeEventListener( Event.COMPLETE, completeHandler );
            _loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, completeHandlerZFB );
            _loader = null;
            if(_callBackZFB)
                _callBackZFB();
        }
    }
    private function progressHandler(e : ProgressEvent) : void
    {
        var i : Number = Math.round( e.bytesLoaded / e.bytesTotal * 100);
        trace("已加载字节" + i);
    }

    /**
     * 返回微信二维码图片bitmapdata
     */
    public function get qrBmpWX() : BitmapData
    {
        return _qrBmpWX;
    }
    /**
     * 返回支付=宝二维码图片bitmapdata
     */
    public function get qrBmpZFB() : BitmapData
    {
        return _qrBmpZFB;
    }

    /**
     *
     * 二维码加载成功调用
     */
    public function loadCompleteCallBackWX( fun : Function ) : void
    {
        _callBackWX = fun;
    }
    public function loadCompleteCallBackZFB( fun : Function ) : void
    {
        _callBackZFB = fun;
    }
}
}
