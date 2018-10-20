//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/26.
 */
package kof.game.player {


import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.player.control.CSkillUpControl;
import kof.game.player.control.equStone.CEqustoneControl;
import kof.game.player.control.equipmentTrain.CEquipmentTrainControl;
import kof.game.player.control.playerDetail.CPlayerHeroDetailControl;
import kof.game.player.control.playerList.CPlayerHeroListControl;
import kof.game.player.control.playerTrain.CPlayerHeroTrainControl;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndType;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.equipmentTrain.CEqustoneView;
import kof.game.player.view.heroGet.CHeroGetViewHandler;
import kof.game.player.view.heroGet.CPlayerHeroGetView;
import kof.game.player.view.player.CPlayerHeroView;
import kof.game.player.view.playerNew.CHeroCareerTipsView;
import kof.game.player.view.playerNew.CHeroTipsView;
import kof.game.player.view.playerNew.CHeroSkillTipsView;
import kof.game.player.view.playerNew.view.heroDevelop.CHeroSkillTipsSmallView;
import kof.game.player.view.skillup.CSkillUpItemTips;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;

public class CPlayerUIHandler extends CViewManagerHandler {

    public function CPlayerUIHandler() {
    }

    public override function dispose() : void {
        super.dispose();
        (system as CPlayerSystem).unListenEvent( _onDataUpdate );
    }

    override public function onEvtEnable() : void {
        super.onEvtEnable();
        if (this.evtEnable) {
            if ( system.stage.getSystem( CBagSystem ) ) {
                (system.stage.getSystem( CBagSystem ) as CBagSystem).listenEvent( _onDataBagUpdate );
            }
        } else {
            if ( system.stage.getSystem( CBagSystem ) ) {
                (system.stage.getSystem( CBagSystem ) as CBagSystem).unListenEvent( _onDataBagUpdate );
            }
        }
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.addViewClassHandler( EPlayerWndType.WND_HERO_MAIN, CPlayerHeroView, CPlayerHeroListControl );
        this.registControl( EPlayerWndType.WND_HERO_MAIN, CPlayerHeroTrainControl );
        this.registControl( EPlayerWndType.WND_HERO_MAIN, CPlayerHeroDetailControl );
        this.registControl( EPlayerWndType.WND_HERO_MAIN, CEquipmentTrainControl );
        this.registControl( EPlayerWndType.WND_HERO_MAIN, CSkillUpControl );
        this.registControl( EPlayerWndType.WND_STONE, CEqustoneControl );
        this.addViewClassHandler( EPlayerWndType.WND_STONE, CEqustoneView );

        this.addViewClassHandler( EPlayerWndType.WND_PLAYER_HERO_GET, CPlayerHeroGetView );
//        this.registerBundle( EPlayerWndType.WND_PLAYER_TEAM_INFO, KOFSysTags.PLAYER_TEAM,
//                showPlayerTeam, hidePlayerTeam );
//        this.registerBundle( EPlayerWndType.WND_HERO_MAIN, KOFSysTags.ROLE, showHeroMain, hideHeroMain );
        this.addBundleData(EPlayerWndType.WND_HERO_MAIN, KOFSysTags.ROLE);

        (system as CPlayerSystem).listenEvent( _onDataUpdate );

        this.registTips( CSkillUpItemTips );
        this.registTips( CHeroTipsView );
        this.registTips( CHeroSkillTipsView );
        this.registTips( CHeroSkillTipsSmallView );
        this.registTips( CHeroCareerTipsView );

        return ret;
    }

    // =================================playerGet=====================
    /**
     * 打开格斗家获得界面
     * @param heroData
     */
    public function showHeroGetView( heroData : CPlayerHeroData ) : void {
        (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).addEventPopWindow( EPopWindow.POP_WINDOW_10, function():void{
//            show( EPlayerWndType.WND_PLAYER_HERO_GET, null, null, heroData );

            var view:CHeroGetViewHandler = system.getHandler(CHeroGetViewHandler) as CHeroGetViewHandler;
            if(view && !view.isViewShow)
            {
                view.viewId = EPopWindow.POP_WINDOW_10;
                view.data = heroData;
                view.addDisplay();
            }
        });
    }

    // =================================playerMain=====================
    public function showHeroMain(tab:int = -1, heroID:int = -1) : void {
        var playerData : CPlayerData = (system as CPlayerSystem).playerData;
        var initialArgs:Array;
        if (tab != -1 || heroID != -1) {
            initialArgs = [tab, heroID];
        }
        show(EPlayerWndType.WND_HERO_MAIN, initialArgs, null, playerData, -1);
    }

    public function heroMainChangeTab(tab:int, heroID:int) : void {
        var wnd : CPlayerHeroView = getWindow( EPlayerWndType.WND_HERO_MAIN ) as CPlayerHeroView;
        if ( wnd ) {
            wnd.changeTab( tab, heroID );
        }
    }

    public function refreshPlayerMainView( tab : int ) : void {
        var wnd : CPlayerHeroView = getWindow( EPlayerWndType.WND_HERO_MAIN ) as CPlayerHeroView;
        if ( wnd ) {
            wnd.refreshView( tab );
        }
    }

    // =================================show view=========================================

    //批量使用物品界面
    public function showMPBatchUse( data : Object ) : void {
        show( EPlayerWndType.WND_BATCH_USE_ITEM, null, null, data );
    }

    //祝福石界面
    public function showStone( data : Object ) : void {
        show( EPlayerWndType.WND_STONE, null, null, data );
    }

    // =================================data update======================================
    private function _onDataUpdate( e : CPlayerEvent ) : void {
        switch ( e.type ) {
            case CPlayerEvent.HERO_ADD:
                _onHeroAdd( e );
                break;
//            case CPlayerEvent.HERO_DATA:
//                _onHeroData( e );
//                break;
//            case CPlayerEvent.PLAYER_DATA:
//                _onPlayerDataUpdate( e );
//                break;
        }
    }

    private function _onDataBagUpdate( e : CBagEvent ) : void {
        if ( e.type == CBagEvent.BAG_UPDATE ) {
            _onHeroTrain();
        }
    }

    private function _onHeroAdd( e : CPlayerEvent ) : void {
        var wnd : CViewBase = getWindow( EPlayerWndType.WND_HERO_MAIN );
        if ( wnd ) {
            wnd.invalidate();
        }

        var heroData:CPlayerHeroData = e.data.heroData as CPlayerHeroData;
        var getWay:int = e.data.getWay as int;
        if(getWay == 0)// 普通招募
        {
            showHeroGetView(heroData);
        }
        else if(getWay == 1)
        {
            // do nothing
        }
    }

    private function _onHeroData( e : CPlayerEvent ) : void {
        var wnd : CViewBase = getWindow( EPlayerWndType.WND_HERO_MAIN );
        if ( wnd ) {
            wnd.invalidate();
        }
    }

    private function _onPlayerDataUpdate( e : CPlayerEvent ) : void {
        //格斗家、装备培养，升星、升品、升级
        _onHeroTrain();
    }

    private function _onHeroTrain() : void {
        var wnd : CViewBase = getWindow( EPlayerWndType.WND_HERO_MAIN );
        if ( wnd ) {
            wnd.invalidate();
        }
    }

}
}
