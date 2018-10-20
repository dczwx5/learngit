//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/26
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import QFLib.Foundation.CMap;
import QFLib.Utils.HtmlUtil;
import QFLib.Utils.PathUtil;

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.effort.CEffortEvent;
import kof.game.effort.CEffortHallHandler;
import kof.game.effort.data.CEffortConst;
import kof.game.effort.data.CEffortTypeRewardData;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.table.EffortTypeRewardConfig;
import kof.table.HangUpSkillVideo;
import kof.ui.master.effortHall.EffortCategorizationUI;
import kof.ui.master.effortHall.EffortRewardItemUI;
import kof.ui.master.effortHall.EffortTotalRewardUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
 * 成就系统--累计奖励
 * @author Leo.Li
 * @date 2018/5/26
 */
public class CEffortTotalRewardViewHandler extends CTweenViewHandler {

    private var _m_pViewUI : EffortTotalRewardUI;

    private var _m_pTypeRewardTable : IDataTable;

    private var _m_iType : int;

    private var _m_aCfgs : Array;

    private var _m_pHallHandler:CEffortHallHandler;


    public function CEffortTotalRewardViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_m_pViewUI ) {

            _m_pViewUI = new EffortTotalRewardUI();
            var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
            _m_pTypeRewardTable = pDatabase.getTable( KOFTableConstants.EFFORT_TYPEREWARD_CONFIG );
            _m_pHallHandler = system.getBean(CEffortHallHandler);
            _m_pViewUI.list_reward.renderHandler = new Handler( _onListRewardRender );
        }

        return _m_pViewUI;
    }

    public function addDisplay( type : int ) : void {

        _m_iType = type;
        this.loadAssetsByView( viewClass, _showDisplay );
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

    public function removeDisplay() : void {
        if ( _m_pViewUI ) {
            _m_pViewUI.remove();
            _removeEventListeners();
//            clearInterval( _showEffID );
        }
    }

    override public function get viewClass() : Array {
        return [ EffortTotalRewardUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    protected function _initView() : void {
        var tempArray : Array = _m_pTypeRewardTable.toArray();
        _m_aCfgs = [];
        var typeRewardData:CEffortTypeRewardData;
        for each( var cfg : EffortTypeRewardConfig in tempArray ) {
            if ( cfg.type == _m_iType ) {
                typeRewardData = new CEffortTypeRewardData();
                typeRewardData.ID = cfg.ID;
                typeRewardData.needPointNum = cfg.needPointNum;
                typeRewardData.dropId = cfg.dropId;
                typeRewardData.obtained = _m_pHallHandler.m_aTypeObtainedIds.indexOf(cfg.ID) > -1;
                typeRewardData.image = cfg.image;
                _m_aCfgs.push( typeRewardData );
            }
        }
        _m_aCfgs.sortOn( ["obtained","ID"] ,[Array.NUMERIC,Array.NUMERIC]);
        _m_pViewUI.list_reward.dataSource = _m_aCfgs;

        _m_pViewUI.list_reward.scrollTo( 0 );

    }


    private function _onListRewardRender( item : Component, index : int ) : void {
        var renderItem : EffortRewardItemUI = item as EffortRewardItemUI;
        var renderData : CEffortTypeRewardData = renderItem.dataSource as CEffortTypeRewardData;
        if ( renderItem && renderData ) {
            renderItem.txt_type.text = CEffortConst.getLangByType(_m_iType);
            var current:int = _m_pHallHandler.m_pType_cur_point.find(_m_iType);
            var max:int = _m_pTypeRewardTable.findByPrimaryKey( renderData.ID ).needPointNum;
            if(current >= max)
            {
                ObjectUtils.gray(renderItem.ok_btn, false);
                renderItem.ok_btn.disabled = false;
            }
            else
            {
                ObjectUtils.gray(renderItem.ok_btn, true);
                renderItem.ok_btn.disabled = true;
            }
            if(_obtainedTypeReward(renderData.ID))
            {
                renderItem.ok_btn.visible = false;
                renderItem.has_get_img.visible = true;
            }
            else
            {
                renderItem.ok_btn.visible = true;
                renderItem.has_get_img.visible = false;
            }
            renderItem.ok_btn.clickHandler = new Handler( _obtainBtnHandler, [ renderData.ID ] );
            if ( current >= max ) {
                renderItem.effort_point_txt.text = "[" + HtmlUtil.getHtmlText( current.toString(), "#fff66e", renderItem.effort_point_txt.size as int,
                                renderItem.effort_point_txt.font,
                                renderItem.effort_point_txt.bold ) + "/" + max + "]";
            }
            else {
                renderItem.effort_point_txt.text = "[" + current + "/" + max + "]";
            }
            renderItem.effort_title_img.url = _getUIPath(renderData.image);
            renderItem.effort_title_img.y = renderData.image == "img_mrcz1" ? 24 : 21;
            renderItem.list_reward_item.left_btn.visible = false;
            renderItem.list_reward_item.right_btn.visible = false;
            renderItem.list_reward_item.item_list.renderHandler = new Handler( CItemUtil.getItemRenderFunc( system ) );
            var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( (uiCanvas as CAppSystem).stage,
                    _m_pTypeRewardTable.findByPrimaryKey( renderData.ID ).dropId );
            var dataList : Array = rewardListData.list;
            renderItem.list_reward_item.item_list.dataSource = dataList;
        }
    }

    protected function _addEventListeners() : void {
        system.addEventListener(CEffortEvent.TYPE_ACHIEVE_REWARD,_typeRewardObtainHandler);
    }

    protected function _removeEventListeners() : void {
        system.removeEventListener(CEffortEvent.TYPE_ACHIEVE_REWARD,_typeRewardObtainHandler);
    }

    protected function _obtainedTypeReward(typeId:int):Boolean
    {
        for each(var id:int in _m_pHallHandler.m_aTypeObtainedIds)
        {
            if(id == typeId)
            {
                return true;
            }
        }
        return false;
    }

    private function _obtainBtnHandler(typeRewardId:int):void
    {
        _m_pHallHandler.typeRewardRequest(typeRewardId);
    }



    protected function _typeRewardObtainHandler(evt:CEffortEvent):void
    {
        var typeId:int = evt.data as int;
        var index:int = _getCellIndexByConfigId(typeId);
        //var cell:Component = _m_pViewUI.list_reward.getCell(index);
        //_onListRewardRender(cell,index);


        for each(var typeData:CEffortTypeRewardData in _m_aCfgs)
        {
            if(typeData.ID == typeId)
            {
                typeData.obtained = true;
            }
        }
        _m_aCfgs.sortOn( ["obtained","ID"] ,[Array.NUMERIC,Array.NUMERIC]);
        _m_pViewUI.list_reward.dataSource = _m_aCfgs;

        var rewardListData : CRewardListData = CRewardUtil.createByDropPackageID( (uiCanvas as CAppSystem).stage,
                _m_pTypeRewardTable.findByPrimaryKey( typeId ).dropId );
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
    }

    private function _getCellIndexByConfigId(id:int):int
    {
        for(var i:int = 0; i < _m_aCfgs.length; i ++)
        {
            if((_m_aCfgs[i] as CEffortTypeRewardData).ID == id)
            {
                return i;
            }
        }
        return 0;
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
