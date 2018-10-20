package kof.game.gm.view.perf {

import QFLib.DashBoard.CDashBoard;
import QFLib.DashBoard.CDashPage;

import flash.text.TextField;

import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.perfs.CGamePerfEvent;
import kof.game.perfs.CGamePerfMonitor;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CGamePerfPage extends CDashPage {

    static public const TYPE_OF_SNAPSHOT : int = 1;
    static public const TYPE_OF_SYNC : int = 2;

    private var m_theResourceText : TextField = null;

    private var m_theMoniter : CGamePerfMonitor;

    private var m_iTriggerdCount : int = 0;

    private var m_pGmSystem : CAppSystem;

    private var m_vecItems : Vector.<CGamePerfItem>;

    public function CGamePerfPage( theDashBoard : CDashBoard, system : CAppSystem ) {
        super( theDashBoard );

        m_pGmSystem = system;

        m_theResourceText = new TextField();
        m_theResourceText.defaultTextFormat.font = "Terminal";
        m_theResourceText.defaultTextFormat.size = 18;
        m_theResourceText.textColor = 0xFFFFFF;
        m_theResourceText.wordWrap = true;
        m_theResourceText.multiline = true;
        m_theResourceText.border = true;
        m_theResourceText.borderColor = 0xFFFFFF;
        m_theResourceText.scrollV = m_theResourceText.numLines;
        m_thePageSpriteRoot.addChild( m_theResourceText );

        m_vecItems = new <CGamePerfItem>[];
    }

    override public function dispose() : void {
        super.dispose();

        m_theMoniter = null;
        m_theResourceText = null;

        if ( m_vecItems ) m_vecItems.splice( 0, m_vecItems.length );
        m_vecItems = null;
    }

    override public function get name() : String {
        return "GamePerfPage";
    }

    override public function onResize() : void {
        super.onResize();

        m_theResourceText.x = m_theDashBoardRef.pageX + 10;
        m_theResourceText.y = m_theDashBoardRef.pageY + 10;
        m_theResourceText.width = m_theDashBoardRef.pageWidth - 20 - 160 - 10;
        m_theResourceText.height = m_theDashBoardRef.pageHeight - 20;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( m_theMoniter == null ) {
            m_theMoniter = m_pGmSystem.stage.getSystem( CGamePerfMonitor ) as CGamePerfMonitor;

            if ( m_theMoniter ) {
                m_theMoniter.addEventListener( CGamePerfEvent.EVENT_TRIGGERED, _onTriggered, false, CEventPriority.DEFAULT, true );
                m_theMoniter.addEventListener( CGamePerfEvent.EVENT_SNAPSHOT, _onSnapshot, false, CEventPriority.DEFAULT, true );
                m_theMoniter.addEventListener( CGamePerfEvent.EVENT_SYNC, _onSync, false, CEventPriority.DEFAULT, true );
            }

            this.flush();
        }
    }

    private function _onTriggered( event : CGamePerfEvent ) : void {
        m_iTriggerdCount++;
        if ( m_iTriggerdCount % 2 == 0 )
            flush();

        if ( m_iTriggerdCount % 4 == 0 ) {
            shirk();
        }
    }

    private function _onSnapshot( event : CGamePerfEvent ) : void {
        var vItem : CGamePerfItem = new CGamePerfItem();
        vItem.iType = TYPE_OF_SNAPSHOT;
        m_vecItems.push( vItem );

        vItem.avgFrameRate = event.record.avgFrameRate;
        vItem.minFrameRate = event.record.minFrameRate;
        vItem.maxFrameRate = event.record.maxFrameRate;
        vItem.avgMemUsage = event.record.avgMemUsage;
        vItem.minMemUsage = event.record.minMemUsage;
        vItem.maxMemUsage = event.record.maxMemUsage;
    }

    private function _onSync( event : CGamePerfEvent ) : void {
        var vItem : CGamePerfItem = new CGamePerfItem();
        vItem.iType = TYPE_OF_SYNC;
        m_vecItems.push( vItem );

        vItem.avgFrameRate = event.record.avgFrameRate;
        vItem.minFrameRate = event.record.minFrameRate;
        vItem.maxFrameRate = event.record.maxFrameRate;
        vItem.avgMemUsage = event.record.avgMemUsage;
        vItem.minMemUsage = event.record.minMemUsage;
        vItem.maxMemUsage = event.record.maxMemUsage;

        flush();
    }

    public function shirk() : void {
        if ( m_vecItems && m_vecItems.length > 20 )
            m_vecItems.splice(0, m_vecItems.length - 20 );
    }

    public function flush() : void {
        trace( "Flush Game Perf Page ..." );
        var str : String = "";

        var l : int = Math.min( 20, m_vecItems.length );
        for ( var i : int = m_vecItems.length - 1; i > m_vecItems.length - l - 1; i-- ) {
            str += "<p>";
            if ( m_vecItems[i].iType == TYPE_OF_SYNC )
                str += "<font color=\"red\">";
            str += "FPS: min (" + m_vecItems[i].minFrameRate.toFixed(2)
                + ") max (" + m_vecItems[i].maxFrameRate.toFixed(2)
                + ") avg (" + m_vecItems[i].avgFrameRate.toFixed(2)
                + ") MEM: min (" + m_vecItems[i].minMemUsage.toFixed(0)
                + ") max (" + m_vecItems[i].maxMemUsage.toFixed(0)
                + ") avg (" + m_vecItems[i].avgMemUsage.toFixed(0)
                + ")";
            if ( m_vecItems[i].iType == TYPE_OF_SYNC )
                str += "</font>";
            str += "</p>";
        }

        if ( m_theResourceText ) {
            m_theResourceText.htmlText = str;
        }
    }

} // class CGamePerfPage
} // kof.game.gm.view.perf

class CGamePerfItem {

    public function CGamePerfItem() {
        super();
    }

    public var iType : int = 0;
    public var avgFrameRate : Number = 0;
    public var minFrameRate : Number = 0;
    public var maxFrameRate : Number = 0;
    public var avgMemUsage : Number = 0;
    public var minMemUsage : Number = 0;
    public var maxMemUsage : Number = 0;

}
