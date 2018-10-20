//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/8/17.
 */
package kof.game.newServerActivity.view {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CAppSystem;
import kof.game.common.CSystemRuleUtil;
import kof.game.newServerActivity.CNewServerActivityHandler;
import kof.game.newServerActivity.CNewServerActivityManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.IUICanvas;
import kof.ui.master.NewServerActivity.NewServerActivityRankItemUI;
import kof.ui.master.NewServerActivity.NewServerActivityRankUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CNewServerActivityRankViewHandler {
    private var m_activityRankUI : NewServerActivityRankItemUI = null;
    private var m_uiConterner : IUICanvas = null;
    private var _appSystem : CAppSystem = null;
    private var m_rankName : String;
    private var m_rankTitle : String;
    private var m_dayIndex : int;

    public function CNewServerActivityRankViewHandler( uiContainer : IUICanvas, sys : CAppSystem ) {

        m_activityRankUI = new NewServerActivityRankItemUI();
        this.m_uiConterner = uiContainer;
        _appSystem = sys;
        _initView();
    }

    private function _initView() : void {
        m_activityRankUI.rank_list.renderHandler = new Handler( _renderItem );
        m_activityRankUI.rank_list.mouseHandler = new Handler( mouseItemHandler );
        m_activityRankUI.btn_refresh.clickHandler = new Handler( _refreshActivityRank );
    }

    private function _renderItem( item : Component, index : int ) : void {
        var itemUI : NewServerActivityRankUI = item as NewServerActivityRankUI;
        if ( !item.dataSource ) return;
        var rank : int = item.dataSource.rank;
        var name : String = item.dataSource.name;
        var value : int = item.dataSource.value;
        itemUI.clip_firstRank.visible = rank <= 3 ? true : false;
        itemUI.clip_firstRank.index = rank - 1;
        itemUI.txt_rank.visible = rank > 3 ? true : false;
        itemUI.txt_rank.text = rank.toString();
        itemUI.txt_name.text = name;
        itemUI.txt_myForce.num = value;
    }
    private function mouseItemHandler( evt:Event,idx : int ) : void {
        var rankItemViewUI : NewServerActivityRankUI = m_activityRankUI.rank_list.getCell( idx ) as NewServerActivityRankUI;
        if ( evt.type == MouseEvent.CLICK ) {
            if(rankItemViewUI.dataSource){
                _pNewServerActivityRankMenuHandler.show( rankItemViewUI);
            }
        }
    }

    private function _refreshActivityRank() : void
    {
        //发送排行榜请求
        if( newServerActivityHandler )
        {
            newServerActivityHandler.getActivityRankRequest( newServerActivityManager.curActivityID );
        }
    }

    public function updateListDataSource() : void
    {
        m_activityRankUI.rank_list.dataSource = newServerActivityManager.curActivityRankData;
        if( newServerActivityManager.activityData.myRank > 0 ){
            m_activityRankUI.txt_rank.text =  newServerActivityManager.activityData.myRank.toString();
            m_activityRankUI.txt_name.text =  _playerData.teamData.name;
        }else{
            m_activityRankUI.txt_rank.text =  '未上榜';
            m_activityRankUI.txt_name.text =  newServerActivityManager.getActivityInfoById( m_dayIndex ).describe;
        }

        m_activityRankUI.txt_myForce.num =  newServerActivityManager.activityData.myForce;

    }

    public function show() : void
    {
//        m_uiConterner.addPopupDialog( m_activityRankUI );
        m_uiConterner.addDialog( m_activityRankUI );
    }

    public function countDown( countStr : String ) : void
    {
        m_activityRankUI.txt_countdown.text = countStr;
    }

    public function get activityRankUI () : NewServerActivityRankItemUI
    {
        return m_activityRankUI;
    }

    public function set rankName( value : String ) : void
    {
        m_rankName = value;
        m_activityRankUI.txt_rankName.text = m_rankName ;
    }

    public function set rankTitle( value : String ) : void
    {
        m_rankTitle = value;
        m_activityRankUI.txt_rankTitle.text = m_rankTitle;
        //m_activityRankUI.tips_btn.toolTip = newServerActivityManager.getRankTips();
        CSystemRuleUtil.setRuleTips(m_activityRankUI.tips_btn, newServerActivityManager.getRankTips());
    }
    public function set dayIndex( value : int ) : void
    {
        m_dayIndex = value;
    }

    private function get newServerActivityManager() : CNewServerActivityManager
    {
        return _appSystem.getBean( CNewServerActivityManager ) as CNewServerActivityManager;
    }

    private function get newServerActivityHandler() : CNewServerActivityHandler
    {
        return _appSystem.getBean( CNewServerActivityHandler ) as CNewServerActivityHandler;
    }
    private function get _pNewServerActivityRankMenuHandler():CNewServerActivityRankMenuHandler{

        return _appSystem.getBean( CNewServerActivityRankMenuHandler ) as CNewServerActivityRankMenuHandler;

    }
    private function get _playerSystem():CPlayerSystem{
        return _appSystem.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData
    {
        return _playerSystem.playerData;
    }
}
}
