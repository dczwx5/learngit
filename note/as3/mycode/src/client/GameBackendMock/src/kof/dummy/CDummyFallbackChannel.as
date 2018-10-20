//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.dummy {

import flash.utils.ByteArray;

import io.asnetty.channel.AbstractChannel;
import io.asnetty.channel.DefaultChannelConfig;

/**
 * 虚拟Socket机制的Fallback到Client的<code>IChannel</code>实现。
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CDummyFallbackChannel extends AbstractChannel {

    /**
     * Creates a new CDummyFallbackChannel.
     */
    public function CDummyFallbackChannel() {
        super(new CDummyFallbackUnsafe(this), new DefaultChannelConfig(this));

        CDummyFallbackMediator.instance.registerChannel(this);
    }

    private var m_active:Boolean;

    public function setActive():void {
        m_active = true;
    }

    public function setClosed():void {
        m_active = false;
    }

    override public function get isActive():Boolean {
        return m_active;
    }

    override public function get isOpen():Boolean {
        return m_active;
    }

    override protected function doWriteBytes(bytes:ByteArray):int {
        var ret:int = CDummyFallbackMediator.instance.appendBytes(bytes, this);
        bytes.position = bytes.bytesAvailable;
        return ret;
    }

    public function socketData(buf:ByteArray):void {
        this.pipeline.fireChannelRead(buf);
        this.pipeline.fireChannelReadComplete();
    }

    public function toString():String {
        return "DummyFallbackChannel#" + id;
    }
}
}

import QFLib.Interface.IDisposable;

import flash.display.Shape;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import io.asnetty.channel.AbstractUnsafe;
import io.asnetty.channel.IChannelPromise;

import kof.dummy.CDummyFallbackChannel;

class CDummyFallbackUnsafe extends AbstractUnsafe {

    private var m_channel:CDummyFallbackChannel;

    function CDummyFallbackUnsafe(channel:CDummyFallbackChannel) {
        super(channel);

        this.m_channel = channel;
    }

    override public function connect(host:String, port:int, promise:IChannelPromise):void {
        CDummyFallbackMediator.instance.insertCallback(finishConnect, host, port, promise);
    }

    public function finishConnect(host:String, port:int, promise:IChannelPromise):void {
        m_channel.setActive();
        channel.pipeline.fireChannelActive();
        promise.trySuccess();
    }

    override protected function doDisconnect():void {
        super.doDisconnect();
    }

    override protected virtual function doClose():void {
        super.doClose();
        m_channel.setClosed();
    }

    override protected virtual function doBeginRead():void {
        super.doBeginRead();
    }

}

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class CDummyFallbackMediator extends EventDispatcher implements IDisposable {

    private static var s_instance:CDummyFallbackMediator;

    public static function get instance():CDummyFallbackMediator {
        s_instance = s_instance || new CDummyFallbackMediator();
        return s_instance;
    }

    private var m_calls:Dictionary;
    private var m_channels:Dictionary;

    /**
     * Creates a new CDummyFallbackMediator
     */
    function CDummyFallbackMediator() {
        super();
        m_calls = new Dictionary();
        m_channels = new Dictionary(true);
    }

    public function registerChannel(channel:CDummyFallbackChannel):void {
        m_channels[channel] = new ByteArray();
    }

    public function deregisterChannel(channel:CDummyFallbackChannel):void {
        if (channel in m_channels) {
            var bs:ByteArray = m_channels[channel] as ByteArray;
            delete m_channels[channel];

            bs.clear();
        }
    }

    public function insertCallback(call:Function, ...args):void {
        if (m_calls[call] == null) {
            m_calls[call] = args || [];
        }
    }

    private function invokeCallback(func:Function):void {
        if (func != null && m_calls[func] != null) {
            var arg:Array = m_calls[func];
            delete m_calls[func];
            func.apply(null, arg);
        }
    }

    public function onTick(event:Event):void {
        for (var func:* in m_calls) {
            invokeCallback(func);
        }

        for (var ch:CDummyFallbackChannel in m_channels) {
            if (ch) {
                var data:ByteArray = m_channels[ch] as ByteArray;
                if (data) {
                    data.position = 0;
                    if (data.bytesAvailable) {
                        ch.socketData(data);

                        data.clear();
                        data.position = 0;
                    }
                }
            }
        }
    }

    public function dispose():void {
        m_calls = null;
    }

    public function appendBytes(data:ByteArray, channel:CDummyFallbackChannel):int {
        var ret:int = data.bytesAvailable;

        for (var ch:CDummyFallbackChannel in m_channels) {
            if (ch == channel)
                continue;

            var buffer:ByteArray = m_channels[ch] as ByteArray;
            if (!buffer)
                return 0;

            buffer.writeBytes(data); // append to buffer.
        }

        return ret;
    }

}

{

    var tickRunner:Shape = new Shape();
    tickRunner.addEventListener(Event.ENTER_FRAME, CDummyFallbackMediator.instance.onTick, false, 0, true);

}
