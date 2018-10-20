//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/24.
 * Time: 14:46
 */
package kof.game.clubBoss.datas.vo {

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/24
 */
public class CCBRewardResultInfo {
    public var rRank:Number=0;//个人排名
    public var cRank:Number=0;//工会排名

    public function CCBRewardResultInfo() {
    }

    public function setRewardInfo(obj:Object):void{
        this.rRank = obj.rRank;
        this.cRank = obj.cRank;
    }
}
}
