//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CVipData extends CObjectData {
    public function CVipData() {
    }

    public function get vipLv() : Number {
        return _rootData.data[ _vipLv ];
    }
    public function get vipExp() : Number {
        return _rootData.data[ _vipExp ];
    }
    public function get vipGifts() : Array {
        if ( _rootData.data[ _vipGifts ] == null ) {
            return new Array();
        }
        return _rootData.data[ _vipGifts ];
    }
    public function get vipEverydayReward() : Array {
        if ( _rootData.data[ _vipEverydayReward ] == null ) {
            return new Array();
        }
        return _rootData.data[ _vipEverydayReward ];
    }
    public function get vipRewards() : Array {
        if ( _rootData.data[ _vipReward ] == null ) {
            return new Array();
        }
        return _rootData.data[ _vipReward ];
    }
    public function get superVip() : int {
        return _rootData.data[ _superVip ];
    }
    public function get totalRecharge() : int {
        return _rootData.data[ _totalRecharge ];
    }
    public function get singleRecharge() : int {
        return _rootData.data[ _singleRecharge ];
    }

    public static const _vipLv : String = "vipLevel";
    public static const _vipExp : String = "vipExp";
    public static const _vipEverydayReward : String = "vipEverydayReward";
    public static const _vipGifts : String = "vipGift";
    public static const _vipReward : String = "vipReward";
    public static const _superVip : String = "superVip";
    public static const _singleRecharge : String = "singleRecharge";
    public static const _totalRecharge : String = "totalRecharge";
}
}
