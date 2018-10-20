//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/21.
 */
package kof.game.player.data {

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.vip.CVIPManager;
import kof.game.vip.CVIPSystem;
import kof.table.VipPrivilege;

public class CVipHelper extends CObjectData {
    public function CVipHelper() {

    }

    public function get resetEliteTotalCount() : int {
        var resetCount:int = 0;
        var vipRecord:VipPrivilege = vipPrivilegeRecord;

        if (vipRecord) {
            resetCount = vipRecord.eliteInstanceCountLimit + _instanceData.constant.INSTANCE_ELITE_RESET_NUM;
        } else {
            resetCount = _instanceData.constant.INSTANCE_ELITE_RESET_NUM;
        }
        return resetCount;
    }

    public function get isScenarioInstanceCanSweep10() : Boolean {
        var vipRecord:VipPrivilege = vipPrivilegeRecord;
        if (vipRecord) {
            return vipRecord.canSweepInstance > 0;
        }
        return false;
    }
    public function get vipLevelSweep10ScenarioInstance() : int {
        var dataTable:IDataTable = (_databaseSystem).getTable(KOFTableConstants.VIPPRIVILEGE);
        var min:int = 9999;

        if (dataTable) {
            var ret:Array = dataTable.findByProperty("canSweepInstance", 1);
            if (ret && ret.length > 0) {
                for each (var record:VipPrivilege in ret) {
                    if (min > record.level) {
                        min = record.level;
                    }
                }
            }
        }
        return min;

    }
    // buff免费重随次数
    public function get climpRandomBuffCount() : int {
        var vipRecord:VipPrivilege = vipPrivilegeRecord;
        if (vipRecord) {
            return vipRecord.dailyRerandTowerBuffNum;
        }
        return 0;
    }
    [Inline]
    public function get vipLv() : Number { return _rootData.data[_vipLv] ? _rootData.data[_vipLv] : 0; }
    public static const _vipLv : String = "vipLevel";

    [Inline]
    public function get vipSystem() : CVIPSystem {
        if (_vipSystem == null) {
            _vipSystem = (_databaseSystem as CAppSystem).stage.getSystem(CVIPSystem) as CVIPSystem;
        }
        return _vipSystem;
    }
    [Inline]
    public function get vipManager() : CVIPManager {
        return vipSystem.getBean(CVIPManager) as CVIPManager;
    }
    [Inline]
    public function get vipPrivilegeRecord() : VipPrivilege {
        if (_vipPrivilegeRecord == null || _vipPrivilegeRecord.level != vipLv) {
            _vipPrivilegeRecord = vipManager.getVipPriTableByID(vipLv);
        }
        return _vipPrivilegeRecord;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return _rootData as CPlayerData;
    }
    [Inline]
    private function get _instanceData() : CInstanceData {
        var instanceSystem:CInstanceSystem = (_databaseSystem as CAppSystem).stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (instanceSystem) {
            return instanceSystem.instanceData;
        }
        return null;
    }

    private var _vipSystem:CVIPSystem;

    private var _vipPrivilegeRecord:VipPrivilege;

}
}
