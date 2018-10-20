//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/9/21.
 */
package kof.game.activityTreasure {

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.activityTreasure.view.CActivityTreasureRewardPreviewViewHandler;
import kof.game.activityTreasure.view.CActivityTreasureTaskViewHandler;
import kof.game.activityTreasure.view.CActivityTreasureViewHandler;
import kof.game.bundle.CBundleSystem;
import kof.table.BundleEnable;

import morn.core.handlers.Handler;

public class CActivityTreasureSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var _pCActivityTreasureManager : CActivityTreasureManager;
    private var _pCActivityTreasureHandler : CActivityTreasureHandler;
    private var _pCActivityTreasureViewHandler : CActivityTreasureViewHandler;
    private var _pCActivityTreasureRewardPreviewViewHandler : CActivityTreasureRewardPreviewViewHandler;
    private var _pCActivityTreasureTaskViewHandler : CActivityTreasureTaskViewHandler;

    public function CActivityTreasureSystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        _pCActivityTreasureManager.dispose();
        _pCActivityTreasureHandler.dispose();
        _pCActivityTreasureViewHandler.dispose();
        _pCActivityTreasureRewardPreviewViewHandler.dispose();
        _pCActivityTreasureTaskViewHandler.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pCActivityTreasureManager = new CActivityTreasureManager() );
            this.addBean( _pCActivityTreasureHandler = new CActivityTreasureHandler() );
            this.addBean( _pCActivityTreasureViewHandler = new CActivityTreasureViewHandler() );
            this.addBean( _pCActivityTreasureRewardPreviewViewHandler = new CActivityTreasureRewardPreviewViewHandler() );
            this.addBean( _pCActivityTreasureTaskViewHandler = new CActivityTreasureTaskViewHandler() );

        }

        _pCActivityTreasureViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.ACTIVITY_TREASURE );
    }


    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CActivityTreasureViewHandler = this.getHandler( CActivityTreasureViewHandler ) as CActivityTreasureViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CActivityTreasureViewHandler isn't instance." );
            return;
        }

        if ( value ) {

            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    public function openSystem() : void {
        this.ctx.startBundle( this );
    }

    public function closeSystem() : void {
        _onViewClosed();
        this.ctx.stopBundle( this );
    }

    public function changeActivityState( bool : Boolean ) : void {
        if ( bool ) {
            this.ctx.startBundle( this );
        }
        else {
            this.ctx.stopBundle( this );
            var pView : CActivityTreasureViewHandler = this.getBean( CActivityTreasureViewHandler );
            if ( pView ) pView.removeDisplay();//如果界面开着，就强制关掉
        }
    }

    public function get ConfigLevel() : int {
        var pDB : IDatabase = stage.getSystem( IDatabase ) as IDatabase;
        if ( !pDB ) return 0;
        var pTable : IDataTable = pDB.getTable( KOFTableConstants.BUNDLE_ENABLE );
        if ( !pTable ) return 0;
        var arr : Array = pTable.toArray();
        for each ( var v : BundleEnable in arr ) {
            if ( v.ID == bundleID )
                return v.MinLevel;
        }
        return 0;
    }
}
}
