//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import QFLib.Graphics.FX.effectsystem.EffectSystem;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;

import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.fight.skillchain.ITriggleSkillMechanism;
import kof.game.common.CSystemRuleUtil;
import kof.game.effort.CEffortHallHandler;
import kof.game.effort.CEffortSystem;
import kof.game.effort.data.CEffortConfigOrderData;
import kof.game.effort.data.CEffortConst;
import kof.game.effort.data.CEffortTargetData;
import kof.game.arena.CArenaSystem;
import kof.game.arena.view.CArenaRoleEmbattleTipsView;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CLang;
import kof.game.fightui.compoment.Sector;
import kof.table.EffortConfig;
import kof.table.EffortStageConfig;
import kof.table.EffortTargetConfig;
import kof.table.EffortTypeRewardConfig;
import kof.table.PassiveSkillPro;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.effortHall.EffortCategorizationUI;
import kof.ui.master.effortHall.EffortCircleUI;
import kof.ui.master.effortHall.EffortDetailItemUI;
import kof.ui.master.effortHall.EffortHallUI;
import kof.ui.master.effortHall.EffortOverviewUI;
import kof.ui.master.welfareHall.RechargeWelfareUI;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Component;

import morn.core.handlers.Handler;

/**
 * 成就系统综述
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortOverviewHandler extends CEffortPanelBase {

    private var _m_pOverviewUI : EffortOverviewUI;

    private var _m_pCurrentProperties:CBasePropertyData;
    private var _m_iCurrentPropertyNum:int;
    private var _m_pNextProperties:CBasePropertyData;
    private var _m_iNextPropertyNum:int;

    public function CEffortOverviewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected override function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }


    protected override function _addToDisplay() : void {
        if ( _m_pOverviewUI ) {
            hallUI.ctn.addChild( _m_pOverviewUI );
        }
        _addEventListeners();
        _initView();
    }

    public override function removeDisplay() : void {
        if ( _m_pOverviewUI ) {
            _m_pOverviewUI.remove();
            _removeEventListeners();
//            clearInterval( _showEffID );
        }
    }


    override protected function onInitializeView() : Boolean {
        _m_bInitBaseView = false;
        if ( !super.onInitializeView() )
            return false;

        if ( !_m_pOverviewUI ) {

            _m_pOverviewUI = new EffortOverviewUI();

//            _m_pOverviewUI.list_show.repeatX = 4;

            _m_pOverviewUI.btn_tips.toolTip = new Handler(showTips,[_m_pOverviewUI.btn_tips]);
            _m_pOverviewUI.btn_tips.addEventListener(MouseEvent.CLICK, _tipBtnClickHandler);

            _m_pOverviewUI.btn_title_system.clickHandler = new Handler(_openTitleSystemHandler);
            _m_pOverviewUI.list_show.renderHandler = new Handler(_onRecentItemRender);

            var rateNum : int = _m_pOverviewUI.list_accomplish_rate.cells.length;
            for ( var i : int = 0; i < rateNum; i++ ) {
                //那个半缓的起始角度30终止角度  330，总角度300，综合起始角度 120
                var rateItem : EffortCircleUI = _m_pOverviewUI.list_accomplish_rate.getCell( i ) as EffortCircleUI;
                if ( rateItem ) {
                    rateItem.mouseChildren = true;
                    rateItem.mouseEnabled = true;
                    //rateItem.addEventListener( MouseEvent.CLICK, clickHandler );
                    var sector : Sector = new Sector();
                    sector.name = 'sector';
                    sector.visible = false;
                    sector.alpha = 0.7;
                    sector.x = 57;
                    sector.y = 57;
                    rateItem.addChildAt( sector, rateItem.getChildIndex( rateItem.img_circle ) );
                    rateItem.img_circle.mask = sector;
                    sector.init( 0, 0, 60, 120, 40, 0.5 );
                }
            }
        }

        return _m_pOverviewUI;
    }

    private function _initView() : void {

        var currentAllEffort:int = sumAllCurrentEffort();
        var nextStageCfg:EffortStageConfig = curMaxStageEffort(currentAllEffort);
        var maxPoint:int = nextStageCfg.needPointNum;

        var tempList:Array;

        tempList = _getProperties(nextStageCfg);
        _m_pNextProperties = tempList[0];
        _m_iNextPropertyNum = tempList[1];

        var currentStage:int = nextStageCfg.ID - 1;
        var currentStageCfg:EffortStageConfig = _m_pStageTable.findByPrimaryKey(currentStage);
        if(currentStageCfg)
        {
            tempList = _getProperties(currentStageCfg);
            _m_pCurrentProperties = tempList[0];
            _m_iCurrentPropertyNum = tempList[1];
        }
        else
        {
            _m_pCurrentProperties = _m_pNextProperties;
            _m_iCurrentPropertyNum = _m_iNextPropertyNum;
        }

        var rateNum : int = _m_pOverviewUI.list_accomplish_rate.cells.length;
        for(var i:int = 1; i <= rateNum; i++)
        {
            updateRateByType(i,sumCurTypeEffort(i),_m_pHallHandler.m_pType_sum_point.find(i));
        }

//        var cellNum:int = _m_pOverviewUI.list_show.cells.length;
//        for(i = 0; i < cellNum; i ++)
//        {
//            var recentItem:EffortDetailItemUI = _m_pOverviewUI.list_show.getCell(i) as EffortDetailItemUI;
//            recentItem.dataSource = _m_pHallHandler.m_aLastObtainIds.length > i ? _m_pHallHandler.m_aLastObtainIds[_m_pHallHandler.m_aLastObtainIds.length - 1 - i]:0;
//            _onRecentItemRender(recentItem,i);
//        }

        var dataArr:Array = [];
        for(i = _m_pHallHandler.m_aLastObtainIds.length-1; i >= 0; i--)
        {
            dataArr.push(_m_pHallHandler.m_aLastObtainIds[i]);
            if(dataArr.length >= 4)
            {
                break;
            }
        }

        if(dataArr.length < 4)
        {
            for(i = dataArr.length; i < 4; i++)
            {
                dataArr.push(0);
            }
        }

//        if((dataArr.length % 4) != 0)
//        {
//            var num:int = 4 - int(dataArr.length % 4);
//            for(i = 0; i < num; i++)
//            {
//                dataArr.push(0);
//            }
//        }

        _m_pOverviewUI.list_show.dataSource = dataArr;

        _m_pOverviewUI.bar_stage.value = currentAllEffort / maxPoint;
        _m_pOverviewUI.txt_bar_label.text = currentAllEffort + "/" + maxPoint;
        _m_pOverviewUI.txt_all_effort.text = sumAllCurrentEffort().toString();
        _m_pOverviewUI.txt_power.num = _m_pCurrentProperties.getBattleValue();

        var strStageIndex:String = "common_number_china_" + currentStageCfg.stage;
        var stagetName:String = CLang.Get(CEffortConst.EFFORT_STAGE_LABEL, {v1:CLang.Get(strStageIndex)});
        _m_pOverviewUI.txt_stage_label.text = stagetName;
        _m_pOverviewUI.bar_stage.value = currentAllEffort/maxPoint;
        _m_pOverviewUI.mc_bar_end.x = -53 + _m_pOverviewUI.bar_stage.width * _m_pOverviewUI.bar_stage.value;
    }
//
//    private var _m_iTestNum : int = 0;
//
//    private function clickHandler( e : MouseEvent ) : void {
//        var rateItem : EffortCircleUI = e.currentTarget as EffortCircleUI;
//        if ( rateItem ) {
//            _m_iTestNum = _m_iTestNum + 2;
//            if ( _m_iTestNum > 360 ) {
//                _m_iTestNum = 0;
//            }
//            trace( "mitestNumn:" + _m_iTestNum );
//            updateRateByType( 1, _m_iTestNum, 360 );
//        }
//    }


    private function updateRateByType( type : int, current : int, total : int ) : void {
        var rateItem : EffortCircleUI = _m_pOverviewUI.list_accomplish_rate.getCell( type - 1 ) as EffortCircleUI;
        if ( current > total ) current = total;
        if ( rateItem ) {
            rateItem.txt_point_current.text = current.toString();
            rateItem.txt_point_max.text = total.toString();
            rateItem.txt_desc.text = CLang.Get(CEffortConst.TYPE_CONST_LIST[type - 1]);
            var sector : Sector = rateItem.getChildByName( "sector" ) as Sector;
            if ( sector ) {
                sector.reDraw( 60, 120, current / total * 304 );
            }
        }
    }

    public function sumAllEffort() : int {
        var sum : int = 0;
        for each( var cfg : EffortConfig in _m_pConfigTable.toArray() ) {
            for each( var targetId : int in cfg.effortTargetId ) {
                var targetCfg : EffortTargetConfig = _m_pTargetTable.findByPrimaryKey( targetId );
                sum += targetCfg.effortPointNum;
            }
        }
        return sum
    }

    public function sumAllCurrentEffort():int
    {
        var sum:int = 0;
        for each(var data:CEffortTargetData in  _m_pHallHandler.m_aTarget_config_obtained)
        {
            if(data.obtainTick > 0)
            {
                sum += (_m_pTargetTable.findByPrimaryKey(data.targetConfigId) as EffortTargetConfig).effortPointNum;
            }
        }
        return sum;
    }

    public function curMaxStageEffort(current:int):EffortStageConfig
    {
        var array:Array = _m_pStageTable.toArray();
        for each(var typeCfg:EffortStageConfig in array)
        {
            if(typeCfg.needPointNum > current)
            {
                return typeCfg;
            }
        }
        return array[array.length - 1];
    }


    override public function get viewClass() : Array {
        return [ EffortOverviewUI ];
    }

    protected override function _addEventListeners():void
    {
    }
    protected override function _removeEventListeners():void
    {
    }

    protected function _tipBtnClickHandler(evt:MouseEvent):void
    {
        showTips(_m_pOverviewUI.btn_tips);
    }

    public function showTips(item:Button):void
    {
        (system as CEffortSystem).addTips(CEffortTipViewHandler,item,[_m_pCurrentProperties,
            _m_iCurrentPropertyNum,_m_pNextProperties,_m_iNextPropertyNum]);
    }

    private function _getProperties(cfg:EffortStageConfig):Array
    {
        var propertyData:CBasePropertyData = new CBasePropertyData();
        propertyData = new CBasePropertyData();
        propertyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        var protertyStr:String = cfg.properties.replace("[","");
        protertyStr = protertyStr.replace("]","");
        var attInfoStrList:Array = protertyStr.split(";");
        for(var j:int = 0; j < attInfoStrList.length; j++)
        {
            var attInfoList:Array = attInfoStrList[j].split(":");
            var attrType:int = int(attInfoList[0]);
            var attrValue:int = int(attInfoList[1]);
            var attrNameEN:String = propertyData.getAttrNameEN(attrType);
            propertyData[attrNameEN] += attrValue;
        }
        return [propertyData,attInfoStrList.length];
    }

    private function _onRecentItemRender( item : EffortDetailItemUI, index : int ) : void {
        item.reward_btn.visible = false;
        item.txt_not_achieve.visible = false;
        item.visible = true;

        if ( item.dataSource ==null|| item.dataSource == 0 ) {
            item.imgMask.visible = true;
            //item.imgMask.alpha = .4;
            item.box_bottom.visible = false;
            item.box_bar.visible = false;
            item.box_icon.visible = false;
            item.name_txt.visible = false;
            item.box_recent_labels.visible = true;
            item.mc_bg.index = 3;
            item.mc_bg.alpha = .5;
            item.box_bg.alpha = .5
        }
        else {
            item.imgMask.visible = false;
            item.mc_bg.alpha = 1;
            item.box_bottom.visible = true;
            item.box_bar.visible = true;
            item.box_icon.visible = true;
            item.name_txt.visible = true;
            item.box_recent_labels.visible = true;

            var targetConfigId:int = item.dataSource as int;
            var configData:EffortConfig = _m_pHallHandler.getConfigByTargetConfigId(targetConfigId);
            var targetIdIndex:int = configData.effortTargetId.indexOf(targetConfigId);
            var currentTargetData:CEffortTargetData = _m_pHallHandler.currentTargetData(targetConfigId);


            item.mc_star0.index = targetIdIndex >= 0 ? 0 : 1;
            item.mc_star1.index = targetIdIndex >= 1 ? 0 : 1;
            item.mc_star2.index = targetIdIndex >= 2 ? 0 : 1;
            item.mc_bg.index = targetIdIndex;
//
            item.img_icon.url = _getUIPath(configData.image);
            item.box_recent_labels.visible = false;
            item.reward_time_txt.text = currentTargetData.achievementTimeStr;
//            item.progress_txt.text = currentTargetData.max + "/" + currentTargetData.max;
            item.txt_currValue.text = currentTargetData.max.toString();
            item.txt_totalValue.text = currentTargetData.max.toString();
            item.progress_bar.value = 1;
            item.name_txt.text = configData.name;

        }

        if(item.mc_bg.index == 2)
        {
            item.frameClip_effect.visible = true;
            item.frameClip_effect.autoPlay = true;
        }
        else
        {
            item.frameClip_effect.stop();
            item.frameClip_effect.autoPlay = false;
            item.frameClip_effect.visible = false;
        }
    }

    private function _openTitleSystemHandler():void
    {
        //(system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert("【系统暂未开放，敬请期待】");

        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.TITLE));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

}
}
