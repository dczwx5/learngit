//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/9.
 */
package kof.game.arena.view {

import kof.framework.CViewHandler;
import kof.game.arena.CArenaHelpHandler;
import kof.game.common.tips.ITips;
import kof.game.player.config.CPlayerPath;
import kof.ui.master.JueseAndEqu.RoleItem03UI;
import kof.ui.master.arena.ArenaRoleEmbattleTipsUI;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CArenaRoleEmbattleTipsView extends CViewHandler implements ITips{

    private var m_pViewUI:ArenaRoleEmbattleTipsUI;
    private var m_pTipsObj:Component;

    public function CArenaRoleEmbattleTipsView( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    public function addTips(box:Component, args:Array = null):void
    {
        if ( !m_pViewUI ) m_pViewUI = new ArenaRoleEmbattleTipsUI();
        m_pTipsObj = box;

        var data:Object = args[0];
        if(data)
        {
            m_pViewUI.txt_roleName.text = data["roleName"];
            m_pViewUI.list_hero.renderHandler = new Handler(_renderHero);
            m_pViewUI.list_hero.dataSource = data["heroList"] as Array;
        }

        App.tip.addChild(m_pViewUI);
    }

    private function _renderHero( item:Component, index:int):void
    {
        if ( !(item is RoleItem03UI) )
        {
            return;
        }

        var render:RoleItem03UI = item as RoleItem03UI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var data:Object = render.dataSource;
        if(null != data)
        {
            render.clip_intell.index = data["intelligence"];
            render.clip_career.index = data["career"];
//            render.quality_clip.index = _arenaHelp.getHeroQualityColor(data["quality"]);
            render.quality_clip.index = 0;
            render.icon_image.mask = render.hero_icon_mask;
            render.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(data["heroId"]);
//            render.star_list.renderHandler = new Handler(_renderStar);

//            var arr:Array = [];
//            for(var i:int = 0; i < data["star" ]; i++)
//            {
//                arr[i] = 1;
//            }
            render.star_list.dataSource = new Array(data["star"]);
            render.star_list.centerX = 0;
        }
        else
        {
            render.clip_intell.index = 0;
            render.clip_career.index = 0;
            render.quality_clip.index = 0;
            render.icon_image.url = "";
            render.star_list.dataSource = [];
        }
    }

    private function _renderStar( item:Component, index:int):void
    {
        if ( !(item is Box) )
        {
            return;
        }

        var render:Box = item as Box;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        var data:Object = render.dataSource;
        if(null != data)
        {
            render.visible = true;
        }
        else
        {
            render.visible = false;
        }
    }

    public function hideTips():void
    {
        if(m_pViewUI)
        {
            m_pViewUI.remove();
        }
    }

    public function get _arenaHelp():CArenaHelpHandler
    {
        return system.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
    }
}
}
