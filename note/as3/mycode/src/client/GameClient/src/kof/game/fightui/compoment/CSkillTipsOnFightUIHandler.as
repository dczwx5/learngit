//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/12/12.
 */
package kof.game.fightui.compoment {

import QFLib.Utils.PathUtil;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.player.data.CSkillData;
import kof.table.FlagDes;
import kof.ui.master.jueseNew.panel.SkillTips2UI;
import kof.ui.master.jueseNew.panel.SkillTipsTagUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CSkillTipsOnFightUIHandler extends CViewHandler {

    private var _skillTipView : SkillTips2UI;

    public function CSkillTipsOnFightUIHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    public function addTips( skillData : CSkillData ):void {

        if( !_skillTipView ){
            _skillTipView = new SkillTips2UI();
            _skillTipView.listTag.renderHandler = new Handler( _renderSkillTag );
        }

        if( skillData.skillPosition == 5 ){//大招
            _skillTipView.txt_consume.text = '3点';
            _skillTipView.txt_consumeT.text = '怒气消耗：';
        }else{
            _skillTipView.txt_consume.text = String( skillData.activeSkillUp.consumeAP1 + skillData.activeSkillUp.consumeAP2 + skillData.activeSkillUp.consumeAP3 );
            _skillTipView.txt_consumeT.text = '能量消耗：';
        }

        _skillTipView.txt_name.text = skillData.pSkill.Name;
        _skillTipView.txt_lv.text = "等级：" + skillData.skillLevel;
        _skillTipView.txt_cd.text =  skillData.activeSkillUp.CD  + "s";

        _skillTipView.txt_desc.text = skillData.pSkill.Description;

        var str1 : String = Math.ceil( ( skillData.activeSkillUp.perDamageCount +  skillData.skillLevel * ( skillData.activeSkillUp.effectPar2 / 10000 ) ) * 100 ) + '%';
        var str2 : String = String( skillData.activeSkillUp.damageCount + skillData.activeSkillUp.hitTimes * skillData.skillLevel * skillData.activeSkillUp.effectPar1 );

//        _skillTipView.txt_vValueA.text = '对目标造成' + str1 + '+' + str2 + '点伤害';
        _skillTipView.txt_vValueA.visible = false;

        //技能标签
        var strII : String = skillData.pSkill.SkillFlag.toString(2) ;
        var aryII : Array = strII.split('' ).reverse();
        var tagIndex : int;
        var aryTag : Array = [];
        for( tagIndex = 0 ; tagIndex < aryII.length ; tagIndex++ ){
            if( int( aryII[tagIndex] == 1 )){
                aryTag.push( tagIndex + 1 );
            }
        }
        _skillTipView.listTag.dataSource = aryTag;


        App.tip.addChild( _skillTipView );

    }
    private function _renderSkillTag(item:Component, idx:int):void {
        if ( !(item is SkillTipsTagUI) ) {
            return;
        }
        var pSkillTipsTagUI : SkillTipsTagUI = item as SkillTipsTagUI;
        var pTable : IDataTable;
        var flagDes : FlagDes;
        if ( pSkillTipsTagUI.dataSource ) {
            pTable   = _databaseSystem.getTable( KOFTableConstants.FLAGDES );
            flagDes  = pTable.findByPrimaryKey( int( pSkillTipsTagUI.dataSource ) );
            if( flagDes ){
                pSkillTipsTagUI.img.url = PathUtil.getVUrl(flagDes.IconName);
            }
        }
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
