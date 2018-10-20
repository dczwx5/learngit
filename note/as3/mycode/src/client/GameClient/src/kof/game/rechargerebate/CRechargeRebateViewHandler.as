//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2018/1/4.
 */
package kof.game.rechargerebate {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.Tutorial.CTutorSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.CLogUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.message.RechargeRebate.ReceiveRebateRewardResponse;
import kof.message.RechargeRebate.RechargeRebateInfoResponse;
import kof.table.RechargeRebate;
import kof.ui.CUISystem;
import kof.ui.master.RechargeRebate.RechargeRebateUI;

import morn.core.components.Box;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CRechargeRebateViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_rechargeRebateUI : RechargeRebateUI;

    private var m_pCloseHandler : Handler;

    private var _mask : Sprite;

    public function CRechargeRebateViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        m_rechargeRebateUI = null;
    }
    override public function get viewClass() : Array {
        return [ RechargeRebateUI ];
    }
    override protected function get additionalAssets() : Array {
        return [
            "RechargeRebate.swf","frameclip_rebat.swf"
        ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_rechargeRebateUI ) {
                m_rechargeRebateUI = new RechargeRebateUI();
                _mask = new Sprite();
                _mask.graphics.beginFill(0xCCFF00);
                _mask.graphics.drawRect(0, 0, 100, 100);
                _mask.alpha = 0;

                m_rechargeRebateUI.closeHandler = new Handler( _onClose );
                m_rechargeRebateUI.btn_recharge.clickHandler = new Handler( _onRecharge );
                m_rechargeRebateUI.img_role.url = "icon/role/big/role_106.png";
                for( var index : int = 1 ; index <= 6 ; index ++ ){
                    m_rechargeRebateUI['box_item_' + index].addEventListener( MouseEvent.CLICK, _onItemCkHandler );
                }
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
        _addEventListeners();
        _pRechargeRebateHandler.onRechargeRebateInfoRequest();
    }
    public function removeDisplay() : void {
        _onRemoveMask();
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_rechargeRebateUI ) {
            _removeEventListeners();
        }
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        _removeEventListeners();
    }

    private function _onRecharge():void{
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);

        CLogUtil.recordLinkLog(system, 10021);
    }
    //打开界面初始数据返回
    private function _onInitDataHandler( evt : CRechargeRebateEvent ):void{
        _onShowExpView();
        if ( m_rechargeRebateUI && ! m_rechargeRebateUI.parent ) {
//            uiCanvas.addDialog( m_rechargeRebateUI );
            setTweenData(KOFSysTags.RECHARGEREBATE);
            showDialog(m_rechargeRebateUI);


        }
    }

    private function _onShowExpView():void{
        var blueDiamondExp : int = _pRechargeRebateManager.blueDiamondExp;
        var index : int ;
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.RECHARGEREBATE );
        var rechargeRebate : RechargeRebate ;
        var obj : Object;
        var proValue : Number;
        for( index = 1 ; index <= 6 ; index ++ ){
            rechargeRebate = pTable.findByPrimaryKey( index );
            m_rechargeRebateUI['box_item_' + index].dataSource = rechargeRebate;
            m_rechargeRebateUI['txt_dNum_' + index ].text = String( rechargeRebate.chestReward );
            obj = _pRechargeRebateManager.getRewardObjById( index );
            if( obj ){
                m_rechargeRebateUI['img_got_' + index ].visible = true;
                m_rechargeRebateUI['img_gotPro_' + index ].visible = true;
                m_rechargeRebateUI['img_full_' + index ].visible = false;
                m_rechargeRebateUI['clip_effLight_I_' + index ].visible = false;
                m_rechargeRebateUI['clip_effLight_II_' + index ].visible = false;
                m_rechargeRebateUI['clip_'+ index ].index = 2;
                proValue = -1;
                m_rechargeRebateUI['txt_pro_' + index ].text = "<font color='#16d04b'>已领取</font>";
            } else {
                m_rechargeRebateUI['img_got_' + index ].visible = false;
                m_rechargeRebateUI['img_gotPro_' + index ].visible = false;
                if( blueDiamondExp >= rechargeRebate.blueDiamondExp ){
                    proValue = 1;
                    m_rechargeRebateUI['img_full_' + index ].visible = true;
                    m_rechargeRebateUI['clip_effLight_I_' + index ].visible = true;
                    m_rechargeRebateUI['clip_effLight_II_' + index ].visible = true;
                    m_rechargeRebateUI['clip_'+ index ].index = 1;
                    m_rechargeRebateUI['txt_pro_' + index ].text = "<font color='#16d04b'>" + blueDiamondExp + "/"
                            + rechargeRebate.blueDiamondExp + "</font>" ;
                }else{
                    proValue = Math.ceil(( blueDiamondExp/rechargeRebate.blueDiamondExp)*100)/100;
                    m_rechargeRebateUI['img_full_' + index ].visible = false;
                    m_rechargeRebateUI['clip_effLight_I_' + index ].visible = false;
                    m_rechargeRebateUI['clip_effLight_II_' + index ].visible = false;
                    m_rechargeRebateUI['clip_'+ index ].index = 0;
                    m_rechargeRebateUI['txt_pro_' + index ].text = "<font color='#cccccc'>" + blueDiamondExp + "/"
                             + rechargeRebate.blueDiamondExp + "</font>" ;
                }
            }
            m_rechargeRebateUI['pro_' + index ].value = proValue;
            m_rechargeRebateUI['pro_' + index ].visible = proValue > 0;
            m_rechargeRebateUI['img_proTop_' + index ].visible =
                    m_rechargeRebateUI['clip_proTop_' + index ].visible  = proValue > 0 && proValue < 1;
            if( m_rechargeRebateUI['img_proTop_' + index ].visible ){
                m_rechargeRebateUI['img_proTop_' + index ].y = m_rechargeRebateUI['pro_' + index ].y -
                        m_rechargeRebateUI['pro_' + index ].width * proValue - m_rechargeRebateUI['img_proTop_' + index ].height;
                m_rechargeRebateUI['clip_proTop_' + index ].y = m_rechargeRebateUI['img_proTop_' + index ].y;
            }
        }
    }

    //充值范钻宝箱领取请求
    private function _onItemCkHandler( evt : MouseEvent ):void{
        var rechargeRebate : RechargeRebate = ( evt.currentTarget as Box ).dataSource as RechargeRebate;
        if( _pRechargeRebateManager.getRewardObjById( rechargeRebate.ID ) ){
            _pCUISystem.showMsgAlert('很抱歉，该宝箱已经领取');
            return;
        }else if( _pRechargeRebateManager.blueDiamondExp < rechargeRebate.blueDiamondExp){
            _pCUISystem.showMsgAlert('很抱歉，该宝箱尚未能领取');
            return;
        }
        _pRechargeRebateHandler.onReceiveRebateRewardRequest( rechargeRebate.chestNumber );

    }

    //充值范钻宝箱领取返回
    private function _onGetAwardHandler( evt : CRechargeRebateEvent ):void {
        var response : ReceiveRebateRewardResponse = evt.data as ReceiveRebateRewardResponse;
        _onShowExpView();

        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.RECHARGEREBATE );
        var rechargeRebate : RechargeRebate = pTable.findByPrimaryKey( response.chestNumber );
        var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, [{ID:3,num:rechargeRebate.chestReward}]);
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull( rewardListData );
    }
    //钻石数量发生变化
    private function _updateMoneyData( evt : CPlayerEvent ) : void {
        _pRechargeRebateHandler.onRechargeRebateInfoRequest();
    }

    private function _onAddToStage( evt : Event ):void{
        if( !_pCTutorSystem.isPlaying )
                return;
        _mask.width = system.stage.flashStage.stageWidth  + 1000;
        _mask.height = system.stage.flashStage.stageHeight + 1000;
        _mask.x = _mask.y = -500;
        m_rechargeRebateUI.addChildAt( _mask, 0  );
    }
    private function _onRemoveMask():void{
        if( _mask && _mask.parent )
            _mask.parent.removeChild( _mask );
    }

    private function _addEventListeners():void {
        _removeEventListeners();
        system.addEventListener( CRechargeRebateEvent.SHOW_RECHARGE_REBATE_VIEW, _onInitDataHandler );
        system.addEventListener( CRechargeRebateEvent.RECEIVE_REBATE_REWARD_RESPONSE, _onGetAwardHandler );
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateMoneyData);
        m_rechargeRebateUI.addEventListener( Event.ADDED_TO_STAGE, _onAddToStage );
        system.stage.flashStage.addEventListener( Event.RESIZE,_onAddToStage );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CRechargeRebateEvent.SHOW_RECHARGE_REBATE_VIEW, _onInitDataHandler );
        system.removeEventListener( CRechargeRebateEvent.RECEIVE_REBATE_REWARD_RESPONSE, _onGetAwardHandler );
        _playerSystem.removeEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateMoneyData);
        m_rechargeRebateUI.removeEventListener( Event.ADDED_TO_STAGE, _onAddToStage );
        system.stage.flashStage.removeEventListener( Event.RESIZE,_onAddToStage );
    }

    private function get _pRechargeRebateHandler():CRechargeRebateHandler{
        return system.getBean( CRechargeRebateHandler ) as CRechargeRebateHandler;
    }
    private function get _pRechargeRebateManager():CRechargeRebateManager{
        return system.getBean( CRechargeRebateManager ) as CRechargeRebateManager;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCTutorSystem() : CTutorSystem {
        return system.stage.getSystem( CTutorSystem ) as CTutorSystem;
    }

    public function get rechargeRebateUI() : RechargeRebateUI {
        return m_rechargeRebateUI;
    }
}
}
