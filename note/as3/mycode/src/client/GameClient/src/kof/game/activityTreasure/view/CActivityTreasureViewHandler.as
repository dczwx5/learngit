//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.activityTreasure.view {

import QFLib.Utils.StringUtil;

import flash.events.MouseEvent;

import kof.game.KOFSysTags;
import kof.game.activityTreasure.CActivityTreasureEvent;
import kof.game.activityTreasure.CActivityTreasureHandler;
import kof.game.activityTreasure.CActivityTreasureManager;
import kof.game.activityTreasure.data.CDartsPointData;
import kof.game.activityTreasure.data.CTreasureBoxData;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.rewardTips.CRewardTips;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.table.ActivityTreasureBox;
import kof.table.ActivityTreasureRepository;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.ActivityTreasure.ActivityTreasureUI;
import kof.ui.master.ActivityTreasure.BlessingBagUI;
import kof.ui.master.ActivityTreasure.DartsBoardUI;

import morn.core.components.Clip;
import morn.core.handlers.Handler;

public class CActivityTreasureViewHandler extends CTweenViewHandler {

    private var m_activityTreasureUI : ActivityTreasureUI;
    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean = false;

    /**
     * 当前选择的靶点实例
     */
    private var selectedDartsBoardItem : DartsBoardUI = null;
    /**
     * 当前是否有苦无动画正在播放（如果是，则拒绝进行投射苦无操作）
     */
    private var isDartsAnimationPlaying : Boolean = false;

    public function CActivityTreasureViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array {
        return [ ActivityTreasureUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_activityTreasureUI ) {
                m_activityTreasureUI = new ActivityTreasureUI();
                m_activityTreasureUI.closeHandler = new Handler( _onClose );
                m_activityTreasureUI.addDartsBtn.clickHandler = new Handler( onAddDartsBtnClick );
                m_activityTreasureUI.rewardPreviewBtn.clickHandler = new Handler( onRewardPreviewBtnClick );

                m_activityTreasureUI.blessingBagHList.renderHandler = new Handler( blessingBagItemRender );
                m_activityTreasureUI.blessingBagVList.renderHandler = new Handler( blessingBagItemRender );
                m_activityTreasureUI.dartsBoardList.renderHandler = new Handler( dartsBoardItemRender );

                m_bViewInitialized = true;
            }
        }
        return m_bViewInitialized;
    }

    private function _addEventListeners() : void {

        system.addEventListener( CActivityTreasureEvent.DigTreasureActivityDataResponse, updateView );
        system.addEventListener( CActivityTreasureEvent.DigTreasureResponse, onDigTreasureResult );
        system.addEventListener( CActivityTreasureEvent.OpenDigTreasureBoxResponse, onOpenTreasureBoxResult );
        system.addEventListener( CActivityTreasureEvent.DigTreasureActivityDataUpdateEvent, updateView );

    }

    private function _removeEventListeners() : void {

        if ( m_activityTreasureUI.dartsBoardList.dataSource ) {
            var len : int = m_activityTreasureUI.dartsBoardList.dataSource.length;
            for ( var i : int = 0; i < len; i++ ) {
                var item : DartsBoardUI = m_activityTreasureUI.dartsBoardList.getCell( i ) as DartsBoardUI;
                item.removeEventListener( MouseEvent.CLICK, ondartsBoradItemClick );
                item.removeEventListener( MouseEvent.MOUSE_OVER, ondartsBoradItemOver );
                item.removeEventListener( MouseEvent.MOUSE_OUT, ondartsBoradItemOut );
            }
        }

        system.removeEventListener( CActivityTreasureEvent.DigTreasureActivityDataResponse, updateView );
        system.removeEventListener( CActivityTreasureEvent.DigTreasureResponse, onDigTreasureResult );
        system.removeEventListener( CActivityTreasureEvent.OpenDigTreasureBoxResponse, onOpenTreasureBoxResult );
        system.removeEventListener( CActivityTreasureEvent.DigTreasureActivityDataUpdateEvent, updateView );
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
        setTweenData( KOFSysTags.ACTIVITY_TREASURE );
        showDialog( m_activityTreasureUI, false, _addToDisplayB );
    }

    private function _addToDisplayB() : void {
        if ( m_activityTreasureUI ) {
            _addEventListeners();

            //向服务器请求一次相关数据
            var activityId : int = activityTreasureManager.curActivityId;
            (system.getBean( CActivityTreasureHandler ) as CActivityTreasureHandler).onDigTreasureActivityDataRequest( activityId );
        }
    }

    private function onDigTreasureResult( event : CActivityTreasureEvent = null ) : void {
        var awardId : int = event.data as int;
        //播放动画
        this.playDartsAnimation( awardId );
    }

    private function onOpenTreasureBoxResult( event : CActivityTreasureEvent = null ) : void {
        var boxId : int = event.data as int;

        //奖励物品
        var boxCfgInfo : ActivityTreasureBox = activityTreasureManager.getActivityTreasureBoxCfgInfoById( boxId );
        if ( boxCfgInfo ) {
            //构造奖励List
            var rewardList : Array = [];
            for ( var j : int = 0; j < boxCfgInfo.itemID.length; j++ ) {
                rewardList.push( {ID : boxCfgInfo.itemID[ j ], num : boxCfgInfo.itemNumber[ j ]} );
            }
            var rewardListData : CRewardListData = CRewardUtil.createByList( system.stage, rewardList );
            //显现奖励面板
            (system.stage.getSystem( CItemSystem ) as CItemSystem).showRewardFull( rewardListData );
        }
    }


    private function updateView( event : CActivityTreasureEvent = null ) : void {
        //苦无数量
        m_activityTreasureUI.dartsNum.num = activityTreasureManager.dartsNum;
        //活动时间
        m_activityTreasureUI.timeLabel.text = activityTreasureManager.getMonthDateTimeByTime( activityTreasureManager.startTime ) + "至" + activityTreasureManager.getMonthDateTimeByTime( activityTreasureManager.endTime );
        //福袋
        m_activityTreasureUI.blessingBagHList.dataSource = activityTreasureManager.getHTreasureBoxArr();
        m_activityTreasureUI.blessingBagVList.dataSource = activityTreasureManager.getVTreasureBoxArr();
        //苦无靶子
        m_activityTreasureUI.dartsBoardList.dataSource = activityTreasureManager.dartsBoardStateArr;
    }


    private function blessingBagItemRender( item : BlessingBagUI, index : int ) : void {
        if ( item == null || item.dataSource == null )return;

        var data : CTreasureBoxData = item.dataSource as CTreasureBoxData;
        if ( data ) {
            item.blessingBag.index = data.m_boxState == 2 ? 1 : 0;
            item.blessingBagBg.visible = data.m_boxState == 1;

            item.blessingBagBg.mouseChildren = false;
            item.blessingBagBg.mouseEnabled = false;

            //福袋tips
            var boxCfgInfo : ActivityTreasureBox = activityTreasureManager.getActivityTreasureBoxCfgInfoById( data.m_boxId );
            if ( boxCfgInfo ) {
                var status : int;
                if ( data.m_boxState == 0 ) {
                    status = CRewardTips.REWARD_STATUS_OTHER_1;
                }
                else if ( data.m_boxState == 1 ) {
                    status = CRewardTips.REWARD_STATUS_CAN_REWARD;
                }
                else if ( data.m_boxState == 2 ) {
                    status = CRewardTips.REWARD_STATUS_HAS_REWARD;
                }
                //构造描述文本
                var describeStr : String;
                if ( boxCfgInfo.colNum != 0 && boxCfgInfo.rowNum == 0 ) {
                    describeStr = StringUtil.format( "击碎第{0}列所有靶子可领取", boxCfgInfo.colNum );
                }
                else if ( boxCfgInfo.colNum == 0 && boxCfgInfo.rowNum != 0 ) {
                    describeStr = StringUtil.format( "击碎第{0}行所有靶子可领取", boxCfgInfo.rowNum );
                }
                //构造奖励物品
                var rewardArr : Array = [];
                for ( var i : int = 0; i < boxCfgInfo.itemID.length; i++ ) {
                    var obj : Object = {ID : boxCfgInfo.itemID[ i ], num : boxCfgInfo.itemNumber[ i ]};
                    rewardArr.push( obj );
                }
                //将奖励物品数组赋值给tips对象的dataSource
                item.blessingBag.dataSource = rewardArr;
                item.blessingBag.toolTip = new Handler( itemSystem.showRewardTips, [ item.blessingBag, [ [ describeStr ], status, 1 ] ] );
            }

            if ( data.m_boxState == 1 ) {
                item.blessingBag.addEventListener( MouseEvent.CLICK, onBlessingBagClick );
            }
            else {
                item.blessingBag.removeEventListener( MouseEvent.CLICK, onBlessingBagClick );
            }
        }
    }

    /**
     * 苦无靶子Render
     * @param item
     * @param index
     */
    private function dartsBoardItemRender( item : DartsBoardUI, index : int ) : void {
        if ( item == null || item.dataSource == null )return;

        item.addEventListener( MouseEvent.CLICK, ondartsBoradItemClick );
        item.addEventListener( MouseEvent.MOUSE_OVER, ondartsBoradItemOver );
        item.addEventListener( MouseEvent.MOUSE_OUT, ondartsBoradItemOut );

        var data : CDartsPointData = item.dataSource as CDartsPointData;
        if ( data.m_state == 0 ) {
            item.dartsState.index = 0;
        }
        else if ( data.m_state == 1 ) {
            item.dartsState.index = 2;
        }
    }

    private function ondartsBoradItemOut( event : MouseEvent ) : void {
        var item : DartsBoardUI = event.currentTarget as DartsBoardUI;
        var data : CDartsPointData = item.dataSource as CDartsPointData;
        if ( data.m_state == 0 ) {
            item.dartsState.index = 0;
        }
    }

    private function ondartsBoradItemOver( event : MouseEvent ) : void {
        var item : DartsBoardUI = event.currentTarget as DartsBoardUI;
        var data : CDartsPointData = item.dataSource as CDartsPointData;
        if ( data.m_state == 0 ) {
            item.dartsState.index = 1;
        }
    }

    private function ondartsBoradItemClick( event : MouseEvent ) : void {
        var item : DartsBoardUI = event.currentTarget as DartsBoardUI;
        var data : CDartsPointData = item.dataSource as CDartsPointData;
        if ( data.m_state == 0 && this.isDartsAnimationPlaying == false ) {
            if ( activityTreasureManager.dartsNum > 0 ) {
                this.selectedDartsBoardItem = item;
                this.isDartsAnimationPlaying = true;
                //向服务器请求投射苦无
                (system.getBean( CActivityTreasureHandler ) as CActivityTreasureHandler).onDigTreasureRequest( data.m_id );
            }
            else {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( "苦无不足", CMsgAlertHandler.NORMAL );
            }
        }
        else if ( data.m_state == 1 ) {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( "这里的奖励已经被获取啦！换一个吧", CMsgAlertHandler.NORMAL );
        }
    }

    /**
     * 播放苦无动画，并在播放完成后根据指定的奖励Id安排奖励物品飞入背包
     * @param awardId
     */
    private function playDartsAnimation( awardId : int ) : void {
        if ( this.selectedDartsBoardItem ) {
            this.selectedDartsBoardItem.dartsState.visible = false;
            this.selectedDartsBoardItem.dartsAnimation.visible = true;
            this.selectedDartsBoardItem.dartsAnimation.playFromTo( null, null, new Handler( onDartsAnimationComplete, [ awardId ] ) );
        }
    }

    private function onDartsAnimationComplete( awardId : int ) : void {
        if ( this.selectedDartsBoardItem ) {
            this.selectedDartsBoardItem.dartsState.visible = true;
            this.selectedDartsBoardItem.dartsState.index = 2;
            this.selectedDartsBoardItem.dartsAnimation.visible = false;

            //奖励物品
            var awardCfgInfo : ActivityTreasureRepository = activityTreasureManager.getActivityTreasureRepositoryCfgInfoById( awardId );
            if ( awardCfgInfo ) {
                //构造奖励List
                var rewardList : Array = [];
                var rewardItem0 : Object = {ID : awardCfgInfo.itemId, num : awardCfgInfo.itemNum};
                rewardList.push( rewardItem0 );
                var rewardListData : CRewardListData = CRewardUtil.createByList( system.stage, rewardList );
                //显现奖励面板
                (system.stage.getSystem( CItemSystem ) as CItemSystem).showRewardFull( rewardListData );
            }

            this.selectedDartsBoardItem = null;
            this.isDartsAnimationPlaying = false;
        }
    }

    private function onBlessingBagClick( event : MouseEvent ) : void {
        var clip : Clip = event.currentTarget as Clip;
        var item : BlessingBagUI = clip.parent as BlessingBagUI;
        var data : CTreasureBoxData = item.dataSource as CTreasureBoxData;
        //向服务器请求打开福袋
        if ( data.m_boxState == 1 ) {
            (system.getBean( CActivityTreasureHandler ) as CActivityTreasureHandler).onOpenDigTreasureBoxRequest( data.m_boxId );
        }
    }

    public function removeDisplay() : void {
        closeDialog( _removeDisplayB );
    }

    private function _removeDisplayB() : void {
        if ( m_activityTreasureUI ) {
            _removeEventListeners();
        }
    }

    private function onAddDartsBtnClick() : void {
        var taskViewHandler : CActivityTreasureTaskViewHandler = system.getBean( CActivityTreasureTaskViewHandler ) as CActivityTreasureTaskViewHandler;
        taskViewHandler.addDisplay();
    }

    private function onRewardPreviewBtnClick() : void {
        var rewardPreviewViewHandler : CActivityTreasureRewardPreviewViewHandler = system.getBean( CActivityTreasureRewardPreviewViewHandler ) as CActivityTreasureRewardPreviewViewHandler;
        rewardPreviewViewHandler.addDisplay();
    }

    private function _onClose( type : String ) : void {
        if ( m_activityTreasureUI && !m_activityTreasureUI.parent )
            return;
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function get itemSystem() : CItemSystem {
        return system.stage.getSystem( CItemSystem ) as CItemSystem;
    }

    private function get activityTreasureManager() : CActivityTreasureManager {
        return (system.getBean( CActivityTreasureManager ) as CActivityTreasureManager);
    }
}
}
