//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/20.
 */
package kof.game.impression.data {


/**
 * 格斗家列表数据结构
 */
public class CPlayerInfoData {

    private var _roleId:int;// 格斗家基础信息
    private var _isGet:Boolean;// 格斗家是否已获得
    private var _isOpen:Boolean;// 格斗家是否已开放
    private var _outerIndex:int;// 外层List index
    private var _innerIndex:int;// 内层List index

    public function CPlayerInfoData() {
    }

    public function get roleId() : int {
        return _roleId;
    }

    public function set roleId( value : int ) : void {
        _roleId = value;
    }

    public function get isOpen() : Boolean {
        return _isOpen;
    }

    public function set isOpen( value : Boolean ) : void {
        _isOpen = value;
    }

    public function get isGet() : Boolean {
        return _isGet;
    }

    public function set isGet( value : Boolean ) : void {
        _isGet = value;
    }

    public function get heroImgUrl():String
    {
        return "icon/role/big/role_"+_roleId+".png";
    }

    public function get heroImgGrayUrl():String
    {
        return "icon/role/big2/role_"+_roleId+".png";
    }

    public function set outerIndex(value:int):void
    {
        _outerIndex = value;
    }

    public function get outerIndex():int
    {
        return _outerIndex;
    }

    public function set innerIndex(value:int):void
    {
        _innerIndex = value;
    }

    public function get innerIndex():int
    {
        return _innerIndex;
    }
}
}
