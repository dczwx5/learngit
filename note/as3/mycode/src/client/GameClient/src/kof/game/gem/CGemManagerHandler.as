//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem {

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.gem.Enum.EGemUpdateType;
import kof.game.gem.data.CGemBagData;
import kof.game.gem.data.CGemBagListData;
import kof.game.gem.data.CGemCategoryListData;
import kof.game.gem.data.CGemData;
import kof.game.gem.data.CGemPageData;
import kof.game.gem.event.CGemEvent;
import kof.message.Gem.GemInfoResponse;
import kof.message.Gem.GemInfoUpdateResponse;

public class CGemManagerHandler extends CAbstractHandler {

    private var m_pGemData:CGemData;
    private var m_pGemCategoryListData:CGemCategoryListData;// 宝石合成分类列表数据(非服务器数据)

    public function CGemManagerHandler()
    {
        super();
    }

    /**
     * 初始化宝石数据
     * @param response
     */
    public function initGemData(response:GemInfoResponse):void
    {
        if(response)
        {
            if(m_pGemData == null)
            {
                m_pGemData = new CGemData(system.stage.getSystem(IDatabase) as IDatabase);
            }

            m_pGemData.pageListData.updateDataByData(response.allPointInfos);
            m_pGemData.bagListData.updateDataByData(response.gemWarehouse);
        }
    }

    /**
     * 宝石信息改变数据更新
     */
    public function updateGemInfo(response:GemInfoUpdateResponse):void
    {
        if(response && response.updateInfos)
        {
            if(response.updateInfos.hasOwnProperty("pointUpdate"))// 宝石孔信息更新
            {
                var holeInfo:Object = response.updateInfos["pointUpdate"];
                var pageType:int = holeInfo["pageType"];
                var holeArr:Array = holeInfo["pointInfos"] as Array;
                var pageData:CGemPageData = m_pGemData.pageListData.getDataByPage(pageType);
                if(pageData == null)// 首次为空则创建
                {
                    var obj:Object = {};
                    obj[CGemPageData.PageType] = pageType;
                    obj[CGemPageData.PointInfos] = [];

                    m_pGemData.pageListData.updateDataByData(obj);

                    pageData = m_pGemData.pageListData.getDataByPage(pageType);
                }

                for each(var info:Object in holeArr)
                {
                    var updateState:int = info["updateState"] as int;
                    delete info["updateState"];

                    pageData.gemHoleListData.updateDataByData(info);
                }

                if(holeArr.length > 0)
                {
                    system.dispatchEvent(new CGemEvent(CGemEvent.UpdateGemHoleInfo, null));
                }
            }

            if(response.updateInfos.hasOwnProperty("gemWarehouse"))// 宝石库信息更新
            {
                var gemListData:CGemBagListData = m_pGemData.bagListData;
                var gemArr:Array = response.updateInfos["gemWarehouse"] as Array;
                if(gemArr && gemArr.length)
                {
                    for each(var gem:Object in gemArr)
                    {
                        updateState = gem["updateState"] as int;
                        delete gem["updateState"];

                        if(updateState == EGemUpdateType.Type_Delete)
                        {
                            gemListData.removeByPrimary(gem["gemConfigID"]);
                        }
                        else
                        {
                            gemListData.updateDataByData(gem);
                        }
                    }
                }

                if(gemArr.length > 0)
                {
                    system.dispatchEvent(new CGemEvent(CGemEvent.UpdateGemBagInfo, null));
                }
            }
        }
    }

    /**
     * 得宝石包中某个宝石的数量
     * @param gemConfigId 宝石唯一id
     * @return
     */
    public function getGemNum(gemConfigId:int):int
    {
        var count:int = 0;
        if(gemData && gemData.bagListData)
        {
            var arr:Array = gemData.bagListData.list;
            for each(var bagData:CGemBagData in arr)
            {
                if(bagData.gemConfigID == gemConfigId)
                {
                    count += bagData.gemNum;
                }
            }
        }

        return count;
    }

    public function get gemData():CGemData
    {
        return m_pGemData;
    }

    // 非服务器数据
    public function get gemCategoryListData():CGemCategoryListData
    {
        if(m_pGemCategoryListData == null)
        {
            var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
            m_pGemCategoryListData = new CGemCategoryListData(dataBase, this);

            m_pGemCategoryListData.initHeadAndListData();
        }

        return m_pGemCategoryListData;
    }
}
}
