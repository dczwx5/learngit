//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.bundle {

import kof.framework.CAppSystem;
import kof.framework.IPropertyChangeDescriptor;
import kof.framework.events.CEventPriority;

/**
 * CBunbldSystem implements from ISysteBundle and extends from CAppSystem.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CBundleSystem extends CAppSystem implements ISystemBundle {

    public static const ACTIVATED : String = "activated";
    public static const NOTIFICATION: String = "notification";
    public static const TAB : String = "tab";
    public static const TIP_HANDLER : String = "tip_handler";
    public static const ICON : String = "icon";
    public static const TIME_COUNTDOWN: String = "time_countdown";
    public static const GLOW_EFFECT : String = "glow_effect";
    public static const WELFARE_HALL_TYPE : String = 'welfare_hall_type';
    public static const RANK_TYPE : String = 'rank_type';
    public static const NOTICE_ARGS : String = 'notice_args';
    public static const ITEM_ID : String = "item_id";
    public static const MARQUEE_DATA : String = "marquee_data";
    public static const HERO_ID : String = "hero_id";
    public static const VISITOR_DATA : String = "visitorData";

    public static const TWEENING:String = "tweening";

    /** @private */
    private var m_bInitialized : Boolean;
    /** @private */
    private var m_objBoundID : *;

    /**
     * Creates a new CBundleSystem.
     */
    public function CBundleSystem( A_objBundleID : * = null ) {
        super();
        this.m_objBoundID = A_objBundleID;
    }

    override public function dispose() : void {
        super.dispose();

        // TODO: implements dispose for CBundleSystem.
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        if ( ret ) {
            ret = this.initialize();
        }

        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        if ( ret ) {
            const pSystemBundleCtx : ISystemBundleContext = this.ctx;
            if ( pSystemBundleCtx ) {
                pSystemBundleCtx.unregisterSystemBundle( this );
            }

            this.detachSystemBundleEventListeners();
        }

        return ret;
    }

    public function initialize() : Boolean {
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            const pSystemBundleCtx : ISystemBundleContext = this.ctx;
            if ( !pSystemBundleCtx )
                return false;

            pSystemBundleCtx.registerSystemBundle( this );

            this.attachSystemBundleEventListeners();
        }

        return m_bInitialized;
    }

    public function get bundleID() : * {
        return m_objBoundID;
    }

    [Inline]
    final public function get ctx() : ISystemBundleContext {
        return stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
    }

    use namespace SystemBundleScope;

    protected function attachSystemBundleEventListeners() : void {
        addEventListener( CSystemBundleEvent.BUNDLE_START, this_onSystemBundleStart, false, CEventPriority.DEFAULT, true );
        addEventListener( CSystemBundleEvent.BUNDLE_STOP, this_onSystemBundleStop, false, CEventPriority.DEFAULT, true );
        addEventListener( CSystemBundleEvent.USER_DATA, this_onSystemBundleUserData, false, CEventPriority.DEFAULT, true );
    }

    protected function detachSystemBundleEventListeners() : void {
        removeEventListener( CSystemBundleEvent.BUNDLE_START, this_onSystemBundleStart );
        removeEventListener( CSystemBundleEvent.BUNDLE_STOP, this_onSystemBundleStop );
        removeEventListener( CSystemBundleEvent.USER_DATA, this_onSystemBundleUserData );
    }

    SystemBundleScope function this_onSystemBundleStart( event : CSystemBundleEvent ) : void {
        this.enabled = true;
        this.onBundleStart( event.context || this.ctx );
    }

    protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        // NOOP.
    }

    SystemBundleScope function this_onSystemBundleStop( event : CSystemBundleEvent ) : void {
        this.enabled = false;
        this.onBundleStop( event.context || this.ctx );
    }

    protected function onBundleStop( pCtx : ISystemBundleContext ) : void {
        // NOOP.
    }

    SystemBundleScope function this_onSystemBundleUserData( event : CSystemBundleEvent ) : void {
        var pCtx:ISystemBundleContext = event.context || this.ctx;
        if (event.propertyData && event.propertyData.propertyName == ACTIVATED) {
            var isTweening:Boolean = pCtx.getUserData(this, TWEENING, false);
            if (isTweening) {
                pCtx.setUserDataOnly(this, ACTIVATED, event.propertyData.oldValue);
                return ;
            }
        }

        this.visitUserDataValidation( pCtx, event.propertyData );
    }

    protected function visitUserDataValidation( pCtx : ISystemBundleContext, pPropertyData : IPropertyChangeDescriptor ) : void {
        if ( pPropertyData ) {
            switch ( pPropertyData.propertyName ) {
                case CBundleSystem.ACTIVATED:
                    visitActivated( pCtx );
                    break;
                case CBundleSystem.TAB:
                    visitTab( pCtx );
                    break;
            }
        }

        this.visitOthers( pCtx );
    }

    protected function visitActivated( pCtx : ISystemBundleContext ) : void {
        if ( !pCtx ) return;

        var v_bCurrent : Boolean = pCtx.getUserData( this, ACTIVATED, false );
        this.onActivated( v_bCurrent ); // Makes value changed affaction.
    }

    protected function onActivated( a_bActivated : Boolean ) : void {
        // NOOP.
    }

    protected function setActivated( a_bActivated : Boolean ) : void {
        const pCtx : ISystemBundleContext = this.ctx;

        pCtx.setUserData( this, ACTIVATED, a_bActivated );
    }
    virtual protected function visitTab( pCtx : ISystemBundleContext ) : void {
    }
    protected function setTab( tab : int ) : void {
        const pCtx : ISystemBundleContext = this.ctx;

        pCtx.setUserData( this, TAB, tab );
    }
    virtual protected function visitOthers( pCtx : ISystemBundleContext ) : void {
        // NOOP.
    }

}
}

internal namespace SystemBundleScope = "http://system_bundle_scope";

// vim:ft=as3 ts=4 sw=4 expandtab tw=120
