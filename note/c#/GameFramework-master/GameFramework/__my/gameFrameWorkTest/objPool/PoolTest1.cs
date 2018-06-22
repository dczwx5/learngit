using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using GameFramework.ObjectPool;

namespace __my.gameFrameWorkTest.objPool {
    class PoolTest1 {

        /** 类
         * ObjectBase : 封装管理对象, 可支持一个对象多次引用(多次引用主要用于资源)
         * Object : ObjectBase的具体类, 私有类, 在ObjectPool中使用
         *
         * ObjectPoolBase : 对象池, 保存ObjectBase对象
         * IObjectPool : 为ObjectPoolBase对象提供Register等 接口 (ObjectPoolBase没Register接口)
         * ObjectPool : 实际的对象池类, 继承ObjectPoolBase 和 IObjectPool, 但是是私有类, 由ObjectPoolManager管理
         * 
         * ObjectPoolManager : 对象池管理类. 管理多个对象池
         */

          /** 使用
           * 需要自定义ObjectBase的子类
           * 
           */ 
        public static void Usage() {
            ObjectPoolManager heroPoolManager = new ObjectPoolManager();
           
           //  ObjectPoolBase heroPool = heroPoolManager.CreateSingleSpawnObjectPool(typeof(RoleObject));
            IObjectPool<RoleObject> heroPool2 = heroPoolManager.CreateSingleSpawnObjectPool<RoleObject>();

            Npc npc1 = new Npc();
            RoleObject roleObject = new RoleObject(npc1);
            heroPool2.Register(roleObject, false);
            RoleObject roleObjectInPool = heroPool2.Spawn();

        }

    }
    
    class RoleObject : ObjectBase {
        public RoleObject(RoleBase target) : base(target) {
            __my.my.Trace((Target.GetType().FullName) + " : 创建");

        }
        /// <summary>
        /// 获取对象时的事件。
        /// </summary>
        protected internal override void OnSpawn() {
            __my.my.Trace((Target.GetType().FullName) + " : OnSpawn");
        }

        /// <summary>
        /// 回收对象时的事件。
        /// </summary>
        protected internal override void OnUnspawn() {
            __my.my.Trace((Target.GetType().FullName) + " : OnUnspawn");

        }

        /// <summary>
        /// 释放对象。
        /// </summary>
        protected internal override void Release() {
            __my.my.Trace((Target.GetType().FullName) + " : Release");

        }
    }
    // heroClass
    class RoleBase {

    }
    class Hero : RoleBase {

    }
    class Npc : RoleBase {

    }
}
