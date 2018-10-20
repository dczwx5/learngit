//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/6/14.
 */
package kof.game.vip {

import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.player.CPlayerSystem;
import kof.table.VipLevel;
import kof.table.VipPrivilege;

public class CVIPManager extends CAbstractHandler implements IUpdatable {

    private var _vipLevelTable:IDataTable;
    private var _vipPrivilegeTable:IDataTable;

    public function CVIPManager() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _vipLevelTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.VIP_LEVEL);
        _vipPrivilegeTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.VIPPRIVILEGE);

        return ret;
    }

    public function update( delta : Number ) : void {

    }


    //============================Table=================================
    public function getVipLevelTableByID( vipLv:int ):VipLevel {
        var arr:Array = _vipLevelTable.findByProperty("level", vipLv);
        for each(var vipTb:VipLevel in arr){
            if(vipTb.level == vipLv){
                return vipTb;
            }
        }
        return null;
    }

    public function getNextVipLevelTableByID( vipLv:int ):VipLevel {
        var maxLv:int = this.getVipMaxLv();
        if( vipLv >= maxLv ){
            vipLv = maxLv;
        }
        return getVipLevelTableByID( vipLv );
    }

    public function getVipMaxLv():int {
        var vipArr:Array = _vipLevelTable.toArray();
        var maxLv:int = 0;
        for each(var vipTb:VipLevel in vipArr){
            if(vipTb.level > maxLv){
                maxLv = vipTb.level;
            }
        }
        return maxLv;
    }

    public function getVipPriTableByID( vipLv:int ):VipPrivilege {
        var arr:Array = _vipPrivilegeTable.findByProperty("level", vipLv);
        for each(var vipTb:VipPrivilege in arr){
            if(vipTb.level == vipLv){
                return vipTb;
            }
        }
        return null;
    }

    public function isCanBuyVipGift():Boolean{
        var curVipLv:int = playSystem.playerData.vipData.vipLv;
        for(var i:int = 1;i <= curVipLv; i++){
            if(!isBuyGift(i)){
                return true;
            }
        }
        return false;
    }

    /**
     * 是否已经购买VIP等级礼包
     * @param vipLv vip等级
     * @return
     */
    public function isBuyGift( vipLv:int ):Boolean {
        var getArr:Array = playSystem.playerData.vipData.vipGifts;
        for each(var lv:int in getArr){
            if( lv == vipLv ){
                return true;
            }
        }
        return false;
    }

    public function getHeroIds():Array {
        var vipArr:Array = _vipLevelTable.toArray();
        var idsArr:Array = [];
        for each(var vipTb:VipLevel in vipArr){
            if(vipTb.heroID > 0){
                idsArr.push(vipTb);
            }
        }
        idsArr.sortOn("level",Array.NUMERIC);
        return idsArr;
    }

    /**
     * 是否已经领取VIP等级免费礼包
     * @param vipLv vip等级
     * @return
     */
    public function isGetFreeGift( vipLv:int ):Boolean {
        var getArr:Array = playSystem.playerData.vipData.vipRewards;
        for each(var lv:int in getArr){
            if( lv == vipLv ){
                return true;
            }
        }
        return false;
    }
    /**
     * 是否已经领取VIP等级每日礼包
     * 这里校验有问题，应是数组中有数据表示已领取，为空表示未领取
     * @param vipLv vip等级
     * @return
     */
    public function isGetEverydayReward( vipLv:int ):Boolean {
        var getArr:Array = playSystem.playerData.vipData.vipEverydayReward;
//        for each(var lv:int in getArr){
//            if( lv == vipLv ){
//                return true;
//            }
//        }
        return getArr.length > 0;
    }

    /**
     * 当前VIP等级可以进行公会钻石投资的次数
     */
    public function getClubVIPInvestCount() : int
    {
        var lvl : int = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.vipData.vipLv;
        var lvlData : VipLevel = getVipLevelTableByID(lvl);
        if(lvlData) return lvlData.clubInvestCounts;
        else return 0;
    }
    //================================================================
    public function get playSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }



}
}
