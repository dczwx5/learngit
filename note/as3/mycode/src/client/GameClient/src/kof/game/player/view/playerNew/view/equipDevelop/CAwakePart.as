//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/22.
 * Time: 16:44
 */
package kof.game.player.view.playerNew.view.equipDevelop {

    import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.bag.data.CBagData;
    import kof.game.common.CLang;
    import kof.game.item.CItemData;
import kof.game.player.CPlayerManager;
import kof.game.player.data.CHeroEquipData;
    import kof.game.player.data.CPlayerHeroData;
    import kof.game.player.view.equipmentTrain.CEquTipsView;
    import kof.game.player.view.playerNew.panel.CEquipDevelopPanel;
    import kof.table.Currency;
    import kof.ui.imp_common.ItemUIUI;
    import kof.ui.master.jueseNew.panel.EquipUI;
    import kof.ui.master.jueseNew.panel.HuiZhangTipUI;
    import kof.ui.master.jueseNew.render.EquipProUI;
    import kof.ui.master.jueseNew.render.HeroDevelopItemUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Box;
    import morn.core.components.Clip;

    import morn.core.components.Component;
    import morn.core.components.Label;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/22
     */
    public class CAwakePart extends CAbstractEquipPart {
        private var _pView : EquipUI = null;
        private var _currentEquipData : CHeroEquipData = null;
        private var _proNameArr : Array = [];
        private var _tipsView : CEquTipsView = null;
        private var _stoneSuccessRate : Number = 0;
        private var _sendWishStoneList : Array = [];
        private var _equipPart : int = 0;

        private var _huizhangMijiTips : HuiZhangTipUI = null;

        private var _hasGold : Number = 0;
        private var _needGold : Number = 0;

        public function CAwakePart( panel : CEquipDevelopPanel ) {
            super( panel );
            this._pView = panel.equipUI;
            _tipsView = new CEquTipsView();
            panel.addEventListener( CEquipDevelopPanel.UPDATE_STONE, _dateStone );

            _huizhangMijiTips = new HuiZhangTipUI();
        }

        override protected function _update( data : CPlayerHeroData ) : void {
            var heroData : CHeroEquipData = data.equipList.toArray()[ 0 ];
            _show( heroData );
        }

        private function _upGradeStar() : void {
            if ( _needGold > _hasGold ) {
                _pPanel.showAddGoldView();
                return;
            }
            _pPanel.requestEquipStar( _pData.ID, _pPanel.currentEquipData.equipID, _sendWishStoneList );
            _pPanel.equiStone.selectStoneIndex = 0;
        }

        private function _dateStone( e : Event ) : void {
            _sendWishStoneList = [];
            this._pView.itemList.dataSource = [ 1, 1, 1, 1 ];
        }

        override protected function _show( data : CHeroEquipData ) : void {
            if ( _pPanel.equipItemPart.currentTabIndex != 1 )return;
            _selectStoneName3 = "";
            _selectStoneName4 = "";
            _stoneIndex3 = 0;
            _stoneIndex4 = 0;
            _successRateAdded3 = false;
            _successRateAdded4 = false;
            _pPanel.equiStone.selectStoneIndex = 0;
            super._show( data );
            _sendWishStoneList = [];
            _equipPart = data.part;
            this._pView.equipProList.renderHandler = new Handler( _equipProRender );
            this._pView.awake_btn.clickHandler = new Handler( _upGradeStar );
            _currentEquipData = data;
            this._pView.stoneTxt.visible = true;
            this._pView.succesTxt.visible = true;
            this._pView.equipProList.dataSource = [ data, data ];
            _pView.goldImg.url = EIcomPath.JIN_BI;
            this._pView.fastLvImg.visible = true;
            this._pView.upgrade.visible = false;
            this._pView.upquality.visible = false;
            this._pView.awake_btn.visible = true;
//            this._pView.upquality.label = CLang.Get( "awake" );
            this._pView.fastLvImg.visible = false;

            this._pView.quickupgrade.visible = false;
            _pView.goldTxt1.visible = true;
            _pView.goldTxt2.visible = false;
            _pView.constTxt.text = data.nextAwakenGoldCost + "";

            //觉醒成功率
            _stoneSuccessRate = data.nextAwakenSuccessRate * 100;
            if ( _stoneSuccessRate > 100 ) {
                _stoneSuccessRate = 100;
            }
            _pView.succesTxt.text = CLang.Get( "successPercent" ) + _stoneSuccessRate + "%";

            var arr : Array = [ 1, 1, 1, 1 ];
//            var bagDataVec : Vector.<CBagData> = data.nextQualityItemCost;
//            if ( bagDataVec ) {
//                for ( var i : int = 0; i < bagDataVec.length; i++ ) {
//                    arr.push( bagDataVec[ i ] );
//                }
//            }
            this._pView.itemList.dataSource = arr;
            _needGold = data.nextAwakenGoldCost;
            _hasGold = _pPanel.playerData.currency.gold;
            if ( data.nextAwakenGoldCost > _pPanel.playerData.currency.gold ) {
                _pView.constTxt.color = 0xff0000;
            } else {
                _pView.constTxt.color = 0xffffff;
            }

            _pView.gotoNiudanbtn.visible = false;
            _pView.goldTxt1.visible = true;
            _pView.goldTxt2.visible = false;
            _pView.goldTxt3.visible = false;
            var currency : Currency = null;
            if ( data.part > 4 ) {
                _pView.goldTxt1.visible = false;
                _pView.goldTxt2.visible = true;
                _pView.goldTxt3.visible = true;
                _pView.gotoNiudanbtn.visible = true;
                _pView.constTxt1.text = data.nextAwakenGoldCost + "";
                if ( data.nextAwakenGoldCost > _pPanel.playerData.currency.gold ) {
                    _pView.constTxt1.color = 0xff0000;
                } else {
                    _pView.constTxt1.color = 0xffffff;
                }
                if ( data.nextAwakenCurrencyType == 10 ) { //这里要改成觉醒的花费货币类型
                    currency = _pPanel.getCurrency( data.nextAwakenCurrencyType );
                    _pView.goldImg2.url = EIcomPath.PATH + currency.source + ".png";
                    _pView.goldImg3.url = EIcomPath.PATH + currency.source + ".png";
                    _pView.constTxt2.text = data.nextAwakenCurrencyCount + "";
                    _pView.constTxt3.text = _pPanel.playerData.equipData.huizhang + "";
                    _pView.huiZhangBox.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "huiZhang" )} ) ] );
                    _pView.goldTxt3.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "huiZhang" )} ) ] );
                    if ( data.nextAwakenCurrencyCount > _pPanel.playerData.equipData.huizhang ) {
                        _pView.constTxt2.color = 0xff0000;
                    } else {
                        _pView.constTxt2.color = 0xffffff;
                    }
                }
                if ( data.nextAwakenCurrencyType == 11 ) {//这里要改成觉醒的花费货币类型
                    currency = _pPanel.getCurrency( data.nextAwakenCurrencyType );
                    _pView.goldImg2.url = EIcomPath.PATH + currency.source + ".png";
                    _pView.goldImg3.url = EIcomPath.PATH + currency.source + ".png";
                    _pView.constTxt2.text = data.nextAwakenCurrencyCount + "";
                    _pView.constTxt3.text = _pPanel.playerData.equipData.miji + "";
                    _pView.huiZhangBox.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "miJi" )} ) ] );
                    _pView.goldTxt3.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "miJi" )} ) ] );
                    if ( data.nextAwakenCurrencyCount > _pPanel.playerData.equipData.miji ) {
                        _pView.constTxt2.color = 0xff0000;
                    } else {
                        _pView.constTxt2.color = 0xffffff;
                    }
                }
            }
            if (data.part > 4 || data.star >= 5 || !_pPanel.isEquipOpen(_currentEquipData)) {
                this._pView.itemList.visible = false;
                this._pView.maxState.index = 2;
                this._pView.maxState.visible = data.star >= 5;
                this._pView.liftBox.visible = false;
                this._pView.goldTxt1.visible = false;
                this._pView.goldTxt2.visible = false;
                this._pView.goldTxt3.visible = false;
                this._pView.awake_btn.visible = false;
                _pView.gotoNiudanbtn.visible = false;
                this._pView.box_notOpen.visible = !_pPanel.isEquipOpen(_currentEquipData) || data.part > 4;
            } else {
                this._pView.maxState.visible = false;
                this._pView.box_notOpen.visible = false;
                this._pView.liftBox.visible = true;
                this._pView.itemList.visible = true;
                this._pView.itemList.renderHandler = new Handler( _renderStarItem );
                this._pView.itemList.dataSource = [ 1, 1, 1, 1 ];
            }
        }

        private function _showhuizhangmijiTips( str : String ) : void {
            (_huizhangMijiTips.tips.getChildByName( "txt" ) as Label).text = str;
            App.tip.addChild( _huizhangMijiTips )
        }

        private function _renderStarItem( item : Component, idx : int ) : void {
            var itemUI : HeroDevelopItemUI = item as HeroDevelopItemUI;
            itemUI.img_cd.visible = false;
            itemUI.txt_num.isHtml = true;
            var equipData : CHeroEquipData = _currentEquipData;
            var itemData : CItemData = null;
            var hasBagData : CBagData = null;
            if ( idx == 0 ) {
                //是否专属武器(策划已去掉)
                if ( equipData.isExclusive ) {
                    /*
                    this._pView.itemList.x = 215;
                    itemUI.visible = true;
                    itemData = _pPanel.getItemData( equipData.awakenSoulID ); // 消耗物品
                    hasBagData = _pPanel.bagManager.getBagItemByUid( equipData.awakenSoulID ); //当前拥有
                    itemUI.toolTip = new Handler( _showEquMaterialsTips, [ itemUI, equipData.awakenSoulID ] );
                    itemUI.img_item.url = itemData.iconSmall;
                    if ( hasBagData ) {
                        if ( hasBagData.num >= equipData.nextAwakenSoulCost ) {
                            itemUI.img_black.visible = false;
                            itemUI.link_get.visible = false;
                            itemUI.txt_num.text = equipData.nextAwakenSoulCost+"/"+hasBagData.num;
                            itemUI.clip_bg.index = itemData.quality;
                        }
                        else {
                            itemUI.img_black.visible = true;
                            itemUI.link_get.visible = true;
                            itemUI.txt_num.isHtml = true;
                            itemUI.txt_num.text = "<font color = '#ff0000'> " + hasBagData.num + "/" + equipData.nextAwakenSoulCost + "</font>";
                            itemUI.clip_bg.index = itemData.quality;
                        }
                    }
                    else {
                        itemUI.img_black.visible = true;
                        itemUI.link_get.visible = true;
                        itemUI.txt_num.isHtml = true;
                        itemUI.txt_num.text = "<font color = '#ff0000'> " + 0 + "/" + equipData.nextAwakenSoulCost + "</font>";
                        itemUI.clip_bg.index = itemData.quality;
                    }
                    */
                }
                else {
                    itemUI.visible = false;
                    this._pView.itemList.x = 188;
                }
                if(equipData.awakenSoulID!=0)
                {
                    itemUI.clip_eff.visible =_pPanel.getItem( equipData.awakenSoulID ).effect;
                }else{
                    itemUI.clip_eff.visible = false;
                }
            } else if ( idx == 1 ) {
                if ( equipData.nextAwakenStoneType == 0 ) {

                    return;
                }
                hasBagData = _pPanel.bagManager.getBagItemByUid( equipData.nextAwakenStoneType ); //当前拥有
                itemData = _pPanel.getItemData( equipData.nextAwakenStoneType );
                itemUI.toolTip = new Handler( _showEquMaterialsTips, [ itemUI, equipData.nextAwakenStoneType ] );
                itemUI.img_item.url = itemData.iconSmall;
                itemUI.clip_bg.index = itemData.quality;
                if ( hasBagData ) {
                    if ( hasBagData.num >= equipData.nextAwakenStoneCost ) {
                        itemUI.img_black.visible = false;
                        itemUI.link_get.visible = false;
                        itemUI.link_get.clickHandler = new Handler( _getItemPath, [ equipData.nextAwakenStoneType ,equipData.nextAwakenStoneCost] );
                        itemUI.txt_num.text = hasBagData.num+"/"+equipData.nextAwakenStoneCost;
                        itemUI.addEventListener(MouseEvent.ROLL_OVER, onOverHandler);
                        itemUI.addEventListener(MouseEvent.ROLL_OUT, onOutHandler);
                    }
                    else {
                        itemUI.img_black.visible = true;
                        itemUI.link_get.visible = true;
                        itemUI.link_get.clickHandler = new Handler( _getItemPath, [ equipData.nextAwakenStoneType ,equipData.nextAwakenStoneCost] );
                        itemUI.txt_num.text = "<font color = '#ff0000'> " + hasBagData.num + "/" + equipData.nextAwakenStoneCost + "</font>";
                    }
                }
                else {
                    if ( equipData.nextAwakenStoneType != 0 ) {
                        itemUI.img_black.visible = true;
                        itemUI.link_get.visible = true;
                        itemUI.link_get.clickHandler = new Handler( _getItemPath, [ equipData.nextAwakenStoneType ,equipData.nextAwakenStoneCost] );
                        itemUI.txt_num.text = "<font color = '#ff0000'> " + 0 + "/" + equipData.nextAwakenStoneCost + "</font>";
                    }
                }
                itemUI.clip_eff.visible =_pPanel.getItem( equipData.nextAwakenStoneType ).effect;
            } else if ( idx == 2 ) {
                itemUI.img_black.visible = true;
                itemUI.link_get.visible = true;
                itemUI.link_get.clickHandler = new Handler( _selectStone, [ "item3" ] );
                itemUI.img_item.url = "";
                itemUI.txt_num.text = "";
                itemUI.toolTip = null;
                itemUI.clip_eff.visible =false;
                if ( _selectStoneName3 == "item3" ) {
                    if ( _stoneIndex3 == 0 ) {
                        _stoneIndex3 = _pPanel.equiStone.selectStoneIndex;
                    }
                    if ( _stoneIndex3 != 0 ) {
                        updateStone( itemUI, _stoneIndex3, _successRateAdded3 );
                        _successRateAdded3 = true;
                    }
                }
            } else if ( idx == 3 ) {
                itemUI.img_black.visible = true;
                itemUI.link_get.visible = true;
                itemUI.img_item.url = "";
                itemUI.txt_num.text = "";
                itemUI.link_get.clickHandler = new Handler( _selectStone, [ "item4" ] );
                itemUI.toolTip = null;
                itemUI.clip_eff.visible =false;
                if ( _selectStoneName4 == "item4" ) {
                    if ( _stoneIndex4 == 0 ) {
                        _stoneIndex4 = _pPanel.equiStone.selectStoneIndex;
                    }
                    if ( _stoneIndex4 != 0 ) {
                        updateStone( itemUI, _stoneIndex4, _successRateAdded4 );
                        _successRateAdded4 = true;
                    }
                }
            }

            function onOverHandler():void
            {
                if(itemUI.img_black.visible)
                {
                    return;
                }

                itemUI.link_get.visible = true;
            }

            function onOutHandler():void
            {
                if(itemUI.img_black.visible)
                {
                    return;
                }

                itemUI.link_get.visible = false;
            }
        }

        private function _getItemPath( itemID : Number ,costNum:int) : void {
            _pPanel.getItemPath( itemID ,costNum);
        }

        private var _selectStoneName3 : String = "";
        private var _stoneIndex3 : int = 0;
        private var _successRateAdded3 : Boolean = false;
        private var _selectStoneName4 : String = "";
        private var _stoneIndex4 : int = 0;
        private var _successRateAdded4 : Boolean = false;

        private function _selectStone( type : String ) : void {
            if ( type == "item3" ) {
                _selectStoneName3 = "item3";
            }
            else if ( type == "item4" ) {
                _selectStoneName4 = "item4";
            }
            _pPanel.equiStone.show();
        }

        public function updateStone( itemUI : HeroDevelopItemUI, index : int, isAdd : Boolean ) : void {
            var bagData : CBagData = null;
            if ( index == 1 ) {
                itemUI.img_item.url = _pPanel.getItemData( CHeroEquipData.LOW_WISH_STONE_ID ).iconSmall;
                itemUI.clip_bg.index = _pPanel.getItemData( CHeroEquipData.LOW_WISH_STONE_ID ).quality;
                bagData = _pPanel.bagManager.getBagItemByUid( CHeroEquipData.LOW_WISH_STONE_ID );
                itemUI.toolTip = new Handler( _showEquMaterialTips, [ itemUI, bagData.itemID ] );
                if ( !isAdd ) {
                    _stoneSuccessRate += _pPanel.getItemData( CHeroEquipData.LOW_WISH_STONE_ID ).stoneProbability;
                    _pView.succesTxt.text = CLang.Get( "successPercent" ) + _stoneSuccessRate + "%";
                    itemUI.clip_eff.visible =_pPanel.getItem( CHeroEquipData.LOW_WISH_STONE_ID ).effect;
                }
            }
            else if ( index == 2 ) {
                itemUI.img_item.url = _pPanel.getItemData( CHeroEquipData.MIDDLE_WISH_STONE_ID ).iconSmall;
                itemUI.clip_bg.index = _pPanel.getItemData( CHeroEquipData.MIDDLE_WISH_STONE_ID ).quality;
                bagData = _pPanel.bagManager.getBagItemByUid( CHeroEquipData.MIDDLE_WISH_STONE_ID );
                itemUI.toolTip = new Handler( _showEquMaterialTips, [ itemUI, bagData.itemID ] );
                if ( !isAdd ) {
                    _stoneSuccessRate += _pPanel.getItemData( CHeroEquipData.MIDDLE_WISH_STONE_ID ).stoneProbability;
                    _pView.succesTxt.text = CLang.Get( "successPercent" ) + _stoneSuccessRate + "%";
                    itemUI.clip_eff.visible =_pPanel.getItem( CHeroEquipData.MIDDLE_WISH_STONE_ID ).effect;
                }
            }
            else if ( index == 3 ) {
                itemUI.img_item.url = _pPanel.getItemData( CHeroEquipData.HIGH_WISH_STONE_ID ).iconSmall;
                itemUI.clip_bg.index = _pPanel.getItemData( CHeroEquipData.HIGH_WISH_STONE_ID ).quality;
                bagData = _pPanel.bagManager.getBagItemByUid( CHeroEquipData.HIGH_WISH_STONE_ID );
                itemUI.toolTip = new Handler( _showEquMaterialTips, [ itemUI, bagData.itemID ] );
                if ( !isAdd ) {
                    _stoneSuccessRate += _pPanel.getItemData( CHeroEquipData.HIGH_WISH_STONE_ID ).stoneProbability;
                    _pView.succesTxt.text = CLang.Get( "successPercent" ) + _stoneSuccessRate + "%";
                    itemUI.clip_eff.visible =_pPanel.getItem( CHeroEquipData.HIGH_WISH_STONE_ID ).effect;
                }
            }
            if ( index != 0 ) {
                itemUI.img_black.visible = false;
                itemUI.link_get.visible = false;
                itemUI.txt_num.text = "1";
                itemUI.addEventListener(MouseEvent.ROLL_OVER, onOverHandler);
                itemUI.addEventListener(MouseEvent.ROLL_OUT, onOutHandler);
            }
            if ( _stoneSuccessRate > 100 ) {
                _stoneSuccessRate = 100;
                _pView.succesTxt.text = CLang.Get( "successPercent" ) + _stoneSuccessRate + "%";
            }
            if ( bagData ) {
                _sendWishStoneList.push( bagData );
            }

            function onOverHandler():void
            {
                if(itemUI.img_black.visible)
                {
                    return;
                }

                itemUI.link_get.visible = true;
            }

            function onOutHandler():void
            {
                if(itemUI.img_black.visible)
                {
                    return;
                }

                itemUI.link_get.visible = false;
            }
        }

        private function _showEquMaterialTips( item : HeroDevelopItemUI, itemID : Number ) : void {
            var itemUI : GoodsItemUI = new GoodsItemUI();
            itemUI.quality_clip.index = item.clip_bg.index;
            itemUI.txt.text = item.txt_num.text;
            _tipsView.showEquiMaterialTips( itemUI, _pPanel.getItem( itemID ), _pPanel.getItemData( itemID ) );
        }

        private function _equipProRender( item : Component, idx : int ) : void {
            var equipItem : EquipProUI = item as EquipProUI;
            equipItem.starBox.visible = true;
            equipItem.lvTxt.visible = false;
            equipItem.item.box_effect.visible = false;
            var data : CHeroEquipData = item.dataSource as CHeroEquipData;
            var iconItem : ItemUIUI = equipItem.item;
            if ( !data )return;
            if ( idx == 0 ) {
                iconItem.img.url = data.bigIcon;
                iconItem.txt_num.text = "";
                iconItem.clip_bg.index = data.qualityLevelValue + 1;
                equipItem.equipName.text = data.nameQualityWithColor;
                equipItem.nameClip.index = 0;
                if ( data.star == 0 ) {
                    equipItem.equipStar.visible = false;
                } else {
                    equipItem.equipStar.visible = true;
                    equipItem.equipStar.repeatX = data.star;
                }
                equipItem.proList.renderHandler = new Handler( _proListRender );
                _proNameArr = showProNameAndValue( data, EPropertyType.CURRENT_PROPERTY );
                equipItem.proList.dataSource = _proNameArr;
            } else {
                iconItem.img.url = data.bigIcon;
                iconItem.txt_num.text = "";
                iconItem.clip_bg.index = data.qualityLevelValue + 1;
                equipItem.equipName.text = data.nameQualityWithColor;
                equipItem.nameClip.index = 1;
                if ( data.star + 1 > 5 ) {
                    equipItem.equipStar.repeatX = data.star;
                    equipItem.lvTxt.text = CLang.Get( "player_level" ) + ":" + (data.level);
                    _proNameArr = showProNameAndValue( data, EPropertyType.CURRENT_PROPERTY );
                } else {
                    equipItem.equipStar.repeatX = data.star + 1;
                    equipItem.lvTxt.text = CLang.Get( "player_level" ) + ":" + (data.level + 1);
                    _proNameArr = showProNameAndValue( data, EPropertyType.NEXT_STAR );
                }
                equipItem.proList.renderHandler = new Handler( _proListRender1 );
                equipItem.proList.dataSource = _proNameArr;
            }

        }

        private function _proListRender( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var obj : Object = item.dataSource;
            if ( idx + 1 > _proNameArr.length )return;
            (itemUI.getChildByName( "proName" ) as Label).text = obj.name;
            if ( _equipPart > 4 ) {
                (itemUI.getChildByName( "value" ) as Label).text = "+" + obj.value;
            } else {
                (itemUI.getChildByName( "value" ) as Label).text = obj.value;
            }
        }

        private function _proListRender1( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var obj : Object = item.dataSource;
            if ( idx + 1 > _proNameArr.length )return;
            (itemUI.getChildByName( "lineClip" ) as Clip).index = 1;
            (itemUI.getChildByName( "proName" ) as Label).text = obj.name;
            if ( _equipPart > 4 ) {
                (itemUI.getChildByName( "value" ) as Label).text = "+" + obj.value;
            } else {
                (itemUI.getChildByName( "value" ) as Label).text = obj.value;
            }
        }

        private function _showEquMaterialsTips( item : HeroDevelopItemUI, itemID : Number ) : void {
            var itemUI : GoodsItemUI = new GoodsItemUI();
            itemUI.quality_clip.index = item.clip_bg.index;
            var hasBagData : CBagData = _pPanel.bagManager.getBagItemByUid( itemID ); //当前拥有
            if ( hasBagData ) {
                itemUI.txt.text = hasBagData.num + "";
            } else {
                itemUI.txt.text = "0";
            }
            _tipsView.showEquiMaterialTips( itemUI, _pPanel.getItem( itemID ), _pPanel.getItemData( itemID ) );
        }
    }
}
