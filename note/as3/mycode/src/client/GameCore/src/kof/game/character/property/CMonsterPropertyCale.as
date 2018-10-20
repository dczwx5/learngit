//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/1/3.
 */
package kof.game.character.property {

import kof.game.character.property.interfaces.ICalcProperty;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.instance.IInstanceFacade;
import kof.table.Monster;
import kof.table.MonsterProperty;
import kof.table.NumericTemplate;


public class CMonsterPropertyCale implements ICalcProperty {
    public function CMonsterPropertyCale(instanceFacade:IInstanceFacade = null , database:IDatabase = null, monsterRecord:Monster = null) {
        _database = database;
        _monsterRecord = monsterRecord;
        _instanceFacade = instanceFacade;
    }

    // =================================================属性计算================================================================
    public function calcProperty() : CBasePropertyData {
        var monsterPropertyData:CMonsterPropertyData;
        var numeric:NumericTemplate = _instanceFacade.getNumericTemplate(_monsterRecord.Type, _monsterRecord.Profession);
        // if (numeric) {
        var monsterPropertyTable:IDataTable = _database.getTable(KOFTableConstants.MONSTER_PROPERTY);
        var baseMonsterPropertyRecord:MonsterProperty = monsterPropertyTable.findByPrimaryKey(_monsterRecord.TemplateID);
        // 根据副本关化的模板数据
        monsterPropertyData = new CMonsterPropertyData();
        {
            monsterPropertyData.rageRestoreComboInterval = _instanceFacade.rageRestoreComboInterval;
        }
        monsterPropertyData.addBaseTemplate(baseMonsterPropertyRecord);

        // add by instance property : 兼容单机没有副本类型的情况
        if (_monsterRecord.Usingtemplate != 0 &&  numeric) {
            var growTemplateMonsterRecord:MonsterProperty = monsterPropertyTable.findByPrimaryKey(numeric.MonsterpropertyID);
            var difficulty:Number = _instanceFacade.instanceContent.difficulty;
            monsterPropertyData.addGrowTemplate(growTemplateMonsterRecord, difficulty);
        }

        return monsterPropertyData;
    }

    public function getMonsterPropertyByTemplateID( _database : IDatabase ,  templateID : int , pInstanceSystem : IInstanceFacade ) : CBasePropertyData{
        var monsterPropertyData : CMonsterPropertyData;
        var baseMonsterPropertyRecord:MonsterProperty = _database.getTable( KOFTableConstants.MONSTER_PROPERTY ).findByPrimaryKey( templateID );
        // 根据副本关化的模板数据
        monsterPropertyData = new CMonsterPropertyData();
        {
            if( pInstanceSystem )
                monsterPropertyData.rageRestoreComboInterval = pInstanceSystem.rageRestoreComboInterval;
        }
        monsterPropertyData.addBaseTemplate(baseMonsterPropertyRecord);
        return monsterPropertyData;
    }

    private var _monsterRecord:Monster;
    private var _instanceFacade:IInstanceFacade;
    private var _database:IDatabase;
}
}
