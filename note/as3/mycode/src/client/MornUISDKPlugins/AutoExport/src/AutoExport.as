package
{
import flash.desktop.NativeApplication;
import flash.events.ErrorEvent;
import flash.events.Event;

import kof.editor.manager.ExportManager;

import morn.editor.Plugin;

public class AutoExport extends Plugin
{
    private static const NAME : String = "AutoExport";
    private var m_iStatus : int = 0;

    public function AutoExport()
    {
        super();
        m_iStatus = 1;
        autoStart();
    }

    public static function autoStart() : void
    {
        execute();
    }

    protected static function execute() : void
    {
        var exportManageClassName : String = "morn.editor.manager.0'";
        if ( !hasClass( exportManageClassName ) )
        {
            getMessageManager().show( NAME + " not found.");
            exit( 1 );
        }
        else
        {
            getCmdManager().addEventListener( Event.COMPLETE, onCmdComplete );
            getCmdManager().addEventListener( ErrorEvent.ERROR, onCmdError );

//            var exportManagerClass : Class = getClass( exportManageClassName );
//                exportManagerClass['forceExport']();
//            exportManagerClass['export']();
            ExportManager.instance.export( true, false );
        }
    }

    override public function start() : void
    {
        if ( m_iStatus != 0 )
            return;

        super.start();
        if ( initialize() )
        {
            log( NAME + " Auto running ..." );
            execute();
            m_iStatus = 1;
        }
        else
        {
            alert( NAME, "start failed." );
        }
    }

    private static function onCmdError( event : ErrorEvent ) : void
    {
        event.currentTarget.removeEventListener( Event.COMPLETE, onCmdComplete );
        event.currentTarget.removeEventListener( ErrorEvent.ERROR, onCmdError );
        getMessageManager().show( "publish failed: " + event.errorID + ", " + event.text );
//        alert( NAME, "onCmdError" );
        exit( 1 );
    }

    private static function onCmdComplete( event : Event ) : void
    {
        event.currentTarget.removeEventListener( Event.COMPLETE, onCmdComplete );
        event.currentTarget.removeEventListener( ErrorEvent.ERROR, onCmdError );
        getMessageManager().show( "publish completed." );
//        alert( NAME, " onCmdComplete" );

//        setTimeout( exit, 2000, 0 );
        ExportManager.instance.exportDependItems();
        exit( 0 );
    }

    private static function exit( exitCode : int ) : void
    {
        NativeApplication.nativeApplication.exit( exitCode );
    }

    private static function initialize() : Boolean
    {
        return true;
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
