//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/10.
 * Time: 10:34
 */
package kof.game.talent.talentFacade.talentSystem.view {

    import flash.events.Event;

import kof.data.CDataTable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.game.talent.talentFacade.CTalentFacade;
    import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
    import kof.game.talent.talentFacade.talentSystem.enums.ETalentSoulSellType;
    import kof.game.talent.talentFacade.talentSystem.mediator.CAbstractTalentMediator;
import kof.game.talent.talentFacade.talentSystem.mediator.CTalentMediator;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.table.Currency;
import kof.table.TalentSoul;
    import kof.ui.demo.talentSys.TalentSellUI;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/10
     */
    public class CTalentSellView extends CAbstractTalentView {
        private var _sellViewUI : TalentSellUI = null;
        private var _soulID : int = 0;
        private var _price : int = 0;
        private var _talentNu : int = 0;

        public function CTalentSellView( mediator : CAbstractTalentMediator ) {
            super( mediator );
            _sellViewUI = new TalentSellUI();
            _sellViewUI.hSlider.addEventListener( Event.CHANGE, _onSliderChange );
            _sellViewUI.maxBtn.clickHandler = new Handler( _maxValue );
            _sellViewUI.minBtn.clickHandler = new Handler( _minValue );
//            _sellViewUI.closeHandler = new Handler( close );
        }

        private function _minValue() : void {
            if ( _talentNu != 0 ) {
                _sellViewUI.hSlider.value = 1;
            }
        }

        private function _maxValue() : void {
            _sellViewUI.hSlider.value = _talentNu;
        }

        private function _onSliderChange( e : Event ) : void {
            if ( _talentNu == 0 ) {
                _sellViewUI.nuTxt.text = "0";
                _sellViewUI.priceTxt.text = "0";
            }
            else {
                _sellViewUI.nuTxt.text = _sellViewUI.hSlider.value + "/" + _talentNu;
                _sellViewUI.priceTxt.text = _price * _sellViewUI.hSlider.value + "";
            }
        }

        override public function show( data : Object = null ) : void {
            this._soulID = data.soulID;
            _show();
            parent.addPopupDialog( _sellViewUI );
        }

        private function _sellTalent() : void {
            App.dialog.close(_sellViewUI);
            CTalentFacade.getInstance().requestSoulSell( ETalentSoulSellType.SELL, _soulID, _sellViewUI.hSlider.value, [], 0 , 0 );//单个出售后三个参数可以随便传，服务器不会用
        }

        override public function close() : void {
            if ( parent.rootContainer.contains( _sellViewUI ) ) {
                parent.rootContainer.removeChild( _sellViewUI );
            }
        }

        override public function update() : void {
            _show();
        }

        private function _show() : void {
            if ( this._soulID == 0 ) {
                return;
            }
            var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( this._soulID );
            var icoItem : Object = null;
            if((_mediator as CTalentMediator).talentMainView.currentPage==ETalentPageType.BEN_YUAN){
                _sellViewUI.icoItem.visible = true;
                _sellViewUI.icoItem1.visible = false;
                icoItem = _sellViewUI.icoItem;
            }else{
                _sellViewUI.icoItem1.visible = true;
                _sellViewUI.icoItem.visible = false;
               icoItem = _sellViewUI.icoItem1;
            }
            icoItem.ico.url = CTalentFacade.getInstance().getTalentIcoPath( talentSoul.icon );
            icoItem.btn.visible = false;
//            icoItem.lvClipWhite.visible = false;
//            icoItem.lvClipBlue.visible = false;
//            icoItem.lvClipGreen.visible = false;
//            icoItem.lvClipOrange.visible = false;
//            icoItem.lvClipHuang.visible = false;
//            icoItem.lvClipHong.visible = false;
//            icoItem.lvClipPurple.visible = false;
//            icoItem.lvClipPurple.index = talentSoul.quality-1;
            icoItem.kuangClip.index = 1;
            icoItem.txt1.visible = false;
            icoItem.txt2.visible = false;
//            icoItem.txt3.visible = false;

            if(icoItem.hasOwnProperty("lvClipWhite")) icoItem.lvClipWhite.visible = false;
            if(icoItem.hasOwnProperty("lvClipBlue")) icoItem.lvClipBlue.visible = false;
            if(icoItem.hasOwnProperty("lvClipGreen")) icoItem.lvClipGreen.visible = false;
            if(icoItem.hasOwnProperty("lvClipOrange")) icoItem.lvClipOrange.visible = false;
            if(icoItem.hasOwnProperty("lvClipPurple")) icoItem.lvClipPurple.visible = false;
            if(icoItem.hasOwnProperty("lvClipHuang")) icoItem.lvClipHuang.visible = false;
            if(icoItem.hasOwnProperty("lvClipHong")) icoItem.lvClipHong.visible = false;

            _sellViewUI.nameTxt.text = talentSoul.name;
            var nu : int = CTalentDataManager.getInstance().getTalentPointNuForSoulID( this._soulID );
            var currency:Currency = getCurrency(talentSoul.sellCurrencyType);
            _sellViewUI.currencyIcon.url = currency == null ? "" : ("icon/currency/" + currency.source + ".png");
            _talentNu = nu;
            if ( nu == 0 ) {
                _sellViewUI.nuTxt.text = "0";
                _sellViewUI.priceTxt.text = "0";
                _sellViewUI.hSlider.max = 0;
                _sellViewUI.hSlider.min = 0;
                _sellViewUI.sellBtn.clickHandler = null;
            }
            else {
                _price = talentSoul.sellPrice;
                _sellViewUI.nuTxt.text = "1/" + nu;
                _sellViewUI.priceTxt.text = talentSoul.sellPrice + "";
                _sellViewUI.hSlider.max = nu;
                _sellViewUI.hSlider.min = 1;
                _sellViewUI.hSlider.value = 1;
                _sellViewUI.sellBtn.clickHandler = new Handler( _sellTalent );
            }
        }

        private function getCurrency( type : Number ) : Currency {
            var pDatabaseSystem : CDatabaseSystem = CTalentFacade.getInstance().talentAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.CURRENCY ) as CDataTable;
            return wbInstanceTable.findByPrimaryKey( type );
        }
    }
}
