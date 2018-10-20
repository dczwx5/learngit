//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/24.
 */
package kof.game.player.view.playerNew.util {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bag.CBagManager;
    import kof.game.bag.CBagSystem;
    import kof.game.bag.data.CBagData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CHeroEquipData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.teaching.CTeachingInstanceManager;
import kof.game.teaching.CTeachingInstanceSystem;
import kof.table.SkillEmitterConsume;
import kof.table.SkillPositionRate;
import kof.table.SkillQualityRate;
import kof.table.SkillUpConsume;

/**
 * 小红点提示
 */
public class CPlayerTipHandler extends CAbstractHandler {
    public function CPlayerTipHandler()
    {
        super();
    }

    /**
     * 整个养成系统是否有可培养的操作项
     * @return
     */
    public function isCanDevelop():Boolean
    {
        var list:Array = _playerData.displayList;

        var existFilter:Function = function (item:CPlayerHeroData, idx:int, arr:Array) : Boolean {
            return item.hasData || (item.hasData == false && item.enoughToHire);
        };

//        var heroList:Array = (system as CPlayerSystem).playerData.heroList.list;
        var heroList:Array = list.filter(existFilter);
        for each(var heroData:CPlayerHeroData in heroList)
        {
            if(!heroData)
            {
                continue;
            }

            if(!heroData.hasData && heroData.enoughToHire)
            {
                return true;
            }
            else if(isHeroCanDevelop(heroData ) || teachingRedPoint())
            {
                return true;
            }
        }

        return false;
    }

    private function teachingRedPoint():Boolean{
        var _system:CTeachingInstanceSystem = (system as CPlayerSystem).stage.getSystem(CTeachingInstanceSystem) as CTeachingInstanceSystem;
        var _manager:CTeachingInstanceManager = _system.getHandler(CTeachingInstanceManager) as CTeachingInstanceManager;
        return _manager.onAllRedPoint();
    }

    /**
     * 某个格斗家是否可培养(养成、装备培养、招式提升)
     * @return
     */
    public function isHeroCanDevelop(heroData:CPlayerHeroData):Boolean
    {
        if(heroData)
        {
            return isHeroCanBaseDevelop(heroData) || isEquipCanDevelop(heroData) || isSkillCanDevelopInEmbattle(heroData);
        }

        return false;
    }

    private function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    public function isHeroCanHire(heroData:CPlayerHeroData):Boolean
    {
        return !heroData.hasData && heroData.enoughToHire;
    }

    public function isHeroCanBaseDevelop(heroData:CPlayerHeroData):Boolean
    {
        if(_playerHelper.isHeroCanStarAdvance(heroData))
        {
            return true;
        }
        else if(!_playerHelper.isHeroInEmbattle(heroData.prototypeID))
        {
            return false;
        }

        return _playerHelper.isHeroCanDevelop(heroData);
    }

    /**
     * 某个格斗家是否有装备可培养
     * @return
     */
    public function isEquipCanDevelop(heroData:CPlayerHeroData):Boolean{

        if(!_playerHelper.isHeroInEmbattle(heroData.prototypeID))
        {
            return false;
        }

        var arr:Array = heroData.equipList.toArray();
        var len:int=arr.length;
        for(var i:int=0;i<arr.length;i++){
            if( _judgeRedPt(arr[i])){
                return true;
            }
        }
        return false;
    }

    private function _judgeRedPt( data : CHeroEquipData) : Boolean {
        if(data == null)
        {
            return false;
        }

        if(!_isEquipOpen(data))
        {
            return false;
        }

        if ( _isCanUpLv( data) ) {
            return true;
        }
        if ( _isCanUpQulity( data) ) {
            return true;
        }
        return _isCanUpStar( data);
    }

    protected function _isCanUpLv( data : CHeroEquipData) : Boolean {
        if(!_playerHelper.isChildSystemOpen(KOFSysTags.EQP_STRONG))
        {
            return false;
        }

        if ( data.level + 1 > (system as CPlayerSystem).playerData.teamData.level )return false;
        if(data.isCanLevelUp()==false)return false;
        if ( data.part > 4 ) {// 后面两件装备
            if(!_isEquipOpen(data))
            {
                return false;
            }

            if ( data.nextLevelGoldCost <= (system as CPlayerSystem).playerData.currency.gold ) {
                if ( data.nextLevelOtherCurrencyType == 10 ) {
                    if ( data.nextLevelOtherCurrencyCost <= (system as CPlayerSystem).playerData.equipData.huizhang ) {
                            return true;
                    }
                }
                if ( data.nextLevelOtherCurrencyType == 11 ) {
                    if ( data.nextLevelOtherCurrencyCost <= (system as CPlayerSystem).playerData.equipData.miji ) {
                            return true;
                    }
                }
            }
        }else if ( data.isCanLevelUp() ) {
            if ( data.nextLevelGoldCost <= (system as CPlayerSystem).playerData.currency.gold ) {
                return true;
            }
        }
        return false;
    }

    protected function _isCanUpQulity( data : CHeroEquipData ) : Boolean {
        if(!_playerHelper.isChildSystemOpen(KOFSysTags.EQP_STRONG))
        {
            return false;
        }

        if(data.isCanLevelUp())return false;
        if ( data.level + 1 > (system as CPlayerSystem).playerData.teamData.level )return false;
        if ( data.part > 4 ) {
            if(!_isEquipOpen(data))// 后面两件装备
            {
                return false;
            }

            if ( data.nextQualityGoldCost <= (system as CPlayerSystem).playerData.currency.gold ) {
                if ( data.nextQualityOtherCurrencyType == 10 ) {
                    if ( data.nextQualityOtherCurrencyCost <= (system as CPlayerSystem).playerData.equipData.huizhang ) {
                        if ( isCanQuality( data ) ) {
                            return true;
                        }
                    }
                }
                if ( data.nextQualityOtherCurrencyType == 11 ) {
                    if ( data.nextQualityOtherCurrencyCost <= (system as CPlayerSystem).playerData.equipData.miji ) {
                        if ( isCanQuality( data ) ) {
                            return true;
                        }
                    }
                }
            }
        }else if ( data.nextQualityGoldCost <= (system as CPlayerSystem).playerData.currency.gold ) {
            if ( isCanQuality( data ) ) {
                return true;
            }
        }
        return false;
    }

    private function isCanQuality( data : CHeroEquipData ) : Boolean {
        if(!_playerHelper.isChildSystemOpen(KOFSysTags.EQP_STRONG))
        {
            return false;
        }

        var bagDataVec : Vector.<CBagData> = data.nextQualityItemCost;
        for each ( var value : CBagData in bagDataVec ) {
            var hasBagData : CBagData = ((system.stage.getSystem(CBagSystem) as CBagSystem).getBean(CBagManager) as CBagManager).getBagItemByUid( value.itemID );
            if ( hasBagData ) {
                if ( hasBagData.num < value.num ) {
                    return false;
                }
            } else {
                return false;
            }
        }
        return true;
    }

    protected function _isCanUpStar( data : CHeroEquipData ) : Boolean {
        if(!_playerHelper.isChildSystemOpen(KOFSysTags.EQP_BREAK))
        {
            return false;
        }

        if ( data.nextAwakenTeamLevelNeed > (system as CPlayerSystem).playerData.teamData.level )return false;
        var hasBagData : CBagData = null;
        var bagManager:CBagManager = ((system.stage.getSystem(CBagSystem) as CBagSystem).getBean(CBagManager) as CBagManager);
        if ( data.isExclusive ) {
            hasBagData = bagManager.getBagItemByUid( data.awakenSoulID ); //当前拥有
            if ( hasBagData ) {
                if ( hasBagData.num >= data.nextAwakenSoulCost ) {
                    hasBagData = bagManager.getBagItemByUid( data.nextAwakenStoneType ); //当前拥有
                    if ( hasBagData ) {
                        if ( hasBagData.num >= data.nextAwakenStoneCost ) {
                            if ( data.nextAwakenGoldCost <= (system as CPlayerSystem).playerData.currency.gold ) {
                                return true;
                            }
                        }
                    }
                }
            }
        } else {
            hasBagData = bagManager.getBagItemByUid( data.nextAwakenStoneType ); //当前拥有
            if ( hasBagData ) {
                if ( hasBagData.num >= data.nextAwakenStoneCost ) {
                    if ( data.nextAwakenGoldCost <= (system as CPlayerSystem).playerData.currency.gold ) {
                        if(data.part>4){

                            return false;// 盾徽和秘卷不开启觉醒功能

                            if(!_isEquipOpen(data))// 后面两件装备
                            {
                                return false;
                            }

                            if ( data.nextAwakenCurrencyType == 10 ) { //徽章
                                if ( data.nextAwakenCurrencyCount <= (system as CPlayerSystem).playerData.equipData.huizhang ) {
                                    return true;
                                }
                            }
                            if ( data.nextAwakenCurrencyType == 11 ) {//秘籍
                                if ( data.nextAwakenCurrencyCount <= (system as CPlayerSystem).playerData.equipData.miji ) {
                                    return true;
                                }
                            }
                        }else{
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    /**
     * 装备是否已开启
     * @param equipData
     * @return
     */
    private function _isEquipOpen(equipData:CHeroEquipData):Boolean
    {
        if(equipData)
        {
            var sysTag:String = equipData.getSysTag();
            return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(sysTag);
        }

        return false;
    }

    /**
     * 当前出战格斗家中是否有可提升的技能
     * @param heroData
     * @return
     */
    public function isSkillCanDevelopInEmbattle(heroData:CPlayerHeroData):Boolean
    {
        if(!_playerHelper.isHeroInEmbattle(heroData.prototypeID))
        {
            return false;
        }

        return isSkillCanDevelop(heroData);
    }

    /**
     * 某个格斗家是否有可以技能升级或者技能突破
     * @return
     */
    public function isSkillCanDevelop(heroData:CPlayerHeroData):Boolean{

        if(!_playerHelper.isChildSystemOpen(KOFSysTags.SKIL_LEVELUP))
        {
            return false;
        }

//        if(!_playerHelper.isHeroInEmbattle(heroData.prototypeID))
//        {
//            return false;
//        }

        //
        var skillAry:Array = _playerData.heroList.getHero( heroData.prototypeID ).skillList.list;
        if( skillAry ){
            var skillData : CSkillData;
            for each ( skillData in skillAry ){
                if( skillData.skillPosition <= 5 ){
                    continue;//这里策划不展示主动技能
                }
                if( canLvUpFlg( skillData ,heroData ) || canBreachFlg( skillData , heroData) ){
                    return true;
                }
            }
        }
        return false;
    }

    //是否可以招式提升
    private function canLvUpFlg( skillData : CSkillData ,heroData : CPlayerHeroData ):Boolean{
        var pTable : IDataTable;
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_UP_CONSUME );
        var skillUpConsume : SkillUpConsume = pTable.findByPrimaryKey( skillData.skillLevel );
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_POSITION_RATE );
        var skillPositionRate : SkillPositionRate = pTable.findByPrimaryKey( skillData.skillPosition );
        pTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_QUALITY_RATE );
        var skillQualityRate : SkillQualityRate = pTable.findByPrimaryKey( heroData.qualityBase );
        var needGold : int = Math.ceil( skillUpConsume.goldConsumeNum * (skillPositionRate.goldConsumeRate / 10000 ) * (skillQualityRate.goldConsumeRate / 10000 ) );
        var needSkillPoint : int = Math.ceil( skillUpConsume.skillConsumeNum * (skillPositionRate.skillConsumeRate / 10000 ) * (skillQualityRate.skillConsumeRate / 10000 ) );
        if(  _playerData.currency.gold < needGold ){
            return false;
        }
        if( _playerData.skillData.skillPoint < needSkillPoint ){
            return false;
        }
        if( heroData.level <= skillData.skillLevel ){
            return false;
        }

        //新加规则
        if( _playerData.teamData.level < 20 && _playerData.skillData.skillPoint < 10 )
            return false;

        if( _playerData.teamData.level >= 20 && _playerData.skillData.skillPoint < 20 )
            return false;

        return true;
    }


    private function canBreachFlg( skillData : CSkillData  ,heroData : CPlayerHeroData ):Boolean{

        if( _playerData.teamData.level < 30){// 战队等级30级才开放能量突破 todo :读表-
            return false;
        }
        var activeObjAry : Array = [];
        var obj : Object;
        for each( obj in skillData.slotListData.list ){
            if( obj.isActive && !obj.isBreak ){
                activeObjAry.push( obj );
            }
        }
        if( activeObjAry.length <= 0 ){// 没有突破状态的点
            return false;
        }

        var curConsume : SkillEmitterConsume;
        var skillPointEnoughObjAry : Array = [];
        for each( obj in activeObjAry ){
            curConsume = getBreachConsume( skillData ,obj.position, heroData );
            if( _playerData.skillData.skillPoint >= curConsume.skillConsumeNum ){
                skillPointEnoughObjAry.push( obj );
            }
        }

        if( skillPointEnoughObjAry.length <= 0 ){// 没有满足足够招式点的点
            return false;
        }

        var itemEnoughObjAry : Array = [];
        var itemEnoughFlg : Boolean;
        for each( obj in skillPointEnoughObjAry ){
            curConsume = getBreachConsume( skillData ,obj.position ,heroData);
            var bagData : CBagData;
            var itemObj : Object;
            itemEnoughFlg = true;
            for( var i : int  = 1 ; i <= 2 ; i++ ){
                itemObj = {};
                itemObj.ID = curConsume['item' + i];
                itemObj.num = curConsume['count' + i];
                if( itemObj.ID != 0 && itemObj.num != 0){
                    bagData = _bagManager.getBagItemByUid( itemObj.ID );
                    if( !bagData || bagData.num < itemObj.num ){
                        itemEnoughFlg = false;
                        break;
                    }
                }
            }
            if( itemEnoughFlg ){
                itemEnoughObjAry.push( obj );
            }
        }

        if( itemEnoughObjAry.length <= 0 ){// 没有满足足够道具的点
            return false;
        }

        var goldEnoughObjAry : Array = [];
        var goldEnoughFlg : Boolean;
        for each( obj in itemEnoughObjAry ){
            curConsume = getBreachConsume( skillData ,obj.position ,heroData);
            if( curConsume.goldConsumeNum <= _playerData.currency.gold ){
                goldEnoughObjAry.push( obj );
            }
        }

        if( goldEnoughObjAry.length <= 0 ){// 没有满足足够金币的点
            return false;
        }

        return true;
    }

    private function getBreachConsume( skillData : CSkillData , position : int ,heroData : CPlayerHeroData  ):SkillEmitterConsume{
        var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.SKILL_EMITTER_CONSUME );
        var item : SkillEmitterConsume;
        var curConsume : SkillEmitterConsume;
        var tableAry : Array = pTable.toArray();
        for each ( item in tableAry ){
            if( position ==  item.skillEmitterLevel &&
                    skillData.skillPosition == item.skillPositionID &&
                    heroData.qualityBase == item.Quality
            ){
                curConsume = item;
                break;
            }
        }
        return curConsume;
    }




    //////////////////////////////////////////


    private function get _databaseSystem():CDatabaseSystem {
        return  system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _bagManager() : CBagManager {
        return _bagSystem.getBean( CBagManager ) as CBagManager;
    }
    private function get _bagSystem() : CBagSystem {
        return system.stage.getSystem(CBagSystem) as CBagSystem;
    }
}
}
