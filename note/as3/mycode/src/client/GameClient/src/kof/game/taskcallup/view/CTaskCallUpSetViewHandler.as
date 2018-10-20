//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/19.
 */
package kof.game.taskcallup.view {

import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.common.view.CViewExternalUtil;
import kof.game.item.data.CRewardData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.taskcallup.CTaskCallUpEvent;
import kof.game.taskcallup.CTaskCallUpHandler;
import kof.game.taskcallup.CTaskCallUpManager;
import kof.game.taskcallup.data.CCallUpListData;
import kof.game.taskcallup.data.CTaskCallUpConst;
import kof.table.CoupleRelationship;
import kof.table.HeroQualityAddition;
import kof.table.HeroStarAddition;
import kof.table.PlayerBasic;
import kof.table.TeamAddition;
import kof.table.TeamLevelAddition;
import kof.ui.CUISystem;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.taskcallup.TaskCallUpHeroItemUI;
import kof.ui.master.taskcallup.TaskCallUpSetIIUI;
import kof.ui.master.taskcallup.TaskCallUpSetItemIIUI;
import kof.ui.master.taskcallup.TaskCallUpSetItemUI;
import kof.ui.master.taskcallup.TaskCallUpSetUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.List;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CTaskCallUpSetViewHandler extends CViewHandler {

    private var _taskCallUpSetUI : TaskCallUpSetIIUI;

    private var m_pCloseHandler : Handler;

    private var _callUpListData : CCallUpListData;

    private var _selectedAry : Array ;

    private var m_viewExternal:CViewExternalUtil;

    private var _womenAry : Array;

    public function CTaskCallUpSetViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _taskCallUpSetUI = null;
        _selectedAry = null;
    }
    override public function get viewClass() : Array {
        return [ TaskCallUpSetUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "frameclip_juesebk.swf"
        ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_taskCallUpSetUI ) {
            _taskCallUpSetUI = new TaskCallUpSetIIUI();

            _taskCallUpSetUI.list_hero.addEventListener( UIEvent.ITEM_RENDER, onListHeroChange );
            _taskCallUpSetUI.list_hero.renderHandler = new Handler( renderItem_hero );
            _taskCallUpSetUI.list_hero.selectHandler = new Handler( selectHeroItemHandler );
            _taskCallUpSetUI.list_hero.dataSource = [];

            _taskCallUpSetUI.list.renderHandler = new Handler( renderItem );
            _taskCallUpSetUI.list.selectHandler = new Handler( selectItemHandler );
            _taskCallUpSetUI.list.dataSource = [];

            _selectedAry = [];

            _taskCallUpSetUI.closeHandler = new Handler( _onClose );
            _taskCallUpSetUI.btn_ok.clickHandler = new Handler( _onAcceptHandler  );
            _taskCallUpSetUI.btn_best.clickHandler = new Handler( _onBestCkHandler );
            _taskCallUpSetUI.btn_best.visible = false;
        }

        return _taskCallUpSetUI;
    }

    private function onListHeroChange( evt : UIEvent ):void{
        var taskCallUpHeroItemUI : TaskCallUpHeroItemUI = evt.data[0] as TaskCallUpHeroItemUI;
        taskCallUpHeroItemUI.box_effbg.visible = false;
//        if( _callUpListData.taskCallUp.type == CTaskCallUpConst.LOVE_TYPE ){
//            if( taskCallUpHeroItemUI.dataSource ){
//                taskCallUpHeroItemUI.box_effbg.visible = isMakeItemTipsEff( taskCallUpHeroItemUI.dataSource as CPlayerHeroData );
//            }
//        }
    }


    //右边英雄列表
    private function renderItem_hero(item:Component, idx:int):void {
        if (!(item is TaskCallUpHeroItemUI)) {
            return;
        }
        var taskCallUpHeroItemUI:TaskCallUpHeroItemUI = item as TaskCallUpHeroItemUI;
        if( taskCallUpHeroItemUI.dataSource ){
            var playerHeroData : CPlayerHeroData = taskCallUpHeroItemUI.dataSource as CPlayerHeroData;

//            taskCallUpHeroItemUI.star_list.dataSource = new Array(playerHeroData.star);
            taskCallUpHeroItemUI.clip_quality.index = playerHeroData.qualityBaseType;
//            taskCallUpHeroItemUI.clip_type.index = playerHeroData.job;
            taskCallUpHeroItemUI.clip_state.visible = false;
            taskCallUpHeroItemUI.clip_type.visible = false;
            taskCallUpHeroItemUI.star_list.visible = false;


            taskCallUpHeroItemUI.icon_image.cacheAsBitmap = true;
            taskCallUpHeroItemUI.hero_icon_mask.cacheAsBitmap = true;
            taskCallUpHeroItemUI.icon_image.mask = taskCallUpHeroItemUI.hero_icon_mask;
            taskCallUpHeroItemUI.icon_image.url = CPlayerPath.getHeroBigconPath(playerHeroData.ID);

            taskCallUpHeroItemUI.icon_image.disabled = _pTaskCallUpManager.usedHeroList.indexOf( playerHeroData.ID) != -1;

            if( taskCallUpHeroItemUI.icon_image.disabled ){
                var usingHeroList : Array = _pTaskCallUpManager.getAcceptedCallUpHeros();
                if( usingHeroList.indexOf( playerHeroData.ID ) != -1 )
                    taskCallUpHeroItemUI.clip_state.index = 1;
                else
                    taskCallUpHeroItemUI.clip_state.index = 0;
                taskCallUpHeroItemUI.clip_state.visible = true;
            }

            if( _selectedAry.indexOf( taskCallUpHeroItemUI.dataSource ) != -1 ){
                taskCallUpHeroItemUI.clip_state.index = 2;
                taskCallUpHeroItemUI.clip_state.visible = true;
            }

        }
    }
    private function selectHeroItemHandler( index : int ) : void {
        var taskCallUpHeroItemUI : TaskCallUpHeroItemUI ;
        taskCallUpHeroItemUI = _taskCallUpSetUI.list_hero.getCell( index ) as TaskCallUpHeroItemUI;
        if ( !taskCallUpHeroItemUI || !taskCallUpHeroItemUI.dataSource)
            return;
        _selectedHandler( taskCallUpHeroItemUI.dataSource as CPlayerHeroData,CTaskCallUpConst.UP_TYPE  );

        _taskCallUpSetUI.list_hero.refresh();
        _taskCallUpSetUI.list_hero.selectedIndex = -1;

    }
    private function isMakeItemTipsEff( playerHeroData :  CPlayerHeroData ):Boolean{
        if( freeTotalPositionNum == 1 ){
//            var upPlayerHeroData : CPlayerHeroData  = ( _taskCallUpSetUI.list.getCell( firstUpPosition ) as TaskCallUpSetItemUI).dataSource as CPlayerHeroData;
            var upPlayerHeroData : CPlayerHeroData = _taskCallUpSetUI.list.dataSource[firstUpPosition] as CPlayerHeroData;
            if( upPlayerHeroData.ID != playerHeroData.ID && _judgeHandler( upPlayerHeroData, playerHeroData ) )
                return true;
            else
                return false;
        }
        return false;
    }
    //上阵的英雄
    private function renderItem(item:Component, idx:int):void {
        if (!(item is TaskCallUpSetItemIIUI)) {
            return;
        }
        var taskCallUpSetItemUI:TaskCallUpSetItemIIUI = item as TaskCallUpSetItemIIUI;
        if( taskCallUpSetItemUI.dataSource == ''){
            taskCallUpSetItemUI.img.url = '';
            taskCallUpSetItemUI.txt_name.text = '';
            taskCallUpSetItemUI.img_free.visible = true;
        }else if( taskCallUpSetItemUI.dataSource is CPlayerHeroData ){
            taskCallUpSetItemUI.img.url = CPlayerPath.getPeakUIHeroFacePath( (taskCallUpSetItemUI.dataSource as CPlayerHeroData).ID );
            taskCallUpSetItemUI.txt_name.text = (taskCallUpSetItemUI.dataSource as CPlayerHeroData).heroNameWithColor;
            taskCallUpSetItemUI.img_free.visible = false;
        }
    }
    private function selectItemHandler( index : int ) : void {
        var taskCallUpSetItemUI : TaskCallUpSetItemIIUI = _taskCallUpSetUI.list.getCell( index ) as TaskCallUpSetItemIIUI;
        if ( !taskCallUpSetItemUI || !taskCallUpSetItemUI.dataSource ){
            _taskCallUpSetUI.list.selectedIndex = -1;
            return;
        }
        if( taskCallUpSetItemUI.dataSource is CPlayerHeroData )
            _selectedHandler( taskCallUpSetItemUI.dataSource as CPlayerHeroData,CTaskCallUpConst.DOWN_TYPE  );

        _taskCallUpSetUI.list_hero.refresh();
        _taskCallUpSetUI.list.selectedIndex = -1;

    }

    //选择英雄操作
    private function _selectedHandler( playerHeroData : CPlayerHeroData ,type : int ):void{
        var heroList : Array;
        var playerHeroDatas : CPlayerHeroData;
        var jobAry : Array;
        if( type == CTaskCallUpConst.UP_TYPE ){
            if( isHeroUp(playerHeroData ) ){
                _pCUISystem.showMsgAlert('该格斗家已上阵');
                return;
            }
            if( getUpHeroNum >= _callUpListData.taskCallUp.num ){
                _pCUISystem.showMsgAlert('上阵人数已满');
                return;
            }
            if( _pTaskCallUpManager.usedHeroList.indexOf( playerHeroData.ID) != -1 ){
                _pCUISystem.showMsgAlert('该格斗家当天已经使用过');
                return;
            }
            if( freeTotalPositionNum == _selectedAry.length ){//还没有人上阵
                if( _callUpListData.taskCallUp.type == CTaskCallUpConst.SINGLE_TYPE || _callUpListData.taskCallUp.type == CTaskCallUpConst.WOMEN_TYPE ){
                    if( _judgeHandler( null , playerHeroData )){
                        _selectedAry[0] = playerHeroData;
                    }else{
                        _pCUISystem.showMsgAlert('该格斗家不符合任务条件要求');
                    }
                } else{
                    _selectedAry[0] = playerHeroData;
                    if( _callUpListData.taskCallUp.type == CTaskCallUpConst.LOVE_TYPE ){
                        heroList  = _playerData.heroList.list.slice( 0, _playerData.heroList.list.length );
                        var loveAry : Array = [];
                        for each( playerHeroDatas in heroList ){
                            if( isMakeItemTipsEff( playerHeroDatas )){
                                loveAry.push( playerHeroDatas );
                            }
                        }
                        _taskCallUpSetUI.list_hero.dataSource = loveAry.sort( sortHeroList );
                    } else if( _callUpListData.taskCallUp.type == CTaskCallUpConst.JOB_TYPE  ){
                        heroList  = _playerData.heroList.list.slice( 0, _playerData.heroList.list.length );
                        jobAry  = [];
                        for each( playerHeroDatas in heroList ){
                            if( _judgeHandler( playerHeroData, playerHeroDatas )){
                                jobAry.push( playerHeroDatas );
                            }
                        }
                        _taskCallUpSetUI.list_hero.dataSource = jobAry.sort( sortHeroList );
                    }
                }
            } else{//已有人上阵
                if( _judgeHandler( _selectedAry[firstUpPosition], playerHeroData ) ){
                    _selectedAry[ firstFreePosition ] = playerHeroData;
                    if( _callUpListData.taskCallUp.type == CTaskCallUpConst.LOVE_TYPE ){
                        _taskCallUpSetUI.list_hero.dataSource = [];
                    }
                }else {
                    _pCUISystem.showMsgAlert('该格斗家不符合任务条件要求');
                }
            }

        }else if( type == CTaskCallUpConst.DOWN_TYPE ){
            var index : int = _selectedAry.indexOf( playerHeroData );
            if( index != -1 ){
                _selectedAry[index] = '';
                if( _callUpListData.taskCallUp.type == CTaskCallUpConst.LOVE_TYPE ){
                    if( ( _selectedAry[0] &&  _selectedAry[0] is CPlayerHeroData ) || ( _selectedAry[1] &&  _selectedAry[1] is CPlayerHeroData ) ){
                        heroList  = _playerData.heroList.list.slice( 0, _playerData.heroList.list.length );
                        var loveArr : Array = [];
                        for each( playerHeroDatas in heroList ){
                            if( isMakeItemTipsEff( playerHeroDatas )){
                                loveArr.push( playerHeroDatas );
                            }
                        }
                        _taskCallUpSetUI.list_hero.dataSource = loveArr.sort( sortHeroList );
                    }else{
                        heroList  = _playerData.heroList.list.slice( 0, _playerData.heroList.list.length );
                        _taskCallUpSetUI.list_hero.dataSource = heroList.sort( sortHeroList );
                    }
                }else if( _callUpListData.taskCallUp.type == CTaskCallUpConst.WOMEN_TYPE ){

                }else if( _callUpListData.taskCallUp.type == CTaskCallUpConst.JOB_TYPE  ){
                    if( getUpHeroNum == 0 ){
                        heroList  = _playerData.heroList.list.slice( 0, _playerData.heroList.list.length );
                        _taskCallUpSetUI.list_hero.dataSource = heroList.sort( sortHeroList );
                    }else if(  getUpHeroNum == 1){
                        heroList  = _playerData.heroList.list.slice( 0, _playerData.heroList.list.length );
                        jobAry  = [];
                        for each( playerHeroDatas in heroList ){
                            if( _judgeHandler( _selectedAry[firstUpPosition], playerHeroDatas )){
                                jobAry.push( playerHeroDatas );
                            }
                        }
                        _taskCallUpSetUI.list_hero.dataSource = jobAry.sort( sortHeroList );
                    }
                }
            }

        }

        _taskCallUpSetUI.list.dataSource = _selectedAry;
        _onStateHandler();


    }
    //判断是否符合规则
    private function _judgeHandler( upPlayerHeroData : CPlayerHeroData = null ,judgePlayerHeroData : CPlayerHeroData = null ):Boolean{
        var pTable : IDataTable ;
        var upPlayerBasic : PlayerBasic ;
        var judgePlayerBasic : PlayerBasic ;
        switch( _callUpListData.taskCallUp.type ){
            case CTaskCallUpConst.TEAM_TYPE:{
//                pTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_BASIC );
//                upPlayerBasic = pTable.findByPrimaryKey( upPlayerHeroData.ID );
//                judgePlayerBasic = pTable.findByPrimaryKey( judgePlayerHeroData.ID );
//                if( upPlayerBasic.teamID == judgePlayerBasic.teamID )
                return true;
                break;
            }
            case CTaskCallUpConst.LOVE_TYPE:{
                pTable = _pCDatabaseSystem.getTable( KOFTableConstants.COUPLERELATIONSHIP );
                var allAry : Array = pTable.toArray();
                var coupleRelationship : CoupleRelationship;
                var heroAry : Array;
                for each( coupleRelationship in allAry ){
                    heroAry = coupleRelationship.heroId;
                    if( heroAry.indexOf( upPlayerHeroData.ID) != -1 && heroAry.indexOf( judgePlayerHeroData.ID) != -1 )
                            return true;
                }
                break;
            }
            case CTaskCallUpConst.SINGLE_TYPE:{
                if( _callUpListData.taskCallUp.fixedHero == 0){
                    return true;
                }else if( _callUpListData.taskCallUp.fixedHero > 0 && judgePlayerHeroData.ID == _callUpListData.taskCallUp.fixedHero ){
                    return true;
                }
                break;
            }
            case CTaskCallUpConst.JOB_TYPE:{
                pTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_BASIC );
                upPlayerBasic = pTable.findByPrimaryKey( upPlayerHeroData.ID );
                judgePlayerBasic = pTable.findByPrimaryKey( judgePlayerHeroData.ID );
                if( upPlayerBasic.Profession == judgePlayerBasic.Profession )
                    return true;
                break;
            }
            case CTaskCallUpConst.WOMEN_TYPE:{
                pTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_BASIC );
                judgePlayerBasic = pTable.findByPrimaryKey( judgePlayerHeroData.ID );
                if( judgePlayerBasic.gender == 2 )
                    return true;
                break;
            }
            case CTaskCallUpConst.CLUB_TYPE:{
                return true;
                break;
            }
        }

        return false;
    }
    private function _onStateHandler():void{
        var pTable : IDataTable ;
        var playerHeroData : CPlayerHeroData;
        switch( _callUpListData.taskCallUp.type ){
            case CTaskCallUpConst.TEAM_TYPE:{

                var value:int;
                var add : int;
                if( getUpHeroNum < _selectedAry.length ){
                    _taskCallUpSetUI.txt_team_0.text = '?'
                    _taskCallUpSetUI.txt_team_1.text = '( 0%收益加成 )';
                    _taskCallUpSetUI.txt_team_2.text = '( 0%收益加成 )';
                    value = add = 0;
                }else{
                    //队伍评级
                    var totalNum : int;
                    var heroQualityAddition : HeroQualityAddition;
                    var heroStarAddition : HeroStarAddition;

                    for each( playerHeroData in _selectedAry ) {
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
                        var star : int = playerHeroData.star;
                        if( star >= 7 )
                            star = 7;
                        heroStarAddition = pTable.findByPrimaryKey( star );

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
                        add = int(( curLevelAddition.addition / 10000 )* 100 ) ;
                        _taskCallUpSetUI.txt_team_0.text = String( curLevelAddition.level );
                        _taskCallUpSetUI.txt_team_1.text =  '( ' + add + '%收益加成 )';
                    }
                    //队伍加成
                    pTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_BASIC );
                    var playerBasic : PlayerBasic;
                    var isSameTeam : Boolean = true;
                    var teamID : int ;
                    for each( playerHeroData in _selectedAry ){
                        playerBasic = pTable.findByPrimaryKey( playerHeroData.ID );
                        if( teamID > 0 && playerBasic.teamID != teamID ){
                            isSameTeam = false;
                            break;
                        }
                        teamID = playerBasic.teamID;
                    }

                   if( isSameTeam ){
                       pTable = _pCDatabaseSystem.getTable( KOFTableConstants.TEAMADDITION );
//                       var teamAddition : TeamAddition = pTable.findByPrimaryKey( playerBasic.teamID );
                       var teamAddition : TeamAddition = _pTaskCallUpManager.getTeamAdditionByTeamID( playerBasic.teamID );
                       value = int(( teamAddition.addition / 10000 )* 100 ) ;
                       _taskCallUpSetUI.txt_team_2.text = '( ' + value + '%收益加成 )';
                   }else{
                       value = 0;
                       _taskCallUpSetUI.txt_team_2.text = '( 0%收益加成 )';
                   }
                }
                _onShowAwardHandler( add + value );
                break;
            }
            case CTaskCallUpConst.LOVE_TYPE:{
                break;
            }
            case CTaskCallUpConst.SINGLE_TYPE:{
                break;
            }
            case CTaskCallUpConst.JOB_TYPE:{
                break;
            }
            case CTaskCallUpConst.WOMEN_TYPE:{
                break;
            }
            case CTaskCallUpConst.CLUB_TYPE:{
                break;
            }
        }
    }
    //英雄是否已经上阵
    private function isHeroUp( playerHeroData : CPlayerHeroData ):Boolean{
        for each( var obj : Object in _selectedAry ) {
            if ( obj is CPlayerHeroData && obj == playerHeroData ){
                return true;
            }
        }
        return false;
    }
    //已上阵英雄数量
    private function get getUpHeroNum() : int{
        var num : int;
        for each( var obj : Object in _selectedAry ){
            if( obj is CPlayerHeroData )
                num++;
        }
        return num;
    }
    //已上阵英雄ID数组
    private function get getUpHeroIDAry() : Array{
        var ary : Array = [];
        for each( var obj : Object in _selectedAry ){
            if( obj is CPlayerHeroData )
                ary.push( (obj as CPlayerHeroData).ID );
        }
        return ary;
    }
    //阵容空位数量
    private function get freeTotalPositionNum() : int {
        var num : int;
        for each( var obj : Object in _selectedAry ){
            if( !(obj is CPlayerHeroData) )
                num++;
        }
        return num;
    }
    //第一个已有上阵英雄位
    private function get firstUpPosition() : int{
        if( freeTotalPositionNum >= _selectedAry.length )
                return -1;
        var position : int;
        var obj : Object;
        for( var index : int = 0 ; index < _selectedAry.length ; index ++ ){
            obj = _selectedAry[index];
            if( obj is CPlayerHeroData ){
                position = index;
                break;
            }
        }
        return position;
    }
    //第一个空位
    private function get firstFreePosition() : int{
        if( freeTotalPositionNum <= 0 )
                return -1;
        var position : int;
        var obj : Object;
        for( var index : int = 0 ; index < _selectedAry.length ; index ++ ){
            obj = _selectedAry[index];
            if( !(obj is CPlayerHeroData) ){
                position = index;
                break;
            }
        }
        return position;
    }
   ///展示加成
    private var _awardAdd : int;
    private function _onShowAwardHandler( awardAdd : int = 0):void{
        _awardAdd = awardAdd;
        _taskCallUpSetUI.img_add1.visible = _taskCallUpSetUI.img_add2.visible = false;
        m_viewExternal = new CViewExternalUtil( CRewardItemListView, this, _taskCallUpSetUI );
        var item_list : List = (m_viewExternal.view as CRewardItemListView).uiView.item_list;
        item_list.addEventListener( UIEvent.ITEM_RENDER, _onListChange );
        m_viewExternal.show();
        ( m_viewExternal.view as CRewardItemListView ).forceAlign = 1;
        ( m_viewExternal.view as CRewardItemListView ).updateLayout();
        m_viewExternal.setData( _callUpListData.taskCallUp.reward );
        m_viewExternal.updateWindow();
    }
    private function _onListChange( evt : UIEvent ):void{
        var item_list : List = evt.currentTarget as List;
        var rewardItem : RewardItemUI;
        var rewardData : CRewardData;
        for each ( rewardItem in item_list.cells ){
            rewardData = rewardItem.dataSource as  CRewardData;
            if( rewardData && ( rewardData.data.ID == 13 || rewardData.data.ID == 1  ) ){//神器能量和金币，显示‘加成’，策划说写死
                rewardData.num = Math.floor( rewardData.num * ( 100 + _awardAdd ) / 100 );
                if( _callUpListData.taskCallUp.type == CTaskCallUpConst.TEAM_TYPE ){
                    if( rewardData.data.ID == 13 && !_taskCallUpSetUI.img_add1.visible ){
                        _taskCallUpSetUI.img_add1.visible = true;
//                        taskCallUpItemUI.img_add1.x = p2.x + 5;
                        _taskCallUpSetUI.img_add1.x = 98;
                    }else if( rewardData.data.ID == 1 && !_taskCallUpSetUI.img_add2.visible ){
                        _taskCallUpSetUI.img_add2.visible = true;
//                        taskCallUpItemUI.img_add2.x = p2.x + 5;
                        _taskCallUpSetUI.img_add2.x = 158;
                    }
                }
            }

        }
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay( callUpListData : CCallUpListData ) : void {
        _callUpListData = callUpListData;

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
        if ( _taskCallUpSetUI ) {
            var heroList : Array  = _playerData.heroList.list.slice( 0, _playerData.heroList.list.length );
            var playerHeroData : CPlayerHeroData;
            if( _callUpListData.taskCallUp.type == CTaskCallUpConst.SINGLE_TYPE ) {
                if( _callUpListData.taskCallUp.fixedHero > 0 ){
                    var hasHero:Boolean = _playerData.heroList.hasHero( _callUpListData.taskCallUp.fixedHero );
                    if( hasHero ) {
                        _onHeroListHandler( [_playerData.heroList.getHero( _callUpListData.taskCallUp.fixedHero )] );
                    }else{
                        _onHeroListHandler( [] );
                    }

                }else{
                    _onHeroListHandler( heroList.sort( sortHeroList ) );
                }

            }else if( _callUpListData.taskCallUp.type == CTaskCallUpConst.WOMEN_TYPE ){
                var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_BASIC );
                _womenAry = [];
                var playerBasic : PlayerBasic;
                for each( playerHeroData in heroList ){
                    playerBasic = pTable.findByPrimaryKey( playerHeroData.ID );
                    if( playerBasic.gender == 2 ){
                        _womenAry.push( playerHeroData );
                    }
                }
                _onHeroListHandler( _womenAry.sort( sortHeroList ) );
            }else{
                _onHeroListHandler( heroList.sort( sortHeroList ) );
            }
            _onUpdateTxtHandler();
            _onStateHandler();
            _onShowAwardHandler();
            uiCanvas.addDialog( _taskCallUpSetUI );
            _addEventListeners();
        }
    }
    private function sortHeroList( a : CPlayerHeroData , b : CPlayerHeroData ) : int{
        var usedHeroList : Array = _pTaskCallUpManager.usedHeroList;
        var usingHeroList : Array = _pTaskCallUpManager.getAcceptedCallUpHeros();
        if( usedHeroList.indexOf( a.ID ) == -1 && usedHeroList.indexOf( b.ID ) != -1 ){
            return -1;
        }else if( usedHeroList.indexOf( a.ID ) != -1 && usedHeroList.indexOf( b.ID ) == -1 ){
            return 1;
        }else{
            if( usingHeroList.indexOf( a.ID ) == -1 && usingHeroList.indexOf( b.ID ) != -1 ){
                return 1
            }else if( usingHeroList.indexOf( a.ID ) != -1 && usingHeroList.indexOf( b.ID ) == -1 ){
                return -1;
            }else{
                if( a.qualityBaseType >  b.qualityBaseType ){
                    return -1;
                }else if( a.qualityBaseType <  b.qualityBaseType ){
                    return 1;
                }else{
                    return 0;
                }
            }
        }
    }
    private function _onHeroListHandler( list : Array ):void{
        _taskCallUpSetUI.list_hero.dataSource = list;
        _selectedAry.splice( 0 , _selectedAry.length );
        for( var index : int = 0 ; index < _callUpListData.taskCallUp.num ; index ++ ){
            _selectedAry.push('');
        }
        _taskCallUpSetUI.list.dataSource = _selectedAry;
        if( _selectedAry.length == 1){
            _taskCallUpSetUI.list.x = 190;
        }else if( _selectedAry.length == 2 ){
            _taskCallUpSetUI.list.x = 100;
        }else if( _selectedAry.length == 3 ){
            _taskCallUpSetUI.list.x = 3;
        }
    }

    public function removeDisplay() : void {
        if ( _taskCallUpSetUI ) {
            _taskCallUpSetUI.close( Dialog.CLOSE );

        }
    }
    private function _onBestCkHandler( ):void{
        _pCUISystem.showMsgAlert('待完成')
    }
    private function _onTeamCkHandler( evt : MouseEvent ):void{
        if( _callUpListData.taskCallUp.type == CTaskCallUpConst.TEAM_TYPE )
            _pTaskCallUpTeamViewHandler.addDisplay();
    }
    private function _onLoveCkHandler( evt : MouseEvent ):void{
        if( _callUpListData.taskCallUp.type == CTaskCallUpConst.LOVE_TYPE )
            _pTaskCallUpLoveViewHandler.addDisplay();
    }
    private function _onUpdateTxtHandler():void{
        switch( _callUpListData.taskCallUp.type ){
            case CTaskCallUpConst.TEAM_TYPE:{
                _taskCallUpSetUI.box_team.visible = true;
                _taskCallUpSetUI.box_love.visible = _taskCallUpSetUI.txt_tips.visible = false;

                _taskCallUpSetUI.txt_team_lv.toolTip = '队伍评级由派出格斗家的资质与星级决定，资质与星级越高，队伍评级越高。';

                break;
            }
            case CTaskCallUpConst.LOVE_TYPE:{
                _taskCallUpSetUI.box_love.visible = true;
                _taskCallUpSetUI.box_team.visible = _taskCallUpSetUI.txt_tips.visible = false;

                break;
            }
            case CTaskCallUpConst.SINGLE_TYPE:{
                _taskCallUpSetUI.box_team.visible = _taskCallUpSetUI.box_love.visible = false;
                _taskCallUpSetUI.txt_tips.visible = _callUpListData.taskCallUp.fixedHero > 0 ;
                if( _callUpListData.taskCallUp.fixedHero > 0 ){
                    var playerHeroData : CPlayerHeroData = _playerData.heroList.getHero( _callUpListData.taskCallUp.fixedHero );
                    _taskCallUpSetUI.txt_tips.text = '需要派出格斗家' + playerHeroData.heroNameWithColor;
                }
                break;
            }
            case CTaskCallUpConst.JOB_TYPE:{
                _taskCallUpSetUI.txt_tips.visible = true;
                _taskCallUpSetUI.box_team.visible = _taskCallUpSetUI.box_love.visible = false;
                _taskCallUpSetUI.txt_tips.text = '需要派出职业相同的格斗家';
                break;
            }
            case CTaskCallUpConst.WOMEN_TYPE:{
                _taskCallUpSetUI.txt_tips.visible = true;
                _taskCallUpSetUI.box_team.visible = _taskCallUpSetUI.box_love.visible = false;
                _taskCallUpSetUI.txt_tips.text = '需要派出女孩子格斗家';
                break;
            }
            case CTaskCallUpConst.CLUB_TYPE:{
                _taskCallUpSetUI.txt_tips.visible = _taskCallUpSetUI.box_team.visible = _taskCallUpSetUI.box_love.visible = false;
                break;
            }
        }
    }
    private function _onAcceptHandler():void{
        if( getUpHeroNum < _callUpListData.taskCallUp.num ){
            _pCUISystem.showMsgAlert('请放入正确数量格斗家。');
            return;
        }
        _pTaskCallUpHandler.onAcceptTaskCallUpRequest( _callUpListData.taskId ,getUpHeroIDAry);
    }
    private function _onTaskCallUpAcceptedResponseHandler( evt : CTaskCallUpEvent ):void{
        _taskCallUpSetUI.close( Dialog.CLOSE );
    }
    private function _addEventListeners():void {
        _removeEventListeners();
        system.addEventListener( CTaskCallUpEvent.ACCEPT_TASK_CALLUP_RESPONSE, _onTaskCallUpAcceptedResponseHandler );
        if( _taskCallUpSetUI ){
            _taskCallUpSetUI.txt_team_add.addEventListener( MouseEvent.CLICK, _onTeamCkHandler, false, 0, true);
            _taskCallUpSetUI.txt_lovet.addEventListener( MouseEvent.CLICK, _onLoveCkHandler, false, 0, true);
        }
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CTaskCallUpEvent.ACCEPT_TASK_CALLUP_RESPONSE, _onTaskCallUpAcceptedResponseHandler );
        if( _taskCallUpSetUI ){
            _taskCallUpSetUI.txt_team_add.removeEventListener( MouseEvent.CLICK,_onTeamCkHandler );
            _taskCallUpSetUI.txt_lovet.removeEventListener( MouseEvent.CLICK,_onLoveCkHandler );
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

    private function get _pTaskCallUpHandler():CTaskCallUpHandler{
        return system.getBean( CTaskCallUpHandler ) as CTaskCallUpHandler;
    }
    private function get _pTaskCallUpManager():CTaskCallUpManager{
        return system.getBean( CTaskCallUpManager ) as CTaskCallUpManager;
    }
    private function get _pTaskCallUpLoveViewHandler():CTaskCallUpLoveViewHandler{
        return system.getBean( CTaskCallUpLoveViewHandler ) as CTaskCallUpLoveViewHandler;
    }
    private function get _pTaskCallUpTeamViewHandler():CTaskCallUpTeamViewHandler{
        return system.getBean( CTaskCallUpTeamViewHandler ) as CTaskCallUpTeamViewHandler;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }

}
}
