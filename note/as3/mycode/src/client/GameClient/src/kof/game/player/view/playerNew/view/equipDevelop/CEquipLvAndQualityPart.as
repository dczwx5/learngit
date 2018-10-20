//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/22.
 * Time: 16:39
 */
package kof.game.player.view.playerNew.view.equipDevelop {

import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bag.data.CBagData;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.player.CPlayerManager;
import kof.game.player.data.CHeroEquipData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.view.equipmentTrain.CEquTipsView;
import kof.game.player.view.playerNew.panel.CEquipDevelopPanel;
import kof.table.BundleEnable;
import kof.table.Currency;
import kof.table.Item;
import kof.ui.CUISystem;
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
    public class CEquipLvAndQualityPart extends CAbstractEquipPart {
        private var _pView : EquipUI = null;
        private var _proNameArr : Array = [];
        private var _currentEquipData : CHeroEquipData = null;
        private var _tipsView : CEquTipsView = null;
        private var _equipPart : int = 0;

        private var _huizhangMijiTips : HuiZhangTipUI = null;

        private var _needGold : Number = 0;
        private var _hasGold : Number = 0;

        public function CEquipLvAndQualityPart( panel : CEquipDevelopPanel ) {
            super( panel );
            this._pView = panel.equipUI;
            this._pView.upgrade.clickHandler = new Handler( _upgrade );
            this._pView.quickupgrade.clickHandler = new Handler( _fastUpgrade );

            _tipsView = new CEquTipsView();

            _huizhangMijiTips = new HuiZhangTipUI();
        }

        private function _upquality() : void {
            if ( _needGold > _hasGold ) {
                _pPanel.showAddGoldView();
                return;
            }
            _pPanel.requestEquipQuality( _pData.ID, _currentEquipData.equipID );
        }

        private function _fastUpgrade() : void {
            var tempNeedGold : Number = 0;
//            var clv : int = _currentEquipData.level;
//            for ( var i : int = clv; i < clv + 5; i++ ) {
//                if ( clv % 5 == 0 )break;
//                tempNeedGold += _currentEquipData.getLevelUpData( clv ).consumeGolds;
//            }
            if ( _needGold > _hasGold ) {
                _pPanel.showAddGoldView();
                return;
            }
            var heroID : int = _pData.ID;
            _pPanel.requestEquipUpgrade( heroID, _currentEquipData.equipID, 1, [] );
        }

        private function _upgrade() : void {
            if ( _needGold > _hasGold ) {
                _pPanel.showAddGoldView();
                return;
            }
            if ( _currentEquipData.level == CHeroEquipData.EQUIP_MAX_LEVEL ) {
                (_pPanel.system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "alreadyHignLv" ) );
                return;
            }
            var heroID : Number = _pData.ID;
            _pPanel.requestEquipUpgrade( heroID, _currentEquipData.equipID, 0, [] );
        }

        override protected function _update( data : CPlayerHeroData ) : void {
            var heroEquipData : CHeroEquipData = data.equipList.toArray()[ 0 ];
            _show( heroEquipData );
        }

        override protected function _show( data : CHeroEquipData ) : void {
            if ( _pPanel.equipItemPart.currentTabIndex != 0 )return;
            super._show( data );
            this._pView.equipProList.renderHandler = new Handler( _equipProRender );
            this._pView.upquality.clickHandler = new Handler( _upquality );
            _currentEquipData = data;
            this._pView.stoneTxt.visible = false;
            this._pView.succesTxt.visible = false;
            this._pView.equipProList.dataSource = [ data, data ];
            var canLevelUp : Boolean = data.isCanLevelUp();
            var currency : Currency = null;
            _pView.goldImg.url = EIcomPath.JIN_BI;
            _equipPart = data.part;
            _pView.gotoNiudanbtn.visible = false;
            if ( canLevelUp ) {
                this._pView.fastLvImg.visible = true;
                this._pView.upgrade.visible = true;
                this._pView.upquality.visible = false;
                this._pView.awake_btn.visible = false;
                this._pView.itemList.visible = false;
                this._pView.quickupgrade.visible = true;
                if ( data.part > 4 ) {
                    _pView.gotoNiudanbtn.visible = true;
                    _pView.goldTxt1.visible = false;
                    _pView.goldTxt2.visible = true;
                    _pView.goldTxt3.visible = true;
                    _pView.constTxt1.text = data.nextLevelGoldCost + "";
                    currency = _pPanel.getCurrency( data.nextLevelOtherCurrencyType );
                    _pView.goldImg1.url = EIcomPath.JIN_BI;
                    _pView.goldImg2.url = EIcomPath.PATH + currency.source + ".png";
                    _pView.constTxt2.text = data.nextLevelOtherCurrencyCost + "";
                    _pView.goldImg3.url = EIcomPath.PATH + currency.source + ".png";
                    if ( data.nextLevelOtherCurrencyType == 10 ) {
                        _pView.constTxt3.text = _pPanel.playerData.equipData.huizhang + "";
                        _pView.huiZhangBox.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "huiZhang" )} ) ] );
                        _pView.goldTxt3.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "huiZhang" )} ) ] );
                        if ( data.nextLevelOtherCurrencyCost > _pPanel.playerData.equipData.huizhang ) {
                            _pView.constTxt2.color = 0xff0000;
                        } else {
                            _pView.constTxt2.color = 0xffffff;
                        }
                    }
                    if ( data.nextLevelOtherCurrencyType == 11 ) {
                        _pView.constTxt3.text = _pPanel.playerData.equipData.miji + "";
                        _pView.huiZhangBox.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "miJi" )} ) ] );
                        _pView.goldTxt3.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "miJi" )} ) ] );
                        if ( data.nextLevelOtherCurrencyCost > _pPanel.playerData.equipData.miji ) {
                            _pView.constTxt2.color = 0xff0000;
                        } else {
                            _pView.constTxt2.color = 0xffffff;
                        }
                    }
                } else {
                    _pView.goldTxt1.visible = true;
                    _pView.goldTxt2.visible = false;
                    _pView.goldTxt3.visible = false;
                    _pView.constTxt.text = data.nextLevelGoldCost + "";
                }
                _needGold = data.nextLevelGoldCost;
                _hasGold = _pPanel.playerData.currency.gold;
                if ( data.nextLevelGoldCost > _pPanel.playerData.currency.gold ) {
                    _pView.constTxt.color = 0xff0000;
                    _pView.constTxt1.color = 0xff0000;
                } else {
                    _pView.constTxt.color = 0xffffff;
                    _pView.constTxt1.color = 0xffffff;
                }

                if ( _currentEquipData.level >= CHeroEquipData.EQUIP_MAX_LEVEL || !_pPanel.isEquipOpen(_currentEquipData)) {
                    this._pView.maxState.index = 1;
                    this._pView.maxState.visible = _currentEquipData.level >= CHeroEquipData.EQUIP_MAX_LEVEL;
                    this._pView.liftBox.visible = false;
                    this._pView.upgrade.visible = false;
                    this._pView.quickupgrade.visible = false;
                    this._pView.goldTxt1.visible = false;
                    this._pView.goldTxt2.visible = false;
                    this._pView.goldTxt3.visible = false;
                    _pView.gotoNiudanbtn.visible = false;
                    _pView.box_notOpen.visible = !_pPanel.isEquipOpen(_currentEquipData);
                } else {
                    this._pView.liftBox.visible = true;
                    this._pView.maxState.visible = false;
                    _pView.box_notOpen.visible = false;
                }
            } else {
                this._pView.upquality.label = "升品";
                this._pView.fastLvImg.visible = false;
                this._pView.upgrade.visible = false;
                this._pView.awake_btn.visible = false;
                this._pView.upquality.visible = true;
                this._pView.itemList.visible = true;
                this._pView.itemList.x = 215;
                this._pView.itemList.renderHandler = new Handler( _renderQualityItem );
                this._pView.quickupgrade.visible = false;
                if ( data.part > 4 ) {
                    _pView.gotoNiudanbtn.visible = true;
                    this._pView.fastLvImg.visible = false;
//                    this._pView.itemList.visible = false;
                    _pView.goldTxt1.visible = false;
                    _pView.goldTxt2.visible = true;
                    _pView.goldTxt3.visible = true;
                    _pView.constTxt1.text = data.nextQualityGoldCost + "";
                    currency = _pPanel.getCurrency( data.nextLevelOtherCurrencyType );
                    _pView.goldImg1.url = EIcomPath.JIN_BI;
                    _pView.goldImg2.url = EIcomPath.PATH + currency.source + ".png";
                    _pView.constTxt2.text = data.nextQualityOtherCurrencyCost + "";
                    _pView.goldImg3.url = EIcomPath.PATH + currency.source + ".png";
                    if ( data.nextQualityOtherCurrencyType == 10 ) {
                        _pView.constTxt3.text = _pPanel.playerData.equipData.huizhang + "";
                        _pView.huiZhangBox.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "huiZhang" )} ) ] );
                        _pView.goldTxt3.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "huiZhang" )} ) ] );
                        if ( data.nextQualityOtherCurrencyCost > _pPanel.playerData.equipData.huizhang ) {
                            _pView.constTxt2.color = 0xff0000;
                        } else {
                            _pView.constTxt2.color = 0xffffff;
                        }
                    }
                    if ( data.nextQualityOtherCurrencyType == 11 ) {
                        _pView.constTxt3.text = _pPanel.playerData.equipData.miji + "";
                        _pView.huiZhangBox.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "miJi" )} ) ] );
                        _pView.goldTxt3.toolTip = new Handler( _showhuizhangmijiTips, [ CLang.Get( "getHuiZhangMiJi", {v1 : CLang.Get( "miJi" )} ) ] );
                        if ( data.nextQualityOtherCurrencyCost > _pPanel.playerData.equipData.miji ) {
                            _pView.constTxt2.color = 0xff0000;
                        } else {
                            _pView.constTxt2.color = 0xffffff;
                        }
                    }
                } else {
                    _pView.goldTxt1.visible = true;
                    _pView.goldTxt2.visible = false;
                    _pView.goldTxt3.visible = false;
                    _pView.constTxt.text = data.nextQualityGoldCost + "";
                }

                var bagDataVec : Vector.<CBagData> = data.nextQualityItemCost;
                if ( !bagDataVec || !_pPanel.isEquipOpen(_currentEquipData)) {
                    this._pView.itemList.visible = false;
                    this._pView.maxState.index = 0;
                    this._pView.maxState.visible = !bagDataVec;
                    this._pView.liftBox.visible = false;
                    this._pView.upquality.visible = false;
                    this._pView.goldTxt1.visible = false;
                    this._pView.goldTxt2.visible = false;
                    this._pView.goldImg3.visible = false;
                    _pView.gotoNiudanbtn.visible = false;
                    _pView.box_notOpen.visible = !_pPanel.isEquipOpen(_currentEquipData);
                } else {
                    this._pView.liftBox.visible = true;
                    this._pView.maxState.visible = false;
                    this._pView.box_notOpen.visible = false;
                    var arr : Array = [];
                    for ( var i : int = 0; i < bagDataVec.length; i++ ) {
                        arr.push( bagDataVec[ i ] );
                    }
                    this._pView.itemList.dataSource = arr;

                    _needGold = data.nextQualityGoldCost;
                    _hasGold = _pPanel.playerData.currency.gold;
                    if ( data.nextQualityGoldCost > _pPanel.playerData.currency.gold ) {
                        _pView.constTxt.color = 0xff0000;
                        _pView.constTxt1.color = 0xff0000;
                    } else {
                        _pView.constTxt.color = 0xffffff;
                        _pView.constTxt1.color = 0xffffff;
                    }
                }
            }

            _pView.gotoNiudanbtn.clickHandler = new Handler( function () : void {
                var pSystemBundleCtx : ISystemBundleContext = _pPanel.system.stage.getSystem( ISystemBundleContext ) as
                        ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EQUIP_CARD ) );
                    if ( pSystemBundle ) {
                        pSystemBundleCtx.setUserData( pSystemBundle, "activated", true );
                    }
                }
            } );
        }

        private function _showhuizhangmijiTips( str : String ) : void {
            (_huizhangMijiTips.tips.getChildByName( "txt" ) as Label).text = str;
            App.tip.addChild( _huizhangMijiTips )
        }

        private function _renderQualityItem( item : Component, idx : int ) : void {
            var _isCanUpQuality : Boolean = false;
            var itemUI : HeroDevelopItemUI = item as HeroDevelopItemUI;
            itemUI.txt_num.isHtml = true;
            itemUI.visible = true;
            itemUI.img_cd.visible = false;
            var costData : CBagData = item.dataSource as CBagData;
            if ( !costData )return;
            itemUI.toolTip = new Handler( _showEquMaterialsTips, [ itemUI, costData.itemID ] );
            var itemTable : Item = _pPanel.getItem( costData.itemID ); // 消耗物品
            itemUI.img_item.url = itemTable.smalliconURL + ".png";
            var hasBagData : CBagData = _pPanel.bagManager.getBagItemByUid( costData.itemID );
            if ( hasBagData ) {
                if ( hasBagData.num >= costData.num ) {
                    itemUI.img_black.visible = false;
                    itemUI.link_get.visible = false;
                    itemUI.link_get.clickHandler = new Handler( _getItemPath, [ costData.itemID , costData.num] );
                    itemUI.txt_num.text = hasBagData.num+"/"+costData.num;
                    _isCanUpQuality = true;
                    itemUI.addEventListener(MouseEvent.ROLL_OVER, onOverHandler);
                    itemUI.addEventListener(MouseEvent.ROLL_OUT, onOutHandler);
                }
                else {
                    itemUI.img_black.visible = true;
                    itemUI.link_get.visible = true;
                    itemUI.link_get.clickHandler = new Handler( _getItemPath, [ costData.itemID , costData.num] );
                    itemUI.txt_num.isHtml = true;
                    itemUI.txt_num.text = "<font color = '#ff0000'> " + hasBagData.num + "/" + costData.num + "</font>";
                    _isCanUpQuality = false;
                }
            } else {
                itemUI.img_black.visible = true;
                itemUI.link_get.visible = true;
                itemUI.link_get.clickHandler = new Handler( _getItemPath, [ costData.itemID ,costData.num] );
                itemUI.txt_num.isHtml = true;
                itemUI.txt_num.text = "<font color = '#ff0000'> " + 0 + "/" + costData.num + "</font>";
                _isCanUpQuality = false;
            }
            itemUI.clip_bg.index = _pPanel.getItem( costData.itemID ).quality;
            itemUI.clip_eff.visible =_pPanel.getItem( costData.itemID ).effect;
            if ( _isCanUpQuality ) {
                if ( _pPanel.playerData.currency.gold >= _currentEquipData.nextQualityGoldCost ) {
                    _isCanUpQuality = true;
                }
                else {
                    _isCanUpQuality = false;
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

        private function _getItemPath( itemID : Number , costNum:int) : void {
            _pPanel.getItemPath( itemID ,costNum);
        }

        private function _equipProRender( item : Component, idx : int ) : void {
            var equipItem : EquipProUI = item as EquipProUI;
            equipItem.starBox.visible = false;
            equipItem.lvTxt.visible = true;
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
                if ( data.isCanLevelUp() ) {
                    equipItem.lvTxt.text = CLang.Get( "player_level" ) + ":" + (data.level);
                } else {
                    equipItem.lvTxt.text = CLang.Get( "lvlimit" ) + ":" + (data.levelLimit);
                }
                equipItem.lvTxt.color = 0xcfffff;
                equipItem.lvTxt.stroke = "0x1a63c5";
                equipItem.lvbgclip.index = 0;
                equipItem.proList.renderHandler = new Handler( _proListRender );
                _proNameArr = showProNameAndValue( data, EPropertyType.CURRENT_PROPERTY );
                equipItem.proList.dataSource = _proNameArr;
            } else {
                iconItem.img.url = data.bigIcon;
                iconItem.txt_num.text = "";
                equipItem.nameClip.index = 1;
                equipItem.lvTxt.color = 0xfff66e;
                equipItem.lvTxt.stroke = "0x8d4206";
                equipItem.lvbgclip.index = 1;
                if ( data.level + 1 > CHeroEquipData.EQUIP_MAX_LEVEL ) {
                    if ( data.isCanLevelUp() ) {
                        equipItem.lvTxt.text = CLang.Get( "player_level" ) + ":" + (data.level);
                    } else {
                        equipItem.lvTxt.text = CLang.Get( "lvlimit" ) + ":" + (data.levelLimit);
                    }
                    _proNameArr = showProNameAndValue( data, EPropertyType.CURRENT_PROPERTY );
                    iconItem.clip_bg.index = data.qualityLevelValue + 1;
                    equipItem.equipName.text = data.nameQualityWithColor;
                } else {
                    if ( data.isCanLevelUp() ) {
                        iconItem.clip_bg.index = data.qualityLevelValue + 1;
                        equipItem.lvTxt.text = CLang.Get( "player_level" ) + ":" + (data.level + 1);
                        equipItem.equipName.text = data.nameQualityWithColor;
                        _proNameArr = showProNameAndValue( data, EPropertyType.NEXT_LEVEL );
                    } else {
                        equipItem.lvTxt.text = CLang.Get( "lvlimit" ) + ":" + (data.getQualityUpRecord( data.quality + 1 ).equipLevelLimit);
                        iconItem.clip_bg.index = data.nextQualityLevelValue + 1;
                        equipItem.equipName.text = data.nameNextQualityWithColor;
                        _proNameArr = showProNameAndValue( data, EPropertyType.NEXT_QUALITY );
                    }
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
