import { framework } from "./frameWork";
import { procedure } from './procedure';
import { log } from "./log";
export module fsm {
	/**
	 * ...
	 * @author
	 */
	export abstract class CFsmBase {
		constructor(name: string) {
			this.m_name = name;
		}


		get Name(): string {
			return this.m_name;
		}

		abstract get isDestroyed(): boolean;

		abstract get fsmStateCount(): number;
		abstract get isRunning(): boolean;
		abstract get currentStateTime(): number;

		abstract initialize(): void;

		abstract shutDown(): void;

		abstract update(deltaTime: number): void;

		private m_name: string;

	}

	// ===========================================================================================

	/**
	 * ...
	 * @author auto
	 */
	export class CFsm extends CFsmBase {
		constructor(name: string, owner: Object, stateList: CFsmState[]) {
			super(name);

			this.m_owner = owner;
			this.m_states = new Array<CFsmState>(stateList.length);
			this.m_datas = new Object();

			let i: number = 0;
			for (; i < stateList.length; i++) {
				let fsmState: CFsmState = stateList[i];
				this.m_states[i] = fsmState;
			}

			this.m_currentStateTime = 0;
			this.m_currentState = null;
			this.m_isDestroyed = false;
		}

		initialize(): void {
			let i: number = 0;
			for (; i < this.m_states.length; i++) {
				let fsmState: CFsmState = this.m_states[i];
				fsmState.initialize(this);
			}
			this.m_currentStateTime = 0;
			this.m_currentState = null;
			this.m_isDestroyed = false;
		}

		start(stateType: new () => CFsmState): void {
			if (this.isRunning) {
				throw new Error("fsm is running, can nott start again");
			}

			let state: CFsmState = this.getState(stateType);
			if (state == null) {
				throw new Error("fsm not exist");
			}

			this.m_currentStateTime = 0;
			this.m_currentState = state;
			this.m_currentState.enter(this);
		}


		get owner(): Object {
			return this.m_owner;
		}
		get fsmStateCount(): number {
			return this.m_states.length;
		}
		get isRunning(): boolean {
			return this.m_currentState != null;
		}
		get isDestroyed(): boolean {
			return this.m_isDestroyed;
		}
		get currentState(): CFsmState {
			return this.m_currentState;
		}
		get currentStateTime(): number {
			return this.m_currentStateTime;
		}

		hasState(stateType: new () => CFsmState): boolean {
			return this.getState(stateType) != null;
		}
		getState(stateType: new () => CFsmState): CFsmState {
			let i: number = 0;
			for (; i < this.m_states.length; i++) {
				let state: CFsmState = this.m_states[i];
				if (state instanceof stateType) {
					return state;
				}
			}
			return null;
		}
		getAllState(): Array<CFsmState> {
			return this.m_states;
		}
		fireEevnt(sender: Object, eventID: number): void {
			this.m_currentState.onEvent(this, sender, eventID, null);
		}

		hasData(name: string): boolean {
			return this.getData(name) != null;
		}
		getData(name: string): Object {
			if (name == null || name.length == 0) {
				throw new Error("name is invalid");
			}

			return this.m_datas[name];
		}
		setData(name: string, data: Object): void {
			if (name == null || name.length == 0) {
				throw new Error("name is invalid");
			}

			this.m_datas[name] = data;
		}
		removeData(name: string): void {
			if (name == null || name.length == 0) {
				throw new Error("name is invalid");
			}

			delete this.m_datas[name];
		}

		update(deltaTime: number): void {
			if (null == this.m_currentState) {
				return;
			}

			this.m_currentStateTime += deltaTime;
			this.m_currentState.update(this, deltaTime);
		}
		shutDown(): void {
			if (null != this.m_currentState) {
				this.m_currentState.leave(this, true);
				this.m_currentState = null;
				this.m_currentStateTime = 0;
			}

			for (let i: number = 0; i < this.m_states.length; i++) {
				let state: CFsmState = this.m_states[i];
				state.destroy(this);
			}
			this.m_states.length = 0;
			for (let key in this.m_datas) {
				delete this.m_datas[key];
			}

			this.m_isDestroyed = true;

			this.m_pSystem = null;
		}

		changeState(stateType: new () => CFsmState): void {
			if (null == this.m_currentState) {
				throw new Error("current state is invalid");
			}

			let state: CFsmState = this.getState(stateType);
			if (null == state) {
				throw new Error("fsm can not change state, state is not exist" + stateType);
			}

			this.m_currentState.leave(this, false);
			this.m_currentStateTime = 0;
			this.m_currentState = state;
			this.m_currentState.enter(this);
		}

		get system(): framework.CAppSystem {
			return this.m_pSystem;
		}
		set system(v: framework.CAppSystem) {
			this.m_pSystem = v;
		}
		private m_pSystem: framework.CAppSystem;

		private m_owner: Object;
		private m_states: Array<CFsmState>;
		private m_datas: Object;

		private m_currentState: CFsmState;
		private m_currentStateTime: number;
		private m_isDestroyed: boolean;
	}
	// ===========================================================================================
	/**
	 * ...
	 * @author
	 */
	export class CFsmState {
		constructor() {

		}

		initialize(fsm: CFsm): void {
			this.onInit(fsm);
		}
		protected onInit(fsm: CFsm): void {

			//log.log('CFsmState ', 'onInit', );
		}


		enter(fsm: CFsm): void {
			this.onEnter(fsm);
		}
		protected onEnter(fsm: CFsm): void {
			//log.log('CFsmState ', 'onEnter');
		}

		update(fsm: CFsm, deltaTime: number): void {
			this.onUpdate(fsm, deltaTime);
		}
		protected onUpdate(fsm: CFsm, deltaTime: number): void {

		}

		leave(fsm: CFsm, isShutDown: boolean): void {
			this.onLeave(fsm, isShutDown);

		}
		protected onLeave(fsm: CFsm, isShutDown: boolean): void {
			//log.log('CFsmState ', 'onLeave');
		}

		destroy(fsm: CFsm): void {
			this.onDestroy(fsm);
		}
		protected onDestroy(fsm: CFsm): void {
			//log.log('CFsmState ', 'onDestroy');
		}

		protected changeState(fsm: CFsm, stateType: new () => CFsmState): void {
			let fsmImp: CFsm = fsm as CFsm;
			if (null == fsmImp) {
				throw new Error("fsm is invalid");
			}

			if (stateType == null) {
				throw new Error("state type is invalid");
			}

			fsmImp.changeState(stateType);
		}

		onEvent(fsm: CFsm, sender: Object, eventID: number, userData: Object): void {

		}
	}

	// ===========================================================================================

	export class CFsmManager extends framework.CBean {
		constructor() {
			super();
			this.m_fsms = new Object();
		}

		protected onAwake(): void {
			super.onAwake();
		}
		protected onStart(): boolean {
			return super.onStart();
		}
		protected onDestroy(): void {
			super.onDestroy();

			for (let key in this.m_fsms) {
				let fsm: CFsmBase = this.m_fsms[key];
				delete this.m_fsms[key];

				if (fsm.isDestroyed) {
					continue;
				}
				fsm.shutDown();
			}
			this.m_fsms = null;
		}

		update(deltaTime:number): void {
			for (let key in this.m_fsms) {
				let fsm:CFsmBase = this.m_fsms[key];
				if (fsm.isDestroyed) {
					continue;
				}
				fsm.update(deltaTime);
			}
		}

		getAllFsms(): Object {
			return this.m_fsms;
		}

		getFsm(name: string): CFsm {
			return this.m_fsms[name];
		}
		getFsmByOwnerType(clazz: new () => CFsm): CFsm {
			let fsm: CFsm;
			for (let key in this.m_fsms) {
				fsm = this.m_fsms[key];
				if (fsm.owner instanceof clazz) {
					return fsm;
				}
			}
			return null;
		}
		getFsmsByOwnerType(clazz: new () => CFsm): Array<CFsm> {
			let ret: Array<any> = new Array();
			let fsm: CFsm;
			for (let key in this.m_fsms) {
				fsm = this.m_fsms[key];
				if (fsm.owner instanceof clazz) {
					ret.push(fsm);
				}
			}
			return ret;
		}

		createFsm(name: string, owner: Object, stateList: CFsmState[]): CFsm {
			if (this.hasFsm(name)) {
				throw new Error("already exist FSM " + name);
			}

			let fsm: CFsm = new CFsm(name, owner, stateList);
			fsm.system = this.system;
			fsm.initialize();
			this.m_fsms[name] = fsm;
			// m_fsms.set(name, fsm);
			return fsm;
		}

		destroyFsm(name: string): boolean {
			let fsm: CFsmBase = this.m_fsms[name];
			if (fsm) {
				fsm.shutDown();
				delete this.m_fsms[name];
				return true;
			}
			return false;
		}

		hasFsm(name: string): boolean {
			return this.m_fsms.hasOwnProperty(name);
		}

		private m_fsms: Object; // key:string, value fsm
	}

	// ===========================================================================================

	export class CFsmSystem extends framework.CAppSystem {
		constructor() {
			super();
		}

		protected onAwake(): void {
			log.log('CFsmSystem.onAwake');

			super.onAwake();
			this.m_proceudres = new Object();
			this.m_fsmManager = new CFsmManager();
			this.addBean(this.m_fsmManager);

		}
		protected onStart(): boolean {
			log.log('CFsmSystem.onStart')
			return super.onStart();
		}

		protected onDestroy(): void {
			super.onDestroy();

			for (let key in this.m_proceudres) {
				delete this.m_proceudres[key];
			}
			this.m_proceudres = null;

			this.m_fsmManager = null;
		}

		createFsm(name: string, owner: Object, stateList: CFsmState[]): CFsm {
			let fsm: CFsm = this.m_fsmManager.createFsm(name, owner, stateList);
			return fsm;
		}
		getFsm(name: string): CFsm {
			return this.m_fsmManager.getFsm(name);
		}
		destroyFsm(name: string): boolean {
			return this.m_fsmManager.destroyFsm(name);
		}

		hasFsm(name: string): boolean {
			return this.m_fsmManager.hasFsm(name);
		}
		update(deltaTime: number): void {
			super.update(deltaTime);

			this.m_fsmManager.update(deltaTime);
		}

		// 流程
		createProcedure(name: string, procedures: CFsmState[]): procedure.CProcedureManager {
			log.log('CFsmSystem add new Procedure => ', name);
			let procedureManager: procedure.CProcedureManager = new procedure.CProcedureManager();

			procedureManager.initialize(name, this.m_fsmManager, procedures);
			this.m_proceudres[name] = procedureManager;
			return procedureManager;
		}
		getProcedure(name: string): procedure.CProcedureManager {
			return this.m_proceudres[name];
		}
		removeProcedure(name: string): void {

			let manager: procedure.CProcedureManager = this.getProcedure(name);
			if (manager) {
				manager.shutDown();
				delete this.m_proceudres[name];
			}
		}

		private m_fsmManager: CFsmManager;

		private m_proceudres: Object;
	}

	// ===========================================================================================

	export interface IProcedureManager {
		initialize(name: string, fsmManager: fsm.CFsmManager, procedures: fsm.CFsmState[]): void;

		startProcedure(typeProcedure: new () => CProcedureBase): void;

		hasProcedure(typeProcedure: new () => CProcedureBase): boolean;

		getProcedure(typeProcedure: new () => CProcedureBase): CProcedureBase;
	}
	/**
	 * ...
	 * @author
	 */
	export class CProcedureBase extends fsm.CFsmState {
		constructor() {
			super();
		}

		protected onInit(fsm: fsm.CFsm): void {
			super.onInit(fsm);
		}
		protected onEnter(fsm: fsm.CFsm): void {
			super.onEnter(fsm);
		}
		protected onUpdate(fsm: fsm.CFsm, deltaTime: number): void {
			super.onUpdate(fsm, deltaTime);
		}
		protected onLeave(fsm: fsm.CFsm, isShutDown: boolean): void {
			super.onLeave(fsm, isShutDown);
		}
		protected onDestroy(fsm: fsm.CFsm): void {
			super.onDestroy(fsm);
		}

		protected changeProcedure(fsm: fsm.CFsm, stateType: new () => CProcedureBase): void {
			this.changeState(fsm, stateType)
		}
	}

	// ===================================================================

	export class CProcedureManager implements IProcedureManager {
		constructor() {

		}

		get currentProcedure(): CProcedureBase {
			if (this.m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}

			return this.m_procedureFsm.currentState as CProcedureBase;
		}

		get currentProcedureTime(): number {
			if (this.m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}

			return this.m_procedureFsm.currentStateTime;
		}

		initialize(name: string, fsmManager: fsm.CFsmManager, procedures: fsm.CFsmState[]): void {
			if (!fsmManager) {
				throw new Error("fsm manager is invalid");
			}
			this.m_name = name;
			this.m_pFsmManager = fsmManager;
			this.m_procedureFsm = this.m_pFsmManager.createFsm(name, this, procedures);
		}

		startProcedure(typeProcedure: new () => CProcedureBase): void {
			if (this.m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}
			this.m_procedureFsm.start(typeProcedure);
		}

		hasProcedure(typeProcedure: new () => CProcedureBase): boolean {
			if (this.m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}
			return this.m_procedureFsm.hasState(typeProcedure);
		}

		getProcedure(typeProcedure: new () => CProcedureBase): CProcedureBase {
			if (this.m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}
			return this.m_procedureFsm.getState(typeProcedure) as CProcedureBase;
		}

		update(deltaTime: number): void {
			// trace("CProcedureManager.update----------------");
		}
		shutDown(): void {
			if (this.m_pFsmManager != null) {
				if (this.m_procedureFsm != null) {
					this.m_pFsmManager.destroyFsm(this.m_procedureFsm.Name);
					this.m_procedureFsm = null;
				}
				this.m_pFsmManager = null;
			}
		}

		private m_pFsmManager: fsm.CFsmManager;
		private m_procedureFsm: fsm.CFsm;

		get name(): string {
			return this.m_name;
		}
		private m_name: string;
	}
}
