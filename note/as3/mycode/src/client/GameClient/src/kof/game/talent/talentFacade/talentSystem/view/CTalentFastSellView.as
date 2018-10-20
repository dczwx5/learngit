//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/11.
 * Time: 9:55
 */
package kof.game.talent.talentFacade.talentSystem.view {

    import flash.events.Event;

    import kof.game.common.CLang;

    import kof.game.talent.talentFacade.CTalentFacade;
    import kof.game.talent.talentFacade.talentSystem.enums.ETalentMainType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentSoulSellType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentWareType;
import kof.game.talent.talentFacade.talentSystem.mediator.CAbstractTalentMediator;
import kof.game.talent.talentFacade.talentSystem.mediator.CTalentMediator;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
    import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentWarehouseData;
    import kof.table.TalentSoul;
    import kof.ui.demo.talentSys.TalentBatchSellUI;

    import morn.core.components.Box;
    import morn.core.components.CheckBox;

    import morn.core.components.Component;
    import morn.core.components.Label;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/11
     */
    public class CTalentFastSellView extends CAbstractTalentView {
        private var _talentBatchSellUI : TalentBatchSellUI = null;
        private var _sellQualityArr : Array = [];
        private var _mainType : int = 0;
        private var _talentWareType:int=0;

        public function CTalentFastSellView( mediator : CAbstractTalentMediator ) {
            super( mediator );
            _talentBatchSellUI = new TalentBatchSellUI();
            _talentBatchSellUI.fastCancle.clickHandler = new Handler( _sellTalent );
            _talentBatchSellUI.qualityList.renderHandler = new Handler( _qualityRender );
        }

        private function _qualityRender( item : Component, idx : int ) : void {
            var box : Box = item as Box;
            var cb : CheckBox = box.getChildByName( "cb" ) as CheckBox;
            cb.selected = false;
            cb.addEventListener( Event.CHANGE, _changeCheckBox );
            (box.getChildByName( "txt" ) as Label).text = (idx + 1) + "";
        }

        private function _changeCheckBox( e : Event ) : void {
            for ( var i : int = 0; i < 5; i++ ) {
                var box : Box = _talentBatchSellUI.qualityList.getCell( i ) as Box;
                var checkBox : CheckBox = box.getChildByName( "cb" ) as CheckBox;
                if ( checkBox.selected ) {
                    if ( _sellQualityArr.indexOf( i + 1 ) == -1 ) {
                        _sellQualityArr.push( i + 1 );
                    }
                } else {
                    var idx : int = _sellQualityArr.indexOf( i + 1 );
                    if ( idx != -1 ) {
                        _sellQualityArr.splice( idx, 1 );
                    }
                }
            }
            var qualityLen : int = _sellQualityArr.length;
            var talentPointNu : int = 0;
            var price : int = 0;
            var alreadySearch : Vector.<int> = new <int>[];

            var vec : Vector.<CTalentWarehouseData> = CTalentDataManager.getInstance().getTalentWarehouse(_talentWareType);
            vec.forEach( function calculationNu( item : CTalentWarehouseData, idx : int, vec : Vector.<CTalentWarehouseData> ) : void {
                var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( item.soulConfigID );
                var obj : Object = null;
                if ( alreadySearch.indexOf( talentSoul.quality ) == -1 ) {
                    if ( _mainType == 0 ) {
                        if ( _sellQualityArr.indexOf( talentSoul.quality ) != -1 ) {
                            obj = CTalentDataManager.getInstance().getTalentPointNuForQuality( talentSoul.quality ,_talentWareType);
                            talentPointNu += obj.nu;
                            price += obj.price;
                        }
                    }
                    else {
                        if ( talentSoul.mainType == _mainType ) {
                            if ( _sellQualityArr.indexOf( talentSoul.quality ) != -1 ) {
                                obj = CTalentDataManager.getInstance().getTalentPointNuForQuality( talentSoul.quality ,_talentWareType);
                                talentPointNu += obj.nu;
                                price += obj.price;
                            }
                        }
                    }
                    alreadySearch.push( talentSoul.quality );
                }
            } );
            _talentBatchSellUI.sellTxt.text = CLang.Get( "soulTalentNu", {v1 : talentPointNu} );
            _talentBatchSellUI.priceNuTxt.text = price + "";
        }

        private function _sellTalent() : void {
            App.dialog.close( _talentBatchSellUI );
            CTalentFacade.getInstance().requestSoulSell( ETalentSoulSellType.BATCH_SELLL, 0, 0, _sellQualityArr, _mainType ,_talentWareType);
        }

        override public function show( data : Object = null ) : void {
            if((_mediator as CTalentMediator).talentMainView.currentPage==ETalentPageType.BEN_YUAN){
                _talentWareType = ETalentWareType.BENYUAN_WARE;
                _talentBatchSellUI.icon.url = "icon/currency/dihunzhili.png";
            }else{
                _talentWareType = ETalentWareType.PEAK_WARE;
                _talentBatchSellUI.icon.url = "icon/currency/equipicon.png";
            }
            _mainType = int( data );
            var typeName : String = "";
            if ( _mainType == ETalentMainType.ATTACK ) {
                typeName = CLang.Get( "talentAttack" );
            } else if ( _mainType == ETalentMainType.DEFENSE ) {
                typeName = CLang.Get( "talentDefense" );
            } else if ( _mainType == ETalentMainType.SPECIAL ) {
                typeName = CLang.Get( "talentSpecial" );
            } else if ( _mainType == ETalentMainType.ONLY ) {
                typeName = CLang.Get( "talentOnly" );
            } else {
                typeName = CLang.Get( "talentAll" );
            }
            _talentBatchSellUI.typeTxt.text = typeName;
            _talentBatchSellUI.sellTxt.text = CLang.Get( "soulTalentNu", {v1 : 0} );
            _talentBatchSellUI.priceNuTxt.text = "0";
            _talentBatchSellUI.qualityList.dataSource = [ 1, 1, 1, 1, 1 ];

            parent.addPopupDialog( _talentBatchSellUI );
        }

        override public function close() : void {
            if ( parent.rootContainer.contains( _talentBatchSellUI ) ) {
                parent.rootContainer.removeChild( _talentBatchSellUI );
            }
        }

        override public function update() : void {
            _talentBatchSellUI.sellTxt.text = CLang.Get( "soulTalentNu", {v1 : 0} );
            _talentBatchSellUI.priceNuTxt.text = "0";
            _talentBatchSellUI.qualityList.dataSource = [ 1, 1, 1, 1, 1 ];
        }
    }
}
