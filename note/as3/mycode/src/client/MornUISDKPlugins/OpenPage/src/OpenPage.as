package
{
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;
import morn.editor.Plugin;
import morn.editor.pluginui.OpenPage.OpenPageDialogUI;

import util.Util;

/**
 * 打开页面
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class OpenPage extends Plugin
{
    private static var m_bInitialized : Boolean;
    private static var m_pWindow : OpenPageDialogUI;
    private static var m_pPageTree : *;
    private static var m_bShiftDown : Boolean;
    private var m_pTempFileList : Array;

    public function OpenPage()
    {
        super();
    }

    override public function start() : void
    {
        if ( initialize() )
        {
            m_pTempFileList = getFileList( workPath + "\\morn\\pages" );
            dialog.popup( m_pWindow, true );

            builderStage.addEventListener( KeyboardEvent.KEY_DOWN, _handleKey );
            m_pWindow.txtFileName.addEventListener( Event.CHANGE, _fileNameChanged );
            m_pWindow.txtFileName.textField.setSelection( 0, m_pWindow.txtFileName.text.length );
            builderStage.focus = m_pWindow.txtFileName;
        }
        else
        {
            log( "OpenPage" + "插件初始化失败" );
        }
    }

    private function _handleKey( event : KeyboardEvent ) : void
    {
        if ( event.keyCode == Keyboard.ESCAPE )
            remove();
        else if ( event.keyCode == Keyboard.SHIFT )
            m_bShiftDown = event.shiftKey;
    }

    private function remove() : void
    {
        m_bShiftDown = false;
        builderStage.removeEventListener( KeyboardEvent.KEY_DOWN, _handleKey );
        m_pWindow.txtFileName.removeEventListener( Event.CHANGE, _fileNameChanged );
        m_pWindow.close( Dialog.CLOSE );

        builderStage.focus = null;
    }

    static protected function initialize() : Boolean
    {
        if ( m_bInitialized )
            return m_bInitialized;

        if ( !m_pWindow )
        {
            m_pWindow = new OpenPageDialogUI();
            m_pWindow.closeHandler = new Handler( _onUIClose );
        }

        if ( !m_pPageTree )
        {
            m_pPageTree = finder.search( Util.pageTreePath, builderMain );
        }

        m_bInitialized = m_pPageTree && m_pWindow;

        return m_bInitialized;
    }

    private function _fileNameChanged( event : Event ) : void
    {

    }

    private static function _onUIClose( type : String = null ) : void
    {
        if ( !type )
            return;

        switch ( type )
        {
            case Dialog.OK:
            case Dialog.SURE:
            case Dialog.YES:
                // Open the page.
                log( "Request to OpenPage: " + m_pWindow.txtFileName.text );
                break;
            default:
                break;
        }
    }


}
}
