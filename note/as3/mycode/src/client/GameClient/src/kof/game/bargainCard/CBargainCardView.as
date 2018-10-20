//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/9/10.
 */
package kof.game.bargainCard {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CLogUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.talent.talentFacade.CTalentFacade;
import kof.table.CardMonthConfig;
import kof.table.PassiveSkillPro;
import kof.ui.CUISystem;
import kof.ui.master.BargainCard.BargainCardUI;


import morn.core.handlers.Handler;

public class CBargainCardView extends CTweenViewHandler {

    private var _bargainCardUI : BargainCardUI;
    private var _curData : *;
    private var _closeHandler:Handler;
    private var _closeBargainSystem : Function;
    private var _isOpen : Boolean;
    public function CBargainCardView() {
        super(false);
    }

    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _bargainCardUI = null;
    }
    override public function get viewClass() : Array {
        return [ BargainCardUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_bargainCardUI )
        {
            _bargainCardUI = new BargainCardUI();
            _bargainCardUI.btn_ok1.clickHandler = new Handler( _onCkHandler1 );
            _bargainCardUI.btn_ok2.clickHandler = new Handler( _onCkHandler2 );
            _bargainCardUI.closeHandler = new Handler( _onClose );
            _bargainCardUI.lb_silverTips.text = _manager.silverData.showinfo;
            _bargainCardUI.lb_goldTips.text = _manager.goldData.showinfo;
        }

        return true;
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
    public function get isOpen() : Boolean
    {
        return _isOpen;
    }
    private function _addToDisplay() : void {
        _isOpen = true;
        setTweenData(KOFSysTags.BARGAINCARD);
        showDialog(_bargainCardUI,false);
        updateView();
    }

    public function removeDisplay() : void {
        if ( _bargainCardUI ) {
            _bargainCardUI.remove();
        }
    }
    public function get closeHandler() : Handler {
        return _closeHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        _closeHandler = value;
    }
    private function _onClose( type : String ) : void {
        if ( this.closeHandler )
        {
            this.closeHandler.execute();
            _isOpen = false;
        }
        if(_closeBargainSystem)
            _closeBargainSystem();
    }
    private function _onCkHandler1():void
    {
        //当日白银月卡奖励领取状态 0未领取 1已领取
        if( _curData.silverCardRewardState ) {
            _pCUISystem.showMsgAlert( '当日贵族福利已经领取' );
        }else
        {
            if(_curData.silverCardState)
                _netHandler.onGetCardMonthRewardRequest( _manager.SILVER );
            else
            {
                //跳转充值界面
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
            }
        }

        CLogUtil.recordLinkLog(system, 10014);
    }
    private function _onCkHandler2():void
    {
        //当日黄金月卡奖励领取状态 0未领取 1已领取
        if( _curData.goldCardRewardState ){
            _pCUISystem.showMsgAlert('当日至尊福利已经领取');
        }else{
            if(_curData.goldCardState)
            {
                _netHandler.onGetCardMonthRewardRequest( _manager.GOLD );
            }
            else
            {
                //跳转充值界面
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
            }
        }

        CLogUtil.recordLinkLog(system, 10015);
    }

    public function updateView() : void
    {
        _curData = _manager.responseData;
        setViewInfoBySilver();
        setViewInfoByGold();
    }
    ///////////白银///////////////////////
    private function setViewInfoBySilver():void
    {
        if(!_curData || !_bargainCardUI) return;
        var cardMonthConfig : CardMonthConfig = _manager.silverData;
        var propertyData : CBasePropertyData = new CBasePropertyData();
        propertyData.databaseSystem = _pCDatabaseSystem;
        var passiveSkillPro : PassiveSkillPro = CTalentFacade.getInstance().getPassiveSkillProData( cardMonthConfig.propertyID[0] );

        _bargainCardUI.box_a_1.visible = _curData.silverCardState;
        _bargainCardUI.clip_1.visible = !_curData.silverCardState;
        _bargainCardUI.img_send1.visible = !_curData.silverCardState;
        _bargainCardUI.box_b_1.visible = !_curData.silverCardState;
        _bargainCardUI.btn_ok1.visible = !_curData.silverCardRewardState;

        if ( _curData.silverCardState )
        {
            _bargainCardUI.txt_getnum1.text = String( cardMonthConfig.everydayRewardNum );
            _bargainCardUI.txt_day1.text = String( _curData.silverCardRewardCounts );
            _bargainCardUI.txt_remainDay1.text = String( cardMonthConfig.continueTime - _curData.silverCardRewardCounts );
            _bargainCardUI.txt_totalCount1.text = String( cardMonthConfig.rewardNum + _curData.silverCardRewardCounts * cardMonthConfig.everydayRewardNum );
        }else
        {
            _bargainCardUI.txt_num1.text = String( cardMonthConfig.rewardNum );
            _bargainCardUI.txt_totalNum1.text = String( cardMonthConfig.everydayRewardNum );
            _bargainCardUI.txt_remainDay11.text = String( cardMonthConfig.continueTime );
        }

        _bargainCardUI.txt_title_1_1.text = passiveSkillPro.name;
        propertyData[passiveSkillPro.word] = cardMonthConfig.propertyValue[0];
        _bargainCardUI.txt_value_1_1.text = '+ ' +  cardMonthConfig.propertyValue[0];
        passiveSkillPro  = CTalentFacade.getInstance().getPassiveSkillProData( cardMonthConfig.propertyID[1] );
        _bargainCardUI.txt_title_1_2.text = passiveSkillPro.name;
        propertyData[passiveSkillPro.word] = cardMonthConfig.propertyValue[1];
        _bargainCardUI.txt_value_1_2.text = '+ ' +  cardMonthConfig.propertyValue[1];

        var status : int = _curData.silverCardState ? 2 : 3;
        _bargainCardUI.clip_1.dataSource = cardMonthConfig.rewardBagID;
        _bargainCardUI.clip_1.toolTip = new Handler( _itemSystem.showRewardTips, [_bargainCardUI.clip_1, ["开通白银月卡可获得", status, 1]]);

    }
    ///////////黄金///////////////////////
    private function setViewInfoByGold():void
    {
        if(!_curData || !_bargainCardUI) return;
        var cardMonthConfig : CardMonthConfig = _manager.goldData;
        var propertyData : CBasePropertyData = new CBasePropertyData();
        propertyData.databaseSystem = _pCDatabaseSystem;
        var passiveSkillPro : PassiveSkillPro = CTalentFacade.getInstance().getPassiveSkillProData( cardMonthConfig.propertyID[0] );

        _bargainCardUI.box_a_2.visible = _curData.goldCardState;
        _bargainCardUI.clip_2.visible = !_curData.goldCardState;
        _bargainCardUI.img_send2.visible = !_curData.goldCardState;
        _bargainCardUI.box_b_2.visible = !_curData.goldCardState;
        _bargainCardUI.btn_ok2.visible = !_curData.goldCardRewardState;

        if ( _curData.goldCardState ) {
            _bargainCardUI.txt_getnum2.text = String( cardMonthConfig.everydayRewardNum );
            _bargainCardUI.txt_day2.text = String( _curData.goldCardRewardCounts );
            _bargainCardUI.txt_remainDay2.text = String( cardMonthConfig.continueTime - _curData.goldCardRewardCounts );
            _bargainCardUI.txt_totalCount2.text = String( cardMonthConfig.rewardNum + _curData.goldCardRewardCounts * cardMonthConfig.everydayRewardNum );

        }else{
            _bargainCardUI.txt_num2.text = String( cardMonthConfig.rewardNum );
            _bargainCardUI.txt_totalNum2.text = String( cardMonthConfig.everydayRewardNum );
            _bargainCardUI.txt_remainDay22.text = String( cardMonthConfig.continueTime );
        }

        _bargainCardUI.txt_title_2_1.text = passiveSkillPro.name;
        propertyData[passiveSkillPro.word] = cardMonthConfig.propertyValue[0];
        _bargainCardUI.txt_value_2_1.text = '+ ' +  cardMonthConfig.propertyValue[0];
        passiveSkillPro  = CTalentFacade.getInstance().getPassiveSkillProData( cardMonthConfig.propertyID[1] );
        _bargainCardUI.txt_title_2_2.text = passiveSkillPro.name;
        propertyData[passiveSkillPro.word] = cardMonthConfig.propertyValue[1];
        _bargainCardUI.txt_value_2_2.text = '+ ' +  cardMonthConfig.propertyValue[1];

        var status : int =  _curData.silverCardState ? 2 : 3;
        _bargainCardUI.clip_2.dataSource = cardMonthConfig.rewardBagID;
        _bargainCardUI.clip_2.toolTip = new Handler( _itemSystem.showRewardTips, [_bargainCardUI.clip_2, ["开通黄金月卡可获得", status, 1]]);

    }

    public function set closeBargainSystemCB(fun : Function) : void
    {
        _closeBargainSystem = fun;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _itemSystem() : CItemSystem {
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }
    private function get _netHandler() : CBargainCardNetHandler
    {
        return system.getBean(CBargainCardNetHandler) as CBargainCardNetHandler;
    }
    private function get _manager() : CBargainCardManager
    {
        return system.getBean(CBargainCardManager) as CBargainCardManager;
    }
}
}
