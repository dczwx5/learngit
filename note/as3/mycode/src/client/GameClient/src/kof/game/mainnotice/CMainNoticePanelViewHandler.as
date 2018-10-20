//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/5.
 */
package kof.game.mainnotice {

import QFLib.Utils.HtmlUtil;
import QFLib.Utils.StringUtil;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.mainnotice.data.CMainNoticeConst;
import kof.game.mainnotice.data.CMainNoticeData;
import kof.game.mainnotice.data.CMainNoticeEvent;
import kof.table.GamePrompt;
import kof.ui.master.mainnotice.MainNoticePanelItemUI;
import kof.ui.master.mainnotice.MainNoticePanelUI;
import kof.util.CQualityColor;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CMainNoticePanelViewHandler extends CViewHandler {

    private var m_noticeUI : MainNoticePanelUI;

    public function CMainNoticePanelViewHandler(  ) {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ MainNoticePanelUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_noticeUI ) {
            m_noticeUI = new MainNoticePanelUI();
            m_noticeUI.list_notice.renderHandler = new Handler( renderNoticeItem );
            m_noticeUI.list_notice.mouseHandler = new Handler( listItemSelectHandler );
            m_noticeUI.list_notice.dataSource = [];
            m_noticeUI.closeHandler = new Handler( _onClose );
        }

        return Boolean( m_noticeUI );
    }


    private function _onResponse( evt : CMainNoticeEvent ):void{
        if ( _domain && m_noticeUI) {
            m_noticeUI.list_notice.dataSource = _domain.list;
            m_noticeUI.list_notice.scrollTo( m_noticeUI.list_notice.length - 1);
        }
    }

    private function renderNoticeItem( item : Component, idx : int ) : void {
        if ( !(item is MainNoticePanelItemUI) ) {
            return;
        }
        var mainNoticeItemUI : MainNoticePanelItemUI = item as MainNoticePanelItemUI;
        if ( !mainNoticeItemUI.dataSource )
            return;
        var mainNoticeData : CMainNoticeData =  mainNoticeItemUI.dataSource as CMainNoticeData;
        var pTable:IDataTable;
        pTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.GAME_PROMPT);
        var itemName :String  = "";
        var pGamePrompt : GamePrompt = pTable.findByPrimaryKey( mainNoticeData.gamePromptID ) as GamePrompt;
        if( mainNoticeData.gamePromptID == 108 ){
            var pItemData : CItemData  = _pItemSystem.getItem( int(mainNoticeData.contents[0]) );
            itemName = HtmlUtil.hrefAndU( pItemData.name , CMainNoticeConst.ITEM_NAME ,CQualityColor.getColorByQuality( pItemData.quality ));
            mainNoticeItemUI.txt_msg.text = replaceStr(pGamePrompt.content,itemName,mainNoticeData.contents[1]);
        }else if( mainNoticeData.gamePromptID == 214 || mainNoticeData.gamePromptID == 215 || mainNoticeData.gamePromptID == 216 ){
            mainNoticeItemUI.txt_msg.text = replaceStr(pGamePrompt.content,mainNoticeData.contents[0]);
        }
        mainNoticeItemUI.txt_time.text = '[' + StringUtil.timeFormat2( mainNoticeData.time ) + ']';
        mainNoticeItemUI.txt_msg.height = mainNoticeItemUI.txt_msg.textField.textHeight + 10;
    }

    private function listItemSelectHandler( evt:Event,idx : int ) : void {
        var pMainNoticeItemUI : MainNoticePanelItemUI  = m_noticeUI.list_notice.getCell( idx ) as MainNoticePanelItemUI;
        if(!pMainNoticeItemUI)
            return;
        if ( evt.type == MouseEvent.ROLL_OVER  ) {
            var turl : String = pMainNoticeItemUI.txt_msg.textField.getTextFormat(
                    pMainNoticeItemUI.txt_msg.textField.getCharIndexAtPoint( pMainNoticeItemUI.txt_msg.mouseX, pMainNoticeItemUI.txt_msg.mouseY ) ).url;
            if(turl){
                var ary : Array = turl.split(':');
                if( ary[1] == CMainNoticeConst.ITEM_NAME ){
                    pMainNoticeItemUI.toolTip = new Handler( showTips, [pMainNoticeItemUI] );
                }
            }else{
                App.tip.closeAll();
            }
        }else if( evt.type == MouseEvent.ROLL_OUT ){
            App.tip.closeAll();
        }

    }
    private function showTips(item:MainNoticePanelItemUI):void {
        _pItemSystem.addTips(CItemTipsView,item,[int( (item.dataSource as CMainNoticeData).contents[0])]);
    }
    public function addDisplay() : void {
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
    public function _addToDisplay( ):void {
        if(m_noticeUI){
            uiCanvas.addDialog(m_noticeUI);
            m_noticeUI.list_notice.dataSource = _domain.list;
            m_noticeUI.list_notice.scrollTo( m_noticeUI.list_notice.length );
            _addEventListeners();
        }
    }
    public function removeDisplay() : void {
        if ( m_noticeUI ) {
            m_noticeUI.close( Dialog.CLOSE );
            _removeEventListeners();
        }
    }
    //todo 全局
    private function replaceStr( string : String , ...param ) : String {
        for( var i:int = 0 ; i < param.length ; i ++ ) {
            string = string.replace( "{" + i + "}", param[i] );
        }
        return string;
    }
    private function _onClose( type : String ) : void {
        _removeEventListeners();
    }

    private function _addEventListeners() : void {
        _removeEventListeners();
        system.addEventListener( CMainNoticeEvent.MAIN_NOTICE_UPDATE ,_onResponse, false, 0, true);
    }
    private function _removeEventListeners() : void {
        if ( m_noticeUI ) {
            system.removeEventListener( CMainNoticeEvent.MAIN_NOTICE_UPDATE ,_onResponse );
        }
    }

    private function get _domain():CMainNoticeMessageList{
        return system.getBean( CMainNoticeMessageList ) as CMainNoticeMessageList;
    }
    private function get _pItemSystem():CItemSystem{
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }
}
}
