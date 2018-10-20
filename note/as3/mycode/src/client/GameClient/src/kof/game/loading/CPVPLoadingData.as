//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/10.
 */
package kof.game.loading {

import kof.data.CObjectData;

public class CPVPLoadingData extends CObjectData {
    public static const SelfHeadInfo:String = "selfHeadInfo";// 己方头部信息
    public static const EnemyHeadInfo:String = "enemyHeadInfo";// 对方头部信息
    public static const SelfHeroList:String = "selfHeroList";// 己方格斗家id列表
    public static const EnemyHeroList:String = "enemyHeroList";// 敌方格斗家id列表
    public static const EnemyQualityList:String = "enemyQualityList";// 敌方格斗家品质列表

    public function CPVPLoadingData()
    {
        super();
    }

    public static function createObjectData(selfHeadInfo:CPVPLoadingHeadData, enemyHeadInfo:CPVPLoadingHeadData,
                                            selfHeroList:Array, enemyHeroList:Array, enemyQualityList:Array = null) : Object
    {
        return {selfHeadInfo:selfHeadInfo, enemyHeadInfo:enemyHeadInfo, selfHeroList:selfHeroList, enemyHeroList:enemyHeroList,
            enemyQualityList:enemyQualityList};
    }

    public function get selfHeadInfo() : CPVPLoadingHeadData { return _data[SelfHeadInfo]; }
    public function get enemyHeadInfo() : CPVPLoadingHeadData { return _data[EnemyHeadInfo]; }
    public function get selfHeroIdList() : Array { return _data[SelfHeroList]; }
    public function get enemyHeroIdList() : Array { return _data[EnemyHeroList]; }
    public function get enemyQualityList() : Array { return _data[EnemyQualityList]; }
}
}
