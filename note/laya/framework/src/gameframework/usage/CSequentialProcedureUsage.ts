namespace gameframework {
export namespace usage {
/**
 * ...
 * @author
 */
export class CSequentialProcedureUsage{
	
	public CSequentialProcedureUsage(){
		this.m_index = 0;
		log.CLog.log("CSequentialProcedureUsage ----------------------");
		var procedureManager:gameframework.sequentialProcedure.CSequentialProcedureManager = new gameframework.sequentialProcedure.CSequentialProcedureManager();
		procedureManager.addSequential(Laya.Handler.create(this, this._login), null);
		procedureManager.addSequential(null, Laya.Handler.create(this, this._isLoginFinish, null, false));
		procedureManager.addSequential(Laya.Handler.create(this, this._loading), Laya.Handler.create(this, this._isLoadingFinish, null, false));
		procedureManager.addSequential(null, Laya.Handler.create(this, this._isDead));

	}

	private _login() : void {
		log.CLog.log("CSequentialProcedureUsage _login")
	}
	private _isLoginFinish() : boolean {
		this.m_index++;
		if (this.m_index > 500) {
			return true;
		}
		return false;
	}

	private _loading() : void {
		log.CLog.log("CSequentialProcedureUsage _loading")
	}
	private _isLoadingFinish() : boolean {
		this.m_index++;
		if (this.m_index > 1000) {
			return true;
		}
		return false;
	}
	private _isDead() : boolean {
		log.CLog.log("CSequentialProcedureUsage -------------------------finish");
		return true;
	}
	private m_index:number;
}
}
}