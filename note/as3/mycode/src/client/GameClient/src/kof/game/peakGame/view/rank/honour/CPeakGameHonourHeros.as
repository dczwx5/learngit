//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/29.
 */
package kof.game.peakGame.view.rank.honour {

import kof.framework.CAppSystem;
import kof.game.common.hero.CHeroSpriteUtil;
import kof.game.common.view.CChildView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.data.CPeakGameGloryData;
import kof.game.peakGame.data.CPeakGameRankItemData;
import kof.game.player.data.CPlayerData;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.master.PeakGame.PeakGameHornorTeamHeroUI;
import kof.ui.master.PeakGame.PeakGameHornorUI;
import kof.ui.master.PeakGame.PeakGameRankUI;

import morn.core.components.Image;

import morn.core.components.Label;

public class CPeakGameHonourHeros extends CChildView {
    public function CPeakGameHonourHeros() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _getHeroClip(1, 1).scaleX = -1;
        _getHeroClip(3, 0).scaleX = -1;
        _getHeroClip(3, 1).scaleX = -1;
        _getHeroClip(3, 2).scaleX = -1;

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.none_1_img.visible = false;
        _ui.none_2_img.visible = false;
        _ui.none_3_img.visible = false;
    }

    protected override function _onHide() : void {
        var ii:int = 0;
        for (var i:int = 0; i < 3; i++) {
            // 格斗家们
            for (ii = 0; ii < 3; ii++) {
                CHeroSpriteUtil.setSkin(uiCanvas as CAppSystem, _getHeroClip(i+1, ii), null);
            }
        }
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_rootUI.tab.selectedIndex != 2) return true;
        if (_peakGameData.gloryData.hasData() == false) {
            return true;
        }


        var page:int = _initialArgs[0] as int;

        var gloryData:CPeakGameGloryData = _peakGameData.gloryData.getGloryDataByIndex(page); // 每赛季数据
        var ii:int = 0;
        for (var i:int = 0; i < 3; i++) {
            var nameLabel:Label = _getTeamNameLabel(i);
            var guideNameLabel:Label = _getTeamGuideNameLabel(i);
            var noneImg:Image = _getNoneHeroImg(i);
            noneImg.visible = false;

            // 每个战队数据
            var rankData:CPeakGameRankItemData = gloryData.getByRanking(i+1);
            if (!rankData) {
                nameLabel.text = "";
                guideNameLabel.text = ""; // CLang.Get("common_none");
                // 格斗家们
                 for (ii = 0; ii < 3; ii++) {
                     CHeroSpriteUtil.setSkin(uiCanvas as CAppSystem, _getHeroClip(i+1, ii), null);
                 }
                noneImg.visible = true;
            } else {
                nameLabel.text = rankData.name;
                guideNameLabel.text = "";
                // 格斗家们
                var heroList:Array = rankData.heroList.list;
                for (ii = 0; ii < 3; ii++) {
                    if (ii < heroList.length) {
                        CHeroSpriteUtil.setSkin(uiCanvas as CAppSystem, _getHeroClip(i+1, ii), heroList[ii]);
                    } else {
                        CHeroSpriteUtil.setSkin(uiCanvas as CAppSystem, _getHeroClip(i+1, ii), null);
                    }
                }
            }
        }

        return true;
    }

    private function _getTeamNameLabel(index:int) : Label {
        return _ui["hero_name_" + (index+1) + "_txt"];
    }
    private function _getTeamGuideNameLabel(index:int) : Label {
        return _ui["hero_guild_" + (index+1) + "_txt"];
    }
    private function _getHeroClip(ranking:int, index:int) : CCharacterFrameClip {
        var view:PeakGameHornorTeamHeroUI = _ui["team_" + (ranking) + "_view"] as PeakGameHornorTeamHeroUI;
        return view["clipCharacter_" + (index+1)];
    }
    private function _getNoneHeroImg(index:int) : Image {
        return _ui["none_" + (index+1) + "_img"];
    }
    [Inline]
    private function get _ui() : PeakGameHornorUI {
        return (rootUI as PeakGameRankUI).honorView;
    }
    [Inline]
    private function get _rootUI() : PeakGameRankUI {
        return (rootUI as PeakGameRankUI);
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
}
}
