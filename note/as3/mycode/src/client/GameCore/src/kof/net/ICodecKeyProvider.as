//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.net {

import QFLib.Interface.IDisposable;

import flash.utils.ByteArray;

/**
 * 用于加解密提供动态或静态的私有秘钥
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ICodecKeyProvider extends IDisposable {

    function get key() : String;

    function get bytes() : ByteArray;

}
}
