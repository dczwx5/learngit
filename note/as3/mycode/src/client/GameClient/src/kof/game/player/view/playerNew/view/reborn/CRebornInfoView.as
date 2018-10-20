//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/11.
 */
package kof.game.player.view.playerNew.view.reborn {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.part.CRewardItemListView;

import kof.game.player.data.CPlayerHeroData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.ui.master.jueseNew.reborn.RebornInfoUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;


public class CRebornInfoView extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:RebornInfoUI;

    public function CRebornInfoView( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        m_pViewUI = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        return ret;
    }

    override public function get viewClass() : Array {
        return [RebornInfoUI];
    }

    override  protected function get additionalAssets() : Array
    {
        return null;
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() ) {
            return false;
        }

        if ( !m_bViewInitialized ) {
            if ( !m_pViewUI ) {
                m_pViewUI = new RebornInfoUI();
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.ok_btn.clickHandler = new Handler(_onOk);
                m_pViewUI.cancel_btn.clickHandler = new Handler(_onCancel);
                m_pViewUI.item_list.renderHandler = new Handler(_onRenderItem);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay(heroData:CPlayerHeroData, rewardData:Array, consumeValue:int) : void {
        _heroData = heroData;
        _rewardData = rewardData;
        _consumeValue = consumeValue;
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        if(m_pViewUI.parent == null) {
            uiCanvas.addPopupDialog( m_pViewUI );
        }
    }


    override protected function updateDisplay() : void {
//        _consumeValue 更新页面
        m_pViewUI.consume_txt.text = _consumeValue.toString();

        if (_rewardData) {
            var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, _rewardData);
//            var itemListLength:int = 0;
//            if (rewardListData) {
//                itemListLength = rewardListData.itemList.length;
//            }

//            var repeatY:int = ((itemListLength-1)/m_pViewUI.item_list.repeatX) + 1;
//            if (itemListLength > 0) {
//                if (m_pViewUI.item_list.repeatY != repeatY) {
//                    m_pViewUI.item_list.repeatY = repeatY;
//                }
//            } else {
//                if (m_pViewUI.item_list.repeatY != 0) {
//                    m_pViewUI.item_list.repeatY = 0;
//                }
//            }

            if (rewardListData) {
                m_pViewUI.item_list.dataSource = rewardListData.itemList;

                m_pViewUI.gold_txt.text = rewardListData.gold.toString();
                m_pViewUI.hz_txt.text = rewardListData.badgeExp.toString();
                m_pViewUI.mj_txt.text = rewardListData.secretExp.toString();
                m_pViewUI.skillPointTxt.text = rewardListData.skillPoint.toString();
            } else {
                m_pViewUI.item_list.dataSource = [];

                m_pViewUI.gold_txt.text = "0";
                m_pViewUI.hz_txt.text = "0";
                m_pViewUI.mj_txt.text = "0";
                m_pViewUI.skillPointTxt.text = "0";
            }

        }
    }
    private function _onRenderItem(box:Component, idx:int) : void {
        CRewardItemListView.onRenderItem(system, box, idx, true, false);
    }

    private function _onOk() : void {
        if (!_rewardData || _rewardData.length == 0) {
            uiCanvas.showMsgAlert(CLang.Get("rebornNeedNotReborn"));
            return ;
        }

        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if (false == pReciprocalSystem.isEnoughToPay(_consumeValue)) {
            pReciprocalSystem.showCanNotBuyTips();
            return ;
        }

        pReciprocalSystem.showCostBdDiamondMsgBox(_consumeValue, function () : void {
            dispatchEvent(new Event("DoReborn"));
            removeDisplay();
        });
    }
    private function _onCancel() : void {
        removeDisplay();
    }
    private function _onClose(type : String) : void {
        removeDisplay();
    }

    public function removeDisplay() : void {
        if ( m_pViewUI && m_pViewUI.parent ) {
            m_pViewUI.close( Dialog.CLOSE );
        }
    }

    public function get isViewShow() : Boolean {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function get viewUI() : Component {
        return m_pViewUI;
    }

    private var _heroData:CPlayerHeroData;
    private var _rewardData:Array;
    private var _consumeValue:int;
}
}
