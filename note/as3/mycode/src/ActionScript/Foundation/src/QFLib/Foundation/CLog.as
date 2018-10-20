//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/1/28
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    //
    //
    //
    public class CLog
    {

        public static const LOG_LEVEL_TRACE : int = -1;
        public static const LOG_LEVEL_NORMAL : int = 0;
        public static const LOG_LEVEL_WARNING : int = 1;
        public static const LOG_LEVEL_ERROR : int = 2;
        public static const LOG_LEVEL_ABOVE_ERROR : int = LOG_LEVEL_ERROR + 1;

        public static var LOG_THRESHOLD : int = LOG_LEVEL_NORMAL;

        public function CLog( sLogCategory : String = null, bLogLine : Boolean = false )
        {
            m_fnStdOut = this._stdOut;
            m_sLogCategory = sLogCategory;
            m_bLogLine = bLogLine;
        }

        final public function logMsg( s : String ) : void
        {
            if (LOG_THRESHOLD <= LOG_LEVEL_NORMAL)
                _logOut( LOG_LEVEL_NORMAL, s, m_bLogTime, m_bMarkLogLevel );
        }

        final public function logWarningMsg( s : String ) : void
        {
            if (LOG_THRESHOLD <= LOG_LEVEL_WARNING)
                _logOut( LOG_LEVEL_WARNING, s, m_bLogTime, m_bMarkLogLevel );
        }

        final public function logErrorMsg( s : String ) : void
        {
            if (LOG_THRESHOLD <= LOG_LEVEL_ERROR)
                _logOut( LOG_LEVEL_ERROR, s, m_bLogTime, m_bMarkLogLevel );
        }

        final public function logTraceMsg( s : String ) : void
        {
            if (LOG_THRESHOLD <= LOG_LEVEL_TRACE)
                _logOut( LOG_LEVEL_TRACE, s, m_bLogTime, m_bMarkLogLevel );
        }

        final public function flush() : void
        {
        }

        //
        // function _stdOut( iLogLevel : int, bLogToFile : Boolean, bOutputDebugString : Boolean, sLogMsg : String ) : void
        //
        [Inline]
        final public function setStdOutFunction( fn : Function ) : void
        {
            m_fnStdOut = fn;
        }

        //
        // function _customOut( iLogLevel : int, sTime : String, s : String, sLogFullMsg : String ) : void
        //
        final public function setCustomLogFunction( fn : Function ) : void
        {
            m_fnCustomLog = fn;
        }

        [Inline]
        final public function get outputToConsole() : Boolean
        {
            return m_bOutputToConsole;
        }
        [Inline]
        final public function set outputToConsole( value : Boolean ) : void
        {
            m_bOutputToConsole = value;
        }

        [Inline]
        final public function get logLine() : Boolean
        {
            return m_bLogLine;
        }
        [Inline]
        final public function set logLine( value : Boolean ) : void
        {
            m_bLogLine = value;
        }

        [Inline]
        final public function get logCategory() : String
        {
            return m_sLogCategory;
        }
        [Inline]
        final public function set logCategory( value : String ) : void
        {
            m_sLogCategory = value;
        }

        [Inline]
        final public function get logPath() : String
        {
            return m_sLogPath;
        }
        [Inline]
        final public function set logPath( value : String ) : void
        {
            m_sLogPath = value;
        }

        [Inline]
        final public function get logFilename() : String
        {
            return m_sLogFilename;
        }
        [Inline]
        final public function set logFilename( value : String ) : void
        {
            m_sLogFilename = value;
        }

        [Inline]
        final public function get logFileExt() : String
        {
            return m_sLogFileExt;
        }
        [Inline]
        final public function set logFileExt( value : String ) : void
        {
            m_sLogFileExt = value;
        }

        [Inline]
        final public function get logToFile() : Boolean
        {
            return m_bLogToFile;
        }
        [Inline]
        final public function set logToFile( value : Boolean ) : void
        {
            m_bLogToFile = value;
        }

        [Inline]
        final public function get logTime() : Boolean
        {
            return m_bLogTime;
        }
        [Inline]
        final public function set logTime( value : Boolean ) : void
        {
            m_bLogTime = value;
        }

        [Inline]
        final public function get markLogLevel() : Boolean
        {
            return m_bMarkLogLevel;
        }
        [Inline]
        final public function set markLogLevel( value : Boolean ) : void
        {
            m_bMarkLogLevel = value;
        }

        //
        //
        private function _logOut( iLogLevel : int, s : String, bLogTime : Boolean, bMarkLogLevel : Boolean ) : void
        {
            var sTime : String = "";
            if( bLogTime )
            {
                sTime = CTime.getCurrentTimeString();
            }

            var sLogFullMsg : String = "";

            if( bMarkLogLevel )
            {
                if( iLogLevel == LOG_LEVEL_ERROR ) sLogFullMsg += "!!";
                else if( iLogLevel == LOG_LEVEL_WARNING ) sLogFullMsg += "! ";
                else sLogFullMsg += "  ";
            }

            if( bLogTime )
            {
                sLogFullMsg += sTime;
                sLogFullMsg += "  ";
            }

            var sMsgCategory : String = m_sLogCategory;
            if( sMsgCategory == null && m_bLogLine )
            {
                var e : Error = new Error();
                sMsgCategory = e.getStackTrace();
                var lines : Array = sMsgCategory.split( "\n\t" );
                if( lines && lines.length )
                {
                    var line : String = lines.length >= 4 ? lines[3] : "";
                    var idx : int = line.lastIndexOf("\\");
                    if( idx >= 0 ) line = line.substr( idx + 1 );
                    if( line.charAt(line.length - 1) == ']' ) line = line.substr(0, line.length - 1);
                    sMsgCategory = line;
                }
            }

            sLogFullMsg += sMsgCategory ? "[" + sMsgCategory + "] " : "";
            sLogFullMsg += s;

            if( m_fnCustomLog != null ) m_fnCustomLog( iLogLevel, sTime, s, sLogFullMsg );
            m_fnStdOut( iLogLevel, m_bLogToFile, m_bOutputToConsole, sLogFullMsg );
        }

        private function _stdOut( iLogLevel : int, bLogToFile : Boolean, bOutputDebugString : Boolean, sLogFullMsg : String ) : void
        {
            if( bOutputDebugString ) trace( sLogFullMsg );
        }

        //
        private var m_sLogPath : String = "/logs/";
        private var m_sLogFilename : String = "default";
        private var m_sLogFileExt : String = ".log";

        private var m_fnStdOut : Function = null;
        private var m_fnCustomLog : Function = null;
        private var m_bLogToFile : Boolean = true;
        private var m_bOutputToConsole : Boolean = true;
        private var m_bLogTime : Boolean = true;
        private var m_bMarkLogLevel : Boolean = true;

        private var m_sLogCategory : String;
        private var m_bLogLine : Boolean;

    }

}