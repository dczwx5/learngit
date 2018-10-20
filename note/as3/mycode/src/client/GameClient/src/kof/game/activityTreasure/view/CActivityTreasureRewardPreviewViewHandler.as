//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by Ender 2018-6-29.
 */
package kof.game.activityTreasure.view {

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.activityTreasure.CActivityTreasureManager;
import kof.game.common.CRewardUtil;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.CItemViewHandler;
import kof.table.ActivityTreasureBox;
import kof.table.ActivityTreasureRepository;
import kof.ui.master.ActivityTreasure.ActivityTreasureRewardPreviewUI;
import kof.ui.master.ActivityTreasure.RewardPreviewListItemUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * @author Ender
 * @date 2018-6-29
 */
public class CActivityTreasureRewardPreviewViewHandler extends CViewHandler {

    private var m_pViewUI : ActivityTreasureRewardPreviewUI;
    private var m_bViewInitialized : Boolean;

    public function CActivityTreasureRewardPreviewViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ ActivityTreasureRewardPreviewUI ];
    }

    override protected function get additionalAssets() : Array {
//        return ["frameclip_item2.swf","frameclip_playerCard_result.swf"];
        return [ "frameclip_item2.swf" ];
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
                m_pViewUI = new ActivityTreasureRewardPreviewUI();
                m_pViewUI.rewardList1.renderHandler = new Handler( rewardListRander );
                m_pViewUI.rewardList2.renderHandler = new Handler( rewardListRander );

                m_pViewUI.closeHandler = new Handler( _onClose );

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    private function rewardListRander( item : RewardPreviewListItemUI, index : int ) : void {
        if ( item == null || item.dataSource == null )return;
        var data : CRewardData = item.dataSource as CRewardData;
        item.item.dataSource = data;
        //物品框
        (system.stage.getSystem( CItemSystem ).getHandler( CItemViewHandler ) as CItemViewHandler).renderBigItem( item.item, index );
        //物品名称
        item.txt_name.text = data.nameWithColor;
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            callLater( _addToDisplay );
        }
        else {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        uiCanvas.addPopupDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( m_pViewUI && m_pViewUI.parent ) {
                    m_pViewUI.close( Dialog.CLOSE );
                }
                break;
        }

        _removeListeners();
    }

    private function _initView() : void {

        //单个靶子奖励配表
        var rewardList1Table : IDataTable = activityTreasureManager.getActivityTreasureRepositoryTable();
        if ( rewardList1Table ) {
            var tempArr : Array = rewardList1Table.toArray();
            var rewardList1Arr : Array = [];
            for ( var i : int = 0; i < tempArr.length; i++ ) {
                var activityTreasureRepository : ActivityTreasureRepository = tempArr[ i ];
                rewardList1Arr.push( {ID : activityTreasureRepository.itemId, num : 1} );
            }
            var rewardListData1 : CRewardListData = CRewardUtil.createByList( system.stage, rewardList1Arr );
            m_pViewUI.rewardList1.dataSource = rewardListData1.list;
        }

        //行列宝箱奖励配表
        var rewardList2Table : IDataTable = activityTreasureManager.getActivityTreasureBoxTable();
        if ( rewardList2Table ) {
            var tempArr2 : Array = rewardList2Table.toArray();
            var rewardList2Arr : Array = [];
            for ( var j : int = 0; j < tempArr2.length; j++ ) {
                var activityTreasureBox : ActivityTreasureBox = tempArr2[ j ];
                for ( var m : int = 0; m < activityTreasureBox.itemID.length; m++ ) {
                    var isSameId : Boolean = false;
                    for ( var n : int = 0; n < rewardList2Arr.length; n++ ) {
                        var obj : Object = rewardList2Arr[ n ];
                        if ( activityTreasureBox.itemID[ m ] == obj.ID ) {
                            isSameId = true;
                            break;
                        }
                    }
                    if ( isSameId == false ) {
                        rewardList2Arr.push( {ID : activityTreasureBox.itemID[ m ], num : 1} );
                    }
                }
            }
            var rewardListData2 : CRewardListData = CRewardUtil.createByList( system.stage, rewardList2Arr );
            m_pViewUI.rewardList2.dataSource = rewardListData2.list;
        }


    }

    private function _addListeners() : void {
    }

    private function _removeListeners() : void {
    }

    override protected function updateDisplay() : void {
    }

    override public function dispose() : void {
    }

    private function get activityTreasureManager() : CActivityTreasureManager {
        return (system.getBean( CActivityTreasureManager ) as CActivityTreasureManager);
    }
}
}
