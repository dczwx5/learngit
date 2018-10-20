//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/3/28.
//----------------------------------------------------------------------
package QFLib.Graphics.Character.model {
public class ResUrlInfo {
    public var xmlUrl:String;
    public var jsonUrl:String;
    public var animUrl:String;

    public function ResUrlInfo() {
    }

    public function dispose():void {
        xmlUrl = null;
        jsonUrl = null;
        animUrl = null;
    }
}
}
