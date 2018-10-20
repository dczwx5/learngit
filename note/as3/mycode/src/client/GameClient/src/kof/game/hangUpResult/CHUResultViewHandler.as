//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/11/22.
 * Time: 10:08
 */
package kof.game.hangUpResult {

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.hook.view.childViews.CHangUpResultView;
import kof.ui.demo.Bag.QualityBoxUI;
import kof.ui.master.hangup.HangUpResultUI;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/11/22
 */
public class CHUResultViewHandler extends CViewHandler{
    private var _bViewInitialized : Boolean = false;
    private var _huResuldView:CHangUpResultView = null;
    public function CHUResultViewHandler() {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function get viewClass() : Array {
        return [ HangUpResultUI ,QualityBoxUI];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !_bViewInitialized ) {
            _bViewInitialized = true;
            _huResuldView = new CHangUpResultView(this);
        }
        return _bViewInitialized;
    }

    public function show() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            _showView();
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _showView() : void {
        if(_huResuldView)
        _huResuldView.show();
    }

    public function close():void{
        if(_huResuldView)
        _huResuldView.close();
    }
}
}
