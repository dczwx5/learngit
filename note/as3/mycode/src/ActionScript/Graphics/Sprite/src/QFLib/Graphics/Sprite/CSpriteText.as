//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/8/17.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Sprite
{

    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.Sprite.Font.CFontQuadBatch;
    import QFLib.Math.CVector3;
    import QFLib.ResourceLoader.CBaseLoader;

    public class CSpriteText extends CSprite
	{
        public function CSpriteText( theSpriteSystem : CSpriteSystem, fWidth : Number, fHeight : Number, bCenterAnchor : Boolean = false )
        {
            super( theSpriteSystem, bCenterAnchor );

            this.createEmpty( fWidth, fHeight );
            m_theImage.visible = false;

            m_theQuadBatchText = new CFontQuadBatch( fWidth, fHeight, bCenterAnchor );
            m_theQuadBatchText.preRender = preRender;
            m_theQuadBatchText.alpha = m_fFontOpaque;
            this._addChild( m_theQuadBatchText );
        }

        public override function dispose() : void
        {
//            if( m_sText.indexOf( "a" ) != -1 ||
//            m_sText.indexOf( "b" ) != -1 )
//            {
//                trace( "arrow text disposed" );
//            }

            if ( this.disposed )
                return;

            if( m_theQuadBatchText != null )
            {
                this._removeChild( m_theQuadBatchText );
                m_theQuadBatchText.preRender = null;
                m_theQuadBatchText.dispose();
                m_theQuadBatchText = null;
            }

            if( m_theQuadBatchTexture != null )
            {
                m_theQuadBatchTexture.dispose();
                m_theQuadBatchTexture = null;
            }

            if ( m_theFilters )
                m_theFilters.splice( 0, m_theFilters.length );
            m_theFilters = null;

            super.dispose();
        }

        public override function set opaque( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;
            if( m_theImage != null ) m_theImage.alpha = m_fBackgroundOpaque;
            if( m_theQuadBatchText != null ) m_theQuadBatchText.alpha = m_fOpaque;
        }

        [Inline]
        public function get backroundColor() : CVector3
        {
            return super.color;
        }
        [Inline]
        public function setBackroundColor( r : Number, g : Number, b : Number, alpha : Number = 1.0  ) : void
        {
            super.setColor( r, g, b, alpha );
        }

        [Inline]
        public function get backroundOpaque() :Number
        {
            return m_fBackgroundOpaque;
        }
        [Inline]
        public function set backroundOpaque( fOpaque : Number ) : void
        {
            if( fOpaque < 0.0 ) fOpaque = 0.0;
            m_fBackgroundOpaque = fOpaque;
            if( m_theImage != null ) m_theImage.alpha = m_fBackgroundOpaque;
        }

        [Inline]
        public function get backroundVisible() : Boolean
        {
            if( m_theImage != null ) return m_theImage.visible;
            else return false;
        }
        [Inline]
        public function set backroundVisible( bVisible : Boolean ) : void
        {
            if( m_theImage != null ) m_theImage.visible = bVisible;
        }

        [Inline]
        public function get text() : String
        {
            return m_sText;
        }
        public function set text( sText : String ) : void
        {
            if( sText != null && m_sText != sText )
            {
                //Foundation.Log.logMsg( "set Text: " + sText );
                m_sText = sText;
                m_bTextDirty = true;
                //if( m_theQuadBatchText.numVertices == 0 ) preRender();
            }
        }

        [Inline]
        public function get fontName() : String
        {
            return m_sFontName;
        }
        public function set fontName( sFontName : String ) : void
        {
            if( m_sFontName != sFontName )
            {
                m_sFontName = sFontName;
                _setTextDirty();
            }
        }

        [Inline]
        public function get fontSize() : Number
        {
            return m_fFontSize;
        }
        public function set fontSize( fFontSize : Number ) : void
        {
            if( m_fFontSize != fFontSize )
            {
                m_fFontSize = fFontSize;
                _setTextDirty();
            }
        }

        [Inline]
        public function get fontColor() : uint
        {
            return m_iFontColor;
        }
        public function set fontColor( iFontColor : uint ) : void
        {
            if( m_iFontColor != iFontColor )
            {
                m_iFontColor = iFontColor;
                _setTextDirty();
            }
        }

        [Inline]
        // sHorizontalAlign:  "left" "center", "right"
        public function get fontHorizontalAlign() : String
        {
            return m_sHorizontalAlign;
        }
        public function set fontHorizontalAlign( sHorizontalAlign : String ) : void
        {
            if( m_sHorizontalAlign != sHorizontalAlign )
            {
                m_sHorizontalAlign = sHorizontalAlign;
                _setTextDirty();
            }
        }

        [Inline]
        // sHorizontalAlign: "top" "center", "bottom"
        public function get fontVerticalAlign() : String
        {
            return m_sVerticalAlign;
        }
        public function set fontVerticalAlign( sVerticalAlign : String ) : void
        {
            if( m_sVerticalAlign != sVerticalAlign )
            {
                m_sVerticalAlign = sVerticalAlign;
                _setTextDirty();
            }
        }

        [Inline]
        public function get fontAutoScale() : Boolean
        {
            return m_bAutoScale;
        }
        public function set fontAutoScale( bAutoScale : Boolean ) : void
        {
            if( m_bAutoScale != bAutoScale )
            {
                m_bAutoScale = bAutoScale;
                _setTextDirty();
            }
        }

        [Inline]
        public function get fontKerning() : Boolean
        {
            return m_bKerning;
        }
        public function set fontKerning( bKerning : Boolean ) : void
        {
            if( m_bKerning != bKerning )
            {
                m_bKerning = bKerning;
                _setTextDirty();
            }
        }

        [Inline]
        public function get fontBold() : Boolean
        {
            return m_bBold;
        }
        public function set fontBold( bBold : Boolean ) : void
        {
            if( m_bBold != bBold )
            {
                m_bBold = bBold;
                _setTextDirty();
            }
        }

        [Inline]
        public function get fontItalic() : Boolean
        {
            return m_bItalic;
        }
        public function set fontItalic( bItalic : Boolean ) : void
        {
            if( m_bItalic != bItalic )
            {
                m_bItalic = bItalic;
                _setTextDirty();
            }
        }

        [Inline]
        public function get fontUnderline() : Boolean
        {
            return m_bUnderline;
        }
        public function set fontUnderline( bUnderline : Boolean ) : void
        {
            if( m_bUnderline != bUnderline )
            {
                m_bUnderline = bUnderline;
                _setTextDirty();
            }
        }

        [Inline]
        public function get fontOpaque() : Number
        {
            return m_fFontOpaque;
        }
        [Inline]
        public function set fontOpaque( fOpaque : Number ) : void
        {
            m_fFontOpaque = fOpaque;
            if( m_theQuadBatchText != null ) m_theQuadBatchText.alpha = m_fFontOpaque;
        }

        public function get filters() : Array {
            return m_theFilters;
        }

        public function set filters( value : Array ) : void {
            m_theFilters = value.concat();
        }

        public function get autoSize() : String {
            return m_sAutoSize;
        }

        public function set autoSize( value : String ) : void {
            m_sAutoSize = value;
        }

        //
        public function preRender() : void
        {
            if( m_bTextDirty )
            {
                //Foundation.Log.logMsg( "preRender Text: " + m_sText );
                m_theSpriteSystemRef.glyphManager.setSpriteText( this, m_sText, m_sFontName, this.width, this.height, m_fFontSize,
                                                                 m_iFontColor, m_sHorizontalAlign, m_sVerticalAlign,
                                                                 m_bAutoScale, m_bKerning, m_bBold, m_bItalic, m_bUnderline, m_sAutoSize, m_theFilters );

                if( m_bCenterAnchor )
                {
                    m_theQuadBatchText.x = -m_theImage.width * 0.5;
                    m_theQuadBatchText.y = -m_theImage.height * 0.5;
                }
                else
                {
                    m_theQuadBatchText.x = 0.0;
                    m_theQuadBatchText.y = 0.0;
                }

                m_bTextDirty = false;
            }
        }

        //
        public function resetTextObject() : void
        {
            m_theQuadBatchText.reset();
        }
        [Inline]
        final public function _getTextObject() : CFontQuadBatch
        {
            return m_theQuadBatchText;
        }
        public function _setTextObjectTexture( theTexture : Texture ) : void
        {
            if( m_theQuadBatchTexture != null )
            {
                m_theQuadBatchTexture.dispose();
                m_theQuadBatchTexture = null;
            }

            m_theQuadBatchTexture = theTexture;
        }

        //
        //
        protected override function _onLoadFinished( loader : CBaseLoader, idErrorCode : int ) : void
        {
            super._onLoadFinished( loader, idErrorCode );
            if( this.disposed ) return ;

            if( idErrorCode == 0 )
            {
                this._removeChild( m_theQuadBatchText );
                this._addChild( m_theQuadBatchText );
            }
        }

        private function _setTextDirty() : void
        {
            if( m_sText != null && m_sText.length != 0 )
            {
                m_bTextDirty = true;
                //if( m_theQuadBatchText.numVertices == 0 ) preRender();
            }
        }

        //
        protected var m_theQuadBatchText : CFontQuadBatch = null;
        protected var m_theQuadBatchTexture : Texture = null;

        protected var m_fBackgroundOpaque : Number = 1.0;

        protected var m_sText : String = "";

        protected var m_theFilters : Array;
        protected var m_sFontName : String = "";
        protected var m_sHorizontalAlign : String = "center";
        protected var m_sVerticalAlign : String = "center";
        protected var m_fFontSize : Number = 32.0;
        protected var m_fFontOpaque : Number = 1.0;
        protected var m_iFontColor : uint = 0x00FFFFFF;
        protected var m_bAutoScale : Boolean = true;
        protected var m_bKerning : Boolean = true;
        protected var m_bBold : Boolean = false;
        protected var m_bItalic : Boolean = false;
        protected var m_bUnderline : Boolean = false;
        protected var m_sAutoSize : String = "none";

        protected var m_bTextDirty : Boolean = false;
    }
}
