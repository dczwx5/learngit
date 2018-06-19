using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using GameFramework;
using GameFramework.Fsm;
using __my;
namespace __my.gameFrameWorkTest {
    public class testFSM {
        public static void Usage() {
            FsmState<MyFsm>[] states = new FsmState<MyFsm>[2];
            states[0] = new MyFsmState();
            states[1] = new MyFsmState2();

            MyFsm owner = new MyFsm();
            // Fsm<MyFsm> fsm = new Fsm<MyFsm>(typeof(MyFsm).Name, owner, states);


            FsmManager fsmMgr = new FsmManager();
            Fsm<MyFsm> fsm = (Fsm<MyFsm>)fsmMgr.CreateFsm<MyFsm>(owner, states);
            fsm.Start<MyFsmState>();
            fsm.ChangeState<MyFsmState2>();

            fsmMgr.Update(0.1f, 0.1f);
            fsmMgr.DestroyFsm<MyFsm>();


        }
    }

 
    public class MyFsm {
        public string name2 = "abc";

    }
     
    public class MyFsmState : FsmState<MyFsm> {
      
        protected internal override void OnInit(IFsm<MyFsm> fsm) {
            my.Trace("MyFsmState OnInit");
            my.Trace(fsm.Owner.name2);
        }

        protected internal override void OnEnter(IFsm<MyFsm> fsm) {
            my.Trace("MyFsmState OnEnter");

        }


        protected internal override void OnUpdate(IFsm<MyFsm> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace("MyFsmState OnUpdate");

        }

        protected internal override void OnLeave(IFsm<MyFsm> fsm, bool isShutdown) {
            my.Trace("MyFsmState OnLeave");

        }


        protected internal override void OnDestroy(IFsm<MyFsm> fsm) {
            base.OnDestroy(fsm);

            my.Trace("MyFsmState OnDestroy");
        }
    }
    public class MyFsmState2 : FsmState<MyFsm> {
        protected internal override void OnInit(IFsm<MyFsm> fsm) {
            my.Trace("MyFsmState2 OnInit");
        }

        protected internal override void OnEnter(IFsm<MyFsm> fsm) {
            my.Trace("MyFsmState2 OnEnter");

        }


        protected internal override void OnUpdate(IFsm<MyFsm> fsm, float elapseSeconds, float realElapseSeconds) {
            my.Trace("MyFsmState2 OnUpdate");

        }

        protected internal override void OnLeave(IFsm<MyFsm> fsm, bool isShutdown) {
            my.Trace("MyFsmState2 OnLeave");

        }


        protected internal override void OnDestroy(IFsm<MyFsm> fsm) {
            base.OnDestroy(fsm);

            my.Trace("MyFsmState2 OnDestroy");
        }
    }
}
