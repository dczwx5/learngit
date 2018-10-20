//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/5.
 */
package kof.game.gem.data {

import QFLib.Foundation.CMap;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;

import kof.framework.IDataTable;

import kof.framework.IDatabase;
import kof.game.bag.data.CBagData;
import kof.game.gem.CGemManagerHandler;
import kof.game.gem.Enum.EGemEmbedType;
import kof.table.Gem;
import kof.table.Gem;

/**
 * 宝石合成分类列表数据
 */
public class CGemCategoryListData {

    private var m_pDataBase:IDatabase;
    private var m_pManager:CAbstractHandler;
    private var m_pMap:CMap;

    public function CGemCategoryListData(dataBase:IDatabase, manager:CAbstractHandler)
    {
        m_pDataBase = dataBase;
        m_pManager = manager;
        m_pMap = new CMap();
    }

    /**
     * 得所有列表头数据
     * @return
     */
    public function getHeadListData():Array
    {
        var arr:Array = [];
        for(var key:CGemCategoryHeadData in m_pMap)
        {
            arr.push(key);
        }

        arr.sortOn("type", Array.NUMERIC);

        return  arr;
    }

    /**
     * 得单个列表头数据
     * @param gemType
     * @return
     */
    public function getHeadByType(gemType:int):CGemCategoryHeadData
    {
        if(m_pMap)
        {
            for(var head:CGemCategoryHeadData in m_pMap)
            {
                if(head && head.type == gemType)
                {
                    return head;
                }
            }
        }

        return null;
    }

    /**
     * 得子列表数据(CGemCategoryListCellData)
     * @param head
     * @return
     */
    public function getListData(head:CGemCategoryHeadData):Array
    {
        return m_pMap.find(head) as Array;
    }

    /**
     * 初始化表头和子列表数据(配置数据)
     */
    public function initHeadAndListData():void
    {
        var arr:Array = _gemTable.toArray();
        if(arr && arr.length)
        {
            for each(var gem:Gem in arr)
            {
                if(gem)
                {
                    var head:CGemCategoryHeadData = getHeadByType(gem.mosaicType);
                    if(head == null || m_pMap.find(head) == null)
                    {
                        head = new CGemCategoryHeadData();
                        head.type = gem.mosaicType;
                        head.name = _getNameByType(gem.mosaicType);
                        // TODO icon
                        m_pMap.add(head, []);
                    }

                    var dataArr:Array = m_pMap.find(head) as Array;
                    if(gem.level > 1)// 1级宝石不能被合成
                    {
                        var cellData:CGemCategoryListCellData = new CGemCategoryListCellData();
                        cellData.resultGem = gem;
                        cellData.stuffGem = _getStuffGem(gem.ID);
                        dataArr.push(cellData);
                        head.hasChild = true;
                    }
                }
            }

            updateHeadAndListData();
        }

        for(head in m_pMap)
        {
            if(head)
            {
                arr = getListData( head ) as Array;
                if ( arr && arr.length )
                {
                    arr.sort(sortByLevel);
                }
            }
        }
    }

    private function sortByLevel(a:CGemCategoryListCellData, b:CGemCategoryListCellData):int
    {
        if(a && b && a.resultGem && b.resultGem)
        {
            return a.resultGem.level - b.resultGem.level;
        }

        return 0;
    }

    /**
     * 宝石包变更后更新表头和子列表数据(可合成、数量等提示数据)
     */
    public function updateHeadAndListData():void
    {
        for(var head:CGemCategoryHeadData in m_pMap)
        {
            if(head)
            {
                head.isCanMerge = false;
                var arr:Array = getListData(head);
                if(arr && arr.length)
                {
                    for each(var cellData:CGemCategoryListCellData in arr)
                    {
                        var stuffGem:Gem = cellData.stuffGem;
                        var consumeNum:int = stuffGem == null ? 0 : stuffGem.consumeCount;
                        var ownNum:int = _getOwnStuffNum(cellData.resultGem.ID);

                        cellData.canMergeNum = consumeNum == 0 ? 0 : int(ownNum / consumeNum);
                        cellData.isCanMerge = stuffGem.canUpgrade && cellData.canMergeNum > 0;

                        if(cellData.isCanMerge)
                        {
                            head.isCanMerge = true;
                        }
                    }
                }
                else
                {
                    head.isCanMerge = false;
                }
            }
        }
    }

    private function _getNameByType(type:int):String
    {
        switch (type)
        {
            case EGemEmbedType.Type_Attack:
                return "攻击宝石";
            case EGemEmbedType.Type_Defense:
                return "防御宝石";
            case EGemEmbedType.Type_Life:
                return "生命宝石";
        }

        return "";
    }

    /**
     * 得材料宝石
     * @return
     */
    private function _getStuffGem(resultGemId:int):Gem
    {
        var arr:Array = _gemTable.findByProperty("upgradeAfterGem", resultGemId);
        if(arr && arr.length)
        {
            return arr[0] as Gem;
        }

        return null;
    }

    /**
     * 拥有的材料宝石数
     * @return
     */
    private function _getOwnStuffNum(resultGemId:int):int
    {
        var stuffGem:Gem = _getStuffGem(resultGemId);
        if(stuffGem)
        {
            var gemData:CGemData = (m_pManager as CGemManagerHandler).gemData;// 取宝石数据
            var bagListData:CGemBagListData = gemData == null ? null : gemData.bagListData;
            var bagData:CGemBagData = bagListData == null ? null : bagListData.getDataByID(stuffGem.ID);
            var ownNum:int = bagData == null ? 0 : bagData.gemNum;

            return ownNum;
        }

        return 0;
    }

    /**
     * 是否有可合成宝石
     * @return
     */
    public function hasCanMergeGem():Boolean
    {
        if(m_pMap)
        {
            for(var head:CGemCategoryHeadData in m_pMap)
            {
                if(head && head.isCanMerge)
                {
                    return true;
                }
            }
        }

        return false;
    }

//==========================================table==================================================
    private function get _gemConstant():IDataTable
    {
        return m_pDataBase.getTable(KOFTableConstants.GemConstant);
    }

    private function get _gemTable():IDataTable
    {
        return m_pDataBase.getTable(KOFTableConstants.Gem);
    }
}
}
