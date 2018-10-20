//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/28.
 */
package kof.game.streetFighter.view.select_hero {

import flash.utils.getTimer;

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.hero.CHeroSpriteUtil;
import kof.game.common.view.CRootView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.CStreetFighterHeroHpData;
import kof.game.streetFighter.data.CStreetFighterHeroHpListData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.ui.master.StreetFighter.StreetFighterEmbattleUI;
import kof.ui.master.taskcallup.TaskCallUpHeroItemUI;

import morn.core.components.Box;

import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.components.List;
import morn.core.components.SpriteBlitFrameClip;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

// 匹配到之后的选择人物界面
public class CStreetFighterSelectHeroView extends CRootView {

    public function CStreetFighterSelectHeroView() {
        super(StreetFighterEmbattleUI, null, null, false);
    }

    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _isFrist = true;
        _ui.hero_1_view.selectedIndex = -1;
        _ui.hero_2_view.selectedIndex = -1;

        _ui.hero_1_view.renderHandler = new Handler(_onRenderHero1Item);
        _ui.hero_1_view.selectHandler = new Handler(_onHeroSelected1);
        _ui.hero_2_view.renderHandler = new Handler(_onRenderHero2Item);
        _ui.hero_2_view.selectHandler = new Handler(_onHeroSelected2);
        _ui.ok_btn.clickHandler = new Handler(_onOk);
        listEnterFrameEvent = true;
        _lastSelectHeroID = -1;
        _isSelected = false;

        _ui.select_1_img.visible = _ui.select_2_img.visible = false;

    }
    protected override function _onHide() : void {
        _ui.hero_1_view.renderHandler = null;
        _ui.hero_2_view.renderHandler = null;
        _ui.hero_1_view.selectHandler = null;
        _ui.hero_2_view.selectHandler = null;

        listEnterFrameEvent = false;
        _ui.ok_btn.clickHandler = null;

        CHeroSpriteUtil.setSkin( ( uiCanvas ) as CAppSystem, _ui.hero_1_sprite, null, false); _ui.hero_1_name_txt.visible = false;
        CHeroSpriteUtil.setSkin( ( uiCanvas ) as CAppSystem, _ui.hero_2_sprite, null, false); _ui.hero_2_name_txt.visible = false;

    }

    protected override function _onEnterFrame(delta:Number) : void {
        super._onEnterFrame(delta);
//        _streetData.matchData.
        if (_streetData.isAllSelectHeroOpened) {
            var curTime:int = getTimer();
            var subTime:int = curTime - _streetData.countDownStartTime;
            var leftTime:int = 10000 - subTime;
            if (leftTime < 0) {
                leftTime = 0;
            }
            _ui.count_down_num.num = (leftTime/1000);

        } else {
            _ui.count_down_num.num = 9;
        }

    }


    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;
            sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.SELECT_HERO_READY));
        }

        var myHeroList:Array = _playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_STREET_FIGHTER);
        _myHeroList.dataSource = myHeroList;
        _enemyHeroList.dataSource = _streetData.matchData.heroList.list;
        _myName.text = _playerData.teamData.name;
        _enemyName.text = _streetData.matchData.enemyName;
        _myCamp.index = 1;
        _enemyCamp.index = 0;

        _enemyHeroList.selectHandler = null;

        _processHeroListSelect();

        this.addToPopupDialog();

        return true;
    }

    private function _processHeroListSelect() : void {
        var enemyHeroSelectID:int = _streetData.enemySelectHeroID;
        var enemySelectedIndex:int = _getListIndexByHeroID(_streetData.matchData.enmeyHeroHpList, _enemyHeroList.dataSource as Array, enemyHeroSelectID); // 找到enemy已选择格斗家的index

        var mySelectHeroID:int = _streetData.mySelectHeroID;
        var mySelectedIndex:int = _getListIndexByHeroID(_streetData.myHeroHpList, _myHeroList.dataSource as Array, mySelectHeroID);
        if (_streetData.matchData.isSelfP1) {
            _onHeroSelected1(mySelectedIndex, true);
            _onHeroSelected2(enemySelectedIndex, false); // 使用已选择index
        }else {
            _onHeroSelected2(mySelectedIndex, true);
            _onHeroSelected1(enemySelectedIndex, false); // 使用已选择index
        }
        _enemySelectedImage.visible = _streetData.isEnemySelectHeroReady;
    }


    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
    }

    private function _onOk() : void {
        var heroList:List = _myHeroList;
        var selected_img:Image = _mySelectedImage;

        var selectHeroIndex:int = _mySelectIndex;
        if (selectHeroIndex == -1) {
            selectHeroIndex = 0;
        }
        var item:Component = heroList.getCell(selectHeroIndex);
        var heroData:CPlayerHeroData = item.dataSource as CPlayerHeroData;
        var heroID:int = heroData.prototypeID;
        var hpData:CStreetFighterHeroHpData = _streetData.myHeroHpList.getItem(heroData.prototypeID);
        if (hpData && hpData.HP <= 0) {
            uiCanvas.showMsgAlert(CLang.Get("street_can_not_select_dead_hero"));
            return ;
        }

        selected_img.visible = true;
        _isSelected = true;
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.SELECT_HERO_CLICK_OK, heroID));
    }

    private function _onRenderHero1Item(box:Component, idx:int) : void {
        _onRenderHeroItemB(box, idx, _streetData.matchData.isSelfP1);
    }
    private function _onRenderHero2Item(box:Component, idx:int) : void {
        _onRenderHeroItemB(box, idx, _streetData.matchData.isSelfP1 == false);
    }

    private function _onRenderHeroItemB(comp:Component, idx:int, isSelf:Boolean) : void {
        if (comp == null) return ;

        var dataSource:CPlayerHeroData = comp.dataSource as CPlayerHeroData;
        if (!dataSource) {
            comp.visible = false;
            return ;
        }
        comp.visible = true;

        var heroItem:TaskCallUpHeroItemUI = comp as TaskCallUpHeroItemUI;
        heroItem.clip_quality.index = dataSource.qualityBaseType;
        heroItem.clip_state.visible = false;
        heroItem.clip_type.visible = false;
        heroItem.star_list.visible = false;
        heroItem.box_effbg.visible = false;

        heroItem.icon_image.cacheAsBitmap = true;
        heroItem.hero_icon_mask.cacheAsBitmap = true;
        heroItem.icon_image.mask = heroItem.hero_icon_mask;
        heroItem.icon_image.url = CPlayerPath.getHeroBigconPath(dataSource.prototypeID);

        var isInEmbattle:Boolean = false;
        if (isSelf) {
            isInEmbattle = _mySelectIndex == idx;
        }
        if( isInEmbattle ){
            heroItem.clip_state.index = 2;
            heroItem.clip_state.visible = true;
            heroItem.box_effbg.visible = true;

        } else {
            heroItem.clip_state.visible = false;
            heroItem.box_effbg.visible = false;
        }

        heroItem.clip_type.index = dataSource.job;

        // 血
        var hp:int = 1;
        var hpMax:int = 1;
        var hpData:CStreetFighterHeroHpData;
        if (isSelf) {
            hpData = _streetData.myHeroHpList.getItem(dataSource.prototypeID);
        } else {
            hpData = _streetData.matchData.enmeyHeroHpList.getItem(dataSource.prototypeID);
        }
        ObjectUtils.gray(comp, false);
        if (hpData) {
            hp = hpData.HP;
            hpMax = hpData.MaxHP;
            if (hp <= 0) {
                ObjectUtils.gray(comp, true);
            }
        }

        if (isSelf) {
            heroItem.hp_bar.visible = true;
            hpMax = Math.max(hpMax, 1);
            heroItem.hp_bar.value = hp/hpMax;
        } else {
            heroItem.hp_bar.visible = false;
        }
    }

    private function _onHeroSelected1(idx:int, isByClick:Boolean = true) : void {
        if (-1 == idx) return ;
        var heroData:CPlayerHeroData = _processSelectHeroB(true, idx, isByClick);
        _onHeroSelectedB(_ui.hero_1_sprite, _ui.hero_1_img, heroData, idx, _streetData.matchData.isSelfP1);
    }
    private function _onHeroSelected2(idx:int, isByClick:Boolean = true) : void {
        if (-1 == idx) return ;
        var heroData:CPlayerHeroData = _processSelectHeroB(false, idx, isByClick);

        _onHeroSelectedB(_ui.hero_2_sprite, _ui.hero_2_img, heroData, idx, _streetData.matchData.isSelfP1 == false);
    }
    private function _processSelectHeroB(isP1:Boolean, idx:int, isByClick:Boolean) : CPlayerHeroData {
        var lastMySelectIndex:int = _mySelectIndex;
        var heroData:CPlayerHeroData;
        var isSelf:Boolean = isP1 == _streetData.matchData.isSelfP1;
        if (isSelf) {
            _mySelectIndex = idx;
            var myHeroList:Array = _playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_STREET_FIGHTER);
            if (myHeroList.length > idx) {
                heroData = myHeroList[idx] as CPlayerHeroData;
            }

            // 判断是否活着
            var heroHpData:CStreetFighterHeroHpData = _streetData.myHeroHpList.getItem(heroData.prototypeID);
            if (heroHpData && heroHpData.HP == 0 || _isSelected) {
                // 挂了 取消选择
                if (lastMySelectIndex != _mySelectIndex) {
                    // 选择改变了
                    _mySelectIndex = lastMySelectIndex;
                    _myHeroList.selectedIndex = _mySelectIndex; // 这里会重新调用select流程。然后不走这里的流程, 如果所有人都死了。会死循环
                }
                return null;
            }

            _streetData.mySelectHeroID = heroData.prototypeID;
            _updateSelectState();

            if (isByClick) {
                if ( heroData && _lastSelectHeroID != heroData.prototypeID) {
                    if (!(_isSelected && isSelf)) {
                        _lastSelectHeroID = heroData.prototypeID; // 防止选了阵亡角色后。重复发选人请求
                        sendEvent( new CViewEvent( CViewEvent.UI_EVENT, EStreetFighterViewEventType.SELECT_HERO, heroData.prototypeID ) );
                    }

                }
            }
        } else {
            // enemy
            if (_streetData.matchData.heroList && _streetData.matchData.heroList.list && _streetData.matchData.heroList.list.length > idx) {
                heroData = _streetData.matchData.heroList.list[idx];
            }
        }
        return heroData;
    }
    private function _updateSelectState() : void {
        var cellList:Vector.<Box> = _myHeroList.cells;
        for (var i:int = 0; i < cellList.length; i++) {
            var cell:TaskCallUpHeroItemUI = _myHeroList.getCell(i) as TaskCallUpHeroItemUI;
            cell.clip_state.index = 2;
            cell.clip_state.visible = i == _mySelectIndex;
            cell.box_effbg.visible = i == _mySelectIndex;
        }
    }
    private function _onHeroSelectedB(spriteBlitFrameClip:SpriteBlitFrameClip, heroNameImg:Image, heroData:CPlayerHeroData, idx:int, isSelf:Boolean) : void {
        if (_isSelected && isSelf) {
            return ;
        }

        if (!heroData) {
            return ;
        }

        CHeroSpriteUtil.setSkin( uiCanvas as CAppSystem, spriteBlitFrameClip, heroData, false);
        heroNameImg.url = CPlayerPath.getUIHeroNamePath(heroData.prototypeID);
    }


    private function _getListIndexByHeroID(hpListData:CStreetFighterHeroHpListData, heroList:Array, heroID:int) : int {
        var isFindAliveOnly:Boolean = false;
        var hpData:CStreetFighterHeroHpData;
        if (heroID <= 0) {
            isFindAliveOnly = true;
//            return -1;
        } else {
            hpData = hpListData.getItem(heroID);
            if (hpData && hpData.HP <= 0) {
                isFindAliveOnly = true;
            }
        }

        for (var i:int = 0; i < heroList.length; i++) {
            var heroData:CPlayerHeroData = heroList[i];
            if (heroData) {
                if (isFindAliveOnly) {
                    hpData = hpListData.getItem(heroData.prototypeID);
                    if (!hpData) {
                        return i;
                    } else {
                        if (hpData.HP > 0) {
                            return i;
                        }
                    }
                } else {
                    if (heroData.prototypeID == heroID) {
                        return i;
                    }
                }
            }
        }
        return -1;
    }
    //===================================get/set======================================
    // =========================================================================================================
    private function get _mySelectedImage() : Image { if (_streetData.matchData.isSelfP1) { return _ui.select_1_img; } else { return _ui.select_2_img; } }
    private function get _enemySelectedImage() : Image { if (_streetData.matchData.isSelfP1) { return _ui.select_2_img; } else { return _ui.select_1_img; } }
    private function get _myHeroList() : List { if (_streetData.matchData.isSelfP1) { return _ui.hero_1_view; } else { return _ui.hero_2_view; } }
    private function get _enemyHeroList() : List { if (_streetData.matchData.isSelfP1) { return _ui.hero_2_view; } else { return _ui.hero_1_view; } }
    private function get _myName() : Label { if (_streetData.matchData.isSelfP1) { return _ui.hero_1_name_txt; } else { return _ui.hero_2_name_txt; } }
    private function get _enemyName() : Label { if (_streetData.matchData.isSelfP1) { return _ui.hero_2_name_txt; } else { return _ui.hero_1_name_txt; } }
    private function get _myCamp() : Clip { if (_streetData.matchData.isSelfP1) { return _ui.p1_camp_clip; } else { return _ui.p2_camp_clip; } }
    private function get _enemyCamp() : Clip { if (_streetData.matchData.isSelfP1) { return _ui.p2_camp_clip; } else { return _ui.p1_camp_clip; } }

//    private function get _mySpriteBlitFrameClip() : SpriteBlitFrameClip { if (_streetData.matchData.isSelfP1) { return _ui.hero_1_sprite; } else { return _ui.hero_2_sprite; } }
//    private function get _enemySpriteBlitFrameClip() : SpriteBlitFrameClip { if (_streetData.matchData.isSelfP1) { return _ui.hero_2_sprite; } else { return _ui.hero_1_sprite; } }
//    private function get _myHeroNameImgae() : Image { if (_streetData.matchData.isSelfP1) { return _ui.hero_1_img; } else { return _ui.hero_2_img; } }
//    private function get _enemyHeroNameImgae() : Image { if (_streetData.matchData.isSelfP1) { return _ui.hero_2_img; } else { return _ui.hero_1_img; } }


    // =========================================================================================================

    [Inline]
    private function get _ui() : StreetFighterEmbattleUI {
        return rootUI as StreetFighterEmbattleUI;
    }
    [Inline]
    private function get _streetData() : CStreetFighterData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStreetFighterData;
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

    private var _isFrist:Boolean = true;
    private var _isSelected:Boolean;
    private var _mySelectIndex:int;
    private var _lastSelectHeroID:int;


}
}
