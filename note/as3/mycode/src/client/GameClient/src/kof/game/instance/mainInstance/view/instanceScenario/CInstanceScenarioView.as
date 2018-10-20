//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceScenario {

import flash.events.MouseEvent;

import kof.game.common.CLang;

import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.ui.instance.InstanceScenarioUI;

import morn.core.components.Image;

import morn.core.handlers.Handler;

public class CInstanceScenarioView extends CRootView {


    public function CInstanceScenarioView() {
        super(InstanceScenarioUI, [CInstanceScenarioPageView, CInstanceScenarioLevelListView,
            CInstanceScenarioRewardView, CInstanceScenarioGoldInfoView, CInstanceScenarioExtraView, CInstanceEffectComponent], EInstanceWndResType.INSTANCE_SCENARIO, false)
    }

    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _ui.bg_elite_img.visible = false;
        for (var i:int = 0; i < NUM_MAP_BG; i++) {
            var bgImg:Image = getBgImage(i);
            if (bgImg) {
                bgImg.visible = false;
            }
        }

        _ui.left_btn.clickHandler = new Handler(_onLeft);
        _ui.right_btn.clickHandler = new Handler(_onRight);
        _ui.embattle_btn.clickHandler = new Handler(_onEmbattle);
        rootView.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

        _isFirstSetData = true;

        _ui.close_btn2.clickHandler = new Handler(this._onClose);
        _ui.one_key_get_reward_btn.visible = false;

        this.listStageClick = true;

        system.stage.getSystem(CPlayerSystem ).dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOWHIDE_COMBAT_EFFECT, false));
        _isFirst = true;
    }
    protected override function _onHide() : void {
        if (_ui) {
            _ui.left_btn.clickHandler = null;
            _ui.right_btn.clickHandler = null;
            _ui.embattle_btn.clickHandler = null;
        }

        if (rootView) rootView.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        system.stage.getSystem(CPlayerSystem ).dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOWHIDE_COMBAT_EFFECT, true));
    }

    private var _isFirst:Boolean;
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFirst) {
            _isFirst = false;
            if (data.instanceDataManager.instanceData.mainChapterOpenFlag) {
                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_NEW_CHAPTER_OPEN, data));
            }
        }

        for (var i:int = 0; i < NUM_MAP_BG; i++) {
            var bgImg:Image = getBgImage(i);
            if (bgImg) {
                bgImg.visible = false;
            }
        }
        _ui.line_img_1.visible = false;

        if (data.instanceType == EInstanceType.TYPE_MAIN) {
            _ui.hero_battle_value_txt.visible = false;
//            _ui.one_key_get_reward_btn.visible = true;
            // 小红点
            _ui.img_red1.visible = data.instanceDataManager.instanceData.chapterList.isScenarioHasReward();

            _ui.scenario_title_img.visible = true;
            _ui.elite_title_img.visible = false;

            // 设置背景
            var firstChapter:CChapterData = data.instanceDataManager.instanceData.chapterList.getFirstChapter(data.instanceType);
            var subValue:int = data.curChapterData.chapterID - firstChapter.chapterID;
            var bgImgIndex:int = subValue % NUM_MAP_BG;
            getBgImage(bgImgIndex).visible = true;

            _ui.bg_elite_img.visible = false;
            _ui.pos_img.visible = true;
        } else {
//            _ui.one_key_get_reward_btn.visible = false;
            // 小红点
            _ui.img_red1.visible = data.instanceDataManager.instanceData.chapterList.isEliteHasReward() ||
                    data.instanceDataManager.instanceData.instanceList.isEliteHasExternsReward();
            _ui.scenario_title_img.visible = false;
            _ui.elite_title_img.visible = true;
            _ui.line_img_1.visible = true;
            _ui.bg_elite_img.visible = true;

            _ui.hero_battle_value_txt.visible = true;
            var iElitePower:int = data.instanceDataManager.playerData.embattleManager.getPowerByEmbattleType(EInstanceType.TYPE_ELITE );
            _ui.hero_battle_value_txt.postfix = CLang.Get("common_battle_value");
            _ui.hero_battle_value_txt.text = iElitePower.toString();
            _ui.pos_img.visible = false;

        }

        if (data.curChapterData.isFirstChapter) {
            _ui.left_btn.visible = false;
        } else {
            _ui.left_btn.visible = true;
        }
        var lastChapterID:int = data.instanceDataManager.instanceData.getLastChapterData(data.instanceType).chapterID;
        if (data.curChapterData.chapterID == lastChapterID) {
            _ui.right_btn.visible = false;
        } else {
            _ui.right_btn.visible = true;
        }

        if (_heroEmbattleList == null) {
            _ui.hero_em_list.mouseHandler = new Handler(function (e:MouseEvent, idx:int) : void {
                if (e.type == MouseEvent.CLICK) {
                    _onAddEmbattleHero();
                }
            });
            _heroEmbattleList = new CHeroEmbattleListView(system, _ui.hero_em_list, data.instanceType, null, null, false, false, false);
        }
        _heroEmbattleList.updateWindow();


        this.addToRoot();

        return true;
    }
    private function _onAddEmbattleHero() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_EMBATTLE, data));

    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

        // 打开界面,
        if (_isFirstSetData) {
            _isFirstSetData = false;
            var selectChapterIndex:int = _initialArgs[0] as int;
            if (-1 == selectChapterIndex) {
                if (data.curChapterData == null) {
                    // 正常打开副本， 设置当前章节页面为最高章节
                    _curChapterData = data.curChapterData = data.instanceDataManager.instanceData.getLastChapterData(data.instanceType);
                } else {
                    // 指定跳到哪个章节
                    _curChapterData = data.curChapterData;
                }
            } else {
                var openChapterList:Array = data.instanceDataManager.instanceData.chapterList.getOpenList(data.instanceType);
                if (openChapterList.length > selectChapterIndex) {
                    _curChapterData = data.curChapterData = openChapterList[selectChapterIndex];
                } else {
                    // 正常打开副本， 设置当前章节页面为最高章节
                    _curChapterData = data.curChapterData = data.instanceDataManager.instanceData.getLastChapterData(data.instanceType);
                }
            }

        } else {
            if (data.curChapterData == null) {
                // 不更换章节
                data.curChapterData = _curChapterData;
            } else {
                // 指定跳到哪个章节
                _curChapterData = data.curChapterData;
            }
        }
        if (_curChapterData == null) {
            // 没有开启的章节, 新玩家
            
        }
        _goldInfoView.setData(data, forceInvalid);
        _pageView.setData(data, forceInvalid);
        _levelListView.setData(data, forceInvalid);
        _rewardView.setData(data, forceInvalid);
        _extraView.setData(data, forceInvalid);
        _effectComponent.setData(data, forceInvalid);
    }

    public function openEmbattleView() : void {
        _onEmbattle();
    }

    // ============
    private function _onOneKeyRewardClick() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_ONE_KEY_REWARD_CLICK, data));
    }
    private function _onEmbattle() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_EMBATTLE, data));
    }
    private function _onLeft() : void {
        var chapter:CChapterData = data.instanceDataManager.instanceData.getPreChapterData(data.curChapterData.instanceType, data.curChapterData.chapterID);
        _changeChapter(chapter);
    }
    private function _onRight() : void {
        var chapter:CChapterData = data.instanceDataManager.instanceData.getNextChapterData(data.curChapterData.instanceType, data.curChapterData.chapterID);
        _changeChapter(chapter);
    }
    private function _changeChapter(chapter:CChapterData) : void {
        if (chapter != data.curChapterData) {
            _curChapterData = data.curChapterData = chapter;
            this.invalidate();
        }
    }

    private function _onUIEvent(e:CViewEvent) : void {
        switch (e.subEvent) {
            case EInstanceViewEventType.INSTANCE_CHANGE_CHAPTER:
                var chapterData:CChapterData = e.data as CChapterData;
                _changeChapter(chapterData);
                break;
        }
    }
    protected override function _onStageClick(e:MouseEvent) : void {
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.CLICK_STAGE));
    }

    // index : start by 0
    private function getBgImage(index:int) : Image {
        return (_ui["bg_img_" + (index + 1)] as Image);
    }
    // index : start by 0
//    private function getLineImage(index:int) : Image {
//        return (_ui["line_img_" + (index + 1)] as Image);
//    }

    public function get _pageView() : CInstanceScenarioPageView { return getChild(0) as CInstanceScenarioPageView; }
    public function get _levelListView() : CInstanceScenarioLevelListView { return getChild(1) as CInstanceScenarioLevelListView; }
    private function get _rewardView() : CInstanceScenarioRewardView { return getChild(2) as CInstanceScenarioRewardView; }
    private function get _goldInfoView() : CInstanceScenarioGoldInfoView { return getChild(3) as CInstanceScenarioGoldInfoView; }
    private function get _extraView() : CInstanceScenarioExtraView { return getChild(4) as CInstanceScenarioExtraView; }
    private function get _effectComponent() : CInstanceEffectComponent { return getChild(5) as CInstanceEffectComponent; }

    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }

    public function get _ui() : InstanceScenarioUI {
        return rootUI as InstanceScenarioUI;
    }

    public function get curChapterData() : CChapterData {
        return _curChapterData;
    }

    private var _isFirstSetData:Boolean;
    private var _curChapterData:CChapterData;
    private var _heroEmbattleList:CHeroEmbattleListView;

    private const NUM_MAP_BG:int = 6;
}
}
