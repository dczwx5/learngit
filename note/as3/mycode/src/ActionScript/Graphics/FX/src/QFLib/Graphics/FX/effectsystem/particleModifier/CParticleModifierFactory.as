/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.ParticleInstance;
    import QFLib.Graphics.FX.utils.SlotPool;

    public class CParticleModifierFactory {
    public static const TYPE_FORWARD_MOVE:int = 0;
    public static const TYPE_GRAVITY:int = 1;
    public static const TYPE_ROTATION_FOLLOW_VELOCITY:int = 2;
    public static const TYPE_ROTATION_FOLLOW_ORIGIN:int = 3;
    public static const TYPE_ROTATION_RANDOM:int = 4;
    public static const TYPE_COLOR:int = 5;

    private static const ArrValueType_TYPE_NAME:int = 0;
    private static const ArrValueType_PMDATA_TYPE:int = 1;
    private static const ArrValueType_PM_TYPE:int = 2;

    private static var m_arrModifierTypes:Array = [
            ["forward_move", CPMForwardMoveData, CPMForwardMove],
            ["gravity", CPMGravityData, CPMGravity],
            ["rotation_follow_velocity", CPMRotationFollowVelocityData, CPMRotationFollowVelocity],
            ["rotation_follow_origin", CPMRotationFollowOriginData, CPMRotationFollowOrigin],
            ["emittion_rotation_random", CPMEmittionRotationRandomData, CPMEmittionRotationRandom],
            ["color", CPMColorData, CPMColor]
    ];

    private static var m_thePMDataPools:SlotPool = new SlotPool(m_arrModifierTypes.length, m_createPMData);
    private static var m_thePMPools:SlotPool = new SlotPool(m_arrModifierTypes.length, m_createPM);

    /**
     * Allocate a new ParticleModifier reference. if it is not useful later, you should call ParticleModifierFactory::Deallocate
     * to deallocate this reference.
     * @param theData ParticleModifier config data object
     * @param theParticleSystem particle system
     * @return a new particle modifier reference
     */
    public static function allocate(theData:Object, theParticleSystem:ParticleInstance):CParticleModifier
    {
        //todo : pool to allocate
        var sTypeName:String = theData["type_name"];
        var thePMData:CParticleModifierData;
        var theModifier:CParticleModifier;
        for(var i:int = 0, l:int = m_arrModifierTypes.length; i < l; ++i)
        {
            if(m_arrModifierTypes[i][ArrValueType_TYPE_NAME] == sTypeName)
            {
                var thePMDataPools:SlotPool = m_thePMDataPools;
                thePMData = thePMDataPools.allocate(i) as CParticleModifierData;
                thePMData.loadFromJson(theData);
                var thePMPools:SlotPool = m_thePMPools;
                theModifier = thePMPools.allocate(i) as CParticleModifier;
                theModifier.init(thePMData, theParticleSystem);
                break ;
            }
        }
        return theModifier;
    }

    /**
     * Deallocate the ParticleModifier reference, it will be is unvalid, so you should not use it again.
     * @param theModifier particle modifier reference
     */
    public static function deallocate(theModifier:CParticleModifier):void
    {
        //todo: add pool to deallocate
        if(theModifier != null)theModifier.dispose();
        theModifier = null;
    }

    /**
     * get total count of modifier type
     * @return
     */
    public static function getModifierTypeCount():uint { return m_arrModifierTypes.length; }

    /**
     * Get modifier type name at index, you can use this class static memmber "TYPE"
     * @param index
     * @return
     */
    public static function getModifierTypeNameAt(index:uint):String
    {
        if(index < m_arrModifierTypes.length)
                return m_arrModifierTypes[index][ArrValueType_TYPE_NAME];
        return null;
    }

    private static function m_createPMData(slot:uint):CParticleModifierData
    {
        var sTypeName:String = m_arrModifierTypes[slot][ArrValueType_TYPE_NAME];
        return new m_arrModifierTypes[slot][ArrValueType_PMDATA_TYPE](slot, sTypeName);
    }

    private static function m_createPM(slot:uint):CParticleModifier
    {
        return new  m_arrModifierTypes[slot][ArrValueType_PM_TYPE]();
    }

    public function CParticleModifierFactory() {
    }
}
}
