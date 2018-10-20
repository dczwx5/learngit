//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/14.
 */
package kof.game.player.view.playerNew {

import kof.framework.CViewHandler;
import kof.game.common.tips.ITips;
import kof.ui.imp_common.HeroCareerTipViewUI;

import morn.core.components.Component;

public class CHeroCareerTipsView extends CViewHandler implements ITips{

    private var m_pViewUI:HeroCareerTipViewUI;
    private var m_pTipsObj:Component;

    public function CHeroCareerTipsView( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ HeroCareerTipViewUI ];
    }

    public function addTips(component:Component, args:Array = null):void
    {
        if ( m_pViewUI == null )
        {
            m_pViewUI = new HeroCareerTipViewUI();
        }

        m_pTipsObj = component;

        App.tip.addChild(m_pViewUI);
    }

    public function hideTips():void
    {
        if(m_pViewUI)
        {
            m_pViewUI.remove();
        }
    }
}
}
