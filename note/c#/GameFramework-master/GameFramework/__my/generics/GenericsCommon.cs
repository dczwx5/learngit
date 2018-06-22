using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;

namespace __my.generics.generics
{
    class GenericsCommon {
        public GenericsCommon() {
        }
        public static void Usage() {
            // TypeUsage();
            my.Trace("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
            // MethodUsage();
            my.Trace("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
            TypeUsageCreateNewObjectByObject();
            my.Trace("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

            TypeUsageCreateNewObjectByObjectGenerics();
        }
        private static void TypeUsage() {
            string s = "kk is bob";
            Type typeS = s.GetType();
            my.Trace("typeS : " + typeS.FullName); // System.String


            // 没有 指定类型的泛型类型
            Type genericType = typeof(CTestRole<>);
            my.Trace("genericType : " + genericType.FullName);

            // 指定类型
            // 获得TestGenrices<typeS.GetType()> 类型 , 由于泛型不能用动态类型表现, 因此用下面的方式
            // TestGenrices<typeS.GetType()>是错误的表达式
            // type = typeof(TestGenrices<Type>); 只能是这样
            genericType = typeof(CTestRole<>).MakeGenericType(typeS); // ~==> type = typeof(TestGenrices<Type>);
            my.Trace("genericType : " + genericType.FullName);

            CTestRoleBase genrices = (CTestRoleBase)Activator.CreateInstance(genericType);
            genrices.Test();
        }


        /// <summary>
        /// TypeUsage2
        /// </summary>
        private class ForTypeUsage2Clz {
            public static int id = 0;
            public ForTypeUsage2Clz() {
                id++;
                my.Trace("\tForTypeUsage2Clz : ID is " + id);
            }
        }
        private class ForTypeUsage2ClzGenerices<T>{
            public static int id = 0;
            public ForTypeUsage2ClzGenerices() {
                id++;
                my.Trace("\tForTypeUsage2Clz : ID is " + id + ", type : " + typeof(T).FullName);
            }
        }
        private static void TypeUsageCreateNewObjectByObject() {
            my.Trace("--------------------在不确定或不知道类型时, 使用对象的类型来创建新对象--------------------------------");
            my.Trace("假设现在有一个对象 : obj");
            ForTypeUsage2Clz obj = new ForTypeUsage2Clz();
            my.Trace("获得obj对象的类型变量objType");
            Type objType = obj.GetType();
            my.Trace("使用Activator.CreateInstance和objType创建对象 : newObj");
            // ForTypeUsage2Clz newObj = (ForTypeUsage2Clz)Activator.CreateInstance(objType);
            Activator.CreateInstance(objType);
            my.Trace("----------------------------------------------------");
        }
        private static void TypeUsageCreateNewObjectByObjectGenerics() {
            my.Trace("--------------------泛型<T> 使用T的对象, 创建新的泛型对象--------------------------------");

            my.Trace("假设现在有一个对象 : obj");
            ForTypeUsage2Clz obj = new ForTypeUsage2Clz();

            my.Trace("获得obj对象的类型变量objType");
            Type objType = obj.GetType();

            my.Trace("使用objType 指定 ForTypeUsage2ClzGenerices<>的泛型类型");
            Type genericesType = typeof(ForTypeUsage2ClzGenerices<>).MakeGenericType(objType);

            my.Trace("使用Activator.CreateInstance和genericesType创建泛型对象 : newObj");
            ForTypeUsage2ClzGenerices<ForTypeUsage2Clz> newObj = (ForTypeUsage2ClzGenerices<ForTypeUsage2Clz>)Activator.CreateInstance(genericesType);
            my.Trace("实际上是不知道ForTypeUsage2ClzGenerices<ForTypeUsage2Clz>的, 如果确定类型, 就不需要使用动态创建对象, 在这里只能通用接口或基类来处理, 这里使用Ojbect基类");
            Object newObj2 = (Object)Activator.CreateInstance(genericesType);
            my.Trace("----------------------------------------------------");

        }

        /// <summary>
        /// MethodUsage
        /// </summary>
        private static void MethodUsage() {
            CTestRoleBase tc = new CTestRoleBase();
            MethodInfo mi = tc.GetType().GetMethod("Test");
            mi.Invoke(tc, null);

            mi = tc.GetType().GetMethod("Test2");
            mi.MakeGenericMethod(typeof(string)).Invoke(tc, null);
        }
    }

    class CTestRoleBase {
        public virtual void Test() {
            my.Trace("TestClass.Test");

        }

        public void Test2<T>() {
            my.Trace("TestClass.Test2<T> " + typeof(T).FullName);

        }
    }
    class CTestRole<T> : CTestRoleBase {
        public override void Test() {
            my.Trace("TestGenrices.Test : " + typeof(T).FullName);

        }
    }
    
}
