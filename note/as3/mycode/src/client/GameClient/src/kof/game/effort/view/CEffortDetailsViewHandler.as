//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/29
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import QFLib.Utils.PathUtil;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.effort.CEffortEvent;
import kof.game.effort.CEffortHallHandler;
import kof.game.effort.data.CEffortConst;
import kof.game.effort.data.CEffortTargetData;
import kof.game.common.CLang;
import kof.game.common.view.CTweenViewHandler;
import kof.table.EffortConfig;
import kof.table.EffortTargetConfig;
import kof.ui.master.effortHall.EffortDetailItemBUI;
import kof.ui.master.effortHall.EffortDetailsUI;
import kof.ui.master.effortHall.EffortTotalRewardUI;

/**
 * 成就系统-详情页面
 * @author Leo.Li
 * @date 2018/5/29
 */
public class CEffortDetailsViewHandler extends CTweenViewHandler {

    private var _m_pViewUI : EffortDetailsUI;

    private var _m_pTargetConfigTable : IDataTable;
    private var _m_pConfigTable : IDataTable;
    private var _m_iConfigId : int;
    private var _m_vTargetConfigs : Vector.<EffortTargetConfig>;
    private var _m_pHallHandler : CEffortHallHandler;

    public function CEffortDetailsViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_m_pViewUI ) {

            _m_pViewUI = new EffortDetailsUI();

            var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
            _m_pConfigTable = pDatabase.getTable( KOFTableConstants.EFFORT_CONFIG );
            _m_pTargetConfigTable = pDatabase.getTable( KOFTableConstants.EFFORT_TARGET_CONFIG );
        }

        return _m_pViewUI;
    }

    public function addDisplay( effortConfigId : int ) : void {
        _m_iConfigId = effortConfigId;
        _m_pHallHandler = system.getBean(CEffortHallHandler);
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    public function removeDisplay() : void {
        if ( _m_pViewUI ) {
            _m_pViewUI.remove();
            _removeEventListeners();
//            clearInterval( _showEffID );

            var config : EffortConfig = _m_pConfigTable.findByPrimaryKey( _m_iConfigId );
            for ( var i : int = 0; i < config.effortTargetId.length; i++ ) {
                var item : EffortDetailItemBUI = _m_pViewUI.getChildByName( "detail" + i ) as EffortDetailItemBUI;
                if(item){
                    item.frameClip_effect.stop();
                    item.frameClip_effect.autoPlay = false;
                    item.frameClip_effect.visible = false;
                }
            }
        }
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    protected function _addToDisplay() : void {

        showDialog( _m_pViewUI );

        _addEventListeners();

        _initView();
    }

    protected function _initView() : void {
        var config : EffortConfig = _m_pConfigTable.findByPrimaryKey( _m_iConfigId );
        _m_vTargetConfigs = new <EffortTargetConfig>[];
        _m_pViewUI.txt_detail_title.text = config.name;
        for ( var i : int = 0; i < config.effortTargetId.length; i++ ) {
            var cfg : EffortTargetConfig = _m_pTargetConfigTable.findByPrimaryKey( config.effortTargetId[ i ] );
            _m_vTargetConfigs.push( cfg );
            var item : EffortDetailItemBUI = _m_pViewUI.getChildByName( "detail" + i ) as EffortDetailItemBUI;
            item.txt_desc.text = cfg.desc;
            item.img_mask.visible = false;
            item.mc_star0.index = i >= 0 ? 0 : 1;
            item.mc_star1.index = i >= 1 ? 0 : 1;
            item.mc_star2.index = i >= 2 ? 0 : 1;
            item.img_icon.url = _getUIPath(config.image);
            item.txt_diamond.text = CLang.Get( CEffortConst.EFFORT_BINDDIAMOND ) + "：" + cfg.bindDiamond;
            item.txt_effort.text = CLang.Get( CEffortConst.EFFORT_POINT_LABEL ) + "：" + cfg.effortPointNum;
            var currentTargetData:CEffortTargetData = _m_pHallHandler.currentTargetData(cfg.ID);
            var currentPoint:int = currentTargetData.current;
            item.mc_bg.index = i;
            if(i == 2)
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

            item.txt_currValue.text = currentPoint.toString();
            item.txt_totalValue.text = currentTargetData.max.toString();

//            item.txt_point.text = currentPoint+"/"+currentTargetData.max;
            item.txt_time.text = currentTargetData.obtainTick > 0?currentTargetData.achievementTimeStr:CLang.Get(CEffortConst.EFFORT_NOT_ACHIEVEMENT_LABEL);
            item.img_mask.visible = currentTargetData.obtainTick <= 0;
            item.bar.value = currentPoint/currentTargetData.max;
        }
    }


    override public function get viewClass() : Array {
        return [ EffortDetailsUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    protected function _targetPointChangeHandler(evt:CEffortEvent):void
    {
        _initView();
    }

    protected function _addEventListeners() : void {
        system.addEventListener(CEffortEvent.TARGET_POINT_CHANGE,_targetPointChangeHandler);
    }

    protected function _removeEventListeners() : void {
        system.removeEventListener(CEffortEvent.TARGET_POINT_CHANGE,_targetPointChangeHandler);
    }

    public function get isViewShow() : Boolean {
        return _m_pViewUI && _m_pViewUI.parent;
    }

    private function _getUIPath(name:String) : String {
        var url:String = "icon/effort/" + name + ".png";
        return PathUtil.getVUrl(url);
    }
}
}
