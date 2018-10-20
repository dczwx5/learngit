package kof.app
{
import QFLib.Utils.CClassUtil;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.TextEvent;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.utils.Dictionary;
import flash.utils.Timer;

public class CLoadingStatusView extends Sprite
{
    private var _loadBar : Sprite;

    private var _currentProMc : Sprite;
    private var _totalProMc : Sprite;

    private var _currentProTxt : TextField;

    private var _totalProTxt : TextField;
    private var _txtRefresh : TextField;
    private var _alertTxt : TextField;
    private var _txtRandomTips : TextField;
    private var _lightMc : Sprite;
    private var _timer : Timer;

    private var _mcContent : MovieClip;
    private var _mcIcon : MovieClip;
    private var _yOfMcIcon : int;
    private var _stage : Stage;
    private var _allBytes : Number;

    public function CLoadingStatusView()
    {
        var loadBarClass : Class = CClassUtil.getClassByAliasName( "LoadingBarMovieClip", MovieClip );
        _loadBar = new loadBarClass();
        _mcContent = _loadBar[ "_mcContent" ];
        _mcIcon = _loadBar[ "_mcIcon" ];
        _yOfMcIcon = _mcIcon.y;

        _lightMc = _mcContent[ "lightMc" ];
        _lightMc.x = -_lightMc.width;

        _currentProMc = _mcContent[ "currentProMc" ];
        _currentProMc.scaleX = 0;

        _totalProMc = _mcContent[ "totalProMc" ];
        _totalProMc.scaleX = 0;

        _totalProTxt = _mcContent[ "totalProTxt" ];
        _currentProTxt = _mcContent[ "currentProTxt" ];

        _txtRefresh = _mcContent[ "_txtRefresh" ];
        _txtRefresh.htmlText = "<a href='event:1'>" + "<u>" + _txtRefresh.text + "</u></a>";
        var hrefSheet : StyleSheet = new StyleSheet();
        hrefSheet.setStyle( "a:hover", {"color": "#fc3636"} );
        _txtRefresh.styleSheet = hrefSheet;
        _txtRefresh.addEventListener( TextEvent.LINK, onLinkHandler );

        _alertTxt = _mcContent[ "_txtAlert" ];
//			_alertTxt.text = Config.getGameNotice();

        _txtRandomTips = _mcContent[ "_txtRandomTips" ];

        this.addChild( _loadBar );
        if ( this.stage != null )
            onAddToStage( null );
        else
            this.addEventListener( Event.ADDED_TO_STAGE, onAddToStage );
    }

    protected function onAddToStage( event : Event ) : void
    {
        _stage = this.stage;
        this.removeEventListener( Event.ADDED_TO_STAGE, onAddToStage );
        _stage.addEventListener( Event.RESIZE, onStageResize );
        onStageResize( null );
    }

    protected function onStageResize( event : Event ) : void
    {
//		if ( _loadBar )
//			_loadBar.scaleX = _loadBar.scaleY = this.stage.stageHeight / 900;

//		if ( _mcIcon ) {
//			_mcIcon.scaleX =  this.stage.stageWidth / 1500;
//			_mcIcon.scaleY =  this.stage.stageHeight / 900;
//			_mcIcon.x = this.stage.stageWidth >> 2;
//			_mcIcon.y = this.stage.stageHeight >> 2;
//		}
    }

    public function get allBytes() : Number
    {
        return _allBytes;
    }

    public function set allBytes( value : Number ) : void
    {
        _allBytes = value;
    }

    private var _randomTipsList : Array = [];

    public function startShowRandomTips( xml : XML ) : void
    {
        if ( !xml.hasOwnProperty( "randomTips" ) )
            return;
        for each( var tipXml : XML in xml.randomTips.tips )
            _randomTipsList.push( String( tipXml ) );

        if ( _randomTipsList.length == 0 )
            return;
        if ( _randomTipsList.length == 1 )
        {
            _txtRandomTips.text = _randomTipsList[ 0 ];
            return;
        }

        _timer = new Timer( 3000 );
        _timer.addEventListener( TimerEvent.TIMER, onTimer );
        onTimer( null );
        _timer.start();
    }

    protected function onTimer( event : TimerEvent ) : void
    {
        var str : String;
        do
        {
            str = _randomTipsList[ int( Math.random() * _randomTipsList.length ) ];
        }
        while ( str == _txtRandomTips.text );
        _txtRandomTips.text = str;
    }


    private function onLinkHandler( e : TextEvent ) : void
    {
        if ( ExternalInterface.available )
            navigateToURL( new URLRequest( ExternalInterface.call( "window.location.href.toString" ) ), "_self" );
    }

    private var _oldIndex : Number = -1;
    private var _loadedBytes : Number = 0;

    private var _bytes : Dictionary = new Dictionary( false );

    public function setStatus( curIndex : uint, total : uint, cLoadedBytes : Number, cTotalBytes : Number, dllName : String ) : void
    {
        var progress : Number = cLoadedBytes / cTotalBytes;
        _bytes[ curIndex.toString() ] = cTotalBytes;
        _currentProMc.scaleX = progress;
        _currentProTxt.text = "正在加载" + dllName + "(" + curIndex + "/" + total + ")";
        var oldBytes : Number = getBytes( curIndex );
        if ( isNaN( oldBytes ) )
            oldBytes = 0;
        var totalPro : Number = (oldBytes + cLoadedBytes) / _allBytes;
        totalPro = Math.min( 1, totalPro );
        _totalProMc.scaleX = totalPro;
        _lightMc.x = _totalProMc.x + _totalProMc.width;
        _totalProTxt.text = "总进度" + uint( totalPro * 100 ) + "%";
    }


    private var _totalBytes : Dictionary = new Dictionary( false );

    private function getBytes( curIndex : uint ) : Number
    {
        if ( _totalBytes.hasOwnProperty( curIndex.toString() ) )
            return _totalBytes[ curIndex.toString() ];
        var bytes : Number = 0;
        for ( var i1 : int = 1; i1 < curIndex; i1++ )
        {
            bytes += _bytes[ i1.toString() ];
        }
        _totalBytes[ curIndex.toString() ] = bytes;
        return bytes;
    }

    public function dispose() : void
    {
        _txtRefresh.removeEventListener( TextEvent.LINK, onLinkHandler );
        this.removeEventListener( Event.ADDED_TO_STAGE, onAddToStage );
        if ( _stage != null )
            _stage.removeEventListener( Event.RESIZE, onStageResize );
        if ( _timer != null )
            _timer.removeEventListener( TimerEvent.TIMER, onTimer );
    }

}
}