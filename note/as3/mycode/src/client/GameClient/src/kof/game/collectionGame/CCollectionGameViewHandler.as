//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/8.
 */
package kof.game.collectionGame {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;
import flash.net.FileReference;

import kof.game.KOFSysTags;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.collection.CollectionUI;

import morn.core.components.Component;

import morn.core.components.Label;

import morn.core.handlers.Handler;

public class CCollectionGameViewHandler extends CTweenViewHandler {
    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:CollectionUI;
    private var m_pCloseHandler : Handler;
    private var m_iClickType:int;// 1:点领取按钮，2:点关闭按钮

    public function CCollectionGameViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function get viewClass() : Array {
        return [ CollectionUI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_item2.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new CollectionUI();
                m_pViewUI.closeHandler = new Handler(_onCloseHandler);
                m_bViewInitialized = true;

                m_pViewUI.list_reward.renderHandler = new Handler( _onRenderItem );//礼包列表

                var rewardData:CRewardListData = CRewardUtil.createByDropPackageID( system.stage, playerData.playerConstant.CollectionReward );
                if( rewardData ){
                    m_pViewUI.list_reward.dataSource = rewardData.list;
                }

                m_pViewUI.img_hero.mask = m_pViewUI.img_mask;
            }
        }

        return m_bViewInitialized;
    }

    private function _onRenderItem(box:Component, idx:int) : void {
        var item:ItemUIUI = box as ItemUIUI;
        if (item == null) return ;

        if (item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        var itemData:CRewardData = item.dataSource as CRewardData;
        if (!itemData) return ;
//        item.txt_num.visible = _isShowItemCount;
        item.txt_num.text = itemData.num.toString();
        item.img.url = itemData.iconBig;
        item.clip_bg.index = itemData.quality;
        item.toolTip = new Handler(_addTips, [item]);

        item.clip_effect.visible = itemData.effect;
        if (item.clip_effect.visible) {
            item.clip_effect.autoPlay = true;
            item.circle_effect.play();
        } else {
            item.clip_effect.autoPlay = false;
            item.circle_effect.stop();
        }

        var label:Label = m_pViewUI.getChildByName("txt_itemName"+idx) as Label;
        if(label)
        {
            label.text = itemData.name;
        }
    }

    public function flyItem():void
    {
        var len:int = m_pViewUI.list_reward.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component =  m_pViewUI.list_reward.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

    private function _addTips(item:Component) : void {
        var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
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
        setTweenData(KOFSysTags.COLLECTION);
        showDialog(m_pViewUI, false, _addToDisplayB);
    }
    private function _addToDisplayB() : void {
        if ( m_pViewUI ){
            m_pViewUI.btn_collection.addEventListener(MouseEvent.CLICK, _onClick);

            m_pViewUI.img_hero.url = CPlayerPath.getUIHeroFacePath(301);
        }
    }

    private function _onClick(e:MouseEvent):void{
        m_iClickType = 1;
        addDesktopUrl();
    }

    private function addDesktopUrl():void{
        try{
            var url:String = ExternalInterface.call( "getFavoriteUrl" );
            var saveFile:FileReference = new FileReference();
            var strFileContent:String = "[InternetShortcut]" + "\n";
            strFileContent += "URL=" + url + "\n";
            strFileContent += "IDList=0";
            saveFile.save(strFileContent,playerData.playerConstant.CollectionGameName+".url");
            saveFile.addEventListener(Event.COMPLETE,function():void{
                (system.getHandler(CCollectionGameHandler) as CCollectionGameHandler).sendCollectionGameRequest();
                trace("保存成功!")});
//            saveFile.addEventListener(Event.CANCEL, function():void
//            {
//                if(m_iClickType == 2 && closeHandler)
//                {
//                    closeHandler.execute();
//                }
//            });
        }catch (e:Error){　　　
            trace("保存失败!");
        }
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    public function _removeDisplayB() : void {
        if ( m_pViewUI ) {
            m_pViewUI.btn_collection.removeEventListener(MouseEvent.CLICK, _onClick);
            m_pViewUI.remove();
        }
    }

    private function _onCloseHandler(type:String = null):void
    {
        m_iClickType = 2;
//        addDesktopUrl();

        if(closeHandler)
        {
            closeHandler.execute();
        }
    }

    private function get playerData() : CPlayerData
    {
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        return playerManager.playerData;
    }

}
}
