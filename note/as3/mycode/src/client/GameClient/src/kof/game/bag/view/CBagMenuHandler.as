//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/10/26.
 */
package kof.game.bag.view {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagConst;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.chat.CChatSystem;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatType;
import kof.ui.demo.Bag.BagMenuUI;
import kof.ui.demo.Bag.QualityBoxUI;

import morn.core.components.Dialog;

public class CBagMenuHandler extends CViewHandler {

    private var m_bagMenuUI : BagMenuUI;
    private var _curQualityBoxUI : QualityBoxUI;
    private var _curBagData : CBagData;


    public function CBagMenuHandler() {
        super();
    }

    override public function get viewClass() : Array {
        return [ BagMenuUI ];
    }

    public function show( qualityBoxUI : QualityBoxUI ) : void {
        _curQualityBoxUI = qualityBoxUI;
        _curBagData = _curQualityBoxUI.dataSource as CBagData;
        if ( !m_bagMenuUI ) {
            m_bagMenuUI = new BagMenuUI();
            m_bagMenuUI.menu.addEventListener( Event.CHANGE, _onMenuSelectedHandler, false, 0, true );
            m_bagMenuUI.menu.addEventListener( MouseEvent.ROLL_OUT, _onMenuRollHandler, false, 0, true );
        }
        var labels : String ;
        if(  _curBagData.item.useEffectScriptID == 4 ){//展示，出售，合成
            labels = CBagConst.SHOW_STR;
            if ( _curBagData.item.canSell )
                labels += "," + CBagConst.SELL_STR;

            labels += "," + CBagConst.SYNTHESIS_STR;
        }else{
            labels = CBagConst.USE_STR; //使用，展示，出售
            labels += ',' +CBagConst.SHOW_STR;
            if ( _curBagData.item.canSell )
                labels += "," + CBagConst.SELL_STR;
        }


        m_bagMenuUI.menu.labels = labels;
        var p : Point = _curQualityBoxUI.parent.localToGlobal( new Point( _curQualityBoxUI.parent.mouseX, _curQualityBoxUI.parent.mouseY ) );
        m_bagMenuUI.x = p.x - 30;
        m_bagMenuUI.y = p.y - 30;

        m_bagMenuUI.popupCenter = false;
        uiCanvas.addDialog( m_bagMenuUI );
    }

    private function _onMenuSelectedHandler( evt : Event ) : void {
        var selectedIndex : int = m_bagMenuUI.menu.selectedIndex;
        var label : String = m_bagMenuUI.menu.labels.split( "," )[ selectedIndex ];
        if ( selectedIndex != -1 ) {
            m_bagMenuUI.remove();
            if ( label == CBagConst.USE_STR && _curBagData.item.useEffectScriptID == 2 ) {
                _pBageOptionalBonusHandler.show( label, _curBagData );
            } else if ( label == CBagConst.USE_STR ) {
                if( _curBagData.item.useEffectScriptID == 3){//跳转
                    var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                    if(!_curBagData.item.param1) return;//加上保护，防止策划遗漏配置而报错
                    var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(_curBagData.item.param1));
                    var iStateValue : int = bundleCtx.getSystemBundleState( bundle );
                    if( iStateValue == CSystemBundleContext.STATE_STARTED ){
                        bundleCtx.setUserData( bundle, CBundleSystem.ITEM_ID, _curBagData.item.ID);
                        bundleCtx.setUserData( bundle, CBundleSystem.TAB, int(_curBagData.item.param2) );
                        bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
                        m_bagMenuUI.close( Dialog.CLOSE );
                        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                        var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BAG ) );
                        pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
                    }else{
                        bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
                    }
                }else{
                    _pBagBatchHandler.show( label, _curBagData );
                }

            } else if ( label == CBagConst.SELL_STR ) {
                if ( _curBagData.item.quality >= CBagConst.QUALITY_VIOLET ) {
                    var str : String = "确定要出售<font color='#cc3300'>" + _curBagData.item.name + "</font>吗？";
                    uiCanvas.showMsgBox( str, function sellItem() : void {
                        _pBagBatchHandler.show( label, _curBagData );
                    } )
                } else {
                    _pBagBatchHandler.show( label, _curBagData );
                }
            }
            else if ( label == CBagConst.SYNTHESIS_STR && _curBagData.item.useEffectScriptID == 4 ) {
                (system.getBean( CBagPropsSynthesisHandler ) as CBagPropsSynthesisHandler).show( label, _curBagData );
            }else if( label == CBagConst.SHOW_STR ){
                _pChatSystem.broadcastMessage( CChatChannel.WORLD, String( _curBagData.itemID ), CChatType.ITEM_SHOW );
            }
        }
    }

    private function _onMenuRollHandler( evt : MouseEvent ) : void {
        if ( m_bagMenuUI )
            m_bagMenuUI.close();
    }

    public function hide( removed : Boolean = true ) : void {
        if ( m_bagMenuUI )
            m_bagMenuUI.close();
    }

    private function get _pBagBatchHandler():CBagBatchHandler{
        return  system.getBean( CBagBatchHandler ) as CBagBatchHandler;
    }
    private function get _pBageOptionalBonusHandler():CBageOptionalBonusHandler{
        return  system.getBean( CBageOptionalBonusHandler ) as CBageOptionalBonusHandler;
    }
    private function get _pBagViewHandler():CBagViewHandler{
        return  system.getBean( CBagViewHandler ) as CBagViewHandler;
    }
    private function get _pChatSystem():CChatSystem{
        return  system.stage.getSystem( CChatSystem ) as CChatSystem;
    }
    private function get _pBagSystem():CBagSystem{
        return  system.stage.getSystem( CBagSystem ) as CBagSystem;
    }
}
}
