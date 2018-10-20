//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/5.
 */
package kof.game.mainnotice {

import QFLib.Utils.HtmlUtil;

import com.greensock.TweenLite;

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.mainnotice.data.CMainNoticeConst;
import kof.game.mainnotice.data.CMainNoticeData;
import kof.game.mainnotice.data.CMainNoticeEvent;
import kof.table.GamePrompt;
import kof.ui.master.mainnotice.MainNoticeHideUI;
import kof.ui.master.mainnotice.MainNoticeItemUI;
import kof.ui.master.mainnotice.MainNoticeUI;
import kof.util.CQualityColor;

import morn.core.components.Box;
import morn.core.handlers.Handler;

public class CMainNoticeViewHandler extends CViewHandler {

    private var m_noticeUI : MainNoticeUI;

    private var m_noticeHideUI : MainNoticeHideUI;

    private static const MAX_ITEM_NUM : int = 40;

    private var _itemAry:Array;

    private var _isMsgDirty : Boolean ;

    public function CMainNoticeViewHandler( ) {
        super();
    }
    override public function get viewClass() : Array {
        return [ MainNoticeUI];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_noticeUI ) {
            m_noticeUI = new MainNoticeUI();
            m_noticeUI.btn_showPanel.clickHandler = new Handler( onOpenPanelHandler );
            m_noticeUI.addEventListener( MouseEvent.ROLL_OUT, _onBgRollHandler);
            m_noticeUI.addEventListener( MouseEvent.ROLL_OVER, _onBgRollHandler);
            m_noticeUI.bg.alpha = 0;
        }
        if( !m_noticeHideUI ){
            m_noticeHideUI = new MainNoticeHideUI();
        }
        m_noticeUI.btn_hide.clickHandler = new Handler( onHideHandler ,[ m_noticeUI,m_noticeHideUI] );
        m_noticeHideUI.btn_hide.clickHandler = new Handler( onHideHandler ,[ m_noticeHideUI,m_noticeUI] );
        onHideHandler( m_noticeHideUI,m_noticeUI );

        _itemAry = [];

        system.addEventListener( CMainNoticeEvent.MAIN_NOTICE_UPDATE ,_onResponse, false, 0, true);

        m_noticeHideUI.visible = m_noticeUI.visible = false;//todo 暂时隐藏

        return Boolean( m_noticeUI );
    }


    private function updateView( delta : Number ) : void {
        if ( !_isMsgDirty )
                return;
        _isMsgDirty = false;
        if ( _domain && m_noticeUI ) {
            var itemY : int  = 0;
            var dataAry : Array = _domain.list;
            var mainNoticeItemUI : MainNoticeItemUI;
            var mainNoticeData : CMainNoticeData;
            for each( mainNoticeData in dataAry){
                if ( _itemAry.length >= MAX_ITEM_NUM ) {
                    mainNoticeItemUI = _itemAry.shift();
                    _itemAry.push( mainNoticeItemUI );
                } else {
                    mainNoticeItemUI = new MainNoticeItemUI();
                }
                updateNoticeItem( mainNoticeItemUI , mainNoticeData );
                m_noticeUI.panel_list.addElement(mainNoticeItemUI,0,itemY);
                itemY += mainNoticeItemUI.height ;
            }
            m_noticeUI.panel_list.scrollTo( 0,itemY );
        }
    }
    private function updateNoticeItem( mainNoticeItemUI : MainNoticeItemUI ,mainNoticeData : CMainNoticeData ):MainNoticeItemUI{
        mainNoticeItemUI.dataSource = mainNoticeData;
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

        mainNoticeItemUI.txt_msg.height = mainNoticeItemUI.txt_msg.textField.textHeight;
        mainNoticeItemUI.height = mainNoticeItemUI.txt_msg.height;

        mainNoticeItemUI.addEventListener( MouseEvent.MOUSE_MOVE,  _onTextRollHandler );
        mainNoticeItemUI.addEventListener( MouseEvent.MOUSE_OVER,  _onTextRollHandler );
        mainNoticeItemUI.addEventListener( MouseEvent.MOUSE_OUT,  _onTextRollHandler );

        return mainNoticeItemUI;
    }

    private function _onTextRollHandler( evt : MouseEvent ):void{
        var mainNoticeItemUI : MainNoticeItemUI = evt.currentTarget as MainNoticeItemUI;
        if( evt.type == MouseEvent.MOUSE_OVER || evt.type == MouseEvent.MOUSE_MOVE ){
            var turl : String = mainNoticeItemUI.txt_msg.textField.getTextFormat( mainNoticeItemUI.txt_msg.textField.getCharIndexAtPoint(
                    mainNoticeItemUI.txt_msg.textField.mouseX, mainNoticeItemUI.txt_msg.textField.mouseY ) ).url;
            if(turl){
                var ary : Array = turl.split(':');
                if( ary[1] == CMainNoticeConst.ITEM_NAME ){
                    mainNoticeItemUI.toolTip = new Handler( showTips, [mainNoticeItemUI] );
                }
            }else {
                App.tip.closeAll();
            }

        }else if( evt.type == MouseEvent.MOUSE_OUT ) {
            App.tip.closeAll();
        }
    }

    private function showTips(item:MainNoticeItemUI):void {
        _pItemSystem.addTips(CItemTipsView,item,[int( (item.dataSource as CMainNoticeData).contents[0])]);
    }
    private function onOpenPanelHandler():void{
        var pCMainNoticePanelViewHandler : CMainNoticePanelViewHandler = system.getBean( CMainNoticePanelViewHandler ) as CMainNoticePanelViewHandler;
        pCMainNoticePanelViewHandler.addDisplay();
    }
    private function onHideHandler( ...args):void{
        if((args[0] as DisplayObject).parent)
            (args[0] as DisplayObject).parent.removeChild(args[0]);
        if ( !parentCtn ) {
            callLater( addDisplaye, args[1] );
        }else{
            addDisplaye( args[1] );
        }
    }
    private function addDisplaye( disObj : DisplayObject ):void{
        if( parentCtn ){
            parentCtn.addChild( disObj );
            _isMsgDirty = true;
            unschedule( updateView );
            schedule( 2, updateView );//每2秒更新一次
        }

    }
    private function _onBgRollHandler(evt:MouseEvent):void{
        TweenLite.killTweensOf( m_noticeUI.bg ,true );
        if( evt.type == MouseEvent.ROLL_OUT ){
            TweenLite.to(m_noticeUI.bg,.5,{alpha:0});
        }else if( evt.type == MouseEvent.ROLL_OVER ){
            TweenLite.to(m_noticeUI.bg,.5,{alpha:0.7});
        }
    }
    private function replaceStr( string : String , ...param ) : String {
        for( var i:int = 0 ; i < param.length ; i ++ ) {
            string = string.replace( "{" + i + "}", param[i] );
        }
        return string;
    }

    private function _onResponse( evt : CMainNoticeEvent ):void{
        _isMsgDirty = true;

    }
    private function get parentCtn():Box{
        var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        if ( !pLobbyViewHandler.pMainUI )
            return null;
        var notice:Box = pLobbyViewHandler.pMainUI.getChildByName("infomation") as Box;
        return notice;
    }

    private function get _domain():CMainNoticeMessageList{
        return system.getBean( CMainNoticeMessageList ) as CMainNoticeMessageList;
    }
    private function get _pItemSystem():CItemSystem{
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }
}
}
