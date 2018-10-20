//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import QFLib.Foundation.free;
import QFLib.Interface.IUpdatable;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;

import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.ui.master.temp.QQGroupOverlayUI;

/**
 * QQ群组全局界面覆盖显示
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CQQGroupOverlayViewHandler extends CViewHandler implements IUpdatable {

    private var m_pUI : QQGroupOverlayUI;

    public function CQQGroupOverlayViewHandler() {
        super( true );
    }

    override public function dispose() : void {
        super.dispose();
        if ( m_pUI ) {
            if ( m_pUI.lnkCopy )
                m_pUI.lnkCopy.removeEventListener( MouseEvent.CLICK, _onLinkCopyClick );

            this.removeDisplay();

            free( m_pUI );
        }

        m_pUI = null;
    }

    override public function get viewClass() : Array {
        return [ QQGroupOverlayUI ];
    }

    override protected virtual function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();

        this.addDisplay();
    }

    override protected function onInitializeView() : Boolean {
        m_pUI = m_pUI || new QQGroupOverlayUI();

        m_pUI.lnkCopy.addEventListener( MouseEvent.CLICK, _onLinkCopyClick, false, CEventPriority.DEFAULT_HANDLER, true );

        this.qqgroup = system.stage.configuration.getNumber( "external.qqgroup", system.stage.configuration.getNumber( "qqgroup", 0 ) );

        if ( this.qqgroup == 0.0 ) {
            m_pUI.visible = false;
        }

        return Boolean( m_pUI );
    }

    private function _onLinkCopyClick( event : MouseEvent ) : void {
//        if ( Clipboard.generalClipboard ) {
//            Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, "574596924", false );
//        }

        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "joinQQGroup" );
            } catch ( e : Error ) {
                LOG.logErrorMsg( "External call 'joinQQGroup' failed: " + e.message );
            }
        }
    }

    private function _onStageResizeEventHandler( event : Event ) : void {
        this.invalidateDisplay();
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addDisplay );
    }

    protected function _addDisplay() : void {
        if ( this.onInitializeView() ) {
            this.invalidate();

            if ( m_pUI ) {
                system.stage.flashStage.addChild( m_pUI );
            }

            system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResizeEventHandler, false, CEventPriority.DEFAULT_HANDLER, true );

            this.schedule( 1 / 30, update );
        }
    }

    public function removeDisplay() : void {
        if ( m_pUI ) {
            m_pUI.remove();
        }

        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResizeEventHandler );

        this.unschedule( update );
    }

    public function update( delta : Number ) : void {
        if ( system.stage.flashStage ) {
            var idx : int = system.stage.flashStage.getChildIndex( m_pUI );
            if ( idx > 0 && idx < system.stage.flashStage.numChildren - 1 ) {
                system.stage.flashStage.setChildIndex( m_pUI, system.stage.flashStage.numChildren - 1 );
            }
        }
    }

    override protected virtual function updateData() : void {
        super.updateData();

        m_pUI.clipQQGroup.num = this.qqgroup;
    }

    override protected virtual function updateDisplay() : void {
        super.updateDisplay();

        // center top the display in stage.
        m_pUI.x = system.stage.flashStage.stageWidth - m_pUI.width >> 1;
        m_pUI.y = 0;
    }

    private var m_nQQGroup : Number;

    final public function get qqgroup() : Number {
        return m_nQQGroup;
    }

    final public function set qqgroup( value : Number ) : void {
        if ( m_nQQGroup == value ) return;
        m_nQQGroup = value;
        this.invalidateData();
    }

}
}
