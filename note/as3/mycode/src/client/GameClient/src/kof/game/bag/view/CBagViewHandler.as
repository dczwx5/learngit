//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/9/21.
 */
package kof.game.bag.view {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bag.*;
import kof.game.bag.data.CBagData;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.table.Item;
import kof.ui.demo.Bag.BagUI;
import kof.ui.demo.Bag.QualityBoxUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CBagViewHandler extends CTweenViewHandler {

    private var m_bagUI : BagUI;
    private var _curQualityBoxUI : QualityBoxUI;
    private var m_pCloseHandler : Handler;

    private static const LIST_LEN : int = 49;
    private static const LIST_V_LEN : int = 7;

    public function CBagViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ BagUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "frameclip_item.swf"
        ];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_bagUI ) {
            m_bagUI = new BagUI();
            m_bagUI.list.renderHandler = new Handler( renderItem );
            m_bagUI.list.mouseHandler = new Handler( listMouseHandler );
            m_bagUI.tab.selectHandler = new Handler( _onTabSelectedHandler );
            m_bagUI.closeHandler = new Handler( _onClose );
        }

        return Boolean( m_bagUI );
    }

    private function _onTabSelectedHandler( index : int ) : void {
        var indexI : int = m_bagUI.tab.selectedIndex;//策划删了装备UI，却不改表
        if( indexI > 0 )
            indexI ++;
        m_bagUI.list.dataSource = _buildListDataArray( _pBagManager.getBagDataByType( indexI ) );
    }

    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is QualityBoxUI) ) {
            return;
        }
        var pQualityBoxUI : QualityBoxUI = item as QualityBoxUI;
        pQualityBoxUI.mouseChildren = false;
        if ( pQualityBoxUI.box_eff )
            pQualityBoxUI.box_eff.visible = false;
        pQualityBoxUI.doubleClickEnabled = true;
        pQualityBoxUI.img.url =
                pQualityBoxUI.txt_num.text = "";
        pQualityBoxUI.clip_bg.index = 0;
        if ( pQualityBoxUI.dataSource ) {
            var pBagData : CBagData = pQualityBoxUI.dataSource as CBagData;
            if ( pBagData.num > 1 )
                pQualityBoxUI.txt_num.text = pBagData.num.toString();
            if ( pBagData.item ) {
                pQualityBoxUI.img.url = pBagData.item.smalliconURL + ".png";
                pQualityBoxUI.clip_bg.index = pBagData.item.quality;
                //新增道具扫光判断条件，effect>0且额外配置数量>0时，数量超过配置数量，或者额外配置数量为0时，显示扫光
                //==============================add by Lune 0617 start======================================
                pQualityBoxUI.box_eff.visible = pBagData.item.effect > 0 ? (pBagData.item.extraEffect == 0 || pBagData.num >= pBagData.item.extraEffect) : false;
                //==============================add by Lune 0617 end========================================
            }
        }

        pQualityBoxUI.toolTip = new Handler( showTips, [ pQualityBoxUI ] );
    }

    private function showTips( item : QualityBoxUI ) : void {
        (system.stage.getSystem( CItemSystem ) as CItemSystem).addTips( CItemTipsView, item );
    }

    private var _double : Boolean;

    private function listMouseHandler( evt : Event, idx : int ) : void {
        _curQualityBoxUI = m_bagUI.list.getCell( idx ) as QualityBoxUI;
        if ( evt.type == MouseEvent.DOUBLE_CLICK ) {
            _double = true;
        } else if ( evt.type == MouseEvent.CLICK ) {
            _double = false;
            delayCall( 260 / 1000, _checkTimer );
        }
    }

    private function _checkTimer() : void {
        if( _curQualityBoxUI.dataSource == '')
                return;
        if ( _double ) {
            if ( _curQualityBoxUI.dataSource.item.useEffectScriptID == 1 )
                _pBagHandler.onItemUseRequest( _curQualityBoxUI.dataSource.uid, 1 );
        } else {
            if ( _curQualityBoxUI.dataSource )
                _pBagMenuHandler.show( _curQualityBoxUI );
        }
    }


    private function _updateMoneyData( evt : CPlayerEvent ) : void {
        var pCPlayerData : CPlayerData = (_playerSystem.getBean( CPlayerManager ) as CPlayerManager).playerData;
        m_bagUI.txt_glod.text = pCPlayerData.currency.gold.toString();
        m_bagUI.txt_diamond.text = pCPlayerData.currency.blueDiamond.toString();
        m_bagUI.txt_purpleDiamond.text = pCPlayerData.currency.purpleDiamond.toString();
    }

    private function _onBagUpdate( evt : CBagEvent ) : void {
        var index : int = m_bagUI.tab.selectedIndex;//策划删了装备UI，却不改表
        if( index > 0 )
            index ++;
        _pBagManager.addDirtyAry( index );
        m_bagUI.list.dataSource = _buildListDataArray( _pBagManager.getBagDataByType( index ) );
    }

    private function _addEventListeners() : void {
        system.addEventListener( CBagEvent.BAG_UPDATE, _onBagUpdate );
        _playerSystem.addEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateMoneyData);
    }

    private function _removeEventListeners() : void {
        if ( _playerSystem )
        system.removeEventListener( CBagEvent.BAG_UPDATE, _onBagUpdate );
        _playerSystem.removeEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateMoneyData);
    }



    private function _buildListDataArray( array : Array ) : Array {
        var i : int;
        var n : int;
        var newAry : Array = [];
        if ( array.length < LIST_LEN ) {
            n = LIST_LEN - array.length;
            for ( i = 0; i < n; i++ ){
                newAry.push( "" );
            }
        }else if(  array.length > LIST_LEN  ){
            n = LIST_V_LEN - array.length % 7;
            for ( i = 0; i < n; i++ ){
                newAry.push( "" );
            }
        }
        return array.concat( newAry );
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay() : void {
        this.invalidate();
        //loadAssetsByView( viewClass,_showDisplay );
        this.callLater( _addToDisplay );
    }
    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            _addToDisplay();
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if ( m_bagUI ) {

            m_bagUI.tab.selectedIndex = 0;
            m_bagUI.tab.callLater( _onTabSelectedHandler,[0]);

            setTweenData(KOFSysTags.BAG);
            showDialog(m_bagUI);
//            uiCanvas.addDialog( m_bagUI );
            _addEventListeners();
            _updateMoneyData( null);
        }
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_bagUI ) {
//            m_bagUI.close( Dialog.CLOSE );
            _pBagMenuHandler.hide();
            _removeEventListeners();
        }
    }

    private function _onClose( type : String ) : void {
        if( m_bagUI && !m_bagUI.parent )
                return;
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function get _pBagManager():CBagManager{
        return system.getBean( CBagManager ) as CBagManager;
    }
    private function get _pBagHandler():CBagHandler{
        return system.getBean( CBagHandler ) as CBagHandler;
    }
    private function get _pBagMenuHandler():CBagMenuHandler{
        return system.getBean( CBagMenuHandler ) as CBagMenuHandler;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
}
}
