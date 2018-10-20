//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IAppTimer {

    /**
     * Elapsed time.
     */
    function get time():Number;

    /**
     * Frame per seconds.
     */
    function get frameRate():Number;

    /**
     * Time in seconds.
     */
    function get timeInSeconds():Number;

    /**
     * Time per frame.
     */
    function get timePerFrame():Number;

    /**
     * 精确度
     */
    function get resolution():Number;

    /**
     * 帧计数
     */
    function get frameCounter() : uint;

    /**
     * Update the ticking information.
     */
    function update():void;

    /**
     * Reset all.
     */
    function reset():void;

}
}
