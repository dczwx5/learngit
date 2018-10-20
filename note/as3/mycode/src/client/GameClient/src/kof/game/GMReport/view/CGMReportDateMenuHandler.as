//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/12.
 */
package kof.game.GMReport.view {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.GMReport.enum.ETimeType;
import kof.ui.imp_common.DateMenuUI;

import morn.core.components.Dialog;

public class CGMReportDateMenuHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:DateMenuUI;
    private var m_pData:*;

    public function CGMReportDateMenuHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [DateMenuUI];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new DateMenuUI();

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        m_pViewUI.popupCenter = false;
        uiCanvas.addPopupDialog( m_pViewUI );

        var p:Point = m_pViewUI.parent.localToGlobal(new Point(m_pViewUI.parent.mouseX, m_pViewUI.parent.mouseY));
        m_pViewUI.x = p.x-20;
        m_pViewUI.y = p.y-20;

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
        m_pViewUI.menu.addEventListener( Event.CHANGE, _onMenuSelectedHandler);
        m_pViewUI.menu.addEventListener( MouseEvent.ROLL_OUT, _onRollOutHandler, false, 0, true);
        system.stage.flashStage.addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMoveHandler, false, 0, true);
    }

    private function _removeListeners():void
    {
        m_pViewUI.menu.removeEventListener( Event.CHANGE, _onMenuSelectedHandler);
        m_pViewUI.menu.removeEventListener( MouseEvent.ROLL_OUT, _onRollOutHandler);
        system.stage.flashStage.removeEventListener( MouseEvent.MOUSE_MOVE, _onMouseMoveHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            m_pViewUI.menu.labels = m_pData as String;
        }
    }

    private function _onMenuSelectedHandler(e:Event):void
    {
        var selectedIndex : int = m_pViewUI.menu.selectedIndex;
        var label : String = m_pViewUI.menu.labels.split( "," )[ selectedIndex ];
        var obj:Object = {};
        obj["timeType"] = ETimeType.Type_Year;
        obj["time"] = int(label);
        system.getHandler(CGMReportViewHandler).dispatchEvent(new CGMReportEvent(CGMReportEvent.SelectDate, obj));

        if ( selectedIndex != -1 )
        {
            removeDisplay();
        }
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
        removeDisplay();
    }

    private function _onMouseMoveHandler(e:MouseEvent):void
    {
        var mouseX:Number = m_pViewUI.parent.mouseX;
        var mouseY:Number = m_pViewUI.parent.mouseY;

        if(mouseX < m_pViewUI.x || mouseX > (m_pViewUI.x + m_pViewUI.width)
            || mouseY < m_pViewUI.y || mouseY > (m_pViewUI.y + m_pViewUI.height))
        {
            removeDisplay();
        }
    }

    public function set data(value:String):void
    {
        m_pData = value;

        if(m_bViewInitialized && m_pViewUI)
        {
            m_pViewUI.menu.labels = value;
        }
    }

    public function show(x:int, y:int):void
    {
        addDisplay();
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }
}
}
