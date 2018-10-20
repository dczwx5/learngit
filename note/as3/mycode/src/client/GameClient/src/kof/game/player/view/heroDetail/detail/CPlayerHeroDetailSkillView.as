//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.player.view.heroDetail.detail {

import kof.game.common.view.CChildView;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.table.Skill;

import morn.core.components.Component;

public class CPlayerHeroDetailSkillView extends CChildView {
    public function CPlayerHeroDetailSkillView() {
        super();
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();
    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();

    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
        var ui:Object = _detailUI;
        // ui.skill_list.renderHandler = new Handler(_renderSkill);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        var ui:Object = _detailUI;
        // ui.skill_list.renderHandler = null;
    }
    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

//        var ui:Object = _detailUI;
//        var selectHeroData:CPlayerHeroData = _heroData;
//        if (selectHeroData) {
//            if (selectHeroData.skillRecord) {
//                ui.skill_list.dataSource = selectHeroData.skillRecord.SkillID;
//                ui.skill_list.visible = true;
//            } else {
//                ui.skill_list.visible = false;
//            }
//        }
        return true;
    }

    private function _renderSkill(item:Component, idx:int) : void {
        if (!(item is Object)) {
            return;
        }
        var pSkillItemUI:Object = item as Object;

         var pSkill:Skill = _playerData.skillTable.findByPrimaryKey(pSkillItemUI.dataSource);
        if(pSkill){
            pSkillItemUI.icon_img.url = CPlayerPath.getSkillBigIcon( pSkill.IconName );
            pSkillItemUI.icon_img.mask = pSkillItemUI.skill_mask;
            pSkillItemUI.lock_image.visible = false;
        }
    }
    private function get _playerData() : CPlayerData {
        return _data[0] as CPlayerData;
    }

    private function get _heroData() : CPlayerHeroData {
        return _data[1] as CPlayerHeroData;
    }
    private function get _ui() : Object {
        return (rootUI as Object).viewStack.items[EPlayerWndTabType.STACK_ID_HERO_WND_DETAIL] as Object;
    }
    private function get _detailUI() : Object {
        return _ui.viewStack.items[EPlayerWndTabType.STACK_ID_HERO_DETAIL_WND_INFO] as Object;
    }
}
}
