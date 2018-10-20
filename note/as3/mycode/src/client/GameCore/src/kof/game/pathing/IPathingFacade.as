//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/23.
 */
package kof.game.pathing {

public interface IPathingFacade {
    //
    function findPath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array ;
    function findReversePath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array ;

}
}
