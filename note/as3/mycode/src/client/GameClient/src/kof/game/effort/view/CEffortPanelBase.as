//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import QFLib.Utils.HtmlUtil;
import QFLib.Utils.PathUtil;

import flash.events.MouseEvent;
import flash.system.System;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.effort.CEffortEvent;
import kof.game.effort.CEffortHallHandler;
import kof.game.effort.data.CEffortConfigOrderData;
import kof.game.effort.data.CEffortConst;
import kof.game.effort.data.CEffortConst;
import kof.game.effort.data.CEffortTargetData;
import kof.game.effort.data.CEffortTargetData;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.openServerActivity.event.COpenServerActivityEvent;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.CPlayerMainViewHandler;
import kof.table.EffortConfig;
import kof.table.EffortConfig;
import kof.table.EffortTargetConfig;
import kof.table.EffortTargetConfig;
import kof.table.EffortTypeRewardConfig;
import kof.ui.master.effortHall.EffortCategorizationUI;
import kof.ui.master.effortHall.EffortDetailItemUI;
import kof.ui.master.effortHall.EffortDetailsUI;
import kof.ui.master.effortHall.EffortHallUI;
import kof.ui.master.effortHall.EffortOverviewUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
 * 成就系统面板handler基类
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortPanelBase extends CViewHandler {

    protected var _m_pViewUI : EffortCategorizationUI;

    private var _m_aCacheCategorizes:Array;

    protected var _m_pHallHandler:CEffortHallHandler;

    protected var _m_pTargetTable:IDataTable;

    protected var _m_pConfigTable:IDataTable;
    protected var _m_pTypeRewardTable:IDataTable;
    protected var _m_pStageTable:IDataTable;

    protected  var _m_pCurTypeRewardCfg:EffortTypeRewardConfig;

    protected var _m_bInitBaseView:Boolean = true;

    public function CEffortPanelBase( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function dispose() : void
    {
        super.dispose();
        _m_pViewUI = null;
        _m_aCacheCategorizes = null;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    protected function _addToDisplay() : void
    {
        if(_m_pViewUI)
        {
            hallUI.ctn.addChild(_m_pViewUI);
        }

        _addEventListeners();

        _initView();
    }

    public function removeDisplay() : void {
        if ( _m_pViewUI ) {
            var effortTotalView:CEffortTotalRewardViewHandler = system.getHandler(CEffortTotalRewardViewHandler) as CEffortTotalRewardViewHandler;
            if(effortTotalView.isViewShow) {
                effortTotalView.removeDisplay();
            }
            var effortDetailsView:CEffortDetailsViewHandler = system.getHandler(CEffortDetailsViewHandler) as CEffortDetailsViewHandler;
            if(effortDetailsView.isViewShow)
            {
                effortDetailsView.removeDisplay();
            }
            _m_pViewUI.remove();
            _removeEventListeners();
//            clearInterval( _showEffID );
        }
    }

    override public function get viewClass() : Array {
        return [ EffortCategorizationUI ];
    }

    override protected function get additionalAssets():Array
    {
        return ["frameclip_achieve.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        _m_pHallHandler = hallHander;
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        _m_pTargetTable = pDatabase.getTable(KOFTableConstants.EFFORT_TARGET_CONFIG);
        _m_pConfigTable = pDatabase.getTable(KOFTableConstants.EFFORT_CONFIG);
        _m_pTypeRewardTable = pDatabase.getTable(KOFTableConstants.EFFORT_TYPEREWARD_CONFIG);
        _m_pStageTable = pDatabase.getTable(KOFTableConstants.EFFORT_STAGE_CONFIG);

        if (_m_bInitBaseView&& !_m_pViewUI ) {
            _m_pViewUI = new EffortCategorizationUI();
            _m_pViewUI.btn_reward.clickHandler = new Handler(_onTypeRewardBtnHandler);
            _m_pViewUI.btn_preview.clickHandler = new Handler(_rewardPreview);
            _m_pViewUI.panel.vScrollBar.target = _m_pViewUI.panel;
            _m_pViewUI.panel.vScrollBar.value = 0;
            _m_pViewUI.panel.vScrollBar.autoHide = false;
            _m_pViewUI.panel.vScrollBar.mouseEnabled = true;
            _m_pViewUI.panel.vScrollBar.mouseChildren = true;
            _m_pViewUI.effort_target_list.renderHandler = new Handler(_onItemRender);

            var currentRepeatY:int = (_categorizeList.length - 1) / _m_pViewUI.effort_target_list.repeatX + 1;

            _m_pViewUI.effort_target_list.repeatY = currentRepeatY;

            _m_pViewUI.list_reward.item_list.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            _m_pViewUI.list_reward.left_btn.visible = false;
            _m_pViewUI.list_reward.right_btn.visible = false;

        }

        return true;
    }

    protected function _initView():void {

        _updateTypeRewardShow();

//        _categorizeList.sortOn(["canObtained","lastObtainedTick","ID"],[Array.NUMERIC|Array.DESCENDING,Array.NUMERIC|Array.DESCENDING,Array.NUMERIC]);
        _m_pViewUI.effort_target_list.dataSource = _categorizeList;

        //_m_pHallHandler.m_pType_cur_point.find(_categorizeType);

        _m_pViewUI.panel.vScrollBar.value = 0;
        _m_pViewUI.panel.refresh();

    }

    protected function get _categorizeList():Array
    {
        if(_m_aCacheCategorizes == null)
        {
            _m_aCacheCategorizes = [];
            var orderData:CEffortConfigOrderData;
            var tempArray:Array = _m_pConfigTable.toArray();
            for each(var item:EffortConfig in tempArray)
            {
                if(item.type == _categorizeType)
                {
                    orderData = new CEffortConfigOrderData();
                    orderData.ID = item.ID;
                    orderData.image = item.image;
                    orderData.effortTargetId = item.effortTargetId;
                    orderData.name = item.name;
                    orderData.type = item.type;
                    orderData.lastObtainedTick = -1;
                    orderData.canObtained = _canObtained(item.ID);
                    for each(var targetId:int in item.effortTargetId)
                    {
                        var targetCurData:CEffortTargetData = _m_pHallHandler.currentTargetData(targetId);
                        orderData.lastObtainedTick = orderData.lastObtainedTick > targetCurData.obtainTick ? orderData.lastObtainedTick:targetCurData.obtainTick;
                    }
                    _m_aCacheCategorizes.push(orderData);
                }
            }
        }

        _m_aCacheCategorizes.sort(_sortByCanTake);

        return _m_aCacheCategorizes;
    }

    private function _sortByCanTake(item1:CEffortConfigOrderData, item2:CEffortConfigOrderData):int
    {
        if(item1.canObtained)
        {
            return -1;
        }
        else if(item2.canObtained)
        {
            return 1;
        }
        else
        {
            return _sortByHasTake(item1, item2);
        }
    }

    private function _sortByHasTake(item1:CEffortConfigOrderData, item2:CEffortConfigOrderData):int
    {
        var targetCfg:EffortTargetConfig = _getTargetConfig(item1);
        var currentTargetData:CEffortTargetData = _m_pHallHandler.currentTargetData(targetCfg.ID);

        var targetCfg2:EffortTargetConfig = _getTargetConfig(item2);
        var currentTargetData2:CEffortTargetData = _m_pHallHandler.currentTargetData(targetCfg2.ID);

        if(currentTargetData.isComplete)
        {
            return -1;
        }
        else if(currentTargetData2.isComplete)
        {
            return 1;
        }
        else
        {
            return _sortByObtain(item1, item2);
        }
    }

    private function _sortByObtain(a:CEffortConfigOrderData, b:CEffortConfigOrderData):int
    {
        var targetCfg:EffortTargetConfig = _getTargetConfig(a);
        var currentTargetData:CEffortTargetData = _m_pHallHandler.currentTargetData(targetCfg.ID);

        var targetCfg2:EffortTargetConfig = _getTargetConfig(b);
        var currentTargetData2:CEffortTargetData = _m_pHallHandler.currentTargetData(targetCfg2.ID);

        if(_isObtained(currentTargetData, a))
        {
            return -1;
        }
        else if(_isObtained(currentTargetData2, b))
        {
            return 1;
        }
        else
        {
            return currentTargetData2.current - currentTargetData.current;
        }
    }
    
    private function _sortById(a:CEffortConfigOrderData, b:CEffortConfigOrderData):int
    {
        return a.ID - b.ID;
    }

    protected function _addEventListeners():void
    {
        system.addEventListener(CEffortEvent.TYPE_ACHIEVE_REWARD,_typeRewardObtainHandler);
        system.addEventListener(CEffortEvent.TARGET_POINT_CHANGE,_targetPointChangeHandler);
        system.addEventListener(CEffortEvent.ACHIEVE_EFFORT ,_obtainEffortHandler );
    }
    protected function _removeEventListeners():void
    {
        system.removeEventListener(CEffortEvent.TYPE_ACHIEVE_REWARD,_typeRewardObtainHandler);
        system.removeEventListener(CEffortEvent.TARGET_POINT_CHANGE,_targetPointChangeHandler);
        system.removeEventListener(CEffortEvent.ACHIEVE_EFFORT ,_obtainEffortHandler );
    }

    protected function get hallUI():EffortHallUI
    {
        return (system.getBean( CEffortHallViewHandler ) as CEffortHallViewHandler).hallUI;
    }

    protected function get hallHander():CEffortHallHandler
    {
        return (system.getBean(CEffortHallHandler) as CEffortHallHandler);
    }

    protected function _rewardPreview():void
    {
        var effortTotalView:CEffortTotalRewardViewHandler = system.getHandler(CEffortTotalRewardViewHandler) as CEffortTotalRewardViewHandler;
        if(effortTotalView.isViewShow)
        {
            effortTotalView.removeDisplay();
            effortTotalView.addDisplay(_categorizeType);
        }
        else
        {
            effortTotalView.addDisplay(_categorizeType);
        }
    }

    protected function get _categorizeType():int
    {
        return 0;
    }

    protected function _onItemRender( item:Component, index:int):void
    {
        if(!(item is EffortDetailItemUI))
        {
            return;
        }
        if(item.dataSource == null)
        {
            item.visible = false;
            return ;
        }

        item.visible = true;


        var render:EffortDetailItemUI = item as EffortDetailItemUI;
        render.box_recent_labels.visible = false;
        render.mouseChildren = render.mouseEnabled = true;
        var renderData:CEffortConfigOrderData = item.dataSource as CEffortConfigOrderData;
        if(renderData)
        {
            var targetCfg:EffortTargetConfig = _getTargetConfig(renderData);
            var currentTargetData:CEffortTargetData = _m_pHallHandler.currentTargetData(targetCfg.ID);
            var currentPoint:int = currentTargetData.current;
            var targetIdIndex:int = _calculateCurShowTargetCfg(renderData);
            var targetConfig:EffortTargetConfig = _m_pTargetTable.findByPrimaryKey(renderData.effortTargetId[targetIdIndex]);


            render.reward_btn.addEventListener(MouseEvent.CLICK, _onRewardBtnHandler);// = new Handler(_onRewardBtnHandler,[targetCfg.ID]);
            render.img_icon.url = _getUIPath(renderData.image);
            render.mouseEnabled = true;
            render.mouseChildren = true;
            render.addEventListener(MouseEvent.CLICK,_onItemClickHandler);
            render.name_txt.text = renderData.name;


            _updateBottomState(render,currentTargetData);

            var maxPoint:int =  _m_pHallHandler.currentTargetData(targetCfg.ID).max;
            render.progress_bar.value = currentPoint / maxPoint;
//            render.progress_txt.text = currentPoint+"/" + maxPoint;
            render.txt_currValue.text = currentPoint.toString();
            render.txt_totalValue.text = maxPoint.toString();

            if(currentTargetData.isComplete == false && targetIdIndex == 0)
            {
                render.imgMask.visible = true;
            }
            else
            {
                render.imgMask.visible = false;
            }

            _updateBgState(targetIdIndex,render,currentTargetData);

        }

        _m_pViewUI.panel.refresh();
    }

    protected function _updateBgState(targetIdIndex:int,render:EffortDetailItemUI,currentTargetData:CEffortTargetData):void
    {
        if(targetIdIndex == 0||targetIdIndex == 1)
        {
            render.mc_bg.index = 0;
        }
        else if(targetIdIndex == 2&&currentTargetData.obtainTick > 0)
        {
            render.mc_bg.index = 2;
        }
        else
        {
            render.mc_bg.index = 1;
        }

        if(render.mc_bg.index == 2)
        {
            render.frameClip_effect.visible = true;
            render.frameClip_effect.autoPlay = true;
        }
        else
        {
            render.frameClip_effect.autoPlay = false;
            render.frameClip_effect.visible = false;
        }

        for(var n:int = 0 ; n < 3; n ++)
        {
            if(targetIdIndex > n)
            {
                render["mc_star"+n].index = 0;
            }
            else if(targetIdIndex == n)
            {
                if(currentTargetData.obtainTick > 0)
                {
                    render["mc_star"+n].index = 0;
                }
                else
                {
                    render["mc_star"+n].index = 1;
                }
            }
            else
            {
                render["mc_star"+n].index = 1;
            }
        }
    }

    protected function _updateBottomState(render:EffortDetailItemUI,currentTargetData:CEffortTargetData):void
    {
        if(currentTargetData.obtainTick > 0)
        {
            render.reward_btn.visible = false;
            render.reward_time_txt.visible = true;
            render.txt_not_achieve.visible = false;
            render.reward_time_txt.text = currentTargetData.achievementTimeStr;
        }
        else
        {
            if(currentTargetData.isComplete)
            {
                render.reward_btn.visible = true;
                render.reward_time_txt.visible = false;
                render.txt_not_achieve.visible = false;
            }
            else
            {
                render.reward_btn.visible = false;
                if(currentTargetData.targetConfigId == render.dataSource.effortTargetId[0])
                {
                    render.txt_not_achieve.visible = true;
                    render.reward_time_txt.visible = false;
                }
                else
                {
                    render.txt_not_achieve.visible = false;
                    render.reward_time_txt.visible = true;
                    var prevData:EffortTargetConfig = _m_pTargetTable.findByPrimaryKey(currentTargetData.targetConfigId - 1);
                    render.reward_time_txt.text = _m_pHallHandler.currentTargetData(prevData.ID).achievementTimeStr;
                }
            }
        }
    }

    private function _isObtained(currentTargetData:CEffortTargetData, configOrderData:CEffortConfigOrderData):Boolean
    {
        if(currentTargetData.obtainTick > 0)
        {
            return true;
        }
        else
        {
            if(!currentTargetData.isComplete)
            {
                if(currentTargetData.targetConfigId != configOrderData.effortTargetId[0])
                {
                    return true;
                }
            }
        }

        return false;
    }

    protected function _onItemClickHandler(e:MouseEvent):void
    {
        var renderItem:EffortDetailItemUI = e.currentTarget as EffortDetailItemUI;
        if(renderItem)
        {
            var renderData:CEffortConfigOrderData = renderItem.dataSource as CEffortConfigOrderData;
            var effortDetailsView:CEffortDetailsViewHandler = system.getHandler(CEffortDetailsViewHandler) as CEffortDetailsViewHandler;
            if(effortDetailsView.isViewShow)
            {
                effortDetailsView.removeDisplay();
                effortDetailsView.addDisplay(renderData.ID);
            }
            else
            {
                effortDetailsView.addDisplay(renderData.ID);
            }
        }
    }

    protected function _onTypeRewardBtnHandler():void
    {
        _m_pHallHandler.typeRewardRequest(_m_pCurTypeRewardCfg.ID);
    }

    protected function _typeRewardObtainHandler(evt:CEffortEvent):void
    {
        var typeId:int = evt.data as int;
        _updateTypeRewardShow();
        var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( (uiCanvas as CAppSystem).stage,
                _m_pTypeRewardTable.findByPrimaryKey( typeId ).dropId );
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
    }

    protected function _targetPointChangeHandler(evt:CEffortEvent):void
    {
        var data:CEffortTargetData = evt.data as CEffortTargetData;
        var configData:EffortConfig = _m_pHallHandler.getConfigByTargetConfigId(data.targetConfigId);
        //var item:EffortDetailItemUI = _getCellByConfigId(configData.ID);

        for each(var orderData:CEffortConfigOrderData in _categorizeList)
        {
            if(orderData.ID == configData.ID)
            {
                orderData.canObtained = _canObtained(configData.ID);
                break ;
            }
        }
        _categorizeList.sortOn(["canObtained","lastObtainedTick","ID"],[Array.NUMERIC|Array.DESCENDING,Array.NUMERIC|Array.DESCENDING,Array.NUMERIC]);
        _m_pViewUI.effort_target_list.dataSource = _categorizeList;
//        if(item)
//        {
////            item.dataSource = configData;
//            _onItemRender(item,0);
//        }
    }
    protected function _obtainEffortHandler(evt:CEffortEvent):void
    {
        var data:CEffortTargetData = evt.data as CEffortTargetData;
        var configData:EffortConfig = _m_pHallHandler.getConfigByTargetConfigId(data.targetConfigId);
//        var item:EffortDetailItemUI = _getCellByConfigId(configData.ID);
//        if(item)
//        {
//            _onItemRender(item,0);
//        }

        for each(var orderData:CEffortConfigOrderData in _categorizeList)
        {
            if(orderData.ID == configData.ID)
            {
                orderData.lastObtainedTick = data.obtainTick;
                orderData.canObtained = _canObtained(configData.ID);
                break ;
            }
        }
        _categorizeList.sortOn(["canObtained","lastObtainedTick","ID"],[Array.NUMERIC|Array.DESCENDING,Array.NUMERIC|Array.DESCENDING,Array.NUMERIC]);
        _m_pViewUI.effort_target_list.dataSource = _categorizeList;
        _updateTypeRewardShow();
    }

    protected function _calculateCurShowTypeReward(currentPoint:int):EffortTypeRewardConfig
    {
        for each(var typeCfg:EffortTypeRewardConfig in _m_pTypeRewardTable.toArray())
        {
            if(typeCfg.type == _categorizeType)
            {
                if(_m_pHallHandler.m_aTypeObtainedIds.indexOf(typeCfg.ID) == -1&&currentPoint >= typeCfg.needPointNum)
                {
                    return typeCfg;
                }
                if(typeCfg.needPointNum > currentPoint)
                {
                    return typeCfg;
                }
            }
        }
        return null;
    }

    protected function _calculateCurShowTargetCfg(effortConfig:CEffortConfigOrderData):int
    {
        for(var i:int = 0; i < effortConfig.effortTargetId.length; i++)
        {
            if(_m_pHallHandler.currentTargetData(effortConfig.effortTargetId[i]).obtainTick <= 0)
            {
                return i;
            }
        }
        return effortConfig.effortTargetId.length - 1;
    }


    public function sumCurTypeEffort(type:int):int
    {
        var sum:int = 0;
        for each(var cfg:EffortConfig in _m_pConfigTable.toArray()) {
            if ( cfg.type == type ) {
                for each(var targetCfgId:int in  cfg.effortTargetId)
                {
                    for each(var data:CEffortTargetData in _m_pHallHandler.m_aTarget_config_obtained)
                    {
                        if(data.obtainTick > 0&&data.targetConfigId == targetCfgId)
                        {
                            sum += (_m_pTargetTable.findByPrimaryKey(data.targetConfigId) as EffortTargetConfig).effortPointNum;
                        }
                    }
                }
            }
        }
        _m_pHallHandler.m_pType_cur_point.add(type,sum,true);
        return sum;
    }

    protected function _updateTypeRewardShow():void
    {
        var currentPoint:int = sumCurTypeEffort(_categorizeType);
        var curTypeRewardCfg:EffortTypeRewardConfig = _calculateCurShowTypeReward(currentPoint);
        _m_pCurTypeRewardCfg = curTypeRewardCfg;
        if(curTypeRewardCfg)
        {
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage,
                    curTypeRewardCfg.dropId);
            var dataList:Array =  rewardListData.list;
            if(curTypeRewardCfg.needPointNum > currentPoint)
            {
                _m_pViewUI.btn_reward.disabled = true;
                ObjectUtils.gray(_m_pViewUI.btn_reward, true);
            }
            else
            {
                _m_pViewUI.btn_reward.disabled = false;
                ObjectUtils.gray(_m_pViewUI.btn_reward, false);
            }
            _m_pViewUI.txt_achieve_fixed_target.text = CLang.Get(CEffortConst.EFFORT_ACHIEVE_POINT,
                    {v1:HtmlUtil.getHtmlText(curTypeRewardCfg.needPointNum.toString(),"#fff66e",_m_pViewUI.txt_achieve_fixed_target.size as int,
                            _m_pViewUI.txt_achieve_fixed_target.font,
                            _m_pViewUI.txt_achieve_fixed_target.bold)});
            _m_pViewUI.list_reward.item_list.dataSource = dataList;
            if(_checkAllComplete() )
            {
                _m_pViewUI.img_all_complete.visible = true;//完成所有成就img
                _m_pViewUI.box_show_reward.visible = false;
            }
            else
            {
                _m_pViewUI.img_all_complete.visible = false;//完成所有成就img
                _m_pViewUI.box_show_reward.visible = true;
            }
        }
        else //null表示领完所有奖励
        {
            _m_pViewUI.img_all_complete.visible = true;//完成所有成就img
            _m_pViewUI.box_show_reward.visible = false;
        }
        _m_pViewUI.txt_current_effort.text = sumCurTypeEffort(_categorizeType).toString();
        _m_pViewUI.txt_type_desc.text = CEffortConst.getLangByTypeA(_categorizeType);
    }

    protected function _getTargetConfig(config:CEffortConfigOrderData):EffortTargetConfig
    {
        for each(var id:int in config.effortTargetId)
        {
            if(_m_pHallHandler.currentTargetData(id).obtainTick <= 0)
            {
                return _m_pTargetTable.findByPrimaryKey(id);
            }
        }
        return _m_pTargetTable.findByPrimaryKey(config.effortTargetId[config.effortTargetId.length - 1]);
    }

    protected function _getCellByConfigId(id:int):EffortDetailItemUI
    {
        for each(var item:EffortDetailItemUI in _m_pViewUI.effort_target_list.cells)
        {
            if((item.dataSource as CEffortConfigOrderData).ID == id)
            {
                return item;
            }
        }
        return null;
    }


    protected function _onRewardBtnHandler(evt:MouseEvent):void
    {
        var targetCfg:EffortTargetConfig = _getTargetConfig(evt.currentTarget.parent.dataSource);
        evt.stopImmediatePropagation();
        _m_pHallHandler.effortAchieveRequest(targetCfg.ID);
    }

    protected function _checkAllComplete():Boolean
    {
        for each(var typeRewardCfg:EffortTypeRewardConfig in _m_pTypeRewardTable.toArray())
        {
            if(typeRewardCfg.type == _categorizeType)
            {
                if(_m_pHallHandler.isTypeRewardObtained(typeRewardCfg.ID) == false)
                {
                    return false;
                }
            }
        }
        return true;
    }

    protected function _canObtained(configId:int):Boolean
    {
        var configData:EffortConfig = _m_pConfigTable.findByPrimaryKey(configId);
        if(configData)
        {
            for each(var targetId:int in configData.effortTargetId)
            {
               var targetCurData:CEffortTargetData = _m_pHallHandler.currentTargetData(targetId);
                if(targetCurData.isComplete&&targetCurData.obtainTick <= 0)
                {
                    return true;
                }
            }
        }
        return false;
    }

    protected function _getUIPath(name:String) : String {
        var url:String = "icon/effort/" + name + ".png";
//        var url:String = "icon/effort/00002.png";
        return PathUtil.getVUrl(url);
    }

}
}
