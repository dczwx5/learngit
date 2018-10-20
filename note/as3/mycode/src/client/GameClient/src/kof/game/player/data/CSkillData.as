//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/28.
 */
package kof.game.player.data {

import flash.profiler.showRedrawRegions;

import kof.data.CObjectData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.table.ActiveSkillUp;
import kof.table.PassiveSkillUp;
import kof.table.Skill;

public class CSkillData extends CObjectData {

    public var pSkill : Skill;
    public var activeSkillUp : ActiveSkillUp;
    public var passiveSkillUp : PassiveSkillUp;
    private static const ACTIVE_SKILL_ARY : Array = [2,3,4,5];
    private static const PASSIVE_SKILL_ARY : Array = [7,8,9,10,11,12,13];
    private var pTable : IDataTable;
    private var isInit : Boolean = true;

    public function CSkillData() {
        this.addChild(CSkillSlotListData);
    }

    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (skillSlotInfo) slotListData.updateDataByData(skillSlotInfo);

        if( !isInit ) return;
        isInit = false;
        if( ACTIVE_SKILL_ARY.indexOf( skillPosition ) != -1 ){
            if( !pSkill ){
                pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL );
                pSkill = pTable.findByPrimaryKey( skillID );
            }
            if( !activeSkillUp ){
                pTable  = _databaseSystem.getTable( KOFTableConstants.ACTIVE_SKILL_UP );
                activeSkillUp = pTable.findByPrimaryKey( skillID );
            }
        }else if( PASSIVE_SKILL_ARY.indexOf( skillPosition ) != -1 ){
            if( !passiveSkillUp ){
                pTable  = _databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_UP );
                passiveSkillUp = pTable.findByPrimaryKey( skillID );
            }
        }
    }

    public function get skillID() : int { return _data[_skillID]; }
    public function get skillLevel() : int { return _data[_skillLevel]; }
    public function set skillLevel( value : int ) : void { _data[_skillLevel] = value ; }
    public function get skillPosition() : int { return _data[_skillPosition]; }
    public function get skillSlotInfo() : Array { return _data[_skillSlotInfo]; }


    public static const _skillID:String = "skillID";
    public static const _skillLevel:String = "skillLevel";
    public static const _skillPosition:String = "skillPosition";
    public static const _skillSlotInfo:String = "skillSlotInfo";

    public function get slotListData() : CSkillSlotListData { return getChild(0) as CSkillSlotListData; }

}
}
