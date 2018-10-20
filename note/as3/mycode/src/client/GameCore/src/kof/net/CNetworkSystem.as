//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net {

import QFLib.DashBoard.CDashBoard;
import QFLib.Foundation.CLog;
import QFLib.Interface.IUpdatable;

import avmplus.getQualifiedClassName;

import flash.events.Event;
import flash.net.GroupSpecifier;
import flash.utils.Dictionary;

import io.asnetty.bootstrap.Bootstrap;
import io.asnetty.channel.ChannelFutureEvent;
import io.asnetty.channel.ChannelInitializer;
import io.asnetty.channel.IChannel;
import io.asnetty.channel.IChannelFuture;
import io.asnetty.channel.IChannelHandler;
import io.asnetty.channel.IChannelPipeline;
import io.asnetty.channel.socket.SocketChannel;
import io.asnetty.handler.codec.LengthFieldBasedFrameDecoder;
import io.asnetty.handler.codec.LengthFieldPrepender;
import io.asnetty.handler.logging.LogLevel;
import io.asnetty.util.InternalLoggerFactory;

import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.framework.IProvider;
import kof.framework.network.INetworkMessageBinder;
import kof.framework.network.INetworkMessageLinkedBuilder;
import kof.message.CAbstractPackMessage;
import kof.message.kof_message;
import kof.net.channel.RTMFPChannel;
import kof.net.codec.CIdCategoryMsgPackDecoder;
import kof.net.codec.CIdCategoryMsgPackEncoder;
import kof.net.codec.CKofMsgEncryptDecoder;
import kof.net.codec.CKofMsgEncryptEncoder;
import kof.util.CAssertUtils;

[Event(name="close", type="flash.events.Event")]
/**
 * An <code>AppSystem</code> implements from <code>INetworking</code> for
 * networking supported.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CNetworkSystem extends CAppSystem implements INetworking, IUpdatable,
        INetworkMessageBinder {

    private var m_pNetworkingLog : CLog;

    /** @private */
    private var m_channel : IChannel;
    /** @private */
    private var m_groupChannel : RTMFPChannel;
    /** @private */
    private var m_bootstrap : Bootstrap;
    /** @private */
    private var m_groupBootstrap : Bootstrap;
    /** @private */
    private var m_writeNum : int;
    /** @private */
    private var m_groupWriteNum : int;
    /** @private */
    private var m_classBindings : Dictionary;
    /** @private */
    private var m_tokenBinding : Dictionary;
    /** @private */
    private var m_bInitialized : Boolean;

    /**
     * Creates a CNetworkSystem object.
     */
    public function CNetworkSystem() {
        super();

        m_tokenBinding = new Dictionary();
        m_classBindings = new Dictionary( true );
        m_pNetworkingLog = new CLog( "NET" );
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            ret = ret && this.addBean( new CNetworkSystemHandler );
        }

        var pDashBoard : CDashBoard = stage.getBean( CDashBoard ) as CDashBoard;
        if ( pDashBoard ) {
            if ( !pDashBoard.findPage( "NetworkingLogPage" ) ) {
                pDashBoard.addPage( new CNetworkingLogPage( pDashBoard, m_pNetworkingLog ) );
            }
        }

        InternalLoggerFactory.defaultFactory = new CNetworkingLogFactory( m_pNetworkingLog );

        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        return ret;
    }

    override public function dispose() : void {
        super.dispose();
        // this.close();
    }

    public function get isConnected() : Boolean {
        return m_channel && m_channel.isOpen;
    }

    public function bind( msgClass : Class ) : INetworkMessageLinkedBuilder {
        var msgInstance : CAbstractPackMessage = new msgClass();
        var iToken : uint = msgInstance.kof_message::token;
        var builder : CNetworkMessageBindingBuilder = new CNetworkMessageBindingBuilder();
        m_classBindings[ msgClass ] = builder;
        m_tokenBinding[ iToken ] = builder;

        return builder.withToken( iToken ).toInstance( msgInstance );
    }

    public function unbind( msgClass : Class ) : void {
        if ( msgClass in m_classBindings ) {
            var builder : CNetworkMessageBindingBuilder = m_classBindings[ msgClass ] as CNetworkMessageBindingBuilder;
            delete m_classBindings[ msgClass ];

            if ( builder ) {
                delete m_tokenBinding[ builder.token ];

                builder.withToken( null ).toInstance( null );
                builder.withNamed( null ).toHandler( null );
            }
        }
    }

    public function send( data : Object ) : Boolean {
        if ( !m_channel )
            return false;
        if ( m_channel.isOpen ) {
            m_writeNum++;
            return m_channel.write( data );
        }
        return false;
    }

    public function post( data : Object ) : void {
        if ( !m_groupChannel ) {
            this.send( data );
        } else {
            m_groupChannel.write( data );
            m_groupWriteNum++;
        }
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
    }

    protected function get channelClass() : Class {
        return SocketChannel;
    }

    public function connect( host : String, port : uint, onConnectedOrError : Function = null ) : void {
        if ( m_channel && m_channel.isOpen ) {
            if ( null != onConnectedOrError )
                onConnectedOrError( m_channel );
            return;
        }

        var pKeyProvider : CKofCodecKeyProvider = new CKofCodecKeyProvider( stage.configuration );

        var fTimeout : Number = stage.configuration.getNumber( 'connect.timeout', 15 );

        var bs : Bootstrap = m_bootstrap || (m_bootstrap = new Bootstrap());

        var connectFuture : IChannelFuture = bs.channel( channelClass ).handler( new ChannelInitializer( function ( ch : IChannel ) : void {
            const pl : IChannelPipeline = ch.pipeline;
            pl.addFirst( "FirstLogging", new LoggingHandler( "FL" ) );
            pl.addLast( "frameDecoder", new LengthFieldBasedFrameDecoder( 1048576, 0, 4, 0, 4 ) );
            pl.addLast( "frameEncoder", new LengthFieldPrepender( 4 ) );

            var bNetworkingEncrypt : Boolean = stage.configuration.getBoolean( "networking.encrypt", true );
            if ( bNetworkingEncrypt ) {
                pl.addLast( "encryptDecoder", new CKofMsgEncryptDecoder( pKeyProvider ) );
                pl.addLast( "encryptEncoder", new CKofMsgEncryptEncoder( pKeyProvider ) );
            }

            pl.addLast( "beforeLogging", new LoggingHandler( "BL" ) );

            pl.addLast( "msgPackDecoder", new CIdCategoryMsgPackDecoder( _getMessageByIdCategory ) );
            pl.addLast( "msgPackEncoder", new CIdCategoryMsgPackEncoder( !bNetworkingEncrypt ) );

            // CONFIG::debug {
            var configXML : XML = stage.configuration.getXML( "ConfigRaw" );
            if ( null == configXML || int( configXML..networkLog ) )
                pl.addLast( "logging", new LoggingHandler( "OL", LogLevel.INFO ) );
            // }

            pl.addLast( "SystemFacadeProxy", handler as IChannelHandler );

        } ) ).connect( host, port, fTimeout );

        if ( connectFuture ) {
            connectFuture.addEventListener( ChannelFutureEvent.OPERATION_COMPLETE, _connectFuture_operationComplete, false, 0, true );
        } else {
            if ( null != onConnectedOrError ) {
                onConnectedOrError( new Error( "Connecting Failed." ) );
            }
        }

        /** @private */
        function _connectFuture_operationComplete( event : ChannelFutureEvent ) : void {
            event.future.removeEventListener( Event.COMPLETE, _connectFuture_operationComplete );

            CAssertUtils.assertEquals( connectFuture, event.future );
            CAssertUtils.assertNull( m_channel );

            if ( event.future.isSuccess ) {
                m_channel = event.future.channel;
                // connected.
                if ( null != onConnectedOrError ) {
                    onConnectedOrError( event.future.channel );
                }
            } else {
                if ( null != onConnectedOrError ) {
                    onConnectedOrError( event.future.cause );
                }
            }
        }
    }

    [Deprecated]
    /**
     * 连接到P2P网络
     */
    public function connectToP2P( rtmfpURL : String, groupName : String,
                                  ipMulticastAddr : String, ipMulticastPort : int,
                                  pfnCompleteOrError : Function = null ) : void {
        if ( m_groupChannel && m_groupChannel.isOpen ) {
            if ( null != pfnCompleteOrError ) {
                pfnCompleteOrError( m_groupChannel );
            }
            return;
        }

        m_groupBootstrap = new Bootstrap();
        var future : IChannelFuture = m_groupBootstrap.channel( RTMFPChannel ).option( "IPMulticast", true ).handler( new ChannelInitializer( function ( ch : IChannel ) : void {
            const pl : IChannelPipeline = ch.pipeline;
            pl.addLast( "msgPackDecoder", new CIdCategoryMsgPackDecoder( _getMessageByIdCategory ) );
            pl.addLast( "msgPackEncoder", new CIdCategoryMsgPackEncoder() );

            pl.addLast( "logging", new LoggingHandler( "RTMFPChannel" ) );

            pl.addLast( "SystemFacadeProxy", handler as IChannelHandler );

            var rtmfpChannel : RTMFPChannel = ch as RTMFPChannel;
            if ( rtmfpChannel ) {
                var groupSpec : GroupSpecifier = new GroupSpecifier( groupName );
                groupSpec.postingEnabled = true;
                // groupSpec.serverChannelEnabled = true;
                groupSpec.ipMulticastMemberUpdatesEnabled = true;
                groupSpec.addIPMulticastAddress( ipMulticastAddr );

                rtmfpChannel.joinGroup( groupSpec );
            }

        } ) ).connect( rtmfpURL, 0 );

        if ( future ) {
            future.addEventListener( ChannelFutureEvent.OPERATION_COMPLETE, function ( event : ChannelFutureEvent ) : void {
                event.currentTarget.removeEventListener( ChannelFutureEvent.OPERATION_COMPLETE, arguments.callee );
                if ( event.future.isSuccess ) {
                    m_groupChannel = event.future.channel as RTMFPChannel;
                    if ( null != pfnCompleteOrError )
                        pfnCompleteOrError( event.future.channel );
                } else {
                    if ( null != pfnCompleteOrError )
                        pfnCompleteOrError( event.future.cause );
                }
            } );
        }
    }

    public function close() : void {
        if ( m_bootstrap ) {
            m_bootstrap.shutdown();
            m_bootstrap = null;
        }

        if ( m_channel ) {
            m_channel.close();
            m_channel = null;
        }

        if ( m_groupBootstrap ) {
            m_groupBootstrap.shutdown();
            m_groupBootstrap = null;
        }

        if ( m_groupChannel ) {
            m_groupChannel.close();
            m_groupChannel = null;
        }
    }

    public function update( delta : Number ) : void {
        if ( !m_bInitialized )
            return;

        if ( m_channel ) {
            if ( m_writeNum > 0 ) {
                m_writeNum = 0;

                m_channel.flush();
            }
        }

        if ( m_groupChannel ) {
            if ( m_groupWriteNum > 0 ) {
                m_groupWriteNum = 0;
                m_groupChannel.flush();
            }
        }
    }

    /**
     * @inheritDoc
     */
    public function getMessage( tokenOrClass : *, fail : Boolean = true ) : CAbstractPackMessage {
        var binding : Object;
        if ( tokenOrClass is Class ) { // Gets request message.
            if ( !(tokenOrClass in m_classBindings) ) {
                // lazy binding
                var builder : CNetworkMessageBindingBuilder = new CNetworkMessageBindingBuilder();
                m_classBindings[ tokenOrClass ] = builder;
                builder.withToken( tokenOrClass ).toInstance( new tokenOrClass );
            }

            binding = m_classBindings[ tokenOrClass ];
        } else if ( tokenOrClass is Number ) { // Gets response message.
            binding = m_tokenBinding[ tokenOrClass ];
        }

        if ( binding && binding.hasOwnProperty( 'provider' ) ) {
            var provider : IProvider = binding.provider as IProvider;
            if ( provider )
                return provider.getInstance();
        }

        if ( fail ) {
            var failMsg : String = "Can not find the message with tokenOrClass: ";
            if ( tokenOrClass is Number ) {
                failMsg += "0x" + Number( tokenOrClass ).toString( 16 ) + "(" + tokenOrClass + ")";
            } else if ( tokenOrClass is Class ) {
                failMsg += getQualifiedClassName( tokenOrClass );
            }
            throw new ArgumentError( failMsg );
        }

        return null;
    }

    /** @private */
    private function _getMessageByIdCategory( id : uint, category : uint ) : CAbstractPackMessage {
        return getMessage( id );
    }

    public function getMessageHandler( tokenOrClass : * ) : Function {
        var binding : Object;
        if ( tokenOrClass is Class ) {
            binding = m_classBindings[ tokenOrClass ];
        } else if ( tokenOrClass is Number ) {
            binding = m_tokenBinding[ tokenOrClass ];
        }

        if ( binding && binding.hasOwnProperty( 'handler' ) ) {
            return binding.handler as Function;
        }

        return null;
    }

}
}

import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.CDashBoard;
import QFLib.Foundation;
import QFLib.Foundation.CLog;

import flash.events.Event;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import io.asnetty.channel.ChannelDuplexHandler;
import io.asnetty.channel.IChannelHandlerContext;
import io.asnetty.channel.IChannelInboundHandler;
import io.asnetty.channel.IChannelOutboundHandler;
import io.asnetty.channel.IChannelPromise;
import io.asnetty.handler.logging.LogLevel;
import io.asnetty.util.FormattingTuple;
import io.asnetty.util.InternalLogger;
import io.asnetty.util.InternalLoggerFactory;
import io.asnetty.util.MessageFormatter;
import io.asnetty.util.TraceLogger;

import kof.framework.CAbstractHandler;
import kof.framework.CSystemHandler;
import kof.framework.IConfiguration;
import kof.framework.INetworking;
import kof.framework.IProvider;
import kof.framework.network.INetworkMessageLinkedBuilder;
import kof.framework.network.INetworkMessageScope;
import kof.framework.network.INetworkMessageScopeBuilder;
import kof.message.Account.AccountLoginResponse;
import kof.message.CAbstractPackMessage;
import kof.message.Exception.ExceptionResponse;
import kof.message.kof_message;
import kof.net.CNetworkSystem;
import kof.net.ICodecKeyProvider;

use namespace kof_message;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
class CNetworkSystemHandler extends CSystemHandler implements IChannelInboundHandler, IChannelOutboundHandler {

    /**
     * Creates a CNetworkSystemHandler instance.
     */
    public function CNetworkSystemHandler() {
        super();
        m_theErrors = [];
    }

    private var m_theErrors : Array;

    override protected function onSetup() : Boolean {
        var netSys : CNetworkSystem = system as CNetworkSystem;
        if ( netSys ) {
            netSys.bind( ExceptionResponse ).toHandler( onServerExceptionMessageHandler );
            return true;
        }
        return false;
    }

    //noinspection JSMethodCanBeStatic
    /**
     * Server异常数据Response
     */
    private function onServerExceptionMessageHandler( net : INetworking, response : CAbstractPackMessage ) : void {
        var msg : ExceptionResponse = response as ExceptionResponse;

        if ( msg ) {
            throw new Error( msg.cause, msg.code );
        }
    }

    protected function throwErrorsIfNeeded() : void {
        if ( m_theErrors && m_theErrors.length ) {
            var errs : Array = m_theErrors.slice();
            m_theErrors.splice( 0, m_theErrors.length );
            for each ( var e : * in errs ) {
                throw e;
            }
        }
    }

    public function channelActive( ctx : IChannelHandlerContext ) : void {
        ctx.fireChannelActive();
    }

    public function channelInactive( ctx : IChannelHandlerContext ) : void {
        ctx.fireChannelInactive();
    }

    public function channelRead( ctx : IChannelHandlerContext, msg : * ) : void {
        ctx.fireChannelRead( msg );

        var packMsg : CAbstractPackMessage = msg as CAbstractPackMessage;
        if ( packMsg ) {
            var networkSystem : CNetworkSystem = system as CNetworkSystem;
            var handler : Function = networkSystem.getMessageHandler( packMsg.kof_message::token );
            if ( null != handler ) {
                try {
                    handler( networking, msg );
                } catch ( e : Error ) {
                    Foundation.Log.logErrorMsg( e.getStackTrace() );
                    m_theErrors.push( e );
                }

                if ( msg is AccountLoginResponse ) {
                    system.stage.configuration.setConfig( CKofCodecKeyProvider.PRIVATE_CONFIG_KEY, String( AccountLoginResponse( msg ).encryptKey ) );
                }
            }
        }
    }

    public function channelReadComplete( ctx : IChannelHandlerContext ) : void {
        ctx.fireChannelReadComplete();

        throwErrorsIfNeeded();
    }

    public function channelWritabilityChanged( ctx : IChannelHandlerContext ) : void {
        ctx.fireChannelWritabilityChanged();
    }

    public function handlerAdded( ctx : IChannelHandlerContext ) : void {
        // NOOP.
    }

    public function handlerRemoved( ctx : IChannelHandlerContext ) : void {
        // NOOP.
    }

    public function errorCaught( ctx : IChannelHandlerContext, cause : Error ) : void {
        m_theErrors.push( cause );
        ctx.fireErrorCaught( cause );
    }


    public function connect( ctx : IChannelHandlerContext, host : String, port : int, promise : IChannelPromise = null ) : void {
        ctx.makeConnect( host, port, promise );
    }

    public function disconnect( ctx : IChannelHandlerContext, promise : IChannelPromise = null ) : void {
        ctx.makeDisconnect( promise );
    }

    public function close( ctx : IChannelHandlerContext, promise : IChannelPromise = null ) : void {
        ctx.makeClose( promise );

        // dispatch close event with Networking.
        system.dispatchEvent( new Event( Event.CLOSE ) );
    }

    public function read( ctx : IChannelHandlerContext ) : void {
        ctx.makeRead();
    }

    public function write( ctx : IChannelHandlerContext, msg : *, promise : IChannelPromise = null ) : void {
        ctx.makeWrite( msg, promise );
    }

    public function flush( ctx : IChannelHandlerContext ) : void {
        ctx.makeFlush();

        throwErrorsIfNeeded();
    }

} // class CNetworkSystemHandler

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class CNetworkMessageBindingBuilder implements INetworkMessageLinkedBuilder, INetworkMessageScopeBuilder {

    function CNetworkMessageBindingBuilder() {
        super();
    }

    public var token : *;
    public var handler : Function;
    public var scope : INetworkMessageScope;
    public var provider : IProvider;

    public function withToken( token : * ) : INetworkMessageLinkedBuilder {
        this.token = token;
        return this;
    }

    public function toHandler( func : Function ) : INetworkMessageScopeBuilder {
        this.handler = func;
        return this;
    }

    public function toInstance( instance : Object ) : INetworkMessageLinkedBuilder {
        this.provider = new CInstanceProvider( instance );
        return this;
    }

    public function withNamed( named : String ) : INetworkMessageLinkedBuilder {
        // NOTE: no implementation now.
        return this;
    }

    public function inScope( scope : INetworkMessageScope ) : void {
        this.scope = scope;
        // return;
    }
}

class CInstanceProvider implements IProvider {

    private var m_instance : Object;

    function CInstanceProvider( instance : Object ) {
        this.m_instance = instance;
    }

    public function getInstance() : * {
        return m_instance;
    }

}

class CNetworkingLogPage extends CConsolePage {

    private var m_pLogRef : CLog;

    function CNetworkingLogPage( theDashBoard : CDashBoard, pLog : CLog ) {
        this.m_pLogRef = pLog;
        super( theDashBoard );
    }

    override protected function configureLog() : void {
        m_pLogRef.setCustomLogFunction( customLogOut );
    }

    override public function get name() : String {
        return "NetworkingLogPage";
    }
}

class CNetworkingLogFactory extends InternalLoggerFactory {

    private var m_pCaches : Dictionary;
    private var m_pLogRef : CLog;

    public function CNetworkingLogFactory( pLog : CLog ) {
        super();

        m_pCaches = new Dictionary();
        this.m_pLogRef = pLog;
    }

    override protected function newInstance( name : String ) : InternalLogger {
        var ret : InternalLogger;
        if ( name in m_pCaches ) {
            ret = m_pCaches[ name ] as InternalLogger;
        }

        if ( !ret ) {
            ret = new CLogLogger( name, m_pLogRef );

            m_pCaches[ name ] = ret;
        }

        return ret;
    }

}

class CLogLogger extends TraceLogger {

    private var m_pLogRef : CLog;
    private var m_iCurrentLogLevel : int;

    function CLogLogger( ref : *, pLog : CLog ) {
        super( ref );
        this.m_pLogRef = pLog;
        m_iCurrentLogLevel = LogLevel.INFO;
    }

    override protected function doPrint( format : String, args : Array ) : void {
//        super.doPrint( format, args );
        const tuple : FormattingTuple = MessageFormatter.applyFormat( format, args );
        switch ( m_iCurrentLogLevel ) {
            case LogLevel.TRACE:
            case LogLevel.DEBUG:
                m_pLogRef.logTraceMsg( " [" + this.name + "] " + tuple.message );
                break;
            case LogLevel.INFO:
                m_pLogRef.logMsg( " [" + this.name + "] " + tuple.message );
                break;
            case LogLevel.WARN:
                m_pLogRef.logWarningMsg( " [" + this.name + "] " + tuple.message );
                break;
            case LogLevel.ERROR:
                m_pLogRef.logErrorMsg( " [" + this.name + "] " + tuple.message );
                break;
            default:
                m_pLogRef.logMsg( " [" + this.name + "] " + tuple.message );
        }
        if ( tuple.throwable ) throw tuple.throwable;
    }

    override protected function doTrace( format : String, ... args ) : void {
        m_iCurrentLogLevel = LogLevel.TRACE;
        doPrint( format, args );
    }

    override protected function doDebug( format : String, ... args ) : void {
        m_iCurrentLogLevel = LogLevel.DEBUG;
        doPrint( format, args );
    }

    override protected function doInfo( format : String, ... args ) : void {
        m_iCurrentLogLevel = LogLevel.INFO;
        doPrint( format, args );
    }

    override protected function doWarn( format : String, ... args ) : void {
        m_iCurrentLogLevel = LogLevel.WARN;
        doPrint( format, args );
    }

    override protected function doError( format : String, ... args ) : void {
        m_iCurrentLogLevel = LogLevel.ERROR;
        doPrint( format, args );
    }
}

class LoggingHandler extends ChannelDuplexHandler {

    private static const DEFAULT_LEVEL : int = LogLevel.DEBUG;

    protected var logger : InternalLogger;
    protected var internalLevel : int;

    private var _level : int;

    public function LoggingHandler( name : String = null, level : int = LogLevel.DEBUG ) {
        logger = InternalLoggerFactory.getInstance( name ? name : LoggingHandler );
        this.internalLevel = this._level = level;
    }

    public function get level() : int {
        return _level;
    }

    protected function printByteArray( ba : ByteArray ) : String {
        var oldPos : int = ba.position;
        var msg : String = "ExpectedLen: " + (ba.bytesAvailable >= 4 ? ba.readUnsignedInt() : NaN);
        msg += ", ActualLen: " + ba.length;
        if ( ba.bytesAvailable >= 6 ) {
            ba.position = oldPos + 4;
            msg += ", Guess MsgID: " + ba.readUnsignedShort();
        } else {
            msg += ", Guess MsgID: NaN";
        }
        ba.position = oldPos;
        return msg;
    }

    protected function format( ctx : IChannelHandlerContext, eventName : String, ... args ) : String {
        var str : String = ctx.channel[ 'toString' ]();
        str += ' ';
        str += eventName;
        var i : int = 0;
        if ( args.length > 0 ) {
            for each ( var va : * in args ) {
                if ( va ) {
                    if ( i > 0 )
                        str += ',';
                    else if ( i == 0 ) {
                        str += ': ';
                    }

                    if ( va is ByteArray ) {
                        str += printByteArray( va );
                    } else if ( va is Array ) {
                        var vaOut : Array = [];
                        for each ( var v : * in va ) {
                            if ( va is ByteArray )
                                vaOut.push( printByteArray( va ) );
                            else
                                vaOut.push( va.toString() );
                        }
                        str += vaOut.join();
                    } else {
                        str += va.toString();
                    }
                }
                i++;
            }
        }

        return str;
    }

    override public function channelActive( ctx : IChannelHandlerContext ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "ACTIVE" ) );
        }
        ctx.fireChannelActive();
    }

    override public function channelInactive( ctx : IChannelHandlerContext ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "INACTIVE" ) );
        }
        ctx.fireChannelInactive();
    }

    override public function channelRead( ctx : IChannelHandlerContext, msg : * ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "RECEIVED", msg ) );
        }
        ctx.fireChannelRead( msg );
    }

    override public function errorCaught( ctx : IChannelHandlerContext, cause : Error ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "ERROR", cause.toString() ) );
        }
        ctx.fireErrorCaught( cause );
    }

    override public function connect( ctx : IChannelHandlerContext, host : String, port : int, promise : IChannelPromise = null ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "CONNECT", host, port ) );
        }
        ctx.makeConnect( host, port, promise );
    }

    override public function disconnect( ctx : IChannelHandlerContext, promise : IChannelPromise = null ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "DISCONNECT" ) );
        }
        ctx.makeDisconnect( promise );
    }

    override public function close( ctx : IChannelHandlerContext, promise : IChannelPromise = null ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "CLOSE" ) );
        }
        ctx.makeClose( promise );
    }

    override public function write( ctx : IChannelHandlerContext, msg : *, promise : IChannelPromise = null ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "WRITE", msg ) );
        }
        ctx.makeWrite( msg, promise );
    }

    override public function flush( ctx : IChannelHandlerContext ) : void {
        if ( logger.isEnabled( internalLevel ) ) {
            logger.log( internalLevel, format( ctx, "FLUSH" ) );
        }
        ctx.makeFlush();
    }

} // class LoggingHandler

class CKofCodecKeyProvider implements ICodecKeyProvider {

    public static const PRIVATE_CONFIG_KEY : String = "netcodec.encryptKey";

    private var m_sPrivateKey : String;
    private var m_pPrivateKeyBytes : ByteArray;
    private var m_pConfiguration : IConfiguration;

    public function CKofCodecKeyProvider( configuration : IConfiguration ) {
        super();

        this.m_pConfiguration = configuration;
        this.init();
    }

    public function dispose() : void {
        if ( m_pPrivateKeyBytes )
            m_pPrivateKeyBytes.clear();
        m_pPrivateKeyBytes = null;
        m_sPrivateKey = null;
        m_pConfiguration = null;
    }

    public function get key() : String {
        return m_sPrivateKey;
    }

    public function set key( value : String ) : void {
        m_sPrivateKey = value;
        if ( value ) {
            if ( !m_pPrivateKeyBytes )
                m_pPrivateKeyBytes = new ByteArray();
            m_pPrivateKeyBytes.length = 0;
            m_pPrivateKeyBytes.writeMultiByte( value, 'iso-5589-1' );
            m_pPrivateKeyBytes.position = 0;
        } else {
            if ( m_pPrivateKeyBytes ) {
                m_pPrivateKeyBytes.clear();
                m_pPrivateKeyBytes.length = 0;
            }
        }
    }

    public function get bytes() : ByteArray {
        return m_pPrivateKeyBytes;
    }

    public function init() : Boolean {
        this.m_pConfiguration.addItemUpdateListener( PRIVATE_CONFIG_KEY, _onConfigKeyUpdate );
        if ( !this.m_pConfiguration.getString( PRIVATE_CONFIG_KEY, null ) ) {
            this.m_pConfiguration.setConfig( PRIVATE_CONFIG_KEY, 'ujzmyrdz' );
        }
        return true;
    }

    private function _onConfigKeyUpdate() : void {
        this.key = this.m_pConfiguration.getString( PRIVATE_CONFIG_KEY );
    }

}


