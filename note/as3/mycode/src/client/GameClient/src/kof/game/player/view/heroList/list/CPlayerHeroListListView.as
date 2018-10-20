//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/9.
 */
package kof.game.player.view.heroList.list {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import kof.game.common.CLang;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.event.EPlayerViewEventType;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CPlayerHeroListListView extends CChildView{
    public function CPlayerHeroListListView() {
        super();
    }
    protected override function _onCreate() : void {
        _rectPanel = new Rectangle(_ui.panel.x, _ui.panel.y, _ui.panel.width, _ui.panel.height);
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();


        _renderList = new Object();
        var ui:Object = _ui;
        ui.unlock_icon_list.renderHandler = new Handler(_renderItem);
        ui.unlock_icon_list.mouseHandler = new Handler(_onClickListHandler);

        ui.lock_icon_list.renderHandler = new Handler(_renderItem);
        ui.lock_icon_list.mouseHandler = new Handler(_onClickListHandler);

        ui.unlock_box.addEventListener(Event.RESIZE, _onResize);
        ui.panel.vScrollBar.changeHandler = new Handler(_onScrollChange);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        var ui:Object = _ui;
        ui.unlock_icon_list.renderHandler = null;
        ui.unlock_icon_list.mouseHandler = null;
        ui.lock_icon_list.renderHandler = null;
        ui.lock_icon_list.mouseHandler = null;
        ui.unlock_box.removeEventListener(Event.RESIZE, _onResize);
        ui.panel.vScrollBar.changeHandler = null;
        _renderList = null;
    }

    // win
    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

        _renderList = new Object();

        // 看能不能优化一下, 不要每次都排序
        var list:Array = _playerData.displayList;

        var existFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean {
            return item.hasData || (item.hasData == false && item.enoughToHire);
        };
        var unHireFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean {
            return item.hasData == false && item.enoughToHire == false;
        };
        var hireList:Array = list.filter(existFilter);
        var unHireList:Array = list.filter(unHireFilter);
        hireList.sort(_playerData.heroList.compare);
        unHireList.sort(_playerData.heroList.compare);
        // list 排序
        var ui:Object = _ui;
        var unlockRepeatY:int = ui.unlock_icon_list.repeatY;
        var curUnlockRepeatY:int = (hireList.length-1)/ui.unlock_icon_list.repeatX + 1;
        ui.unlock_icon_list.dataSource = hireList;
        if (unlockRepeatY != curUnlockRepeatY) {
            ui.unlock_icon_list.repeatY = curUnlockRepeatY;
        }

        var lockRepeatY:int = ui.lock_icon_list.repeatY;
        var curLockRepeatY:int = (unHireList.length-1)/ui.lock_icon_list.repeatX + 1;
        ui.lock_icon_list.dataSource = unHireList;
        if (lockRepeatY != curLockRepeatY) {
            ui.lock_icon_list.repeatY = curLockRepeatY;
        }

        _onResize(null);

        _lastScrollValue = ui.panel.vScrollBar.value;
        ui.panel.refresh();

        return true;
    }

    private function _renderItem(item:Component, idx:int) : void {
        if (!(item is Object)) {
            return ;
        }
        var heroItem:Object = item as Object;
        var isInRect:Boolean = _isItemInScrollRect(heroItem);
        if (isInRect) {
            _renderItemB(heroItem);
        }
     }
    private function _renderItemB(heroItem:Object) : void {
        var heroData:CPlayerHeroData = heroItem.dataSource as CPlayerHeroData;
        if (heroData == null) {
            return ;
        }
        if (heroData.prototypeID in _renderList) {
            return ;
        }
        var isHeroExist:Boolean = heroData != null && heroData.hasData;
        var playerName:String = heroData.heroNameWithColor;

        heroItem.icon_img.cacheAsBitmap = heroItem.hero_icon_mask.cacheAsBitmap = true;
        heroItem.icon_img.mask = heroItem.hero_icon_mask;
//        heroItem.embattle_clip.visible = false;
        heroItem.aptitude_lock_cliip.visible = false;
        heroItem.aptitude_unlock_cliip.visible = false;
        heroItem.aptitude_unlock_cliip.index = heroData.qualityBaseType;
        heroItem.aptitude_lock_cliip.index = heroData.qualityBaseType;
        if (isHeroExist) {
            var qualityLevel:int = heroData.qualityLevelValue;
            var qualitySubValue:int = heroData.qualityLevelSubValue;

//            var embattle:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_MAIN);
//            if (embattle) {
//                if (embattle.getIndexByHero(heroData.prototypeID) != -1) {
//                    heroItem.embattle_clip.visible = true;
//                }
//            }

            heroItem.bg_clip.index = qualityLevel;
            if (heroItem.star_list.repeatX != heroData.star) {
                heroItem.star_list.repeatX = heroData.star;
            }
            heroItem.star_list.dataSource = new Array(heroData.star);
            heroItem.star_list.right = heroItem.star_list.right;

            heroItem.name_label.stroke = heroData.strokeColor;
            heroItem.name_label.text = CLang.Get("common_quality_add_count", {v1:playerName, v2:qualitySubValue});
            heroItem.piece_progress_bar.visible = false;
            heroItem.piece_bg_img.visible = false;
            heroItem.hire_btn.visible = false;
            heroItem.piece_btn.visible = false;
            if (heroItem.quality_list.repeatX != qualitySubValue) {
                heroItem.quality_list.repeatX = qualitySubValue;
            }
            heroItem.quality_list.dataSource = new Array(qualitySubValue);
            heroItem.quality_list.centerX = 0;

            heroItem.quality_list.visible = true;

            heroItem.level_label.visible = true;
            heroItem.level_label.text = CLang.Get("common_level", {v1:heroData.level});
            heroItem.battle_value_label.visible = true;
            heroItem.battle_value_bg.visible = true;
            heroItem.battle_value_num.visible = true;
            heroItem.battle_value_num.text = heroData.battleValue.toString();
            ObjectUtils.gray(heroItem.icon_img, false);
            ObjectUtils.gray(heroItem.bg_clip, false);
            heroItem.aptitude_unlock_cliip.visible = true;
        } else {
            heroItem.bg_clip.index = 0;
            heroItem.name_label.text = playerName;
            if (heroItem.star_list.repeatX != heroData.initialStar) {
                heroItem.star_list.repeatX = heroData.initialStar;
            }
            heroItem.star_list.dataSource = new Array(heroData.initialStar);
            heroItem.star_list.right = heroItem.star_list.right;
            heroItem.piece_progress_bar.visible = true;
            heroItem.piece_progress_bar.value = heroData.pieceRate;
            heroItem.piece_progress_bar.label = CLang.Get("common_v1_v2", {v1:heroData.currentPieceCount, v2:heroData.hireNeedPieceCount});
            heroItem.piece_bg_img.visible = true;
            heroItem.quality_list.visible = false;
            heroItem.level_label.visible = false;
            heroItem.battle_value_label.visible = false;
            heroItem.battle_value_bg.visible = false;
            heroItem.battle_value_num.visible = false;

            // 当前碎片数量
            if (heroData.enoughToHire) {
                heroItem.hire_btn.visible = true;
                heroItem.piece_btn.visible = false;

            } else {
                heroItem.piece_btn.visible = true;
                heroItem.hire_btn.visible = false;
            }

            ObjectUtils.gray(heroItem.icon_img, true);
            ObjectUtils.gray(heroItem.bg_clip, true);

            heroItem.aptitude_lock_cliip.visible = true;
        }

        heroItem.icon_img.url = CPlayerPath.getUIHeroIconBigPath(heroData.prototypeID);
        heroItem.job_clip.index = heroData.job;
        _renderList[heroData.prototypeID] = true;
    }

    private function _onClickListHandler(evt:Event, idx:int) : void {
        if(evt.type == MouseEvent.CLICK) {
            var heroItem:Object = evt.currentTarget as Object;
            if (heroItem == null) return ;
            var heroID:int = (heroItem.dataSource as CPlayerHeroData).prototypeID;

            switch (evt.target.name) {
                case "equip_up":
                    this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_EQUIP_UP_CLICK, heroID));
                    break;
                case "hero_up":
                    this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_UP_CLICK, heroID));
                    break;
                case "hero_icon":
                    this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_ICON_CLICK, heroID));
                    break;
                case "hire":
                    this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_HIRE_CLICK, heroID));
                    break;
                case "piece_btn":
                    this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_HERO_SEARCH_PIECE_CLICK, heroID));
                    break;
            }
        }
    }

    private function _onResize(e:Event) : void {
        var ui:Object = _ui;
        ui.lock_box.y = ui.unlock_box.y + ui.unlock_box.displayHeight + 20;
    }

    // 数据更新之后, set dataSource, 然后refreshPanel, dataSource执行是delayCall, 而refreshPanel是马上执行, 导致scrollChange使用了错误的数据
    private var _lastScrollValue:int;
    private function _onScrollChange(value:int) : void {
        if (_lastScrollValue == value) {
            return ;
        }
        _lastScrollValue = value;
        var lockCells:Vector.<Box> = _ui.lock_icon_list.cells;
        var unLockCells:Vector.<Box> = _ui.unlock_icon_list.cells;
        var allList:Vector.<Box> = lockCells.concat(unLockCells);
        var cell:Object;
        var isInRect:Boolean;
        var isItemHasRender:Boolean;
        for each (cell in allList) {
            if (cell && cell.dataSource) {
                isInRect = _isItemInScrollRect(cell);
                if (isInRect) {
                    var heroData:CPlayerHeroData = cell.dataSource as CPlayerHeroData;
                    if (heroData) {
                        isItemHasRender = heroData.prototypeID in _renderList;
                        if (!isItemHasRender) {
                            _renderItemB(cell);
                        }
                    }
                }
            }
        }
    }

    private var _tempItemPos:Point = new Point();
    private var _tempItemRect:Rectangle = new Rectangle();
    private function _isItemInScrollRect(cell:Object) : Boolean {
        var heroBox:Box = _ui.hero_box;
        if (heroBox == null) {
            return false;
        }
        _tempItemPos.x = cell.x;
        _tempItemPos.y = cell.y;
        var pos:Point = _tempItemPos;
        pos = cell.parent.localToGlobal(pos);
        pos = heroBox.globalToLocal(pos);
        var rect:Rectangle = _tempItemRect;
        rect.x = pos.x;
        rect.y = pos.y;
        rect.width = cell.width;
        rect.height = cell.height;
        if (_ui.panel.content.scrollRect.intersects(rect)) {
            return true;
        }
        return false;
    }

    private function get _ui() : Object {
        var ui:Object = rootUI as Object;
        return ui.viewStack.items[EPlayerWndTabType.STACK_ID_HERO_WND_LIST] as Object;
    }


    private function get _playerData() : CPlayerData {
        return _data as CPlayerData;
    }

    private var _rectPanel:Rectangle;
    private var _renderList:Object;
}
}
