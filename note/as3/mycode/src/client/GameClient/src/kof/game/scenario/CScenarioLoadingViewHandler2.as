//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/3/8.
 */
package kof.game.scenario {

import flash.utils.getTimer;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.table.DeskTips;
import kof.ui.CUISystem;
import kof.ui.Loading.UILoadingViewUI;

public class CScenarioLoadingViewHandler2 extends CViewHandler{

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI : UILoadingViewUI;

    public function CScenarioLoadingViewHandler2() {
        super(false);
    }
    override public function dispose() : void {
        super.dispose();
    }

    override public function get viewClass() : Array {
        return [ UILoadingViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function get additionalAssets() : Array {
        return [];
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() ) {
            return false;
        }

        if ( !m_bViewInitialized ) {
            if ( !m_pViewUI ) {
                m_pViewUI = new UILoadingViewUI();
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void {
        _isRemoved = false;
        delayCall(0.8, _onDelayShowBack)
    }
    private function _onDelayShowBack() : void {
        if (!_isRemoved) {
            this.loadAssetsByView( viewClass, _showDisplay );
        }
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        if (_isRemoved) {
            // 剧情loading开始, 加载ui, 剧情结束, ui加载完 <- 这种情况会有问题
            return ;
        }

        var pUISystem : CUISystem = uiCanvas as CUISystem;
        pUISystem.loadingLayer.addChildAt(m_pViewUI, pUISystem.loadingLayer.numChildren-1);
        m_pViewUI.visible = true;

        _initView();
        _addListeners();

        _startTime = getTimer();
        schedule( 1 / 60, _onTick);
        _virtualLoadingRate = 0;

        var deskTipsTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.DESKTIPS );
        if(deskTipsTable){
            var deskTipsArray : Array = deskTipsTable.toArray();
            var index:int = (Math.random() * deskTipsArray.length);
            var deskTips:DeskTips = deskTipsArray[index];
            m_pViewUI.tips_txt.text = deskTips.tips;
        }
    }
    private function _initView() : void {
        updateDisplay();
    }
    private function _addListeners():void  {

    }

    public function removeDisplay() : void {
        _isRemoved = true;

        _removeListeners();
        if (m_pViewUI && m_pViewUI.parent) {
            m_pViewUI.parent.removeChild(m_pViewUI);
        }
        unschedule(_onTick);

    }
    private function _removeListeners() : void  {
    }

    override protected function updateDisplay() : void {

    }


    // tick
    private function _onTick(delta:Number) : void {
        var curTime:int = getTimer();
        var duringTime:int = curTime - _startTime;

        var p : Number = duringTime / ( 10000 );
        p = Math.min( p, 1 );
        p = Math.sqrt( 1 - ( p = p - 1 ) * p );

        var fRatioTotal : Number = p * 0.9999;
        if ( fRatioTotal > 0.9999 )
            fRatioTotal = 0.9999;

        _virtualLoadingRate = fRatioTotal;

        var rate:int = _virtualLoadingRate*100.0;
        m_pViewUI.progress_bar.value = rate/100.0;
        m_pViewUI.lbl_progress.text = rate + "%";


    }
    private var _virtualLoadingRate:Number;

    private var _startTime:int;

    private var _isRemoved: Boolean = false;

}
}
