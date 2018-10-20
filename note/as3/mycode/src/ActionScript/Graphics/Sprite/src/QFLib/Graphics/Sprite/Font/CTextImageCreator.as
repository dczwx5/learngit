// =================================================================================================
//
//	Starling Framework
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package QFLib.Graphics.Sprite.Font
{
    import QFLib.Graphics.RenderCore.starling.text.*;
    import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.StageQuality;
    import flash.display3D.Context3DTextureFormat;
    import flash.filters.BitmapFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.TextFormat;

    import QFLib.Graphics.RenderCore.starling.display.Image;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.HAlign;
    import QFLib.Graphics.RenderCore.starling.utils.VAlign;
    import QFLib.Graphics.RenderCore.starling.utils.Deg2rad;

    public class CTextImageCreator
    {
        public function CTextImageCreator( sFontName : String )
        {
            m_theTextFormat = new TextFormat( sFontName );
            m_theNativeTextField = new flash.text.TextField();
            m_theNativeTextField.defaultTextFormat = m_theTextFormat;
        }
        
        public function dispose() : void
        {
        }

        public function get fontName():String { return m_theTextFormat.font; }
        public function set fontName(value:String):void
        {
            m_theTextFormat.font = value;
        }

        // The native Flash BitmapFilters to apply to this TextField.
        public function get nativeFilters():Array { return m_theNativeFilters; }
        public function set nativeFilters(value:Array) : void
        {
            if( value != null ) m_theNativeFilters = value.concat();
            else m_theNativeFilters = null;
        }

         // The default (Context3DTextureFormat.BGRA_PACKED) provides a good
         // compromise between quality and memory consumption; use BGRA for
         // the highest quality.
        public static function get defaultTextureFormat() : String { return s_sDefaultTextureFormat; }
        public static function set defaultTextureFormat( value : String ) : void
        {
            s_sDefaultTextureFormat = value;
        }

        public function create( fWidth : Number, fHeight : Number, sText : String, fFontSize : Number = 16.0, iColor : uint = 0xFFFFFF,
                                  sHorizontalAlign : String = "center", sVerticalAlign : String = "center", bAutoScale : Boolean = true, bKerning : Boolean = true,
                                  bBold : Boolean = false, bItalic : Boolean = false, bUnderline : Boolean = false, sAutoSize:String="none" ) : Image
        {
            var bitmapData : BitmapData = renderText( fWidth, fHeight, sText, fFontSize, iColor, sHorizontalAlign, sVerticalAlign,
                                                       bAutoScale, bKerning, bBold, bItalic, bUnderline, sAutoSize );
            var sFormat : String = s_sDefaultTextureFormat;
            var theTexture : Texture = Texture.fromBitmapData( bitmapData, false, false, 1.0, sFormat );
            theTexture.root.onRestore = function () : void
            {
                var bmd : BitmapData = renderText ( fWidth, fHeight, sText, fFontSize, iColor, sHorizontalAlign, sVerticalAlign,
                        bAutoScale, bKerning, bBold, bItalic, bUnderline, sAutoSize );
                theTexture.root.uploadBitmapData ( bmd );
                bmd.dispose ();
            };
            bitmapData.dispose();
            
            var theImage : Image = new Image( theTexture );
            theImage.touchable = false;
            return theImage;
        }

        public function renderText( fWidth : Number, fHeight : Number, sText : String, fFontSize : Number = 16.0, iColor : uint = 0xFFFFFF,
                                      sHorizontalAlign:String = "center", sVerticalAlign : String = "center", bAutoScale : Boolean = true, bKerning : Boolean = true,
                                      bBold : Boolean = false, bItalic : Boolean = false, bUnderline : Boolean = false, sAutoSize:String = "none" ) : BitmapData
        {
            if( _isHorizontalAutoSize( sAutoSize ) )
            {
                fWidth = int.MAX_VALUE;
                sHorizontalAlign = HAlign.LEFT;
            }
            if( _isVerticalAutoSize( sAutoSize ) )
            {
                fHeight = int.MAX_VALUE;
                sVerticalAlign = VAlign.TOP;
            }

            m_theTextFormat.size = fFontSize;
            m_theTextFormat.color = iColor;
            m_theTextFormat.bold = bBold;
            m_theTextFormat.italic = bItalic;
            m_theTextFormat.underline = bUnderline;
            m_theTextFormat.align = sHorizontalAlign;
            m_theTextFormat.kerning = bKerning;

            m_theNativeTextField.defaultTextFormat = m_theTextFormat;
            m_theNativeTextField.width = fWidth;
            m_theNativeTextField.height = fHeight;
            m_theNativeTextField.antiAliasType = AntiAliasType.ADVANCED;
            m_theNativeTextField.selectable = false;
            m_theNativeTextField.multiline = true;
            m_theNativeTextField.wordWrap = true;
            m_theNativeTextField.htmlText = sText;
            m_theNativeTextField.embedFonts = true;
            m_theNativeTextField.filters = m_theNativeFilters;
            
            // we try embedded fonts first, non-embedded fonts are just a fallback
            if( m_theNativeTextField.textWidth == 0.0 || m_theNativeTextField.textHeight == 0.0 ) m_theNativeTextField.embedFonts = false;
            
            if( bAutoScale ) _autoScaleNativeTextField( m_theNativeTextField );
            
            var fTextWidth : Number  = m_theNativeTextField.textWidth;
            var fTextHeight : Number = m_theNativeTextField.textHeight;

            if( _isHorizontalAutoSize( sAutoSize ) ) m_theNativeTextField.width = fWidth = Math.ceil( fTextWidth + 5 );
            if( _isVerticalAutoSize( sAutoSize ) ) m_theNativeTextField.height = fHeight = Math.ceil( fTextHeight + 4 );
            
            // avoid invalid texture size
            if( fWidth  < 1.0 ) fWidth  = 1.0;
            if( fHeight < 1.0 ) fHeight = 1.0;
            
            var fTextOffsetX : Number = 0.0;
            if( sHorizontalAlign == HAlign.LEFT )        fTextOffsetX = 2.0; // flash adds a 2 pixel offset
            else if( sHorizontalAlign == HAlign.CENTER ) fTextOffsetX = ( fWidth - fTextWidth ) / 2.0;
            else if( sHorizontalAlign == HAlign.RIGHT )  fTextOffsetX =  fWidth - fTextWidth - 2.0;

            var fTextOffsetY : Number = 0.0;
            if( sVerticalAlign == VAlign.TOP )         fTextOffsetY = 2.0; // flash adds a 2 pixel offset
            else if( sVerticalAlign == VAlign.CENTER ) fTextOffsetY = ( fHeight - fTextHeight ) / 2.0;
            else if( sVerticalAlign == VAlign.BOTTOM ) fTextOffsetY =  fHeight - fTextHeight - 2.0;
            
            // if 'nativeFilters' are in use, the sText field might grow beyond its bounds
            _calculateFilterOffset( m_theNativeTextField, sHorizontalAlign, sVerticalAlign, m_theFilterOffset );
            
            // finally: draw sText field to bitmap data
            var theBitmapData : BitmapData = new BitmapData( fWidth, fHeight, true, 0x0 );
            var theDrawMatrix : Matrix = new Matrix( 1, 0, 0, 1, m_theFilterOffset.x, m_theFilterOffset.y + int( fTextOffsetY ) - 2 );
            var fnDrawWithQualityFunc : Function = "drawWithQuality" in theBitmapData ? theBitmapData["drawWithQuality"] : null;
            
            // Beginning with AIR 3.3, we can force a drawing quality. Since "LOW" produces
            // wrong output oftentimes, we force "MEDIUM" if possible.
            if( fnDrawWithQualityFunc is Function )
            {
                fnDrawWithQualityFunc.call( theBitmapData, m_theNativeTextField, theDrawMatrix, null, null, null, false, StageQuality.MEDIUM );
            }
            else
            {
                theBitmapData.draw( m_theNativeTextField, theDrawMatrix );
            }
            
            m_theNativeTextField.text = "";
            
            // update textBounds rectangle
            m_theTextBounds.setTo( ( fTextOffsetX + m_theFilterOffset.x ), ( fTextOffsetY + m_theFilterOffset.y ), fTextWidth, fTextHeight );
            return theBitmapData;
        }
        
        private function _autoScaleNativeTextField( textField : flash.text.TextField ) : void
        {
            var fSize : Number   = Number( textField.defaultTextFormat.size );
            var iMaxHeight : int = textField.height - 4;
            var iMaxWidth : int  = textField.width - 4;
            
            while( textField.textWidth > iMaxWidth || textField.textHeight > iMaxHeight )
            {
                if( fSize  <= 4.0 ) break;
                
                var theFormat : TextFormat = textField.defaultTextFormat;
                theFormat.size = fSize--;
                textField.setTextFormat( theFormat );
            }
        }
        
        private function _calculateFilterOffset( textField : flash.text.TextField, hAlign : String, vAlign : String, theResultFilterOffset : Point ) : void
        {
            theResultFilterOffset.setTo( 0.0, 0.0 );

            var aFilters : Array = textField.filters;
            if( aFilters != null && aFilters.length > 0 )
            {
                var fTextWidth : Number  = textField.textWidth;
                var fTextHeight : Number = textField.textHeight;

                m_tempBound1.setEmpty();
                
                for each( var filter : BitmapFilter in aFilters )
                {
                    var fBlurX : Number    = "blurX"    in filter ? filter["blurX"]    : 0;
                    var fBlurY : Number    = "blurY"    in filter ? filter["blurY"]    : 0;
                    var fAngleDeg : Number = "angle"    in filter ? filter["angle"]    : 0;
                    var fDistance : Number = "distance" in filter ? filter["distance"] : 0;
                    var fAngle : Number = Deg2rad(fAngleDeg);
                    var fMarginX : Number = fBlurX * 1.33; // that's an empirical value
                    var fMarginY : Number = fBlurY * 1.33;
                    var fOffsetX : Number  = Math.cos(fAngle) * fDistance - fMarginX / 2.0;
                    var fOffsetY : Number  = Math.sin(fAngle) * fDistance - fMarginY / 2.0;
                    m_tempBound2.setTo( fOffsetX, fOffsetY, fTextWidth + fMarginX, fTextHeight + fMarginY );

                    m_tempBound1 = m_tempBound1.union( m_tempBound2 );
                }
                
                if( hAlign == HAlign.LEFT && m_tempBound1.x < 0 ) theResultFilterOffset.x = -m_tempBound1.x;
                else if( hAlign == HAlign.RIGHT && m_tempBound1.y > 0 ) theResultFilterOffset.x = -(m_tempBound1.right - fTextWidth);
                
                if( vAlign == VAlign.TOP && m_tempBound1.y < 0 ) theResultFilterOffset.y = -m_tempBound1.y;
                else if( vAlign == VAlign.BOTTOM && m_tempBound1.y > 0 ) theResultFilterOffset.y = -(m_tempBound1.bottom - fTextHeight);
            }
        }
        
        //
        //
        private function _isHorizontalAutoSize( sAutoSize:String ) : Boolean
        {
            return sAutoSize == TextFieldAutoSize.HORIZONTAL || sAutoSize == TextFieldAutoSize.BOTH_DIRECTIONS;
        }
        
        private function _isVerticalAutoSize( sAutoSize:String ) : Boolean
        {
            return sAutoSize == TextFieldAutoSize.VERTICAL || sAutoSize == TextFieldAutoSize.BOTH_DIRECTIONS;
        }


        //
        // the texture format that is used for TTF rendering
        private static var s_sDefaultTextureFormat : String = "BGRA_PACKED" in Context3DTextureFormat ? "bgraPacked4444" : "bgra";

        //
        private var m_theNativeTextField : flash.text.TextField = null;
        private var m_theTextFormat : TextFormat = null;
        private var m_theNativeFilters : Array = null;
        private var m_theTextBounds : Rectangle = new Rectangle();
        private var m_theFilterOffset : Point = new Point();

        private var m_tempBound1 : Rectangle = new Rectangle();
        private var m_tempBound2 : Rectangle = new Rectangle();

    }
}
