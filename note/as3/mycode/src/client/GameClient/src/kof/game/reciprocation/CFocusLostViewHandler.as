//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/21.
 */
package kof.game.reciprocation {

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import kof.SYSTEM_ID;

import kof.framework.CAppSystem;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.view.CViewBase;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.hook.CHookSystem;
import kof.game.hook.CHookViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.scenario.CScenarioSystem;
import kof.ui.master.FocusLost.FocusLostViewUI;

import morn.core.components.Dialog;

public class CFocusLostViewHandler extends CViewHandler {

    private var m_pViewUI : FocusLostViewUI;
    private var m_bViewInitialized : Boolean;
    private var m_bIsNeedFocusLostTip:Boolean = true;

    public function CFocusLostViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();

        system.stage.flashStage.addEventListener(Event.ACTIVATE, _onActivateHandler, false, 0, true);
        system.stage.flashStage.addEventListener(Event.DEACTIVATE, _onDeActivateHandler, false, 0, true);

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [FocusLostViewUI];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new FocusLostViewUI();

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView(viewClass, _showDisplay);
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            _addToDisplay();
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        if(m_pViewUI.parent == null)
        {
            uiCanvas.addPopupDialog(m_pViewUI);
            m_pViewUI.clip_mouse.autoPlay = true;
        }
    }

    public function removeDisplay():void
    {
        if (m_pViewUI && m_pViewUI.parent)
        {
            m_pViewUI.close(Dialog.CLOSE);

            m_pViewUI.clip_mouse.autoPlay = false;
        }
    }

    private function _onClickHandler(e:MouseEvent):void
    {
        e.stopImmediatePropagation();

        removeDisplay();
        system.stage.flashStage.removeEventListener(MouseEvent.CLICK, _onClickHandler);
    }

    private function _onKeyboardDown(e:KeyboardEvent):void
    {
        removeDisplay();
        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyboardDown);
    }

    private function _onActivateHandler(e:Event):void
    {
        e.preventDefault()
    }

    private function _onDeActivateHandler(e:Event):void
    {
        if(!m_bIsNeedFocusLostTip)
        {
            removeDisplay();
            return;
        }

        if(!_isAllowShow())
        {
            removeDisplay();
            return;
        }

        addDisplay();
        system.stage.flashStage.addEventListener(MouseEvent.CLICK, _onClickHandler, false, 0, true);
        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyboardDown, false, 0, true);
    }

    private function _isAllowShow():Boolean
    {
        var hookSystem:CAppSystem = system.stage.getSystem(CHookSystem);
        if(hookSystem && hookSystem.enabled)
        {
            var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.HOOK));
            var isShow:Boolean = bundleCtx.getUserData(systemBundle, CBundleSystem.ACTIVATED, false);
            if(isShow)
            {
                return false;
            }
        }

        var scenarioSystem:CScenarioSystem = system.stage.getSystem(CScenarioSystem) as CScenarioSystem;
        if(scenarioSystem && scenarioSystem.enabled)
        {
            if(scenarioSystem.isPlaying)
            {
                return false;
            }
        }

        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem && instanceSystem)
        {
            if(!instanceSystem.isInInstance || instanceSystem.isMainCity)
            {
                return false;
            }
        }

        if(_isInstanceResultShowing())
        {
           return false;
        }

        return true;
    }

    /**
     * 副本结算界面是否显示状态
     * @return
     */
    private function _isInstanceResultShowing():Boolean
    {
        var winTypeArr:Array = [EInstanceWndType.WND_INSTANCE_RESULT_WIN,
                                EInstanceWndType.WND_INSTANCE_RESULT_LOSE,
                                EInstanceWndType.WND_INSTANCE_RESULT_PVP_WIN,
                                EInstanceWndType.WND_INSTANCE_RESULT_GOLD_WIN,
                                EInstanceWndType.WND_INSTANCE_RESULT_TRAIN_WIN];

        var instanceUIHandler:CInstanceUIHandler = (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).getHandler(CInstanceUIHandler)
                                                as CInstanceUIHandler;
        for each(var type:int in winTypeArr)
        {
            var view:CViewBase = instanceUIHandler.getWindow(type );
            if(view && view.isShowState)
            {
                return true;
            }
        }

        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            var pvpResultView:CMultiplePVPResultViewHandler = instanceSystem.getHandler(CMultiplePVPResultViewHandler)
                as CMultiplePVPResultViewHandler;
            if(pvpResultView && pvpResultView.isViewShow)
            {
                return true;
            }
        }

        return false;
    }

    public function closeFocusLostTip():void
    {
        m_bIsNeedFocusLostTip = false;
    }

    public function openFocusLostTip():void
    {
        m_bIsNeedFocusLostTip = true;
    }
}
}
