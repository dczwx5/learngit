//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/12/7.
 */
package kof.game.reciprocation.popWindow {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.table.SequenceOfPopup;

/**
 * 窗口队列管理（同时出现多个窗口，按优先级依次显示）
 */
public class CEventPopWindowHandler extends CViewHandler {

    private var m_popWinList:Array;

    public function CEventPopWindowHandler() {
        super( false );
        m_popWinList = [];
    }

    public override function dispose():void {
        super.dispose();
        _instanceSystem.removeEventListener(CInstanceEvent.LEVEL_ENTERED, _onEnterLevel);

    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();
        _instanceSystem.addEventListener(CInstanceEvent.LEVEL_ENTERED, _onEnterLevel);
        return ret;
    }

    public function addView(viewId:int,showFunc:Function,subType : int = 0):void{
        if(viewId <= 0)return;
        var obj:Object = new Object();
        obj.viewId = viewId;
        obj.showFunc = showFunc;
        obj.priorityValue = getPopupTable(viewId ).sequence;
        obj.subType = subType;
        if(m_popWinList.length <= 0  && _instanceSystem.isMainCity){
            //如果列表没有并且是在主城，直接显示
            if(showFunc){
                showFunc();
            }
            m_popWinList.push(obj);
        }else{
            m_popWinList.push(obj);
            sortView();
        }
    }

    public function removeView(viewId:int):void{

        if(viewId <= 0) return;

        var sTabel:SequenceOfPopup = getPopupTable(viewId);
        if(sTabel){
            var index:int = 0;
            for each(var obj:Object in m_popWinList){
                if(obj.viewId == viewId){
                    index = m_popWinList.indexOf(obj);
                    m_popWinList.splice(index,1);
                    break;
                }
            }
            callLater(_showNextView);
        }
    }

    private function _showNextView():void{
        var viewData:Object = nextView();
        if(viewData && viewData.showFunc){
            var showFunc:Function = viewData.showFunc;
            showFunc();
        }
    }

    public function nextView():Object {
        return m_popWinList.length > 0 ? m_popWinList[0]:null;
    }

    private function _onEnterLevel( e:CInstanceEvent ):void {
        if (_instanceSystem.isMainCity) {
            var viewData:Object = nextView();
            if(viewData && viewData.showFunc){
                var showFunc:Function = viewData.showFunc;
                showFunc();
            }
        }
    }

    public function getEventPopListLength():int{
        return m_popWinList.length;
    }

    private function sortView():void{
        m_popWinList.sortOn(["priorityValue","subType"],[Array.NUMERIC, Array.NUMERIC]);
    }

    private function getPopupTable( popId:int ):SequenceOfPopup {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.SEQUENCEOFPOPUP);
        var info:SequenceOfPopup = pTable.findByPrimaryKey( popId );
        return info;
    }

    private function get _instanceSystem() : CInstanceSystem {
        return (system.stage.getSystem(CInstanceSystem) as CInstanceSystem);
    }

}
}
