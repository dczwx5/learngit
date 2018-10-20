//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.player.view.heroDetail.detail {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.player.data.CHeroEquipData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.ui.master.JueseAndEqu.EquItemUI;
import kof.ui.master.JueseAndEqu.RoleItemUI;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CPlayerHeroDetailEquipView extends CChildView {
    public function CPlayerHeroDetailEquipView() {
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
        var ui:Object= _detailUI;
        ui.equip_list.renderHandler = new Handler(_renderItem);
        ui.equip_list.mouseHandler = new Handler(_onClickListHandler);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        var ui:Object= _detailUI;
        ui.equip_list.renderHandler = null;
        ui.equip_list.mouseHandler = null;
    }
    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

        var ui:Object= _detailUI;

        ui.equip_list.dataSource = _heroData.equipList.toArray();

        return true;

    }

    private function _renderItem(item:Component, idx:int) : void {
        if ( !(item is Object) ) {
            return;
        }
        var roleEquipItem:Object = item as Object;
        var equipData:CHeroEquipData = item.dataSource as CHeroEquipData;
        if (equipData == null) return ;

        var i:int = 0;
        for (i = 0; i < 6; i++) {
            var btn:Button = roleEquipItem["bg_btn" + (i+1)] as Button;
            btn.visible = (i == idx);
        }


        var equIpItemUI:EquItemUI = roleEquipItem.eq_item;
        equIpItemUI.name_label.text = equipData.name;
        equIpItemUI.level_label.text = CLang.Get("common_level", {v1:equipData.level});
        equIpItemUI.quality_clip.index = equipData.qualityLevelValue+1;
//        equIpItemUI.quality_list.dataSource = new Array(equipData.quality);
//        equIpItemUI.star_list.dataSource = new Array(equipData.star);
        equIpItemUI.icon_img.url = equipData.smallIcon; // CPlayerPath.getEquipIconMiddle(equipData.part.toString());
        equIpItemUI.bg_btn.visible = false;

        var arr:Array = [];
        for(i = 0;i<equipData.star;i++)
        {
            arr.push(1);
        }
        equIpItemUI.star_list.repeatX = arr.length;
        equIpItemUI.star_list.dataSource=arr;
        equIpItemUI.star_list.right = equIpItemUI.star_list.right;
        arr=[];
        for(var j:int = 0;j<equipData.qualityLevelSubValue;j++)
        {
            arr.push(equipData);
        }
        equIpItemUI.quality_list.repeatX = arr.length;
        equIpItemUI.quality_list.dataSource=arr;
        equIpItemUI.quality_list.centerX = equIpItemUI.quality_list.centerX;
        equIpItemUI.quality_list.renderHandler = new Handler(_onItemRender);
    }

    private function _onItemRender(item:Component, idx:int):void
    {
        var itemClip:Box = item as Box;
        if(!item.dataSource)return;
        var qualityColor:int = (item.dataSource as CHeroEquipData).qualityLevelValue-1;
        (itemClip.getChildByName("quality") as Clip).index = qualityColor;
    }

    private function _onClickListHandler(evt:Event, idx:int) : void {
        if(evt.type == MouseEvent.CLICK) {
            var heroItem:RoleItemUI = evt.currentTarget as RoleItemUI;
            if (heroItem == null) return ;


        }
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
