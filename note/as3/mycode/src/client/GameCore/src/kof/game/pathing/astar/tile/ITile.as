//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/20.
 */
package kof.game.pathing.astar.tile {

public interface ITile {
    [Inline]
    function get neighborList() : Array;
    function resetWeight() : void ;
    function reCalcWeight(deltaX:int, deltaY:int) : void ;
}
}
