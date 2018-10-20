//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import flash.display.Stage;
import flash.display.Stage3D;
import flash.events.Event;
import flash.system.Capabilities;

import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.game.bootstrap.CBootstrapEvent;
import kof.game.bootstrap.CBootstrapSystem;
import kof.game.bootstrap.CNetDelayHandler;
import kof.ui.master.debug.StatsInfoUI;
import kof.util.Fps;

/**
 * FPS，MEM，运行时相关调试数据显示
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CDebugStatsViewHandler extends CViewHandler {

    /** @private */
    private var m_pDisplay : StatsInfoUI;
    private var m_pFPSMeter : Fps;
    private var m_bVisible : Boolean;

    /** @private */
    public function CDebugStatsViewHandler() {
        super( true );
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pDisplay ) {
            m_pDisplay.remove();
        }
        m_pDisplay = null;

        if ( m_pFPSMeter ) {
            m_pFPSMeter.dispose();
        }
        m_pFPSMeter = null;
    }

    override protected virtual function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function get additionalAssets() : Array {
        return [ "comp.swf" ];
    }

    override protected function onInitializeView() : Boolean {
        var ret : Boolean = super.onInitializeView();
        if ( !ret ) return false;

        if ( !m_pDisplay ) {
            m_pDisplay = new StatsInfoUI();
            m_pFPSMeter = new Fps( 100, 60, 1.0 );
            m_pFPSMeter.fpsColor = 0xFF00FF00;
            m_pFPSMeter.memColor = 0xFFFFFF00;
            m_pDisplay.FPSDiagramBox.addChild( m_pFPSMeter );
            this.visible = false;

            system.stage.flashStage.addChild( m_pDisplay );

            system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, CEventPriority.DEFAULT, true );
        }

        var pAppSystem : CBootstrapSystem = system.stage.getSystem( CBootstrapSystem ) as CBootstrapSystem;
        if ( pAppSystem ) {
            pAppSystem.addEventListener( CBootstrapEvent.NET_DELAY_RESPONSE, _onNetDelayResponse, false, CEventPriority.DEFAULT, true );
        }

        invalidate();
        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
        return ret;
    }

    private function _onStageResize( event : Event ) : void {
        invalidateDisplay();
    }

    private function _onNetDelayResponse( event : Event ) : void {
        this.updateNetDelay();
    }

    override protected function updateData() : void {
        super.updateData();

        if ( !visible )
            return;

        if ( m_pDisplay ) {
            m_pDisplay.txt_kof_version.text = system.stage.configuration.getString( "build_version", "N/A" );

            var runtimeVersionArr : Array = Capabilities.version.split( ' ', 1 );
            if ( runtimeVersionArr && runtimeVersionArr.length > 1 )
                m_pDisplay.txt_runtime_version.text = runtimeVersionArr[ 1 ];
            else
                m_pDisplay.txt_runtime_version.text = Capabilities.version;

            m_pDisplay.txt_runtime_type.text = Capabilities.playerType + " " + (Capabilities.isDebugger ? "Debugger" : "Release");
            m_pDisplay.txt_brower_caps.text = "N/A";

            m_pDisplay.txt_os.text = Capabilities.os;
            m_pDisplay.txt_stage_rect.text = system.stage.flashStage.stageWidth + "x" + system.stage.flashStage.stageHeight;
            m_pDisplay.txt_screen_dpi.text = Capabilities.screenDPI.toString();
            m_pDisplay.txt_cpu_arch.text = Capabilities.cpuArchitecture;
            m_pDisplay.txt_cpu_core.text = "N/A";

            var s3d : Stage3D = system.stage.flashStage.stage3Ds[ 0 ];
            if ( s3d && s3d.context3D ) {
                m_pDisplay.txt_stage3D_driverInfo.text = s3d.context3D.driverInfo;
                m_pDisplay.txt_stage3D_agalVersion.text = getAGALVersion( s3d.context3D.driverInfo );
            } else if ( s3d ) {
                s3d.addEventListener( Event.CONTEXT3D_CREATE, _onContext3DCreated, false, CEventPriority.DEFAULT, true );
            }

            this.updateNetDelay();
        }
    }

    protected function updateNetDelay() : void {
        if ( !visible || !m_pDisplay )
            return;

        var pAppSystem : CAppSystem = system.stage.getSystem( CBootstrapSystem );
        if ( pAppSystem ) {
            var pNetDelayHandler : CNetDelayHandler = pAppSystem.getHandler( CNetDelayHandler ) as CNetDelayHandler;
            if ( pNetDelayHandler ) {
                m_pDisplay.txt_net_delay.text = pNetDelayHandler.currentDelay.toString() + " ms";
                if ( pNetDelayHandler.currentDelayLevel == CNetDelayHandler.NET_DELAY_GOOD ) {
                    m_pDisplay.txt_net_delay.color = 0x00FF00;
                } else if ( pNetDelayHandler.currentDelayLevel == CNetDelayHandler.NET_DELAY_NORMAL ) {
                    m_pDisplay.txt_net_delay.color = 0x999900;
                } else if ( pNetDelayHandler.currentDelayLevel == CNetDelayHandler.NET_DELAY_BAD ) {
                    m_pDisplay.txt_net_delay.color = 0xFF0000;
                }
            }
        }
    }

    private function getAGALVersion( driverInfo : String ) : String {
        if ( !driverInfo )
            return "N/A";

        var idx : int = driverInfo.lastIndexOf( '(' );
        if ( idx != -1 ) {
            driverInfo = driverInfo.slice( idx + 1 );
            idx = driverInfo.lastIndexOf( ')' );
            if ( idx != -1 ) {
                driverInfo = driverInfo.slice( 0, idx );
            }
            driverInfo = driverInfo.charAt( 0 ).toLocaleLowerCase() + driverInfo.slice( 1 );
        }

        const profile : String = driverInfo;

        switch ( profile ) {
            case 'standardExtended': {
                return "N/3.0";
            }
            case 'standard':
            case 'standardConstrained': {
                return "N/2.0";
            }
            case 'baselineExtended':
            case 'baseline':
            case 'baselineConstrained':
            default:
                return "1.0";
        }
    }

    private function _onContext3DCreated( event : Event ) : void {
        event.currentTarget.removeEventListener( event.type, _onContext3DCreated );
        invalidate();
    }

    override protected virtual function updateDisplay() : void {
        super.updateDisplay();

        if ( m_pDisplay && m_pDisplay.parent ) { // align to right-bottom by stage.
            m_pDisplay.txt_stage_rect.text = system.stage.flashStage.stageWidth + "x" + system.stage.flashStage.stageHeight;

            var flashStage : Stage = system.stage.flashStage;
            m_pDisplay.x = flashStage.stageWidth - m_pDisplay.width;
            m_pDisplay.y = flashStage.stageHeight - m_pDisplay.height - 70;

//            m_pDisplay.sendEvent( Event.RESIZE );
            m_pDisplay.boxLayout.refresh();
        }
    }

    public function get visible() : Boolean {
        return m_bVisible;
    }

    public function set visible( visible : Boolean ) : void {
        m_bVisible = visible;
        m_pDisplay.visible = visible;

        invalidate();
    }

}
}
