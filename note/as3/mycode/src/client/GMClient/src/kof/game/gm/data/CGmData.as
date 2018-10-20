//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/17.
 */
package kof.game.gm.data {

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CSkillList;
import kof.game.core.CGameObject;
import kof.game.gm.event.CGmEvent;
import kof.table.Skill;

public class CGmData extends CAbstractHandler {
    public function CGmData() : void {
        _propertyListData = new CGmPropertyData();
    }
    public function clear() : void {
        _selectHero = null;
        _propertyListData = null;
    }

    public function addFindUID(heroUID:int) : void {
        if (_selectUIDList.indexOf(heroUID) == -1) {
            _selectUIDList.push(heroUID);
        }
    }
    public function isUIDHasFind(heroUID:int) : Boolean {
        return _selectUIDList.indexOf(heroUID) != -1;
    }
    public function clearIDList() : void {
        _selectUIDList = new Array();
    }
    public function set selectHero(v:CGameObject) : void {
        if (v == null) {
            _selectHero = null;
            _selectUIDList = new Array();
            return ;
        }
        var isSameID:Boolean = _selectHero && CCharacterDataDescriptor.getID(_selectHero.data) == CCharacterDataDescriptor.getID(v.data);

        _selectHero = v;
        if (!isSameID) {
            _selectUIDList = new Array();
        }
        addFindUID(CCharacterDataDescriptor.getID(_selectHero.data));
        dispatchEvent(new CGmEvent(CGmEvent.EVENT_SELECT_HERO_DATA, _selectHero));
    }
    public function get selectHero() : CGameObject {
        if (_selectHero && _selectHero.isRunning == false) return null;
        return _selectHero;
    }
    public function get characterType() : int {
        if (selectHero) {
            return CCharacterDataDescriptor.getType(_selectHero.data);
        }
        return -1;
    }
    public function get selectUID() : int {
        if (selectHero) {
            return CCharacterDataDescriptor.getID(_selectHero.data)
        }
        return -1;
    }
    public function get selectType() : int {
        if (selectHero) {
            return CCharacterDataDescriptor.getType(_selectHero.data)
        }
        return -1;
    }

    // 获得选中角色的技能列表
    public function get skillList() : Array {
        if (selectHero) {
            var skList:CSkillList = (selectHero.getComponentByClass(CSkillList, false) as CSkillList);
            if (skList && skList.size > 0) {
                var ret:Array = new Array();
                var pTblSkill : IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.SKILL);
                for (var i:int = 0; i < skList.size; i++) {
                    var skillID:int = skList.getSkillIDByIndex(i);
                    var skill:Skill = pTblSkill.findByPrimaryKey(skillID);
                    if (skill) {
                        ret.push(skillID + "(" + skill.Name + ")");
                    }
                }
                return ret;
            }
        }
        return null;
    }

    public function get propertyListData() : CGmPropertyData {
        return _propertyListData;
    }
    private var _propertyListData:CGmPropertyData;
    private var _selectHero:CGameObject;
    private var _selectUIDList:Array; // 已查找过的武将ID列表
}
}
