//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 12:25
 */
package kof.game.diamondRoulette {

import kof.game.KOFSysTags;
import kof.game.common.view.CTweenViewHandler;
import kof.game.diamondRoulette.control.CAbstractControl;
import kof.game.diamondRoulette.control.CRDControl;
import kof.game.diamondRoulette.models.CAbstractModel;
import kof.game.diamondRoulette.models.CRDNetDataManager;
import kof.game.diamondRoulette.view.CAbstractView;
import kof.game.diamondRoulette.view.CRDView;
import kof.ui.master.DiamondRoulette.DiamondRoulettemainUI;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class CReturnDiamondViewHandler extends CTweenViewHandler{
    private var _bViewInitialized : Boolean = false;
    private var _view:CAbstractView = null;
    private var _closeHandler:Function = null;

    public function CReturnDiamondViewHandler() {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function get viewClass() : Array {
        return [DiamondRoulettemainUI];
    }

    override protected function get additionalAssets() : Array {
        return [
            "DiamondRoulette.swf"
        ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !_bViewInitialized ) {
            _init();
            _bViewInitialized = true;
        }
        return _bViewInitialized;
    }

    private function _init():void{
        var control:CAbstractControl = system.getBean(CRDControl) as CRDControl;
        var model:CRDNetDataManager = system.getBean(CRDNetDataManager) as CRDNetDataManager;
        control.model = model;
        _view = new CRDView(control);
        _view.uiCanvas = uiCanvas;
        _view.closeHandler = _closeHandler;
        _view.system = system as CReturnDiamondSystem;
        model.addView(_view);
    }

    public function show():void{
        this.loadAssetsByView( viewClass, _showDisplay );

    }

    private function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _showView );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _showView() : void {
        if(_view){
            _view.show();
        }
    }

    public function close():void{
        if(_view){
            _view.close();
        }
    }

    public function set closeHandler(value:Function):void{
        _closeHandler = value;
    }

}
}
