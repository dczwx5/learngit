//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/1.
 */
package kof.game.instance.mainInstance.view.instanceScenario {

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CAppSystem;
import kof.game.common.CRewardUtil;
import kof.game.common.data.CErrorData;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.item.data.CRewardListData;
import kof.game.common.view.CChildView;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.CInstanceIntroLockTips;
import kof.game.instance.mainInstance.view.CInstanceIntroTips;
import kof.game.player.CPlayerSystem;
import kof.ui.instance.InstanceExtraNodeUI;
import kof.ui.instance.InstanceScenarioUI;

import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CInstanceScenarioExtraView extends CChildView {
    public function CInstanceScenarioExtraView() {
    }


    private var _baseItemPos:Point;
    protected override function _onCreate() : void {
        _baseItemPos = new Point(_ui.extra_item.x, _ui.extra_item.y);
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class

        _ui.extra_item.addEventListener(MouseEvent.CLICK, _onClickItem);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.extra_item.removeEventListener(MouseEvent.CLICK, _onClickItem);
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var instanceList:Array = data.instanceDataManager.instanceData.instanceList.getByChapterID(EInstanceType.TYPE_MAIN_EXTRA, data.curChapterData.chapterID);
        var instanceData:CChapterInstanceData = instanceList[0]; // 只有一条
        if (!instanceData) {
            _ui.extra_item.visible = false;
            return true;
        }
        _ui.extra_item.visible = true;
        _ui.extra_item.name_txt.text = instanceData.name;
        _ui.extra_item.dataSource = instanceData;
        if (instanceData.isServerData == true) {
            // 已通关
            _ui.extra_item.icon_img.url = CInstancePath.getInstanceExtraNodeIcon(instanceData.icon);
        } else {
            var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var teamLevel:int = pPlayerSystem.playerData.teamData.level;
            if (instanceData.getIsOpenCondPass(teamLevel)) {
                // 开启
                _ui.extra_item.icon_img.url = CInstancePath.getInstanceExtraNodeIcon(instanceData.icon);
            } else {
                // 未开启
                _ui.extra_item.icon_img.url = CInstancePath.getInstanceExtraNodeIcon(instanceData.unOpenIcon);
            }
        }
        var isPass:Boolean = instanceData.isCompleted;
        var instanceName:String = instanceData.name;
        var power : int = instanceData.powerRecommend;
        var sPower:String = power.toString();
        var errorData:CErrorData = data.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, 0, false, true);
        if (errorData.isError == false) {
            var starCount : int = instanceData.star;
            var rewardDataList : CRewardListData;
            if (isPass) {
                rewardDataList = CRewardUtil.createByDropPackageID( (uiCanvas as CAppSystem).stage, instanceData.reward );
            } else {
                rewardDataList = CRewardUtil.createByDropPackageID((uiCanvas as CAppSystem).stage, instanceData.rewardFirst);
            }
            _ui.extra_item.toolTip = new Handler(addTips, [CInstanceIntroTips, _ui.extra_item, [starCount, sPower, rewardDataList, instanceName, true, isPass]]);
        } else {
            // 未开启tips
            var openStringList:Array = instanceData.getOpenCondtionTipsList(data.instanceDataManager.playerData.teamData.level);
            _ui.extra_item.toolTip = new Handler(addTips, [CInstanceIntroLockTips, _ui.extra_item, [openStringList, sPower, instanceName, false]]);
        }

        // 星星
        _ui.extra_item.star_list.renderHandler = new Handler(_onRenderStar);
        if (instanceData.isServerData == true) {
            // 已通关
            var starDataList:Array;
            starDataList = [1, 1, 1];
            for (var starIndex:int = 0; starIndex < instanceData.star; starIndex++) {
                starDataList[starIndex] = 2;
            }
            _ui.extra_item.star_list.dataSource = starDataList;
        } else {
            // 未通关
            var pPlayerSys:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var teamLvl:int = pPlayerSys.playerData.teamData.level;
            if (instanceData.getIsOpenCondPass(teamLvl)) {
                // 开启
                _ui.extra_item.star_list.dataSource = [1, 1, 1];
            } else {
                // 未开启
                _ui.extra_item.star_list.dataSource = [0, 0, 0];
            }
        }

        _ui.extra_item.x = _baseItemPos.x + data.curChapterData.chapterRecord.itemDeltaX[5];
        _ui.extra_item.y = _baseItemPos.y + data.curChapterData.chapterRecord.itemDeltaY[5];
        return true;
    }

    private function _onClickItem(e:MouseEvent) : void {
        e.stopImmediatePropagation();
        var item : InstanceExtraNodeUI = _ui.extra_item;
        var instanceData : CChapterInstanceData = item.dataSource as CChapterInstanceData;
        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var teamLevel:int = pPlayerSystem.playerData.teamData.level;
        if ( instanceData.isCompleted == false && instanceData.getIsOpenCondPass(teamLevel) ) {
            rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_EXTRA_CLICK, [ data, item.dataSource ] ) );
        } else {
            rootView.dispatchEvent( new CViewEvent( CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_EXTRA_CLICK, [ data, item.dataSource ] ) );
        }
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
    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get _ui() : InstanceScenarioUI {
        return rootUI as InstanceScenarioUI;
    }
}
}
