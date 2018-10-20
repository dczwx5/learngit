/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/7.
 * Time: 11:45
 */
package Scenes
{
	import QFLib.AI.CAIObject;
	import QFLib.AI.CAISystem;
	import QFLib.Foundation;
	import QFLib.Foundation.CURLJson;

	import actions.CFollowAction;

	import aiDataIO.CActionHandler;
	import aiDataIO.IAIDataIO;

	import factorys.CRoleFactory;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class CSceneView extends Sprite
	{
		private var m_player:Sprite=null;
		private var m_monster:Sprite=null;
		private var handler:IAIDataIO = null;
		private var m_delta:Number=0;
		private var m_preveFrameRateTime:Number = 0;
		private var m_aiObj:CAIObject = null;
		private var m_inputData:Object = null;

		private var aiSystem:CAISystem;
		public function CSceneView()
		{
			if(stage==null)
			{
				addEventListener(Event.ADDED_TO_STAGE,_init);
			}
			else
			{
				_init();
			}
		}

		private function _init(e:Event=null):void
		{
			if(hasEventListener(Event.ADDED_TO_STAGE))
			{
				removeEventListener(Event.ADDED_TO_STAGE,_init);
			}
			m_preveFrameRateTime = new Date().getTime();
			_initData();
			_createAI();
			addEventListener(Event.ENTER_FRAME,_update);
		}

		private function _initData():void
		{
			m_player = CRoleFactory.createRole(CRoleFactory.PLAYER);
			m_monster = CRoleFactory.createRole(CRoleFactory.MONSTER);
			m_player.x = 500;
			m_player.y = 300;
			m_monster.x= 100;
			m_monster.y = 300;
			addChild(m_player);
			addChild(m_monster);

			handler = new CActionHandler();
			var obj:Object = new Object();
			obj.monster = m_monster;
			obj.player = m_player;
			handler.data = obj;
			m_inputData = new Object();
			m_inputData.handler = handler;
			m_inputData.deltaTime = 0.5;

			aiSystem=new CAISystem();
			var actionVector:Vector.<Class> = new Vector.<Class>();
			actionVector.push(CFollowAction);
			aiSystem.registerAction( actionVector );
			_initEvent();
		}

		private function _createAI():void
		{
			//加载ai文件
			var behaviorName:String = "followPlayer";
			var path:String = "assets/"+behaviorName+".json";
			aiSystem.loadAIJsonConfig(path,_createAIObj);
			function _createAIObj(file:CURLJson,idError:int):void
			{
				if(idError==0)
				{
					Foundation.Log.logMsg("Json LoadSuccess");
					m_aiObj = new CAIObject(file.jsonObject[behaviorName],"",m_inputData);
				}
			}
		}

		private function _update(e:Event):void
		{
			var currentFrameTime:Number=new Date().getTime();
			m_delta = currentFrameTime - m_preveFrameRateTime;
			if(aiSystem)
			{

				aiSystem.updateAIObj(m_aiObj,0.5,0.2);
			}
			m_preveFrameRateTime=currentFrameTime;
		}

		private function _initEvent():void
		{
			stage.addEventListener(MouseEvent.CLICK,_handlerClick);
		}

		private function _handlerClick(e:MouseEvent):void
		{
//			TweenLite.to(m_player,0.3,{x:mouseX,y:mouseY});
			m_player.x=mouseX;
			m_player.y=mouseY;
		}
	}
}


