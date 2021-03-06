﻿//----------------------------------------------------------------
// Generated by Excel Table exporter in 2018/8/22 - 12:17:24
//----------------------------------------------------------------


package KOF;

public class Skill
{
    public enum EType { "UNDEFINED, ATTACK, HEAL" }
    public enum ETargetType { "UNDEFINED, PLUS_ONE, ALL" }
    public enum ERange { "SINGLE, LINE, CROSS" }
    public enum EBuffType { "ABC, DEF" }

    public class CRandomTarget
    { 
        public int BuffID;
        public EBuffType BuffType;
        public float BuffChance;
    }
    public class COvercome
    { 
        public int [] TestStructs = new int[ 3 ];
    }

    public int ID;
    public String Name;
    public String Description;
    public String IconName;
    public String SFXName;
    public int ProfessionConstrain;
    public EType Type;
    public ETargetType Target;
    public ERange Range;
    public int NumAddAttacks;
    public ETargetType AddAttackTargetType;
    public int NumTargets;
    public int RestoredRP;
    public int ConsumeHP;
    public int TargetRP;
    public int TargetRPTargetType;
    public int AttackType;
    public int TargetHP;
    public float AttackAddStrength;
    public int SelfBuffID;
    public float SelfBuffAddChance;
    public int TargetBuffID;
    public float TargetBuffAddChance;
    public CRandomTarget RandomTarget = new CRandomTarget();
    public float SuckHPStrength;
    public COvercome Overcome = new COvercome();
    public int [] OvercomeProfessions = new int[ 3 ];
    public float ProfessionAddStrength;
}
