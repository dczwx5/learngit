//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import kof.data.CObjectData;
import kof.framework.CShowDialogTweenData;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IUICanvas {

    /**
     * <code>rootContainer</code>
     * UI界面层级中最底层的容器，包含主界面，战斗UI，全屏系统界面等。
     */
    function get rootContainer() : DisplayObjectContainer;
    function get loadingLayer() : DisplayObjectContainer;

    /**
     * 黑屏处理
     */
    function showMaskView( callBackFun : Function = null, onStartFun : Function
            = null, onProcessFun : Function = null, showTime : Number = 3.0,
            color : uint = 0x000000 ) : void;

    /**
     * 显示PVP过场屏幕效果
     */
    function showPVPLoadingView() : void;

    function removePVPLoadingView() : void;
    function removeAllLoadingView() : void; // 关闭pvploading和sceneLoading

    function showMultiplePVPLoadingView(data:CObjectData, isNeedPreload:Boolean = false):void;
    function removeMultiplePVPLoadingView():void;

    function showDoublePVPLoadingView(data:CObjectData, isNeedPreload:Boolean = false):void;
    function removeDoublePVPLoadingView():void;

    /**
     * 显示剧情压屏开始效果
     */
    function showScenarioStartView( callBackFun : Function = null ) : void;

    /**
     * 显示剧情压屏结束效果
     */
    function showScenarioEndView( callBackFun : Function = null ) : void;

    /**
     * 移除剧情压屏效果
     */
    function removeScenarioLoadingView() : void;
    /**
     * 显示过场加载
     */
    function showSceneLoading( pfnCompleted : Function = null, ... args ) : void;

    function removeSceneLoading() : void;

    /**
     * 消息提示
     */
    function showMsgBox( msg : String,  okFun : Function = null, closeFun : Function = null, cancelIsVisible:Boolean = true, okLable:String = null, cancelLable:String = null, closeBtnIsVisible:Boolean = true ,showType : String = ""):void;

    /**
     * 消息弹窗提示
     */
    function showMsgAlert( msg : String, type : int = 1, playSound : Boolean = true ) : void;
    function showGamePromptMsgAlert( gamePromptID:int, replaceObject:Object = null, type : int = 1, playSound : Boolean = true ) : void ;

    function addDialog( dialog : DisplayObject, closeOther : Boolean = false, tweenData:CShowDialogTweenData = null ) : void;

    function addPopupDialog( dialog : DisplayObject, closeOther : Boolean = false ) : void;

    function addPrompt( dialog : DisplayObject, closeOther : Boolean = false ) : void;

    function addAppPrompt( dialog : DisplayObject, closeOther : Boolean = false ) : void;

    function loadAssetsByViewClass( viewClasses : Array, additions : Array = null, pfnComplete : Function = null, pfnProgress : Function = null,
                                    pfnError : Function = null, isAssetsCached : Boolean = true ) : Boolean;

    function showHoldingMaskView() : void ;
    function hideHoldingMaskView() : void ;

}
}
