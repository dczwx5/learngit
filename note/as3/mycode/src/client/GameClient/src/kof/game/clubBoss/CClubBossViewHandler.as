//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/19.
 * Time: 17:47
 */
package kof.game.clubBoss {

import kof.framework.CViewHandler;
import kof.game.clubBoss.view.CCBMainView;
import kof.ui.imp_common.ItemTipsUI;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.clubBoss.CBEmbattleUI;
import kof.ui.master.clubBoss.CBMainUI;

import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/19
 */
public class CClubBossViewHandler extends CViewHandler {
    private var _bViewInitialized : Boolean = false;
    private var _mainView : CCBMainView = null;

    public function CClubBossViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function get viewClass() : Array {
        return [ CBMainUI , CBEmbattleUI,ItemUIUI,RewardItemUI];
    }

    override protected function get additionalAssets() : Array {
        return [
            "clubboss.swf"
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
            _mainView = new CCBMainView( this );
            _mainView.closeHandler = this.closeHandler;
            _bViewInitialized = true;
        }
        return _bViewInitialized;
    }

    public function show() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _showView );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _showView() : void {
        if(_mainView)
        _mainView.show()
    }

    public function close() : void {
        if(_mainView)
        _mainView.close();
    }

    private var _closeHandler : Handler = null;

    public function set closeHandler( value : Handler ) : void {
        _closeHandler = value;
    }

    public function get closeHandler() : Handler {
        return _closeHandler;
    }

    public function get isViewShow():Boolean
    {
        return _mainView && _mainView.isViewShow;
    }
}
}
