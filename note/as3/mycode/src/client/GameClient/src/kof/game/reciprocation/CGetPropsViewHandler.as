//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/3/30.
 */
package kof.game.reciprocation {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.item.CItemData;
import kof.table.Item;
import kof.ui.CUISystem;
import kof.ui.master.messageprompt.MPCallUI;

/**
 * 获取道具、碎片提示框
 * @author Maniac (maniac@qifun.com)
 */
public class CGetPropsViewHandler extends CViewHandler {

    private var _itemData : CItemData = new CItemData();
    private var m_QuickUsePools:Vector.<CQuickUse> = new Vector.<CQuickUse>();
    private var m_QuickMaxNum:int = 5;

    private var m_waitVec:Vector.<Object> = new Vector.<Object>();
    private var _isWaitShow:Boolean = false;//是否立即显示
    private var _isStart:Boolean = false;

    public function CGetPropsViewHandler() {
        super( false ); // load view by default to call onInitializeView
    }

    override public function dispose() : void {
        super.dispose();
    }

    private function getPropsFromPools():CQuickUse{
        var view:CQuickUse = null;
        if(m_QuickUsePools.length >= m_QuickMaxNum){
            view = m_QuickUsePools[0];
            m_QuickUsePools.splice(0,1);
        }else{
            view = new CQuickUse(this);
            m_QuickUsePools.push(view);
        }
        view.initView();
        return view;
    }

    override public function get viewClass() : Array {
        return [ MPCallUI ];
    }

    override protected function get additionalAssets():Array {
        return ["erjikuang.swf"];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        return true;
    }

    public function show( id : int, num : int, completeBackFunc : Function = null ) : void {
        this.loadAssetsByView( viewClass, function():void{
            if ( onInitializeView() ) {
                invalidate();
                var view:CQuickUse = getPropsFromPools();
                var item : Item = getItemTableByID( id );
                _itemData.itemRecord = item;

                if(_isWaitShow){
                    var objData:Object = new Object();
                    objData.num = num;
                    objData.item = item;
                    objData.func = completeBackFunc;
                    m_waitVec.push(objData);
                }else{
                    if ( view ) {
                        view.show(uiCanvas,item,num,completeBackFunc,system);
                    }
                }

            } else {
                // Show warning, error, etc.
                LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
            }
        } );
    }

    private function startWaitShow():void {
        _isStart = true;
        while(m_waitVec.length > 0){
            var data:Object = m_waitVec[0];
            m_waitVec.splice(0,1);

            var view:CQuickUse = getPropsFromPools();
            if ( view ) {
                view.data = data;
                view.show(uiCanvas,data.item,data.num,data.func,system);
            }
        }

        if(m_waitVec.length == 0){
            _isStart = false;
        }
    }

    public function getWaitVec():Vector.<Object>{
        return m_waitVec;
    }

    // ======================================table================================================
    public function getItemTableByID( id : int ) : Item {
        var itemTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.ITEM );
        return itemTable.findByPrimaryKey( id );
    }

    public function get isWaitShow() : Boolean {
        return _isWaitShow;
    }

    public function set isWaitShow( value : Boolean ) : void {
        _isWaitShow = value;
        if(!_isWaitShow){
            if(_isStart)return;
            startWaitShow();
        }
    }
}

}

