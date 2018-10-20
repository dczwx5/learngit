//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/10/23.
 */
package kof.game.resourceInstance.view {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.instance.enum.EInstanceType;
import kof.game.item.view.part.CRewardItemListView;
import kof.table.Item;
import kof.table.ResourceExpConstance;
import kof.ui.demo.Currency.MoneyOneTipsUI;
import kof.ui.master.ResourceInstance.TrainInstanceViewUI;

import morn.core.components.List;

/**
 * 经验副本难度界面
 *
 * @author dendi (dendi@qifun.com)
 */
public class CTrainInstanceViewHandler extends CResourceInstanceBasicsViewHandler {
    public function CTrainInstanceViewHandler() {
        super();
        instanceType = EInstanceType.TYPE_TRAIN_INSTANCE;
    }

    override protected function onInitializeView() : Boolean {
        if(pViewUI == null)
            pViewUI = new TrainInstanceViewUI();

        return super.onInitializeView();
    }

    override public function initListData() : Array{
        var resourceInstanceDifficultyTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RESOURCEEXPCONSTANCE);
        if(resourceInstanceDifficultyTable){
            var instanceDifArray:Array = resourceInstanceDifficultyTable.toArray();
            return instanceDifArray;
        }
        return null;
    }

    override public function selectItemHandler( ... args ) : void {
        var list : List = args[ 0 ] as List;
        if ( list.selectedItem == null )
            return;
        m_selectedData = list.selectedItem as ResourceExpConstance;

        m_viewExternal.show();
        (m_viewExternal.view as CRewardItemListView).isShowItemCount = false;
        (m_viewExternal.view as CRewardItemListView).forceAlign = 1;
        (m_viewExternal.view as CRewardItemListView).updateLayout();

        var arr:Array = [];
        var len:int = (m_selectedData.Items as Array).length;
        for(var i:int = 0; i< len; i++){
            var item:Item = getItemForItemID(m_selectedData.Items[i]);
            if( item ){
                arr.push(item);
            }
        }

        m_viewExternal.setData(arr);
        m_viewExternal.updateWindow();
    }

    override public function get viewClass() : Array {
        return [ TrainInstanceViewUI,MoneyOneTipsUI ];
    }
}
}
