package QFLib.Application.Component {

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CContainerLifeCycle extends CAbstractLifeCycle implements IContainer {

    public static const AUTO : int = -1;
    public static const DEFAULT : int = 0;
    public static const MANAGED : int = 1;
    public static const UNMANAGED : int = 2;

    private var _beans : Vector.<CLifeCycleBean>;
    private var _listeners : Vector.<ILifeCycleListener>;
    private var _doStarted : Boolean;
    private var _depth : int;

    /**
     * Constructor
     */
    public function CContainerLifeCycle() {
        super();
        _doStarted = false;
        _beans = new Vector.<CLifeCycleBean>();
    }

    [Inline]
    final public function get depth() : int {
        return _depth;
    }

    [Inline]
    final protected function get beanIterator() : Object {
        return new CLifeCycleIterator( _beans );
    }

    override protected function doStart() : Boolean {
        _doStarted = true;

        // start our managed and auto beans
        for each ( var b : CLifeCycleBean in _beans ) {
            if ( b.object is ILifeCycle ) {
                var l : ILifeCycle = b.object as ILifeCycle;
                switch ( b.managed ) {
                    case MANAGED: {
                        if ( !l.isRunning ) {
                            startLifeCycle( l );
                        }
                        break;
                    }
                    case AUTO: {
                        if ( l.isRunning ) {
                            this.unmanage( b );
                        }
                        else {
                            this.manage( b );
                            startLifeCycle( l );
                        }
                        break;
                    }
                }
            }
        }

        return super.doStart();
    }

    override protected function doStop() : Boolean {
        _doStarted = false;
        var ret : Boolean = super.doStop();

        var reverse : Vector.<CLifeCycleBean> = _beans.reverse();
        for each ( var rb : CLifeCycleBean in reverse ) {
            if ( rb.managed == MANAGED && rb.object is ILifeCycle ) {
                var l : ILifeCycle = rb.object as ILifeCycle;
                stopLifeCycle( l );
            }
        }

        return ret;
    }

    public function contains( o : Object ) : Boolean {
        for each ( var b : CLifeCycleBean in _beans ) {
            if ( b && b.object == o ) {
                return true;
            }
        }
        return false;
    }

    public function addBean( o : *, managed : int = AUTO ) : Boolean {
        if ( !o )
            return false;

        if ( contains( o ) )
            return false;

        var b : CLifeCycleBean = new CLifeCycleBean( o );
        if ( o is ILifeCycleListener ) {
            attachBeansEventListener( o as ILifeCycleListener );
        }

        _beans.push( b );

        if ( o is CContainerLifeCycle )
            CContainerLifeCycle( o )._depth = this._depth + 1;

        // tell existing listeners about the new bean.
        if ( _listeners ) {
            for each ( var l : ILifeCycleListener in _listeners ) {
                if ( l ) {
                    l.dispatchEvent( new CLifeCycleBeanEvent( CLifeCycleBeanEvent.BEAN_ADDED, this, o ) );
                }
            }
        }

        try {
            switch ( managed ) {
                case UNMANAGED:
                    this.unmanage( b );
                    break;
                case MANAGED:
                    this.manage( b );
                    if ( isStarting && _doStarted ) {
                        var lc : ILifeCycle = o as ILifeCycle;
                        if ( !lc.isRunning )
                            startLifeCycle( lc );
                    }
                    break;
                case AUTO:
                    if ( o is ILifeCycle ) {
                        lc = o as ILifeCycle;
                        if ( isStarting ) {
                            if ( lc.isRunning ) {
                                this.unmanage( b );
                            }
                            else if ( _doStarted ) {
                                this.manage( b );
                                startLifeCycle( lc );
                            }
                            else {
                                b.managed = AUTO;
                            }
                        }
                        else if ( isStarted ) {
                            this.unmanage( b );
                        }
                        else {
                            b.managed = AUTO;
                        }
                    }
                    else {
                        b.managed = DEFAULT;
                    }
                    break;
                case DEFAULT:
                    b.managed = DEFAULT;
                    break;
            }
        }
        catch ( e : Error ) {
            LOG.logErrorMsg( e.message + "\n" + e.getStackTrace() );
            throw e;
        }

        // DEBUG trace.
        LOG.logTraceMsg( this.toString() + " added " + b.toString() );

        return true;
    }

    public function updateBean( oldBean : *, newBean : *, managed : int = AUTO ) : void {
        if ( newBean != oldBean ) {
            if ( oldBean )
                this.removeBean( oldBean );
            if ( newBean )
                this.addBean( newBean, managed );
        }
    }

    private function attachBeansEventListener( listener : ILifeCycleListener ) : void {
        if ( !listener )
            return;

        _listeners = _listeners || new Vector.<ILifeCycleListener>();

        if ( _listeners.indexOf( listener ) != -1 )
            return;

        _listeners.push( listener );
        // tell it about exiting beans

        for each ( var b : CLifeCycleBean in _beans ) {
            listener.dispatchEvent( new CLifeCycleBeanEvent( CLifeCycleBeanEvent.BEAN_ADDED, this, b.object ) );

            // handle inheritance.
            if ( listener.isInherited && b.isManaged && b.object is IContainer ) {
                if ( b.object is CContainerLifeCycle ) {
                    (b.object as CContainerLifeCycle).addBean( listener, UNMANAGED );
                }
                else {
                    (b.object as IContainer).addBean( listener );
                }
            }
        }
    }

    private function detachBeansEventListener( listener : ILifeCycleListener ) : void {
        if ( !listener || !_listeners || _listeners.length == 0 )
            return;

        var index : int = _listeners.indexOf( listener );
        if ( index == -1 )
            return;
        _listeners.splice( index, 1 );

        // remove exiting beans
        for each ( var b : CLifeCycleBean in _beans ) {
            listener.dispatchEvent( new CLifeCycleBeanEvent( CLifeCycleBeanEvent.BEAN_REMOVED, this, b.object ) );

            if ( listener.isInherited && b.isManaged && b.object is IContainer ) {
                (b.object as IContainer).removeBean( listener );
            }
        }
    }

    public function removeBean( o : * ) : Boolean {
        if ( !o )
            return false;

        var bean : CLifeCycleBean = _getBean( o );
        return bean && this._removeBean( bean );
    }

    private function _removeBean( b : CLifeCycleBean ) : Boolean {
        if ( !b )
            return false;

        var index : int = _beans.indexOf( b );
        if ( index == -1 )
            return false;

        _beans.splice( index, 1 ); // Removed from _beans first.
        var wasManaged : Boolean = b.isManaged;
        this.unmanage( b );
        for each ( var l : ILifeCycleListener in _listeners ) {
            l.dispatchEvent( new CLifeCycleBeanEvent( CLifeCycleBeanEvent.BEAN_REMOVED, this, b.object ) );
        }

        if ( b.object is ILifeCycleListener ) {
            detachBeansEventListener( b.object as ILifeCycleListener );
        }

        // Stop the manage beans.
        if ( wasManaged && b.object is ILifeCycle ) {
            try {
                stopLifeCycle( b.object as ILifeCycle );
            }
            catch ( e : Error ) {
                LOG.logErrorMsg( "Error caught at stopping LifeCycle bean: " + e.message );
                throw e;
            }
        }

        LOG.logTraceMsg( this.toString() + " removed " + b.toString() );

        return true;
    }

    private function _getBean( o : * ) : CLifeCycleBean {
        // Searching _beans.
        for each ( var b : CLifeCycleBean in _beans ) {
            if ( !b )
                continue;

            if ( o is Class ) {
                if ( b.object is o )
                    return b;
            } else {
                if ( b.object == o )
                    return b;
            }
        }

        if ( o is CLifeCycleBean )
            return o as CLifeCycleBean;

        return null;
    }

    public function getBean( clz : Class ) : * {
        if ( _beans ) {
            for each ( var o : CLifeCycleBean in _beans ) {
                if ( o.object is clz )
                    return o.object;
            }
        }
        return null;
    }

    public function getBeans( filter : Function = null ) : Vector.<Object> {
        var result : Vector.<Object> = new <Object>[];
        if ( _beans ) {
            var o : CLifeCycleBean;
            if ( null == filter ) {
                //noinspection JSDuplicatedDeclaration
                for each( o in _beans ) {
                    result.push( o.object );
                }
            }
            else if ( _beans.length > 0 && filter ) {
                //noinspection JSDuplicatedDeclaration
                for each ( o in _beans ) {
                    if ( o && o.object && filter.call( null, o.object ) )
                        result.push( o.object );
                }
            }
        }
        return result;
    }

    private function unmanage( b : * ) : void {
        if ( b is CLifeCycleBean ) {
            if ( b.managed != UNMANAGED ) {
                if ( b.managed == MANAGED && b.object is IContainer ) {
                    for each ( var listener : ILifeCycleListener in _listeners ) {
                        if ( listener.isInherited )
                            (b.object as IContainer).removeBean( listener );
                    }
                }
                b.managed = UNMANAGED;
            }
        }
        else if ( b ) {
            for each ( var bean : CLifeCycleBean in _beans ) {
                if ( bean && bean.object == b ) {
                    unmanage( bean );
                    return;
                }
            }

            throw "Unknown bean " + b.toString();
        }
    }

    private function manage( b : * ) : void {
        if ( b is CLifeCycleBean ) {
            if ( b.managed != MANAGED ) {
                b.managed = MANAGED;
                if ( b.object is IContainer ) {
                    for each ( var listener : ILifeCycleListener in _listeners ) {
                        if ( listener.isInherited ) {
                            if ( b.object is CContainerLifeCycle ) {
                                (b.object as CContainerLifeCycle).addBean( listener, UNMANAGED );
                            }
                            else {
                                (b.object as IContainer).addBean( listener );
                            }
                        }
                    }
                }
            }
        }
        else if ( b ) {
            for each ( var bean : CLifeCycleBean in _beans ) {
                // Figure out bean containing the object.
                if ( bean && bean.object == b ) {
                    manage( bean );
                    return;
                }
            }
            throw "Unknown bean " + b.toString();
        }

        // illegal statements.
    }

    private static function startLifeCycle( lc : ILifeCycle ) : void {
        if ( lc )
            lc.start();
    }

    private static function stopLifeCycle( lc : ILifeCycle ) : void {
        if ( lc )
            lc.stop();
    }

    public override function dispose() : void {
        super.dispose();

        var reverse : Vector.<CLifeCycleBean> = _beans.reverse();
        for each ( var b : CLifeCycleBean in reverse ) {
            b.dispose();
        }

        _beans.splice( 0, _beans.length ); // erase all.
    }

} // class CContainerLifeCycle
}

import QFLib.Application.Component.CContainerLifeCycle;
import QFLib.Foundation.free;
import QFLib.Interface.IDisposable;
import QFLib.Memory.CSmartObject;

import flash.utils.Proxy;
import flash.utils.flash_proxy;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
final class CLifeCycleBean extends CSmartObject implements IDisposable {

    public static function getManagedValueStr( managed : int ) : String {
        switch ( managed ) {
            case CContainerLifeCycle.AUTO:
                return "AUTO";
            case CContainerLifeCycle.DEFAULT:
                return "DEFAULT";
            case CContainerLifeCycle.MANAGED:
                return "MANAGED";
            case CContainerLifeCycle.UNMANAGED:
                return "UNMANAGED";
            default:
                return "UNKNOWN";
        }
    }

    public var object : Object;
    public var managed : int;

    /**
     * Constructor
     */
    public function CLifeCycleBean( obj : Object ) {
        super();
        this.object = obj;
    }

    override public function dispose() : void {
        super.dispose();

        if ( object && ( managed == CContainerLifeCycle.MANAGED || managed == CContainerLifeCycle.DEFAULT ) ) {
            free( object );
        }
    }

    public function get isManaged() : Boolean {
        return managed == CContainerLifeCycle.MANAGED;
    }

    public function toString() : String {
        return "{ " + (object ? object.toString() : "null") + ", " + getManagedValueStr( managed ) + " }";
    }

} // class CLifeCycleBean

/**
 * Iterator specific for CLifeCycleBean's value.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
final class CLifeCycleIterator extends Proxy {

    /** Default empty vector.*/
    private static const EMPTY_VEC : Vector.<CLifeCycleBean> = new <CLifeCycleBean>[];

    /** @private */
    private var m_listBeans : Vector.<CLifeCycleBean>;

    function CLifeCycleIterator( listBeans : Vector.<CLifeCycleBean> ) {
        m_listBeans = listBeans;
        if ( !m_listBeans )
            m_listBeans = EMPTY_VEC;
    }

    final override flash_proxy function nextNameIndex( index : int ) : int {
        if ( index >= m_listBeans.length )
            return 0;
        return index + 1;
    }

    final override flash_proxy function nextName( index : int ) : String {
        if ( index >= m_listBeans.length )
            return null;
        return index.toString();
    }

    final override flash_proxy function nextValue( index : int ) : * {
        var obj : CLifeCycleBean = m_listBeans[ index - 1 ];
        if ( obj && obj.object ) {
            return obj;
        }
        return null;
    }

} // class CLifeCycleIterator
