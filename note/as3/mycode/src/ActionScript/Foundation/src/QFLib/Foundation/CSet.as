//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/7/4
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import QFLib.Foundation;

    import flash.utils.Dictionary;

    //
    //
    //
    public dynamic class CSet extends Dictionary
    {
        public function CSet( bWeakKeys : Boolean = false )
        {
            super( bWeakKeys );
        }

        [Inline]
        final public function get count() : int
        {
            return m_iCount;
        }
        [Inline]
        final public function get length() : int
        {
            return m_iCount;
        }

        public function add( key : *, bDuplicateCheck : Boolean = false ) : void
        {
            if( this[ key ] != null )
            {
                if( bDuplicateCheck )
                {
                    Foundation.Log.logErrorMsg( "CSet.add(): Adding a key that has already existed in the map...!(key: " + key + ")" );
                    throw new Error( "CSet.add(): Adding a key that has already existed in the set...!(key: " + key + ")" );
                }
            }
            else
            {
                this[ key ] = key;
                m_iCount++;
            }
        }

        public function remove( key : * ) : void
        {
            if( this[ key ] != null )
            {
                delete this[ key ];
                m_iCount--;
            }
        }

        [Inline]
        final public function isExisted( key : * ) : Boolean
        {
            if( key == null || this[ key ] == null ) return false;
            else return true;
        }

        [Inline]
        final public function first() : *
        {
            for( var key : * in this ) return key;
            return null;
        }

        [Inline]
        final public function clear() : void
        {
            for( var key : * in this ) delete this[ key ];
            m_iCount = 0;
        }

        public function popFirst() : *
        {
            var key : *;
            for( key in this ) break;

            this.remove( key );
            return key;
        }

        public function sort( fnCompare : * ) : Vector.<Object>
        {
            var theVector : Vector.<Object> = toVector();
            theVector.sort( fnCompare );
            return theVector;
        }

        public function toVector( theVector : Vector.<Object> = null ) : Vector.<Object>
        {
            if( theVector == null ) theVector = new Vector.<Object>( m_iCount );
            else theVector.length = m_iCount;

            var i : int = 0;
            for( var obj : * in this )
            {
                theVector[ i++ ] = obj;
            }
            return theVector;
        }

        public function toArray( theArray : Array = null ) : Array
        {
            if( theArray == null ) theArray = new Array( m_iCount );
            else theArray.length = m_iCount;

            var i : int = 0;
            for( var obj : * in this )
            {
                theArray[ i++ ] = obj;
            }
            return theArray;
        }

        //
        private var m_iCount : int = 0;
    }

}