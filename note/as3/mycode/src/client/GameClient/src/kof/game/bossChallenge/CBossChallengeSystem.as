//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/22.
 */
package kof.game.bossChallenge {

import flash.utils.Dictionary;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bossChallenge.event.CBossChallengeEvent;
import kof.game.bossChallenge.view.CBossChallengeEmbattle;
import kof.game.bossChallenge.view.CBossChallengeHeroBoxView;
import kof.game.bossChallenge.view.CBossChallengeInvitationView;
import kof.game.bossChallenge.view.CBossChallengeMainView;
import kof.game.bossChallenge.view.CBossChallengeVictoryView;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.CooperationBoss.CooperationBossResultResponse;

import morn.core.handlers.Handler;

public class CBossChallengeSystem extends CBundleSystem implements ISystemBundle{
    private var _mainView : CBossChallengeMainView;
    private var _manager : CBossChallengeManager;
    private var _netHandlder : CBossChallengeNetHandler;
    private var _embattle : CBossChallengeEmbattle;
    private var _inviteView : CBossChallengeInvitationView;
    private var _heroBox : CBossChallengeHeroBoxView;
    private var _victoryView : CBossChallengeVictoryView;
    private var _instanceOverHandler:CInstanceOverHandler;
    public function CBossChallengeSystem() {
        super();
    }
    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.BOSS_CHALLENGE);
    }
    override public function dispose():void
    {
        super.dispose();
    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
            return false;
        var ret : Boolean = super.initialize();
        ret = ret && addBean( _mainView = new CBossChallengeMainView() );
        ret = ret && addBean( _manager = new CBossChallengeManager() );
        ret = ret && addBean( _netHandlder = new CBossChallengeNetHandler() );
        ret = ret && addBean( _embattle =  new CBossChallengeEmbattle() );
        ret = ret && addBean( _inviteView =  new CBossChallengeInvitationView() );
        ret = ret && addBean( _heroBox =  new CBossChallengeHeroBoxView() );
        ret = ret && addBean( _victoryView =  new CBossChallengeVictoryView() );

        ret = ret && this.addBean(_instanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_COOPERATION_PVE,
                        new Handler(showResultView)));
        _instanceOverHandler.listenEvent();
        if(ret)
        {
            _mainView.closeHandler = new Handler( onViewClosed);
        }
        return ret;
    }

    override protected function onBundleStart(ctx : ISystemBundleContext) : void
    {
        //_recruitLogic.onActivityDataRequest();
    }

    override protected function onActivated(value : Boolean) : void
    {
        super.onActivated(value);
        if(value)
        {
            var bundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var bundle : ISystemBundle =  bundleCtx.getSystemBundle( bundleID );
            var itemID : int = bundleCtx.getUserData(bundle, CBundleSystem.ITEM_ID);//用来打开界面的道具ID
            var marqueeData : Dictionary = bundleCtx.getUserData(bundle, CBundleSystem.MARQUEE_DATA);//用来打开界面的公告信息
            if(itemID > 0 && !_mainView.isOpen)
            {
                _manager.setCostItem(itemID);
                _mainView.addDisplay();
                bundleCtx.setUserData( bundle, CBundleSystem.ITEM_ID, 0 );//置空bundle的数据
            }//俱乐部聊天栏响应请求,自己点自己发的公告无效,{0}玩家名称，{1}挑战券名，{2}需要战力，{3}玩家ID，{4}bossID
            else if(marqueeData && marqueeData[3] != _playerData.ID)
            {
                _netHandlder.receiveInviteRequest(marqueeData);
            }
        }
        else
        {
            _mainView.removeDisplay();
            //如果出战界面也关闭，则发起解散房间请求
            if(!_embattle.isOpen)
                _netHandlder.dissolveRoomRequest(_manager.bossID);
        }

    }

    public function instanceOver() : void
    {
        _instanceOverHandler.instanceOverEventProcess(null);
    }
    private function showResultView():void
    {
        var isWin : Boolean = _manager.getResultData().isWin;
        if(isWin)
        {
            _victoryView.addDisplay();
        }
        else
        {
            var uiHandler : CInstanceUIHandler = _instance.getBean( CInstanceUIHandler ) as CInstanceUIHandler;
            uiHandler.showResultLoseView();
        }

    }
    public function onViewClosed() : void
    {
        this.setActivated(false);
    }
    public function openSystem() : void {
        this.ctx.startBundle(this);
    }
    public function closeSystem() : void {
        this.ctx.stopBundle(this);
    }
    private function get _playerData() : CPlayerData
    {
        return (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    private function get _instance() : CInstanceSystem
    {
        return stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }
}
}

