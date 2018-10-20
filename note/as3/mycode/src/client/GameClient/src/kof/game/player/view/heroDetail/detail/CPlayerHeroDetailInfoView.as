//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.player.view.heroDetail.detail {

import flash.events.Event;

import kof.game.common.view.CChildView;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;

public class CPlayerHeroDetailInfoView extends CChildView {
    public function CPlayerHeroDetailInfoView() {
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
        ui.info_face_img.url = null;
        // ui.info_history_btn.clickHandler = new Handler(_onClickHistory);
        ui.addEventListener(Event.RESIZE, _onResize);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        var ui:Object = _detailUI;
        ui.removeEventListener(Event.RESIZE, _onResize);

        // ui.info_history_btn.clickHandler = null;
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

        var ui:Object = _detailUI;

        var selectHeroData:CPlayerHeroData = _heroData;
        if (selectHeroData) {
            if (selectHeroData.lineTable) {
                // ui.info_talk_label.text = selectHeroData.lineTable.Lines[int(selectHeroData.lineTable.Lines.length * CMath.rand())];
                ui.info_desc_label.text = selectHeroData.lineTable.RoleSet;
            }

            ui.info_job_clip.index = selectHeroData.playerBasic.Profession;
            ui.info_star_list.repeatX = selectHeroData.star;
            ui.info_star_list.dataSource = new Array(selectHeroData.star);
//            ui.info_star_list.right = ui.info_star_list.right;

            ui.info_face_img.url = CPlayerPath.getUIHeroFacePath(selectHeroData.prototypeID);
            ui.info_name_img.url = CPlayerPath.getUIHeroNamePath(selectHeroData.prototypeID);
           // ui.info_name_img.y = _baseNameImageY - ui.info_name_img.displayHeight*0.5;
            var quality:int = selectHeroData.qualityLevelSubValue;
            ui.info_quality_clip.index = quality;
            ui.info_add_image.x = ui.info_name_img.x + ui.info_name_img.displayWidth/2 + 5;
            ui.info_quality_clip.x = ui.info_add_image.x + ui.info_add_image.displayWidth + 5;
            ui.info_job_clip.x = ui.info_name_img.x-ui.info_job_clip.width-ui.info_name_img.displayWidth/2-5;
            ui.info_star_list.x = ui.info_name_img.x - ui.info_name_img.displayWidth/2;

        }
        // ui.info_history_btn

        return true;

    }

    private function _onClickHistory() : void {

    }

    private function _onResize(e:Event) : void {
        var ui:Object = _detailUI;
        ui.info_add_image.x = ui.info_name_img.x + ui.info_name_img.displayWidth/2 + 5;
        ui.info_quality_clip.x = ui.info_add_image.x + ui.info_add_image.displayWidth + 5;
        ui.info_job_clip.x = ui.info_name_img.x-ui.info_job_clip.width-ui.info_name_img.displayWidth/2-5;
        ui.info_star_list.x = ui.info_name_img.x - ui.info_name_img.displayWidth/2;
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
