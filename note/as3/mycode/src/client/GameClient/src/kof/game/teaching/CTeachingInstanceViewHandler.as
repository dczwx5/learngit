//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/1/29.
 */
package kof.game.teaching {

import QFLib.Utils.FilterUtil;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.CHeroListViewHandler;
import kof.table.Item;
import kof.table.TeachingContent;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.Teaching.TeachingItemUI;
import kof.ui.master.Teaching.TeachingMainUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CTeachingInstanceViewHandler extends CViewHandler {
    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:TeachingMainUI;
    public var getRewardItem:TeachingItemUI;
    public function CTeachingInstanceViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ TeachingMainUI,TeachingItemUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["teaching.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {

            if (!m_pViewUI) {
                m_pViewUI = new TeachingMainUI();
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.list_teaching.renderHandler = new Handler(itemRenderFunction);
                m_pViewUI.list_teaching.mouseHandler = new Handler(onClickListHandler);
                m_pViewUI.tab_teachingLevel.selectHandler = new Handler(onChangeTab);
                m_bViewInitialized = true;
                updateView();
            }
        }

        return m_bViewInitialized;
    }

    private function onClickListHandler( evt : MouseEvent, idx : int ) : void {
        if(evt.type == MouseEvent.CLICK){
            var item:TeachingItemUI = evt.currentTarget as TeachingItemUI;

            if (item == null) return ;
            var data:Object = item.dataSource;

            switch (evt.target.name)
            {
                case "btn_get":
                    getRewardItem = item;
                    (system.getHandler(CTeachingInstanceNetHandler) as CTeachingInstanceNetHandler).sendTeachingRewardRequest(data.ID);
                    break;
                case "btn_practice":
                    (system as CTeachingInstanceSystem).addEvent();
                    (system.getHandler(CTeachingInstanceNetHandler) as CTeachingInstanceNetHandler).sendTeachingChallengeRequest(data.ID);
                    break;
                case "btn_challenge":
                    (system as CTeachingInstanceSystem).addEvent();
                    (system.getHandler(CTeachingInstanceNetHandler) as CTeachingInstanceNetHandler).sendTeachingChallengeRequest(data.ID);
                    break;
            }
        }
    }

    private function itemRenderFunction(item:Component, idx:int):void{
        if(!(item is TeachingItemUI))return;
        var teachingItemUI:TeachingItemUI = (item as TeachingItemUI);
        var data:TeachingContent = teachingItemUI.dataSource as TeachingContent;
        if(data != null)
        {
            if( _manager.getTeachingDataByID( data.ID ) ){
                teachingItemUI.img_sign.visible = true;
                teachingItemUI.btn_get.visible = !_manager.getTeachingDataByID( data.ID ).isReward;
                teachingItemUI.btn_challenge.visible = false;
                teachingItemUI.btn_practice.visible = true;
                teachingItemUI.box_lock.visible = false;
            }
            else{
                teachingItemUI.img_sign.visible = false;
                teachingItemUI.btn_get.visible = false;
                teachingItemUI.btn_practice.visible = false;
                if(_manager.challengeBool(data.ID)){
                    teachingItemUI.btn_challenge.visible = true;
                    teachingItemUI.box_lock.visible = false;
                }else{
                    teachingItemUI.btn_challenge.visible = false;
                    teachingItemUI.box_lock.visible = true;
                    teachingItemUI.box_lock.toolTip = _manager.getToolTip(data);
                }
            }

            teachingItemUI.text_title.text = _manager.getTeachingInstanceDataByID(data.InstanceContentID).name;
            teachingItemUI.txt_desc.text = _manager.getTeachingInstanceDataByID(data.InstanceContentID).desc;

            var dataList:CRewardListData = CRewardUtil.createByList((uiCanvas as CAppSystem).stage, [getItemForItemID(data.ItemID)]);
            teachingItemUI.rewardItem.dataSource = dataList.itemList[0];
            _onRenderItem(teachingItemUI.rewardItem, data)
        }
    }

    private function _onRenderItem(box:Component, data:TeachingContent) : void {
        var item:RewardItemUI = box as RewardItemUI;
        if (item == null) return ;

        item.visible = true;
        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
        item.num_lable.visible = true;
        item.num_lable.text = data.Number.toString();
        item.icon_image.url = itemData.iconSmall;
        item.bg_clip.index = itemData.quality;
        item.toolTip = new Handler(_addTips, [item]);
        item.hasTakeImg.visible = false;
        item.box_eff.visible = itemData.effect;
        //==================add by Lune 0718=======================
        //已结领取过的奖励灰显
        var obj : Object = _manager.getTeachingDataByID( data.ID );
        if(obj && obj.isReward)
        {
            item.filters = FilterUtil.bAndWfilter;
            item.alpha = 0.7;
        }
        else
        {
            item.filters = [];
            item.alpha = 1;
        }
    }
    private function _addTips(item:Component) : void {
        var itemSystem:CItemSystem = (uiCanvas as CAppSystem).stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }

    public function updateView():void{
        var manager:CTeachingInstanceManager = (system.getHandler(CTeachingInstanceManager) as CTeachingInstanceManager);

        if(m_pViewUI){
            m_pViewUI.list_teaching.dataSource = manager.getTeachingType( m_pViewUI.tab_teachingLevel.selectedIndex+1 );

            m_pViewUI.tabRed1.visible = manager.showRedPoint(1);
            m_pViewUI.tabRed2.visible = manager.showRedPoint(2);
            var managerHeroList:CHeroListViewHandler = system.stage.getSystem( CPlayerSystem ).getHandler(CHeroListViewHandler) as CHeroListViewHandler;
            var bool:Boolean = manager.showRedPoint(1) || manager.showRedPoint(2);
            managerHeroList.showTeachingRedPoint(bool);
        }
    }

    private function onChangeTab(index:int):void{
        var manager:CTeachingInstanceManager = (system.getHandler(CTeachingInstanceManager) as CTeachingInstanceManager);
        m_pViewUI.list_teaching.dataSource = manager.getTeachingType(index+1);
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    protected function addToDisplay() : void {
        if ( m_pViewUI ){
            (system.getHandler(CTeachingInstanceNetHandler) as CTeachingInstanceNetHandler).sendTeachingInfoRequest();
            uiCanvas.addDialog( m_pViewUI );
            system.stage.getSystem(CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);
        }
    }

    public function removeDisplay() : void {
        if ( m_pViewUI ) {
            m_pViewUI.remove();
            system.stage.getSystem(CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP,_onUpdateTipInfoHandler);
        }
    }

    private function _onUpdateTipInfoHandler(e:Event):void
    {
        updateView();
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }



    /**
     * 根据物品ID获取物品表数据
     * @ItemID 物品id
     * @return 返回的物品表数据
     *
     * */
    public function getItemForItemID( itemID : int ) : Item {
        var itemTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
        return itemTable.findByPrimaryKey( itemID );
    }

    public function flyItem():void
    {
        if(getRewardItem == null)return;
        CFlyItemUtil.flyItemToBag(getRewardItem.rewardItem, getRewardItem.rewardItem.localToGlobal(new Point()), system);
        getRewardItem = null;
    }

    public function get selectTab() : int {
        if (m_pViewUI) {
            return m_pViewUI.tab_teachingLevel.selectedIndex;
        }
        return 0;
    }
    private function get _manager() : CTeachingInstanceManager
    {
        return system.getHandler(CTeachingInstanceManager) as CTeachingInstanceManager;
    }
}
}
