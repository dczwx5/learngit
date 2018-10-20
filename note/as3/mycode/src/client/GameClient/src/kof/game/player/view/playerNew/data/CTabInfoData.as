//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/16.
 */
package kof.game.player.view.playerNew.data {

public class CTabInfoData {

    public var tabIndex:int;// 标签号(从0开始)
    public var tabNameEN:String;// (标签英文名)
    public var tabNameCN:String;// (标签中文名)
    public var panelClass:Class;// (标签对应的面板)
    public var openLevel:int;// (对应面板的开启等级)
    public var hasGuideOpen:Boolean;// 是否已经指引开启
    public var sysTag:String;// 系统标签(子系统)

    public function CTabInfoData()
    {
    }
}
}
