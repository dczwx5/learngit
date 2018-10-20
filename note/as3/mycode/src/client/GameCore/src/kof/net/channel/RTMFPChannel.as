//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net.channel {

import flash.net.GroupSpecifier;
import flash.net.NetConnection;
import flash.net.NetGroup;
import flash.utils.ByteArray;

import io.asnetty.channel.AbstractChannel;
import io.asnetty.channel.ChannelOutboundBuffer;
import io.asnetty.channel.DefaultChannelConfig;
import io.asnetty.channel.DefaultChannelPromise;
import io.asnetty.channel.IChannelFuture;

/**
 *
 * @author Jeremy
 */
public class RTMFPChannel extends AbstractChannel {

    /** @private */
    private var _connectFuture:IChannelFuture;
    /** @private */
    private var _nc:NetConnection;
    /** @private */
    private var _group:NetGroup;
    /** @private */
    private var _postSeqNum:int;

    /** Creates a new RTMFPChannel. */
    public function RTMFPChannel() {
        super(new RTMFPChannelUnsafe(this), new DefaultChannelConfig(this));
        _connectFuture = new DefaultChannelPromise(this);

        _nc = new NetConnection();
    }

    public function get connection():NetConnection {
        return _nc;
    }

    public function get group():NetGroup {
        return _group;
    }

    public function joinGroup(group:GroupSpecifier):NetGroup {
        if (!group)
            return null;
        _group = (unsafe as RTMFPChannelUnsafe).doJoinGroup(group);
        return _group;
    }

    override public function get isActive():Boolean {
        return _nc && _nc.connected;
    }

    override public function get isOpen():Boolean {
        return _nc && _nc.connected;
    }

    public function get connectFuture():IChannelFuture {
        return _connectFuture;
    }

    override protected function doWrite(outboundBuffer:ChannelOutboundBuffer):void {
        super.doWrite(outboundBuffer);
    }

    override protected function doWriteBytes(bytes:ByteArray):int {
        if (bytes.bytesAvailable == 0 || !_nc.connected)
            return 0;

        var checkpoint:int = bytes.bytesAvailable;
        var message:Object = {};
//        message.text = bytes.readUTFBytes(bytes.bytesAvailable);
        message.text = bytes;
        message.sender = _group.convertPeerIDToGroupAddress(connection.nearID);
        message.sequenceID = _postSeqNum++;
        message.userName = connection.nearID;

        _group.post(message);
        // _group.writeBytes(bytes);
        bytes.position = checkpoint;
        return checkpoint;
    }

    public function toString():String {
        return "RTMFPChannel#" + id;
    }

}
}

import QFLib.Foundation;

import flash.events.AsyncErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.net.GroupSpecifier;
import flash.net.NetConnection;
import flash.net.NetGroup;
import flash.utils.ByteArray;

import io.asnetty.channel.AbstractUnsafe;
import io.asnetty.channel.IChannelPromise;

import kof.net.channel.RTMFPChannel;

/**
 * @author Jeremy
 */
final class RTMFPChannelUnsafe extends AbstractUnsafe {

    /** @private */
    private var _readyPromise:IChannelPromise;

    function RTMFPChannelUnsafe(channel:RTMFPChannel) {
        super(channel);
    }

    [Inline]
    final protected function get dh():RTMFPChannel {
        return super.channel as RTMFPChannel;
    }

    [Inline]
    final public function get connection():NetConnection {
        return dh.connection;
    }

    override public function connect(host:String, port:int, promise:IChannelPromise):void {
        var connection:NetConnection = this.connection;

        connection.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEventHandler);
        connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _connection_securityErrorEventHandler, false, 0, true);
        connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _connection_asyncErrorEventHandler, false, 0, true);

        var remotePeer:String = "";
        if (host && "" != host) {
            remotePeer = "//" + host + ":" + port.toString();
        }

        _readyPromise = promise;
        connection.connect("rtmfp:" + remotePeer);
    }

    private function _connection_securityErrorEventHandler(event:SecurityErrorEvent):void {
        if (_readyPromise) {
            _readyPromise.tryFailure(new SecurityError(event.text, event.errorID));
        }
        _readyPromise = null;
    }

    private function _connection_asyncErrorEventHandler(event:AsyncErrorEvent):void {
        if (_readyPromise) {
            _readyPromise.tryFailure(event.error);
        }
        _readyPromise = null;
    }

    private function _netStatusEventHandler(event:NetStatusEvent):void {
        switch (event.info.code) {
            case "NetConnection.Connect.Success":
                Foundation.Log.logTraceMsg("NetConnection connected.");
                channel.pipeline.fireChannelActive();
                break;
            case "NetGroup.Connect.Success":
                // Set connected, setup group.
                Foundation.Log.logTraceMsg("NetGroup connected.");
                // be ready.
                if (_readyPromise)
                    _readyPromise.trySuccess();
                _readyPromise = null;
                break;
            case "NetGroup.Connect.Failed":
                Foundation.Log.logTraceMsg("NetGroup failed.");
                channel.pipeline.fireErrorCaught(new SecurityError("Peer assisted network disallowed."));
                break;
            case "NetGroup.Connect.Rejected":
                if (_readyPromise)
                    _readyPromise.tryFailure(new SecurityError("Peer assisted network be rejected."));
                _readyPromise = null;
                break;
            case "NetGroup.Posting.Notify":
                // Message received.
                // Foundation.Log.logMsg("NetGroup receieved: " + event.info.message);
                const message:Object = event.info.message;
                const bytes:ByteArray = message.text as ByteArray;
                if (bytes) {
                    bytes.position = 0;
                    channel.pipeline.fireChannelRead(bytes);
                    channel.pipeline.fireChannelReadComplete();
                    bytes.clear();
                }
                break;
            case "NetGroup.SendTo.Notify":
                Foundation.Log.logTraceMsg("NetGroup send: " + event.info.message);
                break;
            case "NetGroup.Neighbor.Connect":
                Foundation.Log.logTraceMsg("Neighbor Connect");
                break;
            case "NetGroup.Neighbor.Disconnect":
                // ignore.
                Foundation.Log.logTraceMsg("Neighbor Disconnect");
                break;
            default:
                trace("Unhandled NetStatus: ", event.info.code);
                break;
        }
    }

    public function doJoinGroup(groupSpec:GroupSpecifier):NetGroup {
        var group:NetGroup = new NetGroup(connection, groupSpec.groupspecWithAuthorizations());
        group.addEventListener(NetStatusEvent.NET_STATUS, _netStatusEventHandler);
        return group;
    }

}
