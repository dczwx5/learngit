//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/27.
 */
package kof.game.peakGame.view {


import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.tips.ITips;
import kof.game.peakGame.data.CPeakGameRankItemData;
import kof.ui.master.PeakGame.PeakGamePlayerTipsUI;

import morn.core.components.Component;
public class CPeakGamePlayerTips extends CViewHandler implements ITips {

    public function CPeakGamePlayerTips() {
        super();

    }

    public function addTips(box:Component, args:Array = null) : void {
        if (!_isInitial) {
            _isInitial = true;
            _ui = new PeakGamePlayerTipsUI();
            _ui.level_title_txt.text = CLang.Get("player_level") + ":";
            _ui.guide_title_txt.text = CLang.Get("common_guide") + ":";
            _ui.win_count_title_txt.text = CLang.Get("peak_win_count") + ":";
            _ui.fight_count_title_txt.text = CLang.Get("common_fight2") + ":";
            _ui.team_power_title_txt.text = CLang.Get("common_team_battle_value") + ": ";

        }


        if (args[0] is CPeakGameRankItemData) {
            // 服务器发下来的数据
            var playerData:CPeakGameRankItemData = args[0] as CPeakGameRankItemData;
            _ui.name_txt.text = playerData.name;
            _ui.level_value_txt.text = playerData.level.toString();
            if (playerData.clubName && playerData.clubName.length > 0) {
                _ui.guide_value_txt.text = playerData.clubName;
            } else {
                _ui.guide_value_txt.text = CLang.Get("common_none");
            }
            _ui.win_count_value_txt.text = playerData.winCount.toString(); // 胜场/出战次数, 没数据
            _ui.fight_count_value_txt.text = playerData.fightCount.toString(); // 胜场/出战次数, 没数据
            _ui.team_power_value_txt.text = playerData.battleValue.toString(); // 战力, 无数据
        } else {
            var objectData:Object = args[0] as Object;
            _ui.name_txt.text = objectData.name;
            _ui.level_value_txt.text = objectData.level.toString();
            if (objectData.clubName && objectData.clubName.length > 0) {
                _ui.guide_value_txt.text = objectData.clubName;
            } else {
                _ui.guide_value_txt.text = CLang.Get("common_none");
            }
            _ui.win_count_value_txt.text = objectData.winCount.toString(); // 胜场/出战次数, 没数据
            _ui.fight_count_value_txt.text = objectData.fightCount.toString(); // 胜场/出战次数, 没数据
            _ui.team_power_value_txt.text = objectData.allFightBattleValue.toString(); // 战力, 无数据
        }


        App.tip.addChild(_ui);
    }

    public function hideTips():void{
        _ui.remove();
    }

    private var _ui:PeakGamePlayerTipsUI;
    private var _isInitial:Boolean;


}
}
