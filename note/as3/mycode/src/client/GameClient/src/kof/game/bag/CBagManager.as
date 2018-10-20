//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/10/10.
 */
package kof.game.bag {

import QFLib.Foundation.CMap;
import QFLib.Foundation.CMap;
import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.bag.data.CBagData;
import kof.game.bag.data.CBagPageType;
import kof.game.chat.CChatSystem;
import kof.game.chat.data.CChatChannel;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CGetPropsViewHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.message.Item.ItemListResponse;
import kof.message.Item.ItemUpdateResponse;
import kof.table.Item;
import kof.table.ItemSequence;

public class CBagManager extends CAbstractHandler implements IUpdatable {

    private var _itemTable:IDataTable;
    private var _bagDataDic:Dictionary;
    private var _typeDic:Dictionary;
    private var _dirtyAry : Array;

    public function CBagManager() {
        super();
        _bagDataDic = new Dictionary();
        _typeDic = new Dictionary();
        _typeDic[CBagPageType.BAG_SHOW_ALL] = [];
        _typeDic[CBagPageType.BAG_EQUIP] = [];
        _typeDic[CBagPageType.BAG_MATERIAL] = [];
        _typeDic[CBagPageType.BAG_CHIP] = [];
        _typeDic[CBagPageType.BAG_OTHER] = [];
        _typeDic[CBagPageType.BAG_NOT_SHOW] = [];
        _dirtyAry = [CBagPageType.BAG_SHOW_ALL,CBagPageType.BAG_EQUIP,CBagPageType.BAG_MATERIAL,CBagPageType.BAG_CHIP,CBagPageType.BAG_OTHER];
    }

    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _itemTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ITEM);
        return ret;
    }

    public function update(delta:Number) : void {

    }


    // ====================================S2C==================================================
    public function initialBagData(response:ItemListResponse) : void {
        for each (var data:Object in response.itemList){
            updateToDic(data , true);
        }
    }
    public function updateBagData(response:ItemUpdateResponse) : void {
        for each (var data:Object in response.itemUpdateList){
            var oldNum : int ;
            var bagData : CBagData =  getBagItemByUid( data[CBagData._itemID] );
            if( bagData )
                oldNum = bagData.num;
            updateToDic(data);
            if( data[CBagData._num] > oldNum )
                (system.stage.getSystem(CChatSystem) as CChatSystem).addSystemMsg( data[CBagData._itemID] + "," + ( data[CBagData._num] - oldNum ) , CChatChannel.GETITEM );
        }
    }
    private function updateToDic( data:Object , isInit : Boolean = false):void{
        var bagData:CBagData = getBagItemByUid(data[CBagData._itemID]);
        if(!bagData){
            bagData = new CBagData();
            _bagDataDic[data[CBagData._itemID]] = bagData;
            bagData.item = getItemTableByID(data[CBagData._itemID]);
        }

        var beforeNum : int = bagData.num;
        bagData.updateDataByData(data);

        if(bagData.num == 0){
            if(bagData.item.page != -1){
                removeDataFromAry(bagData, _typeDic[bagData.item.page]);
                removeDataFromAry(bagData, _typeDic[CBagPageType.BAG_SHOW_ALL]);
            }
            _bagDataDic[bagData.itemID] = null;
        }else {
            removeDataFromAry(bagData, _typeDic[bagData.item.page]);
            _typeDic[bagData.item.page] = (_typeDic[bagData.item.page] as Array).concat(makeDataAry(data,bagData.item));
            removeDataFromAry(bagData, _typeDic[CBagPageType.BAG_SHOW_ALL]);
            _typeDic[CBagPageType.BAG_SHOW_ALL] = (_typeDic[CBagPageType.BAG_SHOW_ALL] as Array).concat(makeDataAry(data,bagData.item));
        }
        if( beforeNum <= 0 ){
            if( _dirtyAry.indexOf( bagData.item.page ) == -1 )
                _dirtyAry.push( bagData.item.page );
            if( _dirtyAry.indexOf( CBagPageType.BAG_SHOW_ALL ) == -1)
                _dirtyAry.push( CBagPageType.BAG_SHOW_ALL );
        }

        //快捷使用
        if(!isInit && beforeNum <= 0 && bagData.item.quickUse && bagData.item.useEffectScriptID != 0){
            _pCReciprocalSystem.showQuickUseView( bagData.itemID ,bagData.num, function(item:Item, useNum:int):void{
                _pBagHandler.onItemUseRequest(bagData.uid, useNum);
            } );
        }
    }

    private function removeDataFromAry(pBagData:CBagData,ary:Array):void{
        var i:int;
        for(i = 0 ; i < ary.length ; i++){
            var bagData:CBagData = ary[i];
            if(bagData.itemID == pBagData.itemID){
                ary.splice(ary.indexOf(bagData),1);
                i--;
            }
        }
    }
    //是否可以叠加。用于界面显示
    private function makeDataAry(pBagData:Object,item:Item):Array{
        var ary:Array = [];
        var i:int;
        var fullNum:int;
        var bagData:CBagData;
        if(item.canStackable){//可叠加  stackableLimit：叠加的数量
           fullNum = Math.floor(pBagData.num/item.stackableLimit);
           for( i = 0 ; i < fullNum ; i++){
               bagData = new CBagData();
               bagData.updateDataByData(pBagData);
               bagData.item = item;
               bagData.num = item.stackableLimit;
               ary.push(bagData);
           }
           if(pBagData.num % item.stackableLimit > 0){
               bagData = new CBagData();
               bagData.updateDataByData(pBagData);
               bagData.item = item;
               bagData.num = pBagData.num % item.stackableLimit;
               ary.push(bagData);
           }
        }else{
            fullNum = pBagData.num;
            for( i = 0 ; i < fullNum ; i++){
                bagData = new CBagData();
                bagData.updateDataByData(pBagData);
                bagData.item = item;
                bagData.num = 1;
                ary.push(bagData);
            }
        }
        return ary;
    }
    private function sortItem(a:CBagData,b:CBagData):int{
        if( !a || !b || !a.item || !b.item )
            return 0;

        if( a.item.type != b.item.type ){
            // ItemSequence
            var pItemSequenceMap:CMap = itemSequenceMap;
            var aSequence:int = pItemSequenceMap.find(a.item.type);
            var bSequence:int = pItemSequenceMap.find(b.item.type);
            if (aSequence == 0) {
                return 1;
            } else if (bSequence == 0) {
                return -1;
            } else {
                return aSequence - bSequence;
            }
        }else{
            if ( a.item.sortID != b.item.sortID) {
                return b.item.sortID - a.item.sortID;
            } else{
                if ( a.item.ID != b.item.ID) {
                    return a.item.ID - b.item.ID;
                } else{ //同一种物品，不同格子（超出999）
                    if( a.num > b.num ){
                        return -1;
                    }else if(a.num < b.num) {
                        return 1;
                    }else{
                        return 0
                    }
                }
            }
        }
    }
    public function getBagItemByUid(itemID:int):CBagData{
        return  _bagDataDic[itemID];
    }

    public function get bagDataDic() : Dictionary {
        return _bagDataDic;
    }

    public function getBagDataByType(type:int = 0):Array{
        if( _dirtyAry.indexOf( type ) != -1 ){
            _typeDic[type].sort(sortItem);
            _dirtyAry.splice(_dirtyAry.indexOf(type),1);
        }

        return _typeDic[type];
    }

    public function addDirtyAry( type:int = 0 ):void{
        if( _dirtyAry.indexOf( type ) == -1 )
            _dirtyAry.push( type );
    }






    // ======================================table================================================
    public function getItemTableByID(ID:int) : Item{
        return _itemTable.findByPrimaryKey(ID);
    }
    // todo fix
    public function getItemUseEffValueByID(ID:int):int{
        var item: Item = _itemTable.findByPrimaryKey(ID);
        if( item.useEffectScriptID == 3 ){
            return int(item.param4);
        }
        return 0;

    }


    // ======================================table================================================
    public function get itemSequenceMap() : CMap {
        if (!_itemSequenceMap) {
            _itemSequenceMap = new CMap();
            var pItemSequenceTable:IDataTable = itemSequenceTable;
            if (pItemSequenceTable) {
                var dataList:Vector.<Object> = pItemSequenceTable.toVector();
                for each (var record:ItemSequence in dataList) {
                    if (record) {
                        _itemSequenceMap.add(record.ID, record.type);
                    }
                }
            }
        }
        return _itemSequenceMap;
    }
    public function get itemSequenceTable() : IDataTable {
        if (!_itemSequenceTable) {
            _itemSequenceTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ItemSequence);
        }
        return _itemSequenceTable;
    }
    private var _itemSequenceTable:IDataTable;
    private var _itemSequenceMap:CMap;

    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCReciprocalSystem():CReciprocalSystem{
        return system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem;
    }

    private function get _pBagHandler():CBagHandler{
        return system.getBean( CBagHandler ) as CBagHandler;
    }



}
}
