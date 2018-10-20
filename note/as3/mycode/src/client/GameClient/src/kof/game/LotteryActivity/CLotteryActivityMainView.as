//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/6/28.
 */
package kof.game.LotteryActivity {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;

import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Sprite;
import flash.geom.Point;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import kof.framework.IDatabase;

import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.common.CLogUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.CItemViewHandler;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.shop.CShopSystem;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.table.LotteryShow;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardPackageItemUI;
import kof.ui.master.chouchoule.chouchoule01UI;
import kof.util.CQualityColor;

import morn.core.components.FrameClip;
import morn.core.components.Image;

import morn.core.components.Label;

import morn.core.handlers.Handler;

public class CLotteryActivityMainView extends CTweenViewHandler{
    public function CLotteryActivityMainView() {
        super(false);
    }
    private var m_isInit:Boolean;
    private var m_mainView:chouchoule01UI;
    private var _closeHandler:Handler;
    private var _bCanClick : Boolean = true;
    private var _pLoopTweenMax : TweenMax = null;
    private var offsetX : Number = 97;//两种特效间的x偏移量
    private var offsetY : Number = 11;//两种特效间的y偏移量
    private var _dic : Dictionary = new Dictionary();
    override public function get viewClass() : Array {
        return [chouchoule01UI];
    }
    override protected function get additionalAssets() : Array{
        return ["frameclip_chouchoule.swf"];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }
    override public function dispose() : void {
        super.dispose();

        if( m_mainView )
            m_mainView.remove();
        m_mainView = null;
    }

    //重载初始化界面方法
    override protected function onInitializeView() : Boolean{
        if( !super.onInitializeView() )
            return false;
        if(!m_isInit)
            initialize();
        return m_isInit;
    }

    protected function initialize() : void{
        if( !m_mainView ){
            m_mainView = new chouchoule01UI();
            m_mainView.btn_close.clickHandler = new Handler( _onClose );
            m_mainView.btn_start.clickHandler = new Handler( _startLottery );
            m_mainView.btn_add.clickHandler = new Handler( _addChick );
            m_mainView.btn_add.toolTip = new Handler( _showTips );
            m_isInit = true;
        }
    }

    override protected function updateDisplay() : void{
        super.updateDisplay();
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _addDisplay );
    }

    private function _addDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if ( !m_mainView )  return;
        setTweenData( KOFSysTags.ACTIVITY_LOTTERY );
        showDialog( m_mainView, false );
        (system.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        _showData();
        refreshView();
        var currTime:Number = CTime.getCurrServerTimestamp();
        var leftTime:Number = _manager.endTime-currTime;
        if(leftTime>0)
        {
            var days:int = leftTime/(24*3600*1000);
            m_mainView.num_day1.num = days / 10;
            m_mainView.num_day2.num = days % 10;
            this.schedule(1,_onCountDown);
        }
        else
        {
            m_mainView.num_day1.num = m_mainView.num_day2.num = 0;
            m_mainView.lb_time.text = CLang.LANG_00301;
        }
        for ( var i : int = 1; i <= 10; i++ ) {
            _dic[ i ] = (i - 1) * 36;
            m_mainView[ "light" + i ].visible = false;
        }
    }
    public function removeDisplay() : void {
        if ( this.m_mainView ) {
            closeDialog(_onFinished);
            if ( _pLoopTweenMax ) {
                _pLoopTweenMax.kill();
                _pLoopTweenMax = null;
            }
            this.unschedule(_onCountDown);
        }
    }
    private function _onFinished() : void {
        m_mainView.remove();
    }
    private function _onClose() : void
    {
        if ( this._closeHandler ) {
            this._closeHandler.execute();
        }
    }
    override protected function updateData () : void{
        super.updateData();
    }
    public function get closeHandler() : Handler {
        return _closeHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        _closeHandler = value;
    }
    private function _startLottery() : void
    {
        if(_manager.hasKeyNum < _manager.needKeyNum)//材料不足
        {
            var proStr:String = _netHandler.getGamePromptStr(4001);
            if( proStr != null){
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
            }
            return;
        }
        if ( !_bCanClick )return;
        _netHandler.startLotteryRequest();
        _bCanClick = false;
    }
    private function _addChick() : void
    {
        _showQuickBuyShop(_manager.itemID,1,true);
        CLogUtil.recordLinkLog(system, 10029);
    }
    /**
     * 快速购买
     */
    private function _showQuickBuyShop(itemId:int,buyNum:int = 1,isShowRecharge:Boolean = false):void
    {
        var shopData:CShopItemData = CPlayerCardUtil.getShopData(itemId);
        if(shopData == null)
        {
            (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( CLang.Get("playerCard_swpz"), CMsgAlertHandler.WARNING );
            return;
        }
        var buyViewHandler:CShopBuyViewHandler = system.stage.getSystem(CShopSystem).getHandler(CShopBuyViewHandler) as CShopBuyViewHandler;
        buyViewHandler.show(0,shopData,buyNum,isShowRecharge);
    }
    private function _showTips() : void
    {
        var dateBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var itemData:CItemData = CRewardData.CreateRewardData(_manager.itemID, 1, dateBase);
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,m_mainView.btn_add,[itemData]);
    }
    //显示活动日期
    private function _showData() : void
    {
        var s_theDate : Date = new Date();
        s_theDate.setTime( _manager.startTime );
        var e_theDate : Date = new Date();
        e_theDate.setTime( _manager.endTime );
        var s_month : String = s_theDate.getMonth()+1 >= 10 ? "" + (s_theDate.getMonth()+1) : "0" + (s_theDate.getMonth()+1);
        var s_date  : String = s_theDate.getDate() >= 10    ? "" + (s_theDate.getDate())    : "0" + s_theDate.getDate();
        var e_month : String = e_theDate.getMonth()+1 >= 10 ? "" + (e_theDate.getMonth()+1) : "0" + (e_theDate.getMonth()+1);
        var e_date  : String = e_theDate.getDate() >= 10    ? "" + (e_theDate.getDate())    : "0" + e_theDate.getDate();
        m_mainView.lb_data.text = s_month + "月" + s_date + "日 - " + e_month + "月" + e_date + "日";
    }
    public function refreshView() : void
    {
        if(!m_mainView) return;
        m_mainView.btn_start.disabled = _manager.count == 10 ? true : false;
        m_mainView.lb_total.text = _manager.hasKeyNum + "";
        m_mainView.lb_total.color =  _manager.hasKeyNum >= _manager.needKeyNum ? "0xffffff" : "0xe22c2c";
        m_mainView.lb_total.stroke =  _manager.hasKeyNum >= _manager.needKeyNum ? "0x1e1818" : "0x260601";
        m_mainView.lb_need.text = _manager.needKeyNum + "";
        _bCanClick = true;
        _showReward();//显示奖励
    }
    /**
     * 显示奖励
     */
    private function _showReward() : void
    {
        var itemUI : RewardPackageItemUI;
        var itemLabel : Label;
        var itemData : CItemData;
        var lotteryItem : LotteryShow;
        var mask : Image;
        for(var i : int = 1; i <= 10; i++)
        {
            itemUI = m_mainView["item"+i] as RewardPackageItemUI;
            itemLabel = m_mainView["name"+i] as Label;
            mask = m_mainView["img_got"+i] as Image;
            if(!itemUI || !itemLabel || !mask) continue;

            lotteryItem = _manager.getItemDataByPosition(i);
            if(!lotteryItem) continue;

            itemData = (system.stage.getSystem( CItemSystem ) as CItemSystem).getItem(lotteryItem.itemID);
            if(!itemData) continue;

            itemData.num = lotteryItem.itemNum;
            itemUI.dataSource = itemData;
            (system.stage.getSystem(CItemSystem).getHandler(CItemViewHandler) as CItemViewHandler).renderBigItem(itemUI,0);
            itemLabel.text = HtmlUtil.getHtmlText(itemData.name,CQualityColor.getColorByQuality(itemData.quality-1),16) ;//名称

            var index : int = _manager.rewardStates.indexOf(lotteryItem.position);
            mask.visible = index != -1;//领完了显示已领取
        }
    }
    /**
     * 倒计时
     */
    private function _onCountDown( delta : Number ):void{
        if( m_mainView){
            var currTime:Number = CTime.getCurrServerTimestamp();
            var leftTime:Number = _manager.endTime-currTime;
            if(leftTime>0)
            {
                var days:int = leftTime/(24*3600*1000);
                leftTime = leftTime-days*24*60*60*1000;
                m_mainView.lb_time.text = CTime.toDurTimeString(leftTime);
            }else{
                m_mainView.lb_time.text = CLang.LANG_00301;
                this.unschedule(_onCountDown);
            }
        }
    }
    private var obj:Object = {rotation:0};
    //抽奖响应
    public function showReward() : void {
        if(m_mainView.checkbox.selected)
        {
            _flyItem();
            return;
        }
        m_mainView.eff_runlight.autoPlay = true;
        //var last:int = _manager.lastPosition;
        if(m_mainView && m_mainView.parent){
            obj.rotation = 0;
            _pLoopTweenMax = TweenMax.to( obj, 0.8, {
                rotation : 360,
                repeat : -1,
                ease : Linear.easeNone,
                onUpdate : _updateLight
            } );

            TweenMax.delayedCall( 1.6, function () : void {
                if ( _pLoopTweenMax ) {
                    _pLoopTweenMax.kill();
                    _pLoopTweenMax = null;
                }
                var index:int = _manager.newPosition;
                _selectItem( _dic[ index ]+10 );
            } );
        }
    }

    private function _selectItem( degree : int ) : void {
        TweenMax.to( obj, 1, {
            rotation : degree,
            ease : Linear.easeNone,
            onUpdate : _updateLight,
            onComplete : playFicker
        } );
    }

    private function playFicker():void{
        var _rotationIndex:int = _manager.newPosition;
        var light : FrameClip = m_mainView[ "light" + _rotationIndex ] as FrameClip;
        TweenMax.killTweensOf(light);
        light.skin = "frameclip_kuangjializibao";
        light.x -= offsetX;
        light.y -= offsetY;
        light.visible = true;
        light.alpha = 1;
        light.playFromTo(null,null,new Handler(_flyItem));
    }

    private function _updateLight() : void {
        var degree : int = obj.rotation < 0 ? 360 + obj.rotation : obj.rotation;
        var index : int = degree / 36 + 1;
        if ( index > 10 ) {
            index = 10;
        }
        if ( index == 0 ) {
            index = 1;
        }
        _updateLightVisible( index );
    }

    private function _updateLightVisible( index : int ) : void {
        var light:FrameClip = m_mainView[ "light" + index ] as FrameClip;
        light.visible = true;
        TweenMax.killTweensOf(light);
        TweenMax.to( light, 0.2, {alpha:0.5,onComplete:function():void{
            light.visible = false;
            light.alpha = 1;
        }});
    }

    private function _flyItem() : void {
        var _rotationIndex:int = _manager.newPosition;
        var light : FrameClip = m_mainView[ "light" + _rotationIndex ] as FrameClip;
        light.visible = false;
        light.gotoAndStop(0);
        //特效爆炸结束后恢复第一状态
        if(!m_mainView.checkbox.selected)
        {
            light.skin = "frameclip_wupinkuangguang";
            light.x += offsetX;
            light.y += offsetY;
        }
        var item : RewardPackageItemUI = m_mainView[ "item" + _rotationIndex ] as RewardPackageItemUI;
        CFlyItemUtil.flyItemToBag( item.mc_item, item.localToGlobal( new Point() ), system, _flyCompleteHandler );
    }

    private function _flyCompleteHandler():void {
        (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).isWaitShowQuickUse(false);
        if(_manager.backCounts > 0) _flyKeyItem();
        refreshView();
        m_mainView.eff_runlight.autoPlay = false;
        _bCanClick = true;
    }
    //如果有钥匙返回的话
    private function _flyKeyItem() : void
    {
        var item : RewardPackageItemUI = m_mainView[ "item" + _manager.newPosition ] as RewardPackageItemUI;
        var itemData : CItemData = (system.stage.getSystem( CItemSystem ) as CItemSystem).getItem(_manager.itemID);
        itemData.num = _manager.backCounts;
        item.dataSource = itemData;
        (system.stage.getSystem(CItemSystem).getHandler(CItemViewHandler) as CItemViewHandler).renderBigItem(item,0);
        CFlyItemUtil.flyItemToBag( item.mc_item, item.localToGlobal( new Point() ), system,_callBack );
        function _callBack() : void
        {
            (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).isWaitShowQuickUse(false);
        }
    }
    /**
     * 背包物品更新
     * @param e
     */
    protected function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        if( e.type == CBagEvent.BAG_UPDATE)
        {
            updateTicketState();
        }
    }
    public function updateTicketState():void
    {
        m_mainView.lb_total.text = _manager.hasKeyNum + "";
        m_mainView.lb_total.color =  _manager.hasKeyNum >= _manager.needKeyNum ? "0xffffff" : "0xe22c2c";
        m_mainView.lb_total.stroke =  _manager.hasKeyNum >= _manager.needKeyNum ? "0x1e1818" : "0x260601";
    }
    private function get _netHandler() : CLotteryActivityNetHander
    {
        return system.getBean(CLotteryActivityNetHander) as CLotteryActivityNetHander;
    }
    private function get _manager() : CLotteryActivityManager
    {
        return system.getBean(CLotteryActivityManager) as CLotteryActivityManager;
    }
}
}
