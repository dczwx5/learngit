//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN at 2016/9/13
//------------------------------------------------------------------------------

package QFLib.Interface {

public interface IRecyclable {

    /**
     * do things before recycle into the pool
     */
    function recycle() : void;

    /**
     * do things after revive from the pool
     */
    function revive() : void;

    /**
     * dispose a recycled object
     */
    function disposeRecyclable() : void;
}
}
