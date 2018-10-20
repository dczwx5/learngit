//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/5/12.
 */
package kof.game.player.view.heroGet {

import com.greensock.TimelineLite;
import com.greensock.TweenMax;
import com.greensock.easing.Cubic;

import flash.display.DisplayObject;

import flash.display.Shape;

import flash.events.Event;

import flash.events.KeyboardEvent;

import flash.events.MouseEvent;

import flash.geom.ColorTransform;
import flash.ui.Keyboard;

import kof.framework.CViewHandler;
import kof.game.audio.IAudio;
import kof.game.common.CLang;
import kof.game.common.CUIFactory;
import kof.game.common.view.viewBaseComponent.CViewBaseLoadAfterShow;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EHeroIntelligence;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.reciprocation.CReciprocalSystem;
import kof.ui.CUISystem;
import kof.ui.master.jueseNew.RoleGetnewIIUI;

import morn.core.components.Dialog;
import morn.core.components.FrameClip;
import morn.core.handlers.Handler;
import morn.core.managers.ResLoader;

public class CHeroGetViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var m_pViewUI:RoleGetnewIIUI;
    private var m_pHeroData:CPlayerHeroData;
    private var m_pLoadAfterShow:CViewBaseLoadAfterShow;
    private var m_pTimeLine1:TimelineLite;
    private var m_pTimeLine2:TimelineLite;
    private var m_pTimeLine3:TimelineLite;
    private var m_arrStarEffect:Array = [];
    private var m_iCount:int;
    private var m_bIsSkip:Boolean;
    private var m_bIsInAnimation:Boolean;
    protected var m_pMask:Shape;

    private var m_pShowCallBack:Function;// 打开界面后的回调
    private var m_pHideCallBack:Function;// 关闭界面后的回调
    private const _CloseCountdownNum:int = 5;

    public function CHeroGetViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [ RoleGetnewIIUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["frameclip_playercards.swf"];
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
                m_pViewUI = new RoleGetnewIIUI();
                m_pMask = m_pMask || new Shape();

                m_pViewUI.btn_confirm.clickHandler = new Handler(_onClickConfirmHandler);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        if(isViewShow)
        {
            return;
        }

        this.loadAssetsByView( viewClass, _showDisplay );

        if(m_pHeroData)
        {
            if(m_pLoadAfterShow == null)
            {
                m_pLoadAfterShow = new CViewBaseLoadAfterShow();
            }
            m_pLoadAfterShow.addUiResource(CPlayerPath.getUIHeroFacePath(m_pHeroData.prototypeID), ResLoader.BMD);
        }
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
        var pUISystem : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISystem )
        {
            pUISystem.dialogLayer.addChildAt( m_pMask, 0 );
        }

        m_bIsInAnimation = true;

        uiCanvas.addPopupDialog( m_pViewUI );

        _initView();
        _addListeners();
        _onStageResize();

        system.dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOWHIDE_COMBAT_EFFECT, false));

        if(m_pShowCallBack != null)
        {
            m_pShowCallBack.apply();
            m_pShowCallBack = null;
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.addEventListener(MouseEvent.CLICK, _onClickHandler);
        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true);
        system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
    }

    private function _removeListeners():void
    {
        m_pViewUI.removeEventListener(MouseEvent.CLICK, _onClickHandler);
        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp);
        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
    }

    private function _onStageResize( event:Event = null ) : void
    {
        this._redrawMask();

        var stageWidth:int = system.stage.flashStage.stageWidth;
        var stageHeight:int = system.stage.flashStage.stageHeight;

        m_pViewUI.x = stageWidth - m_pViewUI.width >> 1;
        m_pViewUI.y = stageHeight - m_pViewUI.height >> 1;

        _setPosition();
    }

    private function _redrawMask() : void
    {
        if ( !m_pMask )
            return;
        m_pMask.graphics.clear();
        m_pMask.graphics.beginFill( 0x0 );
        m_pMask.graphics.drawRect( 0, 0, system.stage.flashStage.stageWidth, system.stage.flashStage.stageHeight );
        m_pMask.graphics.endFill();
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _clear();
            _setPosition();
            _startAnimation();
        }
    }

    private function _setPosition():void
    {
        var stageWidth:int = system.stage.flashStage.stageWidth;
        var stageHeight:int = system.stage.flashStage.stageHeight;

        if(m_pViewUI.y < 0)
        {
            m_pViewUI.box_skip.y = m_pViewUI.y * (-1) + 60;
        }
        else
        {
            m_pViewUI.box_skip.y = 60;
        }

        if(stageWidth < m_pViewUI.width)
        {
            var diff:int = m_pViewUI.width - stageWidth >> 1;
            m_pViewUI.box_skip.x = 1278 - diff;
            m_pViewUI.box_btn.x = 1295 - diff;
        }
        else
        {
            m_pViewUI.box_skip.x = 1278;
            m_pViewUI.box_btn.x = 1295;
        }

        if(stageHeight < m_pViewUI.height)
        {
            diff = m_pViewUI.height - stageHeight >> 1;
            m_pViewUI.box_btn.y = 740 - diff;
        }
        else
        {
            m_pViewUI.box_btn.y = 740;
        }
    }

// 动画开始============================================================================================================
    /**
     * 爆炸特效
     */
    private function _startAnimation():void
    {
        if(m_bIsSkip)
        {
            return;
        }

        // 颜色背景
        m_pViewUI.clip_bg.visible = true;
        m_pViewUI.clip_bg.index = m_pHeroData.qualityBaseType;

        m_pViewUI.frameClip_baozha.visible = true;
        m_pViewUI.frameClip_baozha.alpha = 1;
        m_pViewUI.frameClip_baozha.playFromTo(null,null,new Handler(_onBaozhaComplHandler));

        function _onBaozhaComplHandler():void
        {
            m_pViewUI.frameClip_baozha.stop();
            m_pViewUI.frameClip_baozha.visible = false;
        }

        delayCall(1, _startWhiteAnimation);
    }

    /**
     * 白光、格斗家
     */
    private function _startWhiteAnimation():void
    {
        if(m_bIsSkip)
        {
            return;
        }

        var colorTransform:ColorTransform = new ColorTransform();
        colorTransform.color = 0xFFFFFF;
        m_pViewUI.img_white.transform.colorTransform = colorTransform;
        m_pViewUI.img_white.visible = true;

        m_pViewUI.img_hero.url = CPlayerPath.getUIHeroFacePath(m_pHeroData.prototypeID);
        m_pViewUI.img_hero_white.url = CPlayerPath.getUIHeroFacePath(m_pHeroData.prototypeID);
        m_pViewUI.img_hero_white.transform.colorTransform = colorTransform;

        if(m_pTimeLine1 == null)
        {
            m_pTimeLine1 = new TimelineLite();
        }

        // 白光放大
        m_pTimeLine1.append(TweenMax.fromTo(m_pViewUI.img_white, 0.8, {alpha:0.5}, {alpha:1, onComplete:onShowHeroImg}));
        m_pTimeLine1.insert(TweenMax.fromTo(m_pViewUI.frameClip_baozha, 0.3, {alpha:1}, {alpha:0}));
        function onShowHeroImg():void
        {
            m_pViewUI.box_hero.visible = true;
            m_pViewUI.img_hero.visible = false;
            m_pViewUI.img_hero_white.visible = true;
            m_pViewUI.img_hero_white.alpha = 1;
        }

        // 白光消失
        m_pTimeLine1.append(TweenMax.fromTo(m_pViewUI.img_white, 0.3, {alpha:1}, {alpha:0}));
        m_pTimeLine1.insert(TweenMax.fromTo(m_pViewUI.img_hero_white, 0.3, {scale:1.5}, {scale:1, delay:0.8, ease:Cubic.easeIn,
            onComplete:onCompleteHandler, onUpdate:onUpdateHandler}));

        function onUpdateHandler():void
        {
            m_pViewUI.img_hero_white.centerX = 0;
            m_pViewUI.img_hero_white.bottom = 0;
        }

        function onCompleteHandler():void
        {
            // 格斗家显示
            m_pViewUI.img_hero.visible = true;
            _playSound();

            // 抽卡转换碎片提示
            m_pViewUI.txt_cardTip.visible = CPlayerCardUtil.HeroChipsNum > 0;
            if(m_pViewUI.txt_cardTip.visible)
            {
                m_pViewUI.txt_cardTip.text = CLang.Get("playerCard_yzmgdj",{v1:CPlayerCardUtil.HeroChipsNum});
            }

            // 上下条
            m_pViewUI.box_top.visible = true;
            m_pViewUI.box_bottom.visible = true;
            m_pViewUI.clip_topBg.index = m_pHeroData.qualityBase == EHeroIntelligence.SS ? 1 : 0;
            m_pViewUI.clip_bottomBg.index = m_pHeroData.qualityBase == EHeroIntelligence.SS ? 1 : 0;

            // 结束后扩散
            m_pTimeLine1.append(TweenMax.fromTo(m_pViewUI.img_hero_white, 0.5, {scale:1, alpha:1}, {scale:1.1, alpha:0,
                onUpdate:onUpdateHandler}));

            _playSpreadEffect();

            delayCall(0.5, _qualityAnimation);
        }
    }

    /**
     * 扩散特效
     */
    private function _playSpreadEffect():void
    {
        if(m_bIsSkip)
        {
            return;
        }

        m_pViewUI.frameClip_kuosan.visible = true;
        m_pViewUI.frameClip_kuosan.playFromTo(null,null,new Handler(_onComplHandler));

        function _onComplHandler():void
        {
            m_pViewUI.frameClip_kuosan.stop();
            m_pViewUI.frameClip_kuosan.visible = false;
        }

        m_pViewUI.frameClip_backLight.visible = true;
        m_pViewUI.frameClip_backLight.autoPlay = true;
    }

    /**
     * 资质
     */
    private function _qualityAnimation():void
    {
        if(m_bIsSkip)
        {
            return;
        }

        m_pViewUI.frameClip_quality.visible = true;

        var skin:String = _getQualityEffectSkin();
        m_pViewUI.frameClip_quality.skin = skin;
        if(skin)
        {
            m_pViewUI.frameClip_quality.playFromTo(null,null);

            delayCall(0.5, _nameInfoAnimation);
        }
    }

    private function _getQualityEffectSkin():String
    {
        var skin:String = "";
//        switch(m_pHeroData.qualityBase)
//        {
//            case EHeroIntelligence.S:
//                skin = "frameclip_s1";
//                break;
//            case EHeroIntelligence.A:
//            case EHeroIntelligence.APlus:
//                skin = "frameclip_a1";
//                break;
//            case EHeroIntelligence.B:
//            case EHeroIntelligence.BPlus:
//                skin = "frameclip_b1";
//                break;
//            case EHeroIntelligence.C:
//                skin = "frameclip_c1";
//                break;
//            default:
//                skin = "frameclip_c1";
//                break;
//        }

        var intelligence:int = m_pHeroData.qualityBase;
        if(intelligence >= EHeroIntelligence.C && intelligence < EHeroIntelligence.B)
        {
            skin = "frameclip_c1";
        }
        else if(intelligence >= EHeroIntelligence.B && intelligence < EHeroIntelligence.A)
        {
            skin = "frameclip_b1";
        }
        else if(intelligence >= EHeroIntelligence.A && intelligence < EHeroIntelligence.S)
        {
            skin = "frameclip_a1";
        }
        else if(intelligence >= EHeroIntelligence.S && intelligence < EHeroIntelligence.SS)
        {
            skin = "frameclip_s1";
        }
        else if(intelligence >= EHeroIntelligence.SS)
        {
            skin = "frameclip_ss1";
        }

        return skin;
    }

    // 名字、定位
    private function _nameInfoAnimation():void
    {
        if(m_bIsSkip)
        {
            return;
        }

        m_pViewUI.box_heroDefine.visible = true;

        m_pViewUI.frameClip_heroDefine.visible = true;
        m_pViewUI.frameClip_heroDefine.playFromTo(null,null,new Handler(_onHeroDefineComplHandler));

        function _onHeroDefineComplHandler():void
        {
            _showNameInfo();
        }
    }

    private function _showNameInfo():void
    {
        if(m_bIsSkip)
        {
            return;
        }

        m_pViewUI.txt_heroName.visible = true;
        m_pViewUI.txt_heroName.text = m_pHeroData.heroName;
        m_pViewUI.txt_desc.text = (system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler).getRoleSet(m_pHeroData.prototypeID);

        if(m_pTimeLine2 == null)
        {
            m_pTimeLine2 = new TimelineLite();
        }
        m_pTimeLine2.insert(TweenMax.fromTo(m_pViewUI.txt_heroName, 0.2, {alpha:0}, {alpha:1}));
        m_pTimeLine2.insert(TweenMax.fromTo(m_pViewUI.txt_desc, 0.2, {alpha:0}, {alpha:1, onComplete:onNameInfoCompl}));
        function onNameInfoCompl():void
        {
            _starAnimation();
        }
    }

    // 星星
    private function _starAnimation():void
    {
        if(m_bIsSkip)
        {
            return;
        }

        m_pViewUI.box_star.visible = true;
        var starWidth:int = 25 * m_pHeroData.star - 4;
        m_pViewUI.box_star.x = m_pViewUI.width - starWidth >> 1;

        for(var i:int = 0; i < m_pHeroData.star; i++)
        {
            _playStarEffect(i);
        }
    }

    private function _playStarEffect(index:int):void
    {
        if(m_bIsSkip)
        {
            return;
        }

        delayCall(0.2 * index, _onDelayCall);

        var starEffect:FrameClip;
        function _onDelayCall():void
        {
            if(m_pViewUI.parent == null)
            {
                return;
            }

            starEffect = CUIFactory.getDisplayObj(FrameClip) as FrameClip;
            m_arrStarEffect.push(starEffect);
            m_pViewUI.box_star.addChild(starEffect);

            starEffect.x = index * 50;
            starEffect.visible = true;
            starEffect.skin = "frameclip_xingxingbao";
            starEffect.mouseEnabled = false;
            starEffect.interval = 30;
            starEffect.playFromTo(null,null,new Handler(_onAnimationComplHandler,[index]));
        }

        function _onAnimationComplHandler(idx:int):void
        {
            starEffect.stop();
            starEffect.mouseEnabled = false;

            if(idx >= m_pHeroData.star - 1)
            {
                m_bIsInAnimation = false;
                _showBtn();
            }
        }
    }
// 动画结束=============================================================================================================



    private function _showBtn():void
    {
        m_pViewUI.btn_confirm.visible = true;
        m_pViewUI.txt_leftTime.visible = true;
        m_pViewUI.txt_leftTime.text = m_iCount+"s后自动关闭界面";
        m_pViewUI.clip_skip.index = 0;

        schedule(1, _onScheduleHandler);
    }

    private function _onScheduleHandler(delta : Number):void
    {
        m_iCount--;
        if(m_iCount <= 0)
        {
            m_pViewUI.btn_confirm.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        }
        else
        {
            m_pViewUI.txt_leftTime.text = m_iCount+"s后自动关闭界面";
        }
    }

    private function _playSound() : void
    {
        if(m_pHeroData)
        {
            var sound:String = m_pHeroData.playerDisplayRecord.sound;
            if (sound && sound.length > 0)
            {
                var musicPath:String = CPlayerPath.getHeroAudioPath(sound);
                (system.stage.getSystem(IAudio) as IAudio).playAudioByPath(musicPath, 1, 0);
            }
        }
    }

// 监听处理==============================================================================================================
    private function _onClickConfirmHandler():void
    {
        removeDisplay();
    }

    /**
     * 点击跳过动画
     * @param e
     */
    private function _onClickHandler(e:MouseEvent):void
    {
        if(!m_bIsInAnimation && m_pViewUI.img_hero.visible)
        {
            m_pViewUI.btn_confirm.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        }
        else if(!m_bIsSkip && m_bIsInAnimation)
        {
            m_bIsSkip = true;
            m_bIsInAnimation = false;

            _stopAnimation();

            m_pViewUI.frameClip_baozha.visible = false;
            m_pViewUI.frameClip_kuosan.visible = false;

            m_pViewUI.frameClip_quality.visible = true;
            var skin:String = _getQualityEffectSkin();
            m_pViewUI.frameClip_quality.skin = skin;
            m_pViewUI.frameClip_quality.gotoAndStop(m_pViewUI.frameClip_quality.totalFrame-1);

            m_pViewUI.box_hero.visible = true;
            m_pViewUI.img_white.visible = false;
            m_pViewUI.img_hero_white.visible = false;
            m_pViewUI.img_hero.visible = true;
            m_pViewUI.img_hero.url = CPlayerPath.getUIHeroFacePath(m_pHeroData.prototypeID);
            // 颜色背景
            m_pViewUI.clip_bg.visible = true;
            m_pViewUI.clip_bg.index = m_pHeroData.qualityBaseType;

            m_pViewUI.frameClip_backLight.visible = true;
            m_pViewUI.frameClip_backLight.autoPlay = true;

            // 抽卡转换碎片提示
            m_pViewUI.txt_cardTip.visible = CPlayerCardUtil.HeroChipsNum > 0;
            if(m_pViewUI.txt_cardTip.visible)
            {
                m_pViewUI.txt_cardTip.text = CLang.Get("playerCard_yzmgdj",{v1:CPlayerCardUtil.HeroChipsNum});
            }

            // 上下条
            m_pViewUI.box_top.visible = true;
            m_pViewUI.box_bottom.visible = true;
            m_pViewUI.clip_topBg.index = m_pHeroData.qualityBase == EHeroIntelligence.SS ? 1 : 0;
            m_pViewUI.clip_bottomBg.index = m_pHeroData.qualityBase == EHeroIntelligence.SS ? 1 : 0;

            m_pViewUI.txt_heroName.visible = true;
            m_pViewUI.txt_heroName.text = m_pHeroData.heroName;
            m_pViewUI.box_heroDefine.visible = true;
            m_pViewUI.txt_desc.text = (system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler).getRoleSet(m_pHeroData.prototypeID);
            m_pViewUI.frameClip_heroDefine.visible = true;
            m_pViewUI.frameClip_heroDefine.gotoAndStop(m_pViewUI.frameClip_heroDefine.totalFrame-1);

            m_pViewUI.box_star.visible = true;
            var starWidth:int = 25 * m_pHeroData.star - 4;
            m_pViewUI.box_star.x = m_pViewUI.width - starWidth >> 1;

            var starEffect:FrameClip;
            for(var i:int = 0; i < m_pHeroData.star; i++)
            {
                starEffect = CUIFactory.getDisplayObj(FrameClip) as FrameClip;
                m_arrStarEffect.push(starEffect);
                m_pViewUI.box_star.addChild(starEffect);
                starEffect.x = i * 50;
                starEffect.visible = true;
                starEffect.autoPlay = false;
                starEffect.skin = "frameclip_xingxingbao";
                starEffect.mouseEnabled = false;
                starEffect.interval = 30;
                starEffect.gotoAndStop(starEffect.totalFrame-1);
            }

            _showBtn();
        }
    }

    private function _onKeyboardUp(e:KeyboardEvent):void
    {
        e.stopImmediatePropagation();

        if(e.keyCode == Keyboard.SPACE && !m_bIsInAnimation && m_pViewUI.btn_confirm.visible)
        {
            m_pViewUI.btn_confirm.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        }
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            _stopAnimation();

            if(m_pViewUI && m_pViewUI.parent)
            {
                m_pViewUI.close(Dialog.CLOSE);
            }

            if(m_pMask && m_pMask.parent)
            {
                m_pMask.parent.removeChild(m_pMask);
            }

            _clear();

            // 战力特效
            system.dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOWHIDE_COMBAT_EFFECT, true));

            // 移除窗口队列
            var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
            reciprocalSystem.removeEventPopWindow(this.viewId);

            if(m_pHideCallBack != null)
            {
                m_pHideCallBack.apply();
                m_pHideCallBack = null;
            }

            if(m_pShowCallBack)
            {
                m_pShowCallBack = null;
            }

            m_bIsSkip = false;
            m_bIsInAnimation = false;
            CPlayerCardUtil.HeroChipsNum = 0;
        }
        system.dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOW_GET_HERO_FINISHED, null));
    }

    private function _stopAnimation():void
    {
        m_pViewUI.frameClip_quality.stop();
        m_pViewUI.frameClip_quality.autoPlay = false;

        m_pViewUI.frameClip_baozha.stop();
        m_pViewUI.frameClip_baozha.autoPlay = false;

        m_pViewUI.frameClip_kuosan.stop();
        m_pViewUI.frameClip_kuosan.autoPlay = false;

        m_pViewUI.frameClip_heroDefine.stop();
        m_pViewUI.frameClip_heroDefine.autoPlay = false;

        m_pViewUI.frameClip_backLight.stop();
        m_pViewUI.frameClip_backLight.autoPlay = false;

        if(m_pTimeLine1)
        {
            m_pTimeLine1._kill();
            m_pTimeLine1.clear();
        }

        if(m_pTimeLine2)
        {
            m_pTimeLine2._kill();
            m_pTimeLine2.clear();
        }

        if(m_pTimeLine3)
        {
            m_pTimeLine3._kill();
            m_pTimeLine3.clear();
        }

        unschedule(_onScheduleHandler);
        unschedule(_startWhiteAnimation);
        unschedule(_qualityAnimation);
        unschedule(_nameInfoAnimation);

        for each(var clip:FrameClip in m_arrStarEffect)
        {
            if(clip)
            {
                clip.stop();
                clip.autoPlay = false;
                clip.skin = "";
                CUIFactory.disposeDisplayObj(clip);
            }
        }

        m_pViewUI.clip_skip.index = 0;

        m_arrStarEffect.length = 0;
    }

    private function _clear():void
    {
        m_pViewUI.frameClip_quality.visible = false;
        m_pViewUI.frameClip_baozha.visible = false;
        m_pViewUI.frameClip_baozha.alpha = 1;
        m_pViewUI.frameClip_kuosan.visible = false;
        m_pViewUI.frameClip_heroDefine.visible = false;
        m_pViewUI.frameClip_backLight.visible = false;

        m_pViewUI.img_white.visible = false;
        m_pViewUI.txt_heroName.text = "";
        m_pViewUI.txt_heroName.visible = false;
        m_pViewUI.box_heroDefine.visible = false;
        m_pViewUI.txt_desc.text = "";
        m_pViewUI.box_hero.visible = false;
        m_pViewUI.img_hero.url = "";
        m_pViewUI.img_hero_white.url = "";
        m_pViewUI.img_hero_white.alpha = 1;
        m_pViewUI.box_star.visible = false;
        m_pViewUI.txt_leftTime.text = "";
        m_pViewUI.txt_leftTime.visible = false;
        m_pViewUI.txt_cardTip.text = "";
        m_pViewUI.txt_cardTip.visible = false;
        m_pViewUI.clip_bg.visible = false;
        m_pViewUI.box_bottom.visible = false;
        m_pViewUI.box_top.visible = false;
        m_pViewUI.btn_confirm.visible = false;

        m_pViewUI.clip_skip.index = 1;

        m_iCount = _CloseCountdownNum;
    }

//property==============================================================================================================
    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function set data(value:CPlayerHeroData):void
    {
        m_pHeroData = value;
    }

    public function get hideCallBack():Function
    {
        return m_pHideCallBack;
    }

    public function set hideCallBack(value:Function):void
    {
        m_pHideCallBack = value;
    }

    public function set showCallBack(value:Function):void
    {
        m_pShowCallBack = value;
    }

    public function get showCallBack():Function
    {
        return m_pShowCallBack;
    }
}
}
