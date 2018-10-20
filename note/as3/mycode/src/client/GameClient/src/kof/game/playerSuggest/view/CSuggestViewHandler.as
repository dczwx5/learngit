//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/9.
 */
package kof.game.playerSuggest.view {

import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.utils.getTimer;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.GMReport.enum.EGMReportType;
import kof.game.KOFSysTags;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.common.view.event.CViewEvent;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.playerSuggest.event.ESuggestViewEventType;
import kof.table.SuggestionConfig;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.master.suggest.SuggestUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CSuggestViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : SuggestUI;
    private var m_pCloseHandler : Handler;
    private var m_iLastTime:int;

    public function CSuggestViewHandler()
    {
        super(false);
    }

    override public function get viewClass() : Array
    {
        return [ SuggestUI ];
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
                m_pViewUI = new SuggestUI();

                m_pViewUI.item_list.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.closeHandler = new Handler( _onClose );

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
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
        setTweenData(KOFSysTags.SUGGESTION);
        showDialog(m_pViewUI, false, _onShowEnd);
    }

    private function _onShowEnd():void
    {
        _initView();
        _addListeners();
    }

    public function removeDisplay() : void
    {
        closeDialog(_removeDisplayB);
    }

    public function _removeDisplayB() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();
        }
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if ( this.closeHandler )
                {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.addEventListener(MouseEvent.CLICK, _onClickHandler);
        m_pViewUI.txt_content.addEventListener(TextEvent.TEXT_INPUT,_onTxtInputHandler);
        m_pViewUI.txt_content.addEventListener(FocusEvent.FOCUS_IN, _onFocusHandler);
        m_pViewUI.txt_content.addEventListener(FocusEvent.FOCUS_OUT, _onFocusHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.removeEventListener(MouseEvent.CLICK, _onClickHandler);
        m_pViewUI.txt_content.removeEventListener(TextEvent.TEXT_INPUT,_onTxtInputHandler);
        m_pViewUI.txt_content.removeEventListener(FocusEvent.FOCUS_IN, _onFocusHandler);
        m_pViewUI.txt_content.removeEventListener(FocusEvent.FOCUS_OUT, _onFocusHandler);
    }

    private function _onClickHandler(e:MouseEvent):void
    {
        if( e.target == m_pViewUI.radio_suggest)
        {
            m_pViewUI.radio_bug.selected = false;
        }

        if( e.target == m_pViewUI.radio_bug)
        {
            m_pViewUI.radio_suggest.selected = false;
        }

        if( e.target == m_pViewUI.btn_submit)
        {
            if(_isCanSubmit())
            {
                var data:Object = {};
                data["type"] = m_pViewUI.radio_suggest.selected ? EGMReportType.Type_Suggestion : EGMReportType.Type_Error;
                data["content"] = m_pViewUI.txt_content.text;
                this.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,ESuggestViewEventType.SubmitSuggest,data));

                _afterSubmitHandler();
            }
        }
    }

    private function _isCanSubmit():Boolean
    {
        if(m_pViewUI)
        {
            if(m_pViewUI.txt_content.text == "" || m_pViewUI.txt_content.text == CLang.Get("suggest_default_qsrnd"))
            {
                _showTipInfo(CLang.Get("suggest_null_tip"),CMsgAlertHandler.WARNING);
                return false;
            }

            var nowTime:int = getTimer();
            var configInfo:SuggestionConfig = _getSuggestConfigInfo();
            var timeLimit:int = configInfo == null ? 60 : configInfo.sendInterval*60;
            if(m_iLastTime != 0 && (nowTime - m_iLastTime) * 0.001 < timeLimit)
            {
                _showTipInfo(CLang.Get("suggest_time_tip",{v1:configInfo.sendInterval}),CMsgAlertHandler.WARNING);
                return false;
            }

            m_iLastTime = getTimer();
        }

        return true;
    }

    private function _afterSubmitHandler():void
    {
        if(m_pViewUI)
        {
            m_pViewUI.txt_content.text = "";
        }

        _flyItem();
    }

    private function _onTxtInputHandler(e:TextEvent):void
    {
        if(m_pViewUI)
        {
            var configInfo:SuggestionConfig = _getSuggestConfigInfo();
            var lenLimit:int = configInfo == null ? 200 : configInfo.contentLimit;
            if(m_pViewUI.txt_content.text.length >= lenLimit)
            {
                _showTipInfo(CLang.Get("suggest_num_tip"),CMsgAlertHandler.WARNING);
                e.preventDefault();
            }
        }
    }

    private function _onFocusHandler(e:FocusEvent):void
    {
        if( e.type == FocusEvent.FOCUS_IN)
        {
            if(m_pViewUI.txt_content.text == CLang.Get("suggest_default_qsrnd"))
            {
                m_pViewUI.txt_content.text = "";
                m_pViewUI.txt_content.color = 0xfff1e4;
            }
        }
        else
        {
            if(m_pViewUI.txt_content.text == "")
            {
                m_pViewUI.txt_content.text = CLang.Get("suggest_default_qsrnd");
                m_pViewUI.txt_content.color = 0x9f6b66;
            }
        }
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function show() : void
    {
        _addToDisplay();
        _initView();
        _addListeners();
    }

    private function _initView():void {
        if ( m_pViewUI )
        {
            m_pViewUI.radio_suggest.label = "游戏建议";
            m_pViewUI.radio_suggest.labelSize = 14;
            m_pViewUI.radio_bug.label = "游戏BUG";
            m_pViewUI.radio_bug.labelSize = 14;
            m_pViewUI.radio_suggest.selected = true;
            m_pViewUI.radio_bug.selected = false;
            m_pViewUI.txt_content.text = CLang.Get("suggest_default_qsrnd");
            m_pViewUI.txt_content.color = 0x9f6b66;

            var configInfo:SuggestionConfig = _getSuggestConfigInfo();
            if(configInfo)
            {
                m_pViewUI.txt_content.maxChars = configInfo.contentLimit;

                var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, configInfo.rewardID);
                if(rewardListData)
                {
                    if(m_pViewUI.item_list)
                    {
                        m_pViewUI.item_list.dataSource = rewardListData.list;
                    }
                }
            }
        }
    }

    private function _renderItem( item:Component, index:int):void
    {
        if(!(item is RewardItemUI))
        {
            return;
        }

        var rewardItem:RewardItemUI = item as RewardItemUI;
        rewardItem.mouseChildren = false;
        rewardItem.mouseEnabled = true;
        var itemData:CRewardData = rewardItem.dataSource as CRewardData;
        if(null != itemData)
        {
            if(itemData.num > 1)
            {
                rewardItem.num_lable.text = itemData.num.toString();
            }
            else
            {
                rewardItem.num_lable.text = "";
            }

            rewardItem.icon_image.url = itemData.iconSmall;
            rewardItem.bg_clip.index = itemData.quality;
        }
        else
        {
            rewardItem.num_lable.text = "";
            rewardItem.icon_image.url = "";
        }

        rewardItem.toolTip = new Handler( _showTips, [rewardItem] );
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:RewardItemUI):void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    /**
     * 飘字提示
     * @param str
     * @param type
     */
    private function _showTipInfo(str:String, type:int):void
    {
        (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( str, type );
    }

    public function get isViewShow():Boolean
    {
        if(m_pViewUI && m_pViewUI.parent)
        {
            return true;
        }

        return false;
    }

    private function _flyItem():void
    {
        var len:int = m_pViewUI.item_list.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component = m_pViewUI.item_list.getCell(i) as Component;
//            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

    private function _getSuggestConfigInfo():SuggestionConfig
    {
        var table:IDataTable = (system.stage.getSystem(CDatabaseSystem) as IDatabase).getTable(KOFTableConstants.SUGGESTCONFIG);
        if(table)
        {
            return table.findByPrimaryKey(1) as SuggestionConfig;
        }

        return null;
    }

    override public function dispose() : void
    {
        super.dispose();
    }
}
}
