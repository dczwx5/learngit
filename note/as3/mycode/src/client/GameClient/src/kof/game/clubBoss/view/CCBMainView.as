//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/19.
 * Time: 18:25
 */
package kof.game.clubBoss.view {

import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAppSystem;
import kof.game.clubBoss.CClubBossHandler;
import kof.game.clubBoss.CClubBossSystem;
import kof.game.clubBoss.CClubBossViewHandler;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.enums.EClubBossEventType;
import kof.game.clubBoss.net.CCBNet;
import kof.game.common.CLang;
import kof.game.common.status.CGameStatus;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.clubBoss.CBMainUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/19
 */
public class CCBMainView {
    private var _clubViewHandler : CClubBossViewHandler = null;
    private var _cbMainUI : CBMainUI = null;
    private var _clubBossSystem : CClubBossSystem = null;
    private var _uiContainer : IUICanvas = null;
    private var _closeHandler : Handler = null;

    private var _isShow : Boolean = false;
    private var _pDataManager : CCBDataManager = null;
    private var _pNet : CCBNet = null;

    private var _cbTips : CCBItemTips = null;
    //----------childView-------------
    private var _embattleView : CEmbattleView = null;
    private var _rewardView : CRewardRank = null;
    private var _bossItemView : CBossItemView = null;
    private var _killRewardView:CRewardKill=null;
    private var _ruleView:CCBRuleView = null;
    private var _heroTip:CCBHeroTips = null;

    public function get cbTips():CCBItemTips{
        return _cbTips;
    }

    public function get net() : CCBNet {
        return _pNet;
    }

    public function get embattleView() : CEmbattleView {
        return _embattleView;
    }

    public function get bossItemView() : CBossItemView {
        return _bossItemView;
    }

    public function get system() : CAppSystem {
        return _clubViewHandler.system;
    }

    public function get uiContainer() : IUICanvas {
        return _uiContainer;
    }

    public function get mainUI() : CBMainUI {
        return _cbMainUI;
    }

    public function set closeHandler( value : Handler ) : void {
        _closeHandler = value;
    }

    public function CCBMainView( cbViewHandler : CClubBossViewHandler ) {
        _cbMainUI = new CBMainUI();
        _clubViewHandler = cbViewHandler;
        _clubBossSystem = cbViewHandler.system as CClubBossSystem;
        this._uiContainer = cbViewHandler.uiCanvas;
        _cbMainUI.closeHandler = new Handler( _closeHandlerExecute );
        _cbMainUI.battleBtn.clickHandler = new Handler( opneEmBattleFunc );
        _cbMainUI.challengeBtn.clickHandler = new Handler( _startBattle );
        this._pDataManager = cbViewHandler.system.getBean( CCBDataManager ) as CCBDataManager;
        this._pNet = (cbViewHandler.system.getBean( CClubBossHandler ) as CClubBossHandler).cbNet;
        this._cbMainUI.embattaleView.mask = this._cbMainUI.maskSP;
        this._cbMainUI.embattaleView.x = this._cbMainUI.pt.x;
        this._cbMainUI.embattaleView.visible = false;
        this._cbMainUI.rankRewardBtn.clickHandler = new Handler( _showRewardRankView );
        this._cbMainUI.killRewardBtn.clickHandler = new Handler( _showRewardKillView );
        this._cbMainUI.ruleImg.addEventListener(MouseEvent.CLICK, _showRuleView);
        this._cbMainUI.ruleImg.toolTip = new Handler(_showRuleTip,[CLang.Get("cbRule")]);
        _cbTips = new CCBItemTips();
        _cbTips.appSystem = system;
        this._cbMainUI.timeLabel.text = _pDataManager.clubBossConstant.clubBossStartTime;
        //---childView---
        _embattleView = new CEmbattleView( this );
        _rewardView = new CRewardRank( this );
        _killRewardView = new CRewardKill(this);
        _bossItemView = new CBossItemView( this );
        _ruleView = new CCBRuleView(this);
        _heroTip = new CCBHeroTips();
        _addEvents();
    }

    private function _showRuleTip(str:String):void{
        _heroTip.showRuleTips(str);
    }

    private function _showRuleView(e:MouseEvent):void{
        _ruleView.show();
    }

    private function _showRewardKillView() : void {
        _killRewardView.show();
    }

    private function _showRewardRankView() : void {
        _rewardView.show();
    }

    public function _addEvents() : void {
        _pDataManager.addEventListener(EClubBossEventType.JOIN_BATTALE,_joinFight);
    }

    private function _joinFight(e:Event):void{
        _cbMainUI.close(Dialog.CLOSE);
    }

    public function _startBattle() : void {
        if (!CGameStatus.checkStatus(system)){
            return;
        }
        _pNet.joinClubBossRequest( _bossItemView.currentSelectBossId );
    }

    private function _closeHandlerExecute( type : String = "" ) : void {
        if ( type == Dialog.CLOSE ) {
            _closeHandler.execute();
            _isShow = false;
        }
    }

    public function show() : void {
        _pNet.queryClubBossInfoRequest();
        _pNet.ifGotDamageRewardRequest();
        this._uiContainer.addDialog( _cbMainUI );
        _isShow = true;
    }

    public function close() : void {
        _cbMainUI.close();
        _isShow = false;
    }

    public function opneEmBattleFunc() : void {
        this._cbMainUI.embattaleView.visible = true;
        TweenLite.to( this._cbMainUI.embattaleView, 0.5, {x : this._cbMainUI.maskSP.x} );
    }

    public function showPrompt( erorCode : Number) : void {
        var msg : String = (this._gamePromptTable.findByPrimaryKey( erorCode ) as GamePrompt).content;
        var type:int = (this._gamePromptTable.findByPrimaryKey( erorCode ) as GamePrompt).type;
        (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( msg, type );
    }

    private function get _gamePromptTable():CDataTable{
        var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        return pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
    }

    public function get isViewShow():Boolean
    {
        return _cbMainUI && _cbMainUI.parent;
    }
}
}
