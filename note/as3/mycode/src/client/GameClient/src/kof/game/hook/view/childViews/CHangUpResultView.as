//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/30.
 * Time: 14:05
 */
package kof.game.hook.view.childViews {

    import flash.events.Event;

import kof.SYSTEM_ID;

import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.hangUpResult.CHUResultViewHandler;

import kof.game.hook.CHookClientFacade;
    import kof.game.hook.net.CHookNetDataManager;
    import kof.game.hook.view.CHookTips;
    import kof.game.hook.view.CHookView;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.table.HangUpConstant;
    import kof.table.Item;
    import kof.ui.demo.Bag.QualityBoxUI;
    import kof.ui.master.hangup.HangUpResultUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Component;

    import morn.core.handlers.Handler;
    import morn.core.utils.ObjectUtils;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/9/30
     */
    public class CHangUpResultView {
        private var _huResultViewHandler : CHUResultViewHandler = null;
        private var _resultUI : HangUpResultUI = null;
        private var _hookTips : CHookTips = null;

        public function CHangUpResultView( huResultViewHandler : CHUResultViewHandler ) {
            this._huResultViewHandler = huResultViewHandler;
            _resultUI = new HangUpResultUI();
            CHookNetDataManager.instance.addEventListener( "CancelHook", _resultProp );
            _resultUI.itemList.renderHandler = new Handler( _renderItem );

            _resultUI.leftBtn.clickHandler = new Handler( _scrollList, [ "left" ] );
            _resultUI.rightBtn.clickHandler = new Handler( _scrollList, [ "right" ] );
            _resultUI.closeHandler = new Handler(_closeHandler);

            _hookTips = new CHookTips();
        }

        private function _scrollList( type : String ) : void {
            var page : int = _resultUI.itemList.page;
            if ( type == "left" ) {
                if ( page > 0 ) {
                    _resultUI.itemList.page = --page;
                }
            } else if ( type == "right" ) {
                if ( page < _resultUI.itemList.totalPage - 1 ) {
                    _resultUI.itemList.page = ++page;
                }
            }
            if ( _resultUI.itemList.page == 0 ) {
                _resultUI.leftBtn.mouseEnabled = false;
                _resultUI.rightBtn.mouseEnabled = true;
                ObjectUtils.gray( _resultUI.leftBtn, true );
                ObjectUtils.gray( _resultUI.rightBtn, false );
            }
            if ( _resultUI.itemList.page == _resultUI.itemList.totalPage - 1 ) {
                _resultUI.leftBtn.mouseEnabled = true;
                _resultUI.rightBtn.mouseEnabled = false;
                ObjectUtils.gray( _resultUI.leftBtn, false );
                ObjectUtils.gray( _resultUI.rightBtn, true );
            }
            if ( _resultUI.itemList.page > 0 && _resultUI.itemList.page < _resultUI.itemList.totalPage - 1 ) {
                ObjectUtils.gray( _resultUI.leftBtn, false );
                ObjectUtils.gray( _resultUI.rightBtn, false );
                _resultUI.leftBtn.mouseEnabled = true;
                _resultUI.rightBtn.mouseEnabled = true;
            }
        }

        private function _resultProp( e : Event ) : void {
            _resultUI.timeLabel.text = "<" + CHookNetDataManager.instance.totalTime + ">";
            _resultUI.timeLabel.centerX = 0;
            _resultUI.itemList.dataSource = [];
            _resultUI.itemList.dataSource = CHookNetDataManager.instance.getTotalProp();
            var len : int = _resultUI.itemList.dataSource.length;
            if ( len > 4 ) {
                _resultUI.itemList.repeatX = 4;
            } else {
                _resultUI.itemList.repeatX = len;
            }
            _resultUI.itemList.centerX = 0;
            if ( len > 4 ) {
                _resultUI.leftBtn.visible = true;
                _resultUI.rightBtn.visible = true;
            } else {
                _resultUI.leftBtn.visible = false;
                _resultUI.rightBtn.visible = false;
            }
            if ( _resultUI.itemList.page == 0 ) {
                _resultUI.leftBtn.mouseEnabled = false;
                _resultUI.rightBtn.mouseEnabled = true;
                ObjectUtils.gray( _resultUI.leftBtn, true );
                ObjectUtils.gray( _resultUI.rightBtn, false );
            }
            if ( _resultUI.itemList.page == _resultUI.itemList.totalPage - 1 ) {
                _resultUI.leftBtn.mouseEnabled = true;
                _resultUI.rightBtn.mouseEnabled = false;
                ObjectUtils.gray( _resultUI.leftBtn, false );
                ObjectUtils.gray( _resultUI.rightBtn, true );
            }
            if ( _resultUI.itemList.page > 0 && _resultUI.itemList.page < _resultUI.itemList.totalPage - 1 ) {
                ObjectUtils.gray( _resultUI.leftBtn, false );
                ObjectUtils.gray( _resultUI.rightBtn, false );
                _resultUI.leftBtn.mouseEnabled = true;
                _resultUI.rightBtn.mouseEnabled = true;
            }
        }

        private function _renderItem( item : Component, idx : int ) : void {
            var itemUI : QualityBoxUI = item as QualityBoxUI;
            var data : Object = item.dataSource;
            if ( !data )return;
            var itemTable : Item = CHookClientFacade.instance.getItemForItemID( data.itemId );
            itemUI.clip_bg.index = itemTable.quality;
            itemUI.img.url = itemTable.bigiconURL + ".png";
            itemUI.txt_num.text = data.count + "";
            itemUI.box_eff.visible = itemTable.effect > 0 ? (itemTable.extraEffect == 0 || data.count >= itemTable.extraEffect) : false;
            var goods : GoodsItemUI = new GoodsItemUI();
            goods.img.url = itemUI.img.url;
            goods.quality_clip.index = itemUI.clip_bg.index;
            goods.txt.text = data.count + "";
            itemUI.toolTip = new Handler( _showItemTips, [ goods, data.itemId,data.count] );
        }

        private function _showItemTips( goods : GoodsItemUI, id : int,itemNum:int ) : void {
            _hookTips.showItemTips( goods, _getItemTableData( id ), _getItemData( id ),itemNum );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (CHookClientFacade.instance.hookSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = CHookClientFacade.instance.hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        public function show() : void {
            this._huResultViewHandler.uiCanvas.addDialog( _resultUI );
        }

        public function close():void{
            _resultUI.close();
            _closeHandler("");
        }

        private function _closeHandler(type:String):void{
            var pSystemBundleCtx : ISystemBundleContext = this._huResultViewHandler.system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var systemBundle:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.HANGUP_RESULT));
                pSystemBundleCtx.setUserData( systemBundle , "activated", false );
            }
        }
    }
}
