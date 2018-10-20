//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/20.
 */
package kof.game.platform.tx.data {
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.tx.enum.ETXIdentityType;

public class CTXData extends CPlatformBaseData {
    public function CTXData() {
        super ();
    }

    public override function updateData(data:Object) : void {
        if (!data) return ;

        this.pf = data["pf"];

        this.isBlueVip = data["isBlueVip"];
        this.isBlueYearVip = data["isBlueYearVip"];
        this.blueVipLevel = data["blueVipLevel"];
        this.isSuperBlueVip = data["isSuperBlueVip"];
        this.isSuperBlueYearVip = data["isSuperBlueYearVip"];

        this.isYellowVip = data["isYellowVip"];
        this.yellowVipLevel = data["yellowVipLevel"];
        this.isYellowYearVip = data["isYellowYearVip"];
        this.isYellowHighVip = data["isYellowHighVip"];
    }

    /**
     * @return 返回-1表示数据还没初始化完成（PlayerSystem系统初始化完成后，会初始化QQ相关数据）
     *
     * 返回0表示不是QQ的会员
     * */
    public function getQQLevel() : int {
        if (isQGame) {
            if ( blueVipLevel > 0 ) {
                return blueVipLevel;
            }
            return 0;
        } else if (isQZone) {
            if ( yellowVipLevel > 0 ) {
                return yellowVipLevel;
            }
            return 0;
        }
        return 0;
    }

    /**
     * @return 返回-1表示数据还没初始化完成（PlayerSystem系统初始化完成后，会初始化QQ相关数据）
     *
     * 返回0表示不是QQ的会员
     * (优先返回 豪华年费蓝钻>年费蓝钻>豪华蓝钻>普通蓝钻)
     * (年费黄钻>普通黄钻)
     * */
    public function getQQIdentity() : int {
        if (isQGame) {
            if ( isSuperBlueYearVip || ( isSuperBlueVip && isBlueYearVip ) ) {
                return ETXIdentityType.SUPER_BLUE_YEAR;
            }

            if ( isBlueYearVip ) {
                return ETXIdentityType.BLUE_YEAR;
            }
            if ( isSuperBlueVip ) {
                return ETXIdentityType.SUPER_BLUE;
            }
            if ( isBlueVip ) {
                return ETXIdentityType.BLUE;
            }
            return 0;
        } else if (isQZone) {
            if ( isYellowYearVip ) {
                return ETXIdentityType.YELLOW_YEAR;
            }
            if ( isYellowVip ) {
                return ETXIdentityType.YELLOW;
            }
            return 0;
        }

        return 0;
    }

    [Inline]
    public function get isQZone() : Boolean {
        return pf == EPlatformType.TYPE_QQ_ZONE;
    }
    [Inline]
    public function get isQGame() : Boolean {
        return pf == EPlatformType.TYPE_QQ_GAME;
    }

    public var isYellowVip : Boolean;
    public var yellowVipLevel : int = -1;
    public var isYellowYearVip : Boolean;
    public var isYellowHighVip : Boolean;


    public var isBlueVip : Boolean;
    public var isBlueYearVip : Boolean = false;
    public var blueVipLevel : int = -1;
    public var isSuperBlueVip : Boolean;
    public var isSuperBlueYearVip : Boolean;

}
}
