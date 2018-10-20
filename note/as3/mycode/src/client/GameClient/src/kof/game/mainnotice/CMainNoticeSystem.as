//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/5.
 */
package kof.game.mainnotice {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;

public class CMainNoticeSystem extends CBundleSystem {

    private var _mainNoticeViewHandler : CMainNoticeViewHandler;
    private var _mainNoticePanelViewHandler : CMainNoticePanelViewHandler;

    public function CMainNoticeSystem() {
        super();
    }

    public override function dispose() : void {
        super.dispose();

        if ( _mainNoticeViewHandler )
            _mainNoticeViewHandler.dispose();
        _mainNoticeViewHandler = null;

        if ( _mainNoticePanelViewHandler )
            _mainNoticePanelViewHandler.dispose();
        _mainNoticePanelViewHandler = null;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.MAINNOTICE_SYSTEM );
    }
    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var ret : Boolean = true;

        var domain:CMainNoticeMessageList;

        ret = ret && addBean((domain = new CMainNoticeMessageList()));
        ret = ret && addBean(_mainNoticeViewHandler = new CMainNoticeViewHandler( ));
        ret = ret && addBean(_mainNoticePanelViewHandler = new CMainNoticePanelViewHandler());
        ret = ret && addBean(new CMainNoticeHandler());

        return ret;
    }

    override protected function onBundleStart( ctx : ISystemBundleContext ) : void {
        var pView : CMainNoticeViewHandler = this.getBean( CMainNoticeViewHandler );
        pView.loadAssetsByView( pView.viewClass );
    }


}
}
