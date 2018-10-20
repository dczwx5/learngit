//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/29.
 */
package kof.game.instance.mainInstance.view.result {

import QFLib.Foundation.CMap;

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.game.Tutorial.CTutorSystem;

import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.view.result.winMovie.CInstanceWinShowDescEffectMovieCompoent;

import kof.game.instance.mainInstance.view.result.winMovie.CInstanceWinShowDescMovieCompoent;

import kof.game.instance.mainInstance.view.result.winMovie.CInstanceWinShowRoleMovieCompoent;

import kof.game.player.data.CPlayerHeroData;
import kof.ui.instance.InstanceWinDescUI;

import morn.core.components.Component;

public class CInstanceWinMovieProcess {
    public function CInstanceWinMovieProcess(view:CInstanceWinView) {
        _win = view;
    }

    private var _role1BoxBasePos:Point;
    private var _role2BoxBasePos:Point;
    private var _role3BoxBasePos:Point;
    private var _role11BoxBasePos:Point;
    private var _expComListBasePos:Vector.<Point>;

    private var _baseDataMap:CMap;

    private var _isFinish:Boolean;


    public function initial() : void {

        _baseDataMap = new CMap();


        var descViewUI:InstanceWinDescUI = _win._descView._ui;
        var saveList:Array = [descViewUI.star_box, descViewUI.cond_item1_box, descViewUI.cond_item2_box, descViewUI.cond_item3_box,
            descViewUI.exp_title_img, descViewUI.exp_line_img, descViewUI.reward_title_img, descViewUI.reward_line_img,
            descViewUI.rwd_img_1, descViewUI.rwd_count_img_1, descViewUI.rwd_img_2, descViewUI.rwd_count_img_2,  descViewUI.rwd_img_3, descViewUI.rwd_count_img_3];
        for each (var obj:Component in saveList) {
            _baseDataMap[obj] = {x:obj.x, y:obj.y, visible:obj.visible, scalc:obj.scale, alpha:obj.alpha};
        }

        _win.flashStage.addEventListener(MouseEvent.CLICK, _onClick);

        _win._roleView.visible = false;
        _win._descView.visible = false;

        // effect
//        _win._effectView._ui.up_img.visible = false;
//        _win._effectView._ui.down_img.visible = false;
//        _win._effectView._ui.up_img.y = -_win._effectView._ui.up_img.height;
//        _win._effectView._ui.down_img.y = _win._effectView._ui.height;
        _win._effectView._ui.win_box.visible = false;
        _win._effectView._ui.win_img.visible = false;
        _win._effectView._ui.line2_img.visible = false;
        _win._ui.say1_txt.visible = false;
        _win._ui.say2_txt.visible = false;
        _win._ui.say_bg_img.visible = false;
        _win._ui.say_bg_white_img.visible = false;
        _win._ui.say_box.alpha = 1;

        // role
        _role1BoxBasePos = new Point(_win._roleView.role1Box.x, _win._roleView.role1Box.y);
        _role2BoxBasePos = new Point(_win._roleView.role2Box.x, _win._roleView.role2Box.y);
        _role3BoxBasePos = new Point(_win._roleView.role3Box.x, _win._roleView.role3Box.y);
        _role11BoxBasePos = new Point(_win._roleView.roleWhiteBox.x, _win._roleView.roleWhiteBox.y);
        _win._roleView.role2Box.visible = true;
        _win._roleView.role3Box.visible = true;
        _win._roleView.role1Box.scale = 1.05;
        _win._roleView.roleWhiteBox.alpha = 1.0;
        _win._roleView.roleWhiteBox.scale = 1.05;

        // desc
        var descUI:InstanceWinDescUI = _win._descView._ui;
        descUI.cond_effect_1.visible = false;
        descUI.cond_effect_2.visible = false;
        descUI.cond_effect_3.visible = false;
        descUI.star_effect_1.visible = false;
        descUI.star_effect_2.visible = false;
        descUI.star_effect_3.visible = false;

        descUI.star_box.visible = false;
        descUI.cond_item1_box.visible = false;
        descUI.cond_item2_box.visible = false;
        descUI.cond_item3_box.visible = false;

        // exp
        descUI.exp_title_img.visible = false;
        descUI.exp_line_img.visible = false;
        descUI.lv_txt.visible = false;
        descUI.exp_bar.visible = false;
        descUI.exp_base_bar.visible = false;
        descUI.exp_add_txt.visible = false;
        descUI.exp_white_bar.visible = false;
        descUI.exp_up_img.visible = false;
        _expComListBasePos = new Vector.<Point>(6);
        _expComListBasePos[0] = new Point(descUI.exp_title_img.x, descUI.exp_title_img.y);
        _expComListBasePos[1] = new Point(descUI.exp_line_img.x, descUI.exp_line_img.y);
        _expComListBasePos[2] = new Point(descUI.lv_txt.x, descUI.lv_txt.y);
        _expComListBasePos[3] = new Point(descUI.exp_bar.x, descUI.exp_bar.y);
        _expComListBasePos[4] = new Point(descUI.exp_add_txt.x, descUI.exp_add_txt.y);
        _expComListBasePos[5] = new Point(descUI.exp_up_img.x, descUI.exp_up_img.y);

        // reward
        descUI.reward_title_img.visible = false;
        descUI.reward_line_img.visible = false;
        descUI.reward_list.visible = false;
        descUI.reward_effect_1.visible = false;
        descUI.reward_effect_2.visible = false;
        descUI.reward_effect_3.visible = false;
        descUI.reward_effect_4.visible = false;
        descUI.reward_effect_5.visible = false;
        descUI.reward_effect_6.visible = false;
        descUI.reward_list_mask_img.width = 1;
        descUI.first_pass_img.alpha = 0;
        descUI.first_pass_mv.visible = false;

        descUI.rwd_img_1.alpha = 0;
        descUI.rwd_img_2.alpha = 0;
        descUI.rwd_img_3.alpha = 0;
        descUI.rwd_count_img_1.alpha = 0;
        descUI.rwd_count_img_2.alpha = 0;
        descUI.rwd_count_img_3.alpha = 0;

        descUI.ok2_btn.visible = false;
        descUI.tutor_arrow_clip.visible = descUI.tutor_circle_clip.visible = false;
        descUI.ok_btn_tips.visible = false;
        descUI.ok_btn_tips_bg.visible = false;
        descUI.txt_countDown.visible = false;

        _win._ui.click_to_pass_txt.visible = true;
        _win._ui.click_to_pass_left_box.visible = true;

        _isFinish = false;
        _isForceStop = false;
    }

    public function dispose() : void {

        _win._roleView.role1Box.setPosition(_role1BoxBasePos.x, _role1BoxBasePos.y);
        _win._roleView.role2Box.setPosition(_role2BoxBasePos.x, _role2BoxBasePos.y);
        _win._roleView.role3Box.setPosition(_role3BoxBasePos.x, _role3BoxBasePos.y);
        _win._roleView.roleWhiteBox.setPosition(_role11BoxBasePos.x, _role11BoxBasePos.y);

        var descUI:InstanceWinDescUI = _win._descView._ui;
        descUI.exp_title_img.setPosition(_expComListBasePos[0].x, _expComListBasePos[0].y);
        descUI.exp_line_img.setPosition(_expComListBasePos[1].x, _expComListBasePos[1].y);
        descUI.lv_txt.setPosition(_expComListBasePos[2].x, _expComListBasePos[2].y);
        descUI.exp_bar.setPosition(_expComListBasePos[3].x, _expComListBasePos[3].y);
        descUI.exp_add_txt.setPosition(_expComListBasePos[4].x, _expComListBasePos[4].y);
        descUI.exp_up_img.setPosition(_expComListBasePos[5].x, _expComListBasePos[5].y);

    }

    public function start() : void {
        // 说话内容
        var mainHero:CPlayerHeroData = _win.mainHeroData;
        if (mainHero) {
            var strTalk:String = mainHero.lineTable.VictoryDescription;
            if (strTalk && strTalk.length > 0) {
                var lineList:Array = strTalk.split("\n");
                if (lineList.length > 1) {
                    _win._ui.say1_txt.text = lineList[0] as String;
                    _win._ui.say2_txt.text = lineList[1] as String;
                } else {
                    _win._ui.say1_txt.text = lineList[0] as String;
                    _win._ui.say2_txt.text = "";
                }
            }
        }

        _onStartFinish();

//        var componentList:Vector.<Component> = new Vector.<Component>(2);
//        componentList[0] = _win._effectView._ui.up_img;
//        componentList[1] = _win._effectView._ui.down_img;
//
//        _startMovie = new CInstanceWinStartMovieCompoent(_win, componentList, _onStartFinish);
//        _startMovie.start();
    }
    private function _onStartFinish() : void {
        if (isForceStop) {
            _onFinishMV();
            return
        }

        var componentList:Vector.<Component> = new Vector.<Component>(16);
        componentList[0] = _win._roleView._ui;
        componentList[1] = _win._roleView.role1Box;
        componentList[2] = _win._roleView.role2Box;
        componentList[3] = _win._roleView.role3Box;
        componentList[4] = _win._effectView._ui.win_box;
        componentList[5] = _win._effectView._ui.line1_img;
        componentList[6] = _win._effectView._ui.line2_img;
        componentList[7] = _win._effectView._ui.win_img;
        componentList[8] = _win._effectView._ui.win_effect_clip;
        componentList[9] = _win._roleView.roleWhiteBox;
        componentList[10] = _win._ui.say1_txt;
        componentList[11] = _win._ui.say_bg_img;
        componentList[12] = _win._ui.say_bg_white_img;
        componentList[13] = _win._ui.say_mask1_img;
        componentList[14] = _win._ui.say2_txt;
        componentList[15] = _win._ui.say_mask2_img;

        _showRoleMovie = new CInstanceWinShowRoleMovieCompoent(_win, componentList, _onShowRoleFinish, this);
        _showRoleMovie.start();
    }
    private function _onShowRoleFinish() : void {
        if (isForceStop) {
            _onFinishMV();
            return
        }

        var componentList:Vector.<Component> = new Vector.<Component>(16);
        componentList[0] = _win._roleView.role1Box;
        componentList[1] = _win._roleView.role2Box;
        componentList[2] = _win._roleView.role3Box;
        componentList[3] = _win._ui.say_box;
        componentList[4] = _win._descView._ui;
        componentList[5] = _win._descView._ui;

        componentList[6] = _win._descView._ui.cond_effect_1;
        componentList[7] = _win._descView._ui.cond_effect_2;
        componentList[8] = _win._descView._ui.cond_effect_3;
        componentList[9] = _win._descView._ui.star_effect_1;
        componentList[10] = _win._descView._ui.star_effect_2;
        componentList[11] = _win._descView._ui.star_effect_3;
        componentList[12] = _win._descView._ui.cond_item1_box;
        componentList[13] = _win._descView._ui.cond_item2_box;
        componentList[14] = _win._descView._ui.cond_item3_box;
        componentList[15] = _win._descView._ui.star_box;

        _showDescMovie = new CInstanceWinShowDescMovieCompoent(_win, componentList, _onShowDescFinish, this);
        _showDescMovie.start();
    }
    private function _onShowDescFinish() : void {
        if (isForceStop) {
            _onFinishMV();
            return
        }

        var componentList:Vector.<Component> = new Vector.<Component>(34);
        componentList[0] = _win._roleView.role1Box;
        componentList[1] = _win._roleView.role2Box;
        componentList[2] = _win._roleView.role3Box;
        componentList[3] = _win._ui.say_box;
        componentList[4] = _win._descView._ui;
        componentList[5] = _win._descView._ui;

        componentList[6] = _win._descView._ui.cond_effect_1;
        componentList[7] = _win._descView._ui.cond_effect_2;
        componentList[8] = _win._descView._ui.cond_effect_3;
        componentList[9] = _win._descView._ui.star_effect_1;
        componentList[10] = _win._descView._ui.star_effect_2;
        componentList[11] = _win._descView._ui.star_effect_3;
        componentList[12] = _win._descView._ui.cond_item1_box;
        componentList[13] = _win._descView._ui.cond_item2_box;
        componentList[14] = _win._descView._ui.cond_item3_box;
        componentList[15] = _win._descView._ui.star_box;
        componentList[16] = _win._descView._ui.exp_title_img;
        componentList[17] = _win._descView._ui.exp_line_img;
        componentList[18] = _win._descView._ui.lv_txt;
        componentList[19] = _win._descView._ui.exp_bar;
        componentList[20] = _win._descView._ui.exp_add_txt;
        componentList[21] = _win._descView._ui.exp_up_img;
        componentList[22] = _win._descView._ui.reward_title_img;
        componentList[23] = _win._descView._ui.reward_line_img;
        componentList[24] = _win._descView._ui.reward_list;
        componentList[25] = _win._descView._ui.reward_list_mask_img;
        componentList[26] = _win._descView._ui.reward_effect_1;
        componentList[27] = _win._descView._ui.reward_effect_2;
        componentList[28] = _win._descView._ui.reward_effect_3;
        componentList[29] = _win._descView._ui.reward_effect_4;
        componentList[30] = _win._descView._ui.reward_effect_5;
        componentList[31] = _win._descView._ui.reward_effect_6;
        componentList[32] = _win._descView._ui.exp_base_bar;
        componentList[33] = _win._descView._ui.exp_white_bar;
        componentList[34] = _win._descView._ui.first_pass_img;
        componentList[35] = _win._descView._ui.first_pass_mv;

        componentList[36] = _win._descView._ui.rwd_img_1;
        componentList[37] = _win._descView._ui.rwd_count_img_1;
        componentList[38] = _win._descView._ui.rwd_img_2;
        componentList[39] = _win._descView._ui.rwd_count_img_2;
        componentList[40] = _win._descView._ui.rwd_img_3;
        componentList[41] = _win._descView._ui.rwd_count_img_3;



        _showDescEffectMovie = new CInstanceWinShowDescEffectMovieCompoent(_win, componentList, _onFinishMV, this);
        _showDescEffectMovie.start();
    }

    private function _onFinishMV() : void {
        if (_isFinish) return ;
        _isFinish = true;
        _onShowDescEffectFinish();
    }
    private function _onShowDescEffectFinish() : void {
        // 写死第一关通关指引
        var pInstanceSystem:CInstanceSystem = (_win.system.stage.getSystem(CInstanceSystem) as CInstanceSystem);
        if (false == pInstanceSystem.instanceManager.dataManager.instanceData.isFirstLevelPass) {
            _win._descView._ui.tutor_arrow_clip.visible = _win._descView._ui.tutor_circle_clip.visible = true;
            // 上报
            var pTutorSystem:CTutorSystem = pInstanceSystem.stage.getSystem(CTutorSystem) as CTutorSystem;
            pTutorSystem.netHandler.sendTutorFinish(10831);
            pInstanceSystem.instanceManager.dataManager.instanceData.isFirstLevelPass = true;
        }

        _onFinal();

        _win.flashStage.removeEventListener(MouseEvent.CLICK, _onClick);

    }

    private function _onFinal() : void {
        _win._descView._ui.ok2_btn.visible = true;
        _win._descView._ui.ok_btn_tips.visible = true;
        _win._descView._ui.ok_btn_tips_bg.visible = false;

        _win._descView._ui.txt_countDown.visible = true;

        _win._descView.visible = true;
        _win._effectView.visible = true;
        _win._roleView.visible = true;
        _win._ui.visible = true;

        // 人物
        _win._roleView.role1Box.setPosition(_role1BoxBasePos.x - 200, _role1BoxBasePos.y);
        _win._roleView.role1Box.visible = true;
        _win._roleView.role1Box.scale = 1;
        _win._roleView.role2Box.visible = false;
        _win._roleView.role3Box.visible = false;
        _win._roleView.roleWhiteBox.visible = false;

        _win._ui.say_box.alpha = 0;

        var descView:InstanceWinDescUI = _win._descView._ui;
        // 星星
        _setBaseXAndVisible(descView.star_box);
        _win._descView.setStar(0);
        _win._descView.setStar(1);
        _win._descView.setStar(2);

        // 条件
        _setBaseXAndVisible(descView.cond_item1_box);
        _setBaseXAndVisible(descView.cond_item2_box);
        _setBaseXAndVisible(descView.cond_item3_box);

        _win._descView.setCondition(0);
        _win._descView.setCondition(1);
        _win._descView.setCondition(2);

        // 奖励
        _setBaseXAndVisible(descView.exp_title_img);
        _setBaseXAndVisible(descView.exp_line_img);
        _setBaseXAndVisible(descView.rwd_img_1, true);
        _setBaseXAndVisible(descView.rwd_count_img_1, true);
        _setBaseXAndVisible(descView.rwd_img_2, true);
        _setBaseXAndVisible(descView.rwd_count_img_2, true);
        _setBaseXAndVisible(descView.rwd_img_3, true);
        _setBaseXAndVisible(descView.rwd_count_img_3, true);
        _setBaseXAndVisible(descView.reward_title_img);
        _setBaseXAndVisible(descView.reward_line_img);

        // 首通
        if (descView.first_pass_img.visible) {
            descView.first_pass_img.alpha = 1;
        }
        _win._ui.click_to_pass_txt.visible = false;
        _win._ui.click_to_pass_left_box.visible = false;

        descView.reward_list.visible = true;
        descView.reward_list_mask_img.setPosition(descView.reward_list.x, descView.reward_list.y);
        descView.reward_list_mask_img.width = descView.reward_list.width;
    }

    private function _setBaseXAndVisible(comp:Component, setAlpha:Boolean = false) : void {
        var objData:Object = _baseDataMap[comp];
        comp.x = objData.x;
        comp.visible = true;
        if (setAlpha) {
            comp.alpha = 1;
        }
    }

    private function _onClick(e:MouseEvent) : void {
        _isForceStop = true;
    }

    public function get isForceStop() : Boolean {
        return _isForceStop;
    }

    private var _win:CInstanceWinView;

//    private var _startMovie:CInstanceWinStartMovieCompoent;
    private var _showRoleMovie:CInstanceWinShowRoleMovieCompoent;
    private var _showDescMovie:CInstanceWinShowDescMovieCompoent;
    private var _showDescEffectMovie:CInstanceWinShowDescEffectMovieCompoent;

    private var _isForceStop:Boolean;
}
}
