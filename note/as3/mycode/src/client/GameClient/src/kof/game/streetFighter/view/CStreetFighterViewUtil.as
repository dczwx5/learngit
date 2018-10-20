//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.view {

import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.CStreetFighterHeroHpData;
import kof.ui.master.StreetFighter.StreetFighterDuelUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CStreetFighterViewUtil {
    public static function _onRenderHeroItem(playerData:CPlayerData, comp:Component, idx:int, addHandler:Handler, streedData:CStreetFighterData, showHpBar:Boolean) : void {
        var item:StreetFighterDuelUI = comp as StreetFighterDuelUI;
        var embattleData:CEmbattleData = item.dataSource as CEmbattleData;
        var dataSource:CPlayerHeroData;
        if (embattleData) {
            dataSource = playerData.heroList.getHero(embattleData.prosession);
        }

        item.head_mask.cacheAsBitmap = true;
        item.head_img.cacheAsBitmap = true;
        item.head_img.mask = item.head_mask;
        if (!dataSource) {
            item.add_btn.visible = true;
            item.quality_clip.visible = false;
            item.job_clip.visible = false;
            item.star_list.visible = false;
            item.hp_bar.visible = false;
            item.head_img.visible = false;
            item.star_bg_list.visible = false;

            item.add_btn.clickHandler = addHandler;
            item.visible = true;
            return ;
        }

        item.add_btn.visible = false;
        item.quality_clip.visible = true;
        item.job_clip.visible = true;
        item.star_list.visible = true;
        item.hp_bar.visible = true;
        item.head_img.visible = true;
        item.star_bg_list.visible = true;


        item.head_img.url = CPlayerPath.getPeakUIHeroFacePath(dataSource.prototypeID);
        item.quality_clip.index = dataSource.qualityBaseType;
        item.job_clip.index = dataSource.job;
        item.star_list.dataSource = dataSource.star;
        if (item.star_list.repeatX != dataSource.star) {
            item.star_list.repeatX = dataSource.star;
        }

        if (showHpBar) {
            ObjectUtils.gray(item, false);
            var hpData:CStreetFighterHeroHpData = streedData.myHeroHpList.getItem(dataSource.prototypeID);
            item.hp_bar.value = 1.0;
            if (hpData) {
                var maxHp:int = hpData.MaxHP;
                maxHp = Math.max(maxHp, 1);
                item.hp_bar.value = hpData.HP / maxHp;
                if (hpData.HP <= 0) {
                    ObjectUtils.gray(item, true);
                }
            }
        }

    }
}
}
