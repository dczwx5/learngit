//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/17
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import QFLib.Foundation;

    import avmplus.getQualifiedClassName;

    import flash.utils.Dictionary;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;

    //
    //
    //
    public dynamic class CMap extends Dictionary
    {
        public function CMap( bWeakKeys : Boolean = false )
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

        /*flash.utils.flash_proxy function getProperty( key : * ) : *
        {
            return super[ key ];
        }
        flash.utils.flash_proxy function setProperty( key : *, value : * ) : void
        {
            if( super[ key ] === undefined )
            {
                if( value !== undefined )
                {
                    super[ key ] = value;
                    m_iCount++;
                }
            }
            else
            {
                if( value === undefined )
                {
                    delete super[ key ];
                    m_iCount--;
                }
                else super[ key ] = value;
            }
        }
        flash.utils.flash_proxy function deleteProperty( key : * ) : Boolean
        {
            if( super[ key ] !== undefined )
            {
                delete super[ key ];
                m_iCount--;
                return true;
            }
            return false;
        }*/

        public function add( key : *, value : *, bAllowReplace : Boolean = false ) : void
        {
            if( this[ key ] != null )
            {
                if( bAllowReplace )
                {
                    this[ key ] = value;
                }
                else
                {
                    var sKeyTypeName : String = getQualifiedClassName( key );
                    var sValueTypeName : String = getQualifiedClassName( value );
                    Foundation.Log.logErrorMsg( "CMap.add(): Adding a key that has already existed in the map...!!(key = " + key + " : " + sKeyTypeName + ", value = " + value + " : " + sValueTypeName + ")" );
                    throw new Error( "CMap.add(): Adding a key that has already existed in the map...!!(key = " + key + " : " + sKeyTypeName + ", value = " + value + " : " + sValueTypeName + ")" );
                }
            }
            else
            {
                this[ key ] = value;
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
        final public function find( key : * ) : *
        {
            if( key == null ) return null;
            return this[ key ];
        }

        public function append( theJson : Object, sKey : String, cls : Class = null ) : void
        {
            for( var i : int = 0; i < theJson.length; i++ )
            {
                if( theJson[ i ].hasOwnProperty( sKey ) )
                {
                    if( cls != null )
                    {
                        this.add( theJson[ i ][ sKey ], new cls( theJson[ i ] ) );
                    }
                    else
                    {
                        this.add( theJson[ i ][ sKey ], theJson[ i ] );
                    }
                }
            }
        }

        public function appendFrom( theMap : CMap ) : void
        {
            for( var key : * in theMap )
            {
                this.add( key, theMap.find( key ) );
            }
        }

        [Inline]
        final public function firstKey() : *
        {
            for( var key : * in this ) return key;
            return null;
        }
        [Inline]
        final public function firstValue() : *
        {
            for each( var value : * in this ) return value;
            return null;
        }

        [Inline]
        final public function clear() : void
        {
            while( firstKey() != null )
            {
                for( var key : * in this ) delete this[ key ];
            }
            m_iCount = 0;
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
            for each( var obj : * in this )
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
            for each( var obj : * in this )
            {
                theArray[ i++ ] = obj;
            }
            return theArray;
        }

        // func(key, value)
        public function loop(func:Function) : void {
            if (null == func) return ;
            for(var key:* in this) {
                func(key, this[key]);
            }
        }
        //
        private var m_iCount : int = 0;
    }

}