//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/11/2.
 */
package kof.game.welfarehall.view {

import flash.events.FocusEvent;
import flash.geom.Point;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import kof.data.CDatabaseSystem;
import kof.framework.CAppSystem;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.welfarehall.CWelfareHallEvent;
import kof.game.welfarehall.CWelfareHallHandler;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.welfareHall.WechatgiftUI;
import kof.ui.master.welfareHall.WelfareHallUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CWechatGifViewHandler extends CWelfarePanelBase {

    private var _wechatgiftUI : WechatgiftUI;

    private static const DEFUL_STR : String = '点击输入或粘贴激活码';

    private var m_viewExternal : CViewExternalUtil;

    private var _showEffID : int;

    public function CWechatGifViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _wechatgiftUI = null;
    }
    override public function get viewClass() : Array {
        return [ WechatgiftUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_wechatgiftUI ) {
            _wechatgiftUI = new WechatgiftUI();
            _wechatgiftUI.btn_get.clickHandler = new Handler( _onGetHandler );


//            var pTable : IDataTable;
//            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.WECHATCONFIG );
//            var weChatConfig : WeChatConfig = pTable.findByPrimaryKey( 1 );
//            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.DROP_PACKAGE );//115010001 (0x6dae9d1)
//            var dropPackage : DropPackage = pTable.findByPrimaryKey(  weChatConfig.rewardID );


        }

        return _wechatgiftUI;
    }

    override public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if ( _wechatgiftUI ) {
            mainUI.ctn.addChild( _wechatgiftUI );
        }
        _addEventListeners();
    }

    override public function removeDisplay() : void {
        if ( _wechatgiftUI ) {
            _wechatgiftUI.remove();
            _removeEventListeners();
        }
    }

    private function onTxtFocus( evt : FocusEvent ) : void {
        if( evt.type == FocusEvent.FOCUS_IN ){
            if( _wechatgiftUI.txt_input.text == DEFUL_STR )
                _wechatgiftUI.txt_input.text = "";
        }else if( evt.type == FocusEvent.FOCUS_OUT ){
            if( _wechatgiftUI.txt_input.text.length <= 0 )
                _wechatgiftUI.txt_input.text = DEFUL_STR;
        }
    }

    private function _addEventListeners():void {
        _removeEventListeners();
        _wechatgiftUI.txt_input.addEventListener( FocusEvent.FOCUS_IN, onTxtFocus, false, 0, true );
        _wechatgiftUI.txt_input.addEventListener( FocusEvent.FOCUS_OUT, onTxtFocus, false, 0, true );
        system.addEventListener( CWelfareHallEvent.ACTIVATION_CODE_RESPONSE ,_onActivationCodeResponse, false, 0, true );
    }
    private function _removeEventListeners():void{
        _wechatgiftUI.txt_input.removeEventListener( FocusEvent.FOCUS_IN, onTxtFocus );
        _wechatgiftUI.txt_input.removeEventListener( FocusEvent.FOCUS_OUT, onTxtFocus );
        system.removeEventListener( CWelfareHallEvent.ACTIVATION_CODE_RESPONSE ,_onActivationCodeResponse);
    }

    private function _onGetHandler():void{
        if( _wechatgiftUI.txt_input.text == DEFUL_STR || _wechatgiftUI.txt_input.text.length <= 0 ){
            _pCUISystem.showMsgAlert('请输入正确的激活码',CMsgAlertHandler.WARNING );
            return;
        }

        _pWelfareHallHandler.onActivationCodeRequest( _wechatgiftUI.txt_input.text );
    }

    private function _onActivationCodeResponse( evt : CWelfareHallEvent ):void{
        _wechatgiftUI.txt_input.text = '';
        var rewardList : Array = evt.data as Array;
        if( rewardList == null || rewardList.length <= 0 )
            return;
        m_viewExternal = new CViewExternalUtil( CRewardItemListView, this, _wechatgiftUI );
        m_viewExternal.show();
        var rewardDataList : CRewardListData = CRewardUtil.createByList( (uiCanvas as CAppSystem).stage, rewardList);
        m_viewExternal.setData( rewardDataList );
        m_viewExternal.updateWindow();

        _showEffID = setInterval( showEff,500 );
    }
    private function showEff():void{
        clearInterval( _showEffID );
        var len:int = _wechatgiftUI.reward_list.item_list.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component =  _wechatgiftUI.reward_list.item_list.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

    private function get mainUI():WelfareHallUI{
        return (system.getBean( CWelfareHallViewHandler ) as CWelfareHallViewHandler).welfareHallUI;
    }

    private function get _pWelfareHallHandler():CWelfareHallHandler{
        return system.getBean( CWelfareHallHandler ) as CWelfareHallHandler;
    }

    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
