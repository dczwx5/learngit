//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/1
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{
    import QFLib.Foundation;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.utils.Dictionary;


    //
    //
    //
    public class CURLJson extends CURLFile
    {
        public function CURLJson( sURL : String, sURLVersion : String = null, bLoadFileWithVersionOnly : Boolean = false, pStreamLoaderClass : Class = null )
        {
            super( sURL, sURLVersion, bLoadFileWithVersionOnly, pStreamLoaderClass );
        }

        public override function dispose() : void
        {
            super.dispose();
            m_theJson = null;
        }

        public override function close( bFullCleanUp : Boolean = false ) : void
        {
            super.close( bFullCleanUp );
            m_theJson = null;
        }

        public function get jsonObject() : Object
        {
            return m_theJson;
        }

        public function toDictionary( sKey : String, cls : Class = null, dicTable : Dictionary = null ) : Dictionary
        {
            if( m_theJson == null ) return null;

            if( dicTable == null ) dicTable = new Dictionary();
            for( var i : int = 0; i < m_theJson.length; i++ )
            {
                if( m_theJson[ i ].hasOwnProperty( sKey ) )
                {
                    if( cls != null )
                    {
                        dicTable[ m_theJson[ i ][ sKey ] ] = new cls( m_theJson[ i ] );
                    }
                    else
                    {
                        dicTable[ m_theJson[ i ][ sKey ] ] = m_theJson[ i ];
                    }
                }
            }

            return dicTable;
        }


        public function toMap( sKey : String, cls : Class = null, mapTable : CMap = null ) : CMap
        {
            if( m_theJson == null ) return null;

            if( mapTable == null ) mapTable = new CMap();
            for( var i : int = 0; i < m_theJson.length; i++ )
            {
                if( m_theJson[ i ].hasOwnProperty( sKey ) )
                {
                    if( cls != null )
                    {
                        mapTable.add( m_theJson[ i ][ sKey ], new cls( m_theJson[ i ] ) );
                    }
                    else
                    {
                        mapTable.add( m_theJson[ i ][ sKey ], m_theJson[ i ] );
                    }
                }
            }

            return mapTable;
        }

        //
        //
        protected override function _onCompleted( e : Event ) : void
        {
            try
            {
                var s : String = readAllText();
                if( s != null )
                {
                    Foundation.Perf.sectionBegin( "Json.parse" );
                    m_theJson = JSON.parse( s );
                    Foundation.Perf.sectionEnd( "Json.parse" );
                }
            }
            catch( error : Error )
            {
                super._onError( new IOErrorEvent( "JSON parse fail", false, false, "JSON file format error: " + this.loadingURL, -1 ) );
                return;
            }

            super._onCompleted( e );
        }

        //
        //
        protected var m_theJson : Object = null;
    }

}