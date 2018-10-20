/**
 * Created by user on 2016/12/8.
 */
package kof.game.character.scene {

import QFLib.Foundation;

import flash.events.Event;

import kof.game.bubbles.IBubblesFacade;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.core.CSubscribeBehaviour;
import kof.game.level.ILevelFacade;

/**
 * 头顶冒泡组件
 *
 */
public class CBubblesMediator extends CSubscribeBehaviour {

    /** @private */
    private var m_pBubblesFacade : IBubblesFacade;

    public function CBubblesMediator( pLevelFacade : ILevelFacade ) {
        super( "bubbles" );
        this. m_pBubblesFacade = pLevelFacade.getBubblesFacade();
    }

    override public function dispose() : void {
        super.dispose();
        this.m_pBubblesFacade = null;
    }

    public function bubblesTalk( value:String, time:int, position:int = 0, x:int = 0,y:int = 0, hideCallBack:Function = null, type:int = 0):void{
        if(value == ""){
            Foundation.Log.logErrorMsg("冒泡内容为空!!!");
            return;
        }
        m_pBubblesFacade.bubblesTalk(owner, value, time, position, x, y ,hideCallBack, type);
        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.REMOVED, removedFun );
        }
    }

    private function removedFun(event:Event):void{
        event.currentTarget.removeEventListener( CCharacterEvent.READY, removedFun );
        hideTalk();
    }

    public function hideTalk():void{
        if(owner){
            m_pBubblesFacade.hideTalk(owner);
        }
    }
}
}
