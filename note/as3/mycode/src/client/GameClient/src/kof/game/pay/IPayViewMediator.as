//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.pay {

/**
 * 充值界面功能调停接口
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IPayViewMediator {

    /**
     * 开通平台VIP
     */
    function requestPlatformVIP( type : int ) : void;

    /**
     * 购买商品
     */
    function buyProduct( theProductItem : Object ) : void;

    /**
     * 查看VIP特权
     */
    function requestVIP() : void;

}
}
