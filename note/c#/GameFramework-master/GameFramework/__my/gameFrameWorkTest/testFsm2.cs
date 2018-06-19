using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using GameFramework;
using GameFramework.Fsm;
using __my;
using static __my.gameFrameWorkTest.CLevelLoading;
using static __my.gameFrameWorkTest.CLevelOverState;
using System.Threading;

namespace __my.gameFrameWorkTest {
 
    public class testFSM2 {

        public static void Usage() {
            FsmManager fsmMgr = new FsmManager();
            CLevel level = new CLevel();
            FsmState<CLevel>[] states = new FsmState<CLevel>[14];
            int index = 0;
            states.SetValue(new CLevelEnterState(), index++);
            states.SetValue(new CLevelLoading(), index++);
            states.SetValue(new CLevelLoadConfigState(), index++);
            states.SetValue(new CLevelPreloadState(), index++);
            states.SetValue(new CLevelOpenScenarioState(), index++);
            states.SetValue(new CLevelCountDownStartState(), index++);
            states.SetValue(new CLevelReadyGoState(), index++);
            states.SetValue(new CLevelRunningState(), index++);
            states.SetValue(new CLevelPlayingScenarioState(), index++);
            states.SetValue(new CLevelAssertState(), index++);
            states.SetValue(new CLevelOverState(), index++);
            states.SetValue(new CLevelPlayWinState(), index++);
            states.SetValue(new CLevelShowResultState(), index++);
            states.SetValue(new CLevelEndState(), index++);
            Fsm<CLevel> fsm = (Fsm<CLevel>)fsmMgr.CreateFsm<CLevel>(level, states);
            fsm.Start<CLevelEnterState>();

            while (true) {
                fsmMgr.Update(0, 0);
                if (fsm.CurrentState is CLevelEndState) {
                    fsmMgr.Shutdown();

                    break;
                }
                Thread.Sleep(100);
            }
        }
    }

    public class CLevel {
        

    }
    /// <summary>
    /// 关卡进入
    /// </summary>
    public class CLevelEnterState : FsmState<CLevel> {
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");

        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");
            ((Fsm<CLevel>)fsm).ChangeState<CLevelLoading>();

        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
    }
    /// <summary>
    /// loading
    /// </summary>
    public class CLevelLoading : FsmState<CLevel> {
        private Fsm<CLevel> loadingFsm = null;
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
            FsmState<CLevel>[] states= new FsmState<CLevel>[2];
            states[0] = new CLevelLoadConfigState();
            states[1] = new CLevelPreloadState();

            loadingFsm = new Fsm<CLevel>(this.GetType().Name, fsm.Owner, states);
            loadingFsm.Start<CLevelLoadConfigState>();
        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");

            ((Fsm<CLevel>)loadingFsm).Update(elapseSeconds, realElapseSeconds);
            if (!loadingFsm.IsRunning) {
                // 执行状态了. 结束
                ((Fsm<CLevel>)fsm).ChangeState<CLevelOpenScenarioState>();
            }
        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }

        /// <summary>
        /// 加载配置
        /// </summary>
        public class CLevelLoadConfigState : FsmState<CLevel> {
            protected internal override void OnInit(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnInit");
            }
            protected internal override void OnEnter(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnEnter");
            }
            protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
                my.Trace(this.GetType().Name + " OnUpdate");
               ((Fsm<CLevel>)fsm).ChangeState<CLevelPreloadState>();
}
            protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
                my.Trace(this.GetType().Name + " OnLeave");
            }
            protected internal override void OnDestroy(IFsm<CLevel> fsm) {
                base.OnDestroy(fsm);
                my.Trace(this.GetType().Name + " OnDestroy");
            }
        }
        /// <summary>
        /// 预加载
        /// </summary>
        public class CLevelPreloadState : FsmState<CLevel> {
            protected internal override void OnInit(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnInit");
            }
            protected internal override void OnEnter(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnEnter");
            }
            protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
                my.Trace(this.GetType().Name + " OnUpdate");
                ((Fsm<CLevel>)fsm).Shutdown();

            }
            protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
                my.Trace(this.GetType().Name + " OnLeave");
            }
            protected internal override void OnDestroy(IFsm<CLevel> fsm) {
                base.OnDestroy(fsm);
                my.Trace(this.GetType().Name + " OnDestroy");
            }
        }
    }
    
    /// <summary>
    /// 开场剧情
    /// </summary>
    public class CLevelOpenScenarioState : FsmState<CLevel> {
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");

            ((Fsm<CLevel>)fsm).ChangeState<CLevelCountDownStartState>();

        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
    }
    /// <summary>
    /// 开始倒计时
    /// </summary>
    public class CLevelCountDownStartState : FsmState<CLevel> {
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");
            ((Fsm<CLevel>)fsm).ChangeState<CLevelReadyGoState>();

        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
    }
    /// <summary>
    /// readygo
    /// </summary>
    public class CLevelReadyGoState : FsmState<CLevel> {
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");
            ((Fsm<CLevel>)fsm).ChangeState<CLevelRunningState>();

        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
    }
    /// <summary>
    /// 正常运行
    /// </summary>
    public class CLevelRunningState : FsmState<CLevel> {
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
        }
        bool hasPlayScenario = false;
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");

            if (!hasPlayScenario) {
                // 假设有个剧情要播放 只播一个
                hasPlayScenario = true;
                ((Fsm<CLevel>)fsm).ChangeState<CLevelPlayingScenarioState>();
            } else {
                my.Trace(this.GetType().Name + " 动来动去.");
                my.Trace(this.GetType().Name + " 打架.");
                my.Trace(this.GetType().Name + " 打完了.");

                ((Fsm<CLevel>)fsm).ChangeState<CLevelOverState>();
                
            }
            

        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
    }
    /// <summary>
    /// 播放剧情
    /// </summary>
    public class CLevelPlayingScenarioState : FsmState<CLevel> {
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");

            my.Trace(this.GetType().Name + " 播放剧情");
            my.Trace(this.GetType().Name + " 剧情播放结束");

            ((Fsm<CLevel>)fsm).ChangeState<CLevelRunningState>();

        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
    }
    /// <summary>
    /// 中途退出
    /// </summary>
    public class CLevelAssertState : FsmState<CLevel> {
        /// <summary>
        /// 等待停止
        /// </summary>
        public class CLevelWaitingStopState : FsmState<CLevel> {
            protected internal override void OnInit(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnInit");
            }
            protected internal override void OnEnter(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnEnter");
            }
            protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
                my.Trace(this.GetType().Name + " OnUpdate");
 
            }
            protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
                my.Trace(this.GetType().Name + " OnLeave");
            }
            protected internal override void OnDestroy(IFsm<CLevel> fsm) {
                base.OnDestroy(fsm);
                my.Trace(this.GetType().Name + " OnDestroy");
            }
        }

    }
    /// <summary>
    /// 结束
    /// </summary>
    public class CLevelOverState : FsmState<CLevel> {
        private Fsm<CLevel> m_OverFsm;

        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
            FsmState<CLevel>[] states = new FsmState<CLevel>[2];
            states[0] = new CLevelWaitingStopState();
            states[1] = new CLevelPlayWinState();
            m_OverFsm = new Fsm<CLevel>(fsm.Owner.GetType().Name, fsm.Owner, states);
            m_OverFsm.Start<CLevelWaitingStopState>();
        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");
            if (m_OverFsm.IsRunning) {
                m_OverFsm.Update(elapseSeconds, realElapseSeconds);

            } else { 
                ((Fsm<CLevel>)fsm).ChangeState<CLevelShowResultState>();
            }

        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
        /// <summary>
        /// 等待停止
        /// </summary>
        public class CLevelWaitingStopState : FsmState<CLevel> {
            protected internal override void OnInit(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnInit");
            }
            protected internal override void OnEnter(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnEnter");
            }
            protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
                my.Trace(this.GetType().Name + " OnUpdate");
                ((Fsm<CLevel>)fsm).ChangeState<CLevelPlayWinState>();

            }
            protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
                my.Trace(this.GetType().Name + " OnLeave");
            }
            protected internal override void OnDestroy(IFsm<CLevel> fsm) {
                base.OnDestroy(fsm);
                my.Trace(this.GetType().Name + " OnDestroy");
            }
        }
        /// <summary>
        /// 等待停止
        /// </summary>
        public class CLevelPlayWinState : FsmState<CLevel> {
            protected internal override void OnInit(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnInit");
            }
            protected internal override void OnEnter(IFsm<CLevel> fsm) {
                my.Trace(this.GetType().Name + " OnEnter");
            }
            protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
                my.Trace(this.GetType().Name + " OnUpdate");
                my.Trace(this.GetType().Name + " 全部停止了");

                ((Fsm<CLevel>)fsm).Shutdown();

            }
            protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
                my.Trace(this.GetType().Name + " OnLeave");
            }
            protected internal override void OnDestroy(IFsm<CLevel> fsm) {
                base.OnDestroy(fsm);
                my.Trace(this.GetType().Name + " OnDestroy");
            }
        }
    }
    /// <summary>
    /// 结算界面
    /// </summary>
    public class CLevelShowResultState : FsmState<CLevel> {
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");

            ((Fsm<CLevel>)fsm).ChangeState<CLevelEndState>();
        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
    }

    public class CLevelEndState : FsmState<CLevel> {
        protected internal override void OnInit(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnInit");
        }
        protected internal override void OnEnter(IFsm<CLevel> fsm) {
            my.Trace(this.GetType().Name + " OnEnter");
        }
        protected internal override void OnUpdate(IFsm<CLevel> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace(this.GetType().Name + " OnUpdate");

        }
        protected internal override void OnLeave(IFsm<CLevel> fsm, bool isShutdown) {
            my.Trace(this.GetType().Name + " OnLeave");
        }
        protected internal override void OnDestroy(IFsm<CLevel> fsm) {
            base.OnDestroy(fsm);
            my.Trace(this.GetType().Name + " OnDestroy");
        }
    }

}
