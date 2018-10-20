//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.dummy {

import QFLib.Application.Component.CLifeCycleBeanEvent;
import QFLib.Application.Component.ILifeCycleListener;
import QFLib.Interface.IUpdatable;

import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import io.asnetty.bootstrap.Bootstrap;
import io.asnetty.channel.ChannelFutureEvent;
import io.asnetty.channel.ChannelInitializer;
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.channel.IChannelInboundHandler;
import io.asnetty.handler.codec.LengthFieldBasedFrameDecoder;
import io.asnetty.handler.codec.LengthFieldPrepender;
import io.asnetty.handler.logging.LoggingHandler;

import kof.dummy.handler.CDummyFightHandler;

import kof.dummy.handler.CDummyLoginHandler;
import kof.dummy.handler.CDummyMapInstanceHandler;
import kof.framework.CAppSystem;
import kof.framework.IDatabase;
import kof.message.CAbstractPackMessage;
import kof.message.kof_message;
import kof.net.codec.CIdCategoryMsgPackDecoder;
import kof.net.codec.CIdCategoryMsgPackEncoder;

/**
 * CDummyServer模拟Server的简易功能，辅助客户端的单机实现
 *
 * 实现与ILifeCycleListener接口，所以当CDummyServer被添加到CAppStage中会被作为Listener监听CAppStage下级的CAppSystem的
 * 添加与移除，这里需要用到CDatabaseSystem提供数据。
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CDummyServer extends CAppSystem implements IChannelInboundHandler, IUpdatable, ILifeCycleListener {

    /** @private */
    private var m_bootstrap : Bootstrap;
    /** @private */
    private var m_channel : IChannel;
    /** @private */
    private var m_messageBindings : Dictionary;
    /** @private */
    private var m_channelWriteAmount : int;

    /**
     * Creates a new CDummyServer.
     */
    public function CDummyServer() {
        super();

        attachEventListeners();
    }

    override public function dispose() : void {
        // super.dispose();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( !m_bootstrap && !m_channel ) {
            const thisDummyServer : CDummyServer = this;
            m_bootstrap = new Bootstrap();
            var future : IChannelFuture = m_bootstrap.channel( CDummyFallbackChannel ).handler( new ChannelInitializer( function ( ch : IChannel ) : void {
                ch.pipeline.addLast( "4lengthIn", new LengthFieldBasedFrameDecoder( 1048576, 0, 4, 0, 4 ) );
                ch.pipeline.addLast( "4lengthOut", new LengthFieldPrepender( 4 ) );
                ch.pipeline.addLast( "msgIn", new CIdCategoryMsgPackDecoder( getMessage ) );
                ch.pipeline.addLast( "msgOut", new CIdCategoryMsgPackEncoder( true ) );
                CONFIG::debug {
                    var configXML : XML = stage.configuration.getXML( "ConfigRaw" );
                    if ( null == configXML || int( configXML..networkLog ) )
                        ch.pipeline.addLast( "logging", new LoggingHandler( "DUMMY-SERVER" ) );
                }
                ch.pipeline.addLast( "handler", thisDummyServer );
            } ) ).connect( "", 0 ); // dummy

            future.addEventListener( ChannelFutureEvent.OPERATION_COMPLETE, function ( event : ChannelFutureEvent ) : void {
                event.future.removeEventListener( ChannelFutureEvent.OPERATION_COMPLETE, arguments.callee );

                if ( event.future.isSuccess ) {
                    m_channel = event.future.channel;
                }

                // make started done.
                makeStarted();

                if ( !event.future.isSuccess ) {
                    throw event.future.cause;
                }

            }, false, 0 );

            m_messageBindings = new Dictionary();

            this.addHandlers();

            // waiting for server's channel connected.
            ret = false;
        }

        return ret;
    }

    protected function addHandlers() : void {
        addBean( new CDummyLoginHandler());
        addBean( new CDummyDatabase() ); // Database.
        addBean( new CDummyMapInstanceHandler() ); // Map instance handler.
        addBean( new CDummyFightHandler() );
    }

    override protected function onShutdown() : Boolean {
//        super.onShutdown();
        return true;
    }

    private function attachEventListeners() : void {
        addEventListener( CLifeCycleBeanEvent.BEAN_ADDED, _onSystemAdded, false, 0, true );
        addEventListener( CLifeCycleBeanEvent.BEAN_REMOVED, _onSystemRemoved, false, 0, true );
    }

    private function detachEventListeners() : void {
        removeEventListener( CLifeCycleBeanEvent.BEAN_ADDED, _onSystemAdded );
        removeEventListener( CLifeCycleBeanEvent.BEAN_REMOVED, _onSystemRemoved );
    }

    private function _onSystemAdded( event : CLifeCycleBeanEvent ) : void {
        if ( event.child is IDatabase ) {
            this.addBean( event.child, UNMANAGED );
        }
    }

    private function _onSystemRemoved( event : CLifeCycleBeanEvent ) : void {
        if ( event.child is IDatabase ) {
            if ( this.contains( IDatabase ) )
                this.removeBean( IDatabase );
        }
    }

    override protected function setStarted() : void {
        super.setStarted();

        // After STARTED.
    }

    public function getMessage( id : uint, category : uint ) : CAbstractPackMessage {
        if ( !(id in m_messageBindings) )
            return null;

        var dic : Dictionary = m_messageBindings[ id ] as Dictionary;
        if ( !dic )
            return null;

        var msgClass : Class;
        var msgInstance : CAbstractPackMessage;
        for ( var keyRef : * in dic ) {
            if ( keyRef is Class ) {
                msgInstance = dic[ keyRef ] as CAbstractPackMessage;
                if ( msgInstance ) {
                    return msgInstance;
                } else {
                    msgClass = keyRef as Class;
                    break;
                }
            }
        }

        if ( msgClass ) {
            msgInstance = new msgClass;
            dic[ id ][ msgClass ] = msgInstance;
        }

        return msgInstance;
    }

    public function listen( msgClass : Class, callback : Function ) : void {
        var msgInstance : CAbstractPackMessage = new msgClass;
        var id : uint = msgInstance.kof_message::token;

        if ( !(id in m_messageBindings) )
            m_messageBindings[ id ] = new Dictionary();
        m_messageBindings[ id ][ msgClass ] = msgInstance;
        if ( null != callback )
            m_messageBindings[ id ][ callback ] = true;
    }

    public function send( msg : CAbstractPackMessage ) : void {
        if ( !m_channel ) {
            throw new IllegalOperationError( "Write to null channel." );
        }
        m_channel.write( msg );
        m_channelWriteAmount++;
    }

    public function close() : void {
        detachEventListeners();

        m_bootstrap && m_bootstrap.shutdown();
        m_bootstrap = null;

        m_channel.close();
        m_channel = null;
    }

    public function channelActive( ctx : IChannelHandlerContext ) : void {
        ctx.fireChannelActive();
    }

    public function channelInactive( ctx : IChannelHandlerContext ) : void {
        ctx.fireChannelInactive();
    }

    public function channelRead( ctx : IChannelHandlerContext, msg : * ) : void {
        // CAbstractPackMessage
        var pckMsg : CAbstractPackMessage = msg as CAbstractPackMessage;
        var id : uint = pckMsg.kof_message::token;
        if ( id ) {
            var dic : Dictionary = this.m_messageBindings[ id ] as Dictionary;
            if ( dic ) {
                //noinspection LoopStatementThatDoesntLoopJS
                for ( var keyRef : * in dic ) {
                    if ( keyRef is Function ) {
                        keyRef( pckMsg );
                        break;
                    }
                }
            }
        }
    }

    public function channelReadComplete( ctx : IChannelHandlerContext ) : void {
        ctx.fireChannelReadComplete();
    }

    public function channelWritabilityChanged( ctx : IChannelHandlerContext ) : void {
        ctx.fireChannelWritabilityChanged();
    }

    public function handlerAdded( ctx : IChannelHandlerContext ) : void {
    }

    public function handlerRemoved( ctx : IChannelHandlerContext ) : void {
    }

    public function errorCaught( ctx : IChannelHandlerContext, cause : Error ) : void {
        ctx.fireErrorCaught( cause );
    }

    public function update( delta : Number ) : void {
        if ( m_channel && m_channelWriteAmount > 0 ) {
            m_channel.flush();
            m_channelWriteAmount = 0;
        }

        var dummyMap : CDummyMapInstanceHandler = getBean( CDummyMapInstanceHandler ) as CDummyMapInstanceHandler;
        if( dummyMap )
        {
            dummyMap.update( delta );
        }

        var dummyFight : CDummyFightHandler = getBean( CDummyFightHandler ) as CDummyFightHandler;
        if( dummyFight )
                dummyFight.update( delta );
    }

    public function get channel() : IChannel {
        return m_channel;
    }

    public function get isInherited() : Boolean {
        return false;
    }

}
}
