//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/17
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Memory
{
    import QFLib.Foundation.CMap;

    internal class CSmartObjectRecord
    {
        public function CSmartObjectRecord( sTypeName : String, obj : CSmartObject )
        {
            m_sTypeName = sTypeName;
            addObject( obj );
        }

        public function get typeName() : String
        {
            return m_sTypeName;
        }

        public function get allocateCount() : int
        {
            return m_iAllocateCount;
        }
        public function get objectCount() : int
        {
            return m_mapSmartObjects.count;
        }

        public function addObject( obj : CSmartObject ) : void
        {
            m_mapSmartObjects.add( obj, obj );
            m_iAllocateCount++;
        }
        public function removeObject( obj : CSmartObject ) : void
        {
            m_mapSmartObjects.remove( obj );
        }

        public function clear() : void
        {
            for each( var obj : CSmartObject in m_mapSmartObjects )
            {
                obj._clear();
            }
            m_mapSmartObjects.clear();

            m_sTypeName = null;
            m_iAllocateCount = 0;
        }

        public function dispose() : void
        {
            var vectSmartObjects : Vector.<Object> = m_mapSmartObjects.toVector();
            for each( var obj : CSmartObject in vectSmartObjects )
            {
                obj.dispose();
            }
        }

        public function dump( bDeep : Boolean, iMaxDumpRecords : int = 20 ) : String
        {
            var sContent : String = "";

            if( m_sTypeName != null )
            {
                sContent += "ObjectName: ";
                sContent += m_sTypeName;
                sContent += " --> ";
                sContent += m_mapSmartObjects.count;
                sContent += " in used of ";
                sContent += m_iAllocateCount;
                sContent += " allocation counts";

                if( bDeep )
                {
                    sContent += "\n";

                    var mapSmartObjectsByString : CMap = new CMap();
                    for each( var obj : CSmartObject in m_mapSmartObjects )
                    {
                        var sStackTrace : String = obj._stackTrace();

                        // try to remove redundant information of sStackTrace
                        var iStartIdx : int = sStackTrace.indexOf( m_sTypeName );
                        if( iStartIdx < 0 )
                        {
                            var names : Array = m_sTypeName .split( "::" );
                            iStartIdx = sStackTrace.indexOf( names[ names.length - 1 ] );
                        }
                        if( iStartIdx > 0 )
                        {
                            iStartIdx = sStackTrace.lastIndexOf( "\n",iStartIdx );
                            if( iStartIdx > 0 ) sStackTrace = sStackTrace.substr( iStartIdx );
                        }

                        var objCount : _CSmartObjectCount = mapSmartObjectsByString.find( sStackTrace ) as _CSmartObjectCount;
                        if( objCount == null )
                        {
                            mapSmartObjectsByString.add( sStackTrace, new _CSmartObjectCount( sStackTrace ) );
                        }
                        else objCount.m_iCount++;
                    }

                    function _Compare( lhs : Object, rhs : Object ) : Number
                    {
                        var l : _CSmartObjectCount = lhs as _CSmartObjectCount;
                        var r : _CSmartObjectCount = rhs as _CSmartObjectCount;
                        if( l.m_iCount > r.m_iCount ) return -1;
                        else if( l.m_iCount < r.m_iCount ) return 1;
                        else return 0;
                    }
                    var vectObjectCounts : Vector.<Object>  = mapSmartObjectsByString.sort( _Compare );

                    var i : int = 0;
                    for each( var objectCount : _CSmartObjectCount in vectObjectCounts )
                    {
                        i++;
                        if( i > iMaxDumpRecords )
                        {
                            sContent += "\n  ...Only display " + iMaxDumpRecords + " of " + vectObjectCounts.length + " records...\n";
                            break;
                        }

                        sContent += "  --[ " + i + " ]-- Counts: " + objectCount.m_iCount + ", StackTrace:";
                        sContent += objectCount.m_sStackTrace;
                        sContent += "\n";
                    }
                }

                sContent += "\n";
            }

            return sContent;
        }


        //
        private var m_mapSmartObjects : CMap = new CMap();
        private var m_sTypeName : String = null;
        private var m_iAllocateCount : int = 0;
    }

}


class _CSmartObjectCount
{
    public function _CSmartObjectCount( sStackTrace : String )
    {
        m_sStackTrace = sStackTrace;
        m_iCount = 1;
    }

    public function _addCounting() : void
    {
        m_iCount++;;
    }

    //
    internal var m_sStackTrace : String;
    internal var m_iCount : int;
}