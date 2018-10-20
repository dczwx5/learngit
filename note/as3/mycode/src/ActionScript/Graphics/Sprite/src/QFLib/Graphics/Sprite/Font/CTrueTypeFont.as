//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/8/17.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Sprite.Font
{
    import QFLib.Graphics.RenderCore.starling.display.Image;
    import QFLib.Graphics.Sprite.CSpriteText;

    public class CTrueTypeFont extends CFont
	{
		public function CTrueTypeFont( sName : String )
		{
            m_theTextImageCreator = new CTextImageCreator( sName );
            m_sName = sName;
		}

		public override function dispose() : void
		{
            if( m_bDisposed ) return ;

            if( m_theTextImageCreator != null )
            {
                m_theTextImageCreator.dispose();
                m_theTextImageCreator = null;
            }

            super.dispose();
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
            if( m_theTextImageCreator == null ) return;

            textSprite.resetTextObject();
            m_theTextImageCreator.nativeFilters = nativeFilters;
            var img : Image = m_theTextImageCreator.create( fWidth, fHeight, sText, fFontSize, iFontColor, sHorizontalAlign, sVerticalAlign, bAutoScale, bKerning,
                                                            bBold, bItalic, bUnderline, sAutoSize );
            textSprite._getTextObject().addImage( img );
            textSprite._setTextObjectTexture( img.texture );
        }


        //
        //
        protected var m_theTextImageCreator : CTextImageCreator = null;
        protected var m_sName : String = null;
	}
}
