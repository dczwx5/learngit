//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/1.
 */
package kof.game.player.view.player {

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerHeroListData;

public class CTrainDataUtil {
    public static function getTrainData(system:CAppSystem, playerData:CPlayerData, heroID:int) : Array {
        var heroListData:CPlayerHeroListData = playerData.heroList; // 格斗家列表数据
        // var heroList:Array = heroListData.list;
        var heroData:CPlayerHeroData = heroListData.getHero(heroID);
        var pDB:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var playerTable:IDataTable = pDB.getTable(KOFTableConstants.PLAYER_BASIC);
        var pieceID:int = heroData.pieceID; // 碎片id
        // 当前碎片数量
        var piceData:CBagData = (system.stage.getSystem(CBagSystem).getBean(CBagManager) as CBagManager).getBagItemByUid(pieceID);
        var curPieceCount:int = 0;
        if(piceData)
        {
            curPieceCount = piceData.num;
        }
        var dataTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.ITEM);
        var bagManager:CBagManager = system.stage.getSystem(CBagSystem).getBean(CBagManager) as CBagManager;

        return [playerData,heroID,[pieceID,curPieceCount,playerTable],[dataTable,bagManager]];
    }

    public static function getEquipTrainData(system:CAppSystem, playerData:CPlayerData, heroID:int) : Array {
        var heroListData:CPlayerHeroListData = playerData.heroList; // 格斗家列表数据
        var heroData:CPlayerHeroData = heroListData.getHero(heroID);
        var equipList:Array = heroData.equipList.list; // 装备列表

        var itemTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.ITEM);
        var bagManager:CBagManager = system.stage.getSystem(CBagSystem).getBean(CBagManager) as CBagManager;
        var pDB:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var currencyTable:IDataTable = pDB.getTable(KOFTableConstants.CURRENCY);
        var equipQualityTable:IDataTable=pDB.getTable(KOFTableConstants.EquipUpQuality);

        return [playerData,heroID,equipList,[itemTable,bagManager,currencyTable,equipQualityTable]];
    }

}
}
