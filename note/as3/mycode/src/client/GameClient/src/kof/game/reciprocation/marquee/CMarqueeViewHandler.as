/**
 * Created by Maniac on 2017/3/21.
 */
package kof.game.reciprocation.marquee {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.ui.CUISystem;
import kof.ui.master.main.PublicNoticeUI;
import kof.util.TweenUtil;

/**
 * 走马灯效果消息公告
 * @author Maniac (maniac@qifun.com)
 */
public class CMarqueeViewHandler extends CViewHandler {

    private var _curShowArr : Array = [];//当前消息列表
    private var _currentPlayingMarquee : CMarqueeTips;
    private var m_pMarqueeData : CMarqueeData;
    private var _isPlaying : Boolean = false;
    private var _pool : Vector.<CMarqueeTips> = new Vector.<CMarqueeTips>();

    public function CMarqueeViewHandler( pData : CMarqueeData ) {
        super( false );

        m_pMarqueeData = pData;
    }

    override public function dispose() : void {
        super.dispose();

        if ( _curShowArr && _curShowArr.length )
            _curShowArr.splice( 0, _curShowArr.length );
        _curShowArr = null;

        _currentPlayingMarquee = null;
    }

    private function fromPool( msg : String ) : CMarqueeTips {
        var result : CMarqueeTips = _pool.length > 0 ? _pool.shift() : new CMarqueeTips();
        result.msg = msg;
        result.addEventListener(Event.ADDED_TO_STAGE,_onAddStage);
        result.addEventListener(Event.REMOVED_FROM_STAGE,_onRemoveStage);
        return result;
    }

    private function toPool( tips : CMarqueeTips ) : void {
        if ( !tips ) {
            return;
        }
        tips.remove();
        tips.reset();
        if ( _pool.indexOf( tips ) == -1 ) {
            _pool.push( tips );
        }

        if(m_pMarqueeData){
            m_pMarqueeData.shift();
        }

        var idx : int = _curShowArr.indexOf( tips );
        if ( idx != -1 ) {
            _curShowArr.splice( idx, 1 );
        }

        _isPlaying = false;
    }

    override public function get viewClass() : Array {
        return [ PublicNoticeUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    public function startMarquee() : void {
        if ( m_pMarqueeData && m_pMarqueeData.next() && !_isPlaying ) {
            var objMsg : Object = m_pMarqueeData.next();
            var sMsg : String = objMsg.content;
            var sTime : int = objMsg.time;
            showMarquee( sMsg, sTime );
        }
    }

    /**
     * 显示系统公告（走马灯效果）
     * @param msg 公告内容
     * @param showTime 持续显示时间
     */
    public function showMarquee( msg : String, showTime:int = 5 ) : void {
        this.loadAssetsByView( viewClass, function():void {
            if ( onInitializeView() ) {
                invalidate();
                _show( msg, showTime );
            }
        });
    }

    private function _show( msg : String, showTime:int = 5 ):void{
        var marquee:CMarqueeTips = fromPool(msg);
        marquee.alpha = 1;

        marquee.x = (system.stage.flashStage.stageWidth - marquee.width) >> 1;
        marquee.top = 128;

        var pUISystem : CUISystem = (uiCanvas as CUISystem);
        if ( pUISystem ) {
            pUISystem.msgLayer.addChild( marquee );
        } else {
            App.stage.addChild( marquee );
        }

        _curShowArr.push(marquee);
        _currentPlayingMarquee = marquee;

        if ( marquee.fadeInAlphaTween ) {
            marquee.fadeInAlphaTween.kill();
            marquee.fadeInAlphaTween = null;
        }
        marquee.alpha = 0;
        _isPlaying = true;
        marquee.fadeInAlphaTween = TweenUtil.tween( marquee, .5, {alpha : 1} );

        if ( marquee.fadeOutAlphaTween ) {
            marquee.fadeOutAlphaTween.kill();
            marquee.fadeOutAlphaTween = null;
        }
        marquee.fadeOutAlphaTween = TweenUtil.tween( marquee, .5,
                {
                    delay : showTime, alpha : 0, top : 85,
                    onComplete : function () : void {
                        toPool( marquee );
                        startMarquee();
                    },
                    onStart : function () : void {
                        var idx : int = _curShowArr.indexOf( marquee );
                        if ( idx != -1 ) {
                            _curShowArr.splice( idx, 1 );
                        }
                    }
                } );
    }

    private function _onAddStage( e : Event ) : void {
        system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
    }

    private function _onRemoveStage( e : Event ) : void {
        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
    }

    private function _onStageResize( e : Event = null ) : void {
        if ( _currentPlayingMarquee ) {
            _currentPlayingMarquee.x = (system.stage.flashStage.stageWidth - _currentPlayingMarquee.width) >> 1;
        }
    }
}
}
