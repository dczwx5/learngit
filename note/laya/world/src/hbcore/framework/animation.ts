export module animation {
export interface IAnimation {
	start(caller:any, callback:Function); // 动作开始
	stop(); // 停止动作
	end(); // 完成 动画完成 主动调用
}
export class CAnimation implements IAnimation {
	constructor() {
		this.isStop = false;
        this.m_tweeningObjList = [];
	}
	// 动作开始
	start(caller:any, callback:Function) {
		if (this.isStop) {
			return false;
		}
		this.m_pCaller = caller;
		this.m_pCallback = callback;
		
		this.onStart();
	}
	protected onStart() {

	}

	end() {
		this._onFinalA();		
		if (this.m_pCallback) {
			this.m_pCallback.call(this.m_pCaller);
		}
	}
	
	// 停止动作
	stop() {
		this.isStop = true;
		this._onFinalA();
	}
	private _onFinalA() {
		this.onFinal();
		if (this.m_tweeningObjList && this.m_tweeningObjList.length > 0) {
			for (let sp of this.m_tweeningObjList) {
				if (sp) {
					Laya.Tween.clearAll(sp);
				}
			}
		}
		this.m_tweeningObjList = null;
	} 
	protected onFinal() {

	}

	protected _addTweeningObj(obj:Laya.Sprite) {
		this.m_tweeningObjList.push(obj);
	}
	protected _removeTweeningObj(obj:Laya.Sprite) {
        for (let i:number = 0; i < this.m_tweeningObjList.length; ++i) {
            let poker = this.m_tweeningObjList[i];
            if (poker == obj) {
                this.m_tweeningObjList.splice(i, 1);
                break;
            }
        }
    }
    protected m_tweeningObjList:Array<Laya.Sprite>;

	private m_pCaller:any;
	private m_pCallback:Function;
	isStop:boolean;
}

// 动画不可重新开始, 要多次执行, 需要重新创建Group
// group.add(ani);
// group.start(caller, callback);
// group stop之后, 每个animation都会调onFinal, 执行末尾工作, 清除动画, 执行该设置的内容
// group stop 会执行callback
// animation stop之后, 不会调用callback, 动画链停止
export class CAnimationGroup {
	constructor() {
		this.finish = false;
		this.m_list = [];
		this.m_curAni = null;
	} 
	add(ani:IAnimation | Array<IAnimation>){
		if (this.finish) {
			return ;
		}
		if (ani instanceof Array) {
			for (let i:number = 0; i < ani.length; ++i) {
				this.m_list[this.m_list.length] = ani[i];
			}
		} else {
			this.m_list[this.m_list.length] = ani;
		}
	}

	start(caller:any, callback:Function) {
		if (this.finish) {
			return ;
		}

		this.m_pCaller = caller;
		this.m_pCallback = callback;

		if (!(this._hasNext())) {
			this._onFinish();
			return ;
		}

		this._next();
	}

	// not ok
	stop() {
		if (this.finish) {
			return ;
		}
		
		if (this.m_curAni) {
			this.m_curAni.stop();
		}
		while (this.m_list.length > 0) {
			let ani = this.m_list.shift();
			ani.stop();
		}

		this._onFinish();
	}
	
	private _hasNext() : boolean {
		return this.m_list.length > 0;
	}
	private _next() {
		let ani = this.m_list.shift();
		this.m_curAni = ani;
		ani.start(this, this._onAniCompleted);
	}
	private _onAniCompleted(ani:IAnimation) {
		if (this._hasNext()) {
			this._next();
		} else {
			this._onFinish();
		}
	}
	private _onFinish() {
		this.m_list = null;
		this.finish = true;
		this.m_curAni = null;

		if (this.m_pCallback) {
			this.m_pCallback.call(this.m_pCaller);
		}
		this.m_pCallback = null;
		this.m_pCaller = null;
	}
	finish:boolean;

	private m_list:Array<IAnimation>;
	private m_curAni:IAnimation;

	private m_pCaller:any;
	private m_pCallback:Function;
}

// 例子
// this.group = new CAnimationGroup();
// this.group.add(new MoveAnimation());
// this.group.start(this, ()=>{
//     this.group = null;
// });
// Laya.timer.once(1000, this, ()=>{
//     this.group.stop();
// })

// class MoveAnimation extends CAnimation {
// 	onStart() {
// 		let sp = new Laya.Sprite();

// 		this.m_sp = sp;
// 		sp.graphics.drawRect(0, 0, 10, 10, '#ff0000');
// 		Laya.stage.addChild(sp);
// 		sp.x = 0;
// 		sp.y = 0;
// 		Laya.Tween.to(sp, {x:200}, 5000, Laya.Ease.linearIn, Laya.Handler.create(this, ()=>{
// 			if (!this.isStop) {
// 				Laya.Tween.to(sp, {y:200}, 500, Laya.Ease.linearIn, Laya.Handler.create(this, ()=>{
// 					this.end();
// 				}))
// 			}
// 		}));
// 	}	
// 	onFinal() {
// 		Laya.Tween.clearAll(this.m_sp);
// 		this.m_sp.x = 200;
// 		this.m_sp.y = 200;
// 	}

// 	private m_sp:Laya.Sprite;
// }
}