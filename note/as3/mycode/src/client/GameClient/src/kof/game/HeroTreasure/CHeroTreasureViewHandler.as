//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-05-28.
 */
package kof.game.HeroTreasure {

import QFLib.Foundation.CTime;
import QFLib.Utils.ArrayUtil;

import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.geom.Point;
import flash.utils.Dictionary;

import kof.SYSTEM_ID;

import kof.data.CDataTable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;

import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CLogUtil;
import kof.game.common.hero.CHeroSpriteUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.itemGetPath.CItemTips;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.table.Item;
import kof.table.TreasureActivityInfo;
import kof.table.TreasureCardPool;
import kof.table.TreasureDisplayItem;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardPackageItemUI;
import kof.ui.master.HeroTreasure.HeroTreasureUI;

import morn.core.components.Component;
import morn.core.components.FrameClip;

import morn.core.handlers.Handler;

/**
 *@author Demi.Liu
 *@data 2018-05-28
 */
public class CHeroTreasureViewHandler extends CTweenViewHandler {

    private var viewUI : HeroTreasureUI;

    private var m_bViewInitialized : Boolean;

    private var m_pCloseHandler : Handler;

    private var _bCanClick : Boolean = true;

    private var _pLoopTweenMax : TweenMax = null;

    private var _itemTips:CItemTips;

    private var m_startTime:Number = 0.0;

    private var m_endTime:Number = 0.0;

    private var _dic : Dictionary = new Dictionary();

    private var treasureDisplayItem:TreasureActivityInfo;

    public function CHeroTreasureViewHandler() {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        viewUI = null;
    }

    override public function get viewClass() : Array {
        return [ HeroTreasureUI ];
    }

    override protected function get additionalAssets():Array {
        return ["frameclip_item2.swf","frameclip_starAdvance.swf","frameclip_ficker.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !viewUI ) {
                viewUI = new HeroTreasureUI();
                viewUI.btn_one.clickHandler = new Handler( _onOneLotteryHandler );
                viewUI.btn_ten.clickHandler = new Handler( _onTenotteryHandler );
                viewUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;

                viewUI.img_mask.cacheAsBitmap = true;
                viewUI.img_imgIcon.cacheAsBitmap = true;
                viewUI.img_imgIcon.mask = viewUI.img_mask;
                _itemTips = new CItemTips();

                treasureDisplayItem = _getTreasureActivityInfoData(CHeroTreasureManager.HREOTREASUREACTIVITYINFO_ID);

                var obj:Object = {num:treasureDisplayItem.absoluteTimes};
                viewUI.label_hint.text = CLang.Get("heroTreasure_tips",obj);

                var itemTable : Item = _getItemTableData(treasureDisplayItem.propsId);
                var itemData : CItemData = _getItemData( itemTable.ID );
                var itemUI : RewardItemUI = viewUI.rewardItem;
                itemUI.num_lable.visible = false;
                itemUI.bg_clip.index = itemTable.quality;
                itemUI.icon_image.url = itemTable.bigiconURL + ".png";
                itemUI.box_eff.visible = itemTable.effect;
                itemUI.clip_eff.autoPlay = itemTable.effect;
                itemUI.dataSource = itemData;
                itemUI.toolTip = new Handler( _addTips, [itemUI] );
            }
        }
        return m_bViewInitialized;
    }

    private function _addEventlist():void{
        system.addEventListener(CHeroTreasureEvent.drawTreasureResponse, _onDrawTreasureResponseHandler);
        system.stage.getSystem( CBagSystem ).addEventListener( CBagEvent.BAG_UPDATE, _updateView );
    }

    private function _removeEventList():void{
        system.removeEventListener(CHeroTreasureEvent.drawTreasureResponse, _onDrawTreasureResponseHandler);
        system.stage.getSystem( CBagSystem ).removeEventListener( CBagEvent.BAG_UPDATE, _updateView );
    }

    private function _onDrawTreasureResponseHandler(e:CHeroTreasureEvent):void{
        if(_heroTreasureManager.poolId == CHeroTreasureManager.POOTYPE_THREE){
            _showTenReward();
        }else{
            _showOneReward();
        }
    }

    /**
     * 倒计时
     */
    private function _onCountDown(delta : Number):void{
        if( viewUI && m_endTime > 0){
            var currTime:Number = CTime.getCurrServerTimestamp();
            var leftTime:Number = m_endTime - currTime;

            if(leftTime > 0)
            {
                var days:int = leftTime/(24*3600*1000);
                viewUI.clip_time.num = days;
                leftTime = leftTime - days*24*60*60*1000;
                viewUI.clip_time.visible = true;
                viewUI.label_time.text = CTime.toDurTimeString(leftTime);
            }else{
                viewUI.clip_time.num = 0;
//                viewUI.clip_time.visible = false;
                viewUI.label_time.text = CLang.LANG_00301;
                this.unschedule(_onCountDown);
            }
        }
    }

    private function isInActivityTime():Boolean{
        var currTime:Number = CTime.getCurrServerTimestamp();
        var leftTime:Number = m_endTime - currTime;
        if(leftTime > 0)
        {
            return true;
        }

        _showTipInfo(CLang.Get("playerCard_wzhdsj"),CMsgAlertHandler.WARNING);
        return false;
    }

    /**轮盘奖励物品初始化*/
    private function _initItemView() : void {
        //奖励物品
        for ( var j : int = 1; j <= 16; j++ ) {
            var treasureDisplayItem:TreasureDisplayItem = _getTreasureItemTableData(j);
            var itemTable : Item = _getItemTableData(treasureDisplayItem.propsId);
            var itemData : CItemData = _getItemData( itemTable.ID );

            var rewardItem : RewardPackageItemUI = viewUI[ "item" + j ];
            rewardItem.mouseChildren = false;
            rewardItem.mouseEnabled = true;
            rewardItem.dataSource = itemData;
            rewardItem.toolTip = new Handler( _addTips, [rewardItem] );
            if ( null != itemData ) {
                rewardItem.mc_item.txt_num.text = itemData.num > 1 ? itemData.num.toString() : "";
                rewardItem.mc_item.img.url = itemData.iconBig;
                rewardItem.mc_item.clip_bg.index = itemData.quality;
                rewardItem.mc_item.box_effect.visible = itemData.effect;
                if ( CItemUtil.isHeroItem( itemData ) ) {
                    var heroId : int = int( itemData.ID.toString().slice( 5, 8 ) );
                    var heroData : CPlayerHeroData = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.heroList.createHero( heroId );
                    if ( heroData ) {
                        var heroStar : int = int( itemData.itemRecord.param2 );
                        heroData.updateDataByData( {star : heroStar} );
                    }
                    rewardItem.list_star.visible = true;
                    rewardItem.list_star.repeatX = 5;
                    rewardItem.list_star.dataSource = new Array( heroData.star );
                    rewardItem.list_star.x = (80 - heroData.star * 13)/2;
                    rewardItem.clip_intelligence.visible = true;
                    rewardItem.clip_intelligence.index = heroData.qualityBaseType;
                    rewardItem.mc_item.txt_num.text = "";
                }
            }
        }

        for ( var i : int = 1; i <= 16; i++ ) {
            _dic[ i ] = (i - 1) * 22.5;
            viewUI[ "light" + i ].visible = false;
        }

        _updateView();
        _bCanClick = true;
    }

    private function _addTips(item:Component) : void {
        var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
        itemSystem.addTips(CItemTipsView, item);
    }

    /**活动宣传格斗家*/
    private function _initAdvertisingView():void{
        var heroData:CPlayerHeroData = _getPlayerData(treasureDisplayItem.picId);

        //格斗家形象
        var clip:CCharacterFrameClip = viewUI.box_role.getChildAt(0) as CCharacterFrameClip;
        CHeroSpriteUtil.setSkin( system, clip, heroData, false);
        viewUI.img_imgIcon.url = CPlayerPath.getPeakUIHeroFacePath(heroData.prototypeID);
        viewUI.img_name.url = CPlayerPath.getUIHeroNamePath(heroData.prototypeID);
    }

    private function _updateView(e:CBagEvent = null):void{
        viewUI.img_itemIcon.visible = false;
        viewUI.img_oneIcon.visible = false;
        //抽奖花费
        var treasureCard:TreasureCardPool = _getTreasureBuyPriceTableData(CHeroTreasureManager.POOTYPE_ONE);
        var bgData : CBagData = _bagManager.getBagItemByUid(treasureCard.costItemId);
        var currValue:int = bgData == null ? 0 : bgData.num;
        if(bgData && currValue >= treasureCard.cost){
            viewUI.img_itemIcon.visible = true;
            viewUI.img_itemIcon.url = bgData.item.smalliconURL + ".png";
            viewUI.label_one.text = treasureCard.cost.toString();
        }else
        {
            viewUI.img_oneIcon.visible = true;
            treasureCard  = _getTreasureBuyPriceTableData(CHeroTreasureManager.POOTYPE_TWO);
            viewUI.label_one.text = treasureCard.cost.toString();
        }
        viewUI.label_ten.text =  _getTreasureBuyPriceTableData(CHeroTreasureManager.POOTYPE_THREE).cost.toString();

        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var heroDatas:Array = playerData.heroList.list;
        var v1Index:int = ArrayUtil.findItemByProp(heroDatas, "prototypeID", treasureDisplayItem.picId);
        var heroData:CPlayerHeroData;
        if(v1Index != -1){//拥有
            heroData = playerData.heroList.list[v1Index];
        }else{
            heroData = _getPlayerData(treasureDisplayItem.picId);
        }
        if(heroData.hasData)
        {
            var progressValue : Number = 1;
            var piceData : CBagData = _bagManager.getBagItemByUid(heroData.pieceID);
            var currValueNew:int = piceData == null ? 0 : piceData.num;
            var totalValue:int = heroData.nextStarPieceCost;

            if(heroData.star >= CPlayerHeroData.MAX_STAR_LEVEL)//满星
            {
                progressValue = 1;
                viewUI.progress_star.label = CLang.Get("highStarLv");
            }
            else
            {
                if(totalValue > 0)
                {
                    progressValue = currValueNew / totalValue;
                    viewUI.progress_star.label = currValueNew + "/" + totalValue;
                }
                else
                {
                    viewUI.progress_star.label = "";
                }
            }

            viewUI.progress_star.value = progressValue;
        }
        else
        {
            viewUI.progress_star.value = heroData.pieceRate;
            viewUI.progress_star.label = CLang.Get("common_v1_v2", {v1:heroData.currentPieceCount, v2:heroData.hireNeedPieceCount});
        }
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }

        if ( _pLoopTweenMax ) {
            _pLoopTweenMax.kill();
            _pLoopTweenMax = null;
        }
        unschedule( _onCountDown );
        _removeEventList();
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
        _heroTreasureHandler.onTreasureOpenRequest();
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

    public function removeDisplay() : void {
        closeDialog();
    }

    private function _addToDisplay():void{
        if ( viewUI && !viewUI.parent ) {
            setTweenData(KOFSysTags.HERO_TREASURE, new Point(950, 600));
            showDialog(viewUI);

            m_startTime = _heroTreasureManager.startTime;
            m_endTime = _heroTreasureManager.endTime;
        }

        _initItemView();
        _initAdvertisingView();
        _addEventlist();
        schedule( 1 , _onCountDown );
    }

    public function addToTOP():void{
        if ( viewUI && viewUI.parent ) {
            setTweenData(KOFSysTags.RED_PACKET);
            showDialog(viewUI);
        }
    }

    //点击十连抽
    private function _onTenotteryHandler():void{
        if ( !_bCanClick )return;

        if(!isInActivityTime()) return;

        var price : int = _getTreasureBuyPriceTableData( 3 ).cost;
        var blueDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.blueDiamond;
        if ( price > blueDiamond) {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "arena_zsbz" ) );
        }else{
            _bCanClick = false;
            _heroTreasureHandler.onDrawTreasureRequest(CHeroTreasureManager.POOTYPE_THREE,10);
        }

        CLogUtil.recordLinkLog(system, 10034);
    }

    //十连抽奖励响应
    private function _showTenReward():void{
        if(viewUI && viewUI.parent){
            var _rewardListData:CRewardListData = _heroTreasureManager.getRewardListData();
            if(_rewardListData)
            {
                _bCanClick = true;
                (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(_rewardListData);
            }
        }
    }

    //点击抽一次
    private function _onOneLotteryHandler():void{
        if ( !_bCanClick )return;

        if(!isInActivityTime()) return;

        //道具
        var treasureCard : TreasureCardPool = _getTreasureBuyPriceTableData(1);
        var bgData : CBagData = _bagManager.getBagItemByUid(treasureCard.costItemId);
        var currValue:int = bgData == null ? 0 : bgData.num;
        if(bgData && currValue >= treasureCard.cost){
            _bCanClick = false;
            _heroTreasureHandler.onDrawTreasureRequest(CHeroTreasureManager.POOTYPE_ONE,1);
        }else{
            //钻石
            treasureCard = _getTreasureBuyPriceTableData(2);
            var blueDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.blueDiamond;
            if ( treasureCard.cost > blueDiamond) {
//                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "arena_zsbz" ) );

                var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
                var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert("很抱歉，您的钻石不足，请前往获得");
            }else{
                _bCanClick = false;
                _heroTreasureHandler.onDrawTreasureRequest(CHeroTreasureManager.POOTYPE_TWO,1);
            }
        }

        CLogUtil.recordLinkLog(system, 10033);
    }

    //抽一次奖励响应
    private function _showOneReward() : void {
        if(viewUI && viewUI.parent){
            obj.rotation = 0;
            _pLoopTweenMax = TweenMax.to( obj, 0.8, {
                rotation : 360,
                repeat : -1,
                ease : Linear.easeNone,
                onUpdate : _updateLight
            } );

            TweenMax.delayedCall( 3.2, function () : void {
                if ( _pLoopTweenMax ) {
                    _pLoopTweenMax.kill();
                    _pLoopTweenMax = null;
                }
                var index:int = _heroTreasureManager.getOntRewardIndex();
                _selectItem( _dic[ index ]+10 );
            } );
        }
    }

    private var obj:Object = {rotation:0};
    private function _selectItem( degree : int ) : void {
        TweenMax.to( obj, 2, {
            rotation : degree,
            ease : Linear.easeNone,
            onUpdate : _updateLight,
            onComplete : playFicker
        } );
    }

    private function playFicker():void{
        var _rotationIndex:int = _heroTreasureManager.getOntRewardIndex();
        var mc : FrameClip = viewUI[ "light" + _rotationIndex ] as FrameClip;
        TweenMax.killTweensOf(mc);
        mc.visible = true;
        mc.alpha = 1;
        mc.playFromTo(null,null,new Handler(_flyItem));
    }

    private function _updateLight() : void {
        var degree : int = obj.rotation < 0 ? 360 + obj.rotation : obj.rotation;
        var index : int = degree / 22.5 + 1;
        if ( index > 16 ) {
            index = 16;
        }
        if ( index == 0 ) {
            index = 1;
        }
        _updateLightVisible( index );
    }

    private function _updateLightVisible( index : int ) : void {
        var light:FrameClip = viewUI[ "light" + index ] as FrameClip;
        light.visible = true;
        TweenMax.killTweensOf(light);
        TweenMax.to( light, 0.2, {alpha:0.5,onComplete:function():void{
            light.visible = false;
            light.alpha = 1;
        }});
    }

    private function _flyItem() : void {
        var _rotationIndex:int = _heroTreasureManager.getOntRewardIndex();
        var mc : FrameClip = viewUI[ "light" + _rotationIndex ] as FrameClip;
        mc.visible = false;
        mc.gotoAndStop(0);

        var item : RewardPackageItemUI = viewUI[ "item" + _rotationIndex ] as RewardPackageItemUI;
        CFlyItemUtil.flyItemToBag( item.mc_item, item.localToGlobal( new Point() ), system, _flyCompleteHandler );
    }

    private function _flyCompleteHandler():void {
        _bCanClick = true;
        (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).isWaitShowQuickUse(false);
    }

    private function get _bagManager():CBagManager
    {
        return system.stage.getSystem(CBagSystem ).getHandler(CBagManager) as CBagManager;
    }

    private function _getItemTableData( itemID : int ) : Item {
        var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
        return itemTable.findByPrimaryKey( itemID );
    }

    private function _getItemData( itemID : int ) : CItemData {
        var itemData : CItemData = ((uiCanvas as CAppSystem).stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
        return itemData;
    }

    private function _getPlayerData( heroID : int ) : CPlayerHeroData {
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var heroData:CPlayerHeroData = playerData.heroList.createHero(heroID);
        return heroData;
    }

    /**抽奖奖励配置表*/
    private function _getTreasureItemTableData( index : int ) : TreasureDisplayItem {
        var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.TREASUREDISPLAYITEM ) as CDataTable;
        return itemTable.findByPrimaryKey( index );
    }

    /**抽奖消耗配置表*/
    private function _getTreasureBuyPriceTableData( count : int ) : TreasureCardPool {
        var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.TREASURECARDPOOL ) as CDataTable;
        return itemTable.findByPrimaryKey( count );
    }

    /**抽奖基础配置表*/
    private function _getTreasureActivityInfoData( index : int ) : TreasureActivityInfo {
        var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.TREASUREACTIVITYINFO ) as CDataTable;
        return itemTable.findByPrimaryKey( index );
    }

    private function get _heroTreasureManager():CHeroTreasureManager{
        return system.getBean(CHeroTreasureManager) as CHeroTreasureManager;
    }

    private function get _heroTreasureHandler():CHeroTreasureHandler{
        return system.getBean(CHeroTreasureHandler) as CHeroTreasureHandler;
    }

    /**
     * 飘字提示
     * @param str
     * @param type
     */
    protected function _showTipInfo(str:String, type:int):void
    {
        (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( str, type );
    }
}
}
