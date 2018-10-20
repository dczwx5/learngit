package
{

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import kof.editor.manager.ExportManager;

import morn.editor.Plugin;

public class Publish extends Plugin
{
    private static var NAME : String = "Publish";

    private static var s_export : Function;
    private static var s_forceExport : Function;

    public function Publish()
    {
        hookPublish();
    }

    private static function exporterClass() : Class
    {
        return getClass( "morn.editor.manager.0'" );
    }

    public static function keyManagerClass() : Class
    {
        return getClass( "morn.editor.manager.!-" );
    }

    private static function hookPublish() : void
    {
        if ( null == s_export && null == s_forceExport )
        {
            s_export = exporterClass()['export'];
            s_forceExport = exporterClass()['forceExport'];

//            var finder : DisplayObjectFinder = new DisplayObjectFinder();
//            var tab : * = finder.search( "MenuBar..Tab", builderStage );
//
//            if ( tab )
//            {
//                var numChild : int = (tab as DisplayObjectContainer).numChildren;
//                for ( var i : int = 0; i < numChild; ++i )
//                {
//                    var child : DisplayObject = tab.getChildByIndex( i );
//                }
//            }

            builderStage.addEventListener( KeyboardEvent.KEY_UP, _onBuilderStageKeyUpEventHandler, false, 50, true );
        }
    }

    private static function _onBuilderStageKeyUpEventHandler( event : KeyboardEvent ) : void
    {
        if ( event.keyCode == Keyboard.F12 )
        {
            event.stopImmediatePropagation();
            event.stopPropagation();

            event.preventDefault();
//            alert( NAME, "Hook as My publish." );

//            var logStr : String = DisplayObjectFinder.dumpLogStr( builderMain );
//            log( logStr );
//
//            System.setClipboard( logStr );

            publish();
        }
    }

    public static function initialize() : Boolean
    {
        return (null != s_export && null != s_forceExport);
    }

    override public function start() : void
    {
        super.start();

        if ( initialize() )
        {
            // alert( NAME, keyManagerClass()["7-"].toString() );
            publish();
        }

    }

    private static function publish( forced : Boolean = false, prompt : Boolean = true ) : void
    {
        getCmdManager().addEventListener( Event.COMPLETE, onCmdComplete );
        getCmdManager().addEventListener( ErrorEvent.ERROR, onCmdError );

        ExportManager.instance.export( forced, prompt );
    }

    private static function onCmdError( event : ErrorEvent ) : void
    {
        event.currentTarget.removeEventListener( Event.COMPLETE, onCmdComplete );
        event.currentTarget.removeEventListener( ErrorEvent.ERROR, onCmdError );
        getMessageManager().show( "publish failed: " + event.errorID + ", " + event.text );
    }

    private static function onCmdComplete( event : Event ) : void
    {
        event.currentTarget.removeEventListener( Event.COMPLETE, onCmdComplete );
        event.currentTarget.removeEventListener( ErrorEvent.ERROR, onCmdError );
        getMessageManager().show( "publish completed." );

        ExportManager.instance.exportDependItems();
    }

    protected static function getCmdManager() : *
    {
        var cmdManagerClass : Class = getClass( "morn.editor.manager.CmdManager" );
        return cmdManagerClass['instance'];
    }

    protected static function getMessageManager() : *
    {
        var msgManagerClass : Class = getClass( "morn.editor.manager.MessageManager" );
        return msgManagerClass['instance'];
    }

}
}

