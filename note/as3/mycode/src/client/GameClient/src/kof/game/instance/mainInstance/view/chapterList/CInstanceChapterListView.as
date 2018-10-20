//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/1.
 */
package kof.game.instance.mainInstance.view.chapterList {


import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.CLang;

import kof.game.common.view.CRedNotifyView;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.ui.instance.InstanceChapterListItemUI;

import kof.ui.instance.InstanceChapterListUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CInstanceChapterListView extends CRootView {
    public function CInstanceChapterListView() {
        super(InstanceChapterListUI, [], null, false);
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

    }
    protected override function _onCreate() : void {
        setNoneData();
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _ui.list.renderHandler = new Handler(_renderItem);
        _ui.list.mouseHandler = new Handler(_mouseHandler);

    }

    protected override function _onHide() : void {
        _ui.list.renderHandler = null;
        _ui.list.mouseHandler = null;

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var chapterList:Array = data.instanceDataManager.instanceData.chapterList.getChapterOpenListLess6(data.instanceType);
        _ui.list.dataSource = chapterList;

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

        this.addToDialog();
        return true;
    }


    private function _renderItem(comp:Component, idx:int) : void {
        var item:InstanceChapterListItemUI = comp as InstanceChapterListItemUI;
        if (!item) return ;
        if (!item.dataSource) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        var chapter:CChapterData = item.dataSource as CChapterData;


        // 番外数据
        var curExtraStar:int = 0;
        var totalExtraStar:int = 0;
        var extraInstanceList:Array = data.instanceDataManager.instanceData.instanceList.getByChapterID(EInstanceType.TYPE_MAIN_EXTRA, chapter.chapterID);
        if (extraInstanceList) {
            var extraInstanceData:CChapterInstanceData = extraInstanceList[0]; // 只有一条
            if (extraInstanceData) {
                if (extraInstanceData.isCompleted) {
                    curExtraStar = extraInstanceData.star;
                }
                totalExtraStar = 3;
            }
        }

        if (chapter.isOpen) {
            ObjectUtils.gray(item, false);
            item.star_img.visible = true;
            item.star_process_txt.visible = true;
            var starCount:int = chapter.curStar;
            var totalCount:int = chapter.totalStar;
            item.star_process_txt.text = CLang.Get("common_v1_v2", {v1:starCount + curExtraStar, v2:totalCount + totalExtraStar});
        } else {
            ObjectUtils.gray(item, true);
            item.star_img.visible = false;
            item.star_process_txt.visible = false;
        }

        // 判断是否有章节视频
        var firstPassMovieInstance:CChapterInstanceData = data.instanceDataManager.instanceData.instanceList.getFirstPassMovieInstanceByChapterID(data.instanceType, chapter.chapterID);
        var hasFirstPassMovie:Boolean = false;
        if (firstPassMovieInstance && firstPassMovieInstance.firstPassMovieUrl && firstPassMovieInstance.firstPassMovieUrl.length > 0) {
            hasFirstPassMovie = true;
        }
        item.replay_btn.visible = hasFirstPassMovie;
        if (hasFirstPassMovie) {
            item.replay_btn.clickHandler = new Handler(function () : void {
                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.CHAPTER_REPLAY_MOVIE, firstPassMovieInstance));
                close();
            });
        } else {
            item.replay_btn.clickHandler = null;
        }

        // name
        item.name_txt.text = chapter.name;

        item.icon_img.url = chapter.bgIcon;

        // 小红点
        var isExternsHasReward:Boolean = false;
        if (data.instanceType == EInstanceType.TYPE_ELITE) {
            isExternsHasReward = _chapterHasExternsRewardData.hasOwnProperty(chapter.chapterID.toString());
        }
        if (isExternsHasReward) {
            item.red_img.visible = true;
        } else {
            var needNotify:Boolean = data.instanceDataManager.instanceData.chapterList.isChapterHasReward(chapter);
            if (needNotify) {
                item.red_img.visible = true;
            } else {
                item.red_img.visible = false;
            }
        }
    }

    private function _mouseHandler(evt:Event, idx:int) : void {
        if(evt.type == MouseEvent.CLICK) {
            changeChapter(idx);
        }
    }
    // idx : start by 0
    public function changeChapter(idx:int) : Boolean {
        var item:InstanceChapterListItemUI = _ui.list.getCell(idx) as InstanceChapterListItemUI;

        if (item) {
            var chapter:CChapterData = item.dataSource as CChapterData;
            var isChapterOpen:Boolean = chapter.isOpen;
            if (isChapterOpen) {
                rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.CHAPTER_SELECT, chapter));
                return true;
            } else {
                uiCanvas.showMsgAlert(CLang.Get("instance_chapter_not_open"));
            }
        }

        return false;
    }
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get _ui() : InstanceChapterListUI {
        return rootUI as InstanceChapterListUI;
    }
    private var _chapterHasExternsRewardData:Object; // 保存有宝箱可领的数据 key chapterID, value is true hasReward

}
}
