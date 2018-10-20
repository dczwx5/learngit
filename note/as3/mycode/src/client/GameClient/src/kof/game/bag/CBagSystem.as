//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/9/21.
 */
package kof.game.bag {

import QFLib.Foundation.CMap;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bag.view.CBagBatchHandler;
import kof.game.bag.view.CBagItemTipsHandler;
import kof.game.bag.view.CBagMenuHandler;
import kof.game.bag.view.CBagPropsSynthesisHandler;
import kof.game.bag.view.CBagViewHandler;
import kof.game.bag.view.CBageOptionalBonusHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;

import morn.core.handlers.Handler;

public class CBagSystem extends CBundleSystem implements IBagSystem{

    private var _bagViewHandler:CBagViewHandler;
    private var _bagMenuHandler:CBagMenuHandler;
    private var _bagBatchHandler:CBagBatchHandler;
    private var _bageOptionalBonusHandler:CBageOptionalBonusHandler;
    private var _bagPropsSynthesisHandler:CBagPropsSynthesisHandler;
    private var _bagItemTipsHandler:CBagItemTipsHandler;

    private var _bagManager:CBagManager;
    private var _bagHandler:CBagHandler;
    private var _funcList:CMap;

    public function CBagSystem() {
        super();
    }
    public override function dispose() : void {
        super.dispose();

        _bagViewHandler.dispose();
        _bagMenuHandler.dispose();
        _bagManager.dispose();
        _bagHandler.dispose();
        _bagBatchHandler.dispose();
        _bageOptionalBonusHandler.dispose();
        _bagPropsSynthesisHandler.dispose();
        _bagItemTipsHandler.dispose();

        var funcs:Array = _funcList.toArray();
        for each (var func:Function in funcs) {
            this.unListenEvent(func);
        }
        _funcList = null;

    }

    override public function initialize() : Boolean {
        var ret : Boolean = super.initialize();
        ret = ret && addBean( _bagManager = new CBagManager() );
        ret = ret && addBean( _bagHandler = new CBagHandler() );
        ret = ret && addBean( _bagViewHandler = new CBagViewHandler() );
        ret = ret && addBean( _bagMenuHandler = new CBagMenuHandler() );
        ret = ret && addBean( _bagBatchHandler = new CBagBatchHandler() );
        ret = ret && addBean( _bageOptionalBonusHandler = new CBageOptionalBonusHandler() );
        ret = ret && addBean( _bagPropsSynthesisHandler = new CBagPropsSynthesisHandler() );
//        ret = ret && addBean( _bagItemTipsHandler = new CBagItemTipsHandler() );

        if ( ret ) {
            _funcList = new CMap();

            var pView : CBagViewHandler = this.getBean( CBagViewHandler );
            pView.closeHandler = new Handler( _onViewClosed );
        }

        return ret;
    }

    override protected function onBundleStart( ctx : ISystemBundleContext ) : void {
        var pView : CBagViewHandler = this.getBean( CBagViewHandler );
        pView.loadAssetsByView( pView.viewClass );
    }

    override protected function onActivated( value : Boolean ) : void {
        var pView : CBagViewHandler = this.getBean( CBagViewHandler );

        if (pView) {
            if ( value )
                pView.addDisplay();
            else
                pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        setActivated( false );
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.BAG );
    }

    public function listenEvent(func:Function) : void {
        if (null == func) return ;
        unListenEvent(func);

        _funcList[func] = func;
        this.addEventListener(CBagEvent.BAG_UPDATE, func);
    }

    public function unListenEvent(func:Function) : void {
        if (null == func) return ;

        if (_funcList)
            _funcList.remove(func);
        this.removeEventListener(CBagEvent.BAG_UPDATE, func);
    }

    public function getBagDataByType(type:int) : Array{
        if(_bagManager){
            return _bagManager.getBagDataByType();
        }
        return null;
    }



}
}
