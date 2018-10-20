//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching {

import QFLib.Foundation;

import flash.events.Event;

import kof.SYSTEM_ID;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.switching.triggers.CSwitchingInstanceEnterTrigger;
import kof.game.switching.triggers.CSwitchingInstancePassingTrigger;
import kof.game.switching.triggers.CSwitchingLevelUpTrigger;
import kof.game.switching.triggers.CSwitchingTaskTrigger;
import kof.game.switching.triggers.CSwitchingTriggerBridge;
import kof.game.switching.triggers.CSwitchingTriggerEvent;
import kof.game.switching.validation.CSwitchingMinLevelValidator;
import kof.game.switching.validation.CSwitchingValidatorSeq;
import kof.game.switching.validation.ISwitchingValidation;
import kof.game.switching.view.CFuncNoticeDetectHandler;
import kof.game.switching.view.CFuncNoticeViewHandler;
import kof.game.switching.view.CSwitchingComingViewHandler;
import kof.game.switching.view.CSwitchingPopUpViewHandler;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskData;
import kof.table.BundleEnable;
import kof.table.BundleEnable.EBundleEnableShowType;
import kof.table.FunctionNotice;
import kof.table.MainView;
import kof.table.SystemIDs;
import kof.table.SystemIDs;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.util.CAssertUtils;

/**
 * 触发
 *  - 角色升级事件监听
 *  - 完成任务时间监听
 *  - ...
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingHandler extends CSystemHandler {

    /** @private */
    private var m_pTrigger : CSwitchingInstanceEnterTrigger;

    /**
     * Creates a new CSwitchingHandler.
     */
    public function CSwitchingHandler() {
        super();
    }

    /**
     * @inheritDoc
     */
    override public function dispose() : void {
        super.dispose();
        detachAllEventHandlers();

        if ( m_pTrigger )
            m_pTrigger = null;
    }

    /**
     * @inheritDoc
     */
    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.initialize();
        return ret;
    }

    protected function initialize() : Boolean {
        var pTriggers : CSwitchingTriggerBridge = system.getHandler( CSwitchingTriggerBridge ) as CSwitchingTriggerBridge;
        if ( pTriggers ) {
            pTriggers.addTrigger( new CSwitchingLevelUpTrigger() );
            pTriggers.addTrigger( new CSwitchingInstancePassingTrigger() );
            pTriggers.addTrigger( new CSwitchingTaskTrigger() );

            var vDecorator : CSwitchingInstanceEnterTrigger = new CSwitchingInstanceEnterTrigger();
            vDecorator.initWith( pTriggers, this.system );

            vDecorator.addEventListener( CSwitchingTriggerBridge.EVENT_TRIGGERED, _bridge_triggeredEventHandler, false,
                    CEventPriority.DEFAULT_HANDLER, true );

            m_pTrigger = vDecorator;
        }
        return true;
    }

    /**
     * @inheritDoc
     */
    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        detachAllEventHandlers();
        return ret;
    }

    /**
     * @inheritDoc
     */
    override protected function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );
    }

    /** @private */
    final private function detachAllEventHandlers() : void {
        if ( m_pTrigger ) {
            m_pTrigger.removeEventListener( CSwitchingTriggerBridge.EVENT_TRIGGERED, _bridge_triggeredEventHandler );
        }
    }

    /** @private */
    private function _bridge_triggeredEventHandler( event : CSwitchingTriggerEvent ) : void {
        Foundation.Log.logTraceMsg( "Switching validation triggered ..." );

        // Run validation.
        var pValidators : CSwitchingValidatorSeq = system.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
        var pBundle : ISystemBundle;
        if ( pValidators ) {
            if ( pValidators.evaluate() ) {
                // 有符合条件的开启项
                // 1. 判定所有符合开启条件的功能系统是否已经开启
                // 2. 已经开启的忽略，没有开启的处理开启逻辑执行
                var pBundleCtx : CSystemBundleContext = system.stage.getSystem( CSystemBundleContext ) as CSystemBundleContext;
                CAssertUtils.assertNotNull( pBundleCtx, "ISystemBundleContext required." );

                var vStarted : Vector.<String> = new <String>[];
                var vResult : Vector.<String> = pValidators.listResultAsTags();
                if ( vResult && vResult.length ) {
                    for each ( var vTag : String in vResult ) {
                        if ( !vTag )
                            continue;

                        if(_isChildSystem(vTag))
                        {
                            pBundle = _getParentSystem(vTag);
                            if ( !pBundle )
                            {
                                continue;
                            }

                            if(pBundleCtx.getChildSystemBundleState(pBundle, vTag) == CSystemBundleContext.STATE_STARTED)
                            {
                                continue;
                            }

                            if(pBundleCtx.getSystemBundleState( pBundle ) == CSystemBundleContext.STATE_STOPPED )
                            {
                                continue;
                            }

                            var pChildBundle : ISystemBundle = pBundleCtx.getSystemBundle( SYSTEM_ID( vTag ));

                            pBundleCtx.setChildSystemBundleState( pBundle, pChildBundle, vTag, CSystemBundleContext.STATE_STARTED );
                            LOG.logMsg( "    \\- %%%BUNDLE START: " + vTag );
                        }
                        else
                        {
                            var vBundleID : * = SYSTEM_ID( vTag );
                            pBundle = pBundleCtx.getSystemBundle( vBundleID );
                            if ( !pBundle ) // ignored.
                                continue;

                            if ( pBundleCtx.getSystemBundleState( pBundle ) == CSystemBundleContext.STATE_STARTED )
                                continue;

                            pBundleCtx.setSystemBundleState( pBundle, CSystemBundleContext.STATE_STARTED );
                            LOG.logMsg( "    \\- %%%BUNDLE START: " + vTag );
                        }

                        vStarted.push( vTag );
                    }
                }

                var bOpeningNotify : Boolean = m_pTrigger.isMainCity && !event.isInitPhase;

                if ( bOpeningNotify ) {
                    var pOpenView : CSwitchingPopUpViewHandler = system.getHandler( CSwitchingPopUpViewHandler ) as CSwitchingPopUpViewHandler;
                    if ( pOpenView ) {
                        pOpenView.addEventListener( CSwitchingPopUpViewHandler.EVENT_TWEEN_FINISHED, _openView_tweenFinishedEventHandler, false, 0, true );
                        var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
                        // 找出新开启的功能数据
                        if ( vStarted && vStarted.length ) {
                            if ( pDatabase ) {
                                var pBundleEnableTable : IDataTable = pDatabase.getTable( KOFTableConstants.BUNDLE_ENABLE );
                                if ( pBundleEnableTable ) {
                                    for each ( var vStartedTag : String in vStarted ) {
                                        if ( !vStartedTag ) continue;
                                        var pBundleEnable : BundleEnable = pBundleEnableTable.findByPrimaryKey( vStartedTag );
                                        if ( !pBundleEnable ) continue;
                                        pBundle = pBundleCtx.getSystemBundle( SYSTEM_ID( pBundleEnable.TagID ) );
                                        if ( pBundleEnable.ShowType == EBundleEnableShowType.DEFAULT ) {
                                            if(_isChildSystem(vStartedTag))
                                            {
                                                pOpenView.addToDisplayQueue( _getParentSystemTag(vStartedTag), getChildSystemBundleLocaleName( vStartedTag ), pBundleEnable.IconURI, getIconURI( pBundleEnable.TagID ), getIconText( pBundleEnable.TagID ) );
                                            }
                                            else
                                            {
                                                pOpenView.addToDisplayQueue( pBundleEnable.TagID, pBundle ? getSystemBundleLocaleName( pBundle.bundleID ) : null, pBundleEnable.IconURI, getIconURI( pBundleEnable.TagID ), getIconText( pBundleEnable.TagID ) );
                                                pBundleCtx.setUserData( pBundle, "visible", false );
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 屏蔽
                /*
                if ( m_pTrigger.isMainCity ) {
                    // 找出下一个需要开启的功能（需要预告提示的）
                    var pComingView : CSwitchingComingViewHandler = system.getHandler( CSwitchingComingViewHandler ) as CSwitchingComingViewHandler;
                    if ( pComingView ) {
                        var vComingShowItem : BundleEnable = pValidators.queryComingShowItem();
                        if ( vComingShowItem ) {
                            var iconURI : String = vComingShowItem.IconURI || getIconURI( vComingShowItem.TagID );
                            pBundle = pBundleCtx.getSystemBundle( SYSTEM_ID( vComingShowItem.TagID ) );
                            pComingView.bundleName = pBundle ? getSystemBundleLocaleName( pBundle.bundleID ) : null;
                            pComingView.iconUrl = iconURI;
                            pComingView.noticeDesc = vComingShowItem.NoticeDescText;
                            pComingView.condMinLevel = getConditionMinLevel( pBundle, vComingShowItem );
//                            pComingView.conditionDescList = getConditionDescList( pBundle, vComingShowItem );
                            pComingView.addDisplay();
                        } else {
                            pComingView.bundleName = null;
                            pComingView.iconUrl = null;
                            pComingView.noticeDesc = null;
                            pComingView.condMinLevel = 0;
                            pComingView.conditionDescList = null;
                            pComingView.removeDisplay();
                        }
                    }
                }
                */

                if(m_pTrigger.isMainCity)
                {
                    var funcNoticeView:CFuncNoticeViewHandler = system.getHandler(CFuncNoticeViewHandler) as CFuncNoticeViewHandler;
                    if(funcNoticeView)
                    {
                        var functionNotice:FunctionNotice =
                                (system.getHandler(CFuncNoticeDetectHandler) as CFuncNoticeDetectHandler).getNextNoticeItem();

                        if(functionNotice)
                        {
                            funcNoticeView.configData = functionNotice;
                            funcNoticeView.addDisplay();
                        }
                        else
                        {
                            funcNoticeView.removeDisplay();
                        }
                    }
                }

            }
        } else {
            LOG.logTraceMsg( "Switching validators is not obtained." );
        }
    }

    public function onBundleStart( ctx : ISystemBundleContext ) : void {
        // 通过条件开启该系统功能
        ctx.addEventListener( CSystemBundleEvent.USER_DATA, _systemBundleContext_userDataEventHandler, false, CEventPriority.BINDING, true );

        LOG.logTraceMsg( "SystemBundle [STARTED] at CSwitchingSystem..." );
    }

    [Ignore]
    internal function onBundleStop( ctx : ISystemBundleContext ) : void {
        ctx.removeEventListener( CSystemBundleEvent.USER_DATA, _systemBundleContext_userDataEventHandler );
    }

    private function _systemBundleContext_userDataEventHandler( event : CSystemBundleEvent ) : void {
        var pCtx : ISystemBundleContext = event.context;
        var pBundle : ISystemBundle = event.bundle;

        if ( pCtx.getSystemBundleState( pBundle ) != CSystemBundleContext.STATE_STARTED ) {
            event.stopPropagation();
            event.preventDefault();
            if( event.propertyData.propertyName == CBundleSystem.ACTIVATED ){
                alertActivatedAtStoppedBundle( pBundle, pCtx );
            }
            return;
        }

        event.subscribeEventPhaseEnd( _systemBundleContext_userDataEventEnd );
    }

    private function _openView_tweenFinishedEventHandler( event : Event ) : void {
        var pOpenView : CSwitchingPopUpViewHandler = system.getHandler( CSwitchingPopUpViewHandler ) as CSwitchingPopUpViewHandler;
        if ( pOpenView ) {
            var pBundleCtx : CSystemBundleContext = system.stage.getSystem( CSystemBundleContext ) as CSystemBundleContext;
            CAssertUtils.assertNotNull( pBundleCtx, "ISystemBundleContext required." );
            var pBundle : ISystemBundle = pBundleCtx.getSystemBundle( SYSTEM_ID( pOpenView.sysTag ));
            pBundleCtx.setUserData( pBundle, "visible", true );
        }
    }

    private function _systemBundleContext_userDataEventEnd( pContext : CSystemBundleContext, pBundle : ISystemBundle, bHandled : Boolean ) : void {
        if ( !bHandled ) {
            // 提示系统功能还未开放
            alertActivatedAtStoppedBundle( pBundle, pContext );
        }
    }

    public function getSystemBundleLocaleName( bundleID : * ) : String {
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        if ( pDB ) {
            // Retrieves the SystemBundle config table and binding tag and ID.
            var pTable : IDataTable = pDB.getTable( KOFTableConstants.SYSTEM_IDS ) as IDataTable;
            if ( pTable && bundleID ) {
                var pData : SystemIDs = pTable.findByPrimaryKey( bundleID );
                if ( pData ) {
                    return pData.Description;
                }
            }
        }
        return null;
    }

    public function getIconURI( sTagID : String ) : String {
        var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var pMainViewTable : IDataTable = pDatabase.getTable( KOFTableConstants.MAIN_VIEW );
        var theFindResult : Array = pMainViewTable.findByProperty( "Tag", sTagID );
        if ( theFindResult && theFindResult.length ) {
            var pMainViewData : MainView = theFindResult[ 0 ] as MainView;
            return pMainViewData.Icon;
        }
        return null;
    }

    public function getIconText( sTagID : String ) : String {
        var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var pMainViewTable : IDataTable = pDatabase.getTable( KOFTableConstants.MAIN_VIEW );
        var theFindResult : Array = pMainViewTable.findByProperty( "Tag", sTagID );
        if ( theFindResult && theFindResult.length ) {
            var pMainViewData : MainView = theFindResult[ 0 ] as MainView;
            return pMainViewData.IconText;
        }
        return null;
    }

    public function getConditionMinLevel( pBundle : ISystemBundle, pBundleEnable : BundleEnable, bOnlyInvalid : Boolean = false ) : int {
        if ( pBundleEnable ) {
            var pValidators : CSwitchingValidatorSeq = system.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
            if ( pValidators ) {
                var vStatusQuery : Array = [ 0 ];
                for each ( var pValidator : ISwitchingValidation in pValidators.iterator ) {
                    vStatusQuery[ 0 ] = 0;
                    if ( !pValidator )
                        continue;
                    var bVal : Boolean = pValidator.evaluate( pBundleEnable, vStatusQuery );

                    if ( vStatusQuery[ 0 ] == -1 ) { // No validation required
                        continue; // ignored.
                    }

                    if ( bVal && bOnlyInvalid )
                        continue;

                    if ( pValidator is CSwitchingMinLevelValidator ) {
                        return pBundleEnable.MinLevel;
                    }
                }
            }
        }
        return 0;
    }

//    public function getConditionDescList( pBundle : ISystemBundle, pBundleEnable : BundleEnable, bOnlyInvalid : Boolean = false ) : Array {
//        var ret : Array = null;
//
//        if ( pBundleEnable ) {
//            var pValidators : CSwitchingValidatorSeq = system.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
//            if ( pValidators ) {
//                var vStatusQuery : Array = [ 0 ];
//                for each ( var pValidator : ISwitchingValidation in pValidators.iterator ) {
//                    vStatusQuery[ 0 ] = 0;
//                    if ( !pValidator )
//                        continue;
//                    var bVal : Boolean = pValidator.evaluate( pBundleEnable, vStatusQuery );
//
//                    if ( vStatusQuery[ 0 ] == -1 ) { // No validation required
//                        continue; // ignored.
//                    }
//
//                    if ( bVal && bOnlyInvalid )
//                        continue;
//
//                    var localeDesc : String = null;
//                    if ( pValidator is CSwitchingMinLevelValidator ) {
//                        ret = ret || [];
//                        localeDesc = pBundleEnable.MinLevel + " 级开放";
//                        var sLocaleName : String = pBundle ? this.getSystemBundleLocaleName( pBundle.bundleID ) : null;
//                        if ( sLocaleName )
//                            localeDesc += sLocaleName;
//
//                        ret.push( localeDesc );
//                    }
//
////                    if ( (localeDesc = pValidator.getLocaleDesc( pBundleEnable ) ) ) {
////                        ret = ret || [];
////                        if ( bVal ) {
////                            localeDesc = '<font color="#9dff6d">' + localeDesc + '</font>';
////                        } else {
////                            localeDesc = localeDesc.replace( "{}", "#ff5215" );
////                        }
////                        ret.push( localeDesc );
////                    }
//                }
//            }
//        }
//
//        return ret;
//    }

    private function alertActivatedAtStoppedBundle( pBundle : ISystemBundle, pCtx : ISystemBundleContext ) : void {
        var pUICanvas : IUICanvas = system.stage.getSystem( IUICanvas ) as IUICanvas;
        if ( pUICanvas ) {
            var strMsg : String = "该系统{0}暂未开放！";

            var sLocaleName : String = pBundle ? this.getSystemBundleLocaleName( pBundle.bundleID ) : null;
            if ( sLocaleName )
                strMsg = strMsg.replace( "{0}", "[ " + sLocaleName + " ]" );
            else
                strMsg = strMsg.replace( "{0}", "" );

            pUICanvas.showMsgAlert( strMsg, CMsgAlertHandler.WARNING );
        }
    }

    private function _isChildSystem(sysTag:String):Boolean
    {
        var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var sysIdTable : IDataTable = pDatabase.getTable( KOFTableConstants.SYSTEM_IDS );
        var theFindResult : Array = sysIdTable.findByProperty( "Tag", sysTag );

        if ( theFindResult && theFindResult.length )
        {
            var systemIDs : SystemIDs = theFindResult[ 0 ] as SystemIDs;

            return systemIDs.ParentID > 0;
        }

        return false;
    }

    private function _getParentSystem(childSysTag:String):ISystemBundle
    {
        var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var sysIdTable : IDataTable = pDatabase.getTable( KOFTableConstants.SYSTEM_IDS );
        var theFindResult : Array = sysIdTable.findByProperty( "Tag", childSysTag );

        if ( theFindResult && theFindResult.length )
        {
            var systemIDs : SystemIDs = theFindResult[ 0 ] as SystemIDs;
            var pBundleCtx : CSystemBundleContext = system.stage.getSystem( CSystemBundleContext ) as CSystemBundleContext;
            return pBundleCtx.getSystemBundle( systemIDs.ParentID );
        }

        return null;
    }

    private function _getParentSystemTag(childSysTag:String):String
    {
        var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var sysIdTable : IDataTable = pDatabase.getTable( KOFTableConstants.SYSTEM_IDS );
        var theFindResult : Array = sysIdTable.findByProperty( "Tag", childSysTag );

        if ( theFindResult && theFindResult.length )
        {
            var systemIDs : SystemIDs = theFindResult[ 0 ] as SystemIDs;
            var parentData:SystemIDs = sysIdTable.findByPrimaryKey(systemIDs.ParentID) as SystemIDs;
            return parentData.Tag;
        }

        return null;
    }

    public function getChildSystemBundleLocaleName( sysTag : String ) : String {
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        if ( pDB ) {
            // Retrieves the SystemBundle config table and binding tag and ID.
            var pTable : IDataTable = pDB.getTable( KOFTableConstants.SYSTEM_IDS ) as IDataTable;
            if ( pTable && sysTag ) {
                var theFindResult : Array = pTable.findByProperty( "Tag", sysTag );
                if ( theFindResult && theFindResult.length )
                {
                    var systemIDs : SystemIDs = theFindResult[ 0 ] as SystemIDs;
                    return systemIDs.Description;
                }
            }
        }

        return null;
    }

    /**
     * 系统是否已开启(独立系统/子系统)
     * @param sysTag
     * @return
     */
    public function isSystemOpen(sysTag:String):Boolean
    {
        var pBundleCtx : CSystemBundleContext = system.stage.getSystem( CSystemBundleContext ) as CSystemBundleContext;
        var pBundle:ISystemBundle;

        if(_isChildSystem(sysTag))
        {
            pBundle = _getParentSystem(sysTag);
            if ( pBundle == null)
            {
                return false;
            }

            return pBundleCtx.getChildSystemBundleState(pBundle, sysTag) == CSystemBundleContext.STATE_STARTED;
        }
        else
        {
            var vBundleID : * = SYSTEM_ID( sysTag );
            pBundle = pBundleCtx.getSystemBundle( vBundleID );
            if ( pBundle == null) // ignored.
            {
                return false;
            }

            return pBundleCtx.getSystemBundleState( pBundle ) == CSystemBundleContext.STATE_STARTED;
        }
    }

    internal function addTrigger( pTrigger : ISwitchingTrigger ) : void {
        if ( !pTrigger )
            return;

        var pTriggers : CSwitchingTriggerBridge = system.getHandler( CSwitchingTriggerBridge ) as CSwitchingTriggerBridge;
        if ( pTriggers ) {
            pTriggers.addTrigger( pTrigger );
        }
    }

    internal function removeTrigger( pTrigger : ISwitchingTrigger ) : void {
        if ( !pTrigger )
            return;

        var pTriggers : CSwitchingTriggerBridge = system.getHandler( CSwitchingTriggerBridge ) as CSwitchingTriggerBridge;
        if ( pTriggers ) {
            pTriggers.removeTrigger( pTrigger );
        }
    }

    internal function addValidator( pValidator : ISwitchingValidation ) : void {
        if ( !pValidator )
            return;

        var pValidators : CSwitchingValidatorSeq = system.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
        if ( pValidators ) {
            pValidators.addValidator( pValidator );
        }
    }

    internal function removeValidator( pValidator : ISwitchingValidation ) : void {
        if ( !pValidator )
            return;

        var pValidators : CSwitchingValidatorSeq = system.getHandler( CSwitchingValidatorSeq ) as CSwitchingValidatorSeq;
        if ( pValidators ) {
            pValidators.removeValidator( pValidator );
        }
    }

}
}
// vim:ft=as3 tw=120 ts=4 sw=4 expandtab

