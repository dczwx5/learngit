//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/17.
 */
package kof.game.playerTeam.view {

import QFLib.Utils.ArrayUtil;
import flash.events.Event;
import flash.events.MouseEvent;
import kof.framework.IDataTable;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndResType;
import kof.table.PlayerBasic;
import kof.table.PlayerDisplay;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.player_team.ChangeImageUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CPlayerTeamChangeImageViewHandler extends CRootView {

    public function CPlayerTeamChangeImageViewHandler() {
        super(ChangeImageUI, null, null, false);
    }

    protected override function _onCreate() : void {
        _ui.lock_title_txt.text = CLang.Get("player_team_lock_icon");
        _ui.ok_btn.label = CLang.Get("common_ok");
    }

    private var _type:int; // 0 头像, 1 形象
    protected override function _onShow():void {
        // do thing when show
        super._onShow();

        _type = _initialArgs[0] as int;

        _lastItem = null;
        _selectIconID = -1;
        _ui.unlock_box.addEventListener(Event.RESIZE, _onResize);
        _ui.unlock_icon_list.renderHandler = new Handler(_onRenderUnlockItem);
        _ui.unlock_icon_list.mouseHandler = new Handler(_onClickUnlockItem);
        _ui.lock_icon_list.renderHandler = new Handler(_onRenderlockItem);
        _ui.ok_btn.clickHandler = new Handler(_onOk);
//        _ui.image_list_panel.vScrollBar.changeHandler = new Handler(_onScrollChange);

        _renderItemFunc = CItemUtil.getBigItemRenderByHeroDataFunc(system);

        _ui.title_clip.index = _type;
    }
    protected override function _onHide() : void {
        super._onHide();
        _ui.unlock_box.removeEventListener(Event.RESIZE, _onResize);
        _ui.unlock_icon_list.mouseHandler = null;
        _ui.unlock_icon_list.renderHandler = null;
        _ui.lock_icon_list.renderHandler = null;
        _ui.ok_btn.clickHandler = null;
//        _ui.image_list_panel.vScrollBar.changeHandler = null;
        _renderItemFunc = null;
    }
    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var playerData:CPlayerData = _playerData;
        var unlockList:Array = [];
        var lockList:Array = [];
        var existHeroList:Array = playerData.heroList.list;

        const pTable:IDataTable = playerData.playerBasicTable;
        var allIconList:Array = pTable.toArray(); // 不能改成toVector. 因为下面改变了数据成员
        var iconItem:PlayerBasic;

        //
        for (i = 0; i < allIconList.length; i++) {
            iconItem = (allIconList[i] as PlayerBasic);
            var pDisplayRecord:PlayerDisplay = playerData.playerDisplayTable.findByPrimaryKey(iconItem.ID);
            var isDisplay:Boolean = pDisplayRecord && playerData._isHeroDisplay(pDisplayRecord);
            if (!isDisplay) {
                allIconList.splice(i, 1);
                i--;
            }
        }

        for (var i : int = 0; i < allIconList.length; i++) {
            iconItem = (allIconList[i] as PlayerBasic);
            if (-1 != ArrayUtil.findItemByProp(existHeroList, CPlayerHeroData._prototypeID, iconItem.ID)) {
                unlockList.push(iconItem.ID);
                allIconList.splice(i, 1);
                i--;
            }
        }

        for (i = 0; i < allIconList.length; i++) {
            lockList.push((allIconList[i] as PlayerBasic).ID);
        }
        _ui.unlock_icon_list.repeatY = (unlockList.length-1)/_ui.unlock_icon_list.repeatX + 1;
        _ui.unlock_icon_list.dataSource = unlockList;
        _ui.lock_icon_list.repeatY = (lockList.length-1)/_ui.lock_icon_list.repeatX + 1;
        _ui.lock_icon_list.dataSource = lockList;

        _onResize(null);

        _ui.image_list_panel.refresh();

        this.addToPopupDialog();

        return true;
    }

    private function _onClickUnlockItem(evt:Event, idx:int) : void {
        if(evt.type == MouseEvent.CLICK) {
            if (_lastItem) {
//                _lastItem.light_img.visible = false;
                _lastItem.select_icon_img.visible = false;
            }
            var item:ItemUIUI = this._ui.unlock_icon_list.getCell(idx) as ItemUIUI;
            if (item && item.dataSource) {
//                item.light_img.visible = true;
                item.select_icon_img.visible = true;
            }
            _lastItem = item;
            _selectIconID = _lastItem.dataSource as int;
        }
    }
    private function _onRenderUnlockItem(item:Component, idx:int) : void {
        _onRenderItemB(item, idx, false);
    }
    private function _onRenderlockItem(item:Component, idx:int) : void {
        _onRenderItemB(item, idx, true);

    }
    private function _onRenderItemB(item:Component, idx:int, isLock:Boolean) : void {
        if (_renderItemFunc) {
            _renderItemFunc(item, idx);
        }

        var headItem:ItemUIUI = item as ItemUIUI;
        var heroID:int = headItem.dataSource as int;
        if (isLock) {
            ObjectUtils.gray(headItem.img, true);
        } else {
            ObjectUtils.gray(headItem.img, false);
            if (-1 == _selectIconID) {
                if (_type == EPlayerWndResType.TYPE_CHANGE_ICON) {
                    if (heroID == _playerData.teamData.useHeadID) {
                        _lastItem = headItem;
                        _lastItem.select_icon_img.visible = true;
                        _selectIconID = _playerData.teamData.useHeadID;
                    }
                } else {
                    if (heroID == _playerData.teamData.prototypeID) {
                        _lastItem = headItem;
                        _lastItem.select_icon_img.visible = true;
                        _selectIconID = _playerData.teamData.prototypeID;
                    }
                }
            }
        }
//        headItem.img.cacheAsBitmap = true;
//        if (_isItemInScrollRect(headItem))  {
//            headItem.img.url = CPlayerPath.getUIHeroIconMiddlePath(headItem.dataSource["iconID"]);
//        }
    }
//    private var _tempItemPos:Point = new Point();
//    private var _tempItemRect:Rectangle = new Rectangle();
//    private function _isItemInScrollRect(cell:ItemUIUI) : Boolean {
//        var heroBox:Box = _ui.hero_icon_box;
//        if (heroBox == null) {
//            return false;
//        }
//        _tempItemPos.x = cell.x;
//        _tempItemPos.y = cell.y;
//        var pos:Point = _tempItemPos;
//        pos = cell.parent.localToGlobal(pos);
//        pos = heroBox.globalToLocal(pos);
//
//        var rect:Rectangle = _tempItemRect;
//        rect.x = pos.x;
//        rect.y = pos.y;
//        rect.width = cell.width;
//        rect.height = cell.height;
//        if (_ui.image_list_panel.content.scrollRect.intersects(rect)) {
//            return true;
//        }
//        return false;
//    }
//    private function _onScrollChange(value:int) : void {
//        var lockCells:Vector.<Box> = _ui.lock_icon_list.cells;
//        var unLockCells:Vector.<Box> = _ui.unlock_icon_list.cells;
//        var allList:Vector.<Box> = lockCells.concat(unLockCells);
//        var cell:ItemUIUI;
//        var isInRect:Boolean;
//        for each (cell in allList) {
//            if (cell && cell.dataSource) {
//                isInRect = _isItemInScrollRect(cell);
//                if (isInRect) {
//                    if (_isItemInScrollRect(cell) && cell.dataSource)  {
//                        cell.img.url = CPlayerPath.getUIHeroIconMiddlePath(cell.dataSource["iconID"]);
//                    }
//                }
//            }
//        }
//    }
    private function _onResize(e:Event) : void {
        _ui.lock_box.y = _ui.unlock_box.y + _ui.unlock_box.displayHeight + 20;
    }
    private function _onOk() : void {
        rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, CViewEvent.OK, _type));
        this.close();
    }
    private function get _ui():ChangeImageUI {
        return rootUI as ChangeImageUI;
    }

    protected override function _onClose() : void {
        super._onClose();
    }

    public function getSelectIcon() : int {
        return _selectIconID;
    }

    private function get _playerData() : CPlayerData {
        return _data as CPlayerData;
    }

    private var _lastItem:ItemUIUI;
    private var _selectIconID:int;

    private var _renderItemFunc:Function;

}
}

