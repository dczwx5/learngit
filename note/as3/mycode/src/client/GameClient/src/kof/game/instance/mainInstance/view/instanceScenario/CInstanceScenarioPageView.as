//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.instanceScenario {

import flash.events.Event;
import flash.events.MouseEvent;
import kof.game.common.CLang;

import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.ui.instance.InstanceScenarioUI;

import morn.core.handlers.Handler;

public class CInstanceScenarioPageView extends CChildView {
    public function CInstanceScenarioPageView() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.star1_btn.addEventListener(MouseEvent.CLICK, _onClickStar1);
        _ui.star2_btn.addEventListener(MouseEvent.CLICK, _onClickStar2);
        _ui.star3_btn.addEventListener(MouseEvent.CLICK, _onClickStar3);
        _ui.chapter_list_btn.clickHandler = new Handler(_onOpenChapterList);

        _itemDataList = new Array();

    }
    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.star1_btn.removeEventListener(MouseEvent.CLICK, _onClickStar1);
        _ui.star2_btn.removeEventListener(MouseEvent.CLICK, _onClickStar2);
        _ui.star3_btn.removeEventListener(MouseEvent.CLICK, _onClickStar3);
        _ui.chapter_list_btn.clickHandler = null;

        _itemDataList = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _itemDataList = new Array();


        var chapterList:Array = data.instanceDataManager.instanceData.chapterList.getOpenList(data.instanceType);
        var strList:Array = data.instanceDataManager.instanceData.chapterList.getOpenNameList(data.instanceType);
        var chapterData:CChapterData;
        for (var i:int = 0; i < strList.length; i++) {
            chapterData = chapterList[i] as CChapterData;
            _itemDataList.push(new ListItemData(chapterData, _itemDataList.length));

        }

        // chapterName
        _ui.chapter_title_txt.text = data.curChapterData.name;

        // 副本宝箱数据
        if (data.instanceType == EInstanceType.TYPE_ELITE) {
            _chapterHasExternsRewardData = new Object();
            var pInstanceList:Array = data.instanceDataManager.instanceData.instanceList.list;
            for each (var pInstanceData:CChapterInstanceData in pInstanceList) {
                var isEliteInstance:Boolean = EInstanceType.TYPE_ELITE == pInstanceData.instanceType;
                if (!isEliteInstance) continue;
                var hasExternsReward:Boolean = pInstanceData.isServerData && pInstanceData.rewardExtends > 0 && pInstanceData.isDrawReard == false;
                if (!hasExternsReward) continue;
                if (false == _chapterHasExternsRewardData.hasOwnProperty(pInstanceData.chapterID.toString())) {
                    _chapterHasExternsRewardData[pInstanceData.chapterID] = true;
                }
            }
        }

        return true;
    }

    protected override function _onResize(e:Event) : void {

    }

    private function _onClickStar1(e:Event) : void {
        _onClickStarB(0);
    }
    private function _onClickStar2(e:Event) : void {
        _onClickStarB(1);
    }
    private function _onClickStar3(e:Event) : void {
        _onClickStarB(2);
    }

    private function _onOpenChapterList() : void {
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_OPEN_CHAPTER_LIST));
    }


    private function _onClickStarB(index:int) : void {
        // var btn:Button = _ui["star" + (index+1) + "_btn"];

    }

    // idx : start by 0
    public function changeChapter(idx:int) : Boolean {
        if (_itemDataList.length > idx) {
            var chapter:CChapterData = (_itemDataList[idx] as ListItemData).chapter;
            var isChapterOpen:Boolean = chapter.isOpen;
            if (isChapterOpen) {
                this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_CHANGE_CHAPTER, chapter));
                return true;
            }
        }

        return false;
    }

    private function get _ui() : InstanceScenarioUI {
        return rootUI as InstanceScenarioUI;
    }

    private function get data() : CInstanceDataCollection { return _data as CInstanceDataCollection; }

    private var _itemDataList:Array; // 与item[index]对应
    private var _chapterHasExternsRewardData:Object; // 保存有宝箱可领的数据 key chapterID, value is true hasReward

}
}

import kof.game.instance.mainInstance.data.CChapterData;

class ListItemData {
    public function ListItemData(chapter:CChapterData, index:int) {
        this.chapter = chapter;
        this.index = index;
    }

    public var chapter:CChapterData;
    public var index:int;
}
