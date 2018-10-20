//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.lobby {

import kof.framework.CAbstractHandler;
import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.util.CAssertUtils;

/**
 * 主界面中玩家信息管理控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPlayerInfoInLobbyHandler extends CAbstractHandler {

    /**
     * Creates a new CPlayerInfoInLobbyHandler.
     */
    public function CPlayerInfoInLobbyHandler() {
        super();
    }

    /**
     * @inheritDoc
     */
    override public function dispose() : void {
        super.dispose();
        this.detachEventListeners();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.initialize();
        return ret;
    }

    protected function initialize() : Boolean {
        this.attachEventListeners();
        return true;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        this.detachEventListeners();
        return ret;
    }

    protected function attachEventListeners() : void {
        var pPlayerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;

        CAssertUtils.assertNotNull( pPlayerSystem );

        pPlayerSystem.addEventListener( CPlayerEvent.PLAYER_DATA, _onPlayerDataUpdated, false, CEventPriority.DEFAULT,
                true );
    }

    protected function detachEventListeners() : void {
        var pPlayerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;

        CAssertUtils.assertNotNull( pPlayerSystem );

        pPlayerSystem.removeEventListener( CPlayerEvent.PLAYER_DATA, _onPlayerDataUpdated );
    }

    override protected virtual function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );

        this._onPlayerDataUpdated( null );
    }

    public function invalidate() : void {
        var pData : CPlayerData = null;
        var pPlayerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
        if ( pPlayerSystem ) {
            pData = pPlayerSystem.playerData;
        }
        if ( !pData )
            return;

        var pHeadView : CPlayerHeadViewHandler = system.getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler;
        if ( pHeadView ) {
            pHeadView.playerName = pData.teamData.name;
            pHeadView.vipLevel = pData.vipData.vipLv;
            pHeadView.level = pData.teamData.level;
//            pHeadView.fightScore = pData.teamData.battleValue;
            if(pHeadView.fightScore > pData.teamData.battleValue)
            {
                pHeadView.fightScore = pData.teamData.battleValue;
            }
            pHeadView.money = pData.currency.blueDiamond;
            pHeadView.bindingMoney = pData.currency.purpleDiamond;
            pHeadView.gold = pData.currency.gold;
            pHeadView.strength = pData.vitData.physicalStrength;
            pHeadView.strengthMax = pData.vitMax;
            pHeadView.expCurr = pData.teamData.exp;
            pHeadView.expMax = pData.nextLevelExpCost;

            if ( pData.teamData.useHeadID )
                pHeadView.headIcon = "icon/role/ui/head_icon/big_" + pData.teamData.useHeadID + ".png";
            else
                pHeadView.headIcon = "";

            pHeadView.invalidate();
        }
    }

    private function _onPlayerDataUpdated( event : CPlayerEvent ) : void {
        LOG.logMsg( "PLAYER DATA EVENT UPDATED." );

        this.invalidate();
    }

}
}
// vi:ft=as3 ts=4 sw=4 expandtab tw=120
