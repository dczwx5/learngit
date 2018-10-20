//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import kof.framework.CViewHandler;
import kof.ui.Loading.UILoadingViewUI;

/**
 * UI加载界面控制
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CUILoadingViewHandler extends CViewHandler {

    /** @private */
    private var m_pUIView : UILoadingViewUI;
    /** @private */
    private var m_fValue : Number;

    /** Creates an new CUILoadingViewHandler. */
    public function CUILoadingViewHandler() {
        super( true );
    }

    override public function get viewClass() : Array {
        return [ UILoadingViewUI ];
    }

    override protected virtual function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        var ret : Boolean = super.onInitializeView();
        if ( !ret )
            return false;

        if ( !m_pUIView ) {
            m_pUIView = new UILoadingViewUI();
            m_pUIView.progress_bar.value = 0;
        }

        this.invalidate();

        return ret;
    }

    public function get value() : Number {
        return m_fValue;
    }

    public function set value( value : Number ) : void {
        if ( m_fValue == value )
            return;
        m_fValue = value;
        this.invalidateData();
    }

    override protected virtual function updateData() : void {
        super.updateData();

        if ( m_pUIView ) {
            if ( m_pUIView.progress_bar ) {
                m_pUIView.progress_bar.value = this.value;
            }

            if ( m_pUIView.lbl_progress ) {
                m_pUIView.lbl_progress.text = (this.value * 100.0).toFixed().toString() + "%";
            }
        }
    }

    public function addDisplay() : void {
        var pUISys : CUISystem = uiCanvas as CUISystem;
        if ( pUISys ) {
            this.invalidate();
            pUISys.loadingLayer.addChildAt( this.m_pUIView, 0 );
        }
    }

    public function removeDisplay() : void {
        if ( m_pUIView ) {
            m_pUIView.close();
        }
    }

}
}
