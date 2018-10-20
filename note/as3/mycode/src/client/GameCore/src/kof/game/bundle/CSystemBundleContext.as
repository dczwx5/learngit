package kof.game.bundle {

import QFLib.Application.Component.CLifeCycleBeanEvent;
import QFLib.Application.Component.createLifeCycleListener;
import QFLib.Foundation.CMap;
import QFLib.Foundation.free;

import kof.framework.CAppSystem;

/**
 *
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSystemBundleContext extends CAppSystem implements ISystemBundleContext {

    static public const STATE_STOPPED : int = 0;
    static public const STATE_STARTED : int = 1;

    private var m_pBundleOrderedList : Vector.<ISystemBundle>;
    private var m_pBundles : CMap;
    private var m_bInitialized : Boolean;
    private var m_pBundlesIteratorDirty : Boolean;
    private var m_pBundlesIterator : CSystemBundleIterator;
    private var m_pUserData : CMap;
    private var m_pDefaultMatchingFilter : Function;

    /**
     * Creates a new CSystemBundleContext.
     */
    public function CSystemBundleContext() {
        super();
        m_bInitialized = false;
    }

    /**
     * @inheritDoc
     */
    override public function dispose() : void {
        super.dispose();

        if ( m_pBundleOrderedList )
            m_pBundleOrderedList.splice( 0, m_pBundleOrderedList.length );
        m_pBundleOrderedList = null;

        if ( m_pBundles ) {
            // Unregisters all ISystemBundle.
            var pBundleList : Array = m_pBundles.toArray();
            for each ( var pBundleState : CSystemBundleState in pBundleList ) {
                this.unregisterSystemBundle( pBundleState.bundle );
            }
            m_pBundles.clear();
        }
        m_pBundles = null;

        if ( m_pUserData ) {
            m_pUserData.clear();
        }
        m_pUserData = null;

        free( m_pBundlesIterator );
        m_pBundlesIterator = null;
    }

    /**
     * @inheritDoc
     */
    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.initialize();

        return ret;
    }

    protected virtual function initialize() : Boolean {
        if ( !m_bInitialized ) {
            m_bInitialized = true;
            // Make initialization.

            this.m_pBundleOrderedList = new <ISystemBundle>[];
            this.m_pBundles = new CMap();
            this.m_pBundlesIterator = new CSystemBundleIterator( this.m_pBundles );

            this.addBean( createLifeCycleListener( _onConfiguration, false ) );

            this.addBean( new CInternalSystemBundleConfiguration(), AUTO );

            this.m_pUserData = new CMap();
        }

        return m_bInitialized;
    }

    /**
     * @inheritDoc
     */
    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        return ret;
    }

    [Inline]
    final public function get defaultMatchingFilter() : Function { return m_pDefaultMatchingFilter; }
    final public function set defaultMatchingFilter( value : Function ) : void {
        m_pDefaultMatchingFilter = value;
    }

    [Inline]
    final public function get configuration() : ISystemBundleConfiguration {
        return this.getBean( ISystemBundleConfiguration ) as ISystemBundleConfiguration;
    }

    [Inline]
    final public function set configuration( value : ISystemBundleConfiguration ) : void {
        var pConfig : ISystemBundleConfiguration = this.configuration;
        if ( pConfig ) {
            this.removeBean( pConfig );
        }

        if ( value ) {
            this.addBean( pConfig, AUTO );
        }
    }

    final private function _onConfiguration( event : CLifeCycleBeanEvent ) : void {
        if ( !(event.child is ISystemBundleConfiguration) )
            return;

        var pConfig : ISystemBundleConfiguration = event.child as ISystemBundleConfiguration;

        if ( event.type == CLifeCycleBeanEvent.BEAN_ADDED ) {
            // load and parse configuration.
            this.parseConfig( pConfig );
        } else if ( event.type == CLifeCycleBeanEvent.BEAN_REMOVED ) {
            // configuration unloaded.
            this.unloadConfig( pConfig );
        }
    }

    protected function parseConfig( pConfig : ISystemBundleConfiguration ) : void {
        LOG.logTraceMsg( "Parsing SystemBundle configuration: " + pConfig );
    }

    protected function unloadConfig( pConfig : ISystemBundleConfiguration ) : void {
        LOG.logTraceMsg( "Unload SystemBundle configuration: " + pConfig );
    }

    /**
     * @inheritDoc
     */
    public function get systemBundleIterator() : Object {
//        if ( m_pBundlesIteratorDirty ) {
//            m_pBundlesIteratorDirty = false;
//            free( m_pBundlesIterator );
//            m_pBundlesIterator = new CSystemBundleIterator( m_pBundles );
//        }
//        return m_pBundlesIterator;
        return m_pBundleOrderedList;
    }

    /**
     * @inheritDoc
     */
    public function registerSystemBundle( pBundle : ISystemBundle ) : void {
        if ( !pBundle )
            return;

        var pState : CSystemBundleState = new CSystemBundleState();
        pState.bundle = pBundle;
        pState.value = STATE_STOPPED;

        m_pBundles.add( pBundle.bundleID, pState );
        m_pBundleOrderedList.push( pBundle );

        m_pBundlesIteratorDirty = true;

        var pRegEvent : CSystemBundleEvent = new CSystemBundleEvent( CSystemBundleEvent.BUNDLE_REGISTERED );
        pRegEvent.m_pBundle = pBundle;
        pRegEvent.m_pContext = this;
        dispatchEvent( pRegEvent );
    }

    /**
     * Unregisters the specific <code>ISystemBundle</code>.
     */
    public function unregisterSystemBundle( pBundle : ISystemBundle ) : void {
        if ( !pBundle )
            return;

        var pState : CSystemBundleState = m_pBundles.find( pBundle.bundleID );

        if ( !pState )
            return;

        if ( pState.isStarted )
            setSystemBundleState( pBundle, STATE_STOPPED );

        free( pState );

        m_pBundles.remove( pBundle.bundleID );
        m_pBundleOrderedList.splice( m_pBundleOrderedList.indexOf( pBundle ), 1 );

        m_pBundlesIteratorDirty = true;

        var pRegEvent : CSystemBundleEvent = new CSystemBundleEvent( CSystemBundleEvent.BUNDLE_UNREGISTERED );
        pRegEvent.m_pBundle = pBundle;
        pRegEvent.m_pContext = this;
        dispatchEvent( pRegEvent );
    }

    public function getSystemBundleState( pBundle : ISystemBundle ) : int {
        if ( !pBundle )
            return STATE_STOPPED;

        var pState : CSystemBundleState = m_pBundles.find( pBundle.bundleID );
        if ( pState )
            return pState.value;

        return STATE_STOPPED;
    }

    public function getChildSystemBundleState(pBundle:ISystemBundle, childSysTag:String):int
    {
        if ( !pBundle )
        {
            return STATE_STOPPED;
        }

        var pState : CSystemBundleState = m_pBundles.find( pBundle.bundleID );
        if ( pState )
        {
            return pState.getChildSystemState(childSysTag);
        }

        return STATE_STOPPED;
    }

    public function setSystemBundleState( pBundle : ISystemBundle, value : int ) : void {
        if ( !pBundle )
            return;

        var pState : CSystemBundleState = m_pBundles.find( pBundle.bundleID );
        if ( pState.value == value )
            return;
        pState.value = value;

        if ( pState.value == STATE_STARTED ) {
            _startBundle( pBundle );
        } else if ( pState.value == STATE_STOPPED ) {
            _stopBundle( pBundle );
        }
    }

    public function setChildSystemBundleState(pParentBundle : ISystemBundle, pChildBundle : ISystemBundle, childSysTag:String, value : int):void
    {
        if(pParentBundle == null)
        {
            return;
        }

        var pState : CSystemBundleState = m_pBundles.find( pParentBundle.bundleID );
        if(pState.getChildSystemState(childSysTag) == value)
        {
            return;
        }

        pState.setChildSystemState(childSysTag, value);
        this.setSystemBundleState( pChildBundle, value );

        if (value == STATE_STARTED )
        {
            _startChildBundle(pParentBundle, pChildBundle, childSysTag);
        }
        else if (value == STATE_STOPPED )
        {
            _stopChildBundle(pParentBundle, pChildBundle, childSysTag);
        }
    }

    protected function newBundleEvent( type : String, pBundle : ISystemBundle ) : CSystemBundleEvent {
        var vBundleEvent : CSystemBundleEvent = new CSystemBundleEvent( type );
        vBundleEvent.m_pBundle = pBundle;
        vBundleEvent.m_pContext = this;
        return vBundleEvent;
    }

    public function startBundle( pBundle : ISystemBundle ) : Boolean {
        if ( !pBundle ) return false;

        if ( getSystemBundleState( pBundle ) == STATE_STARTED )
                return false;

        setSystemBundleState( pBundle, STATE_STARTED );
        return true;
    }

    public function stopBundle( pBundle : ISystemBundle ) : Boolean {
        if ( !pBundle ) return false;

        if ( getSystemBundleState( pBundle ) == STATE_STOPPED )
                return false;

        setSystemBundleState( pBundle, STATE_STOPPED );
        return true;
    }

    protected function _startBundle( pBundle : ISystemBundle ) : void {
        if ( !pBundle )
            return;

        pBundle.dispatchEvent( newBundleEvent( CSystemBundleEvent.BUNDLE_START, pBundle ) );
        dispatchEvent( newBundleEvent( CSystemBundleEvent.BUNDLE_START, pBundle ) );
    }

    protected function _stopBundle( pBundle : ISystemBundle ) : void {
        if ( !pBundle )
            return;

        pBundle.dispatchEvent( newBundleEvent( CSystemBundleEvent.BUNDLE_STOP, pBundle ) );
        dispatchEvent( newBundleEvent( CSystemBundleEvent.BUNDLE_STOP, pBundle ) );
    }

    protected function _startChildBundle(pBundle:ISystemBundle, pChildBundle : ISystemBundle, childSysTag:String):void
    {
        if(pBundle == null)
        {
            return;
        }

        pBundle.dispatchEvent( new CChildSystemBundleEvent( CChildSystemBundleEvent.CHILD_BUNDLE_START, childSysTag ) );
        dispatchEvent( new CChildSystemBundleEvent( CChildSystemBundleEvent.CHILD_BUNDLE_START, childSysTag ) );

        _startBundle( pChildBundle );
    }

    protected function _stopChildBundle(pBundle:ISystemBundle, pChildBundle : ISystemBundle, childSysTag:String):void
    {
        if(pBundle == null)
        {
            return;
        }

        pBundle.dispatchEvent( new CChildSystemBundleEvent( CChildSystemBundleEvent.CHILD_BUNDLE_STOP, childSysTag ) );
        _stopBundle( pChildBundle );
    }

    public function getSystemBundle( idBundle : * ) : ISystemBundle {
        if ( null == idBundle || undefined == idBundle )
            return null;
        var pState : CSystemBundleState = m_pBundles.find( idBundle ) as CSystemBundleState;
        if ( pState ) {
            return pState.bundle;
        }
        return null;
    }

    /**
     * @inheritDoc
     */
    public function getUserData( pBundle : ISystemBundle, sProperty : String,
                                 vDefault : * = undefined ) : * {
        if ( !pBundle )
            return vDefault;

        var pBundleData : Object = m_pUserData.find( pBundle );
        if ( null == pBundleData ) {
            m_pUserData.add( pBundle, ( pBundleData = new CMap ) );
        }

        var pValue : * = pBundleData.find( sProperty );
        if ( null == pValue || undefined == pValue )
            return vDefault;
        return pValue;
    }

    public function setUserDataOnly( pBundle : ISystemBundle, sProperty : String,
                                 pValue : * ) : void {
        if ( !pBundle )
            return ;

        var pBundleData : Object = m_pUserData.find( pBundle );
        if ( null == pBundleData ) {
            m_pUserData.add( pBundle, ( pBundleData = new CMap ) );
        }

        var oldValue : * = pBundleData.find( sProperty );
        if ( null != oldValue ) {
            pBundleData[ sProperty ] = pValue;
        } else {
            pBundleData.add( sProperty, pValue );
        }
    }

    public function setUserData( pBundle : ISystemBundle, sProperty : String,
                                 pValue : *, matchingFilter : Function = null ) : void {

        if ( pBundle ) {
            var pBundleData : CMap = m_pUserData.find( pBundle ) as CMap;
            if ( null == pBundleData ) {
                m_pUserData.add( pBundle, ( pBundleData = new CMap ) );
            }

            var oldValue : * = pBundleData.find( sProperty );
            matchingFilter = matchingFilter || this.defaultMatchingFilter;

            if ( matchingFilter ) {
                if ( true == Boolean( matchingFilter( this, pBundle, sProperty, oldValue, pValue ) ) ) // match by custom filter.
                    return;
            }
        }

        var vPropertyData : CUserDataChangeDescriptor = new CUserDataChangeDescriptor();
        vPropertyData.m_sPropertyName = sProperty;
        vPropertyData.m_theOldValue = oldValue;
        vPropertyData.m_theNewValue = pValue;

        var pContextEvent : CSystemBundleEvent;

        // as pre-processing validation.
        pContextEvent = new CSystemBundleEvent( CSystemBundleEvent.USER_DATA, false, true );
        pContextEvent.m_pContext = this;
        pContextEvent.m_pBundle = pBundle;
        pContextEvent.m_pPropertyData = vPropertyData;

        var bHandled : Boolean = this.dispatchEvent( pContextEvent );
        if ( !bHandled && pContextEvent.isDefaultPrevented() )
            return;

        if ( pBundle ) {
            if ( null != oldValue ) {
                pBundleData[ sProperty ] = pValue;
            } else {
                pBundleData.add( sProperty, pValue );
            }
        }

        bHandled = false;

        if ( pBundle ) {

            var pEvent : CSystemBundleEvent = new CSystemBundleEvent( CSystemBundleEvent.USER_DATA );
            pEvent.m_pContext = this;
            pEvent.m_pBundle = pBundle;
            pEvent.m_pPropertyData = vPropertyData;

            bHandled = pBundle.dispatchEvent( pEvent );

            pEvent.dispose();
        }

        if ( pContextEvent.m_pEndCallbacks ) {
            const v_pFuncs : Vector.<Function> = pContextEvent.m_pEndCallbacks.slice();
            for each ( var func : Function in v_pFuncs ) {
                if ( null == func )
                    continue;
                func( this, pBundle, bHandled );
            }
        }

        pContextEvent.dispose();
    }

} // class CSystemBundleContext
} // package kof.game.bundle

import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;

import flash.events.EventDispatcher;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import kof.framework.IPropertyChangeDescriptor;

import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleConfiguration;
import kof.game.bundle.ISystemBundleState;

/**
 * State of ISystemBundle.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
class CSystemBundleState extends EventDispatcher implements ISystemBundleState, IDisposable {

    public var bundle : ISystemBundle;
    private var _value : int; // state value.
    private var _childBundleState:CMap;

    public function CSystemBundleState() {
        super();
    }

    public function dispose() : void {
        this.bundle = null;
    }

    public function get value() : int {
        return _value;
    }

    public function set value( value : int ) : void {
        this._value = value;
    }

    public function get isStopped() : Boolean {
        return this.value == CSystemBundleContext.STATE_STOPPED;
    }

    public function get isStarted() : Boolean {
        return this.value == CSystemBundleContext.STATE_STARTED;
    }

    public function getChildSystemState(childSysTag:String):int
    {
        if(_childBundleState == null)
        {
            return CSystemBundleContext.STATE_STOPPED;
        }

        return _childBundleState[childSysTag];
    }

    public function setChildSystemState(childSysTag:String, value:int):void
    {
        if(_childBundleState == null)
        {
            _childBundleState = new CMap();
        }

        _childBundleState.add(childSysTag, value, true);
    }

} // class CSystemBundleState

/**
 * Iterator specific for ISystemBundle in CSystemBundleContext's bundles.
 */
final class CSystemBundleIterator extends Proxy implements IDisposable {

    /**
     * @private
     * Reference from <code>CSystemBundleContext</code>.
     */
    private var m_pBundlesRef : CMap;
    private var m_pBundles : Vector.<Object>;

    /**
     * Creates a new CSystemBundleIterator.
     */
    function CSystemBundleIterator( bundles : CMap ) {
        super();
        this.m_pBundlesRef = bundles;
        this.m_pBundles = this.m_pBundlesRef.toVector();
    }

    /**
     * @inheritDoc
     */
    public function dispose() : void {
        this.m_pBundlesRef = null;
    }

    /**
     * @inheritDoc
     */
    final override flash_proxy function nextNameIndex( index : int ) : int {
        if ( index >= m_pBundlesRef.length )
            return 0;
        return index + 1;
    }

    /**
     * @inheritDoc
     */
    final override flash_proxy function nextName( index : int ) : String {
        if ( index >= m_pBundlesRef.length )
            return null;
        return index.toString();
    }

    /**
     * @inheritDoc
     */
    final override flash_proxy function nextValue( index : int ) : * {
        if ( this.m_pBundlesRef.length != this.m_pBundles.length )
            this.m_pBundles = this.m_pBundlesRef.toVector();

        var obj : CSystemBundleState = this.m_pBundles[ index - 1 ] as CSystemBundleState;
        return obj ? obj.bundle : null;
    }

} // class CSystemBundleIterator

/**
 * @author Jeremy (jeremy@qifun.com)
 */
class CInternalSystemBundleConfiguration implements ISystemBundleConfiguration {

    /**
     * Creates a new CInternalSystemBundleConfiguration.
     */
    public function CInternalSystemBundleConfiguration() {
        super();
    }

    public function dispose() : void {
    }

} // class CInternalSystemBundleConfiguration

/**
 *  @author Jeremy (jeremy@qifun.com)
 */
class CUserDataChangeDescriptor implements IPropertyChangeDescriptor {

    public var m_sPropertyName : String;
    public var m_theOldValue : *;
    public var m_theNewValue : *;

    public function get propertyName() : String {
        return m_sPropertyName;
    }

    public function get oldValue() : * {
        return m_theOldValue;
    }

    public function get newValue() : * {
        return m_theNewValue;
    }

} // class CUserDataChangeDescriptor
