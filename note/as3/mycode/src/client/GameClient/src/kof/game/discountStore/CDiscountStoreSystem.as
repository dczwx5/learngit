//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/9/11.
 */
package kof.game.discountStore {

import flash.events.Event;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.switching.CSwitchingSystem;
import kof.game.switching.validation.CSwitchingValidatorSeq;

import morn.core.handlers.Handler;

public class CDiscountStoreSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pViewHandler:CDiscountStoreViewHandler;
    private var m_pHelpHandler:CDiscountStoreHelpHandler;

    private var m_pValidater : CDiscountStoreValidater;

    public function CDiscountStoreSystem( A_objBundleID : * = null )
    {
        super( A_objBundleID );
    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pViewHandler = new CDiscountStoreViewHandler();
            this.addBean( m_pViewHandler );

            m_pHelpHandler = new CDiscountStoreHelpHandler();
            this.addBean( m_pHelpHandler );

//            m_pNetHandler = new CDailyRechargeNetHandler();
//            this.addBean( m_pNetHandler );
//
//            m_pManager = new CDailyRechargeManager();
//            this.addBean( m_pManager );

            var switchingSystem : CSwitchingSystem = stage.getSystem( CSwitchingSystem ) as CSwitchingSystem;
            m_pValidater = new CDiscountStoreValidater(this);
            switchingSystem.addValidator( m_pValidater );
        }

        m_pViewHandler = m_pViewHandler || this.getHandler( CDiscountStoreViewHandler ) as CDiscountStoreViewHandler;
        m_pViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override protected function onBundleStart(bundleCtx:ISystemBundleContext):void
    {
        super.onBundleStart(bundleCtx);

        _addListeners();
    }

    private function _addListeners():void
    {
        stage.getSystem(CActivityHallSystem).addEventListener(
                CActivityHallEvent.ActivityHallActivityStateChanged, _updateActivityOpenState);

        this.stage.flashStage.addEventListener("LoginSucc", _onLoginSuccHandler);
    }

    private function _removeListeners():void
    {
        stage.getSystem(CActivityHallSystem ).removeEventListener(
                CActivityHallEvent.ActivityHallActivityStateChanged, _updateActivityOpenState);
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CDiscountStoreViewHandler = this.getHandler( CDiscountStoreViewHandler ) as CDiscountStoreViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CTotalRechargeViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            pView.removeDisplay();
        }
    }

    public function setActivity(isActivity : Boolean) : void
    {
        this.setActivated(isActivity);
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.DISCOUNT_STORE );
    }

    private function _onLoginSuccHandler(e:Event):void
    {
        _updateActivityOpenState();
    }

    private function _updateActivityOpenState(event : CActivityHallEvent = null):void
    {
        if(m_pHelpHandler.isActivityOpen())// 开启
        {
            if((stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(KOFSysTags.DISCOUNT_STORE))
            {
                return;
            }

            m_pValidater.valid = true;
            var switchingSystem:CSwitchingSystem = stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
            var pValidators : CSwitchingValidatorSeq = switchingSystem.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;

            if ( pValidators )
            {
                if ( pValidators.evaluate() )// 验证所有开启条件是否已达成
                {
                    var vResult : Vector.<String> = pValidators.listResultAsTags();
                    if ( vResult && vResult.length )
                    {
                        if(vResult.indexOf(KOFSysTags.DISCOUNT_STORE) != -1)
                        {
                            var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
                            if ( pSystemBundleContext )
                            {
                                pSystemBundleContext.startBundle( this );
                            }
                        }
                    }
                }
            }
        }
        else// 关闭
        {
            if(!(stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(KOFSysTags.DISCOUNT_STORE))
            {
                return;
            }

            m_pValidater.valid = false;
            this.setActivated( false );
            pSystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleContext )
            {
                pSystemBundleContext.stopBundle(this);
            }
        }
    }

    override public function dispose() : void
    {
        super.dispose();

        m_pViewHandler.dispose();
        m_pViewHandler = null;

        m_pHelpHandler.dispose();
        m_pHelpHandler = null;

        m_pValidater.dispose();
        m_pValidater = null;
    }
}
}