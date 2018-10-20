//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/17
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Memory
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CTime;

    import flash.net.FileReference;

    import flash.utils.getQualifiedClassName;

    public class CSmartObjectSystem
    {
        public function CSmartObjectSystem()
        {
        }

        public static function get enableRecording() : Boolean
        {
            return m_bEnableRecording;
        }
        public static function set enableRecording( b : Boolean ) : void
        {
            m_bEnableRecording = b;
            if( b )
            {
                m_fEnableRecordingTimestamp = CTime.getCurrentTimestamp();
                m_fDisableRecordingTimestamp = 0.0;
            }
            else
            {
                m_fDisableRecordingTimestamp = CTime.getCurrentTimestamp();
            }
        }
        public static function get enableStackTrace() : Boolean
        {
            return m_bEnableStackTrace;
        }
        public static function set enableStackTrace( b : Boolean ) : void
        {
            m_bEnableStackTrace = b;
        }

        public static function numInUsedObjects( sClassName : String ) : int
        {
            var record : CSmartObjectRecord = m_mapSmartObjectRecords.find( sClassName ) as CSmartObjectRecord;
            if( record != null )
            {
                return record.objectCount;
            }
            return 0;
        }
        public static function numAllocationCounts( sClassName : String ) : int
        {
            var record : CSmartObjectRecord = m_mapSmartObjectRecords.find( sClassName ) as CSmartObjectRecord;
            if( record != null )
            {
                return record.allocateCount;
            }
            return 0;
        }

        public static function get numRecords() : int
        {
            return m_mapSmartObjectRecords.count;
        }

        public static function dump( bDeep : Boolean, iMaxDumpRecords : int = 20, sObjectNameFilter : String = null ) : String
        {
            var sContent : String = "";
            var record : CSmartObjectRecord;

            function _compare( lhs : Object, rhs : Object ) : Number
            {
                var l : CSmartObjectRecord = lhs as CSmartObjectRecord;
                var r : CSmartObjectRecord = rhs as CSmartObjectRecord;
                if( l.objectCount > r.objectCount ) return -1;
                else if( l.objectCount < r.objectCount ) return 1;
                else return 0;
            }
            var vectObjects : Vector.<Object>  = m_mapSmartObjectRecords.sort( _compare );

            var iTotal : int = 0;
            var iTotalInUsed : int = 0;
            var iTotalAllocationCount : int = 0;
            for each( record in vectObjects )
            {
                if( sObjectNameFilter == null || record.typeName.indexOf( sObjectNameFilter ) >= 0 )
                {
                    iTotal++;
                    iTotalInUsed += record.objectCount;
                    iTotalAllocationCount += record.allocateCount;
                }
            }

            var sStartTime : String = "N/A";
            var sEndTime : String = "N/A";
            var fDuration : Number = 0.0;
            if( m_fEnableRecordingTimestamp > 0.0 )
            {
                sStartTime = CTime.getTimeString( m_fEnableRecordingTimestamp );
                if( m_fDisableRecordingTimestamp > 0.0 )
                {
                    sEndTime = CTime.getTimeString( m_fDisableRecordingTimestamp );
                    fDuration = ( m_fDisableRecordingTimestamp - m_fEnableRecordingTimestamp ) / 1000.0;
                }
                else
                {
                    sEndTime = CTime.getCurrentTimeString();
                    fDuration = ( CTime.getCurrentTimestamp() - m_fEnableRecordingTimestamp ) / 1000.0;
                }
            }

            sContent += "\n======================================================================================================================================";
            sContent += "\n>>> Start dumping smart object info: Total " + iTotal + " records from time: " + sStartTime + " to " + sEndTime + "(" + fDuration + "s)";
            sContent += "\n>>> Totally there are " + iTotalInUsed + " objects in used of all " + iTotalAllocationCount + " allocation counts";
            if( sObjectNameFilter != null ) sContent += " with filter - '" + sObjectNameFilter + "'";
            sContent += "\n======================================================================================================================================\n";

            var i : int = 0;
            for each( record in vectObjects )
            {
                if( sObjectNameFilter == null || record.typeName.indexOf( sObjectNameFilter ) >= 0 )
                {
                    i++;
                    if ( i > iMaxDumpRecords ) {
                        sContent += "\n  ...Only display " + iMaxDumpRecords + " of " + vectObjects.length + " records...\n";
                        break;
                    }

                    sContent += "  ==[ " + i + " ]== ";
                    sContent += record.dump( bDeep, iMaxDumpRecords );
                    sContent += "  ------------------------------------------------------------------------------------------------------------------------------------\n";
                }
            }
            sContent += "\n";
            sContent += "======================================================================================================================================\n";

            return sContent;
        }

        public static function dumpToFile( sFilename : String, bDeep : Boolean, iMaxDumpRecords : int = 20 ) : void
        {
            var sContent : String = dump( bDeep, iMaxDumpRecords );

            var file : FileReference = new FileReference();
            file.save( sContent, sFilename );
        }

        public static function clear() : void
        {
            for each( var record : CSmartObjectRecord in m_mapSmartObjectRecords )
            {
                record.clear();
            }
            m_mapSmartObjectRecords.clear();
        }

        public static function disposeAll() : void
        {
            var vectSmartObjects : Vector.<Object> = m_mapSmartObjectRecords.toVector();
            for each( var record : CSmartObjectRecord in vectSmartObjects )
            {
                record.dispose();
            }
        }
        public static function dispose( sClassName : String ) : void
        {
            var record : CSmartObjectRecord = m_mapSmartObjectRecords.find( sClassName ) as CSmartObjectRecord;
            if( record != null )
            {
                record.dispose();
            }
        }


        //
        //
        public static function add( obj : CSmartObject ) : CSmartObjectRecord
        {
            if( obj == null ) return null;
            if( obj.m_theSmartObjRecord != null )
            {
                Foundation.Log.logErrorMsg( "Add an object more than once...: " + getQualifiedClassName( obj ) );
                return null;
            }

            var sTypeName : String = getQualifiedClassName( obj );
            //var names : Array = sTypeName .split( "::" );
            //sTypeName = names[ names.length - 1 ];

            var record : CSmartObjectRecord = m_mapSmartObjectRecords.find( sTypeName ) as CSmartObjectRecord;
            if( record == null )
            {
                record = new CSmartObjectRecord( sTypeName, obj );
                m_mapSmartObjectRecords.add( record.typeName, record );
            }
            else
            {
                record.addObject( obj );
            }

            return record;
        }

        public static function remove( obj : CSmartObject ) : void
        {
            if( obj == null ) return;

            var record : CSmartObjectRecord = obj.m_theSmartObjRecord;
            if( record != null )
            {
                record.removeObject( obj );
            }
            else
            {
                Foundation.Log.logErrorMsg( "Remove an object more than once...: " + getQualifiedClassName( obj ) )
            }
        }


        //
        public static var m_fEnableRecordingTimestamp : Number = 0.0;
        public static var m_fDisableRecordingTimestamp : Number = 0.0;

        internal static var m_mapSmartObjectRecords : CMap = new CMap();
        internal static var m_bEnableRecording : Boolean = false;
        internal static var m_bEnableStackTrace : Boolean = true;
    }
}

