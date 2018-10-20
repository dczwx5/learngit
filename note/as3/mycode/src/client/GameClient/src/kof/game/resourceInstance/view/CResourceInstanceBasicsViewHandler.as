//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * 资源副本基类
 *
 * @author dendi (dendi@qifun.com)
 */
/**
 * Created by dendi on 2017/10/23.
 */
package kof.game.resourceInstance.view {

import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.resourceInstance.CResourceInstanceHandler;
import kof.game.resourceInstance.CResourceInstanceSystem;
import kof.table.Item;
import kof.table.ResourceInstance;
import kof.table.ResourceInstanceDifficulty;
import kof.ui.CUISystem;
import kof.ui.master.ResourceInstance.ResourceInstanceDifficultyItemUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.List;
import morn.core.components.View;
import morn.core.handlers.Handler;

public class CResourceInstanceBasicsViewHandler extends CViewHandler {

    public var pViewUI : Object;
    public var instanceData:Object;
    public var instanceType:int;
    public var m_viewExternal:CViewExternalUtil;
    public var m_selectedData:Object;

    private var m_tipsView : CResourceInstanceOpenLevelTipsView = null;
    private var m_bViewInitialized : Boolean;
    private var m_pCloseHandler : Handler;
    private var m_heroEmbattleList:CHeroEmbattleListView;
    public function CResourceInstanceBasicsViewHandler() {
    }


    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        pViewUI = null;
        instanceData = null;
        m_viewExternal = null;
    }

    public function removeDisplay() : void {
        if ( pViewUI ) {
            pViewUI.close( Dialog.CLOSE );
            pViewUI.btn_change.removeEventListener( MouseEvent.CLICK, _onClickEmbattleChange );
            pViewUI.btn_sweep.removeEventListener( MouseEvent.CLICK, _onClickSweep );
            pViewUI.btn_challenge.removeEventListener( MouseEvent.CLICK, _onClickChallenge );
            system.stage.getSystem(CEmbattleSystem).removeEventListener(CEmbattleEvent.EMBATTLE_SUCC, _onEmbattleEvent);
        }
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {

            if(!m_tipsView){
                m_tipsView = new CResourceInstanceOpenLevelTipsView();
            }


            if ( !m_bViewInitialized ) {

                if(!m_viewExternal){
                    m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, pViewUI as View);
                }


                var instanceDifArray:Array =  initListData();
                pViewUI.difficulty_list.renderHandler = new Handler(renderItem);
                pViewUI.difficulty_list.selectHandler = new Handler(selectItemHandler,[pViewUI.difficulty_list]);
                pViewUI.difficulty_list.dataSource = instanceDifArray;
                pViewUI.difficulty_list.mouseOverBool = true;
                pViewUI.difficulty_list.selectedIndex = 0;



                pViewUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;

                if(instanceData){
                    updateView();
                }
            }
        }

        return m_bViewInitialized;
    }

    public function initListData():Array{
        return null;
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

    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is ResourceInstanceDifficultyItemUI) || item.dataSource == null) {
            return;
        }
        (item as ResourceInstanceDifficultyItemUI).clip_small.index = idx;
    }

    public function selectItemHandler( ...args) : void {
        var list : List = args[ 0 ] as List;
        if ( list.selectedItem == null )
            return;
        m_selectedData = list.selectedItem as ResourceInstanceDifficulty;

        m_viewExternal.show();
        (m_viewExternal.view as CRewardItemListView).isShowItemCount = false;
        (m_viewExternal.view as CRewardItemListView).forceAlign = 1;
        (m_viewExternal.view as CRewardItemListView).updateLayout();
        m_viewExternal.setData([getItemForItemID(m_selectedData.ResourceType)]);
        m_viewExternal.updateWindow();
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay() : void {
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

    private function _addToDisplay() : void {
        uiCanvas.addPopupDialog( pViewUI as View );
        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var pCPlayerData : CPlayerData = (playerSystem.getBean(CPlayerManager) as CPlayerManager).playerData;

        if(pCPlayerData.embattleManager.hasEmbattleData(instanceType)){
            if (m_heroEmbattleList == null) {
                _createEmbattleListView();
            }

            m_heroEmbattleList.updateWindow();
        } else{
            var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
            embattleSystem.requestBestEmbattle(instanceType);
        }


        pViewUI.btn_change.addEventListener( MouseEvent.CLICK, _onClickEmbattleChange );
        pViewUI.btn_sweep.addEventListener( MouseEvent.CLICK, _onClickSweep );
        pViewUI.btn_challenge.addEventListener( MouseEvent.CLICK, _onClickChallenge );

        system.stage.getSystem(CEmbattleSystem).addEventListener(CEmbattleEvent.EMBATTLE_SUCC, _onEmbattleEvent);
    }

    private function _onEmbattleEvent(e:CEmbattleEvent) : void {
        if (m_heroEmbattleList == null) {
            _createEmbattleListView();
        }
        m_heroEmbattleList.updateWindow();
    }
    private function _createEmbattleListView() : void {
        pViewUI.hero_em_list.mouseHandler = new Handler(function (e:MouseEvent, idx:int) : void {
            if (e.type == MouseEvent.CLICK) {
                _onClickEmbattleChange(null);
            }
        });
        m_heroEmbattleList = new CHeroEmbattleListView(system, pViewUI.hero_em_list, instanceType, new Handler(_onClickEmbattleChange));
    }

    private function _onClickEmbattleChange(e:MouseEvent = null):void{
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
            pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args',[instanceType]);
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
        }
    }


    private function _onClickSweep(e:MouseEvent):void{
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).instanceData.resetSweepData();
        (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).mainNetHandler.sendSweepInstance(m_selectedData.InstanceID,1);
    }

    private function _onClickChallenge(e:MouseEvent = null):void{
        var resourceInstanceTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RESOURCEINSTANCE);
        var instanceArray:Array = resourceInstanceTable.findByProperty( "ID", instanceType );
        var resItem:ResourceInstance = instanceArray[0 ] as ResourceInstance;
        var count:int = resItem.ChallengeNum - instanceData.challengeNum;
        if(count<=0){
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.Get("instance_none_fignt_count"));
            return;
        }
        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var pCPlayerData : CPlayerData = (playerSystem.getBean(CPlayerManager) as CPlayerManager).playerData;
        var embattleListData:CEmbattleListData = pCPlayerData.embattleManager.getByType(instanceType);
        if(embattleListData.list.length<3){
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(CLang.Get("common_need_3_hero"));
            return;
        }
//        (system.getHandler(CResourceInstanceHandler) as CResourceInstanceHandler).onResourceInstanceChallengeRequest(instanceType, m_selectedData.Difficulty);
        (system.getHandler(CResourceInstanceHandler) as CResourceInstanceHandler).onResourceInstanceChallengeRequest(instanceType, m_selectedData.ID);// modify by sprite
        (system as CResourceInstanceSystem).addEvent();
    }

    //渲染List==========================================================================================================

    public function update(data:Object):void{
        instanceData = data;
        if(pViewUI == null){
            return;
        }
        updateView();
    }

    private function updateView():void{
        var resourceInstanceTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RESOURCEINSTANCE);
        if(resourceInstanceTable){
            var instanceArray:Array = resourceInstanceTable.findByProperty( "ID", instanceType );
            var resItem:ResourceInstance = instanceArray[0 ] as ResourceInstance;
            pViewUI.txt_time.text = (resItem.ChallengeNum - instanceData.challengeNum)+"/"+resItem.ChallengeNum;
//            pViewUI.difficulty_list.selectedIndex = instanceData.difficulty - 1;
            var itemArr:Vector.<Box>  = pViewUI.difficulty_list.cells;
            var len:int =  itemArr.length;
            var index:int;
            for(var i:int = 0;i<len;i++){
                var diffItem:ResourceInstanceDifficultyItemUI = itemArr[i] as ResourceInstanceDifficultyItemUI;
                var _playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
                var _diffDate:Object = pViewUI.difficulty_list.getItem(i);
                var _instanceDate:CChapterInstanceData = (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(_diffDate.InstanceID);
                var openLevel:Boolean = _playerData.teamData.level>=_instanceDate.condLevel;
                var isPassLevel:Boolean = i<instanceData.difficulty;
                if(isPassLevel && openLevel){
                    diffItem.img_mask.visible = false;
                    diffItem.mouseEnabled = true;
                    diffItem.mouseChildren = true;
                    pViewUI["icon_mouse_"+i ].visible = false;
                    pViewUI["icon_mouse_"+i ].toolTip = null;
                    index = i;
                }else{
                    diffItem.img_mask.visible = true;
                    diffItem.mouseEnabled = false;
                    diffItem.mouseChildren = false;
                    pViewUI["icon_mouse_"+i ].visible = true;
                    pViewUI["icon_mouse_"+i ].toolTip = new Handler( _onShowTipsFun, [ isPassLevel,openLevel,_instanceDate.condLevel,i ] );
                }
            }
            pViewUI.difficulty_list.selectedIndex = index;
        }
    }

    private function _onShowTipsFun(isPassLevel:Boolean,openLevel:Boolean,level:int,index:int):void{
        m_tipsView.showTips(isPassLevel,openLevel,level,index);
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
}
}
