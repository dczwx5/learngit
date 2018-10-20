//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/4/7.
 * 巅峰赛专用，格斗家头像
 */
package kof.game.fightui.compoment {

import flash.display.DisplayObject;

import kof.framework.CViewHandler;
import kof.game.player.config.CPlayerPath;
import kof.ui.demo.FightHeadItemUI;
import kof.ui.demo.FightUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CFighterHeadViewHandler extends CViewHandler {
    private var m_fightUI:FightUI;

    private static const ROUND_NAME_ARY : Array = ['-第一回合-','-第二回合-','-第三回合-','-第四回合-','-第五回合-','-第六回合-'];

    public function CFighterHeadViewHandler($fightUI:FightUI = null) {
        super();
        m_fightUI = $fightUI;
        m_fightUI.list_headLeft.visible =
                m_fightUI.list_headRight.visible =
                        m_fightUI.txt_peakGameTurn.visible =
                        false;

        m_fightUI.list_headLeft.renderHandler = new Handler( renderItem );
        m_fightUI.list_headRight.renderHandler = new Handler( renderItem );
    }
    public function setData( data : Object):void {
        if(!m_fightUI )
            return;

        m_fightUI.list_headLeft.dataSource = data.P1HeroStatusList;
        m_fightUI.list_headRight.dataSource = data.P2HeroStatusList;
        m_fightUI.txt_peakGameTurn.text = ROUND_NAME_ARY[ data.round ];
        m_fightUI.list_headLeft.visible =
                m_fightUI.list_headRight.visible =
                        m_fightUI.txt_peakGameTurn.visible =
                        true;
    }
    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is FightHeadItemUI) ) {
            return;
        }
        var fightHeadItemUI : FightHeadItemUI = item as FightHeadItemUI;
        var object : Object = fightHeadItemUI.dataSource ;
        if ( object ) {
            fightHeadItemUI.img.url = CPlayerPath.getUIHeroIconBigPath( object.prosessionID );
            fightHeadItemUI.img.disabled = fightHeadItemUI.img_ko.visible = ( object.status == 1 );//0:存活 1:死亡
        }

        var pMaskDisplayObject : DisplayObject;
        pMaskDisplayObject =  fightHeadItemUI.getChildByName( 'mask' );
        if ( pMaskDisplayObject ) {
            fightHeadItemUI.img.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            fightHeadItemUI.img.mask = pMaskDisplayObject;
        }
    }
    public function hide(removed:Boolean = true):void {
        m_fightUI.list_headLeft.visible =
                m_fightUI.list_headRight.visible =
                        m_fightUI.txt_peakGameTurn.visible =
                        false;
    }


}
}
