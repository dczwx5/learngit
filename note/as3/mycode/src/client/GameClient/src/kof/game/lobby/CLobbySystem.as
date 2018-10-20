package kof.game.lobby {

import QFLib.Interface.IUpdatable;

import flash.events.Event;
import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CAppStage;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.ICharacterProfile;
import kof.game.character.fight.CFightHandler;
import kof.game.chat.CChatSystem;
import kof.game.core.CECSLoop;
import kof.game.fightui.CFightViewHandler;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;
import kof.game.lobby.view.CChargeActivityNoticeViewHandler;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.lobby.view.CPlayerHeadViewHandler;
import kof.game.scenario.IScenarioSystem;
import kof.game.scenario.event.CScenarioEvent;
import kof.util.CSystemIDBinder;

/**
 * 游戏大厅系统
 * |- 游戏主界面视图控制器
 *   |- 常驻功能系统挂接
 *   |- 功能系统挂接
 *   |- 玩家(战队)简易状态
 *   \- 布局控制器
 * \- 主界面下个体游戏逻辑控制器
 *   |- 消息提示
 *   |- ...
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLobbySystem extends CBundleSystem implements IUpdatable {

    /** @private */
    private var m_pView : CLobbyViewHandler;
    private var m_pFightView : CFightViewHandler;
    private var m_bFightUIEnabled : Boolean;
    private var m_bTweenEffect : Boolean;

    /**
     * Creates a new CLobbySystem.
     */
    public function CLobbySystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        CSystemIDBinder.bind( KOFSysTags.LOBBY, -1 );

        if ( !super.initialize() )
            return false;


        this.addBean( new CPlayerInfoInLobbyHandler() );
        this.addBean( new CPlayerHeadViewHandler() );
        this.addBean( new CChargeActivityNoticeViewHandler() );
        this.addBean( new CChargeActivityHandler() );
        this.addBean( ( m_pView = new CLobbyViewHandler() ) );
        this.addBean( ( m_pFightView = new CFightViewHandler() ) );

        var pDB : IDatabase = stage.getSystem( IDatabase ) as IDatabase;
        if ( pDB ) {
            var pMainViewTable : IDataTable = pDB.getTable( KOFTableConstants.MAIN_VIEW );
            if ( pMainViewTable ) {
                var pMainViewData : Array = pMainViewTable.toArray();
                this.addBean( new CMainViewConfigHolder( pMainViewData ) );
            } else {
                return false;
            }
        }

        attachEventListeners();

        this.tweenEffect = true;
        this.enabled = true;

        return true;
    }

    public function update( delta : Number ) : void {
        if ( m_pFightView )
            m_pFightView.update( delta );
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        detachEventListeners();

        return ret;
    }

    protected function attachEventListeners() : void {
        var pInstanceSys : IInstanceFacade = stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys ) {
            pInstanceSys.eventDelegate.addEventListener( CInstanceEvent.ENTER_INSTANCE, _onEnterInstance, false, CEventPriority.DEFAULT, true );
            pInstanceSys.eventDelegate.addEventListener( CInstanceEvent.EXIT_INSTANCE, _onExitInstance, false, CEventPriority.DEFAULT, true );
        }
        var scenarioSystem : IScenarioSystem = stage.getSystem( IScenarioSystem ) as IScenarioSystem;
        if ( scenarioSystem ) {
            scenarioSystem.listenEvent( _onScenarioUpdate );
        }

        this.stage.flashStage.addEventListener("LoginSucc", _onLoginSucc);
    }

    private function _onScenarioUpdate( event : CScenarioEvent ) : void {
        var pInstanceSys : IInstanceFacade = stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if (pInstanceSys.isMainCity) {
            if ( enabled ) {
                if ( event.type == CScenarioEvent.EVENT_SCENARIO_START ) {
//                    slideIn(); // 修改成不等待动效
                    // 先界面动效。再播剧情。所以这块。不能在这里处理，要在剧情播放之前处理
                } else if ( event.type == CScenarioEvent.EVENT_SCENARIO_END ) {
//                    slideOut();
                }
                return;
            }
        }


        if ( event.type == CScenarioEvent.EVENT_SCENARIO_START ) {
            this.fightUIEnabled = false;
        } else if ( event.type == CScenarioEvent.EVENT_SCENARIO_END ) {
            this.fightUIEnabled = true;
        }
    }

    private function _onLoginSucc(e:Event):void
    {
        var noticeView:CChargeActivityNoticeViewHandler = this.getHandler(CChargeActivityNoticeViewHandler)
                as CChargeActivityNoticeViewHandler;
        noticeView.addDisplay();
    }

    protected function detachEventListeners() : void {
        var pInstanceSys : IInstanceFacade = stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys ) {
            pInstanceSys.eventDelegate.removeEventListener( CInstanceEvent.ENTER_INSTANCE, _onEnterInstance );
            pInstanceSys.eventDelegate.removeEventListener( CInstanceEvent.EXIT_INSTANCE, _onExitInstance );
        }
        var scenarioSystem : IScenarioSystem = stage.getSystem( IScenarioSystem ) as IScenarioSystem;
        if ( scenarioSystem ) {
            scenarioSystem.unListenEvent( _onScenarioUpdate );
        }
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.LOBBY );
    }

    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        // 开始主界面系统，预载入主城界面相关UI资源
        var pLobbyViewHandler : CLobbyViewHandler = this.getHandler( CLobbyViewHandler ) as CLobbyViewHandler;
        if ( pLobbyViewHandler ) {
            pLobbyViewHandler.loadAssetsByView( pLobbyViewHandler.viewClass );
        }
    }

    protected function onFightEnabled( bEnabled : Boolean ) : void {
        var pLoop : CECSLoop = stage.getSystem( CECSLoop ) as CECSLoop;
        if ( pLoop ) {
            var pFightHandler : CFightHandler = pLoop.getBean( CFightHandler ) as CFightHandler;
            if ( pFightHandler ) {
                pFightHandler.enabled = bEnabled;
            }

            var pCharacterProfile : ICharacterProfile = pLoop.getBean( ICharacterProfile ) as ICharacterProfile;
            if ( pCharacterProfile ) {
                pCharacterProfile.nameDisplayed = !bEnabled;
            }
        }
        fightUIEnabled = bEnabled;
    }

    override protected function setEnabled( value : Boolean ) : void {
        if ( value ) {
            var pInfoHandler : CPlayerInfoInLobbyHandler = getHandler( CPlayerInfoInLobbyHandler ) as CPlayerInfoInLobbyHandler;
            if ( pInfoHandler ) {
                pInfoHandler.invalidate();
            }

            if ( m_pView ) {
                m_pView.addDisplay( this.tweenEffect );
                visible = true;
            }

        } else {
            if ( m_pView ) {
                m_pView.removeDisplay( this.tweenEffect );
//                visible = false;
            }
        }

        this.onFightEnabled( !value );
    }

    public function get visible() : Boolean {
        if (m_pView) {
            return m_pView.visible;
        }
        return false;
    }
    public function set visible(v:Boolean) : void {
        if (m_pView) {
            m_pView.visible = v;
            if (_forceHide) {
                m_pView.visible = false;
            }
            //to fix
            if( !m_pView.visible )
                ( stage.getSystem( CChatSystem ) as CChatSystem ).mainUIHide();
        }
    }

    public function get tweenEffect() : Boolean {
        return m_bTweenEffect;
    }

    public function set tweenEffect( value : Boolean ) : void {
        m_bTweenEffect = value;
    }

    public function slideOut( pfnFinished : Function = null, ... args ) : void {
        var originTweenEffect : Boolean = this.tweenEffect;
        this.tweenEffect = true;
        this.visible = true;
        this.enabled = true;
        m_bSwitchTweening = true;

        m_pView.tweenOut.apply( null, [ function( fatArgs : Array = null ) : void {
            tweenEffect = originTweenEffect;
            m_bSwitchTweening = false;
            visible = true; // 先调slideInt, 再马上调slideOut最后visible是false
//            trace("______dlideOut " + visible);
            if ( pfnFinished != null )
                pfnFinished.apply( null, fatArgs );
        } ].concat( args ) );
    }

    public function slideIn( pfnFinished : Function = null, ... args ) : void {

        var originTweenEffect : Boolean = this.tweenEffect;
        this.tweenEffect = true;
        m_bSwitchTweening = true;

        m_pView.tweenIn.apply( null, [ function( fatArgs : Array = null ) : void {
            tweenEffect = originTweenEffect;
            m_bSwitchTweening = false;
            visible = false;
//            trace("______slideIn " + visible);

            if ( null != pfnFinished )
                pfnFinished.apply( null, fatArgs );
        }].concat( args ) );
    }

    private function _onEnterInstance( event : Event ) : void {
        var pInstanceSys : IInstanceFacade = stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        this.enabled = pInstanceSys.isMainCity;
    }

    private function _onExitInstance( event : Event ) : void {
        // NOOP.
    }

    public function get fightUIEnabled() : Boolean {
        return m_bFightUIEnabled;
    }

    public function set fightUIEnabled( value : Boolean ) : void {
        if ( m_bFightUIEnabled == value )
            return;
        m_bFightUIEnabled = value;
        stage.callLater( setFightUIEnabled );
    }

    protected function setFightUIEnabled() : void {
        if ( this.fightUIEnabled ) {
            if ( m_pFightView ) {
                m_pFightView.show();
            }
        } else {
            if ( m_pFightView ) {
                m_pFightView.hide();
            }
        }
    }

    public function getIconGlobalPointCenter(sysTagName:String) : Point {
        if (m_pView) {
            var point:Point = m_pView.getIconGlobalPointCenter(sysTagName);
            return point;
        }
        return null;
    }

    public function set forceHide(v:Boolean) : void {
        _forceHide = v;
    }
    private var _forceHide:Boolean;

    public function get isSwitchTweening() : Boolean {
        return m_bSwitchTweening;
    }

    private var m_bSwitchTweening:Boolean;
} // class CLobbySystem
}

import QFLib.Interface.IDisposable;

import kof.framework.IDataHolder;

// package kof.game.lobby

class CMainViewConfigHolder implements IDisposable, IDataHolder {

    private var m_pData : Object;

    public function CMainViewConfigHolder( data : Object ) {
        super();
        this.m_pData = data;
    }

    public function get data() : Object {
        return this.m_pData;
    }

    public function dispose() : void {
        if ( this.m_pData ) {
            this.m_pData.splice( 0, this.m_pData.length );
        }
        this.m_pData = null;
    }

}

