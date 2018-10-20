//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.util {

import QFLib.Interface.IDisposable;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.getTimer;

public class Fps extends Sprite implements IDisposable {
    private static const s_fMaxMemory : Number = 4 * 1024 * 1024 * 1024; // Max 4G.

    private var m_txtFPS : TextField;
    private var m_txtMEM : TextField;
    private var m_theStatsBM : Bitmap;
    private var m_theStatsBMD : BitmapData;
    private var m_iFrameCount : int = 0;
    private var m_iLastTime : Number = 0;
    private var m_iTotalTime : Number = 0;
    private var m_fDiagramTimer : int;
    private var m_iSkins : int = -1;
    private var m_iSkinsChanged : int = 0;
    private var m_fDiagramHeight : Number;
    private var m_fDiagramWidth : Number;
    private var m_bDiagramSizeDirty : Boolean;

    private var m_fFPSColor : Number = 0xFFFF0000;
    private var m_fMEMColor : Number = 0xFF00FF00;
    private var m_fBGColor : Number = 0xAA000000;
    private var m_strFont : String = "Tahoma";
    private var m_iFontSize : int = 12;
    private var m_bFormatDirty : Boolean;
    private var m_theFontOutline : BitmapFilter;

    private var m_fUpdateInterval : Number = 1.0;

    public function Fps( diagramWidth : Number = 80, diagramHeight : Number = 60, updateInterval : Number = 0.5 ) {
        this.addEventListener( Event.ADDED_TO_STAGE, init );
        this.diagramWidth = diagramWidth;
        this.diagramHeight = diagramHeight;
        this.updateInterval = updateInterval;

        this.mouseEnabled = false;
        this.mouseChildren = false;
    }

    public function dispose() : void {
        if ( m_theStatsBMD )
            m_theStatsBMD.dispose();
        m_theStatsBMD = null;

        if ( m_theStatsBM && m_theStatsBM.parent )
            m_theStatsBM.parent.removeChild( m_theStatsBM );
        m_theStatsBM = null;
        m_theFontOutline = null;
    }

    final private function init( e : Event ) : void {
        this.removeEventListener( Event.ADDED_TO_STAGE, init );
        m_txtFPS = new TextField();
        m_txtMEM = new TextField();

        /* m_theFontOutline = new DropShadowFilter( 0, 0, 0, 1, 1.5, 1.5, 10, 1, false, false ); */
        m_theFontOutline = new GlowFilter( 0x000000, 1, 2, 2, 10, 1, false, false );

        m_txtFPS.autoSize = TextFieldAutoSize.LEFT;
        m_txtFPS.text = "FPS:" + Number( stage.frameRate ).toFixed( 2 );
        m_txtFPS.filters = [ m_theFontOutline ];
        addChild( m_txtFPS );

        m_txtMEM.autoSize = TextFieldAutoSize.LEFT;
        m_txtMEM.text = "MEM:" + byteToString( System.totalMemory );
        m_txtMEM.filters = [ m_theFontOutline ];
        addChild( m_txtMEM );

        m_theStatsBM = new Bitmap( m_theStatsBMD );
        addChildAt( m_theStatsBM, 0 );

        addEventListener( Event.ENTER_FRAME, onEnterFrame );
        m_iLastTime = m_fDiagramTimer = getTimer();

        m_bFormatDirty = true;
    }

    final private function validateTextFormat() : void {
        if ( m_bFormatDirty ) {
            m_bFormatDirty = false;
            m_txtFPS.defaultTextFormat = new TextFormat( m_strFont, m_iFontSize, m_fFPSColor );
            m_txtMEM.defaultTextFormat = new TextFormat( m_strFont, m_iFontSize, m_fMEMColor );
            m_txtMEM.y = m_txtFPS.y + m_iFontSize;
        }
    }

    final private function validateDiagram() : void {
        if ( m_bDiagramSizeDirty ) {
            m_bDiagramSizeDirty = false;
            m_txtFPS.x = m_txtMEM.x = 0;

            m_theStatsBMD = new BitmapData( m_fDiagramWidth, m_fDiagramHeight, true, 0xFF );
            m_theStatsBM.bitmapData = m_theStatsBMD;
            m_theStatsBM.y = m_txtFPS.y + 2 * m_iFontSize + 4;
            m_theStatsBM.x = 0;

            m_theStatsBMD.fillRect( new Rectangle( 0, 0, m_theStatsBMD.width, m_theStatsBMD.height ), m_fBGColor );
        }
    }

    final private function onEnterFrame( e : Event ) : void {
        validateTextFormat();
        validateDiagram();
        if(stage == null) return;

        // Calc FPS, MEM usage per sec.
        const v_iNow : Number = getTimer();
        m_iTotalTime = ( v_iNow - m_iLastTime ) * 0.001;
        m_iFrameCount++;

        if ( m_iTotalTime > m_fUpdateInterval ) {
            var v_iFPS : Number = m_iFrameCount / m_iTotalTime;
            m_txtFPS.text = "FPS: " + v_iFPS.toFixed( v_iFPS < 100 ? 1 : 0 ) + '/' + stage.frameRate;
            m_txtMEM.text = "MEM: " + byteToString( System.totalMemory );
            m_iFrameCount = m_iTotalTime = 0;
            m_iLastTime = v_iNow;

            var v_fFPSRatio : Number = v_iFPS > stage.frameRate ? (1) : Number( v_iFPS / stage.frameRate );

            m_theStatsBMD.scroll( 1, 0 );
            m_theStatsBMD.fillRect( new Rectangle( 0, 0, 1, m_theStatsBMD.height ), m_fBGColor );
            m_theStatsBMD.setPixel32( 0, m_fDiagramHeight * (1 - v_fFPSRatio), m_fFPSColor );

            // Record MEM usage per frame.
            var ski : int = m_iSkins == 0 ? (0) : (m_iSkinsChanged / m_iSkins);
            m_theStatsBMD.setPixel32( 0, m_fDiagramHeight * (1 - ski), 0xFFFFFFFF );
            var memoryPerSec : Number = System.totalMemory / s_fMaxMemory;
            m_theStatsBMD.setPixel32( 0, m_fDiagramHeight * (1 - memoryPerSec), m_fMEMColor );
        }
    }

    final public function get updateInterval() : Number {
        return m_fUpdateInterval;
    }

    final public function set updateInterval( value : Number ) : void {
        m_fUpdateInterval = value;
    }

    final public function get fpsColor() : Number {
        return m_fFPSColor;
    }

    final public function set fpsColor( value : Number ) : void {
        if ( m_fFPSColor == value ) return;
        m_fFPSColor = value;
        m_bFormatDirty = true;
    }

    final public function get memColor() : Number {
        return m_fMEMColor;
    }

    final public function set memColor( value : Number ) : void {
        if ( m_fMEMColor == value ) return;
        m_fMEMColor = value;
        m_bFormatDirty = true;
    }

    final public function get diagramWidth() : Number {
        return m_fDiagramWidth;
    }

    final public function set diagramWidth( value : Number ) : void {
        if ( m_fDiagramWidth == value ) return;
        m_fDiagramWidth = value;
        m_bDiagramSizeDirty = true;
    }

    final public function get diagramHeight() : Number {
        return m_fDiagramHeight;
    }

    final public function set diagramHeight( value : Number ) : void {
        if ( m_fDiagramHeight == value ) return;
        m_fDiagramHeight = value;
        m_bDiagramSizeDirty = true;
    }

    private function byteToString( byte : uint ) : String {
        var byteStr : String = null;
        if ( byte < 1024 ) {
            byteStr = String( byte ) + "b";
        }
        else if ( byte < 10240 ) {
            byteStr = Number( byte / 1024 ).toFixed( 2 ) + "kb";
        }
        else if ( byte < 102400 ) {
            byteStr = Number( byte / 1024 ).toFixed( 1 ) + "kb";
        }
        else if ( byte < 1048576 ) {
            byteStr = Math.round( byte / 1024 ) + "kb";
        }
        else if ( byte < 10485760 ) {
            byteStr = Number( byte / 1048576 ).toFixed( 2 ) + "mb";
        }
        else if ( byte < 104857600 ) {
            byteStr = Number( byte / 1048576 ).toFixed( 1 ) + "mb";
        }
        else {
            byteStr = Math.round( byte / 1048576 ) + "mb";
        }
        return byteStr;
    }

}
}

