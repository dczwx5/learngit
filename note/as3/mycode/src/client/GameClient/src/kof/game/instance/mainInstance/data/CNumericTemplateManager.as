//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/7.
 */
package kof.game.instance.mainInstance.data {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.table.NumericTemplate;

public class CNumericTemplateManager {
    public function CNumericTemplateManager(database:IDatabase) {
        _numericTemplateTable = database.getTable(KOFTableConstants.NUMERIC_TEMPLATE);
    }

    public function getNumericTemplate(templeteGroupID:int, type:int, profession:int) : NumericTemplate {
        if (_numericList == null) {
            _numericList = _numericTemplateTable.toVector();
        }

        var ret:NumericTemplate;
        for each (var numeric:NumericTemplate in _numericList) {
            if (numeric.Profession == profession && numeric.Type == type && templeteGroupID == numeric.TemplategroupID) {
                ret = numeric;
                break;
            }
        }
        return ret;
    }

    private var _numericTemplateTable:IDataTable;
    private var _numericList:Vector.<Object>;
}
}
