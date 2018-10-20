//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import kof.framework.CViewHandler;
import kof.ui.demo.GlobalViewUI;

public class CGlobalViewHandler extends CViewHandler {

    private var m_globalViewUI : GlobalViewUI;

    public function CGlobalViewHandler() {
        super( true ); // load view by default to call onInitializeView
    }

    override public function dispose() : void {
        super.dispose();
        if ( m_globalViewUI ) {
            m_globalViewUI.remove();
        }
        m_globalViewUI = null;
    }

    override public function get viewClass() : Array {
        return [ GlobalViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        m_globalViewUI = m_globalViewUI || new GlobalViewUI();

        m_globalViewUI.leftBox.visible = false;
        m_globalViewUI.rightBox.visible = false;
        return true;
    }

    public function showGo(isRight:Boolean) : void {
        if ( !m_globalViewUI )
            return;

        m_globalViewUI.leftBox.visible = !(m_globalViewUI.rightBox.visible = isRight);

        callLater( addDisplay );
    }

    final private function addDisplay() : void {
        if ( m_globalViewUI && !m_globalViewUI.parent )
            uiCanvas.rootContainer.addChild( m_globalViewUI );
    }

    public function hideGo() : void {
        if ( !m_globalViewUI )
            return;

        if ( m_globalViewUI )
            m_globalViewUI.remove();
    }

}
}
