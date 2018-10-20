//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/14.
//----------------------------------------------------------------------
package QFLib.Collision.common {

public interface IIteratable {
    function getIterator() : IIterator;
    function resetIterator( iterator : IIterator) : IIterator;
}
}
