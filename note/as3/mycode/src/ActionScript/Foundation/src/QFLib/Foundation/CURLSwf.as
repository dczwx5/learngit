//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Foundation {

import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;

/**
 * 基于CURLFile加载SWF
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CURLSwf extends CURLFile {

    public function CURLSwf( sURL : String = "", sURLVersion : String = null, bLoadFileWithVersionOnly : Boolean = false, pStreamLoaderClass : Class = null ) {
        super( sURL, sURLVersion, bLoadFileWithVersionOnly, pStreamLoaderClass );
        this.m_pApplicationDomain = ApplicationDomain.currentDomain;
    }

    override public function dispose() : void {
        super.dispose();
        this.close( true );

        m_pSwfLoader = null;
        m_pApplicationDomain = null;
        m_pSecurityDomain = null;
        m_pParameters = null;
    }

    override public function close( bFullCleanup : Boolean = false ) : void {
        if ( bFullCleanup && m_pSwfLoader ) {
            m_pSwfLoader.unloadAndStop();
        }

        super.close( bFullCleanup );
    }

    override protected virtual function _onCompleted( e : Event ) : void {
        if ( m_theProgressTimer )
            m_theProgressTimer.reset();

        var vContext : LoaderContext = new LoaderContext( false, this.applicationDomain, this.securityDomain );
        vContext.allowCodeImport = this.allowCodeImport;
        vContext.parameters = this.parameters;

        m_pSwfLoader = m_pSwfLoader || new Loader;
        m_pSwfLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, _onBytesLoadedCompleted );
        m_pSwfLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, _onBytesLoadedError );
        m_pSwfLoader.loadBytes( this.readAllBytes(), vContext );
    }

    protected virtual function _onBytesLoadedCompleted( e : Event ) : void {
        super._onCompleted( e );
    }

    protected virtual function _onBytesLoadedError( e : IOErrorEvent ) : void {
        super._onError( e );
    }

    [Inline]
    final public function get allowCodeImport() : Boolean { return m_bAllowCodeImport; }
    final public function set allowCodeImport( value : Boolean ) : void {
        m_bAllowCodeImport = value;
    }

    [Inline]
    public function get applicationDomain() : ApplicationDomain { return m_pApplicationDomain; }
    public function set applicationDomain( value : ApplicationDomain ) : void {
        m_pApplicationDomain = value;
    }

    [Inline]
    public function get securityDomain() : SecurityDomain { return m_pSecurityDomain; }
    public function set securityDomain( value : SecurityDomain ) : void {
        m_pSecurityDomain = value;
    }

    [Inline]
    final public function get parameters() : Object { return m_pParameters; }
    final public function set parameters( value : Object ) : void {
        m_pParameters = value;
    }

    public function get loader() : Loader { return m_pSwfLoader; }

    // @private
    private var m_pSwfLoader : Loader;
    private var m_bAllowCodeImport : Boolean;
    private var m_pApplicationDomain : ApplicationDomain;
    private var m_pSecurityDomain : SecurityDomain;
    private var m_pParameters : Object;

}
}
// vi:ft=as3 tw=120 sw=4 ts=4 expandtab tw=120
