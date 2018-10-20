//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/4/25.
 */
package kof.game.chat {

import QFLib.Foundation.CMap;

import com.greensock.TweenLite;

import flash.utils.Dictionary;

import kof.framework.CViewHandler;
import kof.game.chat.face.CQueueGetItemTips;
import kof.game.player.CPlayerSystem;
import kof.game.player.CPlayerUIHandler;
import kof.game.player.enum.EPlayerWndType;
import kof.game.player.view.heroGet.CHeroGetViewHandler;
import kof.game.player.view.heroGet.CPlayerHeroGetView;
import kof.ui.CUISystem;
import kof.ui.chat.ItemGetTipsViewUI;
import kof.util.TweenUtil;

public class CItemGetTipsViewHandler extends CViewHandler {
    public function CItemGetTipsViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ ItemGetTipsViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();

    }

    private static const _durationDic_key_sn : Dictionary = new Dictionary();
    _durationDic_key_sn[ 0 ] = 5;
    _durationDic_key_sn[ 1 ] = 4;
    _durationDic_key_sn[ 2 ] = 3;

    private var _reduceDuration : Number = .2;

    private var _pendingInterval : int = 1000;

    private var _pendingArr : Array = [];
    private var _shownArr : Array = [];

    private var _max : int = 3; // ([0~_max), 注意：_max是非闭区间)

    private var _pool : Vector.<CQueueGetItemTips> = new Vector.<CQueueGetItemTips>();

    private function fromPool( msg : String ) : CQueueGetItemTips {
        var result : CQueueGetItemTips = _pool.length > 0 ? _pool.shift() : new CQueueGetItemTips();
        result.msg = msg;
        return result;
    }

    private function toPool( tips : CQueueGetItemTips ) : void {
        if ( !tips ) {
            return;
        }
        tips.remove();
        tips.reset();
        if ( _pool.indexOf( tips ) == -1 ) {
            _pool.push( tips );
        }
        var idx : int = _shownArr.indexOf( tips );
        if ( idx != -1 ) {
            _shownArr.splice( idx, 1 );
        }
    }

    /** arr支持两个结构：
     * </br>
     * 1、arr:[{msg:msg, type:type}]
     * </br>
     * 2、arr:[string1, string2, ..., stringN]
     * </br>
     *  type 参数EnumCQueueGetItemTipsBgType，同时type也是可选参数
     * */
    public function showArr( arr : Array ) : void {
        var canImmediatelyShowCount : int = _max - _shownArr.length;
        var pushToPending : Array;
        if ( canImmediatelyShowCount > 0 ) {
            canImmediatelyShowCount = canImmediatelyShowCount > arr.length ? arr.length : canImmediatelyShowCount;
            for ( var i : int = 0, len : int = canImmediatelyShowCount; i < len; ++i ) {
                show( arr[ i ] );
            }

            if ( arr.length == canImmediatelyShowCount ) { // 全部显示完了
                return;
            }
            else {
                pushToPending = arr.slice( canImmediatelyShowCount, arr.length - 1 );
            }
        }
        else {
            pushToPending = arr;
        }
        if ( pushToPending && pushToPending.length > 0 ) {
            _pendingArr.push.apply( null, pushToPending );
        }
    }

    private static var _delayTween : TweenLite;

    private static var _penddingTime : Boolean = false;

    /** <p>目前支持${item:1010101}, ${face:001}两种处理功能：分别是：物品图标，与表情(001~035) <p>
     * <p>eg. "获得物品：${item:1010101}x1"；"这是表情001：${face:001}"<p>
     * @param type 参数EnumCQueueGetItemTipsBgType
     * @see EnumCQueueGetItemTipsBgType
     * */
    public function show( msg : String , playSound : Boolean = true ) : void {
        return;

        //如果在播放获得格斗家动画，就
//        var uiHandler:CPlayerUIHandler = _playerSystem.getHandler(CPlayerUIHandler) as CPlayerUIHandler;
//        var heroGetView:CPlayerHeroGetView = uiHandler.getCreatedWindow(EPlayerWndType.WND_PLAYER_HERO_GET) as CPlayerHeroGetView;
//        if(heroGetView && heroGetView._ui && heroGetView._ui.parent)
//        {
//            return;
//        }

        var heroGetView:CHeroGetViewHandler = system.stage.getSystem(CPlayerSystem).getHandler(CHeroGetViewHandler) as CHeroGetViewHandler;
        if(heroGetView && heroGetView.isViewShow)
        {
            return;
        }

        if ( !_penddingTime && _shownArr.length < _max ) {
            // show
            innerShow( msg , playSound );

            _penddingTime = true;
            _delayTween = TweenLite.delayedCall( .5, function () : void {
                _penddingTime = false;
                if ( !handleShift() ) {
                    _delayTween.kill();
                    _delayTween = null;
                }
            } );
        }
        else {
            _pendingArr.push( {msg : msg } );
        }
    }

    public function errorMsg( msg : String, playSound : Boolean = true ) : void {
//        show(HtmlUtil.format(msg, 0xffffff, 14), EnumCQueueGetItemTipsBgType.TYPE_2, playSound);
    }

    private function handleShift() : Boolean {
        if ( !_penddingTime && _shownArr.length < _max && _pendingArr.length > 0 ) {
            var pendingData : Object = _pendingArr.shift();
            if ( pendingData is String ) {
                show( pendingData as String );
            }
            else {
                show( pendingData.msg, pendingData.type );
            }
            return true;
        }
        return false;
    }

    private function innerShow( msg : String, playSound : Boolean ) : void {
        var tips : CQueueGetItemTips = fromPool( msg  );

        tips.alpha = 1;

        tips.x = 330;
        tips.y = _pChatViewHandler.m_chatUI.combox_channel.y;
//        tips.x = (App.stage.stageWidth - tips.width) * .2;
//        tips.y = App.stage.stageHeight - tips.height;

//        var pUISystem : CUISystem = (uiCanvas as CUISystem);
//        if ( pUISystem ) {
//            pUISystem.msgLayer.addChild( tips );//
        if( _pChatViewHandler && _pChatViewHandler.m_chatUI )
            _pChatViewHandler.m_chatUI.addChildAt( tips , _pChatViewHandler.m_chatUI.numChildren - 1 );
//        } else {
//            App.stage.addChild( tips );
//        }

        _shownArr.unshift( tips );

        if ( tips.fadeInAlphaTween ) {
            tips.fadeInAlphaTween.kill();
            tips.fadeInAlphaTween = null;
        }
        tips.alpha = 0;
        tips.fadeInAlphaTween = TweenUtil.tween( tips, .5, {alpha : 1} );

        if ( tips.fadeOutAlphaTween ) {
            tips.fadeOutAlphaTween.kill();
            tips.fadeOutAlphaTween = null;
        }
        tips.fadeOutAlphaTween = TweenUtil.tween( tips, .5,
                {
                    delay : 2, alpha : 0,
                    onComplete : function () : void {
                        toPool( tips );
                        handleShift();
                        _onCompleteHandler(tips.msgStr);
                    },
                    onStart : function () : void {
                        var idx : int = _shownArr.indexOf( tips );
                        if ( idx != -1 ) {
                            _shownArr.splice( idx, 1 );
                        }
                    }
                } );

        for ( var i : int = 0, len : int = _shownArr.length; i < len; ++i ) {
            var t : CQueueGetItemTips = _shownArr[ i ];
            if ( t.yTween ) {
                t.yTween.kill();
                t.yTween = null;
            }
//            t.yTween = TweenUtil.tween( t, 1, {y : App.stage.stageHeight - tips.height - tips.height * i - 100} );
            t.yTween = TweenUtil.tween( t, 1, {y : _pChatViewHandler.m_chatUI.combox_channel.y - tips.height * i - 100 } );
        }
    }

    private var m_pShowMap:CMap;
    private var m_pAttrMap:CMap;
    /**
     * 显示属性增加值
     * @param attrName
     * @param value
     * @param playSound
     */
    public function showProp(attrName : String, value:int, playSound : Boolean = true):void
    {
        if(m_pAttrMap == null)
        {
            m_pAttrMap = new CMap();
        }

        if(m_pShowMap == null)
        {
            m_pShowMap = new CMap();
        }

        if(m_pShowMap.find(attrName))
        {
            var totalValue:int = int(m_pAttrMap.find(attrName)) + value;
            m_pAttrMap.add(attrName, totalValue, true);
        }
        else
        {
//            var msgType:int = value >= 0 ? CMsgAlertHandler.NORMAL : CMsgAlertHandler.WARNING;
            show(attrName + " + " + value, playSound);
            m_pAttrMap.add(attrName,0,true);
            m_pShowMap.add(attrName, true, true);
        }
    }

    private function _onCompleteHandler(tips:String):void
    {
        if(m_pShowMap)
        {
            for(var key:String in m_pAttrMap)
            {
                if(m_pShowMap.find(key) && tips.indexOf(key) != -1)
                {
                    m_pShowMap.add(key, false, true);
                    break;
                }
            }
        }

        if(m_pAttrMap)
        {
            for(key in m_pAttrMap)
            {
                var value:int = m_pAttrMap.find(key);
                if(value && !m_pShowMap.find(key))
                {
//                    var type:int = value >= 0 ? CMsgAlertHandler.NORMAL : CMsgAlertHandler.WARNING;
                    show(key + " + " + value );
                    m_pAttrMap.add(key,0,true);
                    m_pShowMap.add(key, true, true);
                    break;
                }
            }
        }
    }

    private function get _playerSystem():CPlayerSystem{
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pChatViewHandler():CChatViewHandler{
        return system.getBean( CChatViewHandler ) as CChatViewHandler;
    }
}
}

