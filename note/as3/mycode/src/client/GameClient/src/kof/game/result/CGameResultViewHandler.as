//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.result {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.ui.demo.ResultUI;

import morn.core.events.UIEvent;

/**
 * KO显示界面
 *
 * @author Eddy.
 */
public class CGameResultViewHandler extends CViewHandler {

    private var m_resultUI : ResultUI;

    private var _fDuration : Number;

    private var _callBackFun : Function;

    private var _playing : Boolean;

    private var m_bViewInitialized : Boolean;

    public function CGameResultViewHandler() {
        super( false );

        removeDisplay();
        m_resultUI = null;
    }
    override public function get viewClass() : Array {
        return [ ResultUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "frame_ko.swf"
        ];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_resultUI ) {
                m_resultUI = new ResultUI();
                m_resultUI.mc_ko.stop();
                m_resultUI.mc_ko.mouseEnabled = m_resultUI.mc_ko.mouseChildren = false;
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay( fDuration : Number = NaN, callBackFun : Function = null) : void {
        _fDuration = fDuration;
        _callBackFun = callBackFun;
        this.loadAssetsByView( viewClass, _showDisplay );
    }
    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if( m_resultUI ){

            _playing = true;
            uiCanvas.addPopupDialog( m_resultUI );
            m_resultUI.mc_ko.addEventListener( UIEvent.FRAME_CHANGED, _onChanged, false, CEventPriority.DEFAULT, true );
            m_resultUI.mc_ko.gotoAndPlay( 0 );

            delayCall( _fDuration, _onDurationEnd );
        }
    }

    private function _onDurationEnd() : void {
        onFinish();
    }

    private function _onChanged( evt : UIEvent ) : void {
        if ( m_resultUI.mc_ko.frame >= m_resultUI.mc_ko.totalFrame - 1 ) {
            // 最后一帧
            m_resultUI.mc_ko.removeEventListener( UIEvent.FRAME_CHANGED, _onChanged );
            m_resultUI.mc_ko.gotoAndStop( m_resultUI.mc_ko.totalFrame - 1 );
            onFinish();
        }
    }

    private function onFinish() : void {
        if ( m_resultUI ) {
            m_resultUI.dispatchEvent( new Event( "GameResultFinished" ) );
            this.dispatchEvent( new Event( "GameResultFinished" ) );
            _playing = false;

            if ( _callBackFun ) {
                _callBackFun.apply();
            }

            unschedule( _onDurationEnd );

            m_resultUI.mc_ko.stop();
            m_resultUI.mc_ko.removeEventListener( UIEvent.FRAME_CHANGED, _onChanged );
            m_resultUI.close();
//            m_resultUI = null;
        }
    }

    public function get isPlaying() : Boolean {
        return _playing;
    }

    public function removeDisplay() : void {
        if ( m_resultUI ) {
            m_resultUI.close();
        }
    }
}
}
