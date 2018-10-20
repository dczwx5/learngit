//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/10.
 * Time: 10:33
 */
package kof.game.character.ai.jsonData
{

	/*json数据结构*/
	public class CNodeJsonData
	{
		public var rootTask:CChildNodeData;
		public function CNodeJsonData()
		{
		}
		public static function initJsonData(data:Object):CNodeJsonData
		{
			var nodeJson:CNodeJsonData=new CNodeJsonData();
			nodeJson.rootTask=new CChildNodeData();
			if(data.rootTask!=null)
			{
				for(var key:String in data.rootTask)
				{
					if(nodeJson.rootTask.hasOwnProperty(key))
					{
						nodeJson.rootTask[key]=data.rootTask[key];
					}
					else
					{

					}
				}
			}

			return nodeJson;
		}
	}
}
