//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.validation {

import QFLib.Interface.IDisposable;

/**
 * 功能开启条件验证
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ISwitchingValidation extends IDisposable {

    function evaluate( ... args ) : Boolean;

    function getLocaleDesc( configData : Object ) : String;

}
}
