//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Edison.Weng on 2017/7/24.
 */
package kof.game.sevenDays.view {

import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.sevenDays.CSevenDaysHandler;
import kof.game.sevenDays.CSevenDaysManager;
import kof.game.sevenDays.event.CSevenDaysEvent;
import kof.table.NewServerLoginActivityConfig;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.SevenDays.RewardItem1UI;
import kof.ui.master.SevenDays.SevenDaysUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CSevenDaysViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pSevenDaysUI : SevenDaysUI;
    private var m_pCloseHandler : Handler;
    private var m_pViewSize : Point = new Point(872,500);

    public function CSevenDaysViewHandler() {
        super( false );
    }

    override public function get viewClass() : Array
    {
        return [ SevenDaysUI, RewardItemUI,RewardItem1UI ];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_itemEffect_small.swf"];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if( !super.onInitializeView() )
            return false;
        if( !m_bViewInitialized )
        {
            this.initialize();
        }
        return m_bViewInitialized;
    }

    protected function initialize() : void
    {
        if( !m_pSevenDaysUI )
        {
            m_pSevenDaysUI = new SevenDaysUI();

//            m_pSevenDaysUI.item_list.renderHandler = new Handler( _onRenderItem );
            m_pSevenDaysUI.item_list.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));// modify by sprite
            m_pSevenDaysUI.close_btn.clickHandler = new Handler( _close );
            m_pSevenDaysUI.getGift_btn.clickHandler = new Handler( _getGift );
            m_pSevenDaysUI.btn_left.clickHandler = new Handler( _refreshPage , ["left"] );
            m_pSevenDaysUI.btn_right.clickHandler = new Handler( _refreshPage , ["right"] );
            _initItemButtonsClickHandler();

            m_bViewInitialized = true;
        }
    }

    private function _initView():void
    {
        if( m_pSevenDaysUI )
        {
            /*var openSeverDay : int = _getSelectedDefaultDay();
            sevenDaysManager.selectedDay = openSeverDay;
            sevenDaysManager.selectedPage = */
            _updateView();
        }
    }

    /**
     * 更新item_list的dataSource
     * */
    private function _updateListDataSource( day : int ) : void
    {
        var configInfo : NewServerLoginActivityConfig = _getSevenDaysConfigInfo( day );
        if( configInfo )
        {
            var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, configInfo.rewardID);
            if(rewardListData)
            {
                if(m_pSevenDaysUI.item_list)
                {
                    m_pSevenDaysUI.item_list.dataSource = rewardListData.list;
                }
            }
        }
    }

    /**
     * 设置item_list数据
     * */
    private function _onRenderItem( item : Component, index : int ) : void {

        if( !(item is RewardItemUI) )
        {
            return;
        }

        if ( item == null || item.dataSource == null ) {
            return;
        }

        var rewardItem:RewardItemUI = item as RewardItemUI;
        rewardItem.mouseChildren = false;
        rewardItem.mouseEnabled = true;
        var itemData : CRewardData = rewardItem.dataSource as CRewardData;

        if ( itemData != null )
        {
            if( itemData.num >= 1 )
            {
                rewardItem.num_lable.text = itemData.num.toString();
            }
            rewardItem.icon_image.url = itemData.iconSmall;
            rewardItem.bg_clip.index = itemData.quality;
            rewardItem.box_eff.visible = itemData.effect;
        }
        else
        {
            rewardItem.num_lable.text = "";
            rewardItem.icon_image.url = "";
        }
        rewardItem.toolTip = new Handler( _showTips, [rewardItem] );
    }

    private function _showTips( item :RewardItemUI ) : void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    private function _close() : void
    {
        if( m_pCloseHandler )
        {
            m_pCloseHandler.execute();
        }
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    /**
     * 请求获取奖励
     **/
    private function _getGift() : void
    {
        if( sevenDaysHandler )
        {
            var day : int = sevenDaysManager.selectedDay;
            sevenDaysHandler.getGiftRequest( day );
            //_flyItem();
        }
    }

    /**
     * 刷新第几页
     * */
    private function _refreshPage( direction : String ) : void
    {
        switch( direction )
        {
            case "left" :
                if( sevenDaysManager.selectedPage > 0 )
                {
                    sevenDaysManager.selectedPage -= 1;
                }
                break;
            case "right":
                if( sevenDaysManager.selectedPage < CSevenDaysManager.ROLL_MAX )
                {
                    sevenDaysManager.selectedPage += 1;
                }
                break;
        }
        //刷新界面数据
        sevenDaysManager.selectedDay = sevenDaysManager.getSelectedWithPage( sevenDaysManager.selectedPage );
        _updateView();
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        if ( onInitializeView() ) {
            invalidate();


            if ( m_pSevenDaysUI )
            {
                setTweenData(KOFSysTags.SEVEN_DAYS,m_pViewSize);
                showDialog(m_pSevenDaysUI);
//                uiCanvas.addDialog( m_pSevenDaysUI );
                _initView();
                _addEventListener();
            }

        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void
    {
        _removeEventListener();

        //关闭的时候判断是否需要关闭系统
        if( sevenDaysManager.allGiftGeted() )
        {
            sevenDaysManager.closeSevenDaysSys();
        }
    }

    private function _addEventListener() : void
    {
        system.addEventListener( CSevenDaysEvent.SEVEN_DAYS_SEVER_UPDATE , _refreshDaysState);
        system.addEventListener( CSevenDaysEvent.SEVEN_DAYS_STATE_UPDATE , _refreshDaysState);
        system.addEventListener( CSevenDaysEvent.SEVEN_DAYS_REWARD_SUCCESS , _onRewardSuccessHandler );
    }

    private function _removeEventListener() : void
    {
        system.removeEventListener( CSevenDaysEvent.SEVEN_DAYS_SEVER_UPDATE , _refreshDaysState);
        system.removeEventListener( CSevenDaysEvent.SEVEN_DAYS_STATE_UPDATE , _refreshDaysState);
        system.removeEventListener( CSevenDaysEvent.SEVEN_DAYS_REWARD_SUCCESS , _onRewardSuccessHandler );
    }

    private function _refreshDaysState( e : CSevenDaysEvent ):void
    {
        sevenDaysManager.selectedDay = sevenDaysManager.getDefaultSelectDay();
        sevenDaysManager.selectedPage =( sevenDaysManager.selectedDay - 1 ) / CSevenDaysManager.ROLL_DAYS;
        //处理超过最大翻页的时候
        sevenDaysManager.selectedPage = sevenDaysManager.selectedPage > CSevenDaysManager.ROLL_MAX ? CSevenDaysManager.ROLL_MAX : sevenDaysManager.selectedPage;
        _updateView();
    }

    private function _initItemButtonsClickHandler() : void
    {
        m_pSevenDaysUI.item1.day_btn.clickHandler = new Handler(_onClickHandler , [1]);
        m_pSevenDaysUI.item2.day_btn.clickHandler = new Handler(_onClickHandler , [2]);
        m_pSevenDaysUI.item3.day_btn.clickHandler = new Handler(_onClickHandler , [3]);
        m_pSevenDaysUI.item4.day_btn.clickHandler = new Handler(_onClickHandler , [4]);
        m_pSevenDaysUI.item5.day_btn.clickHandler = new Handler(_onClickHandler , [5]);
        m_pSevenDaysUI.item6.day_btn.clickHandler = new Handler(_onClickHandler , [6]);
        m_pSevenDaysUI.item7.day_btn.clickHandler = new Handler(_onClickHandler , [7]);
    }

    private function _onClickHandler( index : int ) :void
    {
        sevenDaysManager.selectedDay = index + sevenDaysManager.selectedPage * CSevenDaysManager.ROLL_DAYS ;
        _updateListDataSource( sevenDaysManager.selectedDay );
        _setItemButtonEffect( sevenDaysManager.selectedDay );
        _updateGetGiftButtonState( sevenDaysManager.selectedDay );
    }

    private function _getSelectedDefaultDay() : int
    {
        return sevenDaysManager.getDefaultSelectDay();
    }
    private function _getSevenDaysStateArr() : Array
    {
        return sevenDaysManager.sevenDaysStateArr;
    }

    private function _getSevenDaysConfigInfo( severDay : int ) : NewServerLoginActivityConfig
    {
        var table:IDataTable = sevenDaysManager.sevenDaysTable;
        if(table)
        {
            return table.findByPrimaryKey(severDay) as NewServerLoginActivityConfig;
        }

        return null;
    }

    private function get sevenDaysManager() : CSevenDaysManager
    {
        return system.getBean( CSevenDaysManager ) as CSevenDaysManager;
    }

    private function get sevenDaysHandler() : CSevenDaysHandler
    {
        return system.getBean( CSevenDaysHandler ) as CSevenDaysHandler;
    }
    /****************************界面处理部分****************************************/
    /***
     * 整体刷新界面内容
     * */
    private function _updateView() : void
    {
        _setSevenDaysState();
        _setDaysItemView();
        _setItemButtonEffect( sevenDaysManager.selectedDay );
        _updateListDataSource( sevenDaysManager.selectedDay );
        _updateGetGiftButtonState( sevenDaysManager.selectedDay );
        m_pSevenDaysUI.btn_left.visible = sevenDaysManager.selectedPage == 0 ? false : true ;
        m_pSevenDaysUI.btn_right.visible = sevenDaysManager.selectedPage == CSevenDaysManager.ROLL_MAX ? false : true ;
    }
    /**
     * 设置按钮的天数显示和奖励图片
     * */
    private function _setDaysItemView() : void
    {
        var pageFactor : int = sevenDaysManager.selectedPage * CSevenDaysManager.ROLL_DAYS;
        var giftImgUrl : String = "icon/sevendays/giftIcon/day"
        //初始化第几天
        m_pSevenDaysUI.item1.txt_day.text = (1 + pageFactor).toString();
        m_pSevenDaysUI.item1.gift_img.url = giftImgUrl + (1 + pageFactor).toString() + ".png";
        m_pSevenDaysUI.item2.txt_day.text = (2 + pageFactor).toString();
        m_pSevenDaysUI.item2.gift_img.url = giftImgUrl + (2 + pageFactor).toString() + ".png";
        m_pSevenDaysUI.item3.txt_day.text = (3 + pageFactor).toString();
        m_pSevenDaysUI.item3.gift_img.url = giftImgUrl + (3 + pageFactor).toString() + ".png";
        m_pSevenDaysUI.item4.txt_day.text = (4 + pageFactor).toString();
        m_pSevenDaysUI.item4.gift_img.url = giftImgUrl + (4 + pageFactor).toString() + ".png";
        m_pSevenDaysUI.item5.txt_day.text = (5 + pageFactor).toString();
        m_pSevenDaysUI.item5.gift_img.url = giftImgUrl + (5 + pageFactor).toString() + ".png";
        m_pSevenDaysUI.item6.txt_day.text = (6 + pageFactor).toString();
        m_pSevenDaysUI.item6.gift_img.url = giftImgUrl + (6 + pageFactor).toString() + ".png";
        m_pSevenDaysUI.item7.txt_day.text = (7 + pageFactor).toString();
        m_pSevenDaysUI.item7.gift_img.url = giftImgUrl + (7 + pageFactor).toString() + ".png";
    }

    /**
     * 初始化按钮没有被选中
     * */
    private function _setItemButtonUnselected() : void
    {
        m_pSevenDaysUI.item1.effect_img.visible = false;
        m_pSevenDaysUI.item2.effect_img.visible = false;
        m_pSevenDaysUI.item3.effect_img.visible = false;
        m_pSevenDaysUI.item4.effect_img.visible = false;
        m_pSevenDaysUI.item5.effect_img.visible = false;
        m_pSevenDaysUI.item6.effect_img.visible = false;
        m_pSevenDaysUI.item7.effect_img.visible = false;
    }

    /**
     * 设置被选中的状态，广告页面的天数显示
     * */
    private function _setItemButtonEffect( index : int) : void
    {
        _setItemButtonUnselected();
        //设置广告页面的天数
        m_pSevenDaysUI.day_num.num = index;
        m_pSevenDaysUI.day_num.x = index > 9 ? 375 : 400 ;
        if( index < 3 && index > 0 ) //前两天的广告界面
        {
            m_pSevenDaysUI.adImg.url = "icon/sevendays/adImg/ad1.png";
        }
        else
        {
            if( index < 8 && index > 2 )
            {
                m_pSevenDaysUI.adImg.url = "icon/sevendays/adImg/ad2.png";
            }
            else
            {
                if( index > 7 )
                {
                    m_pSevenDaysUI.adImg.url = "icon/sevendays/adImg/ad3.png";
                }
            }
        }
        index = index - CSevenDaysManager.ROLL_DAYS * sevenDaysManager.selectedPage;
        switch( index )
        {
            case 1:
                m_pSevenDaysUI.item1.effect_img.visible = true;
                break;
            case 2:
                m_pSevenDaysUI.item2.effect_img.visible = true;
                break;
            case 3:
                m_pSevenDaysUI.item3.effect_img.visible = true;
                break;
            case 4:
                m_pSevenDaysUI.item4.effect_img.visible = true;
                break;
            case 5:
                m_pSevenDaysUI.item5.effect_img.visible = true;
                break;
            case 6:
                m_pSevenDaysUI.item6.effect_img.visible = true;
                break;
            case 7:
                m_pSevenDaysUI.item7.effect_img.visible = true;
                break;
        }
    }

    /**
     * 设置七天登录奖励的领取状态
     **/
    private function _setSevenDaysState() : void
    {
        for( var index : int = 0; index < _getSevenDaysStateArr().length; index ++ )
        {
            var hasGet : Boolean = _getSevenDaysStateArr()[index] == 1 ? true : false;
            var day : int = index + 1;
            if( day > CSevenDaysManager.ROLL_DAYS * sevenDaysManager.selectedPage && day <= (CSevenDaysManager.ROLL_DAYS * sevenDaysManager.selectedPage + 7))
            {
                _setDayState( day , hasGet );
            }
        }
    }

    /**
     * 设置某一天的领取状态
     * */
    private function _setDayState( day : int , hasGet : Boolean ) : void
    {
        day = day - CSevenDaysManager.ROLL_DAYS * sevenDaysManager.selectedPage;
        switch( day )
        {
            case 1:
                m_pSevenDaysUI.item1.hasGet_img.visible = hasGet;
                break;
            case 2:
                m_pSevenDaysUI.item2.hasGet_img.visible = hasGet;
                break;
            case 3:
                m_pSevenDaysUI.item3.hasGet_img.visible = hasGet;
                break;
            case 4:
                m_pSevenDaysUI.item4.hasGet_img.visible = hasGet;
                break;
            case 5:
                m_pSevenDaysUI.item5.hasGet_img.visible = hasGet;
                break;
            case 6:
                m_pSevenDaysUI.item6.hasGet_img.visible = hasGet;
                break;
            case 7:
                m_pSevenDaysUI.item7.hasGet_img.visible = hasGet;
                break;
        }
    }

    /**
     * 设置领取奖励的状态
     * **/
    private function _updateGetGiftButtonState( selectedDay : int ):void
    {
        if( selectedDay > sevenDaysManager.openSeverDays ) //还要多少天能领取
        {
            m_pSevenDaysUI.getGift_btn.visible = false;
            m_pSevenDaysUI.txt_tip.visible = true;
            m_pSevenDaysUI.tip_day.visible = true;
            m_pSevenDaysUI.tip_day.text = (selectedDay - sevenDaysManager.openSeverDays).toString();
        }
        else
        {
            m_pSevenDaysUI.getGift_btn.visible = true;
            m_pSevenDaysUI.txt_tip.visible = false;
            m_pSevenDaysUI.tip_day.visible = false;
            var state : Boolean = _getSevenDaysStateArr()[ selectedDay - 1 ] == 1 ? true : false;
            if( state )
            {
                m_pSevenDaysUI.getGift_btn.label = "已领取";
                m_pSevenDaysUI.getGift_btn.disabled = true ;
            }
            else
            {
                m_pSevenDaysUI.getGift_btn.label = "领取";
                m_pSevenDaysUI.getGift_btn.disabled = false ;
            }
        }
    }

    /**
     * 奖励领取成功
     * **/
    private function _onRewardSuccessHandler( e : CSevenDaysEvent ) : void
    {
        _flyItem();
        system.dispatchEvent( new CSevenDaysEvent( CSevenDaysEvent.SEVEN_DAYS_STATE_UPDATE) );
    }

    private function _flyItem():void
    {
        var len:int = m_pSevenDaysUI.item_list.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component =  m_pSevenDaysUI.item_list.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }
}
}
