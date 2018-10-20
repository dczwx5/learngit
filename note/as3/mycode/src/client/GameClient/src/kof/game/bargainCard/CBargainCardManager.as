//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/9/10.
 */
package kof.game.bargainCard {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundleContext;
import kof.table.CardMonthConfig;

public class CBargainCardManager extends CAbstractHandler{
    public const SILVER : int = 1;
    public const GOLD : int = 2;
    private var _baseTable : IDataTable;  //基础数据
    private var _responseData : Object;   //返回数据
    private var _isFirstOpen : Boolean;   //是否第一次打开
    public function CBargainCardManager() {
        super();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        _baseTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.CARD_MONTH_CONFIG);
        return ret;
    }

    public function get silverData() : CardMonthConfig
    {
        return _baseTable.findByPrimaryKey( SILVER );
    }

    public function get goldData() : CardMonthConfig
    {
        return _baseTable.findByPrimaryKey( GOLD );
    }

    public function set responseData(value : Object) : void
    {
        _responseData = value;
        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BUY_MONTH_CARD ) ) );
        if(iStateValue)
            _bargainCardSystem.updateRedTips();
    }
    public function get responseData() : Object
    {
        return _responseData;
    }
    //是否可领取周卡
    public function get silverRewardState() : Boolean
    {
        return _responseData && _responseData.silverCardState && !_responseData.silverCardRewardState;
    }
    //是否可领取月卡
    public function get goldRewardState() : Boolean
    {
        return _responseData && _responseData.goldCardState && !_responseData.goldCardRewardState;
    }
    public function set firstOpen(value : Boolean) : void
    {
        _isFirstOpen = value;
    }
    public function get firstOpen() : Boolean
    {
        return _isFirstOpen;
    }

    private function get _bargainCardSystem() : CBargainCardSystem
    {
        return system.stage.getSystem(CBargainCardSystem) as CBargainCardSystem;
    }
}
}
