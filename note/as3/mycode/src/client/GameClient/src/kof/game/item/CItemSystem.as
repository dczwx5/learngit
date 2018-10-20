//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/12.
 */
package kof.game.item {

import kof.game.common.CLang;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.CItemInfoViewHandler;
import kof.game.item.view.CItemViewHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;

import morn.core.components.Component;

public class CItemSystem extends CItemSystemBase {

    private var m_pItemInfoView:CItemInfoViewHandler;

    public function CItemSystem() {
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.addBean(_uiHandler = new CItemUIHandler());
        this.addBean(new CItemViewHandler());
        this.addBean(_rewardTipsViewHandler = new CRewardTips());
        this.addBean(m_pItemInfoView = new CItemInfoViewHandler());

        return ret;
    }

    public function addTips(tipsClass:Class, item:Component, args:Array = null) : void {
        _uiHandler.addTips(tipsClass, item, args);
    }

    public function showRewardFull(data:CRewardListData) : void {
        (stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).addEventPopWindow( EPopWindow.POP_WINDOW_11, function():void{
            _uiHandler.showRewardFull(data);
        });
    }
    public function hideRewardFull() : void {
        _uiHandler.hideRewardFull();
    }

    public function showRewardTips(box:Component, args:Array = null) : void {
        if (_rewardTipsViewHandler) {
            _rewardTipsViewHandler.addTips(box, args);
        }
    }

    public function showItemInfo(itemData:CItemData):void
    {
        if(itemData)
        {
            m_pItemInfoView.itemData = itemData;
            m_pItemInfoView.setPos(stage.flashStage.mouseX, stage.flashStage.mouseY);
            m_pItemInfoView.addDisplay();
        }
    }

    // item.typeDisplay
    public static function getItemTypeNameByType(typeDisplay:int) : String {
        if (typeDisplay == 1) {
            return "[" + CLang.Get( "item_page_1" ) + "]";
        } else if ( typeDisplay == 2 ) {
            return "[" + CLang.Get( "item_page_2" ) + "]";
        } else if ( typeDisplay == 3 ) {
            return "[" + CLang.Get( "item_page_3" ) + "]";
        } else {
            return "[" + CLang.Get( "item_page_4" ) + "]";
        }
    }
    private var _uiHandler:CItemUIHandler;
    private var _rewardTipsViewHandler:CRewardTips;
}
}
