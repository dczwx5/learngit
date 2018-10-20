//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/3.
 */
package kof.game.instance.mainInstance.view {

import kof.game.common.view.CRootView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.data.CInstanceOneKeyRewardData;
import kof.game.instance.mainInstance.data.CInstanceOneKeyRewardItemData;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.item.view.part.CRewardItemListView;
import kof.ui.instance.InsranceOKTRRewardUI;
import kof.ui.instance.InstanceOneKeyToReceiveUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

// 一键领取奖励界面
public class CInstanceOneKeyRewardView extends CRootView {

    public function CInstanceOneKeyRewardView() {
        super(InstanceOneKeyToReceiveUI, null, null, false)
    }

    protected override function _onCreate() : void {
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _ui.msg_list.renderHandler = new Handler(_onRenderItem);
        _ui.ok_btn.clickHandler = new Handler(_onClickOk);
    }
    protected override function _onHide() : void {
        _ui.msg_list.renderHandler = null;
        _ui.ok_btn.clickHandler = null;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var pInstanceData:CInstanceData = data.instanceDataManager.instanceData;

        var pItemList:Array = pInstanceData.chapterList.getScenarioOneKeyRewardDataList(); // 这个奖励是客户端自己算的
        _ui.msg_list.dataSource = pItemList;
        _ui.msg_list.repeatY = pItemList.length;
        _ui.panel.refresh();

        this.addToDialog(null);

        return true;
    }

    private function _onRenderItem(com:Component, idx:int) : void {
        var item:InsranceOKTRRewardUI = com as InsranceOKTRRewardUI;
        if (!item) return ;

        item.visible = item.dataSource != null;
        if (item.visible == false) {
            return ;
        }
        var pItemData:CInstanceOneKeyRewardItemData = item.dataSource as CInstanceOneKeyRewardItemData;


        var externalUtil:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, _ui);
        (externalUtil.view as CRewardItemListView).ui = item.reward_list;
        externalUtil.show();
        externalUtil.setData(pItemData.rewardList);
        externalUtil.updateWindow();

        var pChapterData:CChapterData = data.instanceDataManager.instanceData.chapterList.getByID(pItemData.chapterID);
        item.title_txt.text = pChapterData.name;
        item.star_count_txt.text = pChapterData.getStarByIndex(pItemData.subIndex-1).toString();
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);


    }

    private function _onClickOk() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_ONE_KEY_REWARD_OK_CLICK, data));
        _onClose();
    }

    private function get _ui() : InstanceOneKeyToReceiveUI {
        return rootUI as InstanceOneKeyToReceiveUI;
    }

    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }

}
}
