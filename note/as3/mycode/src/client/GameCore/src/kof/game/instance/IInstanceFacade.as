//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/6.
 */
package kof.game.instance {

import kof.data.CPreloadData;
import kof.framework.IAppSystemEventSupported;
import kof.table.Exit;
import kof.table.InstanceContent;
import kof.table.NumericTemplate;

public interface IInstanceFacade extends IAppSystemEventSupported {

    function enterInstance( instanceID : int ) : void;

    function exitInstance() : void; // 副本正常结束, 退出
    function stopInstance() : void; // 副本中途退出

    function listenEvent( func : Function ) : void;

    function unListenEvent( func : Function ) : void;

    function addExitProcess(flagClz:Class, flagName:String, func : Function, param : Array, priority : int ) : void;
    function removeExitProcess(flagClz:Class, flagName:String) : void ;

    function get isMainCity() : Boolean;
    function get isPVE() : Boolean;
    function get isArena() : Boolean;
    function get isPractice() : Boolean;
    function get isTeaching() : Boolean;
    function get isGuildWar() : Boolean;

    function get currentIsPrelude() : Boolean;


    function isPrelude(instanceID:int) : Boolean ;

    function get instanceType() : int;

    function get instanceContent() : InstanceContent;

    function getNumericTemplate(monsterType:int, monsterProfession:int) : NumericTemplate;

    function get rageRestoreComboInterval() : int;

    function showLoseView() : void ;

    function get isInInstance() : Boolean ; // 是否已进入副本

    function isInstancePass(instanceID:int) : Boolean ; // 副本是否通关

    // 副本通关会到主城是否任然显示副本界面
    function get isShowViewWhenReturnMainCity() : Boolean;
    function set isShowViewWhenReturnMainCity( value : Boolean ) : void;

    function callWhenInMainCity(callback:Function, args:Array, flagClazz:Class, flagName:String, priority:int) : void ;

    function addPreloadData(list:Vector.<CPreloadData>) : void ;
    function pauseInstance() : void;
    function continueInstance() : void;

    function get isStart():Boolean;

    function isViewShow(type:int) : Boolean;
    function setPlayEnable(v:Boolean) : void ;
    function setAiEnable(v:Boolean) : void ;

    function get exitRecord() : Exit;
}
}
