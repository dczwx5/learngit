//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/7.
 */
package kof.game.peakGame.view.main {

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.components.KOFNum;
import kof.ui.master.PeakGame.PeakGameUI;

import morn.core.components.Box;
import morn.core.components.Button;

import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.FrameClip;

import morn.core.components.Image;
import morn.core.components.Label;

public class CPeakGameMainHeros extends CChildView {
    public function CPeakGameMainHeros() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _moveOutList = new Array(18);
        _selectRect = new Rectangle();
        _mousePos = new Point();
        _lastSelectIndex = -1;

        for (var index:int = 0; index < 3; index++) {
            var compIndex:int = index + 1;
            var heroNameLabel:Image = _ui["hero_name" + compIndex + "_txt"] as Image; // 名字
            var quality:Clip = _ui["hero_quality_" + compIndex] as Clip; // 品质
            var npcBg:Image = _ui["npc_bg_" + compIndex] as Image; // npc bg - 用来选人的
            var base_bg:Image = _ui["base_bg_" + compIndex] as Image; // base bg : 底
            var heroBox:Box = _ui["hero_box_" +  + compIndex] as Box; // 头像所在box
            var role_index_box:Box = _ui["role_index_box_" + compIndex]; // 人物索引1,2,3
            var attrBox:Box = _ui["box_attr" + compIndex]; // 参赛属性

            var startIndex:int = index * MOVE_COMP_COUNT;

            _moveOutList[startIndex + 0] = heroNameLabel;
            _moveOutList[startIndex + 1] = quality;
            _moveOutList[startIndex + 2] = npcBg;
            _moveOutList[startIndex + 3] = base_bg;
            _moveOutList[startIndex + 4] = heroBox;
            _moveOutList[startIndex + 5] = role_index_box;
            _moveOutList[startIndex + 6] = attrBox;
        }

        _tweenProcessList = new Vector.<TweenProcess>(3);
        _tweenProcessList[0] = new TweenProcess(_moveOutList.filter(function (item:Component, idx:int, arr:Array) : Boolean {
            return idx < (MOVE_COMP_COUNT + 0 * MOVE_COMP_COUNT);
        }), 0);
        _tweenProcessList[1] = new TweenProcess(_moveOutList.filter(function (item:Component, idx:int, arr:Array) : Boolean {
            return idx >= MOVE_COMP_COUNT && idx < (MOVE_COMP_COUNT + 1 * MOVE_COMP_COUNT);
        }), 1);
        _tweenProcessList[2] = new TweenProcess(_moveOutList.filter(function (item:Component, idx:int, arr:Array) : Boolean {
            return idx >= MOVE_COMP_COUNT * 2 &&  idx < (MOVE_COMP_COUNT + 2 * MOVE_COMP_COUNT);
        }), 2);
        _tweenProcessList[0]._pProcessList = _tweenProcessList;
        _tweenProcessList[1]._pProcessList = _tweenProcessList;
        _tweenProcessList[2]._pProcessList = _tweenProcessList;
    }

    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.base_bg_1.addEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.base_bg_2.addEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.base_bg_3.addEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.embattle_1_btn.addEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.embattle_2_btn.addEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.embattle_3_btn.addEventListener(MouseEvent.CLICK, _onClickHero);


        _ui.addEventListener(MouseEvent.MOUSE_OVER, _onMoveHero);

        _ui.hero_quality_1.visible = _ui.hero_quality_2.visible = _ui.hero_quality_3.visible = false;
        _lastSelectIndex = -1;

        _ui.box_attr1.visible = _ui.box_attr2.visible = _ui.box_attr3.visible = false;
    }

    protected override function _onHide() : void {
        _ui.base_bg_1.removeEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.base_bg_2.removeEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.base_bg_3.removeEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.embattle_1_btn.removeEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.embattle_2_btn.removeEventListener(MouseEvent.CLICK, _onClickHero);
        _ui.embattle_3_btn.removeEventListener(MouseEvent.CLICK, _onClickHero);

        _ui.removeEventListener(MouseEvent.MOUSE_OVER, _onMoveHero);

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        _ui.hero_quality_1.visible = _ui.hero_quality_2.visible = _ui.hero_quality_3.visible = false;
        _ui.box_attr1.visible = _ui.box_attr2.visible = _ui.box_attr3.visible = false;

        var emList:CEmbattleListData = (system as CPeakGameSystem).embattleListData;
        if (!emList) return true;
        for (var i:int = 0; i < 3; i++) {
            var icon:Image = _ui["hero_icon" + (i+1) + "_img"] as Image;
            var heroNameLabel:Image = _ui["hero_name" + (i+1) + "_txt"] as Image;
            var quality:Clip = _ui["hero_quality_" + (i+1)] as Clip;
            var attrBox:Box = _ui["box_attr" + (i+1)] as Box;
            var emData:CEmbattleData = emList.getByPos(i+1);
            if (!emData) {
                icon.visible = false;
                heroNameLabel.visible = false;
                quality.visible = false;
                attrBox.visible = false;
                continue ;
            }
            var heroData:CPlayerHeroData = _playerData.heroList.getHero(emData.prosession);
            if (!heroData) {
                icon.visible = false;
                heroNameLabel.visible = false;
                quality.visible = false;
                attrBox.visible = false;

                continue ;
            }
            heroNameLabel.url = CPlayerPath.getUIHeroNamePath(heroData.prototypeID);
//            heroNameLabel.text = CLang.Get("peak_hero_name", {v1:heroData.heroName});
            heroNameLabel.visible = true;
            quality.visible = true;
            quality.index = heroData.qualityBaseType;

            icon.visible = true;
            icon.url = CPlayerPath.getPeakUIHeroFacePath(heroData.prototypeID);

            attrBox.visible = true;
            var attrValue:KOFNum = attrBox.getChildByName("num_attr") as KOFNum;
            if(_peakGameData.peakConstantTableData)
            {
                var num:int = heroData.battleValue * (_peakGameData.peakConstantTableData.battleValueParam / 10000) * 0.01;
                attrValue.num = num;
            }
        }

        delayCall(0.1, setPosition);
        function setPosition():void
        {
            for(i = 0; i < 3; i++)
            {
                var attrValue:KOFNum = _ui["box_attr" + (i+1)].getChildByName("num_attr") as KOFNum;
                var percent:Image = _ui["box_attr" + (i+1)].getChildByName("img_percent") as Image;
                percent.x = attrValue.x + attrValue.width + 2;
            }
        }

        return true;
    }

    private function _onClickHero(e:MouseEvent) : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EPeakGameViewEventType.MAIN_CLICK_EMBATTLE));
        e.stopImmediatePropagation();
    }
    private function _onMoveHero(e:MouseEvent) : void {
        for (var i:int = 0; i < 3; i++) {
            var img:Image = _ui["base_bg_" + (i+1)];
            var embattleBtn:Button = _ui["embattle_" + (i+1) + "_btn"];
            _selectRect.x = img.x;
            _selectRect.y = img.y;
            _selectRect.width = img.width;
            _selectRect.height = img.height;

            _mousePos.x = e.stageX;
            _mousePos.y = e.stageY;
            _mousePos = img.parent.globalToLocal(_mousePos);

            var isInRect:Boolean = _selectRect.containsPoint(_mousePos);
            if (isInRect) {
                if (_lastSelectIndex != i) {
                    _resetHeroPos(_lastSelectIndex);
                    _lastSelectIndex = i;

                    _heroMoveOut(i);
                }
                embattleBtn.visible = true;
                return ;
            }
        }

        for (i = 0; i < 3; i++) {
            _resetHeroPos(i);
        }
        _lastSelectIndex = -1;
    }

    private function _heroMoveOut(index:int) : void {
        if (-1 == index) return ;
        _tweenProcessList[index ].tween();

        var box:Box = (_ui["hero_eff_box_" + (index+1)] as Box);
        box.visible = true;
        var heroEffect:FrameClip = (_ui["hero_eff_" + (index+1)] as FrameClip);
        heroEffect.visible = true;
        heroEffect.playFromTo();
    }
    private function _resetHeroPos(index:int) : void {
        if (-1 == index) return ;
        _tweenProcessList[index ].resetTween();
        _ui.embattle_1_btn.visible = _ui.embattle_2_btn.visible = _ui.embattle_3_btn.visible = false;
        _ui.hero_eff_box_1.visible = _ui.hero_eff_box_2.visible = _ui.hero_eff_box_3.visible =
                _ui.hero_eff_1.visible = _ui.hero_eff_2.visible = _ui.hero_eff_3.visible = false;
        _ui.hero_eff_1.stop();
        _ui.hero_eff_2.stop();
        _ui.hero_eff_3.stop();
    }

    [Inline]
    private function get _ui() : PeakGameUI {
        return rootUI as PeakGameUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _moveOutList:Array;
    private const MOVE_COMP_COUNT:int = 7;
    private var _selectRect:Rectangle;
    private var _mousePos:Point;
    private var _lastSelectIndex:int;

    private var _tweenProcessList:Vector.<TweenProcess>;

}
}

import com.greensock.TweenLite;

import flash.geom.Rectangle;

import morn.core.components.Component;

class TweenProcess {
    public function TweenProcess(objList:Array, index:int) {
        _objList = objList;
        _index = index;

        _baseSizeList = new Vector.<Rectangle>(_objList.length);
        _tweenSizeList = new Vector.<Rectangle>(_objList.length);
        _baseScaleList = new Vector.<Number>(_objList.length);

        for (var i:int = 0; i < _objList.length; i++) {
            var comp:Component = _objList[i];
            _baseScaleList[i] = comp.scale;
            _baseSizeList[i] = new Rectangle(comp.x, comp.y, comp.width, comp.height);
            var tweenWidth:Number = comp.width * _SCALE_RADE;
            var tweenHeight:Number = comp.height * _SCALE_RADE;
            _tweenSizeList[i] = new Rectangle(comp.x - (tweenWidth - comp.width)/2, comp.y - (tweenHeight - comp.height)/2, tweenWidth, tweenHeight)
        }
    }

    public function dispose() : void {
        _pProcessList = null;
    }

    private function _stopTween() : void {
        for (var i:int = 0; i < _objList.length; i++) {
            var comp:Component = _objList[i];
            TweenLite.killTweensOf(comp, true);
        }
    }
    public function tween() : void {
//        trace("_________________tween");
        _stopTween();

        for (var i:int = 0; i < _objList.length; i++) {
            var comp:Component = _objList[i];
            comp.scale = _baseScaleList[i];
            var toScale:Number = comp.scale * _SCALE_RADE;
            TweenLite.to(comp, 0.2, {x:_tweenSizeList[i].x, y:_tweenSizeList[i].y, scale:toScale});
        }
        if (_index == 0) {
            _pProcessList[1].tweenRight();
            _pProcessList[2].tweenRight();
        } else if (_index == 1) {
            _pProcessList[0].tweenLeft();
            _pProcessList[2].tweenRight();
        } else {
            _pProcessList[0].tweenLeft();
            _pProcessList[1].tweenLeft();
        }
    }

    private function tweenRight() : void {
        var movePixel:Number = 10;
        for (var i:int = 0; i < _objList.length; i++) {
            var comp:Component = _objList[i];
            TweenLite.to(comp, 0.2, {x:_baseSizeList[i].x + movePixel});
        }

    }
    private function tweenLeft() : void {
        var movePixel:Number = -10;
        for (var i:int = 0; i < _objList.length; i++) {
            var comp:Component = _objList[i];
            TweenLite.to(comp, 0.2, {x:_baseSizeList[i].x + movePixel});
        }
    }

    public function resetTween() : void {
//        trace("_________________resetTween");
        _stopTween();
        for (var i:int = 0; i < _objList.length; i++) {
            var comp:Component = _objList[i];
            TweenLite.to(comp, 0.2, {x:_baseSizeList[i].x, y:_baseSizeList[i].y, scale:_baseScaleList[i]});
        }
    }

    private var _objList:Array;
    private var _index:int;

    private var _baseSizeList:Vector.<Rectangle>;
    private var _tweenSizeList:Vector.<Rectangle>;
    private var _baseScaleList:Vector.<Number>;
    private const _SCALE_RADE:Number = 1.09;

    public var _pProcessList:Vector.<TweenProcess>;
}
