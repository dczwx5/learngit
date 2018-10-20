//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/10.
 * Time: 9:49
 */
package kof.game.talent.talentFacade.talentSystem.view {

import flash.events.Event;

import kof.game.common.CLang;

import kof.game.talent.talentFacade.CTalentFacade;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentColorType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentMainType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentViewType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentWareType;
import kof.game.talent.talentFacade.talentSystem.mediator.CAbstractTalentMediator;
import kof.game.talent.talentFacade.talentSystem.mediator.CTalentMediator;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentWarehouseData;
import kof.table.PassiveSkillPro;
import kof.table.TalentSoul;
import kof.ui.demo.talentSys.TalentBagUI;
import kof.ui.demo.talentSys.TalentIco2UI;
import kof.ui.demo.talentSys.TalentIco3UI;
import kof.ui.demo.talentSys.TalentIcoUI;
import kof.ui.demo.talentSys.TalentItemUI;

import morn.core.components.Box;

import morn.core.components.Button;
import morn.core.components.CheckBox;

import morn.core.components.Component;
import morn.core.components.Label;

import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/5/10
 */
public class CTalentBagView extends CAbstractTalentView {
    private var _talentBagUI : TalentBagUI = null;
    private var _canShowTalentQuality : Array = [];
    private var _canShowTalent : Array = [];
    private var _mainType : int = 0;
    private var _talentWareType : int = 0;

    public function CTalentBagView( mediator : CAbstractTalentMediator ) {
        super( mediator );
        _talentBagUI = new TalentBagUI();
        _talentBagUI.itemList.renderHandler = new Handler( _renderItem );
        _talentBagUI.qunlityList.renderHandler = new Handler( _renderFilterTalent );
        _talentBagUI.tabBtn.selectHandler = new Handler( _changeTab );
        _talentBagUI.fastSell.clickHandler = new Handler( _fastSell );
    }

    private function _fastSell() : void {
        _mediator.contact( this, ETalentViewType.FAST_SELL, _mainType );
    }

    private function _changeTab( selectIndex : int ) : void {
        _talentBagUI.mouseChildren = false;
        if ( selectIndex == ETalentMainType.ATTACK ) {
            this._mainType = ETalentMainType.ATTACK;
        } else if ( selectIndex == ETalentMainType.DEFENSE ) {
            this._mainType = ETalentMainType.DEFENSE;
        } else if ( selectIndex == ETalentMainType.SPECIAL ) {
            this._mainType = ETalentMainType.SPECIAL;
        } else if ( selectIndex == ETalentMainType.ONLY ) {
            this._mainType = ETalentMainType.ONLY;
        } else {
            this._mainType = 0;
        }
        _filterTalent();
    }

    private function _renderFilterTalent( item : Component, idx : int ) : void {
        var box : Box = item as Box;
        var quality : int = int( idx + 1 );
        (box.getChildByName( "txt" ) as Label).text = quality + "";
        var checkBox : CheckBox = box.getChildByName( "cb" ) as CheckBox;
        if ( _canShowTalentQuality.indexOf( quality ) != -1 ) {
            checkBox.selected = true;
        } else {
            checkBox.selected = false;
        }
        checkBox.addEventListener( Event.CHANGE, _changeSelectQuality );
    }

    private function _changeSelectQuality( e : Event ) : void {
        _talentBagUI.mouseEnabled = false;
        _talentBagUI.mouseChildren = false;
        for ( var i : int = 0; i < 7; i++ ) {
            var box : Box = _talentBagUI.qunlityList.getCell( i ) as Box;
            var checkBox : CheckBox = box.getChildByName( "cb" ) as CheckBox;
            if ( checkBox.selected ) {
                if ( _canShowTalentQuality.indexOf( i + 1 ) == -1 ) {
                    _canShowTalentQuality.push( i + 1 );
                }
            }
            else {
                var index : int = _canShowTalentQuality.indexOf( i + 1 );
                if ( index != -1 ) {
                    _canShowTalentQuality.splice( index, 1 );
                }
            }
        }
        var arr : Array = [];
        _canShowTalentQuality.forEach( function deleteZero( item : int, idx : int, canShowArr : Array ) : void {
            if ( item != 0 ) {
                arr.push( item );
            }
        } );
        _canShowTalentQuality = [];
        _canShowTalentQuality = arr;
        CTalentFacade.getInstance().requestWarehouseSelect( _canShowTalentQuality );
        _filterTalent();
    }

    private function _filterTalent() : void {
        _canShowTalent = [];
        var vec : Vector.<CTalentWarehouseData> = CTalentDataManager.getInstance().getTalentWarehouse( _talentWareType );
        vec.forEach( function filterTalent( item : CTalentWarehouseData, idx : int, vec : Vector.<CTalentWarehouseData> ) : void {
            var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( item.soulConfigID );
            if ( talentSoul ) {
                if ( _mainType != 0 ) {
                    if ( talentSoul.mainType == _mainType && _canShowTalentQuality.indexOf( talentSoul.quality ) != -1 ) {
                        _canShowTalent.push( item );
                    }
                }
                else {
                    if ( _canShowTalentQuality.indexOf( talentSoul.quality ) != -1 ) {
                        _canShowTalent.push( item );
                    }
                }
            }
        } );
        _canShowTalent.sort( _sortTalent );
        for ( var i : int = 0; i < 7; i++ ) {
            if ( _canShowTalentQuality.length < 7 ) {
                _canShowTalentQuality.push( 0 );
            }
        }
        _talentBagUI.qunlityList.dataSource = _canShowTalentQuality;
        _talentBagUI.itemList.dataSource = _canShowTalent;
        _talentBagUI.mouseEnabled = true;
        _talentBagUI.mouseChildren = true;
    }

    private function _sortTalent( a : CTalentWarehouseData, b : CTalentWarehouseData ) : int {
        var a_talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( a.soulConfigID );
        var b_talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( b.soulConfigID );
        if ( a_talentSoul.quality > b_talentSoul.quality ) {
            return -1;
        } else if ( a_talentSoul.quality < b_talentSoul.quality ) {
            return 1;
        } else {
            if ( _mainType == 0 && a_talentSoul.mainType > b_talentSoul.mainType ) {
                return -1;
            } else if ( _mainType == 0 && a_talentSoul.mainType < b_talentSoul.mainType ) {
                return 1;
            } else {
                if ( a_talentSoul.ID > b_talentSoul.ID ) {
                    return -1;
                } else if ( a_talentSoul.ID < b_talentSoul.ID ) {
                    return 1;
                } else {
                    return 0;
                }
            }
        }
    }

    private function _renderItem( item : Component, idx : int ) : void {
        var talentItem : TalentItemUI = item as TalentItemUI;
        var talentWarehouseData : CTalentWarehouseData = item.dataSource as CTalentWarehouseData;
        if ( !talentWarehouseData ) {
            return;
        }
        var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( talentWarehouseData.soulConfigID );
        (talentItem.getChildByName( "nuTxt" ) as Label).text = talentWarehouseData.soulNum + "";
        (talentItem.getChildByName( "nameTxt" ) as Label).text = CTalentFacade.getInstance().getTalentName( talentSoul.ID );
        var sProperty : String = _formatStr( talentSoul.propertysAdd );
        var dataArr : Array = sProperty.split( ";" );
        var dataLen : int = dataArr.length;
        var usedNu : int = 0;
        for ( var i : int = 0; i < dataLen; i++ ) {
            var str : String = String( dataArr[ i ] );
            if ( !str || str == "" ) {
                return;
            }
            var pro : Array = str.split( ":" );
            var addvalue : int = int( pro[ 1 ] );
            var percent : Number = int( pro[ 2 ] ) / 10000 * 100;
            var passiveSkillPro : PassiveSkillPro = CTalentFacade.getInstance().getPassiveSkillProData( int( pro[ 0 ] ) );
            if ( addvalue != 0 ) {
                usedNu++;
                (talentItem.getChildByName( "ptxt" + usedNu ) as Label).text = passiveSkillPro.name;
                (talentItem.getChildByName( "vtxt" + usedNu ) as Label).text = "+" + addvalue;
            }
            if ( percent != 0 ) {
                usedNu++;
                (talentItem.getChildByName( "ptxt" + usedNu ) as Label).text = passiveSkillPro.name + CLang.Get( "bafenbi" );
                (talentItem.getChildByName( "vtxt" + usedNu ) as Label).text = "+" + percent + "%";
            }
        }
        for ( var j : int = usedNu + 1; j < 5; j++ ) {
            (talentItem.getChildByName( "ptxt" + j ) as Label).text = "";
            (talentItem.getChildByName( "vtxt" + j ) as Label).text = "";
        }
        ( talentItem.getChildByName( "btn" ) as Button ).clickHandler = new Handler( _sellTalentPoint, [ talentWarehouseData.soulConfigID ] );
        var icoItem : Object = null;
        if ( talentSoul.warehouseType == ETalentWareType.BENYUAN_WARE ) {
            item.getChildByName( "icoItem" ).visible = talentSoul.mainType != ETalentMainType.ONLY;
            item.getChildByName( "icoItem1" ).visible = false;
            talentItem.view_iconItem2.visible = talentSoul.mainType == ETalentMainType.ONLY;

            if(talentSoul.mainType == ETalentMainType.ONLY)
            {
                icoItem = item.getChildByName( "icoItem2" ) as TalentIco3UI;
            }
            else
            {
                icoItem = item.getChildByName( "icoItem" ) as TalentIcoUI;
            }

        } else {
            item.getChildByName( "icoItem" ).visible = false;
            item.getChildByName( "icoItem1" ).visible = talentSoul.mainType != ETalentMainType.ONLY;
            talentItem.view_iconItem2.visible = talentSoul.mainType == ETalentMainType.ONLY;

            if(talentSoul.mainType == ETalentMainType.ONLY)
            {
                icoItem = item.getChildByName( "icoItem2" ) as TalentIco3UI;
            }
            else
            {
                icoItem = item.getChildByName( "icoItem1" ) as TalentIco2UI;
            }
        }
        icoItem.btn.visible = false;
        icoItem.txt1.visible = false;
        icoItem.txt2.visible = false;
        icoItem.ico.url = CTalentFacade.getInstance().getTalentIcoPath( talentSoul.icon );
        var colorIndex : int = 1;
        icoItem.kuangClip.index = colorIndex;
        _visibleLvClip(icoItem);
//        icoItem.lvClipWhite.visible = false;
//        if ( colorIndex == ETalentColorType.BLUE ) {
//            _visibleLvClip( icoItem );
//            icoItem.lvClipBlue.visible = false;
//            icoItem.lvClipBlue.index = talentSoul.quality - 1;
//        }
//        else if ( colorIndex == ETalentColorType.GREEN ) {
//            _visibleLvClip( icoItem );
//            icoItem.lvClipGreen.visible = false;
//            icoItem.lvClipGreen.index = talentSoul.quality - 1;
//        }
//        else if ( colorIndex == ETalentColorType.ORANGE ) {
//            _visibleLvClip( icoItem );
//            icoItem.lvClipOrange.visible = false;
//            icoItem.lvClipOrange.index = talentSoul.quality - 1;
//        }
//        else if ( colorIndex == ETalentColorType.PURPLE ) {
//            _visibleLvClip( icoItem );
//            icoItem.lvClipPurple.visible = false;
//            icoItem.lvClipPurple.index = talentSoul.quality - 1;
//        } else if ( colorIndex == ETalentColorType.WHITE ) {
//            _visibleLvClip( icoItem );
//            icoItem.lvClipPurple.visible = false;
//            icoItem.lvClipPurple.index = talentSoul.quality - 1;
//        }
//        else if ( colorIndex == ETalentColorType.COLOR_6 ) {
//            _visibleLvClip( icoItem );
//            icoItem.lvClipHuang.visible = false;
//            icoItem.lvClipHuang.index = talentSoul.quality - 1;
//        }
//        else if ( colorIndex == ETalentColorType.COLOR_7 ) {
//            _visibleLvClip( icoItem );
//            icoItem.lvClipHong.visible = false;
//            icoItem.lvClipHong.index = talentSoul.quality - 1;
//        }
    }

    private function _sellTalentPoint( soulID : int ) : void {
        this._mediator.contact( this, ETalentViewType.SELL, {soulID : soulID} );
    }

    private function _formatStr( str : String ) : String {
        str = str.replace( "[", "" );
        str = str.replace( "]", "" );
        return str;
    }

    private function _visibleLvClip( icoItem : Object ) : void {
//        icoItem.lvClipWhite.visible = false;
//        icoItem.lvClipBlue.visible = false;
//        icoItem.lvClipGreen.visible = false;
//        icoItem.lvClipOrange.visible = false;
//        icoItem.lvClipPurple.visible = false;
//        icoItem.lvClipHuang.visible = false;
//        icoItem.lvClipHong.visible = false;

        if(icoItem.hasOwnProperty("lvClipWhite")) icoItem.lvClipWhite.visible = false;
        if(icoItem.hasOwnProperty("lvClipBlue")) icoItem.lvClipBlue.visible = false;
        if(icoItem.hasOwnProperty("lvClipGreen")) icoItem.lvClipGreen.visible = false;
        if(icoItem.hasOwnProperty("lvClipOrange")) icoItem.lvClipOrange.visible = false;
        if(icoItem.hasOwnProperty("lvClipPurple")) icoItem.lvClipPurple.visible = false;
        if(icoItem.hasOwnProperty("lvClipHuang")) icoItem.lvClipHuang.visible = false;
        if(icoItem.hasOwnProperty("lvClipHong")) icoItem.lvClipHong.visible = false;
    }

    private function _valueRender( item : Component, idx : int ) : void {
        var str : String = String( item.dataSource );
        if ( !str || str == "" ) {
            return;
        }
        var pro : Array = str.split( ":" );
        var box : Box = item as Box;
        var addvalue : int = int( pro[ 1 ] );
        var percent : Number = int( pro[ 2 ] ) / 10000;
        var value : int = addvalue * (1 + percent);
        (box.getChildByName( "txt" ) as Label).text = "+" + value;
    }

    override public function show( data : Object = null ) : void {
        if ( (_mediator as CTalentMediator).talentMainView.currentPage == ETalentPageType.BEN_YUAN ) {
            _talentWareType = ETalentWareType.BENYUAN_WARE;
            _talentBagUI.titleName.index = 0;
            _talentBagUI.ico.url = "icon/currency/dihunzhili.png";
        } else {
            _talentWareType = ETalentWareType.PEAK_WARE;
            _talentBagUI.titleName.index = 1;
            _talentBagUI.ico.url = "icon/currency/equipicon.png";
        }
        _show();
        parent.addPopupDialog( _talentBagUI );
    }

    override public function close() : void {
        if ( parent.rootContainer.contains( _talentBagUI ) ) {
            parent.rootContainer.removeChild( _talentBagUI );
        }
    }

    override public function update() : void {
        _show();
    }

    private function _show() : void {
        _canShowTalentQuality = CTalentDataManager.getInstance().talentWarehouseSelectRecord;
        if ( (_mediator as CTalentMediator).talentMainView.currentPage == ETalentPageType.BEN_YUAN ) {
            _talentBagUI.talentNuTxt.text = CTalentFacade.getInstance().talentPoint + "";
        } else {
            _talentBagUI.talentNuTxt.text = CTalentFacade.getInstance().niudanbi + "";
        }
        _filterTalent();
    }

    public function updateTalentPointNu() : void {
        if ( (_mediator as CTalentMediator).talentMainView.currentPage == ETalentPageType.BEN_YUAN ) {
            _talentBagUI.talentNuTxt.text = CTalentFacade.getInstance().talentPoint + "";
        } else {
            _talentBagUI.talentNuTxt.text = CTalentFacade.getInstance().niudanbi + "";
        }
    }
}
}
