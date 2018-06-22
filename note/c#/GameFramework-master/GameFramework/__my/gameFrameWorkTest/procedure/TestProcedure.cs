using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using GameFramework.Fsm;
using GameFramework.Procedure;
using ProcedureOwner = GameFramework.Fsm.IFsm<GameFramework.Procedure.IProcedureManager>;
namespace __my.gameFrameWorkTest.procedure {
    /// <summary>
    /// procedure 实际上是对fsm的一个封装
    /// ProcedureBase : 流程步骤, 是一个FsmState
    /// 只能在ProcedureBase里改变流程
    /// </summary>
    class TestProcedure {
        public static void Usage() {
            // 一个全局fmsMgr
            FsmManager fsmMgr = new FsmManager();

            // 准备流程 - 一堆fsmState
            ProcedureBase[] procedureList = new ProcedureBase[3];
            procedureList[0] = new CInstanceProcedureLoadResource();
            procedureList[1] = new CInstanceProcedureDoing();
            procedureList[2] = new CInstanceProcedureEnd();

            // 创建流程管理器
            ProcedureManager procedureManager = new ProcedureManager();
            procedureManager.Initialize(fsmMgr, procedureList);
            procedureManager.StartProcedure<CInstanceProcedureLoadResource>();

            while(true) {
                fsmMgr.Update(0, 0);
                 CInstanceProcedure procedure = (CInstanceProcedure)procedureManager.CurrentProcedure;
                if (procedure == null) {
                    my.Trace("TestProcedure Usage over");
                    break;
                }
                if (procedure is CInstanceProcedureEnd && procedure.IsFinish()) {
                    procedureManager.Shutdown();
                    break;
                }
            }

        }
    }

    class CInstanceProcedure : ProcedureBase {
        public virtual void ChangeProcedure() {

        }
        public Boolean IsFinish() {
            return m_IsFinish;
        }
        protected Boolean m_IsFinish = false;
    }

    // 假设这是一个副本加载流程
    class CInstanceProcedureLoadResource : CInstanceProcedure {
        public CInstanceProcedureLoadResource() {
            my.Trace("CInstanceProcedureLoadResource start");
        }
        protected internal override void OnUpdate(ProcedureOwner procedureOwner, float elapseSeconds, float realElapseSeconds) {
            base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);
            my.Trace("CInstanceProcedureLoadResource OnUpdate");
            m_IsFinish = true;
            if (m_IsFinish) {
                ((Fsm<GameFramework.Procedure.IProcedureManager>)procedureOwner).ChangeState<CInstanceProcedureDoing>();
            }
        }
    }
         
    // 假设这是一个副本进行中流程
    class CInstanceProcedureDoing : CInstanceProcedure {
        public CInstanceProcedureDoing() {
            my.Trace("CInstanceProcedureDoing start");
        }
        protected internal override void OnUpdate(ProcedureOwner procedureOwner, float elapseSeconds, float realElapseSeconds) {
            base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);
            my.Trace("CInstanceProcedureDoing OnUpdate");
            m_IsFinish = true;
            if (m_IsFinish) {
                ((Fsm<GameFramework.Procedure.IProcedureManager>)procedureOwner).ChangeState<CInstanceProcedureEnd>();
            }
        }
    }
    // 假设这是一个副本流程
    class CInstanceProcedureEnd : CInstanceProcedure {
        public CInstanceProcedureEnd() {
            my.Trace("CInstanceProcedureEnd start");
        }
        protected internal override void OnUpdate(ProcedureOwner procedureOwner, float elapseSeconds, float realElapseSeconds) {
            base.OnUpdate(procedureOwner, elapseSeconds, realElapseSeconds);
            my.Trace("CInstanceProcedureEnd OnUpdate");
            m_IsFinish = true;
            if (m_IsFinish) {
                    
            }
        }
    }
}
