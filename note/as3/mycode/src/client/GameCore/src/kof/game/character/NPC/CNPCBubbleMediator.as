//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/14.
 */
package kof.game.character.NPC {

import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import kof.data.KOFTableConstants;

import kof.framework.IDataTable;

import kof.game.character.CDatabaseMediator;

import kof.game.character.scene.CBubblesMediator;

import kof.game.core.CSubscribeBehaviour;
import kof.table.NPC;

public class CNPCBubbleMediator extends CSubscribeBehaviour {

    private var m_pInBubble:Boolean;
    private var timeID:uint;
    private var index:int;
    private var m_pStartBubbleCallbackFun:Function;
    public function CNPCBubbleMediator() {
        super( "npcBubble" );
    }

    override public function dispose() : void {
        super.dispose();
        clearTimeout(timeID);
        m_pInBubble = false;
        timeID = 0;
        index = 0;
    }

    public function startBubble(_startBubbleCallbackFun:Function):void{
        if(m_pInBubble || owner == null){
            return;
        }
        m_pStartBubbleCallbackFun =_startBubbleCallbackFun;
        m_pInBubble = true;
        var pTable:IDataTable = (getComponent(CDatabaseMediator) as CDatabaseMediator).getTable(KOFTableConstants.NPC);
        var npcData:NPC = pTable.findByPrimaryKey( owner.data.prototypeID ) as NPC;
        if( npcData.bubbleInterval == 0) return;
        if(npcData.bubbleContent && npcData.bubbleContent.length){
            if(index>=npcData.bubbleContent.length){
                index = 0;
            }
            if(npcData.bubbleContent[index] != ""){
                timeID = setTimeout(showBubble, npcData.bubbleInterval*1000, npcData.bubbleContent[index]);
            }
            index ++;
        }
    }

    private function showBubble(str:String):void{
        if(owner && !m_pStartBubbleCallbackFun(-1)){
            var bubbles:CBubblesMediator = owner.getComponentByClass(CBubblesMediator, true) as CBubblesMediator;
            var pTable:IDataTable = (getComponent(CDatabaseMediator) as CDatabaseMediator).getTable(KOFTableConstants.NPC);
            var npcData:NPC = pTable.findByPrimaryKey( owner.data.prototypeID ) as NPC;
            if(bubbles){
                m_pStartBubbleCallbackFun(1);
                bubbles.bubblesTalk(str,3,npcData.bubbleOrientation,npcData.xAxis,npcData.yAxis,function():void{m_pInBubble = false;timeID = 0;m_pStartBubbleCallbackFun(0);});
            }
        }else {
            m_pInBubble = false;
            timeID = 0;
        }
    }
}
}
