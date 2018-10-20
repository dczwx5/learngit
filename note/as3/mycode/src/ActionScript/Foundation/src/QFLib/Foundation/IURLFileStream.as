package QFLib.Foundation {

import QFLib.Interface.IDisposable;

import flash.events.IEventDispatcher;
import flash.net.URLRequest;
import flash.utils.IDataInput;

/**
 * Dispatched when data has loaded successfully.
 */
[Event(name="complete", type="flash.events.Event")]
/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IURLFileStream extends IEventDispatcher, IDataInput, IDisposable {

    /**
     * Indictes whether this IURLFileStream object is currently connected.
     */
    function get connected() : Boolean;

    /**
     * Immediately closes the stream and cancels the download operations.
     */
    function close() : void;

    /**
     * Begins downloading the URL specified in the request parameter.
     */
    function load( request : URLRequest ) : void;

    function get position() : uint;
    function set position( value : uint ) : void;

    /** The actually target which delegates to. */
    function get target() : Object;

}
}

// vi:ft=as3 tw=120 ts=4 sw=4 expandtab
