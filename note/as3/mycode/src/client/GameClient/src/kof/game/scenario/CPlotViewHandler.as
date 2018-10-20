//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/8/10.
 */
package kof.game.scenario {

import QFLib.Foundation.CKeyboard;
import QFLib.Framework.CPostEffects;
import QFLib.Math.CAABBox2;

import com.greensock.TweenLite;

import com.greensock.TweenMax;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;
import flash.ui.Keyboard;

import kof.framework.CAppStage;
import kof.game.level.CLevelSystem;
import kof.game.scene.ISceneFacade;
import kof.ui.CUISystem;
import kof.ui.component.CCharacterBustFrameClip;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.demo.PlotDialogueUI;

import morn.core.components.Button;

import morn.core.handlers.Handler;

public class CPlotViewHandler extends CBaseDialogueViewHandler {

    public var m_plotDialogueUI : PlotDialogueUI;

    public var m_bIsDialogOption : Boolean = false;//是否是对话选项
    public var m_nDialogOptionId1 : int = 0;
    public var m_nTriggerId1:int = 0;
    public var m_sOptionContent1:String = "";
    public var m_nDialogOptionId2 : int = 0;
    public var m_nTriggerId2:int = 0;
    public var m_sOptionContent2:String = "";
    public var m_bIsShowIcon:Boolean = false;

    public var m_countTime:int = 5;

    private static const TIME_ON_ALLSHOW : Number = 4.0;
    private var _strIndex : int;
    private var _time : Number = 0.0;
    private var _callBackFun : Function;
    private var m_theKeyboard : CKeyboard;
    private var m_appStage : CAppStage;

    private var m_characterClip1 : CCharacterBustFrameClip;
    private var m_characterClip2 : CCharacterBustFrameClip;

    private var m_move : int = 30;
    private var _isFirst : Boolean = false;

    private var _isShow:Boolean = false;

    public function CPlotViewHandler() {
        super( true ); // load view by default to call onInitializeView
    }

    override public function get viewClass() : Array {
        return [ PlotDialogueUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !m_plotDialogueUI ) {
            m_plotDialogueUI = new PlotDialogueUI();

            m_characterClip1 = new CCharacterBustFrameClip();
            m_characterClip1.interval = 41.666666666667;
            m_characterClip1.autoPlay = true;
            m_characterClip1.pointX = 250;
            m_plotDialogueUI.addChild(m_characterClip1);
            m_characterClip2 = new CCharacterBustFrameClip();
            m_characterClip2.interval = 41.666666666667;
            m_characterClip2.autoPlay = true;
            m_characterClip2.pointX = App.stage.width - 400;
            m_plotDialogueUI.addChild(m_characterClip2);

            m_plotDialogueUI.addEventListener( Event.ADDED_TO_STAGE, _onAddStage );
            m_plotDialogueUI.addEventListener( Event.REMOVED_FROM_STAGE, _onRemoveStage );

            m_plotDialogueUI.btn_optionA.clickHandler = new Handler(_onBtnOptionClickHandler,[m_plotDialogueUI.btn_optionA]);
            m_plotDialogueUI.btn_optionB.clickHandler = new Handler(_onBtnOptionClickHandler,[m_plotDialogueUI.btn_optionB]);

            m_plotDialogueUI.txt_content.isHtml = true;
            m_plotDialogueUI.txt_nameL.text = "";
            m_plotDialogueUI.txt_nameL.font =
                    m_plotDialogueUI.txt_nameR.font =
                            m_plotDialogueUI.txt_content.font = "黑体";

        }
        return Boolean( m_plotDialogueUI );
    }

    override public function show( callBackFun : Function = null ) : void {
        _callBackFun = callBackFun;
        m_plotDialogueUI.txt_content.text = "";
        if (m_characterClip1.pointX < 210) {
            // 原代码有bug, 在从-1000 tween出现的时候。如果快速点击, pointX会不正常(比如是负的或很小的值), 然后下一个show的时候, 人物会在左边
            // 这里简单的处理, 如果小于200, 则强制移至250, 第一个播放的时候, 人物的坐标是从-1000移动到250的位置
            m_characterClip1.pointX = 250;
        } // 动画的实现

        if(m_bIsDialogOption){
            //如果是对话选项
            m_plotDialogueUI.box_option.visible = true;
            m_plotDialogueUI.box_time.visible = true;
            if(m_bIsShowIcon){
                m_plotDialogueUI.img_iconlr.visible = true;
                m_plotDialogueUI.img_iconzy.visible = true;
            }else{
                m_plotDialogueUI.img_iconlr.visible = false;
                m_plotDialogueUI.img_iconzy.visible = false;
            }

            m_plotDialogueUI.btn_optionA.label = m_sOptionContent1;
            m_plotDialogueUI.btn_optionB.label = m_sOptionContent2;

        }else{
            m_plotDialogueUI.box_option.visible = false;
        }


        _showAnimation();

        (uiCanvas as CUISystem).loadingLayer.addChild( m_plotDialogueUI );
        (uiCanvas as CUISystem).hideRootNDialogLayer();

        if ( display == 1 ) {
            _strIndex = 0;
            _time = 0.0;
        } else {
            _time = 0.0;
            m_plotDialogueUI.txt_content.text = content;
        }

        _onStageResize( null );

        _showAnimationEff();

        if(m_bIsDialogOption){
            schedule( 1.0, _countDownTime);
        }else{
            schedule( 1.0 / 30, this.update );
        }
    }

    override public function hide() : void {
        unschedule( this.update );
        unschedule( _countDownTime );
        _isFirst = false;
        _isShow = false;
        if ( m_characterClip1 && m_characterClip1.framework ) {
            m_characterClip1.framework = null;
            m_characterClip1.pointX = 250;
        }

        if ( m_characterClip2 && m_characterClip2.framework ) {
            m_characterClip2.framework = null;
            m_characterClip2.pointX = App.stage.width - 400;
        }

        if(m_plotDialogueUI && m_plotDialogueUI.parent){
            m_plotDialogueUI.parent.removeChild(m_plotDialogueUI);
        }
//        (uiCanvas as CUISystem).plotLayer.close( m_plotDialogueUI );
        (uiCanvas as CUISystem).showRootNDialogLayer();
        levelSystem.getBubblesFacade().startBubblesTalk();
        CPostEffects.getInstance().stop( CPostEffects.Blur );
    }

    private function _onAddStage( e : Event ) : void {
        _isShow = true;

        system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
        levelSystem.getBubblesFacade().stopBubblesTalk();

        if ( m_appStage ) {
            m_appStage.flashStage.addEventListener( MouseEvent.CLICK, _ck );
        }
        if ( !m_theKeyboard) {
            if(m_appStage){
                m_theKeyboard = new CKeyboard( m_appStage.flashStage );
                m_theKeyboard.registerKeyCode( true, Keyboard.SPACE, _enterKeySpace );
            }
        }
    }

    private function _onRemoveStage( e : Event ) : void {
        _isShow = false;

        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );

        if(m_appStage){
            m_appStage.flashStage.removeEventListener( MouseEvent.CLICK, _ck );
        }
        if ( m_theKeyboard ) {
            m_theKeyboard.unregisterKeyCode( true, Keyboard.SPACE, _enterKeySpace );
            m_theKeyboard.dispose();
            m_theKeyboard = null;
        }
    }

    private function showStrOneByOne() : void {
        if ( !m_plotDialogueUI || !m_plotDialogueUI.parent )
            return;
        if ( _strIndex >= content.length && _time >= TIME_ON_ALLSHOW ) {
            onFinish();
            return;
        }
        m_plotDialogueUI.txt_content.text += content.charAt( _strIndex );
    }

    private function onFinish( actionId:int = 0) : void {
        if ( _callBackFun ) {
            _callBackFun( actionId );
        }
        TweenLite.killTweensOf( m_characterClip1, true );
        TweenLite.killTweensOf( m_characterClip2, true );
    }

    //后续版本剧情对话人物显示spine动画
    private function _showAnimation() : void {
        m_characterClip1.isLoopPlay = (this.isLoop == 0 ? false : true);
        m_characterClip1.isStageScale = true;
        m_characterClip1.isBust = true;
        if ( head ) {
            if ( m_characterClip1.framework == null ) {
                m_characterClip1.framework = pScene.scenegraph.graphicsFramework;
            }
            m_characterClip1.scaleX = 1;
            m_characterClip1.skin = head;
            m_characterClip1.animationName = animationName;
        }

        m_characterClip2.isLoopPlay = (this.isLoop1 == 0 ? false : true);
        m_characterClip2.isStageScale = true;
        m_characterClip2.isBust = true;
        if ( head1 ) {
            if ( m_characterClip2.framework == null ) {
                m_characterClip2.framework = pScene.scenegraph.graphicsFramework;
            }
            m_characterClip2.scaleX = -1;
            m_characterClip2.addEventListener("EventCharacterLoadCompleted", _onCharacter2LoadFinish);
            m_characterClip2.skin = head1;
            m_characterClip2.animationName = animationName1;
        }

    }

    private function _showAnimationEff() : void {
        if ( dialogNumber == 1 ) {
            m_plotDialogueUI.txt_nameL.text = name;
            m_characterClip1.isDark = false;
            m_characterClip1.isLight = true;
            m_characterClip1.setColorLight();
            m_characterClip2.isDark = false;
            m_characterClip2.isLight = false;
            m_characterClip2.visible = false;
            return;
        }

        m_characterClip2.visible = true;

        if ( !_isFirst ) {
            _isFirst = true;

            TweenMax.from( m_characterClip1, 0.5, {
                pointX : -1000, onComplete : function () : void {
                    if (_isShow) {
                        _showAnimationDialog();
                        var isPlay : Boolean = (system.stage.getSystem( CScenarioSystem ) as CScenarioSystem).isPlaying;
                        if ( isPlay ) {
                            CPostEffects.getInstance().play( CPostEffects.Blur );
                        }
                    }

                }
            } );

            if (m_characterClip2.aabb) {
                TweenMax.from( m_characterClip2, 0.5, {pointX : 2200} );
            }


            return;
        }

        _showAnimationDialog();
    }

    private function _showAnimationDialog() : void {
        if ( position == 0 ) {
            //左边说话
            if ( m_characterClip1.pointX < 280 ) {
                TweenMax.to( m_characterClip1, 0.2, {pointX : m_characterClip1.pointX + m_move} );
                TweenMax.to( m_characterClip2, 0.2, {delay : 0.1, pointX : m_characterClip2.pointX + m_move} );
            }
            m_plotDialogueUI.txt_nameL.text = name;
            m_characterClip1.isDark = false;
            m_characterClip1.isLight = true;
            m_characterClip1.setColorLight();
            m_characterClip2.isDark = true;
            m_characterClip2.isLight = false;
            m_characterClip2.setColorDark();
        }
        else {
            //右边说话
            if ( m_characterClip1.pointX > 220 ) {
                TweenMax.to( m_characterClip2, 0.2, {pointX : m_characterClip2.pointX - m_move} );
                TweenMax.to( m_characterClip1, 0.2, {delay : 0.1, pointX : m_characterClip1.pointX - m_move} );
            }
            m_plotDialogueUI.txt_nameL.text = name1;
            m_characterClip2.isDark = false;
            m_characterClip2.isLight = true;
            m_characterClip2.setColorLight();
            m_characterClip1.isDark = true;
            m_characterClip1.isLight = false;
            m_characterClip1.setColorDark();
        }
    }

    override public function dispose() : void {
        super.dispose();
        if ( uiCanvas )
            (uiCanvas as CUISystem).plotLayer.close( m_plotDialogueUI );

        reset();
    }

    private function reset() : void {
        if ( !m_plotDialogueUI )
            return;

        m_plotDialogueUI.txt_content.text =
                m_plotDialogueUI.txt_nameL.text =
                        m_plotDialogueUI.txt_nameR.text =
                                m_plotDialogueUI.img_p.url = "";

        if ( m_plotDialogueUI.img_p.filters ) {
            m_plotDialogueUI.img_p.filters = null;
        }
        if ( m_plotDialogueUI.img_p1.filters ) {
            m_plotDialogueUI.img_p1.filters = null;
        }
        if ( m_characterClip1 ) {
            m_characterClip1.isDark = false;
            m_characterClip1.isLight = false;
        }
        if ( m_characterClip2 ) {
            m_characterClip2.isDark = false;
            m_characterClip2.isLight = false;
            m_characterClip2.removeEventListener("EventCharacterLoadCompleted", _onCharacter2LoadFinish);

        }

        _isFirst = false;
        _isShow = false;
    }

    private function _onCharacter2LoadFinish(e:*) : void {
        _onStageResize(null);
    }

    private function _onStageResize( e : Event ) : void {

        m_plotDialogueUI.box_tips.width = system.stage.flashStage.stageWidth;
        m_plotDialogueUI.box_tips.height = system.stage.flashStage.stageHeight;

        m_plotDialogueUI.box_bottom.width = system.stage.flashStage.stageWidth;
        m_plotDialogueUI.img_bottom.width = system.stage.flashStage.stageWidth;

        m_plotDialogueUI.txt_content.width = int((m_plotDialogueUI.img_bottom.width*978)/1500);

        var sWidth:Number = system.stage.flashStage.stageWidth;

        var cWidth:Number = m_characterClip2.cWidth;
        var scaleX:Number = sWidth/1500;
        var scaleY:Number = system.stage.flashStage.stageHeight/900;
        var scaleValue:Number = scaleX > scaleY ? scaleY : scaleX; // 动画是根据宽度缩放, 取最小缩放实现
        var subScale:Number = 1 - scaleValue;
        var subWidth:Number = subScale * cWidth; // 宽度增长(缩减)数值

        // 坐标设在stageWidth是因为做了镜像, scaleX = -1, 所以正常情况下, 坐标点设在最右边就OK了
        m_characterClip2.pointX = sWidth - 400*scaleValue + subWidth + 80; // 250 : 原点估计值 , 60 : 修正值, subWidth : 缩放增长(缩减值), sWidth : stageWidth

        m_plotDialogueUI.box_bottom.left = 0;

        m_plotDialogueUI.box_bLeft.left = 300;
        m_plotDialogueUI.box_bRight.right = 150;

    }

    private function _ck( evt : MouseEvent ) : void {
        evt.stopImmediatePropagation();
        if(m_bIsDialogOption){
            return;
        }

        if ( display != 0 ) {
            display = 0;
            m_plotDialogueUI.txt_content.text = content;
            return;
        }
        onFinish();
    }

    private function _enterKeySpace( keyCode : int ) : void {
        if(m_bIsDialogOption){
            _onBtnOptionClickHandler(m_plotDialogueUI.btn_optionA);
            return;
        }

        if ( display != 0 ) {
            display = 0;
            m_plotDialogueUI.txt_content.text = content;
            return;
        }
        if ( keyCode == Keyboard.SPACE ) {
            onFinish();
        }
    }

    private function _onBtnOptionClickHandler( btn:Button ) : void {
        if(!m_bIsDialogOption){
            return;
        }

        switch(btn){
            case m_plotDialogueUI.btn_optionA:
                onFinish( m_nTriggerId1 );
                break;
            case m_plotDialogueUI.btn_optionB:
                onFinish( m_nTriggerId2 );
                break;
        }

        m_plotDialogueUI.box_time.visible = false;
        unschedule( _countDownTime );
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
        m_appStage = appStage;

        if(!_isShow){
            return;
        }

        if ( m_appStage ) {
            m_appStage.flashStage.addEventListener( MouseEvent.CLICK, _ck );
        }

        if ( !m_theKeyboard) {
            if(m_appStage){
                m_theKeyboard = new CKeyboard( m_appStage.flashStage );
                m_theKeyboard.registerKeyCode( true, Keyboard.SPACE, _enterKeySpace );
            }
        }
    }

    override protected function exitStage( appStage : CAppStage ) : void {
        super.exitStage( appStage );
    }

    override public function update( delta : Number ) : void {
        _time += delta;
        if ( display && _time >= rate * _strIndex ) {
            showStrOneByOne();
            _strIndex++;
        } else if ( !display && _time >= TIME_ON_ALLSHOW ) {
            onFinish();
        }
    }

    private function _countDownTime( delta : Number ) : void {
        m_countTime --;
        if(m_countTime <= 0){
            m_countTime = 5;
            m_plotDialogueUI.box_time.visible = false;
            unschedule( _countDownTime );
            onFinish( m_nTriggerId1 );
        }
        if(m_plotDialogueUI){
            m_plotDialogueUI.txt_countTime.text = m_countTime.toString();
        }
    }

    private function get pScene() : ISceneFacade {
        return system.stage.getSystem( ISceneFacade ) as ISceneFacade;
    }

    private function get levelSystem():CLevelSystem{
        return system.stage.getSystem( CLevelSystem ) as CLevelSystem;
    }
}
}
