//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/8/25.
 */
package kof.game.scenario {

import QFLib.Interface.IUpdatable;

import kof.framework.CAppStage;
import kof.framework.CViewHandler;

public class CBaseDialogueViewHandler extends CViewHandler implements IUpdatable {

    public var size:int = 14;
    public var color:String = "0xcccccc";
    public var effect:String;
    public var name:String;
    public var head:String;
    public var animationName:String = "Idle_1";
    public var isLoop:int = 0;
    public var name1:String;
    public var head1:String;
    public var animationName1:String = "Idle_1";
    public var isLoop1:int = 0;
    public var dialogNumber:int = 1;
    public var position:int = 0;//左=0 右=1
    public var display:int = 0;//0:立刻显示=0 逐字显示=1
    public var uitype:int = 0;//普通对话框=0 boss对话框=1
    public var rate:Number;
    public var content:String = "";

    public function CBaseDialogueViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    public function show(callBackFun:Function = null):void {

    }
    public function hide() : void {

    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
    }
    override public function dispose() : void {
        super.dispose();
    }
    public function update(delta:Number):void {

    }
}
}
