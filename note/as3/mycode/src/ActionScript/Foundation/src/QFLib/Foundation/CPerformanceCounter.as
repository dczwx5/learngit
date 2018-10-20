//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import QFLib.Foundation;
    import QFLib.Interface.IUpdatable;

    //
    //
    //
    public class CPerformanceCounter implements IUpdatable
    {
        public function CPerformanceCounter( fResetTimeInterval : Number = 5.0 )
        {
            m_theTimer.interval = fResetTimeInterval;
            reset();
        }

        [Inline]
        final public function get enabled() : Boolean
        {
            return m_bEnabled;
        }
        [Inline]
        final public function set enabled( bEnable : Boolean ) : void
        {
            m_bEnabled = bEnable;
        }

        [Inline]
        final public function get resetInterval() : Number
        {
            return m_theTimer.interval;
        }
        [Inline]
        final public function set resetInterval( fIntervalInSec : Number ) : void
        {
            m_theTimer.interval = fIntervalInSec;
        }

        [Inline]
        final public function sectionBegin( sSectionName : String ) : void
        {
            if( m_bFinallyEnabled == false )
            {
                if( m_vCurSections.length == 0 && m_bEnabled == true ) m_bFinallyEnabled = true;
                else return;
            }
            _beginSection( sSectionName );
        }

        [Inline]
        final public function sectionEnd( sSectionName : String ) : void
        {
            if( m_bFinallyEnabled == false ) return ;
            _endSection( sSectionName );
            if( m_vCurSections.length == 0 )
            {
                if( m_bEnabled == false ) m_bFinallyEnabled = false;
            }
        }

        public function reset() : void
        {
            m_theTimer.reset();
            for each( var section : CSection in  m_mapSections )
            {
                section.reset();
            }
        }

        public virtual function update( fDeltaTime : Number ) : void
        {
        }

        public function dump( bXmlFormat : Boolean = false, sWithFilter : String = null, iWithinLayer : int = 0 ) : String
        {
            if( m_theTimer.isOnTime() ) this.reset();

            var fCurrentTime : Number = m_theTimer.seconds();
            if( fCurrentTime < 0.1 ) return m_theDumpContext.m_sContext;
            else m_theDumpContext.m_sContext = "";

            var iLayer : int = 1;
            for each( var section : CSection in  m_mapSections )
            {
                section.dump( fCurrentTime, m_theDumpContext, bXmlFormat, iLayer, sWithFilter, iWithinLayer );
            }

            return m_theDumpContext.m_sContext;
        }

        protected function _beginSection( sSectionName : String ) : void
        {
            var curSection : CSection;

            if( m_vCurSections.length == 0 )
            {
                curSection = m_mapSections.find( sSectionName );
                if( curSection == null )
                {
                    curSection = new CSection( sSectionName );
                    m_mapSections.add( sSectionName, curSection );
                }
            }
            else
            {
                var orgSection : CSection = m_vCurSections[ m_vCurSections.length - 1 ];
                curSection = orgSection.m_mapChildSections.find( sSectionName );
                if( curSection == null )
                {
                    curSection = new CSection( sSectionName );
                    orgSection.m_mapChildSections.add( sSectionName, curSection );
                }
            }

            m_vCurSections.push( curSection );
            curSection.start();
        }

        protected function _endSection( sSectionName : String ) : void
        {
            if( m_vCurSections.length == 0 )
            {
                Foundation.Log.logErrorMsg( "beginSection/endSection function call not match!...:" + sSectionName );
                return ;
            }

            var curSection : CSection = m_vCurSections[ m_vCurSections.length - 1 ];
            if( curSection.m_sName != sSectionName )
            {
                Foundation.Log.logErrorMsg( "Performance counter's tag name not match!....:(" + curSection.m_sName + " != " + sSectionName + ")" );

                var bCorrected : Boolean = false;
                for( var i : int = m_vCurSections.length - 2; i >= 0; i-- )
                {
                    curSection = m_vCurSections[ i ];
                    if( curSection.m_sName == sSectionName )
                    {
                        // try re-correcting the error
                        for( var j : int = m_vCurSections.length - 1; j > i; j-- ) m_vCurSections.pop();
                        bCorrected = true;
                    }
                }

                if( bCorrected == false )
                    return ;
            }

            curSection.end();
            m_vCurSections.pop();
        }

        //
        //
        protected var m_mapSections : CMap = new CMap();
        protected var m_vCurSections : Vector.<CSection> = new Vector.<CSection>();
        protected var m_theDumpContext : CDumpContext = new CDumpContext();
        protected var m_theTimer : CTimer = new CTimer( 5.0 );
        protected var m_bEnabled : Boolean = false;
        protected var m_bFinallyEnabled : Boolean = true;
    }

}

import QFLib.Foundation.CMap;
import QFLib.Foundation.CTimer;

class CSection
{
    public function CSection( sName : String )
    {
        m_sName = sName;
    }

    [Inline]
    final public function start() : void
    {
        m_theTimer.reset();
        m_iCounts++;
        m_iTotalCounts++;
    }
    [Inline]
    final public function end() : void
    {
        var fTime : Number = m_theTimer.seconds();
        m_fTime += fTime;
        m_fTotalTime += fTime;
    }
    [Inline]
    final public function reset() : void
    {
        if( m_iCounts > 0 ) // remain the last result if count == 0
        {
            m_fLastTime = m_fTime;
            m_iLastCounts = m_iCounts;
            m_fTime = 0.0;
            m_iCounts = 0;

            for each( var section : CSection in  m_mapChildSections )
            {
                section.reset();
            }
        }
    }

    public function dump( fCurrentTime : Number, theDumpContext : CDumpContext, bXmlFormat : Boolean, iLayer : int, sWithFilter : String, iWithinLayer : int ) : void
    {
        if( sWithFilter != null && sWithFilter != "" )
        {
            if( _findFilter( sWithFilter ) == false ) return ;
        }
        if( iWithinLayer > 0 && iLayer > iWithinLayer ) return ;

        theDumpContext.m_sNamePart = "";
        for( i = 0; i < iLayer; i++ ) theDumpContext.m_sNamePart += ">";
        theDumpContext.m_sNamePart += " " + this.m_sName + ": ";

        if( theDumpContext.m_iLongestNameLen < theDumpContext.m_sNamePart.length ) theDumpContext.m_iLongestNameLen = theDumpContext.m_sNamePart.length;
        var iExtraSpacesLen : int = theDumpContext.m_iLongestNameLen - theDumpContext.m_sNamePart.length;
        for( i = 0; i < iExtraSpacesLen; i++ ) theDumpContext.m_sNamePart += " ";

        var i : int;
        var sAvgTime : String;
        var sTime : String;
        if( m_iCounts == 0 )
        {
            if( bXmlFormat ) theDumpContext.m_sContext += "<font face =\"Terminal\" size=\"" + 12 + "\" color=\"#AAAACC\">";

            if( m_fLastTime / m_iLastCounts > 1.0 ) sAvgTime = Number( m_fLastTime / m_iLastCounts ).toFixed( 2 ) + "s";
            else sAvgTime = Number( m_fLastTime / m_iLastCounts * 1000.0 ).toFixed( 2 ) + "ms";
            if( m_fLastTime > 1.0 ) sTime = Number( m_fLastTime ).toFixed( 2 ) + "s";
            else sTime = Number( m_fLastTime * 1000.0 ).toFixed( 2 ) + "ms";

            theDumpContext.m_sContext += theDumpContext.m_sNamePart + "----" +
                                         "%(Avg: " + sAvgTime + ", Time: " + sTime + ", counts: " + m_iLastCounts + ")" +
                                         ",\tTotal(Time: " + m_fTotalTime.toFixed( 2 ) + "s, Counts: " + m_iTotalCounts + ")";
        }
        else
        {
            if( bXmlFormat ) theDumpContext.m_sContext += "<font face =\"Terminal\" size=\"" + 12 + "\" color=\"#FFFFFF\">";

            if( m_fTime / m_iCounts > 1.0 ) sAvgTime = Number( m_fTime / m_iCounts ).toFixed( 2 ) + "s";
            else sAvgTime = Number( m_fTime / m_iCounts * 1000.0 ).toFixed( 2 ) + "ms";
            if( m_fTime > 1.0 ) sTime = Number( m_fTime ).toFixed( 2 ) + "s";
            else sTime = Number( m_fTime * 1000.0 ).toFixed( 2 ) + "ms";

            theDumpContext.m_sContext += theDumpContext.m_sNamePart + Number( this.m_fTime / fCurrentTime * 100.0 ).toFixed( 2 ) +
                                         "%(Avg: " + sAvgTime + ", Time: " + sTime + ", counts: " + m_iCounts +
                                         ", cnts/sec: " + Number( m_iCounts / fCurrentTime ).toFixed( 2 ) + ")" +
                                         ",\tTotal(Time: " + m_fTotalTime.toFixed( 2 ) + "s, Counts: " + m_iTotalCounts + ")";
        }

        if( bXmlFormat ) theDumpContext.m_sContext += "</font>";
        theDumpContext.m_sContext += "\n";

        var iNextLayer : int = iLayer + 1;
        for each( var section : CSection in  m_mapChildSections )
        {
            section.dump( fCurrentTime, theDumpContext, bXmlFormat, iNextLayer, sWithFilter, iWithinLayer );
        }
    }

    public function _findFilter( sWithFilter : String ) : Boolean
    {
        if( this.m_sName.indexOf( sWithFilter ) >= 0 ) return true;
        else
        {
            for each( var section : CSection in  m_mapChildSections )
            {
                if( section._findFilter( sWithFilter ) ) return true;
            }
        }

        return false;
    }

    public var m_mapChildSections : CMap = new CMap();
    public var m_sName : String = "";
    public var m_fLastTime : Number = 0.0;
    public var m_fTime : Number = 0.0;
    public var m_fTotalTime : Number = 0.0;
    public var m_iLastCounts : int = 0;
    public var m_iCounts : int = 0;
    public var m_iTotalCounts : int = 0;

    private var m_theTimer : CTimer = new CTimer();
}

class CDumpContext
{
    public function CDumpContext() {}
    public var m_sContext : String = "";
    public var m_iLongestNameLen : int = 0;
    public var m_sNamePart : String = "";
}