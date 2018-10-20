package kof.game.perfs {

import QFLib.Interface.IUpdatable;

import kof.SYSTEM_TAG;
import kof.framework.CAppStage;
import kof.framework.CAppSystem;
import kof.framework.IAppTimer;
import kof.framework.events.CEventPriority;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.util.CAssertUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CGamePerfMonitor extends CAppSystem implements IUpdatable, IGamePerfSender {

    public static const COUNT_DOWN_MAXIMUM : int = 3;
    public static const TYPE_OF_LEVEL : int = 1;
    public static const TYPE_OF_SCENARIO : int = 2;

    private var m_fLastSnapshotTimeInMS : Number;
    private var m_fSnapshotIntervalInMS : Number = 1000; // 1 Second.

    private var m_fSyncLastTimeInMS : Number;
     private var m_fSyncIntervalInMS : Number = 60000; // 60 second.
//    private var m_fSyncIntervalInMS : Number = 15000; // 15 second for testing.

    /** @private */
    private var m_iErrTimeElapsed : Number = 0;

    /** @private */
    private var m_iTypeOfStack : Vector.<int>;

    /** @private */
    private var m_bPerfEnabled : Boolean;

    /** @private */
//    private var m_fFpsThreshold : Number = 30.0;
    private var m_fFpsThreshold : Number = 25.0;
    private var m_iFpsCountDown : int = COUNT_DOWN_MAXIMUM;
    private var m_bFpsThresholdEnabled : Boolean = false;

    /** @private */
    private var m_vecActivateBundles : Vector.<String>;

    /** Creates a new CGamePerfMonitor */
    public function CGamePerfMonitor() {
        super();

        m_iTypeOfStack = new <int>[];

        m_vecActivateBundles = new <String>[];
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_iTypeOfStack ) m_iTypeOfStack.length = 0;
        m_iTypeOfStack = null;

        if ( m_vecActivateBundles ) m_vecActivateBundles.length = 0;
        m_vecActivateBundles = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        ret = ret && this.addBean( new CGamePerfRecord() );
        ret = ret && this.addBean( new CGamePerfSender() );

        return ret;
    }

    override protected function onShutdown() : Boolean {
        return super.onShutdown();
    }

    override protected function enterStage( pStage : CAppStage ) : void {
        super.enterStage( pStage );

        var pInstanceSystem : CInstanceSystem = pStage.getSystem( CInstanceSystem ) as CInstanceSystem;
        if ( pInstanceSystem ) {
            pInstanceSystem.addEventListener( CInstanceEvent.LEVEL_ENTER, _instanceSystem_onLevelReadyEventHandler, false, CEventPriority.DEFAULT, true );
            pInstanceSystem.addEventListener( CInstanceEvent.LEVEL_EXIT, _instanceSystem_onLevelExitEventHandler, false, CEventPriority.DEFAULT, true );
            pInstanceSystem.addEventListener( CInstanceEvent.SCENARIO_START, _instanceSystem_onScenarioStartEventHandler, false, CEventPriority.DEFAULT, true );
            pInstanceSystem.addEventListener( CInstanceEvent.SCENARIO_END, _instanceSystem_onScenarioEndEventHandler, false, CEventPriority.DEFAULT, true );
        }

        var pBundleCtx : ISystemBundleContext = pStage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pBundleCtx )
            pBundleCtx.addEventListener( CSystemBundleEvent.USER_DATA, _bundleCtx_onUserDataEventHandler, false, CEventPriority.DEFAULT, true );
    }

    override protected function exitStage( pStage : CAppStage ) : void {
        super.exitStage( pStage );

        var pInstanceSystem : CInstanceSystem = pStage.getSystem( CInstanceSystem ) as CInstanceSystem;
        if ( pInstanceSystem ) {
            pInstanceSystem.removeEventListener( CInstanceEvent.LEVEL_ENTER, _instanceSystem_onLevelReadyEventHandler );
            pInstanceSystem.removeEventListener( CInstanceEvent.LEVEL_EXIT, _instanceSystem_onLevelExitEventHandler );
            pInstanceSystem.removeEventListener( CInstanceEvent.SCENARIO_START, _instanceSystem_onScenarioStartEventHandler );
            pInstanceSystem.removeEventListener( CInstanceEvent.SCENARIO_END, _instanceSystem_onScenarioEndEventHandler );
        }

        var pBundleCtx : ISystemBundleContext = pStage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pBundleCtx )
            pBundleCtx.removeEventListener( CSystemBundleEvent.USER_DATA, _bundleCtx_onUserDataEventHandler );
    }

    public function get perfEnabled() : Boolean {
        return m_bPerfEnabled;
    }

    public function set perfEnabled( value : Boolean ) : void {
        if ( value == m_bPerfEnabled )
            return;
        m_bPerfEnabled = value;
    }

    /** @private */
    private function _bundleCtx_onUserDataEventHandler( event : CSystemBundleEvent ) : void {
        if ( event.propertyData && event.propertyData.propertyName == CBundleSystem.ACTIVATED ) {
            var sTag : String = SYSTEM_TAG( event.bundle.bundleID );
            var bActivated : Boolean = event.propertyData.oldValue != event.propertyData.newValue && event.propertyData.newValue == true;
            if ( bActivated ) {
                if ( m_vecActivateBundles.indexOf( sTag ) == -1 )
                    m_vecActivateBundles.push( sTag );
            } else {
                var idx : int = m_vecActivateBundles.indexOf( sTag );
                if ( idx != -1 )
                    m_vecActivateBundles.splice( idx, 1 );
            }
        }
    }

    private function _instanceSystem_onLevelReadyEventHandler( event : CInstanceEvent ) : void {
        // level ready, a record start point.
        m_iTypeOfStack.push( TYPE_OF_LEVEL );

        this.perfEnabled = m_iTypeOfStack.length > 0;
        dispatchEvent( new CGamePerfEvent( CGamePerfEvent.EVENT_TRIGGERED ) );

        var pRecord : CGamePerfRecord = this.getHandler( CGamePerfRecord ) as CGamePerfRecord;
        if ( pRecord )
            pRecord.clear();

        m_vecActivateBundles.length = 0;
    }

    private function _instanceSystem_onLevelExitEventHandler( event : CInstanceEvent ) : void {
        // level exit, should exit scenario and level both.
        m_iTypeOfStack.length = 0;

        this.perfEnabled = m_iTypeOfStack.length > 0;
        this.send( true );

        dispatchEvent( new CGamePerfEvent( CGamePerfEvent.EVENT_TRIGGERED ) );

        var pRecord : CGamePerfRecord = this.getHandler( CGamePerfRecord ) as CGamePerfRecord;
        if ( pRecord )
            pRecord.clear();

        m_vecActivateBundles.length = 0;
    }

    private function _instanceSystem_onScenarioStartEventHandler( event : CInstanceEvent ) : void {
        // scenario started.
        m_iTypeOfStack.push( TYPE_OF_SCENARIO );

        this.perfEnabled = m_iTypeOfStack.length > 0;

        dispatchEvent( new CGamePerfEvent( CGamePerfEvent.EVENT_TRIGGERED ) );

        var pRecord : CGamePerfRecord = this.getHandler( CGamePerfRecord ) as CGamePerfRecord;
        if ( pRecord )
            pRecord.clear();
    }

    private function _instanceSystem_onScenarioEndEventHandler( event : CInstanceEvent ) : void {
        // scenario end.
        CAssertUtils.assertTrue( m_iTypeOfStack.length );
        CAssertUtils.assertTrue( m_iTypeOfStack[ m_iTypeOfStack.length - 1 ] == TYPE_OF_SCENARIO );

        m_iTypeOfStack.length = m_iTypeOfStack.length - 1;

        this.perfEnabled = m_iTypeOfStack.length > 0;
        this.send( true );

        dispatchEvent( new CGamePerfEvent( CGamePerfEvent.EVENT_TRIGGERED ) );

        var pRecord : CGamePerfRecord = this.getHandler( CGamePerfRecord ) as CGamePerfRecord;
        if ( pRecord )
            pRecord.clear();
    }

    public function update( fDelta : Number ) : void {
        if ( !this.perfEnabled )
            return;

        // FPS threshold detection.
        var pTimer : IAppTimer = stage.timer as IAppTimer;
        if ( !pTimer )
            return;

        var utmp : Number = new Date().valueOf();

        if ( isNaN( m_fSyncLastTimeInMS ) )
            m_fSyncLastTimeInMS = utmp;

        var pRecord : CGamePerfRecord = null;

        if ( utmp - m_fSyncLastTimeInMS >= m_fSyncIntervalInMS ) {
            // hit.
            m_fSyncLastTimeInMS = utmp;

            pRecord = pRecord || getBean( CGamePerfRecord ) as CGamePerfRecord;

            if ( pRecord && !pRecord.empty ) {
                this.send();
                pRecord.clear();
            }
        }

        // We use an unix timestamp instead of the CPU time to detect a
        // heartbeat tick.
        if ( isNaN( m_fLastSnapshotTimeInMS ) ) {
            m_fLastSnapshotTimeInMS = utmp;
        }

        if ( utmp - m_fLastSnapshotTimeInMS >= m_fSnapshotIntervalInMS ) {
            // hit.
            m_fLastSnapshotTimeInMS = utmp;

            if ( pTimer.frameRate >= m_fFpsThreshold ) {
                m_iFpsCountDown = Math.min( COUNT_DOWN_MAXIMUM, m_iFpsCountDown + 1 );
            } else {
                m_iFpsCountDown = Math.max( 0, m_iFpsCountDown - 1 );
            }

            var bThreshold : Boolean = this.m_bFpsThresholdEnabled;

            if ( m_iFpsCountDown == 0 ) {
                bThreshold = true;
            } else if ( m_iFpsCountDown == COUNT_DOWN_MAXIMUM ) {
                bThreshold = false;
            }

            if ( bThreshold != this.m_bFpsThresholdEnabled ) {
                this.m_bFpsThresholdEnabled = bThreshold;
                // threshold triggered, opening or closing.
            }

            if ( !this.m_bFpsThresholdEnabled )
                return;

            m_iErrTimeElapsed += m_fSnapshotIntervalInMS;

            pRecord = pRecord || getBean( CGamePerfRecord ) as CGamePerfRecord;
            if ( pRecord ) {
                pRecord.snapshot();

                var vEvent : CGamePerfEvent = new CGamePerfEvent( CGamePerfEvent.EVENT_SNAPSHOT );
                vEvent.record = pRecord;
                dispatchEvent( vEvent );
            }
        }
    }

    public function send( bEnd : Boolean = false ) : void {
        var pRecord : CGamePerfRecord = this.getHandler( CGamePerfRecord ) as CGamePerfRecord;

        if ( pRecord.empty )
            return;

        var vEvent : CGamePerfEvent = new CGamePerfEvent( CGamePerfEvent.EVENT_SYNC );
        vEvent.record = pRecord;

        dispatchEvent( vEvent );

        var pSender : CGamePerfSender = getHandler( CGamePerfSender ) as CGamePerfSender;
        if ( pSender ) {
            pSender.send( pRecord, m_iErrTimeElapsed, m_iTypeOfStack.length ? m_iTypeOfStack[ m_iTypeOfStack.length - 1 ] : TYPE_OF_LEVEL, m_vecActivateBundles );
        }

        // reset for re-calc.
        m_iErrTimeElapsed = 0;
    }

} // CGamePerfMonitor
} // package kof.game.perfs

// vim:ft=as3 tw=120
