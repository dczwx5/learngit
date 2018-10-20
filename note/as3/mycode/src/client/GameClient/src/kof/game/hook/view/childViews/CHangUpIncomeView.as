//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/26.
 * Time: 10:30
 */
package kof.game.hook.view.childViews {

    import flash.events.Event;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CLang;
    import kof.game.hook.CHookClientFacade;
    import kof.game.hook.net.CHookNetDataManager;
    import kof.game.hook.view.CHookTips;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.HangUpConstant;
import kof.table.HangUpLevelAddition;
import kof.table.Item;
    import kof.ui.demo.Bag.QualityBoxUI;
    import kof.ui.master.hangup.HangUpUI;
    import kof.ui.master.messageprompt.GoodsItemUI;
    import kof.util.CQualityColor;

    import morn.core.components.Box;
    import morn.core.components.Component;
    import morn.core.components.Label;
    import morn.core.handlers.Handler;
    import morn.core.utils.ObjectUtils;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/9/26
     */
    public class CHangUpIncomeView {
        private var _hookUI : HangUpUI = null;
        private var _hookTips : CHookTips = null;

        public function CHangUpIncomeView( hookUI : HangUpUI ) {
            this._hookUI = hookUI;
            this._hookUI.hangupAddList.renderHandler = new Handler( _render );
//            this._hookUI.itemList.renderHandler = new Handler( _renderItem );
            _hookTips = new CHookTips();
//            _hookUI.leftBtn.visible = false;
//            _hookUI.rightBtn.visible = false;
//            _hookUI.leftBtn.clickHandler = new Handler( _scrollList, [ "left" ] );
//            _hookUI.rightBtn.clickHandler = new Handler( _scrollList, [ "right" ] )
        }

//        private function _scrollList( type : String ) : void {
//            var page : int = _hookUI.itemList.page;
//            if ( type == "left" ) {
//                if ( page > 0 ) {
//                    _hookUI.itemList.page = --page;
//                }
//            } else if ( type == "right" ) {
//                if ( page < _hookUI.itemList.totalPage - 1 ) {
//                    _hookUI.itemList.page = ++page;
//                }
//            }
//            if ( _hookUI.itemList.page == 0 ) {
//                _hookUI.leftBtn.mouseEnabled = false;
//                _hookUI.rightBtn.mouseEnabled = true;
//                ObjectUtils.gray( _hookUI.leftBtn, true );
//                ObjectUtils.gray( _hookUI.rightBtn, false );
//            }
//            if ( _hookUI.itemList.page == _hookUI.itemList.totalPage - 1 ) {
//                _hookUI.leftBtn.mouseEnabled = true;
//                _hookUI.rightBtn.mouseEnabled = false;
//                ObjectUtils.gray( _hookUI.leftBtn, false );
//                ObjectUtils.gray( _hookUI.rightBtn, true );
//            }
//            if ( _hookUI.itemList.page > 0 && _hookUI.itemList.page < _hookUI.itemList.totalPage - 1 ) {
//                ObjectUtils.gray( _hookUI.leftBtn, false );
//                ObjectUtils.gray( _hookUI.rightBtn, false );
//                _hookUI.leftBtn.mouseEnabled = true;
//                _hookUI.rightBtn.mouseEnabled = true;
//            }
//        }

        public function show() : void {
//            _hookUI.rewardBox.visible = true;
            _hookUI.hangupAddList.visible = true;
        }

        public function hide() : void {
//            _hookUI.rewardBox.visible = false;
            _hookUI.hangupAddList.visible = false;
        }

        public function initEvent() : void {
            _hookUI.hangupTotalTime.text = "00:00:00";
            CHookNetDataManager.instance.addEventListener( "updateHookData", _updateHookView );
            this._hookUI.hangupAddList.dataSource = [];
//            this._hookUI.itemList.dataSource = [];

        }

        public function dispose() : void {
            CHookNetDataManager.instance.removeEventListener( "updateHookData", _updateHookView );
        }

        public function _renderItem( item : Component, idx : int ) : void {
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
            itemUI.toolTip = new Handler( _showItemTips, [ goods, data.itemId ] );
        }

        private function _showItemTips( goods : GoodsItemUI, id : int ) : void {
            _hookTips.showItemTips( goods, _getItemTableData( id ), _getItemData( id ) );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (CHookClientFacade.instance.hookSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function _render( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var data : Array = itemUI.dataSource as Array;
            if ( !data )return;
            var len : int = data.length;
            var tempStr : String = "";
            for ( var i : int = 0; i < len; i++ ) {
                var obj : Object = data[ i ];
                var itemData : CItemData = _getItemData( obj.itemId );
                tempStr += "<font color='" + CQualityColor.QUALITY_COLOR_ARY[ itemData.quality - 1 ] + "'>" + itemData.name + " x" + obj.count + "</font>" + ",";
            }
            tempStr = tempStr.substr( 0, tempStr.length - 1 );
            (itemUI.getChildByName( "txt" ) as Label).isHtml = true;
            (itemUI.getChildByName( "txt" ) as Label).text = CLang.Get( "hookResultTime", {
                v1 : _getHangUpConstant().dropInterval,
                v2 : tempStr
            } );
        }

        private function _updateHookView( e : Event ) : void {
            _hookUI.hangupAddList.dataSource = CHookNetDataManager.instance.addRecomeArray;
            _hookUI.hangupAddList.scrollTo( _hookUI.hangupAddList.length - 1 );
            var goodsArr1:Array = CHookNetDataManager.instance.getTotalProp();
            var goodsArr2:Array = CHookNetDataManager.instance.getTodayDropItem();
            var goods1:int = 0;
            var goods2:int = 0;
            var goods3:int = 0;
            var goods4:int = 0;
            var goods5:int = 0;
            var goods3limit:int = 0;
            var goods4limit:int = 0;
            var goods5limit:int = 0;
            var i:int;
            for(i = 0;i < goodsArr1.length;i++)
            {
                if(goodsArr1[i].itemId == 50200001)//金币（100）
                {
                    goods1 += goodsArr1[i].count;
                }else if(goodsArr1[i].itemId == 50900001)//充能可乐·小
                {
                    goods2 += goodsArr1[i].count;
                }
            }
            for(i = 0;i < goodsArr2.length;i++)
            {
                if(goodsArr2[i].itemId == 50100001)//能量特饮（小）
                {
                    goods3 = goodsArr2[i].count;
                }else if(goodsArr2[i].itemId == 51000001)//凡级经验盾徽
                {
                    goods4 = goodsArr2[i].count;
                }else if(goodsArr2[i].itemId == 51200001)//凡级神器能量
                {
                    goods5 = goodsArr2[i].count;
                }
            }
            var pDatabase:IDatabase = CHookClientFacade.instance.hookSystem.stage.getSystem(IDatabase) as IDatabase;//获取表系统
            var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.HANGUP_LEVEL_ADDITION);
            var pList:Array = pTable.toArray();
            var levelPlayerData:CPlayerData = (CHookClientFacade.instance.hookSystem.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            for(var p:int = 0;p < pList.length;p++)
            {
                var c:int = pList[p].levelFloor;
                var b:int = pList[p].levelUpper;
                if(levelPlayerData.teamData.level >= pList[p].levelFloor && pList[p].levelUpper >=levelPlayerData.teamData.level)
                {
                    goods3limit = pList[p].VIPDropNumArr[0];
                    goods4limit = pList[p].VIPDropNumArr[1];
                    goods5limit = pList[p].VIPDropNumArr[2];
                    break;
                }
            }

            //ID为金币的叠加
            _hookUI.txt_gold.text = "x" + goods1;
            //ID为经验的叠加
            _hookUI.txt_exp.text = "x" + goods2;
            //ID为大可乐的叠加
            _hookUI.txt_coco.text = "" + goods3 + "/" + goods3limit;
            //ID为盾的叠加
            _hookUI.txt_shield.text = "" + goods4 + "/" + goods4limit;
            //ID为粉水晶的叠加
            _hookUI.txt_pinkCrystal.text = "" + goods5 + "/" + goods5limit;

            _hookUI.pro_coco.value = goods3/goods3limit;// 0-1
            _hookUI.pro_shield.value = goods4/goods4limit;
            _hookUI.pro_pinkCrystal.value = goods5/goods5limit;
            _hookUI.img_coco.x = _hookUI.pro_coco.x + goods3/goods3limit * _hookUI.pro_coco.width;
            _hookUI.img_shield.x = _hookUI.pro_shield.x + goods4/goods4limit * _hookUI.pro_shield.width;
            _hookUI.img_pinkCrystal.x = _hookUI.pro_pinkCrystal.x + goods5/goods5limit * _hookUI.pro_pinkCrystal.width;
//            _hookUI.itemList.dataSource = CHookNetDataManager.instance.getTotalProp();
//            var len : int = _hookUI.itemList.dataSource.length;
//            if ( len > 4 ) {
//                _hookUI.itemList.repeatX = 4;
//            } else {
//                _hookUI.itemList.repeatX = len;
//            }
//            _hookUI.itemList.centerX = 0;
//            if ( len > 4 ) {
//                _hookUI.leftBtn.visible = true;
//                _hookUI.rightBtn.visible = true;
//            } else {
//                _hookUI.leftBtn.visible = false;
//                _hookUI.rightBtn.visible = false;
//            }
//            if ( _hookUI.itemList.page == 0 ) {
//                _hookUI.leftBtn.mouseEnabled = false;
//                _hookUI.rightBtn.mouseEnabled = true;
//                ObjectUtils.gray( _hookUI.leftBtn, true );
//                ObjectUtils.gray( _hookUI.rightBtn, false );
//            }
//            if ( _hookUI.itemList.page == _hookUI.itemList.totalPage - 1 ) {
//                _hookUI.leftBtn.mouseEnabled = true;
//                _hookUI.rightBtn.mouseEnabled = false;
//                ObjectUtils.gray( _hookUI.leftBtn, false );
//                ObjectUtils.gray( _hookUI.rightBtn, true );
//            }
//            if ( _hookUI.itemList.page > 0 && _hookUI.itemList.page < _hookUI.itemList.totalPage - 1 ) {
//                ObjectUtils.gray( _hookUI.leftBtn, false );
//                ObjectUtils.gray( _hookUI.rightBtn, false );
//                _hookUI.leftBtn.mouseEnabled = true;
//                _hookUI.rightBtn.mouseEnabled = true;
//            }
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = CHookClientFacade.instance.hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _getHangUpConstant() : HangUpConstant {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = CHookClientFacade.instance.hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.HANGUP_CONSTANT ) as CDataTable;
            return itemTable.findByPrimaryKey( 1 );
        }
    }
}
