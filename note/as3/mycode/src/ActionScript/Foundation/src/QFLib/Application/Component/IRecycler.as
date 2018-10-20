//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Application.Component {

/**
 * 接口用于表示可以回收的操作
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IRecycler {

    /**
     * 分配当前空闲对象
     */
    function allocate():Object;

    /**
     * 回收指定对象
     */
    function recycle(obj:Object):void;

}
}
