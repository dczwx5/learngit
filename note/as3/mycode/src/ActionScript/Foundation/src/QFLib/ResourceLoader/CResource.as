//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/15
//----------------------------------------------------------------------------------------------------------------------

package QFLib.ResourceLoader
{
    import QFLib.Foundation.CTime;
    import QFLib.Interface.IDisposable;
    import QFLib.Memory.CSmartObject;

import flash.system.System;

//
    //
    //
    public class CResource extends CSmartObject
    {
        public function CResource( sName : String, sTypeName : String, obj : Object, fUnReferencedTimeInterval : Number = 30.0 )
        {
            super();

            m_sName = sName;
            m_sType = sTypeName;
            m_vObjects = new Vector.<Object>( 1 );
            m_vObjects[ 0 ] = obj;
            m_iRefCounts = 1;
            m_fUnReferencedTimeInterval = fUnReferencedTimeInterval;
        }

        public override function dispose() : void
        {
            m_iRefCounts--;
            if( m_iRefCounts == 0 )
            {
                var disposableObj : IDisposable;
                for each( var obj : Object in m_vObjects )
                {
                    if( obj == null ) continue;

                    disposableObj = obj as IDisposable;
                    if( disposableObj != null ) disposableObj.dispose();
                    else if (obj is XML) System.disposeXML( obj as XML );
                    else if( obj.hasOwnProperty( "dispose" ) && obj.dispose is Function ) obj.dispose();
                }
                m_vObjects.length = 0;
                m_vObjects = null;

                m_sName = null;
                m_theBelongResourceCacheRef = null;

                super.dispose();
            }
            else m_fUnReferencedTime = 0.0;

            if( m_iRefCounts == 1 && m_fUnReferencedTimeInterval == 0.0 ) // for destroy immediately
            {
                m_theBelongResourceCacheRef.remove( this.m_sName, this.m_sType );
            }
        }

        [Inline]
        final public function clone() : CResource
        {
            this.addRefCounter();
            return this;
        }

        [Inline]
        final public function get name() : String
        {
            return m_sName;
        }
        [Inline]
        final public function get typeName() : String
        {
            return m_sType;
        }
        [Inline]
        final public function get theObject() : Object
        {
            if( m_vObjects != null ) return m_vObjects[ 0 ];
            else return null;
        }
        [Inline]
        final public function get theObjects() : Vector.<Object>
        {
            return m_vObjects;
        }
        [Inline]
        final public function get refCounts() : int
        {
            return m_iRefCounts;
        }
        [Inline]
        final internal function get unreferencedTime() : Number
        {
            return m_fUnReferencedTime;
        }

        [Inline]
        final public function get unreferencedTimeInterval() : Number
        {
            return m_fUnReferencedTimeInterval;
        }
        [Inline]
        final public function set unreferencedTimeInterval( fInterval : Number ) : void
        {
            m_fUnReferencedTimeInterval = fInterval;
        }

        [Inline]
        final public function get resourceSize () : int { return m_iSize; }

        [Inline]
        final public function set resourceSize ( value : int ) : void { m_iSize = value; }

        [Inline]
        final internal function addRefCounter() : void
        {
            m_iRefCounts++;
            m_fUnReferencedTime = 0.0;
        }
        [Inline]
        final internal function isUnReferencedTimesUp( time : Number ) : Boolean
        {
            m_fUnReferencedTime += time;

            if( m_fUnReferencedTimeInterval >= 0.0 )
            {
                if( m_fUnReferencedTime >= m_fUnReferencedTimeInterval ) return true;
                else return false;
            }
            else return false;
        }

        [Inline]
        final internal function get createdTimestamp() : Number
        {
            return m_fCreateTimeStamp;
        }

        [Inline]
        final internal function setResourceCache( resourceCache : CResourceCache ) : void
        {
            m_theBelongResourceCacheRef = resourceCache;
            m_fCreateTimeStamp = CTime.getCurrentTimestamp();
        }

        protected var m_theBelongResourceCacheRef : CResourceCache = null;
        protected var m_sName : String = null;
        protected var m_sType : String = null;
        protected var m_vObjects : Vector.<Object> = null;
        protected var m_iRefCounts : int = 0;
        protected var m_fUnReferencedTime : Number = 0.0;
        protected var m_fUnReferencedTimeInterval : Number = 30.0;
        protected var m_fCreateTimeStamp : Number = 0.0;
        protected var m_iSize : int = 0;
    }
}
