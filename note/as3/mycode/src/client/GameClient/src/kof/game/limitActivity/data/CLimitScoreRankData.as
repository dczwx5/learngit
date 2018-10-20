/**
 * Created by Maniac on 2017/8/17.
 */
package kof.game.limitActivity.data {

import QFLib.Foundation.CMap;

import kof.data.CObjectData;

public class CLimitScoreRankData extends CObjectData{

    private var _lenth:int;

    public function CLimitScoreRankData(len:int = 20) {
        super();

        _lenth = len;
        resetData();
    }

    override public function updateDataByData( data : Object ) : void {
//        super.updateDataByData( data );
        if (!data) return ;
        resetData();
        for each(var obj:Object in data){
            var itemData:CLimitScoreRankItemData = new CLimitScoreRankItemData();
            itemData.updateDataByData(obj);
            _data[itemData.roleRank] = itemData;
        }
    }

    public function get rankInfos() : Array {
        return _data.toArray();
    }

    public function resetData():void{
        _data = new CMap();
        for(var i:int = 1; i <= _lenth; i++){
            var data:CLimitScoreRankItemData = new CLimitScoreRankItemData();
            data.roleID = 0;
            data.roleName = "";
            data.roleRank = i;
            data.roleScore = 0;
            _data[i] = data;
        }
    }

    public function get lenth() : int {
        return _lenth;
    }

    public function set lenth( value : int ) : void {
        _lenth = value;
    }
}
}
