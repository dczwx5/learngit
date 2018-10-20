//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/7/31.
 */
package kof.game.activityHall {

import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

import kof.game.KOFSysTags;
import kof.game.activityHall.activeTask.CActiveTaskView;
import kof.game.activityHall.activityPreview.CActivityPreviewHandler;
import kof.game.activityHall.chargeActivity.CTotalChargeActivityView;
import kof.game.activityHall.consumeActivity.CTotalConsumeActivityView;
import kof.game.activityHall.data.CActivityHallActivityInfo;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.discountShop.CDiscountShopActivityView;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.common.CLogUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.table.ActivityPreviewData;
import kof.ui.master.ActivityHall.ActivityHallUI;
import kof.ui.master.shop.ShopBuyUI;

import morn.core.components.Button;
import morn.core.handlers.Handler;

public class CActivityHallViewHandler extends CTweenViewHandler {

    private var m_activityHallUI : ActivityHallUI;
    private var m_buttonList : Vector.<Button>;
//    private var m_consumeView : CTotalConsumeActivityView;
//    private var m_chargeView : CTotalChargeActivityView;
//    private var m_discountShopView : CDiscountShopActivityView;
    private var m_activeTaskView : CActiveTaskView;
    private var m_previewHandler : CActivityPreviewHandler;
    private var m_openActivityList : Vector.<CActivityHallActivityInfo>;
    private var m_openActivityAmount : int = 0;
    private var m_selectedActivityType : int = -1;

    private var m_pTimer : Timer;
    private var m_buttonAmount : int;
    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;
    public function CActivityHallViewHandler() {
        m_pTimer = new Timer( 1000 );
    }

    override public function get viewClass() : Array {
        return [ ActivityHallUI, ShopBuyUI ];
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_bViewInitialized ) {
            this.initialize();
        }
        return m_bViewInitialized;
    }

    protected function initialize() : void {
        if ( !m_bViewInitialized ) {
            if ( !m_activityHallUI ) {
                m_activityHallUI = new ActivityHallUI();
                m_activityHallUI.helpBtn.visible = false;
                m_activityHallUI.closeBtn.clickHandler = new Handler( _close );

                m_buttonList = new Vector.<Button>();
                var button : Button;
                m_buttonAmount = m_activityHallUI.buttonBox.numChildren;
                for ( var i : int = 0; i < m_buttonAmount; i++ ) {
                    button = m_activityHallUI.buttonBox.getChildAt( i ) as Button;
                    if ( button ) {
                        button.clickHandler = new Handler( onButtonClick, [ parseInt( button.name ) ] );
                        m_buttonList.push( button );
                    }
                }

//                m_consumeView = new CTotalConsumeActivityView( system, m_activityHallUI.consume );//累计消费界面
//                m_chargeView = new CTotalChargeActivityView( system, m_activityHallUI.chargeUi );//累计充值界面
//                m_discountShopView = new CDiscountShopActivityView( system, m_activityHallUI.discountShop );//特惠商店
                m_activeTaskView = new CActiveTaskView( system, m_activityHallUI.activeTaskUI );//活跃任务
                m_previewHandler = new CActivityPreviewHandler( system, m_activityHallUI.activityPreviewUI);//活动预览
                m_bViewInitialized = true;
            }
        }
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        }
        else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        if ( m_activityHallUI ) {
//            uiCanvas.addDialog( m_activityHallUI );
            setTweenData( KOFSysTags.ACTIVITY_HALL );
            showDialog( m_activityHallUI );

            updateOpenedActivityList();
            system.addEventListener( CActivityHallEvent.ActivityHallActivityStateChanged, updateOpenedActivityList );

            m_pTimer.addEventListener( TimerEvent.TIMER, _onTimerEventHandler );
            m_pTimer.start();
        }
    }

    private function _onTimerEventHandler( e : TimerEvent ) : void {
//        m_consumeView.updateCDTime();
//        m_chargeView.updateCDTime();
//        m_discountShopView.updateCDTime();
        m_activeTaskView.updateCDTime();
        m_previewHandler.updateCDTime();
    }

    //判断可开启活动列表
    private function updateOpenedActivityList( event : CActivityHallEvent = null ) : void {
        _clearView();
        //显示开启的活动按钮标签
        m_openActivityList = activityHallDataManager.getOpenedActivityList();
        m_openActivityAmount = m_openActivityList.length;
        var previewData : Array = activityHallDataManager.previewDataArray;
        //没有可开启的活动
        if ( m_openActivityAmount == 0 && previewData.length == 0) {
            _close();
            return;
        }

        var hasSelectedType : Boolean = false;
        var activityType : int;
        var btn_show_list : Array = [];
        for ( var i : int = 0; i < m_buttonList.length; i++ )
        {
            activityType = parseInt( m_buttonList[ i ].name );
            //特殊处理，如果页签id为999且预览活动数据中有活动的话，则添加btn
            if(activityType == CActivityHallActivityType.ACTIVITY_PREVIEW && previewData.length > 0)
            {
                m_activityHallUI.buttonBox.addElement( m_buttonList[ i ], 0, activityType );
                if(m_selectedActivityType == activityType) hasSelectedType = true;
                btn_show_list.push(activityType);
                break;
            }
            for ( var j : int = 0; j < m_openActivityAmount; j++ )
            {
                if ( activityType == m_openActivityList[ j ].table.type )
                {
                    m_activityHallUI.buttonBox.addElement( m_buttonList[ i ], 0, activityType );
                    btn_show_list.push(activityType);
                    if ( !hasSelectedType && m_openActivityList[ j ].table.type == m_selectedActivityType )
                    {
                        //上次选择的活动还开启着
                        hasSelectedType = true;
                    }
                }
            }
        }
        btn_show_list.sort();
        if ( hasSelectedType ) {
            onButtonClick( m_selectedActivityType );
        }
        else {
            //上一次选择的活动已关闭，显示第一个界面
            onButtonClick( btn_show_list[0] );//这里要加保护
        }

        var hasChargeReward : Boolean = activityHallDataManager.hasTotalChargeReward();
        var hasConsumeReward : Boolean = activityHallDataManager.hasConsumeReward();
        var hasActiveTaskReward : Boolean = activityHallDataManager.hasActiveTaskReward();
        var isFirstOpenPreview : Boolean = activityHallDataManager.isFirstOpenPreview;
        updateRedPoint( hasChargeReward, hasConsumeReward, hasActiveTaskReward,isFirstOpenPreview );
    }

    private function onButtonClick( activityType : int ) : void {
        m_selectedActivityType = activityType;

        var activityInfo : CActivityHallActivityInfo;
        var buttonAmount : int = m_buttonList.length;
        for ( var i : int = 0; i < buttonAmount; i++ ) {
            if ( m_buttonList[ i ].name == activityType.toString() ) {
                m_buttonList[ i ].selected = true;
            }
            else {
                m_buttonList[ i ].selected = false;
            }
        }
        for ( i = 0; i < m_openActivityAmount; i++ ) {
            if ( m_openActivityList[ i ].table.type == m_selectedActivityType ) {
                activityInfo = m_openActivityList[ i ];
                break;
            }

        }

//        m_consumeView.removeDisplay();
//        m_chargeView.removeDisplay();
//        m_discountShopView.removeDisplay();
        m_activeTaskView.removeDisplay();
        m_previewHandler.removeDisplay();
        switch ( activityType ) {
            case CActivityHallActivityType.CHARGE:
//                m_chargeView.addDisplay( activityInfo );
                break;
            case CActivityHallActivityType.CONSUME:
//                m_consumeView.addDisplay( activityInfo );
                break;
            case CActivityHallActivityType.DISCOUNT:
//                m_discountShopView.addDisplay( activityInfo );
                CLogUtil.recordLinkLog(system, 10025);
                break;
            case CActivityHallActivityType.ACTIVE_TASK:
                m_activeTaskView.addDisplay( activityInfo );
                break;
            case CActivityHallActivityType.ACTIVITY_PREVIEW://如果是活动预览，就整合所有可以显示的活动
                var dataArr : Array = activityHallDataManager.previewDataArray;
                m_previewHandler.addDisplay(dataArr);
                break;
            default:
                break;
        }
    }

    public function updateRedPoint( hasChargeReward : Boolean, hasConsumeReward : Boolean, hasActiveTaskReward : Boolean,isFirstOpenPreview : Boolean ) : void {
        if ( m_activityHallUI == null ) return;
        var buttonNum : int = m_activityHallUI.buttonBox.numChildren;
        var items : Array = [];
        for ( var i : int = 0, n : int = buttonNum; i < n; i++ ) {
            var item : Button = m_activityHallUI.buttonBox.getChildAt( i ) as Button;
            if ( item ) {
                items.push( item );
            }
        }
        items.sortOn( [ "y" ], Array.NUMERIC );

        var btn : Button;
        for ( var j : int = 0; j < m_buttonAmount; j++ ) {
            btn = j >= items.length ? null : items[ j ];
            if ( btn && btn.name == CActivityHallActivityType.CHARGE + "" ) {
                m_activityHallUI.getChildByName( "redpoint" + j ).visible = hasChargeReward;
            } else if ( btn && btn.name == CActivityHallActivityType.CONSUME + "" ) {
                m_activityHallUI.getChildByName( "redpoint" + j ).visible = hasConsumeReward;
            }
            else if ( btn && btn.name == CActivityHallActivityType.ACTIVE_TASK + "" ) {
                m_activityHallUI.getChildByName( "redpoint" + j ).visible = hasActiveTaskReward;
            }
            else if(btn && btn.name == CActivityHallActivityType.ACTIVITY_PREVIEW + "" )
            {
                m_activityHallUI.getChildByName( "redpoint" + j ).visible = isFirstOpenPreview;
            }
            else {
                m_activityHallUI.getChildByName( "redpoint" + j ).visible = false;
            }
        }
    }

    public function removeDisplay() : void {
        closeDialog( _removeDisplayB );
    }

    private function _removeDisplayB() : void {
        if ( m_activityHallUI && m_activityHallUI.parent ) {
            _clearView();
            system.removeEventListener( CActivityHallEvent.ActivityHallActivityStateChanged, updateOpenedActivityList );
        }
        m_pTimer.removeEventListener( TimerEvent.TIMER, _onTimerEventHandler );
        m_pTimer.stop();
        m_pTimer.reset();
    }

    private function _clearView() : void {
        m_activityHallUI.buttonBox.removeAllChild();
        for ( var i : int = 0; i < m_buttonAmount; i++ ) {
            m_activityHallUI.getChildByName( "redpoint" + i ).visible = false;
        }
//        m_consumeView.removeDisplay();
//        m_chargeView.removeDisplay();
//        m_discountShopView.removeDisplay();
        m_activeTaskView.removeDisplay();
        m_previewHandler.removeDisplay();
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function _close() : void {
        if ( m_pCloseHandler ) {
            m_pCloseHandler.execute();
        }
    }

    private function get activityHallDataManager() : CActivityHallDataManager {
        return system.getBean( CActivityHallDataManager ) as CActivityHallDataManager;
    }
}
}
