//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/9/5
//----------------------------------------------------------------------------------------------------------------------

package QFLib.DashBoard
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;

    //
    //
    //
    public class CConsoleCommandHandler
    {
        public function CConsoleCommandHandler( consolePageRef : CConsolePage )
        {
            m_theConsolePageRef = consolePageRef;

            // register default commands
            registerCommand( new CConsoleCommand_Help( this ) );
            registerCommand( new CConsoleCommand_ClearLog( consolePageRef ) );
            registerCommand( new CConsoleCommand_SmartObjectRecording() );
            registerCommand( new CConsoleCommand_SmartObjectDump( consolePageRef ) );
            registerCommand( new CConsoleCommand_SmartObjectClear() );
        }

        public function get commandMap() : CMap
        {
            return m_mapCommands;
        }

        public function registerCommand( cmd : IConsoleCommand ) : void
        {
            m_mapCommands.add( cmd.name, cmd );
        }
        public function findCommand( clazz : Class ) : IConsoleCommand {
            for each ( var cmd : IConsoleCommand in m_mapCommands ) {
                if ( cmd is clazz ) {
                    return cmd;
                }
            }
            return null;
        }

        public function parseCommand( sFullCommand : String ) : Boolean
        {
            var aCmds : Array = sFullCommand.split( " " );
            if( aCmds.length == 0 ) return true;

            var cmd : IConsoleCommand = m_mapCommands.find( aCmds[ 0 ] ) as IConsoleCommand;
            if( cmd == null )
            {
                Foundation.Log.logWarningMsg( "find no command: " + aCmds[ 0 ] );
                return false;
            }

            Foundation.Log.logMsg( "executing command: " + sFullCommand );
            if( cmd.onCommand( aCmds ) == false )
            {
                Foundation.Log.logWarningMsg( "command execution failed: " + sFullCommand );
                return false;
            }
            else return true;
        }

        //
        protected var m_mapCommands : CMap = new CMap();
        protected var m_theConsolePageRef : CConsolePage = null;
    }

}

import QFLib.DashBoard.CConsoleCommandHandler;
import QFLib.DashBoard.IConsoleCommand;
import QFLib.Foundation;
import QFLib.Memory.CSmartObjectSystem;

import mx.utils.StringUtil;


class CConsoleCommand_Help implements IConsoleCommand
{
    function CConsoleCommand_Help( cmdHandler : CConsoleCommandHandler )
    {
        m_theCommandHandler = cmdHandler;
    }

    public function get name() : String
    {
        return "help";
    }

    public function get description() : String
    {
        return "list all commands and their function description.";
    }
    public function get label() : String {
        return "help";
    }

    public function onCommand( args : Array ) : Boolean
    {
        var aCommands : Vector.<Object> = m_theCommandHandler.commandMap.toVector();
        aCommands.sort( function ( lhs : IConsoleCommand, rhs : IConsoleCommand ) : int
        {
            // the bigger z the later drawing
            if( lhs.name > rhs.name ) return 1;
            else if( lhs.name < rhs.name ) return -1;
            else return 0;
        });

        var cmd : IConsoleCommand;
        var iMaxCmdNameLength : int = 0;
        for each( cmd in aCommands )
        {
            if( cmd.name.length > iMaxCmdNameLength ) iMaxCmdNameLength = cmd.name.length;
        }

        for each( cmd in aCommands )
        {
            var s : String = "    " + cmd.name + ":";
            for( var i : int = ( iMaxCmdNameLength + 4 ) - cmd.name.length; i > 0; i-- ) s += " ";
            s += cmd.description;
            Foundation.Log.logMsg( s );
        }

        return true;
    }

    private var m_theCommandHandler : CConsoleCommandHandler;
}

import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.IConsoleCommand;


class CConsoleCommand_ClearLog implements IConsoleCommand
{
    function CConsoleCommand_ClearLog( consolePage : CConsolePage )
    {
        m_theConsolePage = consolePage;
    }

    public function get name() : String
    {
        return "clr";
    }

    public function get description() : String
    {
        return "clear log display.";
    }
    public function get label() : String {
        return "clear";
    }

    public function onCommand( args : Array ) : Boolean
    {
        m_theConsolePage.clearLogs();
        return true;
    }

    private var m_theConsolePage : CConsolePage;
}


class CConsoleCommand_SmartObjectRecording implements IConsoleCommand
{
    function CConsoleCommand_SmartObjectRecording()
    {
    }

    public function get name() : String
    {
        return "smartobject_recording";
    }

    public function get description() : String
    {
        return "enable / disable smart object recording, usage: smartobject_recording [enable/disable recording] [enable/disable stacktrace:1]";
    }
    public function get label() : String {
        return "smartobject_recording";
    }

    public function onCommand( args : Array ) : Boolean
    {
        if( args.length >= 2 )
        {
            var bEnable : Boolean = ( parseInt( args[1] ) == 0 ) ? false : true;
            CSmartObjectSystem.enableRecording = bEnable;

            if( bEnable ) Foundation.Log.logMsg( "smart object recording enabled." );
            else Foundation.Log.logMsg( "smart object recording disabled." );
        }
        else return false;

        if( args.length >= 3 )
        {
            var bEnableStacktrace : Boolean = ( parseInt( args[2] ) == 0 ) ? false : true;
            CSmartObjectSystem.enableStackTrace = bEnableStacktrace;

            if( bEnableStacktrace ) Foundation.Log.logMsg( "smart object stacktrace enabled." );
            else Foundation.Log.logMsg( "smart object stacktrace disabled." );
        }

        return true;
    }
}

class CConsoleCommand_SmartObjectDump implements IConsoleCommand
{
    function CConsoleCommand_SmartObjectDump( consolePage : CConsolePage )
    {
        m_theConsolePage = consolePage;
    }

    public function get name() : String
    {
        return "smartobject_dump";
    }

    public function get description() : String
    {
        return "dump current smart object records, usage: smartobject_dump [deep:1] [maxDumpRecords:20] [nameFilter:null]";
    }
    public function get label() : String {
        return "smartobject_dump";
    }

    public function onCommand( args : Array ) : Boolean
    {
        var bDeep : Boolean = false;

        if( args.length >= 2 )
        {
            var i : int = parseInt( args[1] );
            bDeep = ( parseInt( args[1] ) == 0 ) ? false : true;
        }

        var sDump : String = "";
        if( args.length >= 3 )
        {
            var iNumDumpRecords : int = parseInt( args[2] );
            if( args.length >= 4 )
            {
                var sFilter : String = args[3];
                sDump = CSmartObjectSystem.dump( bDeep, iNumDumpRecords, sFilter );
            }
            else sDump = CSmartObjectSystem.dump( bDeep, iNumDumpRecords );
        }
        else sDump = CSmartObjectSystem.dump( bDeep );

        //m_theConsolePage.
        Foundation.Log.logMsg( sDump );
        return true;
    }

    //
    var m_theConsolePage : CConsolePage;
}

class CConsoleCommand_SmartObjectClear implements IConsoleCommand
{
    function CConsoleCommand_SmartObjectClear()
    {
    }

    public function get name() : String
    {
        return "smartobject_clear";
    }

    public function get description() : String
    {
        return "clear current smart object records, usage: smartobject_clear";
    }
    public function get label() : String {
        return "smartobject_clear";
    }

    public function onCommand( args : Array ) : Boolean
    {
        CSmartObjectSystem.clear();
        Foundation.Log.logMsg( "all smart object records cleared." );
        return true;
    }
}