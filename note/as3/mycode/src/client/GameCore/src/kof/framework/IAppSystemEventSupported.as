/**
 * Created by user on 2016/10/10.
 */
package kof.framework {

import flash.events.IEventDispatcher;

public interface IAppSystemEventSupported {

    function get eventDelegate() : IEventDispatcher;

}
}
