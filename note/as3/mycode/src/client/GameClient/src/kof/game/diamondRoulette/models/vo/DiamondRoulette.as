//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2018/2/5.
 * Time: 14:57
 */
package kof.game.diamondRoulette.models.vo {

import kof.message.Activity.DiamondRouletteDrawResponse;
import kof.message.Activity.DiamondRouletteResponse;

/**
 * @author yili(guoyiligo@qq.com)
 * 2018/2/5
 */
public class DiamondRoulette {
    public var recordMap:Array = [];  //轮盘返钻记录
    public var drawCounts:int = 0;  //轮盘返钻次数
    public var extraCounts:int = 0;  //额外次数
    public var addCountsRecharge:int = 0; //已经参加过的次数
    public var rechargeValue:int = 0; //累积充值的钻石
    public var gamePromptID:int = 0;  //提示消息，0表示成功，其他表示有提示语。

    public function decode(data:DiamondRouletteResponse):void{
        this.recordMap = data.recordMap.drawRecords;//[{"drawValue":188,"name":"s144.百合在减肥"}]
        this.drawCounts = data.drawCounts;
        this.extraCounts = data.extraCounts;
        this.rechargeValue = data.rechargeValue;
        this.gamePromptID = data.gamePromptID;
    }
    public function decodeDraw(data:DiamondRouletteDrawResponse):void{
        this.recordMap = data.recordMap.drawRecords;//[{"drawValue":188,"name":"s144.百合在减肥"}]
        this.drawCounts = data.drawCounts;
        this.extraCounts = data.extraCounts;
        this.gamePromptID = data.gamePromptID;
    }
    private function _convert(obj:Object):void{

    }
}
}
