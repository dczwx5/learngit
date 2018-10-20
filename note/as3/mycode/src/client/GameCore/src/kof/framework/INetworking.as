//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

import kof.framework.network.INetworkMessageLinkedBuilder;
import kof.message.CAbstractPackMessage;

/**
 * Network facade.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface INetworking {

    /**
     * 开始为指定的<code>msgClass</code>构建绑定关系
     */
    function bind(msgClass:Class):INetworkMessageLinkedBuilder;

    /**
     * 发送数据到Server
     */
    function send(data:Object):Boolean;

    /**
     * Post数据到P2P网络
     */
    function post(data:Object):void;

    /**
     * 连接指定<code>host</code>, <code>port</code>的终端Server。
     */
    function connect(host:String, port:uint, onConnectOrError:Function = null):void;

    /**
     * 获取对应给定<code>tokenOrClass</code>继承与CAbstractPackMessage的消息体。
     */
    function getMessage(tokenOrClass:*, fail:Boolean = true):CAbstractPackMessage;

    /**
     * 移除指定的<code>msgClass</code>的所有绑定关系并释放
     */
    function unbind(msgClass:Class):void;

    function get isConnected() : Boolean;

    /**
     * Close the current connection from end-point peer.
     */
    function close() : void;

}
}
