//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/30.
 */
package kof.game.playerTeam.view.team_new {

import QFLib.Utils.FileType;

import kof.data.CDatabaseSystem;
import kof.game.artifact.data.CArtifactData;
import kof.game.common.CLang;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.CChildView;
import kof.game.instance.enum.EInstanceType;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.player.data.CPlayerVisitData;
import kof.table.PeakScoreLevel;
import kof.ui.master.Artifact.ArtifactItemUI;
import kof.ui.master.player_team.PlayerTeamSystemInfoUI;
import kof.ui.master.player_team.PlayerTeamUI;

import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CTeamSystemView extends CChildView {
    public function CTeamSystemView() {
    }
    protected override function _onCreate() : void {
        _sysUI.sys_title.text = CLang.Get("team_power_full_hero_title");
        _sysUI.sys_peak_title.text = CLang.Get("peak_name");
        _sysUI.sys_arena_title.text = CLang.Get("arena_name");
        _sysUI.sys_talent_title.text = CLang.Get("talent_name");
        _sysUI.sys_im_title.text = CLang.Get("impression_name");
        _sysUI.sys_art_title.text = CLang.Get("artifact_name");
        _sysUI.sys_im_property_title.text = CLang.Get("impression_property_add_title");
        _sysUI.sys_im_star_title.text = CLang.Get("impression_star_add_title");

        _sysUI.sys_power_title.text = CLang.Get("common_battle_value");
        _sysUI.sys_arena_power_title.text = CLang.Get("common_battle_value");
        _sysUI.sys_talent_power_title.text = CLang.Get("team_talent_power_title");
        _sysUI.sys_talent_peak_power_title.text = CLang.Get("team_talent_power_title");

        _sysUI.sys_im_power_title.text = CLang.Get("common_battle_value");
        _sysUI.sys_art_power_title.text = CLang.Get("common_battle_value");
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _sysUI.sys_right_btn.clickHandler = new Handler(_onHeroListRightBtn);
        _sysUI.sys_art_hero_list.renderHandler = new Handler(_onRenderArtifactItemB);
        _sysUI.sys_right_btn.scaleX = 1;
    }
    protected override function _onShowing() : void {
        var isSelf:Boolean = false; // 这里不能用_visitPlayerData.isSelf, 因为使用的都是visitor的数据, 如果直接访问battleBalue，是0
        _sysUI.sys_hero_list.renderHandler = new Handler(CHeroEmbattleListView.RenderHeroItem, [system, false, null, true, true, isSelf]);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _sysUI.sys_hero_list.renderHandler = null;
        _sysUI.sys_right_btn.clickHandler = null;
        _sysUI.sys_art_hero_list.renderHandler = null;

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui.tab.selectedIndex != 1) return true;

//        _sysUI.sys_panel.refresh();

        // 最强格斗家
        _updatePowerfullHero();

        // 拳皇大赛
        _updatePeakGame();

        // 竞技 场
        _updateArena();

        // 斗魂
        _updateTalent();

        // 亲密度
        _updateImpression();

        // 神器
        _updateArtifact();


        return true;
    }

    private function _updatePowerfullHero() : void {
        var pVisitData:CPlayerVisitData = _visitPlayerData;

        _sysUI.sys_power_txt.text = pVisitData.top10BattleValue.toString();
        _sysUI.sys_hero_list.dataSource = pVisitData.heroList.list;
        _sysUI.sys_hero_list.page = 0;

    }
    private function _onHeroListRightBtn() : void {
        if (_sysUI.sys_hero_list.page == 0) {
            _sysUI.sys_hero_list.page++;
        } else {
            _sysUI.sys_hero_list.page--;
        }

        if (_sysUI.sys_hero_list.page > 0) {
            _sysUI.sys_right_btn.scaleX = -1;
        } else {
            _sysUI.sys_right_btn.scaleX = 1;
        }
    }

    private function _updatePeakGame() : void {
        if (_peakHeroListView == null) {
            _peakHeroListView = new CHeroEmbattleListView(system, _sysUI.sys_peak_hero_list, EInstanceType.TYPE_PEAK_GAME_FAIR, null);
        }

        _peakHeroListView.updateData(EInstanceType.TYPE_PEAK_GAME_FAIR, _visitPlayerData.peakHeroList.list);
        _peakHeroListView.updateWindow();

        var peakData:CPeakGameData = (system.stage.getSystem(CPeakGameSystem) as CPeakGameSystem).peakGameData;
        var levelRecord:PeakScoreLevel = peakData.getLevelRecordByID(_visitPlayerData.peakHightestScoreLevelID);

        _sysUI.sys_peak_cur_rank.text = _visitPlayerData.peakCurScor.toString();
        _sysUI.sys_peak_max_level.text = levelRecord.levelName;
    }

    private function _updateArena() : void {
        _sysUI.sys_arena_cur_rank.text = _visitPlayerData.arenaRank.toString();
        _sysUI.sys_arena_max_rank.text = _visitPlayerData.arenaHightestRank.toString();
        _sysUI.sys_arena_power.text = _visitPlayerData.arenaPower.toString();

        if (_arenaHeroListView == null) {
            _arenaHeroListView = new CHeroEmbattleListView(system, _sysUI.sys_arena_hero_list, EInstanceType.TYPE_ARENA, null);
        }

        _arenaHeroListView.updateData(EInstanceType.TYPE_ARENA, _visitPlayerData.arenaHeroList.list);
        _arenaHeroListView.updateWindow();
    }

    private function _updateTalent() : void {
        _sysUI.sys_talent_level.text = _visitPlayerData.talentLevel.toString();
        _sysUI.sys_talent_power.text = _visitPlayerData.talentPower.toString();
        _sysUI.sys_talent_peak_level.text = _visitPlayerData.talentPeakLevel.toString();
        _sysUI.sys_talent_peak_power.text = _visitPlayerData.talentPeakPower.toString();
    }

    private function _updateImpression() : void {
        _sysUI.sys_im_level.text = _visitPlayerData.impressionTotalLevel.toString();
        _sysUI.sys_im_power.text = _visitPlayerData.impressionPower.toString();
        _sysUI.sys_im_property_hp.text = CLang.Get("player_hp") + " + " + _visitPlayerData.impressionProperty.HP;
        _sysUI.sys_im_property_attack.text = CLang.Get("player_attack") + " + " + _visitPlayerData.impressionProperty.Attack;
        _sysUI.sys_im_property_defend.text = CLang.Get("player_denfense") + " + " + _visitPlayerData.impressionProperty.Defense;

        var fStarHpAdd:Number = 0;
        var fStarAttackAdd:Number = 0;
        var fStarDefendsAdd:Number = 0;
        if (_visitPlayerData.impressionStarAddPercent.hasOwnProperty("1")) {
            fStarHpAdd = _visitPlayerData.impressionStarAddPercent["1"];
        }
        if (_visitPlayerData.impressionStarAddPercent.hasOwnProperty("2")) {
            fStarAttackAdd = _visitPlayerData.impressionStarAddPercent["2"];
        }
        if (_visitPlayerData.impressionStarAddPercent.hasOwnProperty("3")) {
            fStarDefendsAdd = _visitPlayerData.impressionStarAddPercent["3"];
        }
        _sysUI.sys_im_star_hp.text = CLang.Get("player_hp") + " + " + (fStarHpAdd/100).toFixed(2) + "%";
        _sysUI.sys_im_star_attack.text = CLang.Get("player_attack") + " + " + (fStarAttackAdd/100).toFixed(2) + "%";
        _sysUI.sys_im_star_defend.text = CLang.Get("player_denfense") + " + " + (fStarDefendsAdd/100).toFixed(2) + "%";
    }

    private function _updateArtifact() : void {

        var artList:Array = _visitPlayerData.artifactList;

        var artCount:int = artList.length;
        if (artCount < 3) {
            for (var i:int = 0; i < 3; i++) {
                if (i >= artCount) {
                    var artData:Object = {quality:1, id:i+1, lock:true, level:0};
                    artList.push(artData);
                } else {
                    artList[i].lock = false;
                }
            }
        }
        _sysUI.sys_art_hero_list.dataSource = artList;
        _sysUI.sys_art_power.text = _visitPlayerData.artifactPower.toString();

    }

    private var _tempArtifacData:CArtifactData;
    private function _onRenderArtifactItemB( item : Component, idx : int ) : void {
        if ( !(item is ArtifactItemUI) || item.dataSource == null) {
            item.visible = false;
            return;
        }
        item.visible = true;

        if (_tempArtifacData == null) {
            _tempArtifacData = new CArtifactData();
            _tempArtifacData.databaseSystem = system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
        }
        _tempArtifacData.updateDataByData({artifactID: item.dataSource.id, artifactLevel: item.dataSource.level, quality: item.dataSource.quality, isLock: item.dataSource.lock});

        var pItem:ArtifactItemUI = (item as ArtifactItemUI);
        pItem.img_mask.visible = pItem.icon_lock.visible = _tempArtifacData.isLock;
        pItem.img.url = _getArtifactURLC(_tempArtifacData.baseCfg.iconSource);
        pItem.clip_bg.index = _tempArtifacData.colorCfg.quality;

        pItem.txt_name.isHtml = true;
        pItem.txt_name.stroke = _tempArtifacData.colorCfg.traceside;
        pItem.txt_name.text = _tempArtifacData.htmlNameWithNum;

        pItem.img_dian.visible = false;

        var selectBox:Clip = pItem.select_clip;
        if (selectBox && selectBox.parent) {
            selectBox.parent.removeChild(selectBox);
        }

        var level:int = (item.dataSource["level"]);
        pItem.lv_txt.text = "LV" + level;
        pItem.lv_txt.visible = level > 0;


    }
    private function _getArtifactURLC( sName : String ) : String {
        if ( !sName || !sName.length )
            return null;
        return "icon/artifact/icon/" + sName + "." + FileType.PNG;
    }

    ///////////////////////////////////////////////////

    [Inline]
    private function get _ui() : PlayerTeamUI {
        return rootUI as PlayerTeamUI;
    }
    private function get _sysUI() : PlayerTeamSystemInfoUI {
        return _ui.sys_view;
    }
    [Inline]
    private function get _visitPlayerData() : CPlayerVisitData {
        return super._data as CPlayerVisitData;
    }

    private var _peakHeroListView:CHeroEmbattleListView;
    private var _arenaHeroListView:CHeroEmbattleListView;

}
}
