namespace gameframework {


/**
 * ...
 * @author auto
 */
export class CGameStageStart extends Laya.EventDispatcher {

	constructor(){
		super();

		this.m_duringTime = 0;

		framework.CAppStage.DEBUG = false;
		this.m_gameStage = CGameStage.getInstance();
		this.m_gameStage.awake();
		
		Laya.timer.frameLoop(1, this, this._waitStart);
	}
	private _waitStart() : void {
		let isStarted:boolean = this.m_gameStage.start();
		if (isStarted) {
			Laya.timer.clear(this, this._waitStart);
			// Laya.timer.frameLoop(1, this, _onEnterFrame);
			this.m_isReady = true;
			this.event(Laya.Event.COMPLETE);
		}
	}
	public update() : void {
		let deltaTime:number = Laya.timer.delta*0.001;
		this.m_gameStage.update(deltaTime);

		this.m_duringTime += deltaTime;
		while(this.m_duringTime >= this.FIX_TIME) {
			this.m_duringTime -= this.FIX_TIME;
			this.m_gameStage.fixUpdate(this.FIX_TIME);
		}
	}

	public get stage() : CGameStage {
		return this.m_gameStage;
	}

	private m_gameStage:CGameStage;
	private m_duringTime:number;
	private FIX_TIME:number = 1/60;

	public get isReady() : boolean {
		return this.m_isReady;
	}
	private m_isReady:boolean;
}

}