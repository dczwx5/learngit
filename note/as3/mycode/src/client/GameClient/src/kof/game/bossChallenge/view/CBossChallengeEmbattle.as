//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/22.
 */
package kof.game.bossChallenge.view {

import QFLib.Foundation.CTime;
import QFLib.Utils.StringUtil;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.utils.Dictionary;
import kof.framework.CViewHandler;
import kof.game.bossChallenge.CBossChallengeManager;
import kof.game.bossChallenge.CBossChallengeNetHandler;
import kof.game.bossChallenge.CBossChallengeSystem;
import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.subData.CGuildData;
import kof.game.scene.ISceneFacade;
import kof.table.PlayerBasic;
import kof.ui.CUISystem;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.embattle.EmbattleItemUI;
import kof.ui.master.BossChallenge.BossChallengeBattleUI;
import kof.ui.master.BossChallenge.BossChallengeFriendItemUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.SpriteBlitFrameClip;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CBossChallengeEmbattle extends CViewHandler{
    private var m_embattle : BossChallengeBattleUI;
    private var m_isInit : Boolean;
    private var _curEmbattleItemUI : EmbattleItemUI;
    private var _curSpriteBlitFrameClip : SpriteBlitFrameClip;
    private var _lastTime : Number;
    private var _iLeftTime : int;//倒计时
    private var _timeDic : Dictionary;
    public var isOpen : Boolean;

    public function CBossChallengeEmbattle() {
        super(false);
    }
    override public function get viewClass() : Array {
        return [BossChallengeBattleUI];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override public function dispose() : void {
        super.dispose();

        if( m_embattle )
            m_embattle.remove();
        m_embattle = null;
    }

    //重载初始化界面方法
    override protected function onInitializeView() : Boolean{
        if( !super.onInitializeView() )
            return false;
        if(!m_isInit)
            initialize();
        return m_isInit;
    }

    protected function initialize() : void{
        if( !m_embattle ){
            m_embattle = new BossChallengeBattleUI();
            m_embattle.btn_close.clickHandler = new Handler( removeDisplay );
            m_embattle.btn_fight.clickHandler = new Handler( _btnClick );
            m_embattle.list_fighter.renderHandler = new Handler( renderItem );
            //m_embattle.list_fighter.selectHandler = new Handler( selectItemHandler );
            m_embattle.list_fighter.mouseHandler = new Handler( listMouseHandler );
            m_embattle.btn_left.clickHandler = new Handler(_onLeft);
            m_embattle.btn_right.clickHandler = new Handler(_onRight);

            m_embattle.list_friend.renderHandler = new Handler( renderFriend );

            m_embattle.img_bg_1.cacheAsBitmap = true;
            m_embattle.img_masking_1.cacheAsBitmap = true;
            m_embattle.img_bg_1.mask = m_embattle.img_masking_1;

            m_embattle.img_bg_2.cacheAsBitmap = true;
            m_embattle.img_masking_2.cacheAsBitmap = true;
            m_embattle.img_bg_2.mask = m_embattle.img_masking_2;

            m_embattle.btn_write.clickHandler = new Handler( _btnWrite );//点击修改按钮，隐藏美术字，显示输入框
            m_embattle.input_power.restrict = "0-9";
            m_embattle.input_power.maxChars = 6;
            m_embattle.input_power.addEventListener( FocusEvent.FOCUS_IN, _showInput);
            m_embattle.input_power.addEventListener( FocusEvent.FOCUS_OUT,_hideInput);

            m_embattle.btn_clubInvite.clickHandler = new Handler( _sendClubInvite );
            m_embattle.img_help.toolTip = CLang.Get("boss_challenge");
            _timeDic = new Dictionary();
            m_isInit = true;
        }
    }

    override protected function updateDisplay() : void{
        super.updateDisplay();
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addDisplay );
    }

    private function _addDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if(!m_embattle)  return;
        uiCanvas.addPopupDialog( m_embattle );
        isOpen = true;
        embattleShow(_challengeManager.recommendHero); //初次打开自动上阵最佳格斗家

        m_embattle.lb_confPower.text = _challengeManager.configPower + "";
        m_embattle.list_fighter.dataSource = _challengeManager.getHeroListByPower(0);
        var friendArray : Array = _challengeManager.getFriendListData(_challengeManager.needPower);
        m_embattle.list_friend.dataSource = _challengeManager.getFriendListData(_challengeManager.needPower);
        if(friendArray.length > 0)//没有好友显示提示文本
        {
            m_embattle.list_friend.visible = true;
            m_embattle.lb_noFriend.visible = false;
        }
        else
        {
            m_embattle.list_friend.visible = false;
            m_embattle.lb_noFriend.visible = true;
        }

        refreshView();
    }
    public function removeDisplay() : void {
        if( m_embattle )
        {
            m_embattle.close( Dialog.CLOSE );
            isOpen = false;
            if(!_challengeMain.isOpen)
                _challengeSystem.onViewClosed();
        }
    }
    override protected function updateData () : void{
        super.updateData();
    }

    public function refreshView() : void
    {
        if(!m_embattle)  return;
        var helperData : Object =  _challengeManager.getHelperData();
        if(helperData)
        {
            m_embattle.box_helperPower.visible = true;
            m_embattle.box_setPower.visible = false;
            _helperShow(helperData); //上阵协助者
        }
        else
        {
            m_embattle.box_helperPower.visible = false;
            m_embattle.box_setPower.visible = true;
            m_embattle.num_setPower.num = _challengeManager.needPower;
            m_embattle.lb_wait.visible = true;
            m_embattle.clipCharacter_2.visible = false;
            m_embattle.hero_name_txt_2.url = "";
            m_embattle.img_bg_2.url = "";
            m_embattle.img_player2.visible = true;
        }
    }

    /**
     * 渲染自己格斗家列表
     * @param item
     * @param idx
     */
    private function renderItem(item:Component, idx:int):void {
        if ( !(item is EmbattleItemUI) ) {
            return;
        }
        var pEmbattleItemUI : EmbattleItemUI = item as EmbattleItemUI;
        var heroData:CPlayerHeroData = pEmbattleItemUI.dataSource as CPlayerHeroData;
        if (!heroData) return ;
        pEmbattleItemUI.quality_clip.index = 0;
        pEmbattleItemUI.star_list.dataSource = new Array(heroData.star);
        pEmbattleItemUI.lv_txt.visible = false;
        pEmbattleItemUI.level_frame_img.visible = false;
        pEmbattleItemUI.icon_image.cacheAsBitmap = true;
        pEmbattleItemUI.hero_icon_mask.cacheAsBitmap = true;
        pEmbattleItemUI.icon_image.mask = pEmbattleItemUI.hero_icon_mask;
        pEmbattleItemUI.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroData.prototypeID);
        pEmbattleItemUI.clip_type.visible = false;
        pEmbattleItemUI.clip_quality.index = heroData.qualityBaseType;
        pEmbattleItemUI.img_embattle.visible = _challengeManager.recommendHero == heroData;
        pEmbattleItemUI.hp_bar.visible = false;
        pEmbattleItemUI.toolTip = new Handler( _playerSystem.showHeroTips, [heroData]);
        ObjectUtils.gray(pEmbattleItemUI.icon_image, false);
    }
    private function listMouseHandler( evt:Event,idx : int ) : void {
        if( evt.type == MouseEvent.MOUSE_DOWN ){
            for each(var item : EmbattleItemUI in m_embattle.list_fighter.cells)
            {
                item.img_embattle.visible = false;
            }
            _curEmbattleItemUI = m_embattle.list_fighter.getCell(idx) as EmbattleItemUI;
            _curEmbattleItemUI.img_embattle.visible = true;
            embattleShow();
        }
    }
    private function embattleShow(lastHero:CPlayerHeroData = null):void
    {
        var heroData:CPlayerHeroData = lastHero ? lastHero : _curEmbattleItemUI.dataSource as CPlayerHeroData;
        if ( !(m_embattle.clipCharacter_1 as CCharacterFrameClip).framework )
            ( m_embattle.clipCharacter_1 as CCharacterFrameClip ).framework = _pScene.scenegraph.graphicsFramework;
        m_embattle.clipCharacter_1.skin = heroData.playerBasic.SkinName;
        _curSpriteBlitFrameClip = m_embattle.clipCharacter_1;
        m_embattle.hero_name_txt_1.url = CPlayerPath.getUIHeroNamePath( heroData.prototypeID );
        m_embattle.img_bg_1.url = CPlayerPath.getPeakUIHeroFacePath( heroData.prototypeID );
        m_embattle.img_player1.visible = false;
        m_embattle.num_myPower.num = heroData.battleValue;
        _challengeManager.recommendHero = heroData;//手动选择上阵格斗家
        if(heroData.battleValue >= _challengeManager.needPower)
            _challengeManager.needPower = 0;
        _challengeMain.refreshView();//刷新主界面的上阵格斗家
    }

    /**
     * 显示协助者
     * @param data
     */
    private function _helperShow(data:Object) : void
    {
        var heroData:CPlayerHeroData = _playerData.heroList.getHero(data.heroID);
        if(heroData == null) return;
        if ( !(m_embattle.clipCharacter_2 as CCharacterFrameClip).framework )
            ( m_embattle.clipCharacter_2 as CCharacterFrameClip ).framework = _pScene.scenegraph.graphicsFramework;
        var pPlayerObject : PlayerBasic = heroData.playerBasic;
        m_embattle.clipCharacter_2.visible = true;
        m_embattle.clipCharacter_2.skin = pPlayerObject.SkinName;
        _curSpriteBlitFrameClip = m_embattle.clipCharacter_2;
        m_embattle.hero_name_txt_2.url = CPlayerPath.getUIHeroNamePath( heroData.prototypeID );
        m_embattle.img_bg_2.url = CPlayerPath.getPeakUIHeroFacePath( heroData.prototypeID );
        m_embattle.img_player2.visible = false;
        m_embattle.box_setPower.visible = false;
        m_embattle.num_teamPower.num = data.power;
        m_embattle.lb_wait.visible = false;
    }
    private function _onLeft() : void {
        if( m_embattle.list_fighter.page <= 0 )
            return;
        m_embattle.list_fighter.page --;
        _onBtnDisabled();
    }
    private function _onRight() : void {
        if( m_embattle.list_fighter.page >= m_embattle.list_fighter.totalPage )
            return;
        m_embattle.list_fighter.page ++;
        _onBtnDisabled();
    }
    private function _onBtnDisabled():void{
        m_embattle.btn_left.disabled = m_embattle.list_fighter.page <= 0;
        m_embattle.btn_right.disabled = m_embattle.list_fighter.page >= m_embattle.list_fighter.totalPage - 1;
    }

    /**
     * 渲染好友列表
     * @param item
     * @param idx
     */
    private function renderFriend(item:Component, idx:int):void {
        if (!(item is BossChallengeFriendItemUI)) {
            return;
        }
        var pItemUI:BossChallengeFriendItemUI = item as BossChallengeFriendItemUI;
        if( pItemUI.dataSource )
        {
            pItemUI.visible = true;
            pItemUI.img_head.url = CPlayerPath.getUIHeroIconBigPath(pItemUI.dataSource.headID);
            pItemUI.txt_power.text = pItemUI.dataSource.battleValue;
            pItemUI.txt_lv.text = 'Lv.' + pItemUI.dataSource.level;
            pItemUI.img_head.cacheAsBitmap = true;
            pItemUI.maskimg.cacheAsBitmap = true;
            pItemUI.img_head.mask = pItemUI.maskimg;
            pItemUI.btn_invite.clickHandler = new Handler( _onItemBtnCkHandler,[pItemUI]);
            _playerSystem.platform.signatureRender.renderSignature( pItemUI.dataSource.vipLevel,
                    pItemUI.dataSource.platformData, pItemUI.signature, pItemUI.dataSource.name);
        }
        else
        {
            pItemUI.visible = false;
        }
    }

    /**
     * 发送邀请
     * @param args
     */
    private function _onItemBtnCkHandler(... args):void {
        var pIMItemUI : BossChallengeFriendItemUI = args[ 0 ] as BossChallengeFriendItemUI;
        var roleID : int = pIMItemUI.dataSource.roleID;
        var helpData:Object = _challengeManager.getHelperData();
        var tipStr:String;
        if(helpData == null) //无协助者时才可以发送邀请
        {
            var timeObj :Object = _challengeManager.getTimeDicByID(roleID);
            var leftTime:int = 0;
            if(timeObj)
            {
                leftTime = Math.floor((CTime.getCurrServerTimestamp() - timeObj.startTime)/1000) - _challengeManager.constTable.InviteCD ;
            }

            if(!timeObj || leftTime >= 0)
            {
                _challengeNet.inviteRequest(roleID ,_challengeManager.needPower );
                _challengeManager.setStartTime(roleID,CTime.getCurrServerTimestamp());
            }
            else
            {
                tipStr =  CLang.Get(StringUtil.format(CLang.LANG_00402,Math.abs(leftTime)));
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( tipStr );
            }
        }
        else
        {
            tipStr = _challengeManager.getGamePromptStr(3612);//当前已有协助者,无法发起邀请
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( tipStr );
        }
    }
    private var isInput : Boolean = false;
    private function _btnWrite() : void
    {
        if(isInput)
        {
            _hideInput();
        }
        else
        {
            system.stage.flashStage.focus = m_embattle.input_power.textField;
            var index :int =  m_embattle.input_power.textField.length;
            m_embattle.input_power.textField.setSelection(index,index);
        }
        isInput = !isInput;
    }
    private function _showInput(e:FocusEvent) : void
    {
        m_embattle.num_setPower.visible = false;
        m_embattle.input_power.visible = true;
        m_embattle.input_power.text = m_embattle.num_setPower.num + "";
    }
    private function _hideInput(e:FocusEvent = null) : void
    {
        m_embattle.num_setPower.visible = true;
        m_embattle.input_power.visible = false;
        _challengeManager.needPower = int(m_embattle.input_power.text);
        m_embattle.num_setPower.num =  _challengeManager.needPower;
        //筛选好友
        var friendArray : Array = _challengeManager.getFriendListData(_challengeManager.needPower);
        m_embattle.list_friend.dataSource = _challengeManager.getFriendListData(_challengeManager.needPower);
        if(friendArray.length > 0)//没有好友显示提示文本
        {
            m_embattle.list_friend.visible = true;
            m_embattle.lb_noFriend.visible = false;
        }
        else
        {
            m_embattle.list_friend.visible = false;
            m_embattle.lb_noFriend.visible = true;
        }
        isInput = false;
    }

    /**
     * 发送俱乐部邀请
     */
    private function _sendClubInvite() : void
    {
        var guideData : CGuildData = _playerData.guideData;
        var proStr : String = "";
        if(guideData.clubName != "")//有公会才能发出
        {
            var helpData : Object = _challengeManager.getHelperData();
            if(!helpData)//无协助者时才可以发送邀请
            {
                var _curTime : Number = CTime.getCurrServerTimestamp();
                var _constTime : Number = _challengeManager.constTable.InviteCD * 1000;
                if ( _curTime - _lastTime < _constTime ) //俱乐部邀请内置CD30s；
                {
                    proStr = _challengeManager.getGamePromptStr(3613);//邀请冷却中...
                }
                else
                {
                    _challengeNet.clubHelpRequest( _challengeManager.needPower );
                    _lastTime = CTime.getCurrServerTimestamp();
                    _iLeftTime = _challengeManager.constTable.InviteCD;
                    m_embattle.lb_time.visible = true;
                    schedule(1, _onScheduleHandler);
                    return;
                }
            }
            else
            {
                proStr = _challengeManager.getGamePromptStr(3612);//当前已有协助者,无法发起邀请
            }
        }
        else
        {
            proStr = _challengeManager.getGamePromptStr( 3608 );//您还没有加入俱乐部
        }
        (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( proStr );
    }
    /**
     * 挑战boss
     */
    private function _btnClick():void
    {
        //校验有没队友，有则弹出提示框
        var helpData:Object = _challengeManager.getHelperData();
        var tisStr:String;
        var selfData : CPlayerHeroData = _challengeManager.recommendHero;
        if(!helpData)
        {
            tisStr = _challengeManager.getGamePromptStr( 3611 );//您确定要单人挑战Boss？
            uiCanvas.showMsgBox( tisStr, _gotoBoss,null,true,null,null,true,"3611" );
        }
        else if(selfData.battleValue < _challengeManager.configPower && helpData.power < _challengeManager.configPower)
        {
            tisStr = _challengeManager.getGamePromptStr( 3615 );//战力不足挑战boss？
            uiCanvas.showMsgBox( tisStr, _gotoBoss,null,true,null,null,true,"3615" );
        }
        else
        {
            _gotoBoss();
        }
    }

    private function _onScheduleHandler(delta : Number):void
    {
        m_embattle.lb_time.text = "(" + _iLeftTime + "s)";
        _iLeftTime--;

        if(_iLeftTime <= 0)
        {
            m_embattle.lb_time.visible = false;
            unschedule(_onScheduleHandler);
        }
    }


    private function _gotoBoss():void
    {
        _challengeNet.bossChallengeRequest(_challengeManager.recommendHero.ID);
    }

    private function get _pScene():ISceneFacade{
        return system.stage.getSystem( ISceneFacade ) as ISceneFacade;
    }
    private function get _playerSystem():CPlayerSystem{
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData
    {
        return _playerSystem.playerData;
    }
    private function get _challengeManager() : CBossChallengeManager
    {
        return system.getBean( CBossChallengeManager ) as CBossChallengeManager;
    }
    private function get _challengeNet() : CBossChallengeNetHandler
    {
        return system.getBean( CBossChallengeNetHandler ) as CBossChallengeNetHandler;
    }
    private function get _challengeMain() : CBossChallengeMainView
    {
        return system.getBean( CBossChallengeMainView ) as CBossChallengeMainView;
    }
    private function get _challengeSystem() : CBossChallengeSystem
    {
        return system as CBossChallengeSystem;
    }
}
}
