//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.ranking.view {

import kof.framework.CViewHandler;
import kof.game.scene.ISceneFacade;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.master.ranking.RankingViewUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

import mx.utils.StringUtil;

/**
 * 排行榜
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CRankingViewHandler extends CViewHandler {

    private var m_pViewUI : RankingViewUI;
    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;

    /**
     * Creates a new CRankingViewHandler.
     */
    public function CRankingViewHandler() {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        m_pViewUI = null;
    }

    override public function get viewClass() : Array {
        return [ RankingViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_pViewUI ) {
                m_pViewUI = new RankingViewUI();

                m_pViewUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        uiCanvas.addDialog( m_pViewUI );
    }

    public function removeDisplay() : void {
        if ( m_pViewUI ) {
            for ( var i : int = 1; i <= 3; ++i ) {
                var pCharacterClip : CCharacterFrameClip = m_pViewUI[ 'clipCharacter_' + i ] as CCharacterFrameClip;
                if ( pCharacterClip ) {
                    pCharacterClip.framework = null;
                }
            }
            m_pViewUI.close( Dialog.CLOSE );
        }
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    override protected virtual function updateData() : void {
        super.updateData();

        if ( m_pViewUI ) {

            var pScene : ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
            for ( var i : int = 1; i <= 3; ++i ) {
                var pCharacterClip : CCharacterFrameClip = m_pViewUI[ 'clipCharacter_' + i ] as CCharacterFrameClip;
                if ( pCharacterClip ) {
                    if ( !pCharacterClip.framework ) {
                        pCharacterClip.framework = pScene.scenegraph.graphicsFramework;
                    }

                    var labels : Array = m_pViewUI.tabAnimationCilp.labels.split( "," );
                    var sAnimationName : String = labels[ m_pViewUI.tabAnimationCilp.selectedIndex ];
                    if ( sAnimationName ) {
                        pCharacterClip.animationName = StringUtil.trim( sAnimationName );
                    }
                }
            }

            if ( !m_pViewUI.tabAnimationCilp.selectHandler ) {
                m_pViewUI.tabAnimationCilp.selectHandler = new Handler( _onTabSelected );
            }
        }
    }

    private function _onTabSelected( ... args ) : void {
        this.invalidateData();
    }

}
}
