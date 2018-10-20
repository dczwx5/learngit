
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.display.MovieClip;
import flash.events.TimerEvent;
import flash.utils.Timer;

var wid:int = 86;              //头像格子宽度
var offsetX:int = 468;         //头像组舞台坐标偏移量X
var offsetY:int = 270;         //头像组舞台坐标偏移量Y
var initX:int = -272;          //1P光标舞台坐标偏移量X
var initY:int = -113;          //1P光标舞坐标偏移量Y
var index:int;                 //1P光标位置索引
var reFrame:int = 39;          //循环初始帧数
var count:int;                 //n秒后1P开始随机移动
var curTime:int;			   //当前时间
var lastDir:int = 1;           //记录上一次的移动方向
var mixTime:int = 50;         //1P自动随机移动间隔最小值
var maxTime:int = 1000;        //1P自动随机移动间隔最大值
var dirArr:Array = [-1,1,-2,2];//方向数组上下左右
var isInit:Boolean;            //不是第一次启动

//各个人物头像相对父容器坐标
var ptArr:Array = [[-149,-83],[-65,-87],[22,-92],[157,-96],[243,-100],[326,-96],[463,-93],[548,-88],[635,-82],
				   [-161,8],  [-76,5],  [9,2],   [157,1],  [243,-1],  [329,1],  [474,2],  [561,5],  [647,8],
				   [-162,95], [-77,96], [9,99],  [157,99], [243,102], [329,99], [476,99], [561,98], [647,95],
				   [-150,184],[-65,190],[22,194],[157,197],[243,201], [326,197],[466,194],[550,189],[636,186],
				   [139,297], [345,297]];

main();

function main()
{
	var mainScene:DisplayObject = this.getChildByName("allSprite");
	if(mainScene)
	{
		allSprite.addEventListener(Event.ENTER_FRAME,rePlay);//播放到最后跳回39帧继续播放
		allSprite.addEventListener(MouseEvent.CLICK,onClick);//鼠标控制1P光标
	}
	if(stage)
	{
		stage.addEventListener(KeyboardEvent.KEY_DOWN,onPressDown);//键盘控制1P光标
		this.addEventListener(Event.REMOVED_FROM_STAGE, removeAllListener);
	}
	//curTime = getTimer();//开始计时
}

function rePlay(e:Event):void
{
//	count = isInit ? count : 5000;
//	if(getTimer() - curTime >= count)
//	{
//		var dir:int = Math.floor(Math.random() * dirArr.length);//定时器触发随机方向
//		while(dirArr[dir] + lastDir == 0)
//		{
//			dir = Math.floor(Math.random() * dirArr.length);//如果下次方向和上次相反再随机，避免光标来回跳动
//		}
//		calculate(dirArr[dir]);
//		lastDir = dirArr[dir];
//		count = Math.floor(Math.random() * maxTime) + mixTime;//触发随机移动后，间隔调成mix-max
//		isInit = true;
//	}
	if(allSprite.currentFrame == allSprite.totalFrames)
	{
		allSprite.gotoAndPlay(reFrame);
	}
}

function onClick(e:MouseEvent):void
{
	if(allSprite.currentFrame < reFrame)
		return;
	count = 5000;//动了鼠标后重置为5s
	var curX:int = int(mouseX-offsetX);
	var curY:int = int(mouseY-offsetY);
	for(var i:int = 0; i < ptArr.length; i++)
	{
		if(curX - ptArr[i][0] < wid && curX > ptArr[i][0]&&
		   curY - ptArr[i][1] < wid && curY > ptArr[i][1])
		{
			onMove(i);
			break;
		}
	}
}
//键盘方向判定0上1下2左3右
function onPressDown(e:KeyboardEvent):void
{
	count = 5000;//动了键盘后重置为5s
	var direct:int;
	switch(e.keyCode)
	{
		case 38:
		case 87:
			direct = -1;
			break;
		case 40:
		case 83:
			direct = 1;
			break;
		case 37:
		case 65:
			direct = -2;
			break;
		case 39:
		case 68:
			direct = 2;
			break;
	}
	calculate(direct);

}

//执行移动判断
function calculate(direct:int):void
{
	if(direct == 0) return;
	var nextIndex:int;
	switch(direct)
	{
		case -1:
			if(index == 3)        nextIndex = 36;
			else if(index == 5)   nextIndex = 37;
			else if(index == 36)  nextIndex = 30;
			else if(index == 37)  nextIndex = 32;
			else if(index < 9)    nextIndex = index + 27;
			else                  nextIndex = index - 9;
			break;
		case 1:
			if(index == 30)       nextIndex = 36;
			else if(index == 32)  nextIndex = 37;
			else if(index == 36)  nextIndex = 3;
			else if(index == 37)  nextIndex = 5;
			else if(index >= 27)  nextIndex = index - 27;
			else                  nextIndex = index + 9;
			break;
		case -2:
			if(index == 36)       nextIndex = 37;
			else if(index % 9==0) nextIndex = index + 8;
			else                  nextIndex = index - 1;
			break;
		case 2:
			if(index == 37)       nextIndex = 36;
			else if(index % 9==8) nextIndex = index - 8;
			else                  nextIndex = index + 1;
			break;
	}
	onMove(nextIndex);
}

//1P光标移动到指定位置
function onMove(i:int):void
{
	var mainScene:DisplayObject = this.getChildByName("allSprite");
	if(!mainScene)
	{
		trace("动画未加载完成");
		return;
	}
	var cursor:DisplayObject = allSprite.getChildByName("_cursor");
	if(!cursor)
	{
		trace("光标未加载完成");
		return;
	}
	allSprite._cursor.x = initX + ptArr[i][0];
	allSprite._cursor.y = initY + ptArr[i][1];
	index = i;
	curTime = getTimer();
	//trace("当期位置=========="+i);
}

function removeAllListener(e:Event):void
{
	var mainScene:DisplayObject = this.getChildByName("allSprite");
	if(mainScene)
	{
		allSprite.removeEventListener(Event.ENTER_FRAME,rePlay);//播放到最后跳回39帧继续播放
		allSprite.removeEventListener(MouseEvent.CLICK,onClick);//鼠标控制1P光标
	}
	if(stage)
	{
		stage.removeEventListener(KeyboardEvent.KEY_DOWN,onPressDown);//键盘控制1P光标
		this.removeEventListener(Event.REMOVED_FROM_STAGE, removeAllListener);
	}
}