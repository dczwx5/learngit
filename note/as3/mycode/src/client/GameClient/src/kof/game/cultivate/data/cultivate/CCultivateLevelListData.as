//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/17.
 */
package kof.game.cultivate.data.cultivate {

import kof.data.CObjectListData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;

public class CCultivateLevelListData extends CObjectListData {
    public function CCultivateLevelListData() {
        super (CCultivateLevelData, CCultivateLevelData._layer);
    }

    public function getLevel(levelID:int) : CCultivateLevelData {
        return this.getByPrimary(levelID) as CCultivateLevelData;
    }

    public function get curOpenLevelIndex() : int {
        var index:int = 15;
        for (var i:int = 1; i <= 15; i++) {
            var levelData:CCultivateLevelData = getLevel(i);
            if (levelData.passed <= 0) {
                index = levelData.layer;
                break;
            }
        }
        return index;
    }
    public function get curOpenSectionIndex() : int {
        var curLevelIndex:int = curOpenLevelIndex;
        return getLevel(curLevelIndex).sectionID;
    }

    public function getSectionByLevelIndex(levelIndex:int) : int {
        return getLevel(levelIndex).sectionID;
    }

    public function get sectionTable() : IDataTable {
        if (!_sectionTable) {
            _sectionTable = _databaseSystem.getTable(KOFTableConstants.CULTIVATE_BASE);
        }
        return _sectionTable;
    }

    public function get curLevelData() : CCultivateLevelData {
        return getLevel(curOpenLevelIndex);
    }

    private var _sectionTable:IDataTable;
}
}
