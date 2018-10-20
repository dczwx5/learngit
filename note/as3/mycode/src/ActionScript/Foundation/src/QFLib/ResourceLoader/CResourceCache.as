//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/8
//----------------------------------------------------------------------------------------------------------------------

package QFLib.ResourceLoader
{

import QFLib.Foundation.CPath;
import QFLib.Foundation.CTimer;
    import QFLib.Memory.*;
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;

    import flash.events.TimerEvent;
import flash.utils.Timer;

    //
    //
    //
    public class CResourceCache extends CSmartObject
    {
        public static function instance() : CResourceCache
        {
            if( s_theInstance == null ) s_theInstance = new CResourceCache();
            return s_theInstance;
        }

        public function CResourceCache( fUpdateTimeInterval : Number = 5.0, fFPS : Number = 15.0 /* set fFPS to non-zero if you want CResourceLoader call Update() itself */ )
        {
            super();

            m_fUpdateTimeInterval = fUpdateTimeInterval;

            if( fFPS > 0.0 )
            {
                var iMilliSec : int = 1000.0 / fFPS;

                m_theRunTimer = new Timer( iMilliSec );
                m_theRunTimer.addEventListener( TimerEvent.TIMER, _onTimer );
                m_theRunTimer.start();

                m_theTimer = new CTimer();
                m_theTimer.reset();
            }
        }

        public override function dispose() : void
        {
            m_theRunTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
            m_theRunTimer.stop();
            m_theRunTimer = null;

            m_theTimer = null;

            for each( var resource : CResource in m_mapResources )
            {
                resource.dispose();
                if( resource.refCounts > 0 )
                {
                    Foundation.Log.logErrorMsg( "There are resource leaks while disposing resource: " + resource.name + " from CResourceCache.(counts: " + resource.refCounts + ")" );
                }
            }
            m_mapResources.clear();

            super.dispose();

            if( this == s_theInstance ) s_theInstance = null;
        }

        [Inline]
        final public function getCombinedKeyName( sName : String, sType : String ) : String
        {
            return ( sType == null ) ? sName : sName + "[" + sType + "]";
        }

        public function add( sName : String, sType : String, theResource : CResource, bReferenceCount : Boolean = true, bSuppressAddError : Boolean = false ) : void
        {
            var sCombinedKeyName : String = this.getCombinedKeyName( sName, sType );
            var res : CResource = m_mapResources.find( sCombinedKeyName ) as CResource;
            if( res == null )
            {
                theResource.setResourceCache( this );
                if( bReferenceCount ) theResource.addRefCounter();
                m_mapResources.add( sCombinedKeyName, theResource );
            }
            else
            {
                if( bSuppressAddError == false ) Foundation.Log.logErrorMsg( "Resource already existed in Cache: " + sName );
            }
        }

        public function remove( sName : String, sType : String ) : void
        {
            var sCombinedKeyName : String = this.getCombinedKeyName( sName, sType );
            var theResource : CResource = m_mapResources.find( sCombinedKeyName ) as CResource;
            if( theResource != null )
            {
                m_mapResources.remove( sCombinedKeyName );
                theResource.dispose();
            }
        }

        public function isExisted( sName : String, sType : String ) : Boolean
        {
            var sCombinedKeyName : String = this.getCombinedKeyName( sName, sType );
            return m_mapResources.find( sCombinedKeyName ) != null ? true : false;
        }

        public function create( sName : String, sType : String ) : CResource
        {
            var sCombinedKeyName : String = this.getCombinedKeyName( sName, sType );
            var theResource : CResource = m_mapResources.find( sCombinedKeyName ) as CResource;
            if( theResource != null )
            {
                theResource.addRefCounter();
                return theResource;
            }
            else return null;
        }

        public function find( sName : String, sType : String ) : CResource // only get the reference, no reference count
        {
            var sCombinedKeyName : String = this.getCombinedKeyName( sName, sType );
            return m_mapResources.find( sCombinedKeyName ) as CResource;
        }

        public function get numResources() : int
        {
            return m_mapResources.count;
        }
        public function get numReferencedResources() : int
        {
            var iCount : int = 0;
            for each( var resource : CResource in m_mapResources )
            {
                if( resource.refCounts > 1 ) iCount++;
            }

            return iCount;
        }
        public function get numUnReferencedResources() : int
        {
            var iCount : int = 0;
            for each( var resource : CResource in m_mapResources )
            {
                if( resource.refCounts == 1 ) iCount++;
            }

            return iCount;
        }

        public function update( fDeltaTime : Number ) : void
        {
            m_fUpdateTime += fDeltaTime;

            if( m_fUpdateTime > m_fUpdateTimeInterval )
            {
                var resource : CResource;
                var vResourcesToBeDeleted : Vector.<CResource> = new  Vector.<CResource>();
                for each( resource in m_mapResources )
                {
                    if( resource.refCounts == 1 )
                    {
                        if( resource.isUnReferencedTimesUp( m_fUpdateTimeInterval ) ) vResourcesToBeDeleted.push( resource );
                    }
                }

                for each( resource in vResourcesToBeDeleted )
                {
                    var sCombinedKeyName : String = this.getCombinedKeyName( resource.name, resource.typeName );
                    m_mapResources.remove( sCombinedKeyName );
                    resource.dispose();
                }

                m_fUpdateTime %= m_fUpdateTimeInterval;
            }
        }

        public function dump( bDetail : Boolean, bXmlFormat : Boolean = false, sWithFilter : String = null,
                                iWithCounts : int = 0, sWithCountCondition : String = null, iSortMethod : int = 0 ) : String
        {
            var sContext : String = "";

            if( bXmlFormat ) sContext += "<font face =\"Terminal\" size=\"" + 12 + "\" color=\"#FFFFFF\">";
            sContext += "ResourceCache: " + this.numReferencedResources + " / " + this.numResources + " (Referenced/Total)";
            if( bXmlFormat ) sContext += "</font>";

            if( bDetail )
            {
                if( bXmlFormat ) sContext += "<font face =\"Terminal\" size=\"" + 12 + "\" color=\"#FFFFFF\">";
                sContext += "\nCounts by type: " + _dumpResourcesByType() + "\n";
                if( bXmlFormat ) sContext += "</font>";

                var resource : CResource;
                var iLongestNameLen : int = 0;
                var aResources : Array = m_mapResources.toArray();

                if( iSortMethod == 0 )
                {
                    aResources.sort( function ( lhs : CResource, rhs : CResource ) : int
                    {
                        if( lhs.name > rhs.name ) return 1;
                        else if( lhs.name < rhs.name ) return -1;
                        else return 0;
                    } );
                }
                else if( iSortMethod == 1 )
                {
                    aResources.sort( function ( lhs : CResource, rhs : CResource ) : int
                    {
                        var fDiff : Number = lhs.createdTimestamp - rhs.createdTimestamp;
                        if( fDiff > 0 ) return 1;
                        else if( fDiff < 0 ) return -1;
                        else return 0;
                    } );
                }
                else if( iSortMethod == 2 )
                {
                    aResources.sort( function ( lhs : CResource, rhs : CResource ) : int
                    {
                        return rhs.refCounts - lhs.refCounts;
                    } );
                }

                // get the longest resource name length
                for each( resource in aResources )
                {
                    if( iLongestNameLen < resource.name.length ) iLongestNameLen = resource.name.length;
                }

                var sAdditionalText : String = "";
                var i : int;
                var iCount : int = 0;
                for each( resource in aResources )
                {
                    if( _isMatchCondiction( resource, sWithFilter, iWithCounts, sWithCountCondition ) == false ) continue;

                    iCount++;

                    if( bXmlFormat ) sContext += "<font face =\"Terminal\" size=\"" + 12 + "\" color=\"#FFFFFF\">";

                    var iRefCount : int = resource.refCounts;
                    if( resource.unreferencedTimeInterval >= 0.0 )
                    {
                        var fTimeLeft : Number = resource.unreferencedTimeInterval - resource.unreferencedTime;
                        if( fTimeLeft < 0.0 ) fTimeLeft = 0.0;
                        if( iRefCount == 1 ) sAdditionalText = "(dispose in " + fTimeLeft + " secs)";
                        else sAdditionalText = "";
                    }
                    else sAdditionalText = "(permanent)";

                    if( iCount < 10 ) sContext += "  ";
                    else if( iCount < 100 ) sContext += " ";

                    var sCombinedKeyName : String = this.getCombinedKeyName( resource.name, resource.typeName );
                    sContext += iCount.toString() + ". " + sCombinedKeyName + ",";

                    var iExtraSpacesLen : int = iLongestNameLen - sCombinedKeyName.length;
                    for( i = 0; i < iExtraSpacesLen; i++ ) sContext += " ";

                    sContext += "refCount: " + iRefCount + sAdditionalText;

                    if( bXmlFormat ) sContext += "</font>";
                    sContext += "\n";
                }
            }

            return sContext;
        }

        private function _dumpResourcesByType() : String
        {
            m_mapResourceCounts.clear();
            for each( var resource : CResource in m_mapResources )
            {
                if( m_mapResourceCounts.find( resource.typeName ) == null )
                {
                    m_mapResourceCounts.add( resource.typeName, 1 );
                }
                else
                {
                    m_mapResourceCounts[ resource.typeName ]++;
                }
            }

            var aTypeNames : Array = new Array( m_mapResourceCounts.count );
            var i : int = 0;
            for( var sType : String in m_mapResourceCounts ) aTypeNames[ i++ ] = sType;
            aTypeNames.sort( Array.CASEINSENSITIVE );

            var s : String = "";
            for( i = 0; i < aTypeNames.length; i++ )
            {
                s += aTypeNames[ i ] + ": " + m_mapResourceCounts[ aTypeNames[ i ] ] + ", ";
            }
            return s;
        }

        //
        private function _isMatchCondiction( resource : CResource, sWithFilter : String, iWithCounts : int, sWithCountConditiion : String ) : Boolean
        {
            var iRefCount : int = resource.refCounts;
            if( iWithCounts > 0 )
            {
                if( ( sWithCountConditiion == "<=" ) )
                {
                    if( iRefCount > iWithCounts ) return false;
                }
                else if( ( sWithCountConditiion == "<" ) )
                {
                    if( iRefCount >= iWithCounts ) return false;
                }
                else if( ( sWithCountConditiion == ">=" ) )
                {
                    if( iRefCount < iWithCounts ) return false;
                }
                else if( ( sWithCountConditiion == ">" ) )
                {
                    if( iRefCount <= iWithCounts ) return false;
                }
                else if( ( sWithCountConditiion == "==" || sWithCountConditiion == "=" ) )
                {
                    if( iRefCount != iWithCounts ) return false;
                }
                else
                {
                    if( iRefCount > iWithCounts ) return false;
                }
            }

            if( sWithFilter != null )
            {
                var sCombinedKeyName : String = this.getCombinedKeyName( resource.name, resource.typeName );
                if( sCombinedKeyName.indexOf( sWithFilter ) < 0 ) return false;
            }

            return true;
        }

        //
        //
        private function _onTimer( e:TimerEvent ) : void
        {
            update( m_theTimer.seconds() );
            m_theTimer.reset();
        }

        //
        //
        internal var m_mapResources : CMap = new CMap();
        internal var m_mapResourceCounts : CMap = new CMap();

        private var m_theRunTimer : Timer = null;
        private var m_theTimer: CTimer = null;

        protected var m_fUpdateTime : Number = 0.0;
        protected var m_fUpdateTimeInterval : Number = 10.0;

        private static var s_theInstance : CResourceCache = null;
    }
}
