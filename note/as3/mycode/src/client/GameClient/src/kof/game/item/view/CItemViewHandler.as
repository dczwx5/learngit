//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/10/26.
 */
package kof.game.item.view {

import kof.framework.CViewHandler;
import kof.game.common.CItemUtil;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardPackageItemUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CItemViewHandler extends CViewHandler {
    public function CItemViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override protected function get additionalAssets() : Array {
        return [ "frameclip_item.swf","frameclip_item2.swf" ];
    }

    /**
     * 物品渲染通用方法
     * @param item
     * @param index
     */
    public function renderItem( item : Component, index : int ) : void {
        if ( !(item is RewardItemUI) ) {
            return;
        }

        if ( item == null || item.dataSource == null ) {
            return;
        }

        var rewardItem : RewardItemUI = item as RewardItemUI;
        rewardItem.mouseChildren = false;
        rewardItem.mouseEnabled = true;
        var itemData : CItemData = rewardItem.dataSource as CItemData;
        if ( itemData ) {
            rewardItem.icon_image.url = itemData.iconSmall;
            rewardItem.bg_clip.index = itemData.quality;

            if ( CItemUtil.isHeroItem( itemData ) ) {
                rewardItem.num_lable.text = "";

                var heroId : int = int( itemData.ID.toString().slice( 5, 8 ) );
                var heroData : CPlayerHeroData = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.heroList.createHero( heroId );
                if ( heroData ) {
                    var heroStar : int = int( itemData.itemRecord.param2 );
                    heroData.updateDataByData( {star : heroStar} );
                }

                rewardItem.clip_intelligence.visible = true;
                rewardItem.clip_intelligence.index = heroData.qualityBaseType;
                rewardItem.list_star.visible = true;
                rewardItem.list_star.repeatX = 5;
                rewardItem.list_star.dataSource = new Array( heroData.star );
                var listWidth : int = 11 * heroData.star + rewardItem.list_star.spaceX * (heroData.star - 1);
                rewardItem.list_star.x = rewardItem.width - listWidth >> 1;

                rewardItem.clip_eff.autoPlay = false;
                rewardItem.clip_eff.visible = false;

                rewardItem.box_eff.visible = true;
                rewardItem.clip_effect2.visible = true;
                rewardItem.clip_effect2.autoPlay = true;

                rewardItem.toolTip = new Handler( _showHeroTips, [ rewardItem, heroData ] );
            }
            else {
                rewardItem.num_lable.text = itemData.num > 1 ? itemData.num.toString() : "";
                rewardItem.clip_intelligence.visible = false;
                rewardItem.list_star.dataSource = [];
                rewardItem.list_star.visible = false;
                rewardItem.clip_effect2.visible = false;
                rewardItem.clip_effect2.autoPlay = false;
                rewardItem.box_eff.visible = true;
                rewardItem.clip_eff.visible = itemData.effect;
                rewardItem.clip_eff.autoPlay = itemData.effect;

                rewardItem.toolTip = new Handler( _showItemTips, [ rewardItem ] );
            }
        }
        else {
            rewardItem.num_lable.text = "";
            rewardItem.icon_image.url = "";
            rewardItem.bg_clip.index = 0;
            rewardItem.clip_intelligence.visible = false;
            rewardItem.list_star.dataSource = [];
            rewardItem.list_star.visible = false;
            rewardItem.clip_eff.autoPlay = false;
            rewardItem.clip_eff.visible = false;
            rewardItem.clip_effect2.autoPlay = false;
            rewardItem.clip_effect2.visible = false;
        }
    }

    public function renderBigItem( item : Component, index : int ) : void {
        var itemData : CItemData;
        if(item is RewardPackageItemUI)
        {
            var rewardItem : RewardPackageItemUI = item as RewardPackageItemUI;
            rewardItem.mouseChildren = false;
            rewardItem.mouseEnabled = true;
            itemData = rewardItem.dataSource as CItemData;
            if ( null != itemData ) {
                rewardItem.mc_item.txt_num.text = itemData.num > 1 ? itemData.num.toString() : "";
                rewardItem.mc_item.img.url = itemData.iconBig;
                rewardItem.mc_item.clip_bg.index = itemData.quality;
                rewardItem.mc_item.box_effect.visible = itemData.effect;
                if ( CItemUtil.isHeroItem( itemData ) ) {
                    var heroId : int = int( itemData.ID.toString().slice( 5, 8 ) );
                    var heroData : CPlayerHeroData = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.heroList.createHero( heroId );
                    if ( heroData ) {
                        var heroStar : int = int( itemData.itemRecord.param2 );
                        heroData.updateDataByData( {star : heroStar} );
                    }
                    rewardItem.list_star.visible = true;
                    rewardItem.list_star.repeatX = 5;
                    rewardItem.list_star.dataSource = new Array( heroData.star );
//                  var listWidth : int = 11 * heroData.star + rewardItem.list_star.spaceX * (heroData.star - 1);
                    rewardItem.list_star.x = (80 - heroData.star * 13)/2;
                    rewardItem.clip_intelligence.visible = true;
                    rewardItem.clip_intelligence.index = heroData.qualityBaseType;
                    rewardItem.mc_item.txt_num.text = "";
                }
               else
                {
                    rewardItem.list_star.dataSource = [];
                    rewardItem.list_star.visible = false;
                    rewardItem.clip_intelligence.visible = false;
                }
            }
            else {
                rewardItem.mc_item.txt_num.text = "";
                rewardItem.mc_item.img.url = "";
                rewardItem.mc_item.box_effect.visible = false;
                rewardItem.list_star.dataSource = [];
                rewardItem.list_star.visible = false;
                rewardItem.clip_intelligence.visible = false;
            }
            rewardItem.toolTip = new Handler( _showBigRewardItemTips, [ rewardItem ] );
            return;
        }

        if ( item is ItemUIUI)
        {
            var commonItem : ItemUIUI = item as ItemUIUI;
            commonItem.mouseChildren = false;
            commonItem.mouseEnabled = true;
            itemData = commonItem.dataSource as CItemData;
            if ( null != itemData ) {
                commonItem.txt_num.text = itemData.num > 1 ? itemData.num.toString() : "";
                commonItem.img.url = itemData.iconBig;
                commonItem.clip_bg.index = itemData.quality;
                commonItem.box_effect.visible = itemData.effect;
            }
            else {
                commonItem.txt_num.text = "";
                commonItem.img.url = "";
                commonItem.box_effect.visible = false;
            }
            commonItem.toolTip = new Handler( _showBigItemTips, [ commonItem ] );
        }
    }

    public function renderBigItemByHeroData( item : Component, index : int ) : void {

        if ( !(item is ItemUIUI) ) {
            return;
        }

        var commonItem : ItemUIUI = item as ItemUIUI;
        commonItem.mouseChildren = false;
        commonItem.mouseEnabled = true;
        commonItem.txt_num.text = "";
        commonItem.box_effect.visible = false;
        commonItem.clip_bg.index = 0;

        var heroID:int = -1;
        var heroData : CPlayerHeroData;
        if (commonItem.dataSource is CPlayerHeroData) {
            heroData = commonItem.dataSource as CPlayerHeroData;
            heroID = heroData.prototypeID;
        } else {
            heroID = commonItem.dataSource as int;
        }
        if ( heroID > 0 ) {
            commonItem.img.url = CPlayerPath.getHeroBigconPath( heroID );
        } else {
            commonItem.img.url = "";
        }

        if (heroData) {
            var playerSystem : CPlayerSystem = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem);
            item.toolTip = new Handler( playerSystem.showHeroTips, [ heroData ] );
        }
    }

    private function _showItemTips(item:RewardItemUI) : void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView, item);
    }

    private function _showBigItemTips(item:ItemUIUI):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }
    private function _showBigRewardItemTips(item:RewardPackageItemUI):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }
    private function _showHeroTips(item:RewardItemUI, heroData:CPlayerHeroData) : void
    {
        (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showHeroTips(heroData, item);
    }
}
}
