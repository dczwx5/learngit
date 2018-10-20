//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.view.main {

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CAppSystem;

import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.story.CStorySystem;
import kof.game.story.control.CStoryControler;
import kof.game.story.data.CStoryData;
import kof.game.story.data.CStoryGateData;
import kof.game.story.enum.EStoryViewEventType;
import kof.game.story.enum.EStoryWndResType;
import kof.table.HeroStoryBase;
import kof.table.HeroStoryGate;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.HeroStoryView.HeroStoryViewUI;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Component;

import morn.core.components.Image;

import morn.core.components.Label;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CStoryView extends CRootView {

    public function CStoryView() {
        var childrenList:Array = null;
        super(HeroStoryViewUI, childrenList, EStoryWndResType.MAIN, false);
    }

    protected override function _onCreate() : void {
        _isFrist = true;
    }

    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        for (var i:int = 1; i <= 5; i++) {
            var btn:Button = _getFightButton(i);
            btn.clickHandler = new Handler(_onFight, [i]);

            var addBtn:Button = _getAddFightCountBtn(i);
            addBtn.clickHandler = new Handler(_onAddFightCount, [i]);
        }
        flashStage.addEventListener(MouseEvent.MOUSE_MOVE, onRollMouse);
        _ui.shop_btn.clickHandler = new Handler(_onOpenShop);
    }
    protected override function _onShowing() : void {
        _ui.currency_img.toolTip = new Handler(AddTips, [system, _ui.currency_img]);
    }
    private function AddTips(system:CAppSystem, item:Component) : void {
        var itemSystem:CItemSystem = (system).stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item, [_storyData.ITEM_ID]);
    }

    protected override function _onHide() : void {
        _ui.currency_img.toolTip = null;
        _heroData = null;
        _dataList = null;
        for (var i:int = 1; i <= 5; i++) {
            var btn:Button = _getFightButton(i);
            btn.clickHandler = null;
        }
        flashStage.removeEventListener(MouseEvent.MOUSE_MOVE, onRollMouse);
        _ui.shop_btn.clickHandler = null;
        _heroRecord = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
        }

        var heroID:int = _initialArgs[0] as int;
        if (heroID < 0) {
            heroID = 312;
        }
        _heroData = _playerData.heroList.getHero(heroID);
        _heroRecord = _storyData.heroTable.findByPrimaryKey(_heroData.prototypeID) as HeroStoryBase;

        var dataList:Array = _storyData.gateListData.getListByHeroID(heroID);
        _dataList = dataList;
        for (var i:int = 0; i < dataList.length > 0; i++) {
            _renderItem(dataList[i] as CStoryGateData, 1+i);
        }

        _ui.hero_name_txt.text = _heroData.heroName;

        // 门票显示
        var pController:CStoryControler = controlList[0] as CStoryControler;
        var currencyCount:int = 0;
        var itemData:CBagData = pController.getItem(_storyData.ITEM_ID);
        if (itemData) {
            currencyCount = itemData.num;
        }

        _currencyCountTxt().text = currencyCount.toString();
        this.addToDialog();

        return true;
    }

    // idx : start by 1
    private function _renderItem(gateData:CStoryGateData, idx:int) : void {
        var gateRecord:HeroStoryGate = gateData.gateRecord;
        var pController:CStoryControler = controlList[0] as CStoryControler;
        var instanceData:CChapterInstanceData = pController.getInstanceData(gateRecord.InstanceContentID);

        // 副本名
        var instanceTxt:Label = _getInstanceNameTxt(idx);
        instanceTxt.text = instanceData.name;

        var bgImg:Image = _getBgImage(idx);
        bgImg.url = _heroRecord.bg + "/" + idx + ".png";

        // 奖励显示
        var rewardView:RewardItemUI = _getRewardView(idx);
        var rewardItemID:int = gateRecord.showRewardID;
        var rewardData:CRewardData = CRewardData.CreateRewardData(rewardItemID, 1, _storyData.databaseSystem);
        rewardView.dataSource = rewardData;
        CRewardItemListView.onRenderItem(system, rewardView, 0, false, false);

        var rewardDescTxt:Label = _getRewardDescTxt(idx);
        if (gateData.passed) {
            rewardDescTxt.text = gateRecord.rewardDesc;
        } else {
            rewardDescTxt.text = gateRecord.firstRewardDesc;
        }

        // fight
        var fightConsume:int = _storyData.getFightGateConsume(_heroData.qualityBase, idx);
        var fightConsumeTxt:Label = _getFightConsumeTxt(idx);
        var currencyCount:int = 0;
        var itemData:CBagData = pController.getItem(_storyData.ITEM_ID);
        if (itemData) {
            currencyCount = itemData.num;
        }
        if (currencyCount >= fightConsume) {
            fightConsumeTxt.text = CLang.Get("common_color_content_green", {v1:fightConsume});
        } else {
            fightConsumeTxt.text = CLang.Get("common_color_content_red", {v1:fightConsume});
        }

        // left count
        var leftCountTxt:Label = _getLeftCountTxt(idx);
        var leftCount:int = gateData.leftCount;
        leftCount = Math.max(leftCount, 0);
        leftCountTxt.text = CLang.Get("common_v1_v2", {v1:leftCount, v2:_storyData.FREE_FIGHT_COUNT_DAILY});

        var box:Box = _getBox(idx);
        ObjectUtils.gray(box, false);
        if (idx > 1) {
            var preGateData:CStoryGateData = _dataList[idx-2] as CStoryGateData;
            if (!preGateData.passed) {
                ObjectUtils.gray(box, true);
            }
        }
    }


    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================
    private function _onFight(gateIndex:int) : void {
        var gateData:CStoryGateData = _dataList[gateIndex-1];
        var preGateData:CStoryGateData = null;
        if (gateIndex > 1) {
            preGateData = _dataList[gateIndex - 2];
        }
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStoryViewEventType.MAIN_FIGHT_CLICK, [gateData, _heroData, preGateData]));
    }
    private function _onAddFightCount(gateIndex:int) : void {
        var gateData:CStoryGateData = _dataList[gateIndex-1];
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStoryViewEventType.MAIN_ADD_FIGHT_COUNT_CLICK, [gateData, _heroData]));
    }
    private function _onOpenShop() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStoryViewEventType.MAIN_SHOP_CLICK));
    }

    private function onRollMouse(e:MouseEvent):void {
        if (!_dataList) return ;

        var preGatePassed:Boolean = true;
        for (var i:int = 1; i <= 5; i++) {
            var bgImage:Image = _getBgImage(i);
            var contentBox:Box = _getContentBox(i);
            var leftCountBox:Box = _getLeftCountBox(i);
            var firstPassImage:Image = _getFirstPassImage(i);
            var gateData:CStoryGateData = _dataList[i-1];
            if ( preGatePassed && true == _hitTestItem( bgImage, e.stageX, e.stageY ) ) {
                contentBox.visible = true;
                leftCountBox.visible = true;
                // 首通
                firstPassImage.visible = !gateData.passed;

                var addBtn:Button = _getAddFightCountBtn(i);
                addBtn.visible = gateData.leftCount == 0;
            } else {
                contentBox.visible = false;
                leftCountBox.visible = false;

                // 首通
                firstPassImage.visible = false
            }
            preGatePassed = gateData.passed;
        }
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
    //===================================get/set======================================
    private function _getInstanceNameTxt(index:int) : Label {
        return _ui["instance_name_" + index];
    }
    private function _getFirstPassImage(index:int) : Image {
        return _ui["first_pass_img_" + index];
    }
    private function _getContentBox(index:int) : Box {
        return _ui["content_box_" + index];
    }
    private function _getLeftCountBox(index:int) : Box {
        return _ui["left_count_box_" + index];
    }
    private function _getRewardView(index:int) : RewardItemUI {
        return _ui["reward_" + index];
    }

    private function _getRewardDescTxt(index:int) : Label {
        return _ui["reward_desc_txt_" + index];
    }
    private function _getFightConsumeTxt(index:int) : Label {
        return _ui["fight_consum_txt_" + index];
    }
    private function _getFightButton(index:int) : Button {
        return _ui["fight_btn_" + index];
    }
    private function _getLeftCountTxt(index:int) : Label {
        return _ui["left_count_txt_" + index];
    }
    private function _getBgImage(index:int) : Image {
        return _ui["bg_img_" + index];
    }
    private function _getAddFightCountBtn(index:int) : Button {
        return _ui["add_fight_count_btn_" + index];
    }
    private function _getBox(index:int) : Box {
        return _ui["box_" + index];
    }
    private function _currencyCountTxt() : Label {
        return _ui.currency_count_txt;
    }
//    private function get _linksView() : CPeakGameMainLinks { return getChild(0) as CPeakGameMainLinks; }

    [Inline]
    private function get _ui() : HeroStoryViewUI {
        return rootUI as HeroStoryViewUI;
    }
    [Inline]
    private function get _storyData() : CStoryData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStoryData;
        }
        return null;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        if (_data && _data.length > 1) {
            return super._data[1] as CPlayerData;
        }
        return null;
    }
    private function get _system() : CStorySystem {
        return system as CStorySystem;
    }

    private var _isFrist:Boolean = true;
    private var _heroData:CPlayerHeroData;
    private var _dataList:Array;
    private var _heroRecord:HeroStoryBase;

}
}
