//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/8/17.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Sprite.Font
{
    import QFLib.Foundation;
    import QFLib.Foundation.CPath;
    import QFLib.Graphics.RenderCore.CTextureLoader;
    import QFLib.Graphics.RenderCore.starling.text.BitmapFont;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.Sprite.CSpriteText;
    import QFLib.ResourceLoader.CBaseLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.CXmlLoader;
    import QFLib.ResourceLoader.ELoadingPriority;

    /*
    --- the bitmap font's xml file format ---

    <?xml version="1.0" encoding="utf-8"?>
    <font>
        <info face = "Numbers" size="48" />
        <common lineHeight="48" base = "14" />
        <pages>
            <page id="0" file="Numbers.png" />
        </pages>
        <chars>
            <char id="48" x="35" y="0" width="35" height="48" xoffset="0" yoffset="0" xadvance="25" />
            <char id="49" x="70" y="0" width="35" height="48" xoffset="0" yoffset="0" xadvance="25" />
            ...etc
        </chars>
        <kernings>
            <kerning first="1" second="1" amount="0" />
        </kernings>
    </font>*/

    public class CBitmapFont extends CFont
	{
		public function CBitmapFont( sName : String )
		{
            m_sName = sName;
		}

		public override function dispose():void
		{
            if( m_bDisposed ) return ;

            if( m_theTextureResource != null )
            {
                m_theTextureResource.dispose();
                m_theTextureResource = null;
            }

            if( m_theAtlasXmlResource != null )
            {
                m_theAtlasXmlResource.dispose();
                m_theAtlasXmlResource = null;
            }

            super.dispose();
		}

        public function isLoaded() : Boolean
        {
            if( m_theBitmapFont != null ) return true;
            else return false;
        }

        //
        // callback: function fnOnLoadFinished( theFont : CBitmapFont, iResult : int ) : void
        //
        public virtual function loadFile( sFilename : String, fnOnLoadFinished : Function = null,
                                              iPriority : int = ELoadingPriority.NORMAL ) : void
        {
            m_sFilename = sFilename;
            m_fnOnLoadFinished = fnOnLoadFinished;

            var sAtlasFile : String = CPath.driverDirName( sFilename ) + ".xml";
            CResourceLoaders.instance().startLoadFile( sAtlasFile, _onAtlasXmlLoadFinished );

            var vTexFilenames : Vector.<String> = new Vector.<String>( 3 );
            vTexFilenames[ 0 ] = CPath.driverDirName( sFilename ) + ".atf";
            vTexFilenames[ 1 ] = CPath.driverDirName( sFilename ) + ".png";
            vTexFilenames[ 2 ] = CPath.driverDirName( sFilename ) + ".jpg";
            CResourceLoaders.instance().startLoadFileFromPathSequence( vTexFilenames, _onTextureLoadFinished, CTextureLoader.NAME, iPriority );
        }

        public function createDefaultFont() : void
        {
            m_theBitmapFont = new BitmapFont( null, null );
        }

        public override function get name() : String
        {
            return m_sName;
        }

        public override function setSpriteText( textSprite : CSpriteText, sText : String,
                                                fWidth : Number, fHeight : Number, fFontSize : Number,
                                                iFontColor : uint, sHorizontalAlign : String, sVerticalAlign : String,
                                                bAutoScale : Boolean, bKerning : Boolean, bBold : Boolean, bItalic : Boolean, bUnderline : Boolean, sAutoSize : String, nativeFilters : Array = null ) : void
        {
            if( m_theBitmapFont == null ) return;

            textSprite.resetTextObject();
            m_theBitmapFont.fillQuadBatch( textSprite._getTextObject(), fWidth, fHeight, sText, fFontSize, iFontColor, sHorizontalAlign, sVerticalAlign, bAutoScale, bKerning );
        }


        //
        //
        private function _onAtlasXmlLoadFinished( loader : CXmlLoader, idErrorCode : int ) : void
        {
            if( idErrorCode != 0 )
            {
                m_sFilename = null;
                return;
            }

            m_theAtlasXmlResource = loader.createResource();

            if( m_theTextureResource != null )
            {
                _createFont( m_theTextureResource, m_theAtlasXmlResource );
            }

        }

        protected function _onTextureLoadFinished( loader : CBaseLoader, idErrorCode : int ) : void
        {
            if( idErrorCode != 0 )
            {
                m_sFilename = null;
                Foundation.Log.logErrorMsg( "_onLoadFinished(): Can not load font image: " + loader.filename );
                if( m_fnOnLoadFinished != null ) m_fnOnLoadFinished( this, idErrorCode );
                return ;
            }

            m_theTextureResource = loader.createResource();
            if( m_theTextureResource == null || m_theTextureResource.theObject == null )
            {
                Foundation.Log.logErrorMsg( "_onLoadFinished(): cannot get font image's data( null): " + loader.filename );
                return ;
            }

            // use clamp mode by default to avoid crack edges effects amount images
            var tex : Texture = m_theTextureResource.theObject as Texture;
            tex.repeat = false;

            if( m_theAtlasXmlResource != null )
            {
                _createFont( m_theTextureResource, m_theAtlasXmlResource );
            }
        }

        protected function _createFont( theTextureResource : CResource, m_theAtlasXmlResource : CResource ) : void
        {
            m_theBitmapFont = new BitmapFont( theTextureResource.theObject as Texture, m_theAtlasXmlResource.theObject as XML );

            if( m_fnOnLoadFinished != null ) m_fnOnLoadFinished( this, 0 );
        }


        //
        //
        protected var m_sFilename : String = "";
        protected var m_sName : String = null;

        protected var m_theBitmapFont : BitmapFont = null;
        protected var m_fnOnLoadFinished : Function = null;
        private var m_theAtlasXmlResource : CResource = null;
        protected var m_theTextureResource : CResource = null;
    }
}
