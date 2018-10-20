//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 12:24
 */
package kof.game.diamondRoulette {

import QFLib.Foundation.CTime;

import kof.SYSTEM_ID;
import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.limitActivity.enum.ELimitActivityState;
import kof.game.diamondRoulette.control.CRDControl;
import kof.game.diamondRoulette.models.CRDNetDataManager;
import kof.game.diamondRoulette.view.CRDView;
import kof.game.switching.CSwitchingSystem;
import kof.game.switching.validation.CSwitchingValidatorSeq;
import kof.game.talent.CTalentViewHandler;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.message.Activity.ActivityChangeResponse;
import kof.table.Activity;
import kof.table.DiamondRouletteConfig;
import kof.table.DiamondRouletteConst;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class CReturnDiamondSystem extends CBundleSystem {
    private var _bIsInitialize : Boolean = false;
    private var _rdViewHandler:CReturnDiamondViewHandler = null;
    private var _activityState:int=0;
    private var _startTime:Number=0;
    private var _endTime:Number=0;
    private var _time:Number=0
    private var _activityTable:IDataTable;
    public function CReturnDiamondSystem() {
        super();
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.DIAMOND_ROULETTE );
    }

    public override function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;
        if ( !_bIsInitialize ) {
            _bIsInitialize = true;
            this.addBean( new CRDControl() );
            this.addBean( new CRDNetDataManager());
            this.addBean( new CReturnDiamondHandler());
            this.addBean( _rdViewHandler=new CReturnDiamondViewHandler());
            _activityTable = (stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ACTIVITY);
            this._initialize();
        }
        return _bIsInitialize;
    }
    private var _bActivityIsOpen:Boolean = false;
    override protected function onBundleStart(pCtx : ISystemBundleContext):void{
        if(_bActivityIsOpen)return;
        setActivated(false);
        this.ctx.stopBundle(this);
    }

    private function _initialize() : void {
        _rdViewHandler.closeHandler = _closeHandler;
        stage.getSystem(CActivityHallSystem).addEventListener(CActivityHallEvent.ActivityStateChanged, _onActivityStateRespone);
    }

    private function _onActivityStateRespone(event:CActivityHallEvent):void{
        var response:ActivityChangeResponse = event.data as ActivityChangeResponse;
        if(!response) return;
        var activityType:int = getActivityType(response.activityID);
        if(activityType == CActivityHallActivityType.ROULETTE)
        {
            //1准备中2进行中3已完成4已结束5已关闭/
            if(response.state >= ELimitActivityState.ACTIVITY_STATE_PREPARE && response.state <= ELimitActivityState.ACTIVITY_STATE_END){
                _bActivityIsOpen = true;
                _endTime = response.params.endTick;
                _startTime = response.params.startTick;
//                this.ctx.startBundle(this);

                if((stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(KOFSysTags.ACTIVITY_TREASURE))
                {
                    return;
                }

                var pValidators : CSwitchingValidatorSeq = getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
                if ( pValidators )
                {
                    if ( pValidators.evaluate() )// 验证所有开启条件是否已达成
                    {
                        var vResult : Vector.<String> = pValidators.listResultAsTags();
                        if ( vResult && vResult.length )
                        {
                            if(vResult.indexOf(KOFSysTags.ACTIVITY_TREASURE) != -1)
                            {
                                var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
                                if ( pSystemBundleContext ) {
                                    pSystemBundleContext.startBundle( this as ISystemBundle );
                                }
                            }
                        }
                    }
                }

            }else if(response.state == ELimitActivityState.ACTIVITY_STATE_CLOSE){
                _bActivityIsOpen = false;
                setActivated(false);
                this.ctx.stopBundle(this);
            }
        }
    }

    public function closeSystem():void{
        setActivated(false);
        this.ctx.stopBundle(this);
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );
        if ( value ) {
            _rdViewHandler.show();
        }
        else {
            _rdViewHandler.close();
        }
    }

    //获取对应次数的返钻配置
    public function getDiamondRouletteConfig(count:int):DiamondRouletteConfig{
        var rdTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = this.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        rdTable = pDatabaseSystem.getTable( KOFTableConstants.DIAMOND_ROULETTE_CONFIG ) as CDataTable;
        var config:DiamondRouletteConfig = rdTable.findByPrimaryKey(count) as DiamondRouletteConfig;
        if(!config){
            var arr:Array = rdTable.toArray();
            var len:int= arr.length;
            config = arr[len-1]
        }
        return config;
    }
    //获取返钻常量配置
    public function getDiamondRouletteConst():DiamondRouletteConst{
        var rdTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = this.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        rdTable = pDatabaseSystem.getTable( KOFTableConstants.DIAMOND_ROULETTE_CONST ) as CDataTable;
        return rdTable.findByPrimaryKey(1) as DiamondRouletteConst;
    }

    public function _closeHandler():void{
        setActivated(false);
    }
    public function getActivityType(activityId:int):int
    {
        var activityConfig:Activity = _activityTable.findByPrimaryKey(activityId);
        if(activityConfig)
        {
            return activityConfig.type;
        }
        else
        {
            return 0;
        }
    }
    public function get time():Number{
        _time = _endTime-CTime.getCurrServerTimestamp();
        return _time;
    }
}
}
