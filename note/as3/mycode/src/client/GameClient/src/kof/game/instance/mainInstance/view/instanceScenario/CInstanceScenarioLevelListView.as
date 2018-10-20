//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceScenario {

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.data.CErrorData;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;

import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.CInstanceIntroLockTips;
import kof.game.instance.mainInstance.view.CInstanceIntroTips;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.player.CPlayerSystem;
import kof.table.InstanceChapter;
import kof.ui.instance.InsranceBubblesDialogue2UI;
import kof.ui.instance.InsranceBubblesDialogueUI;
import kof.ui.instance.InstanceNoteUI;
import kof.ui.instance.InstanceScenarioUI;

import morn.core.components.Button;
import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.events.UIEvent;

import morn.core.handlers.Handler;

import morn.core.utils.ObjectUtils;

public class CInstanceScenarioLevelListView extends CChildView {
    public function CInstanceScenarioLevelListView() {
    }

    protected override function _onCreate() : void {

        _baseItemPosList = new Vector.<Point>(5);
        _baseDialogPosList = new Vector.<Point>(5);
        for (var i:int = 0; i < _baseItemPosList.length; i++) {
            var item:InstanceNoteUI = getItem(i+1);
            _baseItemPosList[i] = new Point(item.x, item.y);

            var dialogView:Component = _ui["dialog_" + (i+1)];
            _baseDialogPosList[i] = new Point(dialogView.x, dialogView.y);
        }

        _ui.ins_box_get_eff_clip.visible = false;
        _ui.ins_box_get_eff_clip.stop();
        _ui.ins_box_get_eff_clip2.visible = false;
        _ui.ins_box_get_eff_clip2.stop();

//        _onBgResize(null);
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        for (var i:int = 0; i < 5; i++) {
            var item:InstanceNoteUI = getItem(i+1);
            item.bg_img.addEventListener(MouseEvent.CLICK, this["_onClickLevel" + (i+1)]);
            item.bg_img.addEventListener(MouseEvent.MOUSE_MOVE, onRollMouse);
            item.bg_img.addEventListener(MouseEvent.MOUSE_OUT, onRollMouse);
            item.bg_img.addEventListener(MouseEvent.MOUSE_DOWN, onRollMouse);
        }

        _ui.extends_reward_btn1.addEventListener(MouseEvent.CLICK, _onClickExtendsReward);
        _ui.extends_reward_btn2.addEventListener(MouseEvent.CLICK, _onClickExtendsReward);
        _ui.level_get_reward1_btn.addEventListener(MouseEvent.CLICK, _onClickExtendsReward);
        _ui.level_get_reward2_btn.addEventListener(MouseEvent.CLICK, _onClickExtendsReward);

        _isShowTips = false;
    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
        for (var i:int = 0; i < 5; i++) {
            var item:InstanceNoteUI = getItem(i+1);
            item.bg_img.removeEventListener(MouseEvent.CLICK, this["_onClickLevel" + (i+1)]);
            item.bg_img.removeEventListener(MouseEvent.MOUSE_MOVE, onRollMouse);
            item.bg_img.removeEventListener(MouseEvent.MOUSE_OUT, onRollMouse);
            item.bg_img.removeEventListener(MouseEvent.MOUSE_DOWN, onRollMouse);
        }

        _ui.extends_reward_btn1.removeEventListener(MouseEvent.CLICK, _onClickExtendsReward);
        _ui.extends_reward_btn2.removeEventListener(MouseEvent.CLICK, _onClickExtendsReward);

        _ui.level_get_reward1_btn.removeEventListener(MouseEvent.CLICK, _onClickExtendsReward);
        _ui.level_get_reward2_btn.removeEventListener(MouseEvent.CLICK, _onClickExtendsReward);

        _isShowTips = true;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        // 宝箱, 预设为不可见, 精英副本没有宝箱
        _ui.level_get_reward1_btn.visible = false;
        _ui.level_get_reward2_btn.visible = false;
        _ui.extends_reward_btn1.visible = false;
        _ui.extends_reward_btn2.visible = false;


        var instanceData:CChapterInstanceData;
        var instanceList:Array = data.instanceDataManager.instanceData.instanceList.getByChapterID(data.curChapterData.instanceType, data.curChapterData.chapterID);

        var chapterRecord:InstanceChapter = data.curChapterData.chapterRecord;


//        data.curChapterData.chapterRecord.rewardUrl[0];

        var item:InstanceNoteUI;
        var preInstanceIsComplete:Boolean = true;
        var levelIndex:int = 0;
        for (var i:int = 0; i < 5; i++) {
            levelIndex = i+1;
            item = getItem(levelIndex);
            if (null == item) continue ;

            if (i < instanceList.length) {
                item.visible = true;
            } else {
                item.visible = false;
                continue;
            }

            item.pass_effect_clip.visible = false;
            item.pass_effect_clip.stop();

            instanceData = instanceList[i] as CChapterInstanceData;
            var errorData:CErrorData = data.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, 0, false, true);
            if (errorData.isError == false) {
                ObjectUtils.gray(item.bg_clip, false);
                ObjectUtils.gray(item.name_txt, false);
                ObjectUtils.gray(item.name_bg_clip, false);
                item.bg_img.url = CInstancePath.getInstanceNodeIcon(instanceData.icon);
            } else {
                ObjectUtils.gray(item.bg_clip, true);
                ObjectUtils.gray(item.name_txt, true);
                ObjectUtils.gray(item.name_bg_clip, true);
                item.bg_img.url = CInstancePath.getInstanceNodeIcon(instanceData.unOpenIcon);
            }
            item.star_list.renderHandler = new Handler(_onRenderStar);

            var instanceStatus:int = 0;
            if (instanceData.isServerData == true) {
                preInstanceIsComplete = true;
                // 已通关
                var starDataList:Array;
                starDataList = [1, 1, 1];
                for (var starIndex:int = 0; starIndex < instanceData.star; starIndex++) {
                    starDataList[starIndex] = 2;
                }
                item.star_list.dataSource = starDataList;
                item.new_effect_clip.visible = false;
                item.new_effect_clip.stop();
                instanceStatus = 1;
            } else {
                preInstanceIsComplete = false;
                // 未通关
                var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                var teamLevel:int = pPlayerSystem.playerData.teamData.level;
                if (instanceData.getIsOpenCondPass(teamLevel)) {
                    // 开启
                    item.star_list.dataSource = [1, 1, 1];

                    item.new_effect_clip.visible = true;
                    item.new_effect_clip.play();
                    instanceStatus = 2;
                } else {
                    // 未开启
                    item.star_list.dataSource = [0, 0, 0];
                    item.new_effect_clip.visible = false;
                    item.new_effect_clip.stop();
                    instanceStatus = 3;
                }
            }

            var isUnOpen:Boolean = false;
            var isPass:Boolean = instanceData.isCompleted;
            isUnOpen = errorData.isError;

            item.dataSource = instanceData;
            item.name_txt.text = instanceData.name;

            if (instanceData.isElite) {
                item.bg_clip.index = 1;
                item.name_bg_clip.index = 1;
            } else {
                if (i == instanceList.length - 1) {
                    item.bg_clip.index = 2;
                    item.name_bg_clip.index = 2;
                } else {
                    item.bg_clip.index = 0;
                    item.name_bg_clip.index = 0;
                }
            }

            if (instanceData.isElite) {
                // 宝箱
                var canGetEffect:FrameClip;
                var clickBtn:Image = null; // ui后来加了一个按钮, 实际点的是这个按钮, 其他的部分和以前一样
                var rewardBtn:Image = null;
                if (instanceData.rewardExtends > 0) {
                    if (levelIndex == 2) { // 暂时固定宝箱只有第2和第4关之后才有
                        clickBtn = _ui.extends_reward_btn1;
                        rewardBtn = _ui.level_get_reward1_btn;
                        canGetEffect = _ui.ins_box_can_get_eff_clip;
                    } else if (levelIndex == 4) {
                        clickBtn = _ui.extends_reward_btn2;
                        rewardBtn = _ui.level_get_reward2_btn;
                        canGetEffect = _ui.ins_box_can_get_eff_clip2;
                    }
                }
                if (rewardBtn) {
                    clickBtn.url = rewardBtn.url = instanceData.instanceRecord.ExtendsRewardIcon;
                    // 有宝箱
                    canGetEffect.visible = false;
                    canGetEffect.stop();
                    clickBtn.visible = rewardBtn.visible = true;
                    var status:int = CRewardTips.REWARD_STATUS_NOT_COMPLETED; // 未通关
                    if (instanceData.isServerData) {
                        if (instanceData.isDrawReard) {
                            status = CRewardTips.REWARD_STATUS_HAS_REWARD; // 已领
                            clickBtn.visible = false;
                        } else {
                            status = CRewardTips.REWARD_STATUS_CAN_REWARD;
                            // 可领
                            canGetEffect.visible = true;
                            canGetEffect.play();
                        }
                        ObjectUtils.gray(rewardBtn, false);
                        ObjectUtils.gray(clickBtn, false);

                    } else {
                        ObjectUtils.gray(rewardBtn, true);
                        ObjectUtils.gray(clickBtn, true);

                    }
                    rewardBtn.dataSource = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, instanceData.rewardExtends);
                    var tipsTitle:String = CLang.Get("instance_extends_reward_title", {v1:instanceData.name});
                    var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
                    rewardBtn.toolTip = new Handler(itemSystem.showRewardTips, [rewardBtn, [tipsTitle, status, 1]]);
                    clickBtn.toolTip = new Handler(itemSystem.showRewardTips, [rewardBtn, [tipsTitle, status, 1]]);
                }
            }
            // 专属关卡
            item.pro_img.visible = instanceData.instanceRecord.embattleHeroID[0] > 0;

            // 推荐
//            item.job_clip.index = instanceData.profession;
            var powerRecommend:int = instanceData.powerRecommend;
            item.recommon_txt.postfix = CLang.Get("common_battle_value");
            item.recommon_txt.text = powerRecommend.toString();
            item.recommon_bg.visible = item.recommon_title.visible = item.recommon_txt.visible = !isPass && !isUnOpen;
            item.recommendBox.centerX = item.recommendBox.centerX;

            item.x = _baseItemPosList[i ].x + chapterRecord.itemDeltaX[i];
            item.y = _baseItemPosList[i ].y + chapterRecord.itemDeltaY[i];

            // 气泡
            var dialogView:Component = _ui["dialog_" + (i+1)];
            dialogView.mouseEnabled = false;
            if (instanceData.dialogRecord) {
                dialogView.x = _baseDialogPosList[i ].x + instanceData.dialogRecord.DX;
                dialogView.y = _baseDialogPosList[i ].y + instanceData.dialogRecord.DY;
                dialogView.visible = instanceStatus == 2; // 开启未打

                if (dialogView is InsranceBubblesDialogueUI) {
                    (dialogView as InsranceBubblesDialogueUI).desc_txt.text = instanceData.dialogRecord.Desc;
                } else {
                    (dialogView as InsranceBubblesDialogue2UI).desc_txt.text = instanceData.dialogRecord.Desc;
                }
            } else {
                dialogView.visible = false;
            }
        }

        return true;
    }

    private function _onRenderStar(com:Component, idx:int) : void {
        if (!com) return ;

        com.visible = true;
        var starClip:Clip = com.getChildByName("star") as Clip;
        if (starClip) {
            if (com.dataSource == 0) {
                com.visible = false;
            } else if (com.dataSource == 1) {
                (starClip).index = 1;
            } else {
                (starClip).index = 0;
            }
        }
    }

    private function _onClickLevel1(e:MouseEvent) : void {
        _onClickLevelB(e, 1);
    }
    private function _onClickLevel2(e:MouseEvent) : void {
        _onClickLevelB(e, 2);
    }
    private function _onClickLevel3(e:MouseEvent) : void {
        _onClickLevelB(e, 3);
    }
    private function _onClickLevel4(e:MouseEvent) : void {
        _onClickLevelB(e, 4);
    }
    private function _onClickLevel5(e:MouseEvent) : void {
        _onClickLevelB(e, 5);
    }

    private function _hitTestItem(image:Image, stageX:Number, stageY:Number) : Boolean {
        if (image && image.bitmap && image.bitmap.bitmapData) {
            // 点的是头像的图片
            var p1:Point = new Point(0, 0);
            var p2:Point = new Point(stageX, stageY);
            p2 = image.globalToLocal(p2);

            var isHit:Boolean = image.bitmap.bitmapData.hitTest(p1, 0, p2);
            return isHit;
        }
        return false;
    }
    private function _onClickLevelB(e:MouseEvent, index:int) : void {
        var item:InstanceNoteUI = _ui["note" + (index) + "_item"];
        // 点的是头像的图片
        // 模拟发的事件没有stageXY
        if (!isNaN(e.stageX) && !isNaN(e.stageY)) {
            if ( false == _hitTestItem( item.bg_img, e.stageX, e.stageY ) ) {
                return;
            }
        }

//        e.stopImmediatePropagation();
        var instanceData:CChapterInstanceData = item.dataSource as CChapterInstanceData;
        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var teamLevel:int = pPlayerSystem.playerData.teamData.level;
        if (instanceData.isCompleted == false && instanceData.getIsOpenCondPass(teamLevel)) {
            if (item.pass_effect_clip.mc) {
                item.pass_effect_clip.visible = true; // todo
                item.pass_effect_clip.playFromTo(null, null, new Handler(function () : void {
                    item.pass_effect_clip.visible = false;
                    item.pass_effect_clip.stop();
                    rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_CLICK, [data, item.dataSource]));
                }));
            } else {
                rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_CLICK, [data, item.dataSource]));
            }
        } else {
            rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_CLICK, [data, item.dataSource]));
        }
    }
    private function onRollMouse(e:MouseEvent):void {
        var item:InstanceNoteUI = (((e.currentTarget as Image).parent.parent)) as InstanceNoteUI;
        var instanceData:CChapterInstanceData = item.dataSource as CChapterInstanceData;
        if (!item || !instanceData) {
            return ;
        }

        if ( e.type == MouseEvent.MOUSE_DOWN || e.type == MouseEvent.MOUSE_OUT) {
            item.dispatchEvent(new UIEvent(UIEvent.HIDE_TIP, null, true));
            _isShowTips = false;
            return ;
        }


        if ( false == _hitTestItem( item.bg_img, e.stageX, e.stageY ) ) {
            _isShowTips = false;
            item.dispatchEvent(new UIEvent(UIEvent.HIDE_TIP, null, true));
            return;
        }

        if (_isShowTips) {
            return ;
        }

        _isShowTips = true;
        e.stopImmediatePropagation();
        var isPass:Boolean = instanceData.isCompleted;
        var instanceName:String = instanceData.name;
        var power : int = instanceData.powerRecommend;
        var sPower:String = power.toString();
        var toolHanderl:Handler;
        var errorData:CErrorData = data.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, 0, false, true);
        if (errorData.isError == false) {
            var starCount : int = instanceData.star;

            var rewardDataList : CRewardListData;
            if (isPass) {
                rewardDataList = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, instanceData.reward);

            } else {
                rewardDataList = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, instanceData.rewardFirst);
            }
            toolHanderl = new Handler(addTips, [CInstanceIntroTips, item, [starCount, sPower, rewardDataList, instanceName, true, isPass]]);
        } else {
            // 未开启tips
            var openStringList:Array = instanceData.getOpenCondtionTipsList(data.instanceDataManager.playerData.teamData.level);
            toolHanderl = new Handler(addTips, [CInstanceIntroLockTips, item, [openStringList, sPower, instanceName, true]]);
        }

        item.dispatchEvent(new UIEvent(UIEvent.SHOW_TIP, toolHanderl, true));
    }

    private function _onClickExtendsReward(e:MouseEvent) : void {
        var btn:Component = e.currentTarget as Component;
//        var btn:Clip = e.currentTarget as Clip;
        var instanceData:CChapterInstanceData;
        var levelItem:InstanceNoteUI;
        var getEffect:FrameClip;
        if (btn == _ui.extends_reward_btn1 || btn == _ui.level_get_reward1_btn) {
            levelItem = getItem(2);
            getEffect = _ui.ins_box_get_eff_clip;

        } else {
            levelItem = getItem(4);
            getEffect = _ui.ins_box_get_eff_clip2;

        }
        if (levelItem && levelItem.dataSource) {
            instanceData = levelItem.dataSource as CChapterInstanceData;
            if (instanceData && instanceData.isServerData && instanceData.isDrawReard == false) {
                getEffect.visible = true;
                getEffect.playFromTo();
                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_CLICK_EXTENDS_REWARD, [instanceData]));
            } else {
                if (instanceData && instanceData.isServerData == false) {
                    uiCanvas.showMsgAlert(CLang.Get("common_cond_not_ok_reward"));
                } else {
                    uiCanvas.showMsgAlert(CLang.Get("common_have_get_reward"));
                }
            }
        }

        e.stopImmediatePropagation();
    }

    private function getItem(index:int) : InstanceNoteUI {
        if (_ui.hasOwnProperty("note" + (index) + "_item")) {
            return _ui["note" + (index) + "_item"];
        }
        return null;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get _ui() : InstanceScenarioUI {
        return rootUI as InstanceScenarioUI;
    }

    private var _isShowTips:Boolean = false;

    private var _baseItemPosList:Vector.<Point>;
    private var _baseDialogPosList:Vector.<Point>;

}
}
