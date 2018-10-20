//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/24.
 */
package kof.game.player.view.skillup {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.common.tips.ITips;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CSkillData;
import kof.table.BreachLvConst;

import morn.core.components.Component;

public class CSkillUpItemTips extends CViewHandler implements ITips {
    public function CSkillUpItemTips() {
        super();
    }
    private var _ui:Object;
    private var _sourceItem:Component;
    private var _skillData:CSkillData;

    public function addTips(box:Component, args:Array = null) : void {
        if( !_ui ){
            _ui = new Object();
        }
        _sourceItem = box;
        if(_sourceItem.dataSource){
            _skillData = _sourceItem.dataSource as CSkillData;
            if( _skillData.pSkill ){
                if(_skillData.pSkill){
                    _ui.txt_name.text = _skillData.pSkill.Name;
                    _ui.mc_item.img.url = CPlayerPath.getSkillBigIcon( _skillData.pSkill.IconName );

                    _ui.txt_cont.text = _skillData.pSkill.Description;
                }
            }else if( _skillData.passiveSkillUp ){
                _ui.txt_name.text = _skillData.passiveSkillUp.skillname;
                _ui.mc_item.img.url = CPlayerPath.getPassiveSkillBigIcon( _skillData.passiveSkillUp.icon );

                _ui.txt_cont.text = _skillData.passiveSkillUp.skillDesc;
            }
            _ui.txt_lv.text = "等级：" + _skillData.skillLevel;
            _skillData.skillPosition == 5 ? _ui.mc_item.clip_bg.index = 1 : _ui.mc_item.clip_bg.index = 0;

            var i:int;
            var str : String = '';
            for( i = 1 ; i <= 3 ; i++ ){
                var obj : Object = getPositionInfo(i);
                if( obj ){
                    if( obj.isBreak ){
                        if( _skillData.activeSkillUp ){
                            str = _skillData.activeSkillUp['emittereffectdesc' + i];
                        }else if( _skillData.passiveSkillUp ){
                            str = _skillData.passiveSkillUp['emittereffectdesc' + i];
                        }
                        _ui['txt_' + i ].text = "<font color='#ffeaa9'>" +  str +  "</font>";;
                    }else if( obj.isActive ){
                        _ui['txt_' + i ].text = "<font color='#ff0000'>< 尚未突破 ></font>";
                    }
                }else{
                    var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.BREACH_LV_CONST );
                    var breachLvConst : BreachLvConst = pTable.findByPrimaryKey( 1 );
                    _ui['txt_' + i ].text = "<font color='#ff0000'>技能等级到达" + breachLvConst['needSkillLv' + i] + "级自动开启</font>";
                }



            }


//            App.tip.addChild(_ui);
        }
    }

    private function getPositionInfo( i : int ):Object{
        for each( var obj : Object in _skillData.slotListData.list ){
            if( obj.position == i ){
                return obj;
                break;
            }
        }
        return null;
    }

    public function hideTips():void{
        _ui.remove();
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
