/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.Particle;
    import QFLib.Graphics.FX.effectsystem.ParticleInstance;

    public class CParticleModifier {
    private var m_theModifierData:CParticleModifierData;
    private var m_theParticleSystem:ParticleInstance;

    public function CParticleModifier() {

    }

    public virtual function dispose():void
    {
        m_theModifierData = null;
        m_theParticleSystem = null;
    }

    /**
     * Init, update particle system and reset.
     * @param theParticleSystem new particle system
     */
    public function init(theData:CParticleModifierData, theParticleSystem:ParticleInstance = null):void
    {
        m_theModifierData = theData;
        m_theParticleSystem = theParticleSystem;
        _reset();
    }

    /**
     * Reset modifier
     */
    public function reset():void
    {
        _reset();
    }

    /**
     * Get modifier data
     */
    public function get modifierData():CParticleModifierData { return m_theModifierData; }

    /**
     * Process particle when particle is emitted by emittor.
     * @param theParticle
     */
    public function processAfterEmition(theParticle:Particle):void
    {
        _processAfterEmition(theParticle);
    }

    /**
     * Process particle before update(tick) particle.
     * @param theParticle
     * @param fDeltaTime
     */
    public function processBeforeUpdate(theParticle:Particle, fDeltaTime:Number):void
    {
        _processBeforeUpdate(theParticle, fDeltaTime);
    }

    /**
     * Process particle after update(tick) particle.
     * @param theParticle
     * @param fDeltaTime
     */
    public function processAfterUpdate(theParticle:Particle, fDeltaTime:Number):void
    {
        _processAfterUpdate(theParticle, fDeltaTime);
    }

    public function get particleSystem():ParticleInstance { return m_theParticleSystem; }

    /**
     * Get modifier data.
     * Subclass use thi smember function to get modifier data
     */
    protected function _getModifierData():CParticleModifierData { return m_theModifierData; }

    /**
     * Reset modifier data
     * Subclass override this member to implement its logic
     */
    protected virtual function _reset():void
    {

    }

    /**
     * Process particle when particle is emitted by emittor.
     * Subclass override this member function to implement its logic.
     * @param theParticle
     */
    protected virtual function _processAfterEmition(theParticle:Particle):void
    {

    }

    /**
     * Process particle before update(tick) particle
     * Subclass override this member function to implement its logic.
     * @param theParticle
     * @param fDeltaTime
     */
    protected virtual function _processBeforeUpdate(theParticle:Particle, fDeltaTime:Number):void
    {

    }

    /**
     * Process particle after update(tick) particle
     * Subclass override this member to implement its logic
     * @param theParticle
     * @param fDeltaTime
     */
    protected virtual function _processAfterUpdate(theParticle:Particle, fDeltaTime:Number):void
    {

    }

}
}
