//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/17.
//----------------------------------------------------------------------
package kof.game.character.scripts.playersprite {

import QFLib.Foundation;
import QFLib.Graphics.Sprite.CSpriteSystem;
import QFLib.Graphics.Sprite.CSpriteText;
import QFLib.Interface.IDisposable;

public class CPlayerSpriteItem implements IDisposable {
    public function CPlayerSpriteItem( container : CPlayerSpriteContainer = null ) {
        m_pSpriteContainer = container;
    }

    public function createSpriteText( text : String = null, fontName : String = null, fontSize : int = 32,
                                      width : int = 40, height : int = 32, piority : int = 0,
                                      extraX : Number = 0.0, extraY : Number = 0.0 ) : void {
        m_nFontName = fontName;
        m_sText = text;
        m_nWidth = width;
        m_nHeight = height;
        m_nPriority = piority;
        m_nFontSide = fontSize;
        if ( m_theSpriteText == null )
            m_theSpriteText = new CSpriteText( pSpriteSystem, 250, 48, false );
        m_theSpriteText.fontName = fontName;
        m_theSpriteText.fontSize = fontSize;
        m_theSpriteText.fontAutoScale = false;
        m_theSpriteText.text = text;
        m_fExtraOffSetX = extraX;
        m_fExtraOffSetY = extraY;

    }

    public function setSpriteText( theSpriteText : CSpriteText, width : int = 0,
                                   height : int = 32, priority : int = -1 ) : void {
        this.m_theSpriteText = theSpriteText;
        m_nWidth = width;
        m_nHeight = height;
        this.m_nPriority = priority;
    }

    public function setText( text : String ) : void {
        if ( m_theSpriteText != null )
            m_theSpriteText.text = text;
        else
            Foundation.Log.logTraceMsg( "U must init the spriteItem using func createSpriteText() before set text to it " );
    }

    public function setExtraPosition( x : Number, y : Number ) : void {
        this.m_fExtraOffSetX = x;
        this.m_fExtraOffSetY = y;
    }

    public function dispose() : void {
        m_pSpriteContainer = null;
        if ( m_theSpriteText )
            m_theSpriteText.dispose();
        m_theSpriteText = null;
    }

    public function get theSpriteText() : CSpriteText {
        return m_theSpriteText;
    }

    public function get priority() : int {
        return m_nPriority;
    }

    public function get width() : int {
        return m_nWidth;
    }

    public function get height() : int {
        return m_nHeight;
    }

    public function setPosition( x : Number, y : Number ) : void {
        m_theSpriteText.setPosition( x + m_fExtraOffSetX, y + m_fExtraOffSetY );
    }

    final protected function get pSpriteSystem() : CSpriteSystem {
        return this.m_pSpriteContainer.pSpriteSystem;
    }

    public function set priority( p : int ) : void {
        m_nPriority = p;
        if ( m_pSpriteContainer )
            m_pSpriteContainer._reSortSpriteItems();
    }

    private var m_pSpriteContainer : CPlayerSpriteContainer;
    private var m_theSpriteText : CSpriteText;
    private var m_nPriority : int;
    private var m_nFontName : String;
    private var m_nFontSide : int;
    private var m_sText : String;
    private var m_nWidth : int;
    private var m_nHeight : int;
    private var m_fExtraOffSetX : Number;
    private var m_fExtraOffSetY : Number;

}
}
