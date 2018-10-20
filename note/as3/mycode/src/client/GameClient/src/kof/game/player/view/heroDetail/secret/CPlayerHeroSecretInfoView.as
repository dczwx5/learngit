//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.player.view.heroDetail.secret {

import QFLib.Math.CMath;

import flash.events.Event;

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.table.PlayerLines;

public class CPlayerHeroSecretInfoView extends CChildView {
    public function CPlayerHeroSecretInfoView() {
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

        var ui:Object = _serectUI;
        ui.info_face_img.url = null;
        // ui.info_history_btn.clickHandler = new Handler(_onClickHistory);
        ui.addEventListener(Event.RESIZE, _onResize);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        var ui:Object = _serectUI;
        ui.removeEventListener(Event.RESIZE, _onResize);

        // ui.info_history_btn.clickHandler = null;
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

        var ui:Object = _serectUI;

        var selectHeroData:CPlayerHeroData = _heroData;
        if (selectHeroData) {
            if (selectHeroData.lineTable) {
                 ui.info_talk_label.text = selectHeroData.lineTable.Lines[int(selectHeroData.lineTable.Lines.length * CMath.rand())];
                // ui.info_desc_label.text = selectHeroData.lineTable.RoleSet;
            }
            /**
             *
             * 注释2017/4/25 策划删除了星级、职业、品质资源
             *
             * 修改者 yili
             *
             * */
//            ui.property_battle_value_num.num = selectHeroData.battleValue;
//
//            ui.info_job_clip.index = selectHeroData.playerBasic.Profession;
//            ui.info_star_list.repeatX = selectHeroData.star;
//            ui.info_star_list.dataSource = new Array(selectHeroData.star);
//            ui.info_star_list.right = ui.info_star_list.right;

            ui.info_face_img.url = CPlayerPath.getUIHeroFacePath(selectHeroData.prototypeID);
            ui.info_name_img.url = CPlayerPath.getUIHeroNamePath(selectHeroData.prototypeID);
           // ui.info_name_img.y = _baseNameImageY - ui.info_name_img.displayHeight*0.5;
            var quality:int = selectHeroData.qualityLevelSubValue;
//            ui.info_quality_clip.index = quality;
//            ui.info_add_image.x = ui.info_name_img.x + ui.info_name_img.displayWidth/2 + 5;
//            ui.info_quality_clip.x = ui.info_add_image.x + ui.info_add_image.displayWidth + 5;
//            ui.info_job_clip.x = ui.info_name_img.x-ui.info_job_clip.width-ui.info_name_img.displayWidth/2-5;

            //
            var playerlines:PlayerLines = selectHeroData.lineTable;
            ui.desc_txt.text = playerlines.RoleExpreience;
            ui.fight_style_txt.text = CLang.Get("sceret_fight_style") + playerlines.FightStyles;
            ui.birth_txt.text = CLang.Get("sceret_birth") + playerlines.RoleBirth;
            ui.blood_txt.text = CLang.Get("sceret_blood") + playerlines.RoleBlood;
            ui.height_txt.text = CLang.Get("sceret_height") + playerlines.RoleHeight;
            ui.weight_txt.text = CLang.Get("sceret_weight") + playerlines.RoleWeight;
            ui.bwh_txt.text = CLang.Get("sceret_bwh") + playerlines.Rolebwh;
            ui.hate_txt.text = CLang.Get("sceret_hate") + playerlines.Roledislike;
            ui.like_food_txt.text = CLang.Get("sceret_like_food") + playerlines.RoleLikefood;
            ui.hobbies_txt.text = CLang.Get("sceret_hobbies") + playerlines.RoleHobbies;
            ui.important_txt.text = CLang.Get("sceret_important") + playerlines.Roleimportant;
            ui.set_txt.text = playerlines.RoleSet;
        }
        // ui.info_history_btn

        return true;

    }
    private function _onResize(e:Event) : void {
        var ui:Object = _serectUI;
        /**
         *
         * 注释2017/4/25 策划删除了星级、职业、品质资源
         *
         * 修改者 yili
         *
         * */
//        ui.info_add_image.x = ui.info_name_img.x + ui.info_name_img.displayWidth/2 + 5;
//        ui.info_quality_clip.x = ui.info_add_image.x + ui.info_add_image.displayWidth + 5;
//        ui.info_job_clip.x = ui.info_name_img.x-ui.info_job_clip.width-ui.info_name_img.displayWidth/2-5;
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
    private function get _serectUI() : Object {
        return _ui.viewStack.items[EPlayerWndTabType.STACK_ID_HERO_DETAIL_WND_SECRET] as Object;
    }
}
}
