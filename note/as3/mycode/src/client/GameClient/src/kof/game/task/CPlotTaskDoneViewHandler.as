//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/6.
 */
package kof.game.task {

import kof.framework.CViewHandler;
import kof.ui.master.task.TaskPlotDoneUI;

import morn.core.components.Dialog;
import morn.core.events.UIEvent;

public class CPlotTaskDoneViewHandler extends CViewHandler {

    private var m_taskPlotDoneUI:TaskPlotDoneUI;

    public function CPlotTaskDoneViewHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ TaskPlotDoneUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_taskPlotDoneUI ) {
            m_taskPlotDoneUI = new TaskPlotDoneUI();
            m_taskPlotDoneUI.mouseEnabled =
                    m_taskPlotDoneUI.mouseChildren = false;
        }

        return Boolean( m_taskPlotDoneUI );
    }

    override protected function get additionalAssets() : Array {
        return [
            "taskdone.swf"
        ];
    }
    public function addDisplay() : void {
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
    public function _addToDisplay( ):void {
        m_taskPlotDoneUI.eff_taskDone.removeEventListener( UIEvent.FRAME_CHANGED  , onChanged );
        m_taskPlotDoneUI.eff_taskDone.addEventListener( UIEvent.FRAME_CHANGED  , onChanged );
        m_taskPlotDoneUI.eff_taskDone.gotoAndPlay(0);
        uiCanvas.addPopupDialog(m_taskPlotDoneUI);
    }
    private function onChanged(evt:UIEvent):void{
        if( m_taskPlotDoneUI.eff_taskDone.frame >=  m_taskPlotDoneUI.eff_taskDone.totalFrame - 1) {
            m_taskPlotDoneUI.eff_taskDone.removeEventListener( UIEvent.FRAME_CHANGED  , onChanged );
            m_taskPlotDoneUI.eff_taskDone.stop();
            m_taskPlotDoneUI.close( Dialog.OK );
        }
    }
}
}
