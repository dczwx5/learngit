//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/5/22.
 */
package kof.game.bossChallenge {

import flash.utils.Dictionary;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bossChallenge.data.CBossChallengeRewardData;
//import kof.game.bossChallenge.treeUI.SynthTreeVO;
import kof.game.im.CIMManager;
import kof.game.im.CIMSystem;
import kof.game.im.data.CIMFriendsData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.CooperationBossBase;
import kof.table.CooperationBossConstant;
import kof.table.CooperationBossProperty;
import kof.table.GamePrompt;
import kof.table.Item;

public class CBossChallengeManager extends CAbstractHandler{
    private var _constTable : IDataTable; //常量配置
    private var _baseTable : IDataTable;  //基础数据
    private var _configTable : IDataTable;//boss配置
    private var _costItem : Item;         //当前使用的挑战券
    private var _bossID : int;            //当前bossID
    private var _helper : Object;         //协助者信息
    private var _requesterName : String;  //请求者名字
    private var _requesterID : int;       //请求者ID
    private var _needPower : int = -1;    //邀请战力
    private var _helperHeroID : int = 0;  //协助者提供的格斗家ID
    private var _rewardCount : int;       //协助者可领取奖励次数
    private var _recommendHero : CPlayerHeroData;//推荐上阵格斗家
    private var _victoryData : CBossChallengeRewardData;//胜利结算数据
    private var _isDirectInvite : Boolean;  //是否来自俱乐部
    public function CBossChallengeManager() {
        super();
    }
    override public function dispose() : void
    {
        super.dispose();
        _costItem = null;
        _bossID = 0;
        _helper = null;
        _requesterName = null;
        _requesterID = 0;
        _needPower = -1;
        _helperHeroID = 0;
        _rewardCount = 0;
        _victoryData = null;
        _recommendHero = null;
    }

    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        _baseTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.BOSS_CHALLENGE_BASE);
        _configTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.BOSS_CHALLENGE_PROP);
        _constTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.BOSS_CHALLENGE_CONST);
        return ret;
    }
    public function get constTable() : CooperationBossConstant
    {
        var data : CooperationBossConstant = _constTable.findByPrimaryKey(1);
        return data;
    }
    public function getConstTableByBossID(bossID : int) : int
    {
        var arr : Array = constTable.filterBattleValue.split(",");
        return arr.length >= bossID ? arr[bossID - 1] : 1;
    }
    public function get baseTable() : CooperationBossBase
    {
        var data : Array = _baseTable.findByProperty("ID",bossID);
        for each(var item : CooperationBossBase in data) {
            if ( bossID == item.ID ) {
                return item;
            }
        }
        return null;
    }
    /**
     * 获取boss属性配置
     */
    public function get configTable():CooperationBossProperty{
        var lvl:int = _playerData.teamData.level;
        var data : Array = _configTable.findByProperty("ID",lvl);
        for each(var item : CooperationBossProperty in data) {
            if ( lvl == item.ID ) {
                return item;
            }
        }
        return null;
    }
    /**
     * 读取奖励列表
     * @return
     */
    public function getItemForItemID( id : int ) : Item {
        var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
        return itemTable.findByPrimaryKey( id );
    }
    /**
     * 使用了哪个挑战券
     * @param itemID
     */
    public function setCostItem( itemID : int ) : void
    {
        _costItem = (_bagSystem.getBean(CBagManager) as CBagManager).getItemTableByID(itemID);
        if(!_costItem)
        {
            trace("This is an Error!");
            return;
        }

        _bossID = int( _costItem.param2 );
    }
    public function get costItem() : Item
    {
        return _costItem;
    }
    public function get costNum() : int
    {
        var pBagData : CBagData = (_bagSystem.getBean(CBagManager) as CBagManager).getBagItemByUid(costItem.ID);
        if(pBagData)
                return pBagData.num;
        else
                return 0;
    }
    public function set bossID(value : int) : void
    {
        if(_bossID != value)
            _bossID = value;
    }
    public function get bossID() : int
    {
        return _bossID;
    }

    public function setHelperData(roleID:int,roleName:String,heroID:int,power:int,star:int) : void
    {
        _helper ||= new Object();
        _helper.roleID = roleID;
        _helper.roleName = roleName;
        _helper.heroID = heroID;
        _helper.power = power;
        _helper.star = star;
    }
    public function getHelperData() : Object
    {
        return _helper;
    }

    /**
     * 收到邀请弹出出阵界面
     * @param name    邀请者名字
     */
    public function set requesterName(name:String) : void
    {
        _requesterName = name;
    }
    public function get requesterName() : String
    {
        return _requesterName;
    }

    public function set requesterID(value : int) :void
    {
        _requesterID = value;
    }
    public function get requesterID() : int
    {
        return _requesterID;
    }
    public function set rewardCount(value : int) :void
    {
        _rewardCount = value;
    }
    public function get rewardCount() : int
    {
        //这里是剩余的次数
        return baseTable.CooperatorRewardLimit - _rewardCount;
    }

    /**
     * 获取格斗家列表
     */
    public function getHeroListByPower(power : int = 0):Array
    {
        var heroList : Array = _playerData.heroList.getSortList(0);
        var result : Array = [];
        for(var i : int = 0; i < heroList.length; i++)
        {
            if(heroList[i ].battleValue >= power)
            {
                result.push(heroList[i ]);
            }
        }
        result.sortOn("battleValue",Array.NUMERIC|Array.DESCENDING);
        return result;
    }

    /**
     * 获得格斗家分页（协助者用）
     */
    public function getHeroListByPage(page:int) : Array
    {
        var heroList : Array = getHeroListByPower(needPower);
        var result : Array = [];

        for(var i:int = 0; i < heroList.length; i++)
        {
            if(page == 0)
            {
                result.push(heroList[i ]);
            }
            else if(heroList[i ].job == (page - 1) )//全攻防技0123，而攻防技对应012，所以要-1
            {
                result.push(heroList[i ]);
            }
        }
        return result;
    }

    /**
     * 提供出阵的格斗家ID
     * @param value
     */
    public function set helperHeroID(value:int) : void
    {
        _helperHeroID = value;
    }
    public function get helperHeroID() : int
    {
        return _helperHeroID;
    }

    public function set recommendHero(value:CPlayerHeroData) : void
    {
        _recommendHero = value;
    }
    public function get recommendHero() : CPlayerHeroData
    {
        if(_recommendHero)
        {
            return _recommendHero;
        }
        else  //获取自身最强格斗家
        {
            var temp : CPlayerHeroData;
            var heroList : Array = _playerData.heroList.getSortList(0);
            for each( var item : CPlayerHeroData in heroList )
            {
                if(!temp || item.battleValue > temp.battleValue)
                    temp = item;
            }
            _recommendHero =  temp;
        }
        return _recommendHero;
    }

    /**
     * 读取好友列表
     * @return
     */
    public function getFriendListData(power:int) : Array
    {
        var result : Array = [];
        var list : Array = _imManager.getFriendList();
        var item : CIMFriendsData;
        for(var i : int = 0; i < list.length; i++)
        {
            item = list[i] as CIMFriendsData;
            if(item.isOnline && item.battleValue >= power)
            {
                result.push(item);
            }
        }
        result.sortOn("battleValue",Array.NUMERIC|Array.DESCENDING);
        if(result.length > 4)//此处特殊处理，如果好友列表超过4个，填充一个空数据，使最后一个好友可以向上滚动
        {
            item = null;
            result.push(item);
        }
        return result;
    }

    /**
     * 推荐战力
     */
    public function get configPower() : int
    {
        if(bossID <= 0) return 0;
        return configTable["SuggestBattleValue" + bossID];
    }
    /**
     * 邀请战力
     */
    public function set needPower(value : int) :void
    {
        if(value > -1)
            _needPower = value;
    }
    public function get needPower() : int
    {
        if(_needPower == -1 && bossID > 0)
            return configTable["SuggestBattleValue" + bossID];
        return _needPower;
    }
    public function setResultData(data : Object) : void
    {
        _victoryData ||= new CBossChallengeRewardData();
        _victoryData.updateDataByData(data);
    }
    public function getResultData() : CBossChallengeRewardData
    {
        return _victoryData;
    }

    public function getGamePromptStr(gamePromptID:int):String {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.GAME_PROMPT);
        var configInfo:GamePrompt = pTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        var pStr:String = null;
        if(configInfo){
            pStr = configInfo.content;
        }
        return pStr;
    }
    private var _timeDic:Dictionary;
    public function setStartTime(id:int,time:Number) : void
    {
        _timeDic ||= new Dictionary();
        var obj:Object = _timeDic[id] ? _timeDic[id] : new Object();
        obj.startTime = time;
        _timeDic[id] = obj;
    }
    public function getTimeDicByID(id:int) : Object
    {
        _timeDic ||= new Dictionary();
        return _timeDic[id];
    }

    public function set isDirectInvite(value:Boolean) : void
    {
        _isDirectInvite = value;
    }
    public function get isDirectInvite() : Boolean
    {
        return _isDirectInvite;
    }

    public function getBossPropByID(id : int):CooperationBossProperty
    {
        var data : Array = _configTable.findByProperty("ID",id);
        for each(var item : CooperationBossProperty in data) {
            if ( id == item.ID ) {
                return item;
            }
        }
        return null;
    }

//    public function getTreeData(page:int=0):Array
//    {
//        var formulaList:Dictionary = _configTable.tableMap;
//        var treeData:Array = [];
//        var markDic:Dictionary = new Dictionary();
//        var conf:CooperationBossProperty;
//        var parentVO:SynthTreeVO;               //父节点
//        var childrenVO:SynthTreeVO;             //子节点
//        for each(conf in formulaList)
//        {
//            if (markDic[conf.type] == null)
//            {   //这个类型的主键还没有创建过
//                markDic[conf.type] = treeData.length;
//                parentVO = new SynthTreeVO();
//                parentVO.conf = conf;
//                parentVO.sortid = conf.type;
//                parentVO.childNodes = [];
//                treeData.push(parentVO);
//            }
//            parentVO = treeData[markDic[conf.type]];
//            childrenVO = new SynthTreeVO();
//            childrenVO.conf = conf;
//            childrenVO.sortid = conf.ID;
//            childrenVO.label = conf.TemplateID1 + "";
//            if(parentVO.childNodes.length > 3) continue;
//            parentVO.childNodes.push(childrenVO);
//            treeData[markDic[conf.type]] = parentVO;
//        }
//        treeData.sortOn("sortid", Array.NUMERIC);
//        return treeData;
//    }


    private function get _playerData() : CPlayerData
    {
        return (system.stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData;
    }
    private function get _bagSystem() : CBagSystem
    {
        return system.stage.getSystem(CBagSystem) as CBagSystem;
    }
    private function get _imSystem() : CIMSystem
    {
        return system.stage.getSystem(CIMSystem) as CIMSystem;
    }
    private function get _imManager() : CIMManager
    {
        return _imSystem.getBean(CIMManager) as CIMManager;
    }
}
}
