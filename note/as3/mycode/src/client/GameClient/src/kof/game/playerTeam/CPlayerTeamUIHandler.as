//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/26.
 */
package kof.game.playerTeam {

import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerVisitData;
import kof.game.player.enum.EHeroIntelligence;
import kof.game.player.enum.EPlayerWndType;
import kof.game.player.event.CPlayerEvent;
import kof.game.playerTeam.control.CPlayerTeamChangeIconControl;
import kof.game.playerTeam.control.CPlayerTeamChangeNameControl;
import kof.game.playerTeam.control.CPlayerTeamControl;
import kof.game.playerTeam.control.CPlayerTeamCreateControl;
import kof.game.playerTeam.control.CPlayerTeamFirstChangeNameControl;
import kof.game.playerTeam.view.CPlayerTeamChangeImageViewHandler;
import kof.game.playerTeam.view.CPlayerTeamChangeNameConfirmViewHandler;
import kof.game.playerTeam.view.CPlayerTeamChangeNameViewHandler;
import kof.game.playerTeam.view.CPlayerTeamCreateViewHandler;
import kof.game.playerTeam.view.CPlayerTeamFirstChangeNameViewHandler;
import kof.game.playerTeam.view.CPlayerTeamLevelUpViewHandler;
import kof.game.playerTeam.view.team_new.CTeamNewViewHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.game.title.CTitleSystem;
import kof.game.title.event.CTitleEvent;
import kof.util.CAssertUtils;

public class CPlayerTeamUIHandler extends CViewManagerHandler {

    public function CPlayerTeamUIHandler() {

    }

    public override function dispose() : void {
        super.dispose();
        var playerSystem:CPlayerSystem = _playerSystem;
        if (playerSystem) {
            playerSystem.removeEventListener(CPlayerEvent.PLAYER_TEAM, _onDataUpdate);
            playerSystem.removeEventListener(CPlayerEvent.RANDOM_NAME, _onDataUpdate);
            playerSystem.removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP, _onDataUpdate);
            playerSystem.removeEventListener(CPlayerEvent.PLAYER_VIP_LEVEL, _onDataUpdate);
            playerSystem.removeEventListener(CPlayerEvent.HERO_ADD, _onDataUpdate);
        }
        var pTitleSystem:CTitleSystem = system.stage.getSystem(CTitleSystem) as CTitleSystem;
        if (pTitleSystem) {
            pTitleSystem.removeEventListener(CTitleEvent.DATA_EVENT, _onTitleDataUpdate);
        }
        var pTeamSystem:CPlayerTeamSystem = playerSystem.stage.getSystem(CPlayerTeamSystem) as CPlayerTeamSystem;
        if (pTeamSystem) {
            pTeamSystem.removeEventListener(CPlayerEvent.VISIT_DATA, _onDataUpdate);
        }

    }

    override public function onEvtEnable() : void {
        super.onEvtEnable();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

//        this.addViewClassHandler( EPlayerWndType.WND_PLAYER_TEAM_INFO, CPlayerTeamViewHandler, CPlayerTeamControl );
        this.addViewClassHandler( EPlayerWndType.WND_PLAYER_TEAM_CHANGE_IMAGE, CPlayerTeamChangeImageViewHandler, CPlayerTeamChangeIconControl );
        this.addViewClassHandler( EPlayerWndType.WND_TEAM_MAIN, CTeamNewViewHandler, CPlayerTeamControl );
        this.addViewClassHandler( EPlayerWndType.WND_PLAYER_TEAM_CHANGE_NAME, CPlayerTeamChangeNameViewHandler, CPlayerTeamChangeNameControl );
        this.addViewClassHandler( EPlayerWndType.WND_PLAYER_TEAM_FIRST_CHANGE_NAME, CPlayerTeamFirstChangeNameViewHandler, CPlayerTeamFirstChangeNameControl );
        this.addViewClassHandler( EPlayerWndType.WND_PLAYER_TEAM_CREATE, CPlayerTeamCreateViewHandler, CPlayerTeamCreateControl );
        this.addViewClassHandler( EPlayerWndType.WND_PLAYER_TEAM_LEVEL_UP, CPlayerTeamLevelUpViewHandler );
        this.addViewClassHandler( EPlayerWndType.WND_PLAYER_TEAM_CHANGE_NAME_CONFIRM, CPlayerTeamChangeNameConfirmViewHandler );

        this.addBundleData(EPlayerWndType.WND_TEAM_MAIN, KOFSysTags.PLAYER_TEAM);

        var playerSystem:CPlayerSystem = _playerSystem;
        if (playerSystem) {
            playerSystem.addEventListener(CPlayerEvent.PLAYER_TEAM, _onDataUpdate);
            playerSystem.addEventListener(CPlayerEvent.RANDOM_NAME, _onDataUpdate);
            playerSystem.addEventListener(CPlayerEvent.PLAYER_LEVEL_UP, _onDataUpdate);
            playerSystem.addEventListener(CPlayerEvent.PLAYER_VIP_LEVEL, _onDataUpdate);
            playerSystem.addEventListener(CPlayerEvent.HERO_ADD, _onDataUpdate);
        }
        var pTeamSystem:CPlayerTeamSystem = playerSystem.stage.getSystem(CPlayerTeamSystem) as CPlayerTeamSystem;
        if (pTeamSystem) {
            pTeamSystem.addEventListener(CPlayerEvent.VISIT_DATA, _onDataUpdate);
        }
        var pTitleSystem:CTitleSystem = system.stage.getSystem(CTitleSystem) as CTitleSystem;
        if (pTitleSystem) {
            pTitleSystem.addEventListener(CTitleEvent.DATA_EVENT, _onTitleDataUpdate);
        }
        return ret;
    }


    // =================================player Team=========================================
    public function showPlayerTeam(playerUID:Number) : void {
        system.removeEventListener(CPlayerEvent.VISIT_DATA, _onVisitDataUpdateB);
        system.addEventListener(CPlayerEvent.VISIT_DATA, _onVisitDataUpdateB);
        var netHandler:CPlayerTeamHandler = system.getBean(CPlayerTeamHandler) as CPlayerTeamHandler;
        netHandler.sendGetVisitData(playerUID);
    }
    private function _onVisitDataUpdateB(e:CPlayerEvent) : void {
        var playerData : CPlayerData = (system as CPlayerTeamSystem).playerData;
        show( EPlayerWndType.WND_TEAM_MAIN, null, null, playerData.visitPlayerData );
    }


    public function showCreateTeam() : void {
        var playerData : CPlayerData = (system as CPlayerTeamSystem).playerData;
        show( EPlayerWndType.WND_PLAYER_TEAM_CREATE, null, null, playerData );
    }
    public function hideCreateTeam() : void {
        hide( EPlayerWndType.WND_PLAYER_TEAM_CREATE );
    }
    public function hidePlayerTeam() : void {
        hide( EPlayerWndType.WND_TEAM_MAIN );
    }

    // =================================data update======================================
    private function _onDataUpdate( e : CPlayerEvent ) : void {
        switch ( e.type ) {
            case CPlayerEvent.PLAYER_TEAM:
            case CPlayerEvent.PLAYER_VIP_LEVEL:
            case CPlayerEvent.VISIT_DATA :
                _onPlayerDataUpdate( e );
                break;
            case CPlayerEvent.RANDOM_NAME:
                _onRandomName( e );
                break;
            case CPlayerEvent.PLAYER_LEVEL_UP:
                _onPlayerLevelUp( e );
                break;
            case CPlayerEvent.HERO_ADD:
                var heroData:CPlayerHeroData = e.data.heroData as CPlayerHeroData;
                if (heroData && heroData.qualityBase >= EHeroIntelligence.A) {
                    var onGetHeroFinishedHandler:Function = function (e:CPlayerEvent) : void {
                        _playerSystem.removeEventListener(CPlayerEvent.SHOW_GET_HERO_FINISHED, onGetHeroFinishedHandler);
                        uiCanvas.showMsgBox(CLang.Get("player_ask_to_use_new_hero_display", {v1: heroData.heroNameWithColor}), function () : void {
//                            (system as CPlayerTeamSystem).netHandler.sendChangeHead(heroData.prototypeID);
                            (system as CPlayerTeamSystem).netHandler.sendChangeTeamModel(heroData.prototypeID);
                        });
                    };
                    _playerSystem.removeEventListener(CPlayerEvent.SHOW_GET_HERO_FINISHED, onGetHeroFinishedHandler);
                    _playerSystem.addEventListener(CPlayerEvent.SHOW_GET_HERO_FINISHED, onGetHeroFinishedHandler);
                }
                break;
        }
    }

    private function _onTitleDataUpdate(e:CTitleEvent) : void {
        var wnd : CViewBase = getWindow( EPlayerWndType.WND_TEAM_MAIN );
        if ( wnd ) wnd.invalidate();
    }
    // ===================CREATE TEAM
    private function _onInstanceEvent(e:CInstanceEvent) : void {
        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        CAssertUtils.assertNotNull(instanceSystem);
        instanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onInstanceEvent);

        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            // 进入副本
            if (instanceSystem.isMainCity == false) {
                instanceSystem.addExitProcess(null, CInstanceExitProcess.FLAG_CREATE_TEAM, showCreateTeam, null, 9999);
            } else {
                showCreateTeam();
            }
        }
    }
    // ================CREATE TEAM
    private function _onRandomName( e : CPlayerEvent ) : void {
        // 改名
        var wnd : CViewBase = getWindow( EPlayerWndType.WND_PLAYER_TEAM_CHANGE_NAME );
        if ( wnd ) {
            (wnd as CPlayerTeamChangeNameViewHandler)._lastRandomName = (e.data as CPlayerData).randomName;
            wnd.setData( e.data as CPlayerData );
        }

        // 第一次改名
        wnd = getWindow( EPlayerWndType.WND_PLAYER_TEAM_FIRST_CHANGE_NAME );
        if ( wnd ) {
            (wnd as CPlayerTeamFirstChangeNameViewHandler)._lastRandomName = (e.data as CPlayerData).randomName;
            wnd.setData( e.data as CPlayerData );
        }

        // 创建战队
        wnd = getWindow( EPlayerWndType.WND_PLAYER_TEAM_CREATE );
        if ( wnd ) wnd.setData( e.data as CPlayerData );
    }

    private function _onPlayerDataUpdate( e : CPlayerEvent ) : void {
        var pPlayerData:CPlayerData;
        var pVisitData:CPlayerVisitData;
        if ( e.data is CPlayerData) {
            pPlayerData = e.data as CPlayerData;
        } else {
            pPlayerData = _playerSystem.playerData;
        }
        pVisitData = pPlayerData.visitPlayerData;

        // 战队信息界面
        var wnd : CViewBase = getWindow( EPlayerWndType.WND_TEAM_MAIN );
        if ( wnd ) wnd.setData(pVisitData);

        // 改名
        wnd = getWindow( EPlayerWndType.WND_PLAYER_TEAM_CHANGE_NAME );
        if ( wnd ) {
            wnd.setData(pPlayerData);
            var teamChangeName : CPlayerTeamChangeNameViewHandler = wnd as CPlayerTeamChangeNameViewHandler;
            if ( teamChangeName._lastSendName == pPlayerData.teamData.getNoneServerName() ) {
                wnd.close();
            }
        }

        // 首次改名
        wnd = getWindow( EPlayerWndType.WND_PLAYER_TEAM_FIRST_CHANGE_NAME );
        if ( wnd ) {
            wnd.setData(pPlayerData);
            var teamFirstChangeName : CPlayerTeamFirstChangeNameViewHandler = wnd as CPlayerTeamFirstChangeNameViewHandler;
            if ( teamFirstChangeName._lastSendName == (pPlayerData).teamData.getNoneServerName() ) {
                wnd.close();
            }
        }

        // 战队创建
        wnd = getWindow( EPlayerWndType.WND_PLAYER_TEAM_CREATE );
        if ( wnd ) {
            wnd.setData(pPlayerData);
            var teamCreateView : CPlayerTeamCreateViewHandler = wnd as CPlayerTeamCreateViewHandler;
            if ( teamCreateView._lastSendName == pPlayerData.teamData.getNoneServerName() ) {
                wnd.close();
            }
        }
 
    }

    private function _onPlayerLevelUp( e : CPlayerEvent ) : void {
//        var isInMainCity : Boolean = (system.stage.getSystem( IInstanceFacade ) as IInstanceFacade).isMainCity;
//        if ( isInMainCity == false ) {
//            (system.stage.getSystem( IInstanceFacade ) as IInstanceFacade).addExitProcess(CPlayerTeamLevelUpViewHandler, null,
//                    show, [ EPlayerWndType.WND_PLAYER_TEAM_LEVEL_UP, null, null, e.data as CPlayerData ], 1 );
//        } else {
//            _reciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_1, function():void{
//                show( EPlayerWndType.WND_PLAYER_TEAM_LEVEL_UP, null, null, e.data as CPlayerData );
//            });
//        }
        var uiTag:int = -1;
        var isInMainCity : Boolean = (system.stage.getSystem( IInstanceFacade ) as IInstanceFacade).isMainCity;
        if ( isInMainCity == false ) {
            uiTag = 1;
        }
        _reciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_1, function():void{
                show( EPlayerWndType.WND_PLAYER_TEAM_LEVEL_UP, null, null, e.data as CPlayerData,uiTag );
            });

    }

    private function get _playerSystem() : CPlayerSystem {
        return  system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function get _reciprocalSystem() : CReciprocalSystem {
        return system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem;
    }

}
}
