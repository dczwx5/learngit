//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/8.
 */
package kof.game.recruitRank {
/*绑定系统*/


import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.recruitRank.view.CRankQueryView;
import kof.game.recruitRank.view.CRecruitRankTotalView;
import kof.game.recruitRank.view.CRecruitRankView;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.recruitRank.view.CRecruitRewardView;
import kof.table.BundleEnable;

import morn.core.handlers.Handler;

public class CRecruitRankSystem extends CBundleSystem implements ISystemBundle{
    private var _recruitView:CRecruitRankView;
    private var _recruitManager:CRecruitRankManager;
    private var _recruitLogic:CRecruitRankHandler;
    private var _recruitRewardview:CRecruitRewardView;
    private var _recruitTotalView:CRecruitRankTotalView;
    private var _pRankMenuHandler : CRankQueryView;
    public function  CRecruitRankSystem()
    {
        super();
    }

    override public function dispose():void
    {
        super.dispose();

        _recruitLogic.dispose();
        _recruitManager.dispose();
        _recruitView.dispose();

    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
            return false;
        var ret : Boolean = super.initialize();
        ret = ret && addBean( _recruitLogic = new CRecruitRankHandler() );
        ret = ret && addBean( _recruitView = new CRecruitRankView() );
        ret = ret && addBean( _recruitManager = new CRecruitRankManager() );
        ret = ret && addBean( _recruitRewardview = new CRecruitRewardView() );
        ret = ret && addBean( _recruitTotalView = new CRecruitRankTotalView() );
        ret = ret && addBean( _pRankMenuHandler = new CRankQueryView() );
        if(ret)
        {
            var pView : CRecruitRankView = this.getBean(CRecruitRankView);
            if(pView)
                pView.closeHandler = new Handler( onViewClosed);
        }
        return ret;
    }

    override protected function onBundleStart(ctx : ISystemBundleContext) : void
    {
        _recruitLogic.onActivityDataRequest();
    }

    override protected  function onActivated(value : Boolean) : void
    {
        super.onActivated(value);
            if(value)
            {
                _recruitManager.firstOpen = false;
                _recruitView.addDisplay();
            }
            else
            {
                _recruitView.removeDisplay();
                _recruitRewardview.removeDisplay();
                _recruitTotalView.removeDisplay();
        }
    }

    public function onViewClosed():void
    {
        this.setActivated(false);
    }
    public function changeActivityState( bool:Boolean ) : void {
        if(bool)
        {
            this.ctx.startBundle(this);
        }
       else
        {
            this.ctx.stopBundle(this);
            var pView : CRecruitRankView = this.getBean( CRecruitRankView);
            if(pView) pView.removeDisplay();//如果界面开着，就强制关掉
        }
    }
    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.RECRUIT_RANK);
    }

    public function get ConfigLevel():int
    {
        var pDB : IDatabase = stage.getSystem( IDatabase ) as IDatabase;
        if( !pDB ) return 0;
        var pTable : IDataTable = pDB.getTable( KOFTableConstants.BUNDLE_ENABLE );
        if( !pTable ) return 0;
        var arr : Array = pTable.toArray();
        for each ( var v : BundleEnable in arr )
        {
            if ( v.ID == bundleID )
                return v.MinLevel;
        }
        return 0;
    }
}
}