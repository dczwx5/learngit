package {

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Loader;
import flash.events.ErrorEvent;

import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TextEvent;
import flash.external.ExternalInterface;

import flash.net.URLRequest;
import flash.net.URLStream;
import flash.net.navigateToURL;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.text.StyleSheet;

import flash.text.TextField;

import flash.utils.ByteArray;

[Event(name="complete", type="flash.events.Event")]
[Event(name="initialize", type="flash.events.Event")]
[Event(name="createChildren", type="flash.events.Event")]
[Event(name="creationCompleted", type="flash.events.Event")]
[Event(name="unload", type="flash.events.Event")]
/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class LoadingBarMovieClip extends Sprite {

    /**
     * Creates a new LoadingBarMovieClip.
     */
    public function LoadingBarMovieClip( dataSource : Object = null ) {
        // constructor code
        super();

        this.dataSource = dataSource;

        if ( this.stage ) {
            this._addToStage( null );
        } else {
            this.addEventListener( Event.ADDED_TO_STAGE, _addToStage, false, 0, true );
        }
    }

    public function dispose() : void {
        this.removeEventListener( Event.ENTER_FRAME, _onEnterFrame );

        if ( this.stage ) {
            this.stage.removeEventListener( Event.RESIZE, _onStageResize );
        }

        this.removeMask();
        this.dispatchEvent( new Event( Event.UNLOAD ) );

        m_pMask = null;
    }

    private function _addToStage( event : Event ) : void {
        this.createChildren();
        this.initialize();
        this.creationCompleted();
    }

    private function _removeFromStage( event : Event ) : void {
        this.removeEventListener( Event.REMOVED_FROM_STAGE, _removeFromStage );

        this.dispose();
    }

    public function createChildren() : void {
        if ( !this.m_pMask ) {
            this.m_pMask = new Sprite;
            this.resetMask();
        }
        this.dispatchEvent( new Event( "createChildren" ) );
    }

    public function initialize() : Boolean {
        this.addEventListener( Event.REMOVED_FROM_STAGE, _removeFromStage, false, 0 );
        this.addEventListener( Event.ENTER_FRAME, _onEnterFrame, false, 0, true );
        this.stage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );

        if ( !this.m_pMask.parent ) {
            this.parent.addChildAt( this.m_pMask, this.parent.getChildIndex( this ) );
        }

        if ( isNaN( m_fRatioTotal ) )
            m_fRatioTotal = 0.0;
        if ( isNaN( m_fRatioSingle ) )
            m_fRatioSingle = 0.0;

        var mc : MovieClip = this[ 'loadingBarMc' ] as MovieClip;
        if ( mc ) {
            var pLinkRefresh : TextField = mc[ 'link_refresh' ];
            pLinkRefresh.htmlText = "<a href='event:1'><u>" + pLinkRefresh.text + "</u></a>"
            var hrefSheet : StyleSheet = new StyleSheet();
            hrefSheet.setStyle( "a:hover", {"color" : "#FC3636"} );
            pLinkRefresh.styleSheet = hrefSheet;
            pLinkRefresh.addEventListener( TextEvent.LINK, _onLinkRefreshHandler );
        }

        this.dispatchEvent( new Event( "initialize" ) );
        return true;
    }

    public function creationCompleted() : void {
        this.resetPosition();
        this.dispatchEvent( new Event( "creationCompleted" ) );
    }

    private function _onLinkRefreshHandler( event : Event ) : void {
        if ( ExternalInterface.available ) {
            navigateToURL( new URLRequest( ExternalInterface.call( "window.location.href.toString" ) ), "_self" );
        }
    }

    private function _onStageResize( event : Event ) : void {
        this.m_bLayoutDirty = true;
    }

    //----------------------------------
    // Layouts
    //----------------------------------

    protected function resetPosition() : void {
        this.x = this.stage.stageWidth - this.width >> 1;
        this.y = this.stage.stageHeight - this.height >> 1;

        var mc : MovieClip = this[ 'loadingBarMc' ] as MovieClip;
        if ( mc ) {
            mc.y = Math.max( -this.y, 0 ) + Math.min( this.stage.stageHeight, this.height ) - 170 + 45;
            trace( "this.y: ", this.y, ", stageHeight: ", this.stage.stageHeight, ", this.height: ", this.height, ", mc.height: ", mc.height, ", result mc.y: ", mc.y );
        }
    }

    override public function get width() : Number {
        return 1500;
    }

    override public function get height() : Number {
        return 900;
    }

    protected function resetMask() : void {
        if ( m_pMask ) {
            m_pMask.graphics.clear();
            m_pMask.graphics.beginFill( 0x0 );
            m_pMask.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
            m_pMask.graphics.endFill();
        }
    }

    protected function removeMask() : void {
        if ( m_pMask && m_pMask.parent )
            m_pMask.parent.removeChild( m_pMask );
    }

    private function _onEnterFrame( event : Event ) : void {
        if ( m_bDataSourceDirty ) {
            m_bDataSourceDirty = false;

            if ( this.dataSource ) {
                this.backgroundUrl = 'background' in this.dataSource ? this.dataSource.background : null;
            } else {
                this.backgroundUrl = null;
            }
        }

        const mc : MovieClip = this[ 'loadingBarMc' ] as MovieClip;
        if ( mc ) {
            const loadingProgressMainText : TextField = mc[ 'loadingProgressMainText' ];
            const loadingProgressSubText : TextField = mc[ 'loadingProgressSubText' ];
            const progressMainMc : DisplayObject = mc[ '_progressMainMc' ];
            const progressSubMc : DisplayObject = mc[ '_progressSubMc' ];
            const loadingBarMainMc : DisplayObject = mc[ 'loadingBarMainMc' ];
            const loadingBarSubMc : DisplayObject = mc[ 'loadingBarSubMc' ];

            if ( isNaN( m_fMainProgressMax ) )
                m_fMainProgressMax = progressMainMc.width;

            if ( isNaN( m_fSubProgressMax ) )
                m_fSubProgressMax = progressSubMc.width;

            progressMainMc.width = this.m_fMainProgressMax * this.ratioTotal;
            loadingProgressMainText.htmlText = ( 100.0 * this.ratioTotal ).toFixed( 2 ) + "%";

            if ( !m_pLoadingBarMainMcConfig ) {
                m_pLoadingBarMainMcConfig = {
                    x : loadingBarMainMc.x,
                    y : loadingBarMainMc.y
                };
            }

            loadingBarMainMc.x = m_pLoadingBarMainMcConfig.x + progressMainMc.width;

            progressSubMc.width = this.m_fSubProgressMax * this.ratioSingle;
            loadingProgressSubText.htmlText = this.loadingMessage || "";

            if ( !m_pLoadingBarSubMcConfig ) {
                m_pLoadingBarSubMcConfig = {
                    x : loadingBarSubMc.x,
                    y : loadingBarSubMc.y
                };
            }

            loadingBarSubMc.x = m_pLoadingBarSubMcConfig.x + progressSubMc.width;

        } else {
            trace( "Non-Exist MC..." );
        }

        if ( this.m_bBackgroundUrlDirty ) {
            this.m_bBackgroundUrlDirty = false;

            if ( this.m_pBackgroundLoader && this.m_pBackgroundLoader.parent ) {
                this.m_pBackgroundLoader.parent.removeChild( this.m_pBackgroundLoader );
                this.m_pBackgroundLoader.close();
                this.m_pBackgroundLoader.unload();
            }

            if ( !this.m_pBackgroundLoader ) {
                this.m_pBackgroundLoader = new Loader();
                this.addChildAt( this.m_pBackgroundLoader, this.getChildIndex( mc ) );
                m_bLayoutDirty = true;
            }

            var vUrlRequest : URLRequest = new URLRequest( this.backgroundUrl );
            var vUrlStream : URLStream = new URLStream();
            var bSwfImported : Boolean = this.backgroundUrl.toLowerCase().indexOf( '.swf' ) > 0;
            var vLoaderContext : LoaderContext = null;
            vUrlStream.load( vUrlRequest );

            if ( bSwfImported ) {
                vLoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain, null );
                vLoaderContext.allowCodeImport = true;
            }

            var vStreamData : ByteArray = new ByteArray();

            vUrlStream.addEventListener( ProgressEvent.PROGRESS, _onProgress );
            vUrlStream.addEventListener( Event.COMPLETE, _onComplete );
            vUrlStream.addEventListener( ErrorEvent.ERROR, _onError );
            vUrlStream.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _onError );

            function _onProgress( e : ProgressEvent ) : void {
                var iLen : int = vStreamData.length;
                vUrlStream.readBytes( vStreamData, vStreamData.length );
                if ( vStreamData.length > iLen ) {
                    m_pBackgroundLoader.loadBytes( vStreamData, vLoaderContext );
                }
            }

            function _onError( e : Event ) : void {
                vUrlStream.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
                vUrlStream.removeEventListener( Event.COMPLETE, _onComplete );
                vUrlStream.removeEventListener( ErrorEvent.ERROR, _onError );
                vUrlStream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onError );
                vUrlStream.close();
            }

            function _onComplete( e : Event ) : void {
                vUrlStream.close();
                vUrlStream.removeEventListener( ProgressEvent.PROGRESS, _onProgress );
                vUrlStream.removeEventListener( Event.COMPLETE, _onComplete );
                vUrlStream.removeEventListener( ErrorEvent.ERROR, _onError );
                vUrlStream.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, _onError );
                m_bLayoutDirty = true;
            }
        }

        if ( m_bLayoutDirty ) {
            m_bLayoutDirty = false;

            this.resetMask();
            this.resetPosition();
        }
    }

    public function get dataSource() : Object {
        return m_pDataSource;
    }

    public function set dataSource( value : Object ) : void {
        if ( this.m_pDataSource != value ) {
            m_pDataSource = value;
            m_bDataSourceDirty = true;
        }
    }

    public function get ratioSingle() : Number {
        return m_fRatioSingle;
    }

    public function set ratioSingle( value : Number ) : void {
        if ( m_fRatioSingle != value ) {
            m_fRatioSingle = value;
        }
    }

    public function get ratioTotal() : Number {
        return m_fRatioTotal;
    }

    public function set ratioTotal( value : Number ) : void {
        if ( this.ratioTotal != value ) {
            this.m_fRatioTotal = value;
        }
    }

    public function get loadingMessage() : String {
        return m_sLoadingMessage;
    }

    public function set loadingMessage( value : String ) : void {
        m_sLoadingMessage = value;
    }

    public function get backgroundUrl() : String {
        return m_sBackgroundUrl;
    }

    public function set backgroundUrl( value : String ) : void {
        if ( m_sBackgroundUrl == value )
            return;
        m_sBackgroundUrl = value;
        m_bBackgroundUrlDirty = true;
    }

    private var m_fRatioTotal : Number;
    private var m_fRatioSingle : Number;

    private var m_sLoadingMessage : String;

    private var m_pDataSource : Object;
    private var m_bDataSourceDirty : Object;

    private var m_bLayoutDirty : Boolean;

    private var m_fMainProgressMax : Number;
    private var m_fSubProgressMax : Number;

    private var m_sBackgroundUrl : String;
    private var m_bBackgroundUrlDirty : Boolean;

    private var m_pBackgroundLoader : Loader;
    private var m_pMask : Sprite;

    private var m_pLoadingBarMainMcConfig : Object;
    private var m_pLoadingBarSubMcConfig : Object;

}
}

// vi:ft=as3 tw=0 sw=4 ts=4 expandtab
