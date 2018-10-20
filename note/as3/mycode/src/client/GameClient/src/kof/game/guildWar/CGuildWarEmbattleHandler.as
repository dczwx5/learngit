//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/21.
 */
package kof.game.guildWar {

import flash.events.Event;

import kof.SYSTEM_ID;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.embattle.CEmbattleViewHandler;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.data.CGuildWarHeroStateData;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CHeroExtendsData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.InstanceType;

public class CGuildWarEmbattleHandler extends CAbstractHandler {
    public function CGuildWarEmbattleHandler()
    {
        super();
    }

    // 打开布阵界面
    public function openEmbattleView() : void
    {
        _setHeroListExtendsData();

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if( pSystemBundleCtx )
        {
            var database:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
            var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(EInstanceType.TYPE_GUILD_WAR);
            var fighterCount:int = 3;
            if (instanceTypeRecord)
            {
                fighterCount = instanceTypeRecord.embattleNumLimit;
            }

            var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
            var pEmbattleView:CEmbattleViewHandler = embattleSystem.getBean(CEmbattleViewHandler) as CEmbattleViewHandler;
            pEmbattleView.removeEventListener(Event.CLOSE, _onEmbattleCloseB);
            pEmbattleView.addEventListener(Event.CLOSE, _onEmbattleCloseB);
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
            pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args',[EInstanceType.TYPE_GUILD_WAR, fighterCount, true, true, true]);
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
        }

        _onUpdateView();
    }

    // 布阵界面关闭, 移除事件监听, 清除血条状态
    private function _onEmbattleCloseB(e:Event) : void
    {
        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        var pEmbattleView:CEmbattleViewHandler = embattleSystem.getBean(CEmbattleViewHandler) as CEmbattleViewHandler;
        pEmbattleView.removeEventListener(Event.CLOSE, _onEmbattleCloseB);

        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var heroList:Array = playerData.heroList.list;
        for each (var heroData:CPlayerHeroData in heroList)
        {
            heroData.extendsData = null;
        }
    }

    // 数据更新时, 更新布阵界面
    private function _onUpdateView() : void {
        // 更新heroListData
        // 这里更新了格斗家列表的数据，添加了extendsData
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var embattleList:CEmbattleListData = playerData.embattleManager.getByType(EInstanceType.TYPE_GUILD_WAR);
        if (!embattleList) return ;

        var hasChangeEmbattle:Boolean = false;
        var isInEmbattle:Boolean;

        var heroList:Array = _guildWarData.baseData.heroStateListData.list;
        for each (var guildWarHeroData:CGuildWarHeroStateData in heroList) {
            var pos:int = embattleList.getPosByHero(guildWarHeroData.profession);
            isInEmbattle = pos != -1;
            if (isInEmbattle && guildWarHeroData.hp == 0) {
                // 失败下阵
                isInEmbattle = false;
                embattleList.removeByPos(pos);
                hasChangeEmbattle = true;
            }
        }

        if (hasChangeEmbattle) {
            var pEmbattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
            if (pEmbattleSystem) {
                pEmbattleSystem.requestEmbattle(EInstanceType.TYPE_GUILD_WAR);
            }
        }
    }

    private function _setHeroListExtendsData() : void
    {
        // 更新heroListData
        // 这里更新了格斗家列表的数据，添加了extendsData
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var heroList:Array = playerData.heroList.list;
        var guildWarHeroData:CGuildWarHeroStateData;
        var extendsData:CHeroExtendsData;
        for each (var heroData:CPlayerHeroData in heroList)
        {
            if (heroData.extendsData && heroData.extendsData is CHeroExtendsData)
            {
                extendsData = heroData.extendsData as CHeroExtendsData;
            }
            else
            {
                extendsData = new CHeroExtendsData();
            }

            // hp
            guildWarHeroData = _guildWarData.baseData.heroStateListData.getHero(heroData.prototypeID);
            if (guildWarHeroData)
            {
                extendsData.hp = guildWarHeroData.hp;
            }
            else
            {
                extendsData.hp = heroData.propertyData.HP;
            }

            heroData.extendsData = extendsData;
        }
    }

    private function get _guildWarData():CGuildWarData
    {
        return (system as CGuildWarSystem).data;
    }
}
}
