//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/12.
 * Time: 11:46
 */
package kof.game.character.ai.jsonData
{
	public class CChildNodeData
	{
		public var objectType:String;
		public var name:String;
		public var children:Array;

		//自定义节点参数，可在怪物表配置
		public var followDistance:Number=150;
		public var testBool:Boolean=false;
	}
}
