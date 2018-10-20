//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/26.
 * 俱乐部基金
 */
package kof.game.club.view {

import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubEvent;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubPath;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CSystemRuleUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.vip.CVIPManager;
import kof.game.vip.CVIPSystem;
import kof.table.ClubConstant;
import kof.table.ClubUpgradeBasic;
import kof.table.InvestConsumeReward;
import kof.ui.master.club.ClubFundActiveItemUI;
import kof.ui.master.club.ClubFundUI;

import morn.core.components.Dialog;

import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CClubFundViewHandler extends CViewHandler {

    private var _clubFundUI : ClubFundUI;

    private var _activeItemAry : Array;

    private var _playActiveAwardGetEff :Boolean;

    private var _requestActiveIndex : int = -1 ;

    private var _requestClubFundActiveItemUI : ClubFundActiveItemUI ;

    public static var TYPE_1 : int = 1; //金币投资
    public static var TYPE_2 : int = 2; //绑钻投资
    public static var TYPE_3 : int = 3; //钻石投资
    public function CClubFundViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ ClubFundUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_clubFundUI ){
            _clubFundUI = new ClubFundUI();
            _activeItemAry = [];
            initActiveViewHandler();
            _clubFundUI.closeHandler = new Handler( _onClose );

            _clubFundUI.btn_ok_1.clickHandler = new Handler( _onFundHandler, [_clubFundUI.btn_ok_1]);
            _clubFundUI.btn_ok_2.clickHandler = new Handler( _onFundHandler, [_clubFundUI.btn_ok_2]);
            _clubFundUI.btn_ok_3.clickHandler = new Handler( _onFundHandler, [_clubFundUI.btn_ok_3]);

            _clubFundUI.img_gold_1.toolTip =
                    _clubFundUI.img_gold_2.toolTip  =
                            _clubFundUI.img_gold_3.toolTip ="建设值\n可用于<font color='#53ff4a'>提升俱乐部等级</font>。";
            _clubFundUI.img_item_1.toolTip =
                    _clubFundUI.img_item_2.toolTip  =
                            _clubFundUI.img_item_3.toolTip  = "俱乐部积分\n可用于<font color='#53ff4a'>俱乐部商店</font>购买道具。";
//            _clubFundUI.img_item_1.toolTip =
//                    _clubFundUI.img_item_2.toolTip  =
//                            _clubFundUI.img_item_3.toolTip  = "俱乐部活跃值\n可用于领取俱乐部<font color='#53ff4a'>活跃值宝箱</font>。";

//            _clubFundUI.img_tips.toolTip = CClubConst.CLUBFUND_TIPS;
            CSystemRuleUtil.setRuleTips(_clubFundUI.img_tips, CLang.Get("club_build_rule"));
            CSystemRuleUtil.setRuleTips(_clubFundUI.active.img_tips, CLang.Get("club_active_rule"));

        }

        return Boolean( _clubFundUI );
    }

    override protected function get additionalAssets() : Array {
        return [
            "frameclip_task.swf"
        ];
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
        _addEventListeners();
        _pClubHandler.onOpenClubFundRequest();
    }
    public function removeDisplay() : void {
        if ( _clubFundUI ) {
            _clubFundUI.close( Dialog.CLOSE );
        }
        _investNote.removeDisplay();
    }
    private function _onFundHandler(...args):void{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTCONSUMEREWARD );
        var investConsumeReward : InvestConsumeReward ;
        var investType : int;
        var constDNum : int;
        if( args[0] == _clubFundUI.btn_ok_1 ){
            investConsumeReward =  pTable.findByPrimaryKey( TYPE_1 );
            uiCanvas.showMsgBox( '需要消耗' + int(_clubFundUI.txt_num_1.text) + '金币，确定继续吗？',okClubFund);
        }else if( args[0] == _clubFundUI.btn_ok_2 ){
            investConsumeReward =  pTable.findByPrimaryKey( TYPE_2 );
            constDNum = int(_clubFundUI.txt_num_2.text);
            uiCanvas.showMsgBox( '需要消耗' + constDNum + '绑钻，确定继续吗？',okFun,null,true,null,null,true,"COST_BIND_D");
        }else if( args[0] == _clubFundUI.btn_ok_3 ){
            investConsumeReward =  pTable.findByPrimaryKey( TYPE_3 );
            constDNum = int(_clubFundUI.txt_num_3.text);
            var total : int = _vipManager.getClubVIPInvestCount();//VIP可投资的次数
            var used : int = _pClubManager.selfClubFundData.vipInvestCounts ? _pClubManager.selfClubFundData.vipInvestCounts : 0;//已经投资次数
            if(used >= total)//提醒前往充值
            {
                _investNote.addDisplay(removeDisplay);
                return;
            }
            uiCanvas.showMsgBox( '需要消耗' + constDNum + '钻石，确定继续吗？',okClubFund,null,true,null,null,true,"COST_DIAMOND");
        }

        function okFun():void{
            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( constDNum, okClubFund );

            var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var diamond : int = playerSystem.playerData.currency.blueDiamond;
            var bindDiamond : int = playerSystem.playerData.currency.purpleDiamond;
            if ( constDNum > (diamond + bindDiamond))
            {
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
            }
        }

        function okClubFund():void{
            investType = investConsumeReward.type;
            _pClubHandler.onClubFundInvestmentRequest( investType );

            if(investType == TYPE_3)
            {
                var playerSystem2:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                var diamond2 : int = playerSystem2.playerData.currency.blueDiamond;
                var constDNum2:int = int(_clubFundUI.txt_num_3.text);
                if ( constDNum2 > diamond2)
                {
                    var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                    var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                    bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                }
            }
        }

    }
    private function initActiveViewHandler():void{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        var fundActiveAry : Array = clubConstant.getActiveRewardValue;

        var xLen : Number = ( _clubFundUI.active.pro.width / 100 ) * ( 100 / fundActiveAry[fundActiveAry.length - 1 ] );
        var fundActive : int;
        var clubFundActiveItemUI : ClubFundActiveItemUI;
        for each( fundActive in fundActiveAry ){
            clubFundActiveItemUI = new ClubFundActiveItemUI();
            clubFundActiveItemUI.box_eff.visible =
                    clubFundActiveItemUI.box_get.visible =
                            clubFundActiveItemUI.box_lock.visible =
                                    false;
            clubFundActiveItemUI.y = 15;
            clubFundActiveItemUI.x = _clubFundUI.active.pro.x + xLen * fundActive - clubFundActiveItemUI.width ;
            clubFundActiveItemUI.txt.text = String( fundActive );
            clubFundActiveItemUI.clip.dataSource = fundActiveAry.indexOf( fundActive );
            _clubFundUI.active.addChild( clubFundActiveItemUI );
            _activeItemAry.push( clubFundActiveItemUI );
//            clubFundActiveItemUI.toolTip = new Handler( showActiveItemTips, [clubFundActiveItemUI] );

        }
    }
    private function showActiveItemTips( item : ClubFundActiveItemUI ):void {
        _pClubFundActiveTipsHandler.addDisplay(item);
    }
    private function _onClubFundInfoResponseHandler( evt:CClubEvent ):void{
        if( !_pClubManager.selfClubFundData )
                return;
        var pTable : IDataTable;
        _clubFundUI.img_iocn.url = CClubPath.getBigClubIconUrByID( _pClubManager.selfClubData.clubSignID );
        _clubFundUI.txt_name.text = _pClubManager.selfClubFundData.name;
        _clubFundUI.txt_lv.text = _pClubManager.selfClubFundData.level + '级';
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        _clubFundUI.txt_num.text = '投资次数：' + _pClubManager.selfClubFundData.fundInvestCounts + '/' + clubConstant.everydayInvestTimes;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        var clubUpgradeBasic : ClubUpgradeBasic =  pTable.findByPrimaryKey( _pClubManager.clubLevel );
        _clubFundUI.pro.value = int(( _pClubManager.selfClubFundData.fund/clubUpgradeBasic.upgradeExp)*100)/100;
        _clubFundUI.txt_pro.text = _pClubManager.selfClubFundData.fund + "/" + clubUpgradeBasic.upgradeExp;

        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.INVESTCONSUMEREWARD );
        var investConsumeReward : InvestConsumeReward ;
        var i : int;
        for( i = 1 ; i <= 3 ; i++ ){
            investConsumeReward =  pTable.findByPrimaryKey( i );
            fundItemData( i , investConsumeReward );
        }
        _clubFundUI.active.pro.value = int(( _pClubManager.selfClubFundData.activeValue/clubConstant.getActiveRewardValue[clubConstant.getActiveRewardValue.length - 1])*100)/100;
        _clubFundUI.active.txt_active.text = String( _pClubManager.selfClubFundData.activeValue );
        _clubFundUI.active.box_pro.visible = _clubFundUI.active.pro.value > 0;
        if( _clubFundUI.active.box_pro.visible )
            _clubFundUI.active.box_pro.x = 210 + _clubFundUI.active.pro.value * 570 - _clubFundUI.active.box_pro.width;


        if( _requestActiveIndex == -1 ){
            _onclubFundActiveItemUIHandler(null);
        }else{
            var getActiveRewardSign : int = _pClubManager.selfClubFundData.getActiveRewardSign[_requestActiveIndex];
            if( getActiveRewardSign == CClubConst.GOT_FUND_ACTIVE ){
                _playActiveAwardGetEff = true;
                _requestActiveIndex = -1;
                onPlayActiveAwardGetEff( _requestClubFundActiveItemUI );
            }
        }

        _onclubFundActiveItemUIHandler();
        _onBuffTips();
        if( !_clubFundUI.parent )
            uiCanvas.addPopupDialog( _clubFundUI );

        var total : int = _vipManager.getClubVIPInvestCount();//VIP可投资的次数
        var used : int = _pClubManager.selfClubFundData.vipInvestCounts ? _pClubManager.selfClubFundData.vipInvestCounts : 0;//已经投资次数
        if(total > 0)
        {
            var leftCount : String = total - used > 0?"<font color='#00ff00'>" + String(total - used) + "</font>":"<font color='#ff0000'>" + String(total - used) + "</font>";
            _clubFundUI.txt_vipCount.text = "剩余投资次数：" + leftCount;
        }
        else
        {
            _clubFundUI.txt_vipCount.text = "VIP等级不足无法投资";
        }
    }
    private function fundItemData( index : int, investConsumeReward : InvestConsumeReward ):void{
        _clubFundUI['txt_' + index + '_1' ].text = String( investConsumeReward.fundValue );
        _clubFundUI['txt_' + index + '_2' ].text = String( investConsumeReward.clubPoints );
//        _clubFundUI['txt_' + index + '_3' ].text = String( investConsumeReward.activeValue );
        _clubFundUI['txt_num_' + index ].text = String( investConsumeReward.consumption );
        _clubFundUI['clip_vip_' + index ].visible =
                _clubFundUI['clip_vip_bg_' + index ].visible =
                        investConsumeReward.vipLevelLimit > 0 ;
        if(  _clubFundUI['clip_vip_' + index ].visible )
            _clubFundUI['clip_vip_' + index ].index = investConsumeReward.vipLevelLimit ;
    }

    private function _onActiveItemCkHandler( evt :MouseEvent ):void{
        if( _playActiveAwardGetEff )
            return;
        _requestClubFundActiveItemUI = evt.currentTarget as ClubFundActiveItemUI;
        _requestActiveIndex = int(_requestClubFundActiveItemUI.clip.dataSource);
        _pClubHandler.onGetClubActiveRewardRequest( _requestActiveIndex  );
    }
    private function _onclubFundActiveItemUIHandler( evt : CClubEvent = null):void{
        var activeIndex : int ;
        var clubFundActiveItemUI  : ClubFundActiveItemUI;
        var getActiveRewardSign : int;
        var pTable : IDataTable;
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        var clubUpgradeBasic : ClubUpgradeBasic =  pTable.findByPrimaryKey( _pClubManager.clubLevel );
        for each(  clubFundActiveItemUI  in _activeItemAry ){
            activeIndex = int( clubFundActiveItemUI.clip.dataSource );
            getActiveRewardSign  = _pClubManager.selfClubFundData.getActiveRewardSign[activeIndex];
            if( getActiveRewardSign == CClubConst.GOT_FUND_ACTIVE  ){
                clubFundActiveItemUI.clip.index = 2;//已领取
                clubFundActiveItemUI.box_eff.visible =
                    clubFundActiveItemUI.box_get.visible =
                            clubFundActiveItemUI.box_lock.visible =
                                            false;
            }else if( _pClubManager.selfClubFundData.activeValue >= clubConstant.getActiveRewardValue[activeIndex] ){
                clubFundActiveItemUI.clip.index = 1;//达到
                clubFundActiveItemUI.box_eff.visible = true;
                clubFundActiveItemUI.box_get.visible =
                        clubFundActiveItemUI.box_lock.visible =
                                false;
            }else{
                clubFundActiveItemUI.clip.index = 0;//未达到
                clubFundActiveItemUI.box_eff.visible =
                        clubFundActiveItemUI.box_get.visible =
                                clubFundActiveItemUI.box_lock.visible =
                                        false;
            }
            var status : int;
            getActiveRewardSign = _pClubManager.selfClubFundData.getActiveRewardSign[activeIndex];
            if( getActiveRewardSign == CClubConst.GOT_FUND_ACTIVE ){
                status = 2;
            }else if( _pClubManager.selfClubFundData.activeValue >= clubConstant.getActiveRewardValue[activeIndex] ){
                status = 1;
            }else{
                status = 3;
            }
            clubFundActiveItemUI.dataSource = clubUpgradeBasic.activeValueReward[activeIndex];
            clubFundActiveItemUI.toolTip = new Handler( _itemSystem.showRewardTips, [clubFundActiveItemUI, ["建设值达" + clubConstant.getActiveRewardValue[activeIndex] + "可领", status, 1]]);
        }
    }

    private function onPlayActiveAwardGetEff( clubFundActiveItemUI : ClubFundActiveItemUI ):void{
        clubFundActiveItemUI.clip.index = 1;
        stopeff();
        clubFundActiveItemUI.frameclip_get.addEventListener(UIEvent.FRAME_CHANGED,onChanged );
        clubFundActiveItemUI.box_get.visible = true;
        clubFundActiveItemUI.box_eff.visible = false;
        clubFundActiveItemUI.frameclip_get.gotoAndPlay(0);

        function onChanged(evt:UIEvent):void{
            if ( clubFundActiveItemUI.frameclip_get.frame >= clubFundActiveItemUI.frameclip_get.totalFrame - 1 ) {
                stopeff();
                _playActiveAwardGetEff = false;
                clubFundActiveItemUI.clip.index = 2;
            }
        }
        function stopeff():void{
            clubFundActiveItemUI.frameclip_get.removeEventListener( UIEvent.FRAME_CHANGED, onChanged );
            clubFundActiveItemUI.frameclip_get.stop();
            clubFundActiveItemUI.box_get.visible = false;
        }

        var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, int( clubFundActiveItemUI.dataSource ));
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull( rewardListData );

    }
    private function _onBuffTips():void{
        var clubUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel( _pClubManager.clubLevel );
        var nextUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel( _pClubManager.clubLevel + 1 );
        if(nextUpgradeBasic)
        {
            _clubFundUI.box_buff.toolTip =
                    "<font color='#FFA500'>----" + _pClubManager.clubLevel + "级俱乐部buff----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + clubUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + clubUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + clubUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "\n" +
                    "<font color='#FFA500'>----下一级属性预览----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + nextUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + nextUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + nextUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "<font color='#FFA500'>----buff对全员生效----</font>";
        }
        else
        {
            _clubFundUI.box_buff.toolTip = "<font color='#FFA500'>----" + _pClubManager.clubLevel + "级俱乐部buff----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + clubUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + clubUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + clubUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "\n" +
                    "<font color='#FFA500'>已达到最高俱乐部等级\n</font>" +
                    "<font color='#FFA500'>----buff对全员生效----</font>";
        }
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        system.addEventListener( CClubEvent.OPEN_CLUB_FUND_RESPONSE ,_onClubFundInfoResponseHandler );
        for each( var clubFundActiveItemUI : ClubFundActiveItemUI in _activeItemAry ){
            clubFundActiveItemUI.addEventListener( MouseEvent.CLICK, _onActiveItemCkHandler , false, 0, true);
        }
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CClubEvent.OPEN_CLUB_FUND_RESPONSE ,_onClubFundInfoResponseHandler );
        if( _clubFundUI ){
            for each( var clubFundActiveItemUI : ClubFundActiveItemUI in _activeItemAry ){
                clubFundActiveItemUI.removeEventListener( MouseEvent.CLICK, _onActiveItemCkHandler );
            }
        }
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                break;
        }
        _removeEventListeners();
        _playActiveAwardGetEff = false;
        _requestActiveIndex = -1;
    }

    private function get _pClubHandler(): CClubHandler{
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubFundActiveTipsHandler(): CClubFundActiveTipsHandler{
        return system.getBean( CClubFundActiveTipsHandler ) as CClubFundActiveTipsHandler;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _itemSystem() : CItemSystem {
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }
    private function get _investNote() : CClubInvestNoteView
    {
        return system.getBean( CClubInvestNoteView ) as CClubInvestNoteView;
    }
    private function get _vipManager() : CVIPManager
    {
        var _vipSystem : CVIPSystem =  system.stage.getSystem(CVIPSystem) as CVIPSystem;
        return _vipSystem.getBean(CVIPManager) as CVIPManager;
    }
}
}
