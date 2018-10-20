//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm.view.gmView {

import kof.game.character.fight.buff.buffentity.CBuffAttModifiedProperty;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMonsterProperty;
import kof.game.common.view.event.CViewEvent;
import kof.game.core.CGameObject;
import kof.game.gm.event.EGmEventType;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.gm.GMPropertyViewUI;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.components.TextInput;

import morn.core.handlers.Handler;

public class CGmActionView extends CGmChildView {
    public function CGmActionView() {
        super();
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();
        _ui.action_move_pixel_txt.text = "100";
        _ui.action_use_skill_times_txt.text = "1";
        _ui.action_use_skill_cd_txt.text = "1";

    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }
    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
        _ui.action_select_btn.clickHandler = new Handler(_onSelect);
        _ui.action_select_id_btn.clickHandler = new Handler(_onSelectHero);
        _ui.action_select_comb_btn.clickHandler = new Handler(_onSelectComb);
        _ui.action_select_id_comb.selectHandler = new Handler(_onSelectCharacter);

        _ui.action_next_hero_btn.clickHandler = new Handler(_onNextHero);
        _ui.action_kill_hero_btn.clickHandler = new Handler(_onKillHero);
        _ui.action_move_up_btn.clickHandler = new Handler(_onMoveUp);
        _ui.action_move_down_btn.clickHandler = new Handler(_onMoveDown);
        _ui.action_move_left_btn.clickHandler = new Handler(_onMoveLeft);
        _ui.action_move_right_btn.clickHandler = new Handler(_onMoveRight);
        _ui.action_move_jump_btn.clickHandler = new Handler(_onMoveJump);
        _ui.action_move_flash_btn.clickHandler = new Handler(_onMoveFlash);

        _ui.action_change_ai_btn.clickHandler = new Handler(_onChangeAI);
        _ui.action_open_ai_btn.clickHandler = new Handler(_onOpenAI);
        _ui.action_close_ai_btn.clickHandler = new Handler(_onCloseAI);

        _ui.action_use_skill_btn.clickHandler = new Handler(_onUseSkill);
        _ui.action_select_skill_comb_btn.clickHandler = new Handler(_onSelectSkillComb);
         _ui.action_use_skill_id_txt.selectHandler = new Handler(_onSelectSkill);

        var propertyView:GMPropertyViewUI = _ui.action_property_view;
        propertyView.list.renderHandler = new Handler(_onRenderItem);
        _ui.action_refresh_hero_data_btn.clickHandler = new Handler(_onRefreshProperty);

    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        _ui.action_select_btn.clickHandler = null;
        _ui.action_select_id_btn.clickHandler = null;
        _ui.action_select_comb_btn.clickHandler = null;
        _ui.action_select_id_comb.selectHandler = null;

        _ui.action_next_hero_btn.clickHandler = null;
        _ui.action_kill_hero_btn.clickHandler = null;
        _ui.action_select_id_btn.clickHandler = null;

        _ui.action_move_up_btn.clickHandler = null;
        _ui.action_move_down_btn.clickHandler = null;
        _ui.action_move_left_btn.clickHandler = null;
        _ui.action_move_right_btn.clickHandler = null;
        _ui.action_move_jump_btn.clickHandler = null;
        _ui.action_move_flash_btn.clickHandler = null;

        _ui.action_change_ai_btn.clickHandler = null;
        _ui.action_open_ai_btn.clickHandler = null;
        _ui.action_close_ai_btn.clickHandler = null;
        _ui.action_use_skill_btn.clickHandler = null;
        _ui.action_select_skill_comb_btn.clickHandler = null;
         _ui.action_use_skill_id_txt.selectHandler = null;

        var propertyView:GMPropertyViewUI = _ui.action_property_view;
        propertyView.list.renderHandler = null;
        _ui.action_refresh_hero_data_btn.clickHandler = null;

    }
    private function _onSelect() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SELECT_PANEL, 2));
    }
    private function _onNextHero() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_NEXT_HERO));
    }
    private function _onKillHero() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_KILL_HERO));
    }
    private function _onSelectHero() : void {
        var heroID:int = (int)(_ui.action_select_id_txt.text);
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SELECT_HERO, heroID));
    }

    private function _onSelectComb() : void {
        _ui.action_select_id_comb.isOpen = !(_ui.action_select_id_comb.isOpen);
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SELECT_COMB));
    }
    private function _onSelectCharacter(idx:int) : void {
        var selectLabel:String = _ui.action_select_id_comb.selectedLabel;
        if (selectLabel == null || selectLabel.length == 0) return ; // 重新设置列表时, 会调用

        this._ui.action_select_comb_btn.label = selectLabel;
        var array:Array = selectLabel.split("(");
        if (array && array.length > 1) {
            var selectID:int = array[0];
            if (selectID > 0) {
                _ui.action_select_id_txt.text = selectID.toString();
                _onSelectHero();
            }
        }
    }
    private function _onMoveUp() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MOVE_TO, 0));
    }
    private function _onMoveDown() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MOVE_TO, 1));
    }
    private function _onMoveLeft() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MOVE_TO, 2));
    }
    private function _onMoveRight() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MOVE_TO, 3));
    }
    private function _onMoveJump() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MOVE_TO, 4));
    }
    private function _onMoveFlash() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_MOVE_TO, 5));
    }
    private function _onChangeAI() : void {
        var aiID:int = (int)(_ui.action_change_ai_id_txt.text);
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_CHANGE_AI, aiID));
    }
    private function _onOpenAI() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_OPEN_AI));
    }
    private function _onCloseAI() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_CLOSE_AI));
    }
    private function _onUseSkill() : void {
        var selectSkill:String = _ui.action_use_skill_id_txt.selectedLabel;
        var skillID:int = 0;
        if (selectSkill && selectSkill.length > 0) {
            var array:Array = selectSkill.split("(");
            if (array.length > 1) {
                skillID = (int)(array[0]);
            }
        }
        var times:int = (int)(_ui.action_use_skill_times_txt.text);
        var cd:Number = (Number)(_ui.action_use_skill_cd_txt.text);
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_USE_SKILL, [skillID, times, cd]));
    }
    private function _onSelectSkillComb() : void {
        _ui.action_use_skill_id_txt.isOpen = !(_ui.action_use_skill_id_txt.isOpen);
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EGmEventType.EVENT_SKILL_SELECT_COMB));
    }
    private function _onSelectSkill(idx:int) : void {
        var selectSkill:String = _ui.action_use_skill_id_txt.selectedLabel;
        _ui.action_select_skill_comb_btn.label = selectSkill;
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

        var heroData:CGameObject;
        if (_initialArgs && _initialArgs.length > 0) {
            heroData = _initialArgs[0];
        }
        var propertyView:GMPropertyViewUI = _ui.action_property_view;
        if (propertyView) {
            if (heroData) {
                var dataList:Array = new Array();
                var property:CCharacterProperty = heroData.getComponentByClass(CCharacterProperty, false) as CCharacterProperty;
                var pBuffProperty : CBuffAttModifiedProperty = heroData.getComponentByClass( CBuffAttModifiedProperty , false ) as CBuffAttModifiedProperty;
                var boShowBuff: Boolean = pBuffProperty != null;
                var hun: int = 100;

                if (property) {
                    var i:int = 0;
                    dataList[i++] = "攻击 : " + property.Attack + "+" + (!boShowBuff?0:pBuffProperty.Attack + ":"+ pBuffProperty.getPercentProperty("Attack")/hun + "%");
                    dataList[i++] = "防御 : " + property.Defense + "+" + (!boShowBuff?0:pBuffProperty.Defense+ ":" + pBuffProperty.getPercentProperty("Defense") /hun + "%");
                    dataList[i++] = "生命 : " + property.HP + "+"+ (!boShowBuff?0:pBuffProperty.HP + ":" + pBuffProperty.getPercentProperty("HP")/hun  + "%");
                    dataList[i++] = "暴击万分比 : " + property.CritChance + "+"+( !boShowBuff?0:pBuffProperty.CritChance+ ":" + pBuffProperty.getPercentProperty("CritChance")/hun  + "%");
                    dataList[i++] = "抗暴万分比 : " + property.DefendCritChance+ "+"+ (!boShowBuff?0:pBuffProperty.DefendCritChance+ ":" + pBuffProperty.getPercentProperty("DefendCritChance") /hun + "%");
                    dataList[i++] = "暴伤万分比 : " + property.CritHurtChance+ "+"+ (!boShowBuff?0:pBuffProperty.CritHurtChance + ":" + pBuffProperty.getPercentProperty("CritHurtChance")/hun  + "%");
                    dataList[i++] = "抗暴伤万分比 : " + property.CritDefendChance+ "+"+ (!boShowBuff?0:pBuffProperty.CritDefendChance + ":" + pBuffProperty.getPercentProperty("CritDefendChance") /hun + "%");
                    dataList[i++] = "格档减伤万分比 : " + property.BlockHurtChance + "+"+( !boShowBuff?0:pBuffProperty.BlockHurtChance + ":" + pBuffProperty.getPercentProperty("BlockHurtChance") /hun + "%");
                    dataList[i++] = "碾压格挡万分比 : " + property.RollerBlockChance + "+"+ (!boShowBuff?0:pBuffProperty.RollerBlockChance + ":" + pBuffProperty.getPercentProperty("RollerBlockChance") /hun + "%");
//                    dataList[i++] = "伤害加成万分比 : " + property.HurtAddChance+ "+"+ (!boShowBuff?0:pBuffProperty.HurtAddChance + ":" + pBuffProperty.getPercentProperty("HurtAddChance") /hun + "%");
//                    dataList[i++] = "伤害减免万分比 : " + property.HurtReduceChance+ "+"+ (!boShowBuff?0:pBuffProperty.HurtReduceChance + ":" + pBuffProperty.getPercentProperty("HurtReduceChance") /hun + "%");
                    dataList[i++] = "攻击值 : " + property.AttackPower;
                    dataList[i++] = "防御值 : " + property.DefensePower;
                    dataList[i++] = "怒气值 : " + property.RagePower;
                }
                propertyView.list.dataSource = dataList;
                propertyView.list.visible = true;
            } else {
                propertyView.list.visible = false;
            }
        }
        return true;
    }
    private function _onRenderItem(box:Box, idx:int) : void {
        var text:TextInput = box.getChildByName("txt") as TextInput;
        if (text == null) return ;
        var content:String = box.dataSource as String;
        if (content == null || content.length == 0) {
            text.visible = false;
            return ;
        }
        text.visible = true;

        text.text = content;
    }

    private function _onRefreshProperty() : void {
        this.invalidate();
    }
    public function setSelectCombData(dataList:Array) : void {
        _ui.action_select_id_comb.dataSource = dataList;
    }
    public function setSelectSkillCombData(dataList:Array) : void {
        _ui.action_use_skill_id_txt.dataSource = dataList;
    }
    public override function set enable(v:Boolean) : void {
        //if (enable == v) return ;
        super.enable = v;
        _ui.action_sub_box.visible = enable;
    }
    public function get movePixel() : int {
        var pixel:int = (int)(_ui.action_move_pixel_txt.text);
        return pixel;
    }
    public override function get panel() : Component { return _ui.action_box; }

}
}
