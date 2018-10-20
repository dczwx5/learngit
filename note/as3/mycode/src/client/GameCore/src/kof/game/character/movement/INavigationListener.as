//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.movement {

import QFLib.Interface.IDisposable;

import flash.events.IEventDispatcher;

/**
 * 导航开始
 */
[Event(name="navigationBegin", type="flash.events.Event")]
/**
 * 导航节点
 */
[Event(name="navigationCheckPoint", type="flash.events.Event")]
/**
 * 导航结束
 */
[Event(name="navigationEnd", type="flash.events.Event")]
/**
 * 导航监听器接口
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface INavigationListener extends IEventDispatcher, IDisposable {

}
}
// vim:ft=as3 ts=4 sw=4 et tw=0

