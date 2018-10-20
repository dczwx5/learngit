//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/28.
 */
package kof.game.platform.view {

import kof.game.platform.data.CPlatformBaseData;

import morn.core.components.Box;

public interface IPlatformSignatureRender {

    function renderSignature(signatureBox:Box, platformData:CPlatformBaseData, vipLevel:int) : void ;
    function get autoSortItem() : Boolean;

}
}
