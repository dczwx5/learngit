//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/28.
 */
package kof.game.platform.view {

import flash.display.DisplayObject;

public interface IPlatformGetSignatureView {

    function get viewClass() : Array;
    function createView() : DisplayObject ;

}
}
