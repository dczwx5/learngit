//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/8/17.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Sprite.Font
{
    import QFLib.Graphics.Sprite.CSpriteText;
    import QFLib.Interface.IDisposable;

    public class CFont implements IDisposable
	{
		public function CFont()
		{
		}

        public virtual function dispose() : void
        {
            m_bDisposed = true;
        }

        public virtual function get name() : String
        {
            return null;
        }

        public virtual function setSpriteText( textSprite : CSpriteText, sText : String,
                                               fWidth : Number, fHeight : Number, fFontSize : Number,
                                               iFontColor : uint, sHorizontalAlign : String, sVerticalAlign : String,
                                               bAutoScale : Boolean, bKerning : Boolean, bBold : Boolean, bItalic : Boolean, bUnderline : Boolean, sAutoSize : String, nativeFilters : Array = null ) : void
        {
        }

        //
        protected var m_bDisposed : Boolean = false;
    }
}
