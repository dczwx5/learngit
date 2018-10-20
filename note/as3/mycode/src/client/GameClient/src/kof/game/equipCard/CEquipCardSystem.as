//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/13.
 */
package kof.game.equipCard {

import com.greensock.plugins.BezierPlugin;
import com.greensock.plugins.TweenPlugin;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ESystemBundlePropertyType;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.equipCard.Enum.EEquipCardOpenType;
import kof.game.equipCard.util.CEquipCardUtil;
import kof.game.equipCard.view.CEquipCardActiveViewHandler;
import kof.game.equipCard.view.CEquipCardPoolViewHandler;
import kof.game.equipCard.view.CEquipCardResultViewHandler;
import kof.game.equipCard.view.CEquipCardViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;

import morn.core.handlers.Handler;

/**
 * 装备抽卡系统
 * @author sprite (sprite@qifun.com)
 */
public class CEquipCardSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var m_pMainViewHandler:CEquipCardViewHandler;
    private var m_pManager:CEquipCardManager;
    private var m_pNetHandler:CEquipCardNetHandler;
    private var m_pActivityWin:CEquipCardActiveViewHandler;

    public function CEquipCardSystem()
    {
        super();

        CEquipCardUtil.initialize(this);
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

            m_pMainViewHandler = new CEquipCardViewHandler();
            this.addBean( m_pMainViewHandler );

            m_pNetHandler = new CEquipCardNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CEquipCardManager();
            this.addBean( m_pManager );

            m_pActivityWin = new CEquipCardActiveViewHandler();
            this.addBean(m_pActivityWin);

            this.addBean( new CEquipCardResultViewHandler() );
            this.addBean( new CEquipCardPoolViewHandler() );
        }

        m_pMainViewHandler = m_pMainViewHandler || this.getHandler( CEquipCardViewHandler ) as CEquipCardViewHandler;
        m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

        TweenPlugin.activate([BezierPlugin]);

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.EQUIP_CARD);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        addEventListeners();

        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            instanceSystem.callWhenInMainCity(_showActiveWin,null,null,null,1);
        }

        // 登陆时小红点提示
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,CEquipCardUtil.hasCardToPump());
        }

        addEventListeners();
    }

    protected function addEventListeners() : void
    {
        if(stage.getSystem(CBagSystem))
        {
            (stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }
    }

    protected function removeEventListeners() : void
    {
        if(stage.getSystem(CBagSystem))
        {
            (stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        }
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CEquipCardViewHandler = this.getHandler( CEquipCardViewHandler ) as CEquipCardViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CEquipCardViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            if(CEquipCardUtil.IsInPumping)
            {
                (stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert(CLang.Get("equipCard_zznd"),CMsgAlertHandler.WARNING);
                this.setActivated( true );
            }
            else
            {
                pView.removeDisplay();
            }
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
        var bundleCtx:ISystemBundleContext = stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        bundleCtx.setUserData(this, ESystemBundlePropertyType.Type_SystemOpenWay, EEquipCardOpenType.OPEN_TYPE_ICON);
    }

    private function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if( e.type == CBagEvent.BAG_UPDATE)
        {
            var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( null != pSystemBundleCtx )
            {
                var curState:Boolean = pSystemBundleCtx.getUserData(this,CBundleSystem.NOTIFICATION,false);
                var isCanPump:Boolean = CEquipCardUtil.hasCardToPump();
                if(curState != isCanPump)
                {
                    pSystemBundleCtx.setUserData(this,CBundleSystem.NOTIFICATION,isCanPump);
                }
            }
        }
    }

    /**
     * 显示活动窗口
     */
    private function _showActiveWin():void
    {
//        if(CEquipCardUtil.isInActiveTime())
//        {
//            m_pActivityWin.addDisplay();
//        }
    }

    override public function dispose() : void
    {
        super.dispose();

        removeEventListeners();

        m_pMainViewHandler.dispose();
        m_pMainViewHandler = null;

        m_pNetHandler.dispose();
        m_pNetHandler = null;

        m_pManager.dispose();
        m_pManager = null;

        m_pActivityWin.dispose();
        m_pActivityWin = null;
    }
}
}
