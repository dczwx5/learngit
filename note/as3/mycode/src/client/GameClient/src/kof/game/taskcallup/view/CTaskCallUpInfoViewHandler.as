//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/19.
 */
package kof.game.taskcallup.view {

import QFLib.Foundation.CTime;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.taskcallup.CTaskCallUpEvent;
import kof.game.taskcallup.CTaskCallUpHandler;
import kof.game.taskcallup.CTaskCallUpManager;
import kof.game.taskcallup.data.CCallUpAcceptedData;
import kof.game.taskcallup.data.CTaskCallUpConst;
import kof.table.CallUpConstant;
import kof.table.HeroQualityAddition;
import kof.table.HeroStarAddition;
import kof.table.PlayerBasic;
import kof.table.TeamAddition;
import kof.table.TeamLevelAddition;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RoleDetailsUI;
import kof.ui.master.taskcallup.TaskCallUpInfoUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.List;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CTaskCallUpInfoViewHandler extends CViewHandler {

    private var _taskCallUpInfoUI : TaskCallUpInfoUI;

    private var m_pCloseHandler : Handler;

    private var _pCallUpAcceptedData : CCallUpAcceptedData;

    private var m_viewExternal:CViewExternalUtil;

    public function CTaskCallUpInfoViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _taskCallUpInfoUI = null;
    }
    override public function get viewClass() : Array {
        return [ TaskCallUpInfoUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_taskCallUpInfoUI ) {
            _taskCallUpInfoUI = new TaskCallUpInfoUI();

            _taskCallUpInfoUI.list.renderHandler = new Handler( renderItem );
            _taskCallUpInfoUI.list.dataSource = [];

            _taskCallUpInfoUI.btn_cancle.clickHandler = new Handler( _onCancelHandler );
            _taskCallUpInfoUI.btn_quick.clickHandler = new Handler( _onQuickHandler );

            _taskCallUpInfoUI.closeHandler = new Handler( _onClose );
        }

        return _taskCallUpInfoUI;
    }


    private function renderItem(item:Component, idx:int):void {
        if (!(item is RoleDetailsUI)) {
            return;
        }
        var roleDetailsUI:RoleDetailsUI = item as RoleDetailsUI;
        if( roleDetailsUI.dataSource ){
            var playerHeroData : CPlayerHeroData = _playerData.heroList.getHero( int( roleDetailsUI.dataSource ) );

            roleDetailsUI.star_list.visible = false;
            roleDetailsUI.quality_list.visible = false;
            roleDetailsUI.level_label.visible = false;
            roleDetailsUI.state_clip.visible = false;
            roleDetailsUI.bar.visible = false;

            roleDetailsUI.icon_img.cacheAsBitmap = true;
            roleDetailsUI.hero_icon_mask.cacheAsBitmap = true;
            roleDetailsUI.icon_img.mask = roleDetailsUI.hero_icon_mask;
            roleDetailsUI.icon_img.url = CPlayerPath.getUIHeroIconBigPath(playerHeroData.ID);
        }
    }

    private function _onCancelHandler():void{
        var pTable : IDataTable  = _pCDatabaseSystem.getTable( KOFTableConstants.CALLUPCONSTANT );
        var callUpConstant : CallUpConstant = pTable.findByPrimaryKey( 1 );
        if( callUpConstant.cancel > 0  && _pTaskCallUpManager.cancel >=  callUpConstant.cancel ) {
            _pCUISystem.showMsgAlert('当日取消次数已用完');
            return;
        }
        var str : String = '取消当前召集不会获得该召集奖励，消耗召集次数将会返还，确定取消召集？';
        _pCUISystem.showMsgBox( str , onConfire );
        function onConfire():void{
            _pTaskCallUpHandler.onCancelTaskCallUpRequest( _pCallUpAcceptedData.taskId );
        }
    }
    private function _onQuickHandler():void{
//        if( _playerData.currency.purpleDiamond < _pCallUpAcceptedData.taskCallUp.speedUpMoney &&
//                _playerData.currency.blueDiamond < _pCallUpAcceptedData.taskCallUp.speedUpMoney &&
//                ( _playerData.currency.purpleDiamond + _playerData.currency.blueDiamond ) < _pCallUpAcceptedData.taskCallUp.speedUpMoney){
//            _pCUISystem.showMsgAlert('很抱歉，您的绑钻不足，无法加速完成。');
//            return;
//        }
//        var str : String = '加速将消耗绑钻石*' + _pCallUpAcceptedData.taskCallUp.speedUpMoney + '，确定加速？';
//        _pCUISystem.showMsgBox( str , onConfire );
//        function onConfire():void{
//            _pTaskCallUpHandler.onQuicklyFinishCallUpRequest( _pCallUpAcceptedData.taskId );
//        }

        _pCUISystem.showMsgBox( '需要消耗' + _pCallUpAcceptedData.taskCallUp.speedUpMoney + '绑钻，确定继续吗？',okFun,null,true,null,null,true,"COST_BIND_D" );
        function okFun():void{
            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).showCostBdDiamondMsgBox( _pCallUpAcceptedData.taskCallUp.speedUpMoney, onConfire );

            var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var haveDiamond : int = playerSystem.playerData.currency.purpleDiamond + playerSystem.playerData.currency.blueDiamond;
            var cost:int = _pCallUpAcceptedData.taskCallUp.speedUpMoney;
            //钻石跟绑钻都不足的时候，弹出充值界面
            if(cost > haveDiamond){
                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                (system.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert("很抱歉，您的钻石不足，请前往获得");
            }
        }
        function onConfire():void{
            _pTaskCallUpHandler.onQuicklyFinishCallUpRequest( _pCallUpAcceptedData.taskId );
        }
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay( pCallUpAcceptedData : CCallUpAcceptedData ) : void {

        _pCallUpAcceptedData = pCallUpAcceptedData;

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
        if ( _taskCallUpInfoUI ) {

            _taskCallUpInfoUI.list.addEventListener( UIEvent.ITEM_RENDER, _onListChange );
            _taskCallUpInfoUI.list.dataSource = _pCallUpAcceptedData.heros;

            _taskCallUpInfoUI.img_add1.visible = _taskCallUpInfoUI.img_add2.visible = false;

            m_viewExternal = new CViewExternalUtil(CRewardItemListView, this, _taskCallUpInfoUI);
            var item_list : List = (m_viewExternal.view as CRewardItemListView).uiView.item_list;
            item_list.addEventListener( UIEvent.ITEM_RENDER, _onListChangeII );
            m_viewExternal.show();
            m_viewExternal.setData( _pCallUpAcceptedData.taskCallUp.reward );
            m_viewExternal.updateWindow();

            _taskCallUpInfoUI.txt_num.text = String( _pCallUpAcceptedData.taskCallUp.speedUpMoney );
            if( !_taskCallUpInfoUI.parent ){
                unschedule( _onRefreshTime );
                schedule( 1 , _onRefreshTime );
            }

            _txtAddValueHandler();
            _onRefreshTime(0);

            uiCanvas.addDialog( _taskCallUpInfoUI );
            _addEventListeners();

        }

    }

    public function removeDisplay() : void {
        if ( _taskCallUpInfoUI ) {
            _taskCallUpInfoUI.close( Dialog.CLOSE );

        }
    }
    private function _onListChange( evt : UIEvent ):void {
        var roleDetailsUI:RoleDetailsUI;
        var num : int;
        for each( roleDetailsUI in _taskCallUpInfoUI.list.cells ){
           if( roleDetailsUI.dataSource )
               num ++ ;
        }
        if( num == 1){
            _taskCallUpInfoUI.list.x = 133;
        }else if( num == 2 ){
            _taskCallUpInfoUI.list.x = 67;
        }else if( num == 3 ){
            _taskCallUpInfoUI.list.x = 10;
        }
    }
    private function _onListChangeII( evt : UIEvent ):void{
        if( _pCallUpAcceptedData.taskCallUp.type == CTaskCallUpConst.TEAM_TYPE ){
            var item_list : List = evt.currentTarget as List;
            var rewardItem : RewardItemUI;
            var rewardData : CRewardData;
            for each ( rewardItem in item_list.cells ){
                rewardData = rewardItem.dataSource as  CRewardData;
                if( rewardData && ( rewardData.data.ID == 13 || rewardData.data.ID == 1  ) ){//神器能量和金币，显示‘加成’，策划说写死
                    if( rewardData.data.ID == 13 && !_taskCallUpInfoUI.img_add1.visible ){
                        _taskCallUpInfoUI.img_add1.visible = true;
                        _taskCallUpInfoUI.img_add1.x = 107;
                    }else if( rewardData.data.ID == 1 && !_taskCallUpInfoUI.img_add2.visible ){
                        _taskCallUpInfoUI.img_add2.visible = true;
                        _taskCallUpInfoUI.img_add2.x = 167;
                    }
                }
            }
        }
    }
    private function _txtAddValueHandler():void{
        _taskCallUpInfoUI.box_txt.visible = _pCallUpAcceptedData.taskCallUp.type ==  CTaskCallUpConst.TEAM_TYPE;
        if( !_taskCallUpInfoUI.box_txt.visible )
                return;

        //队伍评级
        var totalNum : int;
        var pTable : IDataTable ;
        var heroQualityAddition : HeroQualityAddition;
        var heroStarAddition : HeroStarAddition;
        var playerHeroData : CPlayerHeroData;
        var playerBasic : PlayerBasic;
        var heroId:int;
        for each(  heroId  in _pCallUpAcceptedData.heros ) {
            playerHeroData  = _playerData.heroList.getHero( heroId );
            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_BASIC );
            playerBasic = pTable.findByPrimaryKey( playerHeroData.ID );

            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.HEROQUALITYADDITION );
            var totalAry : Array = pTable.toArray();
            for each ( var heroQualityAdditionT : HeroQualityAddition  in totalAry ){
                if( heroQualityAdditionT.quality == playerBasic.intelligence ){
                    heroQualityAddition = heroQualityAdditionT;
                    break;
                }
            }

            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.HEROSTARADDITION );
            heroStarAddition = pTable.findByPrimaryKey( playerHeroData.star );

            totalNum += heroQualityAddition.addition * heroStarAddition.addition;
        }

        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.TEAMLEVELADDITION );
        var teamLevelAdditionAry : Array = pTable.toArray();
        var teamLevelAddition : TeamLevelAddition;
        var curLevelAddition : TeamLevelAddition;
        teamLevelAdditionAry.sortOn('ID',Array.NUMERIC);
        for each( teamLevelAddition in teamLevelAdditionAry ){
            if( totalNum >= teamLevelAddition.score ){
                curLevelAddition = teamLevelAddition;
                break;
            }
        }
        if( curLevelAddition ){
            var add : int = int(( curLevelAddition.addition / 10000 )* 100 ) ;
            _taskCallUpInfoUI.txt_0.text = curLevelAddition.level + '( ' + add + '%收益加成 )';
        }
        //队伍加成
        pTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_BASIC );
        var isSameTeam : Boolean = true;
        var teamID : int ;
        for each(  heroId  in _pCallUpAcceptedData.heros ) {
            playerHeroData  = _playerData.heroList.getHero( heroId );
            playerBasic = pTable.findByPrimaryKey( playerHeroData.ID );
            if( teamID > 0 && playerBasic.teamID != teamID ){
                isSameTeam = false;
                break;
            }
            teamID = playerBasic.teamID;
        }
        if( isSameTeam ){
//            pTable = _pCDatabaseSystem.getTable( KOFTableConstants.TEAMADDITION );
//            var teamAddition : TeamAddition = pTable.findByPrimaryKey( playerBasic.teamID );
            var teamAddition : TeamAddition = _pTaskCallUpManager.getTeamAdditionByTeamID( playerBasic.teamID );
            var value:int = int(( teamAddition.addition / 10000 )* 100 ) ;
            _taskCallUpInfoUI.txt_1.text = '( ' + value + '%收益加成 )';
        }else{
            _taskCallUpInfoUI.txt_1.text = '( 0%收益加成 )';
        }

    }
    private function _onRefreshTime( delta : Number ):void{
        if( _pCallUpAcceptedData.endTime - CTime.getCurrServerTimestamp() <= 0 ){
            _taskCallUpInfoUI.txt_time.text = '00:00:00';
            _taskCallUpInfoUI.pro.value = 1;
            unschedule( _onRefreshTime );
            _taskCallUpInfoUI.close( Dialog.CLOSE );
            return;
        }
        _taskCallUpInfoUI.txt_time.text = CTime.toDurTimeString( _pCallUpAcceptedData.endTime - CTime.getCurrServerTimestamp() ) + ' 后完成';
        var lessTime : int = int((_pCallUpAcceptedData.endTime - CTime.getCurrServerTimestamp())/1000);
        var timeValue:Number = int(( lessTime/(_pCallUpAcceptedData.taskCallUp.time * 60 ))*100)/100;
        _taskCallUpInfoUI.pro.value = 1 - timeValue;
    }
    private function _onTaskCallUpCancelResponseHandler( evt : CTaskCallUpEvent ):void{
        _taskCallUpInfoUI.close( Dialog.CLOSE );
    }
    private function _addEventListeners():void {
        _removeEventListeners();
        system.addEventListener( CTaskCallUpEvent.CANCEL_TASK_CALLUP_RESPONSE, _onTaskCallUpCancelResponseHandler );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CTaskCallUpEvent.CANCEL_TASK_CALLUP_RESPONSE, _onTaskCallUpCancelResponseHandler );
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
        unschedule( _onRefreshTime );
    }

    private function get _pTaskCallUpHandler():CTaskCallUpHandler{
        return system.getBean( CTaskCallUpHandler ) as CTaskCallUpHandler;
    }
    private function get _pTaskCallUpManager():CTaskCallUpManager{
        return system.getBean( CTaskCallUpManager ) as CTaskCallUpManager;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }


}
}
