//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/10.
 */
package kof.game.loading {

import kof.data.CObjectData;

public class CPVPLoadingHeadData extends CObjectData {
    public static const HeroId:String = "heroId";// 格斗家id
    public static const Star:String = "star";// 格斗家星级
    public static const Quality:String = "quality";// 格斗家品质
    public static const RoleName:String = "roleName";// 角色名字
    public static const InfoLabel1:String = "infoLabel1";// 第一列信息label
    public static const InfoValue1:String = "infoValue1";// 第一列信息value
    public static const InfoLabel2:String = "infoLabel2";// 第二列信息label
    public static const InfoValue2:String = "infoValue2";// 第二列信息value
    public static const IsShowHeadInfo:String = "isShowHeadInfo";// 是否显示头部信息

    public function CPVPLoadingHeadData()
    {
        super();
    }

    public static function createObjectData(heroId:int, star:int, quality:int, roleName:String, infoLabel1:String, infoValue1:*,
                                            infoLabel2:String, infoValue2:*, isShowHeadInfo:Boolean = true) : Object
    {
        return {heroId:heroId, star:star,quality:quality, roleName:roleName, infoLabel1:infoLabel1, infoValue1:infoValue1,
                infoLabel2:infoLabel2, infoValue2:infoValue2, isShowHeadInfo:isShowHeadInfo};
    }

    public function get heroId() : int { return _data[HeroId]; }
    public function get star() : int { return _data[Star]; }
    public function get quality() : int { return _data[Quality]; }
    public function get roleName() : String { return _data[RoleName]; }
    public function get infoLabel1() : String { return _data[InfoLabel1]; }
    public function get infoValue1() : * { return _data[InfoValue1]; }
    public function get infoLabel2() : String { return _data[InfoLabel2]; }
    public function get infoValue2() : * { return _data[InfoValue2]; }
    public function get isShowHeadInfo() : Boolean { return _data[IsShowHeadInfo]; }
}
}
