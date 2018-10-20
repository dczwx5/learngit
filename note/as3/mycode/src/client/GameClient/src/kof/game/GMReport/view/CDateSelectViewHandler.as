//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/13.
 */
package kof.game.GMReport.view {

import QFLib.Foundation.CTime;

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.GMReport.enum.ETimeType;
import kof.ui.imp_common.DateSelectRenderUI;
import kof.ui.imp_common.DateSelectUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CDateSelectViewHandler extends CViewHandler
{
    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : DateSelectUI;
    private var m_iTimeType:int;
    private var m_iMonth:int;

    public function CDateSelectViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [DateSelectUI];
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
                m_pViewUI = new DateSelectUI();
                m_pViewUI.list_date.selectHandler = new Handler(_onSelectHandler);
                m_pViewUI.list_date.renderHandler = new Handler(_renderHandler);

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
//        uiCanvas.addDialog( m_pViewUI );
        uiCanvas.addPopupDialog( m_pViewUI );

        var p:Point = m_pViewUI.parent.localToGlobal(new Point(m_pViewUI.parent.mouseX, m_pViewUI.parent.mouseY));
        m_pViewUI.x = p.x-30;
        m_pViewUI.y = p.y-30;

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
        m_pViewUI.addEventListener( MouseEvent.ROLL_OUT, _onRollOutHandler, false, 0, true);
        system.stage.flashStage.addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMoveHandler, false, 0, true);
    }

    private function _removeListeners():void
    {
        m_pViewUI.removeEventListener( MouseEvent.ROLL_OUT, _onRollOutHandler);
        system.stage.flashStage.removeEventListener( MouseEvent.MOUSE_MOVE, _onMouseMoveHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _updateTimeList();
            m_pViewUI.list_date.selectedIndex = -1;

            _updateBg();
        }
    }

    private function _updateTimeList():void
    {
        var arr:Array = [];

        if(m_iTimeType == ETimeType.Type_Year)
        {
            var date:Date = new Date(CTime.getCurrServerTimestamp());
            arr[0] = date.fullYear - 1;
            arr[1] = date.fullYear;
        }

        if(m_iTimeType == ETimeType.Type_Month)
        {
            for(var i:int = 0; i < 12; i++)
            {
                arr[i] = i+1;
            }
        }

        if(m_iTimeType == ETimeType.Type_Day)
        {
            var arr2:Array = [1,3,5,7,8,10,12];
            var totalMonth:int = (arr2.indexOf(m_iMonth) == -1) ? 30 : 31;
            for(i = 0; i < totalMonth; i++)
            {
                arr[i] = i+1;
            }
        }

        if(m_iTimeType == ETimeType.Type_Hour)
        {
            for(i = 0; i < 23; i++)
            {
                arr[i] = i+1;
            }
        }

        if(m_iTimeType == ETimeType.Type_Min)
        {
            for(i = 0; i < 59; i++)
            {
                arr[i] = i+1;
            }
        }

        m_pViewUI.list_date.dataSource = arr;
    }

    private function _updateBg():void
    {
        switch (m_iTimeType)
        {
            case ETimeType.Type_Month:
                m_pViewUI.img_bg.height = 86;
                break;
            case ETimeType.Type_Day:
                m_pViewUI.img_bg.height = 146;
                break;
            case ETimeType.Type_Hour:
                m_pViewUI.img_bg.height = 116;
                break;
            case ETimeType.Type_Min:
                m_pViewUI.img_bg.height = 240;
                break;
        }

        var stageHeight:int = system.stage.flashStage.stageHeight;
        if((m_pViewUI.y + m_pViewUI.img_bg.height) > stageHeight)
        {
            m_pViewUI.y = stageHeight - m_pViewUI.img_bg.height;
        }
    }

    private function _onSelectHandler(index:int):void
    {
        if(index == -1)
        {
            return;
        }

        var time:int = m_pViewUI.list_date.getItem(index) as int;
        var obj:Object = {};
        obj["timeType"] = m_iTimeType;
        obj["time"] = time;
        system.getHandler(CGMReportViewHandler).dispatchEvent(new CGMReportEvent(CGMReportEvent.SelectDate, obj));

        this.removeDisplay();
    }

    private function _renderHandler(item:Component, index:int):void
    {
        if ( !(item is DateSelectRenderUI) )
        {
            return;
        }

        var render:DateSelectRenderUI = item as DateSelectRenderUI;
        render.mouseEnabled = true;
        var data:int = render.dataSource as int;
        if(data)
        {
            render.txt_time.text = data.toString();
        }
        else
        {
            render.txt_time.text = "";
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

    public function set timeType(value:int):void
    {
        m_iTimeType = value;
    }

    public function set selMonth(value:int):void
    {
        m_iMonth = value;
    }
}
}
