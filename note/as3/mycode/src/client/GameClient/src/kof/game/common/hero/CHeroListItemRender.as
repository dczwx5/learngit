//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/8.
 */
package kof.game.common.hero {

import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.imp_common.HeroItemSmall2UI;
import kof.ui.imp_common.HeroItemSmallUI;
import kof.ui.master.JueseAndEqu.RoleItem02UI;
import kof.ui.master.JueseAndEqu.RoleItem03UI;
import kof.ui.master.JueseAndEqu.RoleItemUI;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.Image;

public class CHeroListItemRender {
    public function renderItem(item:Component, idx:int) : void {
        if ( !(item is RoleItemUI) ) {
            return;
        }
        var roleItem:RoleItemUI = item as RoleItemUI;
        var heroData:CPlayerHeroData = roleItem.dataSource as CPlayerHeroData;
        if (!heroData) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        roleItem.state_clip.visible = false;

        if (isShowQuality) {
            roleItem.quality_clip.index = heroData.qualityLevelValue;
        } else {
            roleItem.quality_clip.index = 0;
        }

        roleItem.star_list.repeatX = heroData.star;
        roleItem.star_list.dataSource = new Array(heroData.star);
        roleItem.star_list.right = roleItem.star_list.right;
        if (isShowLevel) {
            roleItem.lv_txt.visible = true;
            roleItem.lv_txt.text = heroData.level.toString();
        } else {
            roleItem.lv_txt.visible = false;
        }
        roleItem.icon_image.cacheAsBitmap = true;
        roleItem.hero_icon_mask.cacheAsBitmap = true;
        roleItem.icon_image.mask = roleItem.hero_icon_mask;
        roleItem.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroData.prototypeID);

        roleItem.img_black.visible = !heroData.hasData;
        roleItem.img_question.visible = !heroData.isHeroOpened;
        roleItem.icon_image.visible = heroData.isHeroOpened;
        roleItem.star_list.visible = heroData.isHeroOpened;
    }

    // 方形的那种UI
    public function renderItemFlat(item:Component, idx:int) : void {
        if ( !(item is RoleItem02UI) ) {
            return;
        }
        var roleItem:RoleItem02UI = item as RoleItem02UI;
        var heroData:CPlayerHeroData = roleItem.dataSource as CPlayerHeroData;
        if (!heroData) {
            item.visible = false;
            return ;
        }
        item.visible = true;
        if (isShowQuality) {
            roleItem.quality_clip.index = heroData.qualityLevelValue;
        } else {
            roleItem.quality_clip.index = 0;
        }

        roleItem.star_list.repeatX = heroData.star;
        roleItem.star_list.dataSource = new Array(heroData.star);
        roleItem.star_list.right = roleItem.star_list.right;

        if (isShowLevel) {
            roleItem.lv_txt.visible = true;
            roleItem.lv_txt.text = heroData.level.toString();
        } else {
            roleItem.lv_txt.visible = false;
        }

        roleItem.icon_image.cacheAsBitmap = true;
        roleItem.hero_icon_mask.cacheAsBitmap = true;
        roleItem.icon_image.mask = roleItem.hero_icon_mask;
        roleItem.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroData.prototypeID);
    }

    // 方形的那种UI, 小的, 用的物品图标
    public function renderItemFlatSmall(item:Component, idx:int) : void {
        if ( !(item is HeroItemSmallUI) ) {
            return;
        }
        var roleItem:HeroItemSmallUI = item as HeroItemSmallUI;
        var heroData:CPlayerHeroData = roleItem.dataSource as CPlayerHeroData;

        var heroID:int;
        var qualityLevelValue:int;
        if (heroData) {
            qualityLevelValue = heroData.qualityLevelValue;
            heroID = heroData.prototypeID;
        }

        var commonHeroData:CCommonHeroData;
        if (!heroData) {
            commonHeroData = roleItem.dataSource as CCommonHeroData;
            if (!commonHeroData) {
                item.visible = false;
                return ;
            }
            heroID = commonHeroData.prototypeID;
            qualityLevelValue = commonHeroData.quality;
        }


        item.visible = true;
        if (isShowQuality) {
            roleItem.quality_clip.index = qualityLevelValue;
        } else {
            roleItem.quality_clip.index = 0;
        }

        roleItem.icon_image.cacheAsBitmap = true;
        roleItem.hero_icon_mask.cacheAsBitmap = true;
        roleItem.icon_image.mask = roleItem.hero_icon_mask;
        roleItem.icon_image.url = CPlayerPath.getHeroItemFacePath(heroID);
    }

    // 巅峰赛里只有底图和头像的, 小图
    public function renderItemSimpleSmall(item:Component, idx:int) : void {
        if ( !(item is HeroItemSmall2UI) ) {
            return;
        }
        var roleItem:HeroItemSmall2UI = item as HeroItemSmall2UI;
        var heroData:CPlayerHeroData = roleItem.dataSource as CPlayerHeroData;
        if (!heroData) {
            item.visible = false;
            return ;
        }
        item.visible = true;


        roleItem.icon_image.cacheAsBitmap = true;
        roleItem.hero_icon_mask.cacheAsBitmap = true;
        roleItem.icon_image.mask = roleItem.hero_icon_mask;
        roleItem.icon_image.url = CPlayerPath.getHeroBigconPath(heroData.prototypeID);
    }

    public function renderRoleItem03UI(item:Component, idx:int) : void {
        var itemUI:RoleItem03UI = item as RoleItem03UI;
        var data:CPlayerHeroData = itemUI.dataSource as CPlayerHeroData;

        if ( !data )return;
        itemUI.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath( data.prototypeID );
        itemUI.icon_image.mask = itemUI.hero_icon_mask;
        itemUI.clip_intell.index = data.qualityBaseType;
        itemUI.clip_career.index = data.job;
        itemUI.star_list.visible = false;
//        itemUI.star_list.repeatX = data.star;
    }

    public var isShowQuality:Boolean = true;
    public var isShowLevel:Boolean = true;
}
}
