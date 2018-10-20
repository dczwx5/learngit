//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem {

import QFLib.Foundation.CMap;

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CAttributeUtil;
import kof.game.common.data.CAttributeBaseData;
import kof.game.gem.Enum.EGemPageType;
import kof.game.gem.data.CGemBagData;
import kof.game.gem.data.CGemBagData;
import kof.game.gem.data.CGemBagData;
import kof.game.gem.data.CGemConst;
import kof.game.gem.data.CGemData;
import kof.game.gem.data.CGemData;
import kof.game.gem.data.CGemHoleData;
import kof.game.gem.data.CGemPageData;
import kof.game.gem.data.CGemPageData;
import kof.game.gem.data.CGemPageData;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.table.Gem;
import kof.table.Gem;
import kof.table.Gem;
import kof.table.GemPoint;
import kof.table.GemSuit;

public class CGemHelpHandler extends CAbstractHandler {

    private var m_pAttrMap:CMap;

    public function CGemHelpHandler()
    {
        super();
    }

    /**
     * 通过宝石孔位置得宝石孔数据
     */
    public function getGemHoleDataByHoleIndex(pageType:int, holeIndex:int):CGemHoleData
    {
        var pageData:CGemPageData = _manager.gemData.pageListData.getDataByPage(pageType);
        if(pageData)
        {
            var arr:Array = pageData.gemHoleListData.list;
            for each(var holeData:CGemHoleData in arr)
            {
                var gemPoint:GemPoint = _gemPoint.findByPrimaryKey(holeData.gemPointConfigID) as GemPoint;
                if(gemPoint && gemPoint.pointID == holeIndex)
                {
                    return holeData;
                }
            }
        }

        return null;
    }

    /**
     * 某个孔是否可镶嵌
     * @param gemHoleConfigID
     * @return
     */
    public function isCanEmbed(gemHoleConfigID:int):Boolean
    {
        var arr:Array = getCanEmbedGems(gemHoleConfigID);
        return arr && arr.length;
    }

    /**
     * 某个孔是否可升级
     * @param gemHoleConfigID 宝石孔ID
     * @param gemConfigID 宝石孔镶嵌的宝石ID
     * @return
     */
    public function isCanUpgrade(gemHoleConfigID:int, gemConfigID:int):Boolean
    {
        if(!gemConfigID)
        {
            return false;
        }

        var gemConfig:Gem = _gemTable.findByPrimaryKey(gemConfigID) as Gem;
        if(gemConfig)
        {
            if(!gemConfig.canUpgrade)
            {
                return false;
            }

            var gemData:CGemData = _manager.gemData;
            if(gemData && gemData.bagListData)
            {
                var bagData:CGemBagData = gemData.bagListData.getDataByID(gemConfigID);
                var hasNum:int = bagData == null ? 0 : bagData.gemNum;
                hasNum += 1;// 当前镶嵌的也算

                return hasNum >= gemConfig.consumeCount;
            }
        }

        return false;
    }

    /**
     * 得宝石包列表渲染用的数据
     * @return
     */
    public function getBagRenderListData():Array
    {
        var result:CRewardListData = new CRewardListData();
        result.setToRootData(system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem);

        var dataList:Array = [];
        var dataSource:Array = _manager.gemData.bagListData.list;
        for (var i:int = 0; i < dataSource.length; i++)
        {
            var bagData:CGemBagData = dataSource[i] as CGemBagData;
            var sourceID:int = bagData.gemConfigID;
            var num:int = bagData.gemNum;
            var rewardType:int = CRewardData.getTypeByID(sourceID);
            var rewardData:Object = CRewardData.buildData(rewardType, sourceID, num);
            dataList.push(rewardData);
        }

        result.updateDataByData(dataList);

        return result.list;
    }

    public function getPageNameByType(type:int):String
    {
        var pageName:String = "";
        switch (type)
        {
            case EGemPageType.Type_Heart:
                pageName = "战队之心";
                break;
            case EGemPageType.Type_Soul:
                pageName = "战队之魂";
                break;
            case EGemPageType.Type_Power:
                pageName = "战队之力";
                break;
        }

        return pageName;
    }

    public function getAttrDataByPage(pageType:int):Array
    {
        if(m_pAttrMap == null)
        {
            m_pAttrMap = new CMap();
        }
        m_pAttrMap.clear();

        _accumulatePageAllAttr(pageType);

        var resultArr:Array = m_pAttrMap.toArray();
        resultArr.sortOn("attrType", Array.NUMERIC);

        return resultArr;
    }

    /**
     * 累计当前页的总属性值(宝石属性+套装属性)
     * @param pageType
     */
    private function _accumulatePageAllAttr(pageType:int):void
    {
        // 当前页镶嵌的所有宝石所加属性
        var pageData:CGemPageData = _manager.gemData.pageListData.getDataByPage(pageType);
        if(pageData)
        {
            var holeDatas:Array = pageData.gemHoleListData.list;
            for each(var holeData:CGemHoleData in holeDatas)
            {
                if(holeData && holeData.gemConfigID)
                {
                    var gemTableData:Gem = _gemTable.findByPrimaryKey(holeData.gemConfigID) as Gem;
                    if(gemTableData && gemTableData.propertysAdd)
                    {
                        var attrDatas:Array = CAttributeUtil.parseAttrStr(gemTableData.propertysAdd, system);
                        _accumulateAttr(attrDatas);
                    }
                }
            }
        }

        //当前页套装所加属性
        _accumulateSuitAttr(pageType);
    }

    /**
     * 累加套装属性
     * @param pageType
     */
    private function _accumulateSuitAttr(pageType:int):void
    {
        var suitAttr:Array = getSuitAttrByPage(pageType);
        _accumulateAttr(suitAttr);
    }

    /**
     * 累加属性
     * @param dataArr (ElementType:CAttributeBaseData)
     */
    private function _accumulateAttr(dataArr:Array):void
    {
        if(dataArr && dataArr.length)
        {
            for each(var attrData:CAttributeBaseData in dataArr)
            {
                if(m_pAttrMap.hasOwnProperty(attrData.attrType + ""))// 已经有的就叠加
                {
                    var existData:CAttributeBaseData = m_pAttrMap.find(attrData.attrType + "") as CAttributeBaseData;
                    existData.attrBaseValue += attrData.attrBaseValue;
                }
                else// 没有的就新增
                {
                    m_pAttrMap.add(attrData.attrType+"", attrData);
                }
            }
        }
    }

    /**
     * 某页的套装等级
     * @param pageType
     * @return
     */
    public function getSuitLevelByPage(pageType:int):int
    {
        var minLevel:int = 100;
        var count:int = 0;
        var pageData:CGemPageData = _manager.gemData.pageListData.getDataByPage(pageType);
        if(pageData && pageData.gemHoleListData)
        {
            var holeArr:Array = pageData.gemHoleListData.list;
            if(holeArr.length == CGemConst.MaxHoleNum)
            {
                for each(var holeData:CGemHoleData in holeArr)
                {
                    if(holeData && holeData.gemConfigID)
                    {
                        var gem:Gem = _gemTable.findByPrimaryKey(holeData.gemConfigID) as Gem;
                        var level:int = gem == null ? 0 : gem.level;
                        if(level < minLevel)
                        {
                            minLevel = level;
                        }

                        count++;
                    }
                }
            }
        }

        var arr:Array = _gemSuit.toArray();
        var firstSuitLevel:int = arr.length > 0 ? arr[0 ].suitLevel : 0;
        if(count == CGemConst.MaxHoleNum && minLevel >= firstSuitLevel)
        {
            return minLevel;
        }

        return 0;
    }

    /**
     * 套装所加的属性
     * @return
     */
    public function getSuitAttrByPage(pageType:int):Array
    {
        var arr:Array = _gemSuit.findByProperty("pageID", pageType);
        var suitLevel:int = getSuitLevelByPage(pageType);
        for each(var gemSuit:GemSuit in arr)
        {
            if(gemSuit && gemSuit.suitLevel == suitLevel)
            {
                return CAttributeUtil.parseAttrStr(gemSuit.propertysAdd, system);
            }
        }

        return [];
    }

    public function getSuitAttrByPageAndLevel(pageType:int, suitLevel:int):Array
    {
        var arr:Array = _gemSuit.findByProperty("pageID", pageType);
        for each(var gemSuit:GemSuit in arr)
        {
            if(gemSuit && gemSuit.suitLevel == suitLevel)
            {
                return CAttributeUtil.parseAttrStr(gemSuit.propertysAdd, system);
            }
        }

        return [];
    }

    /**
     * 某个套装已经达成的数量
     * @param pageType
     * @param suitLevel
     * @return
     */
    public function getCurrNumBySuitLevel(pageType:int, suitLevel:int):int
    {
        var count:int = 0;
        var gemData:CGemData = _manager.gemData;
        if(gemData && gemData.pageListData)
        {
            var pageData:CGemPageData = gemData.pageListData.getDataByPage(pageType);
            if(pageData)
            {
                var holeArr:Array = pageData.gemHoleListData.list;
                if(holeArr && holeArr.length)
                {
                    for each(var holeData:CGemHoleData in holeArr)
                    {
                        if(holeData.gemConfigID)
                        {
                            var gem:Gem = _gemTable.findByPrimaryKey(holeData.gemConfigID) as Gem;
                            if(gem && gem.level >= suitLevel)
                            {
                                count++;
                            }
                        }
                    }
                }
            }
        }

        return count;
    }

    /**
     * 得所有标签页所加的总属性(包括所有套装)
     * @return
     */
    public function getTotalAttrData():Array
    {
        if(m_pAttrMap == null)
        {
            m_pAttrMap = new CMap();
        }
        m_pAttrMap.clear();

        _accumulatePageAllAttr(EGemPageType.Type_Heart);
        _accumulatePageAllAttr(EGemPageType.Type_Power);
        _accumulatePageAllAttr(EGemPageType.Type_Soul);

        var resultArr:Array = m_pAttrMap.toArray();

        return resultArr;
    }

    public function getGemConfigInfoById(gemConfigId:int):Gem
    {
        return _gemTable.findByPrimaryKey(gemConfigId) as Gem;
    }


    /**
     * 得某个孔可镶嵌的宝石
     * @param gemHoleConfigId
     * @return
     */
    public function getCanEmbedGems(gemHoleConfigId:int):Array
    {
        var resultArr:Array = [];
        if(gemHoleConfigId)
        {
            var gemPoint:GemPoint = _gemPoint.findByPrimaryKey(gemHoleConfigId) as GemPoint;
            var mosaicType1:int = gemPoint == null ? 0 : gemPoint.mosaicType;
            var bagDatas:Array = _manager.gemData.bagListData.list;
            for each(var bagData:CGemBagData in bagDatas)
            {
                var gem:Gem = _gemTable.findByPrimaryKey(bagData.gemConfigID) as Gem;
                var mosaicType2:int = gem == null ? 0 : gem.mosaicType;

                if(mosaicType1 == mosaicType2)
                {
                    resultArr.push(bagData);
                }
            }
        }

        resultArr.sort(sortByLevel);
        return resultArr;
    }

    private function sortByLevel(a:CGemBagData, b:CGemBagData):int
    {
        if(a && b)
        {
            var configA:Gem = _gemTable.findByPrimaryKey( a.gemConfigID) as Gem;
            var configB:Gem = _gemTable.findByPrimaryKey( b.gemConfigID) as Gem;
            if(configA && configB)
            {
                return configB.level - configA.level;
            }
        }

        return 0;
    }

    /**
     * 宝石孔开启等级
     * @param pageType 页号
     * @param holeIndex 孔位置
     * @return
     */
    public function getHoleIndexOpenLevel(pageType:int, holeIndex:int):int
    {
        var arr:Array = _gemPoint.findByProperty("pageID", pageType) as Array;
        if(arr && arr.length)
        {
            for each(var holeData:GemPoint in arr)
            {
                if(holeData && holeData.pointID == holeIndex)
                {
                    return holeData.openLevel;
                }
            }
        }

        return 0;
    }

    public function isCanOperate():Boolean
    {
        return isCanOperateByPage(EGemPageType.Type_Heart)
                || isCanOperateByPage(EGemPageType.Type_Power)
                || isCanOperateByPage(EGemPageType.Type_Soul);
    }

    /**
     * 某页是否有可操作项
     * @param pageType
     * @return
     */
    public function isCanOperateByPage(pageType:int):Boolean
    {
        return isCanEmbedByPage(pageType) || isCanUpgradeByPage(pageType);
    }

    /**
     * 某页是否可镶嵌
     * @param pageType
     * @return
     */
    public function isCanEmbedByPage(pageType:int):Boolean
    {
        var gemData:CGemData = _manager.gemData;
        if(gemData && gemData.pageListData)
        {
            var pageData:CGemPageData = gemData.pageListData.getDataByPage(pageType);
            if(pageData && pageData.gemHoleListData)
            {
                var arr:Array = pageData.gemHoleListData.list;
                for each(var holeData:CGemHoleData in arr)
                {
                    if(holeData && holeData.gemPointConfigID && !holeData.gemConfigID && isCanEmbed(holeData.gemPointConfigID))
                    {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    /**
     * 某页是否可升级
     * @param pageType
     * @return
     */
    public function isCanUpgradeByPage(pageType:int):Boolean
    {
        var gemData:CGemData = _manager.gemData;
        if(gemData && gemData.pageListData)
        {
            var pageData:CGemPageData = gemData.pageListData.getDataByPage(pageType);
            if(pageData && pageData.gemHoleListData)
            {
                var arr:Array = pageData.gemHoleListData.list;
                for each(var holeData:CGemHoleData in arr)
                {
                    if(holeData && holeData.gemPointConfigID && isCanUpgrade(holeData.gemPointConfigID, holeData.gemConfigID))
                    {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    public function getBagDataById(gemConfigId:int):CGemBagData
    {
        if(_manager.gemData)
        {
            var bagData:CGemBagData = _manager.gemData.bagListData.getDataByID(gemConfigId);
            return bagData;
        }

        return null;
    }

    /**
     * 得宝石包中拥有的某种宝石数量
     * @param gemId
     * @return
     */
    public function getOwnGemNum(gemId:int):int
    {
        var bagData:CGemBagData = getBagDataById(gemId);
        var ownNum:int = bagData == null ? 0 : bagData.gemNum;

        return ownNum;
    }

    /**
     * 宝石合成页是否有宝石可合成
     * @return
     */
    public function isCanMerge():Boolean
    {
        return _manager.gemCategoryListData && _manager.gemCategoryListData.hasCanMergeGem();
    }

//==========================================table==================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _gemConstant():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GemConstant);
    }

    private function get _gemTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.Gem);
    }

    private function get _gemPoint():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GemPoint);
    }

    private function get _gemSuit():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GemSuit);
    }

    private function get _manager():CGemManagerHandler
    {
        return system.getHandler(CGemManagerHandler) as CGemManagerHandler;
    }
}
}
