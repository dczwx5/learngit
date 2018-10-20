//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/1/22.
 * Time: 10:59
 */
package kof.game.diamondRoulette.view {

import flash.events.MouseEvent;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CRewardUtil;
import kof.game.diamondRoulette.CReturnDiamondSystem;
import kof.game.diamondRoulette.CReturnDiamondViewHandler;
import kof.game.diamondRoulette.commands.CInvestCommand;
import kof.game.diamondRoulette.commands.COpenViewCommand;
import kof.game.diamondRoulette.control.CAbstractControl;
import kof.game.diamondRoulette.models.CRDNetDataManager;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.table.DiamondRouletteConfig;
import kof.table.DiamondRouletteConst;
import kof.table.RechargeExtraCounts;
import kof.ui.master.DiamondRoulette.DiamondRoulettemainUI;
import kof.ui.master.DiamondRoulette.DiamondtipsUI;
import morn.core.components.Box;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.Label;
import morn.core.components.LinkButton;

import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/1/22
 */
public class CRDView extends CAbstractView {
    private var _viewUI : DiamondRoulettemainUI = null;
    private var _ruleView : DiamondtipsUI = null;
    private var _openViewCMD : COpenViewCommand = null;
    private var _investCMD : CInvestCommand = null;
    private var _timeStamp : Number = 0;
    private var _timeStampIntervelID : int = 0;

    private var _lastBindDiamond:int=0;
    private var _getRewardDiamond:int=0;//本次获得的奖励钻石
    private var _canClick:Boolean = true;
    private var rewardState:Boolean = false;
    private var rewardStateCount:int = 0;
    private var openState:Boolean = false;
    private var num1state:int = 0;
    private var num2state:int = 0;
    private var num3state:int = 0;
    private var num4state:int = 0;
    private var num5state:int = 0;
    private var num1count:int = 0;
    private var num2count:int = 0;
    private var num3count:int = 0;
    private var num4count:int = 0;
    private var num5count:int = 0;
    private var numy:int = 0;

    private var _isReceived : Boolean;
    private var _interval : uint;
    public function CRDView( control : CAbstractControl ) {
        super( control );
        _ruleView = new DiamondtipsUI();
        _viewUI = new DiamondRoulettemainUI();
        _viewUI.btn.clickHandler = new Handler( _openRuleView );
        _viewUI.ok.clickHandler = new Handler( _executeInvest );
        _viewUI.closeHandler = new Handler( _close );
        _ruleView.closeHandler = new Handler( _closePopup );
        _viewUI.list.renderHandler = new Handler(_renderItem);
        _viewUI.list.dataSource = [];
        _viewUI.numRun.mask = _viewUI.img_mask;
        _viewUI.movie_result.visible = false;
        _viewUI.movie_result.stop();
    }

    private function _renderItem(item:Component,idx:int):void{
        var ui:Box = item as Box;
        var data:Object = item.dataSource;
        if(!data)return;
        (ui.getChildByName("name") as Label).text = data.name;
        (ui.getChildByName("value") as Label).text = data.drawValue;
    }

    private function _executeInvest() : void
    {
        var playerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        _lastBindDiamond = playerSystem.playerData.currency.purpleDiamond;

        var drawCounts : int = _control.model.data.drawCounts;
        var counts : int = CReturnDiamondSystem( _system ).getDiamondRouletteConst().diamondRouletteCounts;
        var extraCounts : int = _control.model.data.extraCounts;
        if(drawCounts >= counts + extraCounts)
        {
            _openRuleView();
            return;
        }
        if(!_canClick)return;
        var sys:CReturnDiamondSystem = _system as CReturnDiamondSystem;
        var config:DiamondRouletteConfig = sys.getDiamondRouletteConfig(_control.model.data.drawCounts+1);
        var diamondArr:Array=config.diamond;
        var highest:int = diamondArr[diamondArr.length-1];

        //钻石是否足够抽奖
        if(playerSystem.playerData.currency.purpleDiamond >= highest)
        {
            //_canClick = false;
        }

        var blueDiamond : int = playerSystem.playerData.currency.blueDiamond;
        var cost:int = config == null ? 0 : config.consumes;
        if ( cost > blueDiamond)
        {
            var bundleCtx:ISystemBundleContext = _system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
            var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PAY));
            bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
        }

        if ( !_investCMD ) {
            _investCMD = new CInvestCommand( _control.model );
        }
        _control.cmd = _investCMD;
        _control.invoker();
        _isReceived = false;
        _canClick = false;
        _interval = setTimeout(_resetState,2000);
    }

    /**
     * 延时重置按钮锁，2s
     */
    private function _resetState() : void
    {
        if(!_isReceived)
            _canClick = true;
        clearTimeout(_interval);
    }
    private function _closePopup( type : String ) : void {
        if ( type == Dialog.CLOSE ) {
            _ruleView.close();
        }
    }

    override public function update() : void {
        _isReceived = true;
        _initData();
    }

    private function _openRuleView() : void {
        _uiCanvas.addPopupDialog( _ruleView );
        openState = true;
//        _ruleView.txt1.text = CLang.Get("diamondRoulette_rule").replace(/\r/g,"");
//        _ruleView.txt2.text = CLang.Get("diamondRoulette_cout",{v1:CReturnDiamondSystem( _system ).getDiamondRouletteConst().diamondRouletteCounts});
        updateRuleView();
    }
    private function updateRuleView() : void
    {
//        _ruleView.list_reward.renderHandler = new Handler(_renderCost);
        var pDatabase:IDatabase = _system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.DRECHARGE_EXTRA_CONST);
        var costLength:int = pTable.tableMap.length+1;
        var addCount:int = 0;
        for(var i:int = 0;i < costLength;i++)
        {
            var cell:Component = _ruleView.list_reward.getCell(i) as Component;
            var overLabel:Label = cell.getChildByName("costOver") as Label;
            var costLabel:LinkButton = cell.getChildByName("costMoney") as LinkButton;
            var describeLabel:Label = cell.getChildByName("describe") as Label;
            if(describeLabel && overLabel && costLabel)
            {
                if(i == 0)
                {
                    var levelPlayerData:CPlayerData = (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
                    var a:int = levelPlayerData.vipData.vipLv;
                    if(levelPlayerData.vipData.vipLv > 0)
                    {
                        overLabel.visible = true;
                        costLabel.visible = false;
                        addCount++;
                    }else{
                        overLabel.visible = false;
                        costLabel.visible = true;
                        costLabel.disabled = false;
                        costLabel.mouseEnabled = true;
                        costLabel.addEventListener( MouseEvent.CLICK, openVip);
                    }
                    describeLabel.text = "成为VIP额外提升1次";
                }else{
                    var pRecord:RechargeExtraCounts = pTable.findByPrimaryKey(i) as RechargeExtraCounts;
                    describeLabel.text = "活动期间，累计充值" + pRecord.rechargeValue + "钻石，次数+1";
                    if(_control.model.data.rechargeValue >= pRecord.rechargeValue)
                    {
                        overLabel.visible = true;
                        costLabel.visible = false;
                        addCount++;
                    }else{
                        overLabel.visible = false;
                        costLabel.visible = true;
                        costLabel.disabled = false;
                        costLabel.mouseEnabled = true;
                        costLabel.addEventListener( MouseEvent.CLICK, openCharge);
                    }
                }
            }
        }
        _ruleView.txt1.text = _control.model.data.rechargeValue + "钻石"
        _ruleView.txt2.text = addCount + "次";
    }
    override public function show() : void {
        _init();
        if ( !_openViewCMD ) {
            _openViewCMD = new COpenViewCommand( _control.model );
        }
        _control.cmd = _openViewCMD;
        _control.invoker();
        _uiCanvas.addDialog( _viewUI );
        var hallViewHandler : CReturnDiamondViewHandler = _system.getBean( CReturnDiamondViewHandler );
        hallViewHandler.setTweenData( KOFSysTags.DIAMOND_ROULETTE );
        hallViewHandler.showDialog( _viewUI );
        rewardState = false;
        _system.stage.addUITick(numMove);
//        _system.stage.removeUITick(numMove);

        var playerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        _lastBindDiamond = playerSystem.playerData.currency.purpleDiamond;
        playerSystem.addEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateGetDiamondData );
    }

    private function _updateGetDiamondData(e:CPlayerEvent):void{
        var playerSystem:CPlayerSystem = _system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var getDiamond:int = playerSystem.playerData.currency.purpleDiamond - _lastBindDiamond;
        if(getDiamond <= 0)
            return;
        _lastBindDiamond = playerSystem.playerData.currency.purpleDiamond;
        _getRewardDiamond = getDiamond;
        var num1:int = 0;
        var num2:int = 0;
        var num3:int = 0;
        var num4:int = 0;
        var num5:int = 0;
        if(getDiamond>9&&getDiamond<100){
            num1 = getDiamond%10;
            num2 = getDiamond/10;
            num3 = 0;
            num4 = 0;
            num5 = 0;
        }else if(getDiamond>99&&getDiamond<1000){
            num1 = getDiamond%100%10;
            num2 = getDiamond%100/10;
            num3 = getDiamond/100;
            num4 = 0;
            num5 = 0;
        }else if(getDiamond>999&&getDiamond<10000){
            num1 = getDiamond%1000%100%10;
            num2 = getDiamond%1000%100/10;
            num3 = getDiamond%1000/100;
            num4 = getDiamond/1000;
            num5 = 0;
        }else{
            num1 = getDiamond%10000%1000%100%10;
            num2 = getDiamond%10000%1000%100/10;
            num3 = getDiamond%10000%1000/100;
            num4 = getDiamond%10000/1000;
            num5 = getDiamond/10000;
        }
        if(num1 != 0 || num2 != 0 || num3 != 0 || num4 != 0 ||num5 != 0)
        {
            _viewUI.t1.index = num1;
            _viewUI.t2.index = num2;
            _viewUI.t3.index = num3;
            _viewUI.t4.index = num4;
            _viewUI.t5.index = num5;
            _viewUI.numRun1.y = 0;
            _viewUI.numRun2.y = 0;
            _viewUI.numRun3.y = 0;
            _viewUI.numRun4.y = 0;
            _viewUI.numRun5.y = 0;

            num1state = 0;
            num2state = 0;
            num3state = 0;
            num4state = 0;
            num5state = 0;

            rewardStateCount = 0;
            rewardState = true;
        }
        if(openState)
        {
            updateRuleView();
        }
    }

    override public function close() : void {
        _viewUI.numRun1.y = 0;
        _viewUI.numRun2.y = 0;
        _viewUI.numRun3.y = 0;
        _viewUI.numRun4.y = 0;
        _viewUI.numRun5.y = 0;
        _canClick = true;
        rewardState = false;
        _system.stage.removeUITick(numMove);
        clearInterval( _timeStampIntervelID );
        _viewUI.close();
    }

    private function _close( type : String ) : void {
        if ( type == Dialog.CLOSE ) {
            if ( _closeHandler ) {
                _closeHandler.apply();
            }
        }
    }

    private function _init():void{
        _timeStamp = CReturnDiamondSystem( _system ).time/1000;
        clearInterval( _timeStampIntervelID );
        _countDown();
        _timeStampIntervelID = setInterval( _countDown, 1000 );
        _initData();
    }

    private function _initData():void{
        _viewUI.list.dataSource = _control.model.data.recordMap.reverse();
        var sys:CReturnDiamondSystem = _system as CReturnDiamondSystem;
        var config:DiamondRouletteConfig = sys.getDiamondRouletteConfig(_control.model.data.drawCounts+1);
        var diamondArr:Array=config.diamond;
        for(var i:int=1;i<7;i++){
            _viewUI["get"+i].index = 0;
        }
        var highest:int = diamondArr[diamondArr.length-1];
        if(highest>9&&highest<100){
            _viewUI.get1.index = highest%10;
            _viewUI.get2.index = highest/10;
            _viewUI.get3.index = 0;
            _viewUI.get4.index = 0;
            _viewUI.get5.index = 0;
            _viewUI.get6.index = 0;
            _viewUI.get7.index = 0;
            visibleNu(3);
        }else if(highest>99&&highest<1000){
            _viewUI.get1.index = highest%100%10;
            _viewUI.get2.index = highest%100/10;
            _viewUI.get3.index = highest/100;
            _viewUI.get4.index = 0;
            _viewUI.get5.index = 0;
            _viewUI.get6.index = 0;
            _viewUI.get7.index = 0;
            visibleNu(4);
        }else if(highest>999&&highest<10000){
            _viewUI.get1.index = highest%1000%100%10;
            _viewUI.get2.index = highest%1000%100/10;
            _viewUI.get3.index = highest%1000/100;
            _viewUI.get4.index = highest/1000;
            _viewUI.get5.index = 0;
            _viewUI.get6.index = 0;
            _viewUI.get7.index = 0;
            visibleNu(5);
        }else{
            _viewUI.get1.index = highest%10000%1000%100%10;
            _viewUI.get2.index = highest%10000%1000%100/10;
            _viewUI.get3.index = highest%10000%1000/100;
            _viewUI.get4.index = highest%10000/1000;
            _viewUI.get5.index = highest/10000;
            _viewUI.get6.index = 0;
            _viewUI.get7.index = 0;
            visibleNu(6);
        }
        function visibleNu(index:int):void{
            for(var i:int=1;i<8;i++){
                _viewUI["get"+i].visible = true;
            }
            for(var j:int=index;j<8;j++){
                if(_viewUI["get"+j].index==0){
                    _viewUI["get"+j].visible=false;
                }else{
                    _viewUI["get"+j].visible=true;
                }
            }
        }

        _viewUI.cost.text =config.consumes+"";
        _viewUI.leastGet.text = config.diamond[0]+"";
        var constConfig:DiamondRouletteConst= sys.getDiamondRouletteConst();

        var pDatabase:IDatabase = _system.stage.getSystem(IDatabase) as IDatabase;
        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.DIAMOND_ROULETTE_CONST);
        var pRecord:DiamondRouletteConst = pTable.findByPrimaryKey(1) as DiamondRouletteConst;
        _viewUI.count.text = "<font color='#64e936'>"+pRecord.diamondRouletteCounts + "</font>";
        var numCount:int = pRecord.diamondRouletteCounts + _control.model.data.extraCounts - _control.model.data.drawCounts;
        if(numCount < 10){
            _viewUI.num.index = numCount;
            _viewUI.num2.visible = false;
        }else{
            _viewUI.num.index = numCount%10;
            _viewUI.num2.index = numCount/10;
            _viewUI.num2.visible = true;
        }
//        _viewUI.extCount.text = _control.model.data.extraCounts+"";
    }

    //开始滚动
    private function numMove(e:*):void
    {
        rewardStateCount++;
        //随机数
        if(rewardState)
        {
            var num1ok:Boolean;
            var num2ok:Boolean;
            var num3ok:Boolean;
            var num4ok:Boolean;
            var num5ok:Boolean;
            num1ok = numMoveStart(_viewUI.numRun1,1850,60,-1,num1ok);
            num2ok = numMoveStart( _viewUI.numRun2, 1850, 60, 3, num2ok );
            num3ok = numMoveStart( _viewUI.numRun3, 1850, 60, 6, num3ok );
            num4ok = numMoveStart( _viewUI.numRun4, 1850, 60, 10, num4ok );
            num5ok = numMoveStart( _viewUI.numRun5, 1850, 60, 14, num5ok );
            if(num1ok)
            {
                num1ok = false;
                //缓动 0 向上缓动 1 向下缓动 2 缓动完毕
                if(num1state == 0)
                {
                    if(num1count == 0 || num1count == 1)
                    {
                        _viewUI.t1.y -= 1;
                    }else if(num1count == 2)
                    {
                        _viewUI.t1.y -= 2;
                    }
                    num1count ++;
                    if(num1count == 3)
                    {
                        num1state ++;
                        num1count = 0;
                    }
                }else if(num1state == 1){

                    if(num1count == 0 || num1count == 1)
                    {
                        _viewUI.t1.y += 1;
                    }else if(num1count == 2)
                    {
                        _viewUI.t1.y += 2;
                    }
                    num1count ++;
                    if(num1count == 3)
                    {
                        num1state ++;
                        num1count = 0;
                    }
                }else if(num1state == 2) {
                    num1ok = true;
                }
            }
            if(num2ok)
            {
                num2ok = false;
                //缓动 0 向上缓动 1 向下缓动 2 缓动完毕
                if(num2state == 0)
                {
                    if(num2count == 0 || num2count == 1)
                    {
                        _viewUI.t2.y -= 1;
                    }else if(num2count == 2)
                    {
                        _viewUI.t2.y -= 2;
                    }
                    num2count ++;
                    if(num2count == 3)
                    {
                        num2state ++;
                        num2count = 0;
                    }
                }else if(num2state == 1){

                    if(num2count == 0 || num2count == 1)
                    {
                        _viewUI.t2.y += 1;
                    }else if(num2count == 2)
                    {
                        _viewUI.t2.y += 2;
                    }
                    num2count ++;
                    if(num2count == 3)
                    {
                        num2state ++;
                        num2count = 0;
                    }
                }else if(num2state == 2) {
                    num2ok = true;
                }
            }
            if(num3ok)
            {
                num3ok = false;
                //缓动 0 向上缓动 1 向下缓动 2 缓动完毕
                if(num3state == 0)
                {
                    if(num3count == 0 || num3count == 1)
                    {
                        _viewUI.t3.y -= 1;
                    }else if(num3count == 2)
                    {
                        _viewUI.t3.y -= 2;
                    }
                    num3count ++;
                    if(num3count == 3)
                    {
                        num3state ++;
                        num3count = 0;
                    }
                }else if(num3state == 1){

                    if(num3count == 0 || num3count == 1)
                    {
                        _viewUI.t3.y += 1;
                    }else if(num3count == 2)
                    {
                        _viewUI.t3.y += 2;
                    }
                    num3count ++;
                    if(num3count == 3)
                    {
                        num3state ++;
                        num3count = 0;
                    }
                }else if(num3state == 2) {
                    num3ok = true;
                }
            }
            if(num4ok)
            {
                num4ok = false;
                //缓动 0 向上缓动 1 向下缓动 2 缓动完毕
                if(num4state == 0)
                {
                    if(num4count == 0 || num4count == 1)
                    {
                        _viewUI.t4.y -= 1;
                    }else if(num4count == 2)
                    {
                        _viewUI.t4.y -= 2;
                    }
                    num4count ++;
                    if(num4count == 3)
                    {
                        num4state ++;
                        num4count = 0;
                    }
                }else if(num4state == 1){

                    if(num4count == 0 || num4count == 1)
                    {
                        _viewUI.t4.y += 1;
                    }else if(num4count == 2)
                    {
                        _viewUI.t4.y += 2;
                    }
                    num4count ++;
                    if(num4count == 3)
                    {
                        num4state ++;
                        num4count = 0;
                    }
                }else if(num4state == 2) {
                    num4ok = true;
                }
            }
            if(num5ok)
            {
                num5ok = false;
                //缓动 0 向上缓动 1 向下缓动 2 缓动完毕
                if(num5state == 0)
                {
                    if(num5count == 0 || num5count == 1)
                    {
                        _viewUI.t5.y -= 1;
                    }else if(num5count == 2)
                    {
                        _viewUI.t5.y -= 2;
                    }
                    num5count ++;
                    if(num5count == 3)
                    {
                        num5state ++;
                        num5count = 0;
                    }
                }else if(num5state == 1){

                    if(num5count == 0 || num5count == 1)
                    {
                        _viewUI.t5.y += 1;
                    }else if(num5count == 2)
                    {
                        _viewUI.t5.y += 2;
                    }
                    num5count ++;
                    if(num5count == 3)
                    {
                        num5state ++;
                        num5count = 0;
                    }
                }else if(num5state == 2) {
                    num5ok = true;
                }
            }
            if(num1ok && num2ok && num3ok && num4ok && num5ok)
            {
                _canClick = true;
                rewardState = false;
                //白色闪光动画
                _viewUI.movie_result.visible = true;
                var hideResult:Handler = new Handler( hideMovie );
                _viewUI.movie_result.playFromTo(null,null,hideResult)//_viewUI.movie_result.totalFrame
                //弹出钻石奖励界面
                var rewardListData:CRewardListData = CRewardUtil.createByList(_system.stage, [{ID:2,num:_getRewardDiamond}]);
                (_system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull( rewardListData );
            }
        }
    }
    private function numMoveStart(moveBox:Box,moveLimit:int,moveSpeed:int,moveStart:int, numok:Boolean):Boolean
    {
        if(moveBox.y <= moveLimit && rewardStateCount > moveStart)
        {
            if(moveBox.y >= moveLimit - moveSpeed * 3)
            {
                if(moveBox.y >= moveLimit - moveSpeed * 1)
                {
                    moveBox.y += moveSpeed/4;
                }else{
                    moveBox.y += moveSpeed/2;
                }
            }else{
                moveBox.y += moveSpeed;
            }
        }else{
            numok = true;
        }
        return numok;
    }
    private function moveLow(moveBox:Clip,numstate:int,numcount:int,numok:Boolean):Boolean
    {
        numok = false;
        if(numstate == 0)
        {
            moveBox.y -- ;
            numcount ++;
            if(numcount == 5)
            {
                numstate ++;
                numcount = 0;
            }
        }else if(numstate == 1){
            moveBox.y ++ ;
            numcount ++;
            if(numcount == 5)
            {
                numstate ++;
                numcount = 0;
            }
        }else if(numstate == 2) {
            numok = true;
        }
        return numok;
    }
    private function hideMovie():void
    {
        _viewUI.movie_result.visible = false;
    }
    private function openVip(e:MouseEvent):void
    {
        _ruleView.close();
        _system._closeHandler();
        var pBundle:ISystemBundle = _system.ctx.getSystemBundle(SYSTEM_ID(KOFSysTags.VIP));
        _system.ctx.setUserData(pBundle, CBundleSystem.ACTIVATED, true);
    }
    private function openCharge(e:MouseEvent):void
    {
        _ruleView.close();
        _system._closeHandler();
        var pBundle:ISystemBundle = _system.ctx.getSystemBundle(SYSTEM_ID(KOFSysTags.RECHARGEREBATE));
        _system.ctx.setUserData(pBundle, CBundleSystem.ACTIVATED, true);
    }

    private function _countDown() : void {
        if ( _timeStamp > 0 ) {
            _timeStamp--;
            var time : int = _timeStamp;
            var d:int = time/(3600*24);
            var h : int = time % (3600*24)/3600;
            var m : int = time % (3600*24)% 3600 / 60;
            var s : int = time % (3600*24)%3600 % 60;
            var sh : String = "";
            var sm : String = "";
            var ss : String = "";
            if ( h < 10 ) {
                sh = "0" + h;
            } else {
                sh = "" + h;
            }
            if ( m < 10 ) {
                sm = "0" + m;
            } else {
                sm = "" + m;
            }
            if ( s < 10 ) {
                ss = "0" + s;
            } else {
                ss = "" + s;
            }
            if(d>9){
                _viewUI.timeUI.day2.index = d/10;
                _viewUI.timeUI.day1.index = d%10;
            }else{
                _viewUI.timeUI.day2.index = 0;
                _viewUI.timeUI.day1.index = d;
            }
            _viewUI.timeUI.time.text = sh + ":" + sm + ":" + ss;
        }else{
            //时间到了
            CReturnDiamondSystem(_system).closeSystem();
        }
    }
}
}
