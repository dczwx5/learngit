//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/23.
 */
package kof.game.playerCard.view {

import kof.framework.CViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.playerCard.CPlayerCardManager;
import kof.game.playerCard.CPlayerCardNetHandler;
import kof.game.playerCard.util.CPlayerCardConst;
import kof.game.playerCard.util.ECardPoolType;
import kof.ui.master.playerCard.PlayerCardEffectViewUI;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CPlayerCardEffectViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : PlayerCardEffectViewUI;
    private var m_pCallBack:Handler;
    private var m_pData:Object;

    public function CPlayerCardEffectViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ PlayerCardEffectViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_playerCard_pump.swf","frameclip_playerCard_result.swf"];
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
                m_pViewUI = new PlayerCardEffectViewUI();
                m_pViewUI.btn_send.clickHandler = new Handler(_onClickHandler);

//                m_pViewUI.closeHandler = new Handler( _onClose );

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
//            invalidate();
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
        uiCanvas.addPopupDialog( m_pViewUI );

        var mainView:CPlayerCardViewHandler = system.getHandler(CPlayerCardViewHandler) as CPlayerCardViewHandler;
        if(mainView.isViewShow)
        {
            mainView.isShow = false;
        }

        _initView();
    }

    public function removeDisplay() : void
    {
        if(m_bViewInitialized)
        {
            if (m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            m_pViewUI.clip_before.autoPlay = false;
            m_pViewUI.clip_after.autoPlay = false;

            var mainView:CPlayerCardViewHandler = system.getHandler(CPlayerCardViewHandler) as CPlayerCardViewHandler;
            if(mainView.isViewShow)
            {
                mainView.isShow = true;
            }

            m_pCallBack = null;
//            m_pData = null;
        }
    }

    public function set data(value:*):void
    {
        m_pData = value;
    }

    private function _initView():void
    {
        m_pViewUI.box_mail.visible = false;
        m_pViewUI.clip_before.gotoAndStop(1);
        m_pViewUI.clip_after.gotoAndStop(1);
        m_pViewUI.clip_before.autoPlay = false;
        m_pViewUI.clip_before.visible = false;
        m_pViewUI.clip_after.autoPlay = false;
        m_pViewUI.clip_after.visible = false;
        m_pViewUI.clip_expand.autoPlay = false;
        m_pViewUI.clip_expand.visible = false;

        var content:String = (system.getHandler(CPlayerCardManager) as CPlayerCardManager).mailContent;
        if(content)
        {
            m_pViewUI.txt_content.text = content;
        }

        _startAnimation();
    }

    private function _startAnimation():void
    {
        m_pViewUI.clip_before.visible = true;
        m_pViewUI.clip_before.skin = _getBeforeSkin();
        m_pViewUI.clip_before.interval = 40;
        m_pViewUI.clip_before.playFromTo(null,null,new Handler(_onAnimationComplHandler));
        function _onAnimationComplHandler():void
        {
            m_pViewUI.box_mail.visible = true;
            var teamName:String = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.getNoneServerName();
            m_pViewUI.txt_teamName.text = teamName;
        }
    }

    private function _getBeforeSkin():String
    {
        var poolId:int = m_pData == null ? 0 : m_pData.poolId;
        var skin:String;
        switch (poolId)
        {
            case ECardPoolType.Type_Common:
                skin = "frameclip_lanxinfengchuxian";
                m_pViewUI.clip_before.y = 328;
                break;
            case ECardPoolType.Type_Better:
            case ECardPoolType.Type_Active:
                skin = "frameclip_jinxinfengchuxian";
                m_pViewUI.clip_before.y = 328-38;
                break;
            default:
                skin = "frameclip_lanxinfengchuxian";
                m_pViewUI.clip_before.y = 328;
        }

        return skin;
    }

    private function _getAfterSkin():String
    {
        var skin:String;
        var poolId:int = m_pData == null ? 0 : m_pData.poolId;
        var consumeNum:int = m_pData.consumeNum;

        if(poolId == ECardPoolType.Type_Common)
        {
            if(consumeNum == CPlayerCardConst.Consume_Num_One || consumeNum == 0)
            {
                skin = "frameclip_lanxinfengdanfeng";
            }
            else
            {
                skin = "frameclip_lanxinfengshilian";
            }
        }
        else
        {
            if(consumeNum == CPlayerCardConst.Consume_Num_One)
            {
                skin = "frameclip_jinxinfengdanfeng";
            }
            else
            {
                skin = "frameclip_jinxinfengshilian";
            }
        }

        return skin;
    }

    private function _onClickHandler():void
    {
        m_pViewUI.box_mail.visible = false;
        m_pViewUI.clip_before.gotoAndStop(1);
        m_pViewUI.clip_before.visible = false;

        m_pViewUI.clip_after.skin = _getAfterSkin();
        m_pViewUI.clip_after.interval = 40;
        m_pViewUI.clip_after.visible = true;
        m_pViewUI.clip_after.playFromTo(null,null,new Handler(_onAnimationComplHandler));
        function _onAnimationComplHandler():void
        {
            m_pViewUI.clip_after.gotoAndStop(1);
            m_pViewUI.clip_after.visible = false;

            _expandAnimation();
        }
    }

    private function _expandAnimation():void
    {
        m_pViewUI.clip_expand.visible = true;
        m_pViewUI.clip_expand.playFromTo(null,null,new Handler(_onAnimationComplHandler));

        function _onAnimationComplHandler():void
        {
            m_pViewUI.clip_expand.gotoAndStop(1);
            m_pViewUI.clip_expand.visible = false;

//            removeDisplay();
            _pumpHandler();
        }
    }

    /**
     * 抽卡
     */
    private function _pumpHandler():void
    {
        if(m_pData)
        {
            var poolId:int = m_pData.poolId;
            var consumeNum:int = m_pData.consumeNum;

            if(consumeNum == 0)
            {
                (system.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardFreeRequest(poolId);
            }
            else
            {
                (system.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).pumpingCardRequest(poolId,consumeNum);
            }

            var content:String = m_pViewUI.txt_content.text;
            if(content)
            {
                (system.getHandler(CPlayerCardNetHandler) as CPlayerCardNetHandler).cardPlayerMailContentRequest(content);
            }
        }
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

}
}
