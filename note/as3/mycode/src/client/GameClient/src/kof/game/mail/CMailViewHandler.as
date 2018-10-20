//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/15.
 */
package kof.game.mail {

import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.mail.data.CMailData;
import kof.game.systemnotice.CSystemNoticeConst;
import kof.ui.master.mail.MailItemUI;
import kof.ui.master.mail.MailUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CMailViewHandler extends CTweenViewHandler {

    private var m_mailUI : MailUI;

    private var m_pCloseHandler : Handler;

    private var _curCMailData : CMailData;

    private var m_viewExternal : CViewExternalUtil;

    private var m_bViewInitialized : Boolean;

    private var _curMailItemUI : MailItemUI;

    public function CMailViewHandler() {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        m_mailUI = null;
    }
    override public function get viewClass() : Array {
        return [ MailUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_mailUI ) {
                m_mailUI = new MailUI();
                m_mailUI.mainopen.btn_delAll.clickHandler = new Handler( _onDelAllHandler );
                m_mailUI.mainopen.btn_getAll.clickHandler = new Handler( _onGetAllHandler );
                m_mailUI.mainopen.btn_get.clickHandler = new Handler( _onGetHandler );
                m_mailUI.mainopen.list.renderHandler = new Handler( renderItem );
                m_mailUI.mainopen.list.selectHandler = new Handler( _selectItemHandler );
                m_mailUI.mainopen.list.dataSource = [];
                m_viewExternal = new CViewExternalUtil( CRewardItemListView, this, m_mailUI.mainopen);

                m_mailUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }


    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
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

    private function _addToDisplay() : void {
        setTweenData(KOFSysTags.MAIL);
        showDialog(m_mailUI, false, _addToDisplayB);
    }
    private function _addToDisplayB() : void {
        if ( m_mailUI ) {
            _pCMailManager.readTheFirstMailFlg = true;
            _addEventListeners();
            m_mailUI.mainno.visible = !Boolean( _pCMailManager.getMailList().length );
            m_mailUI.mainopen.visible = Boolean( _pCMailManager.getMailList().length );
            m_mailUI.mainopen.list.addEventListener( UIEvent.ITEM_RENDER, _onListChange );
            m_mailUI.mainopen.list.dataSource = _pCMailManager.getMailList();
        }
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_mailUI ) {
            _removeEventListeners();
            _curCMailData = null;
        }
    }

    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is MailItemUI) ) {
            return;
        }
        var pMailItemUI : MailItemUI = item as MailItemUI;
        var pCMailData : CMailData = pMailItemUI.dataSource as CMailData;
        if ( pCMailData ) {
            pMailItemUI.txt_title.text = pCMailData.name;
            pMailItemUI.txt_sendName.text = pCMailData.sent ;
            pMailItemUI.clip_state.index = pCMailData.state - 1;
            var date : Date = new Date( pCMailData.createTime );
            pMailItemUI.txt_time.text = date.fullYear + "/" + (date.month + 1) + "/" + date.date ;

        }
    }

    private function _selectItemHandler( index : int ) : void {
        if( index < m_mailUI.mainopen.list.startIndex || index > m_mailUI.mainopen.list.startIndex + m_mailUI.mainopen.list.repeatY ){
            _selectItemInfoHandler( _curCMailData );
            return;
        }
        var pMailItemUI : MailItemUI = m_mailUI.mainopen.list.getCell( index ) as MailItemUI;
        if( pMailItemUI && pMailItemUI.dataSource ){
            _selectItemInfoHandler( pMailItemUI.dataSource as CMailData );
            _onTxtColorHandler( pMailItemUI );
        }

    }
    private var _oldState : int;
    private var _oldUid : Number;
    private function _selectItemInfoHandler( pCMailData : CMailData ):void{
        if ( !pCMailData )
            return;
        m_mailUI.mainopen.box_got.visible =
                m_mailUI.mainopen.reward_list.visible =
                        m_mailUI.mainopen.btn_get.visible =
                                m_mailUI.mainopen.img_reward.visible =
                                        false;
        _curCMailData = pCMailData;
        if( _oldUid == _curCMailData.uid && ( _oldState == 3 || _oldState == 4 ) && _curCMailData.state == 5 ){//道具飞背包特效
            var len:int = m_mailUI.mainopen.reward_list.item_list.dataSource.length;
            for(var i:int = 0; i < len; i++)
            {
                var item:Component =  m_mailUI.mainopen.reward_list.item_list.getCell(i) as Component;
                CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
            }
        }

        _oldState = _curCMailData.state;
        _oldUid = _curCMailData.uid;
        m_mailUI.mainopen.txt_title.text = pCMailData.name;
        m_mailUI.mainopen.txt_sendName.text = pCMailData.sent;
        m_mailUI.mainopen.txt_content.text = pCMailData.content;
        m_mailUI.mainopen.txt_content.textField.height = m_mailUI.mainopen.txt_content.textField.textHeight + 10;
        var date : Date = new Date( pCMailData.expireTime );
        m_mailUI.mainopen.txt_time.text = '有效期：' + date.fullYear + "/" + (date.month + 1) + "/" + date.date;
        m_mailUI.mainopen.panel_txt.scrollTo();
        // 邮件状态
        //1 邮件没有附件，且邮件未阅读状态
        //2 邮件没有附件，且邮件已阅读状态
        //3 邮件有附件，且邮件未阅读状态
        //4 邮件有附件，附件未领取，邮件已阅读状态
        //5 邮件有附件，附件已领取，邮件已阅读状态

        if ( pCMailData.state == 3 || pCMailData.state == 4 || pCMailData.state == 5) {
            m_mailUI.mainopen.reward_list.visible =
                    m_mailUI.mainopen.img_reward.visible =
                            true;
            m_viewExternal.show();
            var rewardDataList : CRewardListData = CRewardUtil.createByList( (uiCanvas as CAppSystem).stage, pCMailData.attachs );
            m_viewExternal.setData( rewardDataList );
            m_viewExternal.updateWindow();
            m_mailUI.mainopen.box_got.visible = pCMailData.state == 5;
            m_mailUI.mainopen.btn_get.visible = pCMailData.state == 3 || pCMailData.state == 4;

            m_mailUI.mainopen.reward_list.item_list.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
            if(m_mailUI.mainopen.txt_content.textField.textHeight > 90)
            {
                m_mailUI.mainopen.panel_txt.height = 90;
            }
            else
            {
                m_mailUI.mainopen.panel_txt.height = 210;
            }
        }
        else//======add by Lune,修改文本显示域=====
        {
            m_mailUI.mainopen.panel_txt.height = 210;
        }
        _readMailHandler();
    }

    private function _onTxtColorHandler( pMailItemUI : MailItemUI ):void{
        var mailItemUI : MailItemUI;
        for each( mailItemUI in m_mailUI.mainopen.list.cells ){
            if( mailItemUI.dataSource ){
                mailItemUI.txt_sendName.text = "<font color='#a3b7d4'>" + mailItemUI.txt_sendName.textField.text + "</font>";
                mailItemUI.txt_time.text = "<font color='#a3b7d4'>" + mailItemUI.txt_time.textField.text + "</font>";
            }
        }
        pMailItemUI.txt_sendName.text = "<font color='#ffffff'>" + pMailItemUI.txt_sendName.textField.text + "</font>";
        pMailItemUI.txt_time.text = "<font color='#ffffff'>" + pMailItemUI.txt_time.textField.text + "</font>";
    }
    private function _onMailListUpdate( evt : CMailEvent = null ) : void {
        _pCMailManager.readTheFirstMailFlg = false;
        m_mailUI.mainno.visible = !Boolean( _pCMailManager.getMailList().length );
        m_mailUI.mainopen.visible = Boolean( _pCMailManager.getMailList().length );
        m_mailUI.mainopen.list.refresh();
//        m_mailUI.mainopen.list.scrollTo( m_mailUI.mainopen.list.selectedIndex );//如果不这样做，选中的在第一页，拉到下一页，就会报错
        m_mailUI.mainopen.list.callLater( _selectItemHandler,[m_mailUI.mainopen.list.selectedIndex]);
    }

    private function _onListChange( evt : UIEvent ) : void {
        m_mailUI.mainopen.list.removeEventListener( UIEvent.ITEM_RENDER, _onListChange );
        if( _pCMailManager.readTheFirstMailFlg ){
            m_mailUI.mainopen.list.scrollTo( 0 );
            m_mailUI.mainopen.list.selectedIndex = 0;
            m_mailUI.mainopen.list.callLater( _selectItemHandler ,[0] );
        }
    }

    private function _addEventListeners() : void {
        _removeEventListeners();
        system.addEventListener( CMailEvent.MAIL_UPDATE, _onMailListUpdate );
    }

    private function _removeEventListeners() : void {
        system.removeEventListener( CMailEvent.MAIL_UPDATE, _onMailListUpdate );
    }

    private function _readMailHandler() : void {
        if ( _curCMailData.state == 1 || _curCMailData.state == 3 ){
            pCMailHandler.onMailReadRequest( _curCMailData.uid );
        }
    }

    private function _onDelAllHandler() : void {
        pCMailHandler.onMailDeleteRequest();
    }

    private function _onGetAllHandler() : void {

        var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, _pCMailManager.getAllMainItem() );
        if(rewardListData)
        {
            (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
        }

        pCMailHandler.onMailAttachRecvRequest( 1 );
    }

    private function _onGetHandler() : void {
        pCMailHandler.onMailAttachRecvRequest( 0, _curCMailData.uid );
    }


    private function get pCMailHandler() : CMailHandler {
        return system.getBean( CMailHandler ) as CMailHandler;
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        if( _pCMailManager.hasNewMail || _pCMailManager.hasItemMail ){
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.NOTICE_ARGS,[CSystemNoticeConst.SYSTEM_MAIL]);
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
            }
        }

        _pCMailManager.readTheFirstMailFlg = false;
    }

    private function get _pCMailManager() : CMailManager {
        return system.getBean( CMailManager ) as CMailManager;
    }

}
}
