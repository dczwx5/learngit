package core.framework
{
	/**
	 * ...
	 * @author auto
	 */
	public interface ILifeCycle {
		// function onAwark() : void;
		// function onStart() : void;
		// function onUpdate(deltaTime:Number) : void;
		// function onFixedUpdate(fixTime:Number) : void;
		// function onDestroy() : void;

		function awake() : void ;
		function start() : void ;
		// function update(deltaTime:Number) : void ;
		// function fixUpdate(fixTime:Number) : void ;
		function destroy() : void;
	}

}