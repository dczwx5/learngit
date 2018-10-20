//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/8/17.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Sprite.Font
{
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Graphics.Sprite.CSpriteText;
    import QFLib.Interface.IDisposable;

    public class CFontManager implements IDisposable
	{
		public function CFontManager()
		{
            // register a default true type font
            m_theDefaultTrueTypeFont = new CTrueTypeFont( "Arial" );

            // register a default bitmap font
            m_theDefaultBitmapFont = new CBitmapFont( "MiniBitmapFont" );
            m_theDefaultBitmapFont.createDefaultFont();
		}

        public function dispose() : void
        {
            reset();
        }

        public function reset() : void
        {
            for each( var font : CFont in m_mapRegisteredFonts )
            {
                font.dispose();
            }
            m_mapRegisteredFonts.clear();
        }

        public function registerFont( font : CFont ) : Boolean
        {
            if( font is CBitmapFont ) return registerBitmapFont( font as CBitmapFont );
            else if( font is CTrueTypeFont ) return registerTrueTypeFont( font as CTrueTypeFont );
            else return false;
        }

        public function registerBitmapFont( font : CBitmapFont ) : Boolean
        {
            if( font.isLoaded == false )
            {
                Foundation.Log.logErrorMsg( "Cannot register a font that is not loaded: " + font.name );
                return false;
            }

            m_mapRegisteredFonts.add( font.name, font );
            return true;
        }

        public function registerTrueTypeFont( font : CTrueTypeFont ) : Boolean
        {
            m_mapRegisteredFonts.add( font.name, font );
            return true;
        }

        public function setSpriteText( textSprite : CSpriteText, sText : String, sFontName : String,
                                         fWidth : Number, fHeight : Number, fFontSize : Number,
                                         iFontColor : uint, sHorizontalAlign : String, sVerticalAlign : String,
                                         bAutoScale : Boolean, bKerning : Boolean, bBold : Boolean, bItalic : Boolean, bUnderline : Boolean, sAutoSize : String, nativeFilters : Array = null ) : void
        {
            var theFont : CFont = m_mapRegisteredFonts.find( sFontName ) as CFont;
            if( theFont == null )
            {
                var bASCII : Boolean = true;
                for( var i : int = 0; i < sText.length; i++ )
                {
                    if( sText.charCodeAt( i ) > 127 )
                    {
                        bASCII = false;
                        break;
                    }
                }

                if( bASCII ) theFont = m_theDefaultBitmapFont;
                else theFont = m_theDefaultTrueTypeFont;
            }

            theFont.setSpriteText( textSprite, sText, fWidth, fHeight, fFontSize, iFontColor, sHorizontalAlign, sVerticalAlign, bAutoScale, bKerning,
                                   bBold, bItalic, bUnderline, sAutoSize, nativeFilters );
        }

        //
        //
        protected var m_mapRegisteredFonts : CMap = new CMap();
        protected var m_theDefaultBitmapFont : CBitmapFont = null;
        protected var m_theDefaultTrueTypeFont : CTrueTypeFont = null;
	}
}
