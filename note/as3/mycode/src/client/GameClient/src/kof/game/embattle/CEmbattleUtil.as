//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/20.
 */
package kof.game.embattle {

import kof.framework.CAbstractHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.table.InstanceContent;

public class CEmbattleUtil extends CAbstractHandler {
    public function CEmbattleUtil() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    // 获得当前副本格斗家出战列表ID, 必须要副本里调用
    public function getHeroIDListInEmbattleByCurrentInstance() : Array {
        var list:Array = null;

        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem && pInstanceSystem.instanceContent) {
            list = _getHeroIDListInEmbattleByInstanceB(pInstanceSystem.instanceContent);
        }

        return list;
    }

    // 获得某个副本格斗家出战列表ID
    public function getHeroIDListInEmbattleByCurrentInstanceID(instanceID:int) : Array {
        // 使用固定出 战格 斗家
        var list:Array = null;
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            var instanceData:CChapterInstanceData = pInstanceSystem.getInstanceByID(instanceID);
            list = _getHeroIDListInEmbattleByInstanceB(instanceData.instanceRecord);
        }
        return list;
    }
    private function _getHeroIDListInEmbattleByInstanceB(instanceContent:InstanceContent) : Array {
        var list:Array = new Array(3);
        var i:int = 0;

        if (EInstanceType.isMainCity(instanceContent.Type)) {
            return null;
        }

        // 使用固定出 战格 斗家
        if (instanceContent) {
            var staticEmbattleList:Array = instanceContent.embattleHeroID;
            if (staticEmbattleList && staticEmbattleList.length > 0 && staticEmbattleList[0] > 0) {
                for (i = 0; i < staticEmbattleList.length; i++) {
                    list[i] = staticEmbattleList[i];
                }
                return list;
            }
        }

        // 使用阵型格斗家
        if (instanceContent) {
            var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            var instanceType:int = instanceContent.Type;
            var embattleListData:CEmbattleListData = playerData.embattleManager.getByType(instanceType);
            if (embattleListData && embattleListData.list && embattleListData.list.length > 0) {
                var emData:CEmbattleData;
                for (i = 0; i < 3; i++) {
                    emData = null;
                    emData = embattleListData.getByPos(i + 1);
                    if (emData && emData.prosession > 0) {
                        list[i] = emData.prosession;
                    }
                }
                return list;
            }
        }

        return list;
    }
}
}
