/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/3/12
//----------------------------------------------------------------------------------------------------------------------

/*
 */

package QFLib.QEngine.Loader
{
    import QFLib.Foundation;
    import QFLib.Foundation.CPath;
    import QFLib.Foundation.CURLFile;
    import QFLib.QEngine.Renderer.Textures.Texture;
    import QFLib.ResourceLoader.CBaseLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.Utils.CFlashVersion;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display3D.Context3DTextureFormat;
    import flash.events.Event;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;

    public class TextureLoader extends CBaseLoader
    {
        public static const NAME : String = ".ATF";

        public function TextureLoader( theBelongResourceLoaderRef : CResourceLoaders )
        {
            super( theBelongResourceLoaderRef );

            m_loaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
            m_loader = new Loader();
            m_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, _decodeFinished, false, 0, true );
        }
        private var m_loaderContext : LoaderContext = null;
        private var m_loader : Loader = null;
        private var m_theBitmap : BitmapData = null;
        private var m_theRawData : ByteArray = null;

        public override function dispose() : void
        {
            m_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, _decodeFinished );
            m_loader = null;
            m_loaderContext = null;

            if( m_theBitmap != null )
            {
                m_theBitmap.dispose();
                m_theBitmap = null;
            }
            m_theRawData = null;

            super.dispose();
        }

        public override function start() : void
        {
            if( CFlashVersion.isPlayerVersionPriorOrEqualTo( 11, 7 ) ) // versions that are not support ATF format
            {
                for( var i : int = 0; i < m_vFilenames.length; i++ )
                {
                    if( CPath.ext( m_vFilenames[ i ] ).toUpperCase() == TextureLoader.NAME )
                    {
                        m_vFilenames[ i ] = ""; // skip loading this file
                    }
                }
            }

            super.start();
        }

        //

        public override function createResource( bCleanUp : Boolean = true ) : CResource
        {
            var theResource : CResource = super.createResource( false );

            if( m_theBitmap != null )
            {
                theResource.theObjects.push( m_theBitmap );
                if( bCleanUp ) m_theBitmap = null;
            }
            if( m_theRawData != null )
            {
                theResource.theObjects.push( m_theRawData );
                if( bCleanUp ) m_theRawData = null;
            }

            return theResource;
        }

        public override function createObject( bCleanUp : Boolean = true ) : Object
        {
            var tex : Texture;

            if( m_theBitmap != null )
            {
                try
                {
                    tex = Texture.fromBitmapData( m_theBitmap, false, false, 1.0, Context3DTextureFormat.BGRA, false );
                    if( bCleanUp )
                    {
                        m_theBitmap.dispose();
                        m_theBitmap = null;
                    }
                }
                catch( error : Error )
                {
                    Foundation.Log.logErrorMsg( "Error happened when converting Bitmap data to texture: " + m_theURLFile.loadingURL +
                            ", " + error.toString() );
                    tex = Texture.empty( 4, 4 ); // create an empty texture when encounter this problem, 4x4 is the minimal size in Starling system
                }
                return tex;
            }
            else
            {
                try
                {
                    m_theRawData = m_theURLFile.readAllBytes();
                    tex = Texture.fromAtfData( m_theRawData, 1.0, false, null, false );
                    if( bCleanUp )
                    {
                        m_theRawData = null;
                    }
                }
                catch( error : Error )
                {
                    Foundation.Log.logErrorMsg( "Error happened when converting ATF data to texture: " + m_theURLFile.loadingURL +
                            ", " + error.toString() );
                    tex = Texture.empty( 4, 4 ); // create an empty texture when encounter this problem, 4x4 is the minimal size in Starling system
                }

                return tex;
            }
        }

        protected override function _loadFinished( file : CURLFile, idError : int ) : void
        {
            if( idError == 0 && CPath.ext( file.loadingURL ).toUpperCase() != ".ATF" )
            {
                var theRawData : ByteArray = m_theURLFile.readAllBytes();
                m_loader.loadBytes( theRawData, m_loaderContext );
            }
            else
            {
                m_bDone = true;
                if( m_fnOnFinished != null ) m_fnOnFinished( this, idError );
            }
        }

        protected virtual function _decodeFinished( e : Event ) : void
        {
            var loaderInfo : LoaderInfo = e.currentTarget as LoaderInfo;
            m_theBitmap = ( loaderInfo.content as Bitmap ).bitmapData;

            m_loader.unload();

            m_bDone = true;
            if( m_fnOnFinished != null ) m_fnOnFinished( this, 0 );
        }

    }

}

